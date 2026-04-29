package com.eboutique.servlet;

import com.eboutique.dao.CommandeDao;
import com.eboutique.modele.Commande;
import com.eboutique.modele.Utilisateur;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "HistoriqueCommandesServlet", urlPatterns = {"/historique"})
public class HistoriqueCommandesServlet extends HttpServlet {

    private final CommandeDao commandeDao = new CommandeDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Utilisateur utilisateur = session == null
                ? null
                : (Utilisateur) session.getAttribute("utilisateurConnecte");

        if (utilisateur == null) {
            resp.sendRedirect(req.getContextPath() + "/connexion");
            return;
        }

        List<Commande> commandes = commandeDao.trouverParUtilisateur(utilisateur);
        req.setAttribute("commandes", commandes);

        String confirmee = req.getParameter("confirmee");
        if (confirmee != null) {
            req.setAttribute("commandeConfirmee", confirmee);
        }

        req.getRequestDispatcher("/WEB-INF/views/historique-commandes.jsp").forward(req, resp);
    }
}
