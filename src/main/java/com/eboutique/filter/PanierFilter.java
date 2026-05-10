package com.eboutique.filter;

import com.eboutique.modele.Panier;
import com.eboutique.servlet.PanierServlet;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Filtre panier — restaure le panier depuis le cookie si la session ne l'a pas.
 * Cela permet de conserver le panier après déconnexion/reconnexion.
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

        // Restaurer le panier depuis le cookie si la session ne l'a pas encore
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("panier") == null) {
            String cookieVal = PanierServlet.lireCookiePanier(req);
            if (cookieVal != null && !cookieVal.isBlank()) {
                Panier panierRestaure = PanierServlet.restaurerDepuisCookie(cookieVal);
                if (!panierRestaure.estVide()) {
                    session.setAttribute("panier", panierRestaure);
                }
            }
        }

        chain.doFilter(request, response);
    }
}
