package com.eboutique.servlet;

import com.eboutique.modele.Order;
import com.eboutique.modele.Panier;
import com.eboutique.modele.User;
import com.eboutique.service.OrderService;
import com.eboutique.service.MailService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

    private final OrderService orderService = new OrderService();
    private final MailService mailService = new MailService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Panier panier = getPanier(req);
        if (panier == null || panier.estVide()) {
            resp.sendRedirect(req.getContextPath() + "/panier");
            return;
        }
        if (getUtilisateurConnecte(req) == null) {
            resp.sendRedirect(req.getContextPath() + "/connexion");
            return;
        }

        req.setAttribute("panier", panier);
        req.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Panier panier = getPanier(req);
        User user = getUtilisateurConnecte(req);

        if (panier == null || panier.estVide()) {
            resp.sendRedirect(req.getContextPath() + "/panier");
            return;
        }
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/connexion");
            return;
        }

        String adresse = req.getParameter("adresseLivraison");
        if (adresse == null || adresse.isBlank()) {
            req.setAttribute("erreur", "L'adresse de livraison est obligatoire.");
            req.setAttribute("panier", panier);
            req.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(req, resp);
            return;
        }

        try {
            Order order = orderService.passerCommande(user, panier.getContenuPourService(), adresse);
            
            try {
                mailService.envoyerConfirmationCommande(order);
            } catch (Exception e) {
                getServletContext().log("Echec envoi email pour commande " + order.getId(), e);
            }

            panier.vider();
            resp.sendRedirect(req.getContextPath() + "/historique?confirmee=" + order.getId());

        } catch (Exception e) {
            req.setAttribute("erreur", "Erreur lors de l'enregistrement de la commande : " + e.getMessage());
            req.setAttribute("panier", panier);
            req.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(req, resp);
        }
    }

    private Panier getPanier(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (Panier) session.getAttribute("panier");
    }

    private User getUtilisateurConnecte(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (User) session.getAttribute("utilisateurConnecte");
    }
}
