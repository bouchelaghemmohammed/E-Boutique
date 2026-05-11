package com.eboutique.filter;

import com.eboutique.dao.UserDao;
import com.eboutique.modele.User;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.logging.Logger;

/**
 * Filtre d'authentification.
 * Protège les URLs sensibles contre les accès non authentifiés.
 * Si l'utilisateur n'est pas connecté, il est redirigé vers /connexion
 * avec l'URL originale en paramètre "redirect".
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = { "/*" })
public class AuthFilter implements Filter {

    private static final Logger LOG = Logger.getLogger(AuthFilter.class.getName());

    /** URLs publiques accessibles sans connexion. */
    private static final List<String> URLS_PUBLIQUES = Arrays.asList(
            "/connexion",
            "/inscription",
            "/catalogue",
            "/produit");

    /** Préfixes de ressources statiques toujours accessibles. */
    private static final List<String> PREFIXES_STATIQUES = Arrays.asList(
            "/assets/",
            "/WEB-INF/");

    private static final String COOKIE_REMEMBER = "remember_me";
    private final UserDao userDao = new UserDao();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String contextPath = req.getContextPath();
        String requestURI = req.getRequestURI();
        String chemin = requestURI.substring(contextPath.length());

        // Laisser passer les ressources statiques
        for (String prefix : PREFIXES_STATIQUES) {
            if (chemin.startsWith(prefix)) {
                chain.doFilter(request, response);
                return;
            }
        }

        // Laisser passer la racine (redirigée par AccueilServlet)
        if ("/".equals(chemin) || chemin.isEmpty() || chemin.equals("/accueil")) {
            chain.doFilter(request, response);
            return;
        }

        // Laisser passer les URLs publiques
        for (String url : URLS_PUBLIQUES) {
            if (chemin.startsWith(url)) {
                chain.doFilter(request, response);
                return;
            }
        }

        // Vérifier la session
        HttpSession session = req.getSession(false);
        boolean connecte = session != null && session.getAttribute("utilisateurConnecte") != null;

        if (!connecte) {
            // Tentative d'auto-login via le cookie "remember_me" (30 jours)
            connecte = tryAutoLogin(req);
        }

        if (!connecte) {
            // Sauvegarder l'URL pour rediriger après connexion
            String redirect = chemin;
            if (req.getQueryString() != null) {
                redirect += "?" + req.getQueryString();
            }
            resp.sendRedirect(contextPath + "/connexion?redirect=" +
                    java.net.URLEncoder.encode(redirect, "UTF-8"));
            return;
        }

        chain.doFilter(request, response);
    }

    /**
     * essaie de reconnecter automatiquement l'utilisateur depuis le cookie
     * remember_me.
     * Crée une nouvelle session et y place l'utilisateur + restaure le panier.
     * 
     * @return true si l'auto-login a réussi.
     */
    private boolean tryAutoLogin(HttpServletRequest req) {
        Cookie[] cookies = req.getCookies();
        if (cookies == null)
            return false;

        for (Cookie c : cookies) {
            if (COOKIE_REMEMBER.equals(c.getName()) && c.getValue() != null && !c.getValue().isBlank()) {
                try {
                    String email = URLDecoder.decode(c.getValue(), StandardCharsets.UTF_8);
                    Optional<User> opt = userDao.trouverParEmail(email);
                    if (opt.isPresent() && opt.get().isEnabled()) {
                        User user = opt.get();
                        // Invalider l'ancienne session anonyme éventuelle
                        HttpSession old = req.getSession(false);
                        if (old != null)
                            old.invalidate();
                        HttpSession newSession = req.getSession(true);
                        newSession.setAttribute("utilisateurConnecte", user);
                        newSession.setMaxInactiveInterval(30 * 60);
                        LOG.info("[AuthFilter] Auto-login réussi pour : " + user.getEmail());
                        return true;
                    } else if (!opt.isPresent()) {
                        LOG.warning("[AuthFilter] Auto-login: aucun utilisateur trouvé pour l'email du cookie.");
                    } else {
                        LOG.warning("[AuthFilter] Auto-login: compte désactivé.");
                    }
                } catch (Exception e) {
                    LOG.warning(
                            "[AuthFilter] Échec auto-login: " + e.getClass().getSimpleName() + ": " + e.getMessage());
                }
                break;
            }
        }
        return false;
    }
}