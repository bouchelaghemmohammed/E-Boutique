package com.eboutique.filter;

import com.eboutique.modele.Panier;
import com.eboutique.servlet.PanierServlet;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Filtre panier — restaure le panier depuis le cookie si la session ne l'a pas.
 * Cela permet de conserver le panier après déconnexion/reconnexion.
 */
@WebFilter(filterName = "PanierFilter", urlPatterns = { "/*" })
public class PanierFilter implements Filter {

    private static final Logger LOG = Logger.getLogger(PanierFilter.class.getName());

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

        // Restaurer le panier depuis le cookie si la session ne contient pas de panier.
        // On lit d'abord le cookie AVANT de créer/ouvrir la session pour éviter de
        // créer une session inutile sur chaque requête anonyme.
        String cookieVal = PanierServlet.lireCookiePanier(req);
        if (cookieVal != null && !cookieVal.isBlank()) {
            // Cookie présent → ouvrir (ou créer) la session et restaurer le panier
            HttpSession session = req.getSession(true);
            if (session.getAttribute("panier") == null) {
                try {
                    Panier panierRestaure = PanierServlet.restaurerDepuisCookie(cookieVal);
                    if (!panierRestaure.estVide()) {
                        session.setAttribute("panier", panierRestaure);
                    }
                } catch (Exception e) {
                    LOG.log(Level.WARNING, "[PanierFilter] Echec restauration panier depuis cookie", e);
                }
            }
        }

        chain.doFilter(request, response);
    }
}
