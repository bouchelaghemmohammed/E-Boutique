package com.eboutique.filter;

import com.eboutique.modele.Role;
import com.eboutique.modele.Utilisateur;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Filtre de contrôle des rôles.
 * Protège les URLs /admin/* contre les accès par des utilisateurs non-ADMIN.
 * Suppose que AuthFilter a déjà vérifié que l'utilisateur est connecté.
 */
@WebFilter(filterName = "RoleFilter", urlPatterns = {"/admin/*"})
public class RoleFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("utilisateurConnecte") == null) {
            resp.sendRedirect(req.getContextPath() + "/connexion");
            return;
        }

        Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateurConnecte");

        if (!Role.ADMIN.equals(utilisateur.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/dashboard?erreur=acces_refuse");
            return;
        }

        chain.doFilter(request, response);
    }
}
