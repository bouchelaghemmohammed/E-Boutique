package com.eboutique.servlet;

import com.eboutique.modele.Panier;
import com.eboutique.modele.User;
import com.eboutique.service.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Optional;

/**
 * Servlet de connexion (GET + POST /connexion).
 */
@WebServlet(name = "ConnexionServlet", urlPatterns = { "/connexion" })
public class ConnexionServlet extends HttpServlet {

    private static final String COOKIE_REMEMBER = "remember_me";
    private static final int COOKIE_MAX_AGE = 30 * 24 * 3600; // 30 jours

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("utilisateurConnecte") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        String courrielSauvegarde = lireCookieRememberMe(req);
        if (courrielSauvegarde != null) {
            req.setAttribute("courrielSauvegarde", courrielSauvegarde);
        }

        HttpSession sess = req.getSession(false);
        if (sess != null) {
            String msg = (String) sess.getAttribute("messageSucces");
            if (msg != null) {
                req.setAttribute("messageSucces", msg);
                sess.removeAttribute("messageSucces");
            }
        }

        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String courriel = req.getParameter("courriel");
        String motDePasse = req.getParameter("motDePasse");
        String rememberMe = req.getParameter("rememberMe");
        String redirect = req.getParameter("redirect");

        Optional<User> optUser = userService.connecter(courriel, motDePasse);

        if (optUser.isEmpty()) {
            req.setAttribute("erreur", "Identifiants incorrects. Vérifiez votre courriel et mot de passe.");
            req.setAttribute("courriel", courriel);
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        User user = optUser.get();

        // 1) Récupérer le panier depuis la session courante (PanierFilter a pu le
        // restaurer)
        HttpSession oldSession = req.getSession(false);
        Panier panierAvantConnexion = null;
        if (oldSession != null) {
            panierAvantConnexion = (Panier) oldSession.getAttribute("panier");
            oldSession.invalidate();
        }

        // 2) Fallback direct depuis le cookie (si la session n'avait pas de panier)
        if (panierAvantConnexion == null || panierAvantConnexion.estVide()) {
            String cookieVal = PanierServlet.lireCookiePanier(req);
            if (cookieVal != null && !cookieVal.isBlank()) {
                try {
                    panierAvantConnexion = PanierServlet.restaurerDepuisCookie(cookieVal);
                } catch (Exception e) {
                    // panier sera vide — pas critique
                }
            }
        }

        // Nouvelle session (protection contre la fixation de session)
        HttpSession session = req.getSession(true);
        session.setAttribute("utilisateurConnecte", user);
        session.setMaxInactiveInterval(30 * 60);

        // Transférer le panier vers la nouvelle session
        if (panierAvantConnexion != null && !panierAvantConnexion.estVide()) {
            session.setAttribute("panier", panierAvantConnexion);
        }

        if ("on".equals(rememberMe) || "true".equals(rememberMe)) {
            String encoded = URLEncoder.encode(user.getEmail(), StandardCharsets.UTF_8);
            Cookie cookie = new Cookie(COOKIE_REMEMBER, encoded);
            cookie.setMaxAge(COOKIE_MAX_AGE);
            cookie.setPath(req.getContextPath().isEmpty() ? "/" : req.getContextPath());
            cookie.setHttpOnly(true);
            resp.addCookie(cookie);
        } else {
            supprimerCookieRememberMe(req, resp);
        }

        if (redirect != null && !redirect.isBlank() && redirect.startsWith("/")) {
            resp.sendRedirect(req.getContextPath() + redirect);
        } else {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        }
    }

    private String lireCookieRememberMe(HttpServletRequest req) {
        Cookie[] cookies = req.getCookies();
        if (cookies == null)
            return null;
        for (Cookie c : cookies) {
            if (COOKIE_REMEMBER.equals(c.getName())) {
                try {
                    return URLDecoder.decode(c.getValue(), StandardCharsets.UTF_8);
                } catch (Exception e) {
                    return c.getValue();
                }
            }
        }
        return null;
    }

    private void supprimerCookieRememberMe(HttpServletRequest req, HttpServletResponse resp) {
        Cookie[] cookies = req.getCookies();
        if (cookies == null)
            return;
        for (Cookie c : cookies) {
            if (COOKIE_REMEMBER.equals(c.getName())) {
                c.setMaxAge(0);
                c.setPath(req.getContextPath().isEmpty() ? "/" : req.getContextPath());
                resp.addCookie(c);
                return;
            }
        }
    }
}
