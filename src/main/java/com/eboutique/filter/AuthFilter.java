package com.eboutique.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

/**
 * Filtre d'authentification.
 * Protège les URLs sensibles contre les accès non authentifiés.
 * Si l'utilisateur n'est pas connecté, il est redirigé vers /connexion
 * avec l'URL originale en paramètre "redirect".
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
public class AuthFilter implements Filter {

    /** URLs publiques accessibles sans connexion. */
    private static final List<String> URLS_PUBLIQUES = Arrays.asList(
            "/connexion",
            "/inscription",
            "/catalogue",
            "/produit"
    );

    /** Préfixes de ressources statiques toujours accessibles. */
    private static final List<String> PREFIXES_STATIQUES = Arrays.asList(
            "/assets/",
            "/WEB-INF/"
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String contextPath = req.getContextPath();
        String requestURI  = req.getRequestURI();
        String chemin      = requestURI.substring(contextPath.length());

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
        boolean connecte    = session != null && session.getAttribute("utilisateurConnecte") != null;

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
}
