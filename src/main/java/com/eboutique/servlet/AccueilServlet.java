package com.eboutique.servlet;

import com.eboutique.modele.Utilisateur;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet d'accueil (GET /).
 * Redirige vers le dashboard si l'utilisateur est connecté,
 * sinon vers la page de connexion.
 */
@WebServlet(name = "AccueilServlet", urlPatterns = {"/accueil"})
public class AccueilServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        boolean connecte = session != null && session.getAttribute("utilisateurConnecte") != null;

        if (connecte) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        } else {
            resp.sendRedirect(req.getContextPath() + "/connexion");
        }
    }
}
