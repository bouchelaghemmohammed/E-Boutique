package com.eboutique.servlet;

import com.eboutique.dao.CommandeDao;
import com.eboutique.dao.UtilisateurDao;
import com.eboutique.modele.Commande;
import com.eboutique.modele.Role;
import com.eboutique.modele.Utilisateur;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * Servlet du tableau de bord (GET /dashboard).
 * Affiche des statistiques personnalisées selon le rôle (USER ou ADMIN).
 */
@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {

    private final CommandeDao    commandeDao    = new CommandeDao();
    private final UtilisateurDao utilisateurDao = new UtilisateurDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session  = req.getSession(false);
        Utilisateur connecte = (Utilisateur) session.getAttribute("utilisateurConnecte");

        if (Role.ADMIN.equals(connecte.getRole())) {
            // ---- Statistiques ADMIN ----
            List<Commande>    toutesCommandes = commandeDao.trouverToutes();
            List<Utilisateur> tousUtilisateurs = utilisateurDao.trouverTous();

            BigDecimal totalVentes = toutesCommandes.stream()
                    .map(Commande::getTotal)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            req.setAttribute("toutesCommandes",   toutesCommandes);
            req.setAttribute("totalVentes",        totalVentes);
            req.setAttribute("nbUtilisateurs",     tousUtilisateurs.size());
            req.setAttribute("nbCommandes",        toutesCommandes.size());

        } else {
            // ---- Statistiques USER ----
            List<Commande> mesCommandes = commandeDao.trouverParUtilisateur(connecte);

            BigDecimal totalDepense = mesCommandes.stream()
                    .map(Commande::getTotal)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            // Les 3 dernières commandes pour l'aperçu rapide
            List<Commande> dernieres = mesCommandes.stream().limit(3).toList();

            req.setAttribute("mesCommandes",  mesCommandes);
            req.setAttribute("dernieres",     dernieres);
            req.setAttribute("totalDepense",  totalDepense);
            req.setAttribute("nbCommandes",   mesCommandes.size());
        }

        req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);
    }
}
