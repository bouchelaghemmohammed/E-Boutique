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
 * Servlet d'inscription (GET + POST /inscription).
 * GET  : affiche le formulaire d'inscription.
 * POST : valide les données, crée le compte et redirige vers la connexion.
 */
@WebServlet(name = "InscriptionServlet", urlPatterns = {"/inscription"})
public class InscriptionServlet extends HttpServlet {

    private final UtilisateurService utilisateurService = new UtilisateurService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Si déjà connecté, pas besoin de s'inscrire à nouveau
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("utilisateurConnecte") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String prenom    = req.getParameter("prenom");
        String nom       = req.getParameter("nom");
        String courriel  = req.getParameter("courriel");
        String mdp       = req.getParameter("motDePasse");
        String mdpConf   = req.getParameter("motDePasseConfirm");
        String telephone = req.getParameter("telephone");
        String adresse   = req.getParameter("adresse");

        // Vérification confirmation mot de passe
        if (mdp == null || !mdp.equals(mdpConf)) {
            req.setAttribute("erreur", "Les mots de passe ne correspondent pas.");
            req.setAttribute("prenom",   prenom);
            req.setAttribute("nom",      nom);
            req.setAttribute("courriel", courriel);
            req.setAttribute("telephone", telephone);
            req.setAttribute("adresse",   adresse);
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            return;
        }

        try {
            Utilisateur nouvel = utilisateurService.inscrire(
                    prenom, nom, courriel, mdp, telephone, adresse);

            // Succès — on informe la page de connexion
            req.getSession().setAttribute("messageSucces",
                    "Inscription réussie ! Bienvenue " + nouvel.getPrenom() + " 🎉");
            resp.sendRedirect(req.getContextPath() + "/connexion");

        } catch (IllegalArgumentException e) {
            req.setAttribute("erreur",    e.getMessage());
            req.setAttribute("prenom",    prenom);
            req.setAttribute("nom",       nom);
            req.setAttribute("courriel",  courriel);
            req.setAttribute("telephone", telephone);
            req.setAttribute("adresse",   adresse);
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
        }
    }
}
