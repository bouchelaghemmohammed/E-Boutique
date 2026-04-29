package com.eboutique.servlet;

import com.eboutique.modele.Panier;
import com.eboutique.modele.Produit;
import com.eboutique.util.JpaUtil;

import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "PanierServlet", urlPatterns = {"/panier"})
public class PanierServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        afficher(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "voir";

        switch (action) {
            case "ajouter" -> ajouter(req, resp);
            case "modifier" -> modifier(req, resp);
            case "retirer" -> retirer(req, resp);
            case "vider" -> vider(req, resp);
            default -> afficher(req, resp);
        }
    }

    private void afficher(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Panier panier = getPanier(req);
        req.setAttribute("panier", panier);
        req.getRequestDispatcher("/WEB-INF/views/panier.jsp").forward(req, resp);
    }

    private void ajouter(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Long produitId = parseLong(req.getParameter("produitId"));
        int quantite = parseInt(req.getParameter("quantite"), 1);
        if (produitId == null || quantite <= 0) {
            redirigerVersPanier(req, resp);
            return;
        }

        Panier panier = getPanier(req);
        EntityManager em = JpaUtil.getEntityManager();
        try {
            Produit produit = em.find(Produit.class, produitId);
            if (produit != null) {
                panier.ajouterArticle(produit, quantite);
            }
        } finally {
            em.close();
        }
        redirigerVersPanier(req, resp);
    }

    private void modifier(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Long produitId = parseLong(req.getParameter("produitId"));
        int quantite = parseInt(req.getParameter("quantite"), 0);
        if (produitId != null) {
            getPanier(req).modifierQuantite(produitId, quantite);
        }
        redirigerVersPanier(req, resp);
    }

    private void retirer(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Long produitId = parseLong(req.getParameter("produitId"));
        if (produitId != null) {
            getPanier(req).retirerArticle(produitId);
        }
        redirigerVersPanier(req, resp);
    }

    private void vider(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        getPanier(req).vider();
        redirigerVersPanier(req, resp);
    }

    private Panier getPanier(HttpServletRequest req) {
        HttpSession session = req.getSession();
        Panier panier = (Panier) session.getAttribute("panier");
        if (panier == null) {
            panier = new Panier();
            session.setAttribute("panier", panier);
        }
        return panier;
    }

    private void redirigerVersPanier(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/panier");
    }

    private Long parseLong(String s) {
        try { return s == null ? null : Long.parseLong(s); }
        catch (NumberFormatException e) { return null; }
    }

    private int parseInt(String s, int defaut) {
        try { return s == null ? defaut : Integer.parseInt(s); }
        catch (NumberFormatException e) { return defaut; }
    }
}
