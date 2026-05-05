package com.eboutique.servlet;

import com.eboutique.modele.Utilisateur;
import com.eboutique.service.UtilisateurService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet du profil utilisateur (GET + POST /profil).
 * GET  : affiche les informations du profil.
 * POST : met à jour les infos personnelles et/ou le mot de passe.
 */
@WebServlet(name = "ProfilServlet", urlPatterns = {"/profil"})
public class ProfilServlet extends HttpServlet {

    private final UtilisateurService utilisateurService = new UtilisateurService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/profil.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Utilisateur connecte = (Utilisateur) session.getAttribute("utilisateurConnecte");

        String action    = req.getParameter("action");
        String prenom    = req.getParameter("prenom");
        String nom       = req.getParameter("nom");
        String telephone = req.getParameter("telephone");
        String adresse   = req.getParameter("adresse");

        try {
            if ("changerMotDePasse".equals(action)) {
                // --- Changement de mot de passe ---
                String ancienMdp  = req.getParameter("ancienMotDePasse");
                String nouveauMdp = req.getParameter("nouveauMotDePasse");
                String confMdp    = req.getParameter("confirmerMotDePasse");

                if (!nouveauMdp.equals(confMdp)) {
                    req.setAttribute("erreurMdp", "Les nouveaux mots de passe ne correspondent pas.");
                    req.getRequestDispatcher("/WEB-INF/views/profil.jsp").forward(req, resp);
                    return;
                }
                utilisateurService.changerMotDePasse(connecte.getId(), ancienMdp, nouveauMdp);
                req.setAttribute("succesMdp", "Mot de passe modifié avec succès !");

            } else {
                // --- Mise à jour du profil ---
                Utilisateur mis = utilisateurService.mettreAJourProfil(
                        connecte.getId(), prenom, nom, telephone, adresse);

                // Mettre à jour l'objet en session
                session.setAttribute("utilisateurConnecte", mis);
                req.setAttribute("succesInfos", "Profil mis à jour avec succès !");
            }
        } catch (IllegalArgumentException e) {
            if ("changerMotDePasse".equals(action)) {
                req.setAttribute("erreurMdp", e.getMessage());
            } else {
                req.setAttribute("erreurInfos", e.getMessage());
            }
        }

        req.getRequestDispatcher("/WEB-INF/views/profil.jsp").forward(req, resp);
    }
}
