package com.eboutique.servlet;

import com.eboutique.modele.Utilisateur;
import com.eboutique.service.UtilisateurService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Optional;

/**
 * Servlet de connexion (GET + POST /connexion).
 * GET : affiche le formulaire de login (prérempli via cookie remember-me).
 * POST : authentifie, stocke l'utilisateur en session, gère le cookie.
 */
@WebServlet(name = "ConnexionServlet", urlPatterns = { "/connexion" })
public class ConnexionServlet extends HttpServlet {

    private static final String COOKIE_REMEMBER = "remember_me";
    private static final int COOKIE_MAX_AGE = 30 * 24 * 3600; // 30 jours

    private final UtilisateurService utilisateurService = new UtilisateurService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Si déjà connecté, rediriger vers le dashboard
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("utilisateurConnecte") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        // Lire cookie remember-me pour préremplir l'email
        String courrielSauvegarde = lireCookieRememberMe(req);
        if (courrielSauvegarde != null) {
            req.setAttribute("courrielSauvegarde", courrielSauvegarde);
        }

        // Message de succès depuis l'inscription
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

        Optional<Utilisateur> optUtil = utilisateurService.connecter(courriel, motDePasse);

        if (optUtil.isEmpty()) {
            req.setAttribute("erreur", "Identifiants incorrects. Vérifiez votre courriel et mot de passe.");
            req.setAttribute("courriel", courriel);
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        Utilisateur utilisateur = optUtil.get();

        // Créer la session
        HttpSession session = req.getSession(true);
        session.setAttribute("utilisateurConnecte", utilisateur);
        session.setMaxInactiveInterval(30 * 60); // 30 min

        // Gérer le cookie remember-me
        if ("on".equals(rememberMe) || "true".equals(rememberMe)) {
            Cookie cookie = new Cookie(COOKIE_REMEMBER, utilisateur.getEmail());
            cookie.setMaxAge(COOKIE_MAX_AGE);
            cookie.setPath(req.getContextPath().isEmpty() ? "/" : req.getContextPath());
            cookie.setHttpOnly(true);
            resp.addCookie(cookie);
        } else {
            // Supprimer le cookie s'il existe
            supprimerCookieRememberMe(req, resp);
        }

        // Rediriger vers l'URL demandée ou le dashboard
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
                return c.getValue();
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
