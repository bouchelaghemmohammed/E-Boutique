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
 * Servlet d'inscription (GET + POST /inscription).
 */
@WebServlet(name = "InscriptionServlet", urlPatterns = {"/inscription"})
public class InscriptionServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

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
        String email     = req.getParameter("courriel");
        String mdp       = req.getParameter("motDePasse");
        String mdpConf   = req.getParameter("motDePasseConfirm");

        if (mdp == null || !mdp.equals(mdpConf)) {
            req.setAttribute("erreur", "Les mots de passe ne correspondent pas.");
            req.setAttribute("prenom",   prenom);
            req.setAttribute("nom",      nom);
            req.setAttribute("courriel", email);
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            return;
        }

        try {
            userService.inscrire(prenom, nom, email, mdp);

            req.getSession().setAttribute("messageSucces",
                    "Inscription réussie ! Bienvenue " + prenom + " 🎉");
            resp.sendRedirect(req.getContextPath() + "/connexion");

        } catch (Exception e) {
            req.setAttribute("erreur",    e.getMessage());
            req.setAttribute("prenom",    prenom);
            req.setAttribute("nom",       nom);
            req.setAttribute("courriel",  email);
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
        }
    }
}
