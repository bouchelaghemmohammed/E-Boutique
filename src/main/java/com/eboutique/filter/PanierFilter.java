package com.eboutique.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;

import java.io.IOException;

/**
 * Filtre panier — le panier est désormais géré uniquement en HttpSession.
 * Ce filtre se contente de laisser passer les requêtes (hors ressources
 * statiques).
 */
@WebFilter(filterName = "PanierFilter", urlPatterns = { "/*" })
public class PanierFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        String uri = req.getRequestURI();
        String ctx = req.getContextPath();
        String chemin = uri.startsWith(ctx) ? uri.substring(ctx.length()) : uri;

        // Ignorer les ressources statiques
        if (chemin.startsWith("/assets/") || chemin.startsWith("/WEB-INF/")) {
            chain.doFilter(request, response);
            return;
        }

        chain.doFilter(request, response);
    }
}
