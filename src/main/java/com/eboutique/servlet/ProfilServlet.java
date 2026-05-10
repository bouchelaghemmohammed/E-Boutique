package com.eboutique.servlet;

import com.eboutique.modele.User;
import com.eboutique.service.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet du profil utilisateur (GET + POST /profil).
 */
@WebServlet(name = "ProfilServlet", urlPatterns = { "/profil" })
public class ProfilServlet extends HttpServlet {

    private final UserService userService = new UserService();

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
        User connecte = (User) session.getAttribute("utilisateurConnecte");

        String action = req.getParameter("action");
        String firstName = req.getParameter("prenom");
        String lastName = req.getParameter("nom");
        String email = req.getParameter("email");
        String adresseLivraison = req.getParameter("adresseLivraison");

        try {
            if ("changerMotDePasse".equals(action)) {
                String ancienMdp = req.getParameter("ancienMotDePasse");
                String nouveauMdp = req.getParameter("nouveauMotDePasse");
                String confMdp = req.getParameter("confirmerMotDePasse");

                if (!nouveauMdp.equals(confMdp)) {
                    req.setAttribute("erreurMdp", "Les nouveaux mots de passe ne correspondent pas.");
                    req.getRequestDispatcher("/WEB-INF/views/profil.jsp").forward(req, resp);
                    return;
                }
                userService.changerMotDePasse(connecte.getId(), ancienMdp, nouveauMdp);
                req.setAttribute("succesMdp", "Mot de passe modifié avec succès !");

            } else {
                User mis = userService.mettreAJourProfil(connecte.getId(), firstName, lastName, email,
                        adresseLivraison);
                session.setAttribute("utilisateurConnecte", mis);
                req.setAttribute("succesInfos", "Profil mis à jour avec succès !");
            }
        } catch (Exception e) {
            if ("changerMotDePasse".equals(action)) {
                req.setAttribute("erreurMdp", e.getMessage());
            } else {
                req.setAttribute("erreurInfos", e.getMessage());
            }
        }

        req.getRequestDispatcher("/WEB-INF/views/profil.jsp").forward(req, resp);
    }
}
