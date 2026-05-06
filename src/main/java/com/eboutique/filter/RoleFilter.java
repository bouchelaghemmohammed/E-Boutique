package com.eboutique.filter;

import com.eboutique.modele.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Filtre de contrôle des rôles.
 * Protège les URLs /admin/* contre les accès par des utilisateurs non-ADMIN.
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

        User user = (User) session.getAttribute("utilisateurConnecte");

        if (!user.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard?erreur=acces_refuse");
            return;
        }

        chain.doFilter(request, response);
    }
}
