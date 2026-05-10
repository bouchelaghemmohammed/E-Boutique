package com.eboutique.servlet;

import com.eboutique.modele.LignePanier;
import com.eboutique.modele.Panier;
import com.eboutique.modele.Product;
import com.eboutique.util.JpaUtil;

import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet du panier (GET + POST /panier).
 * Le panier est stocké en session ET persisté dans un cookie
 * pour survivre aux déconnexions/reconnexions.
 * Format cookie : "produitId1:qty1|produitId2:qty2|..."
 */
@WebServlet(name = "PanierServlet", urlPatterns = { "/panier" })
public class PanierServlet extends HttpServlet {

    public static final String COOKIE_PANIER = "panier_data";
    private static final int COOKIE_MAX_AGE = 30 * 24 * 3600; // 30 jours

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        afficher(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null)
            action = "voir";

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
            Product produit = em.find(Product.class, produitId);
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
        Panier panier = getPanier(req);
        if (produitId != null) {
            panier.modifierQuantite(produitId, quantite);
        }
        redirigerVersPanier(req, resp);
    }

    private void retirer(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Long produitId = parseLong(req.getParameter("produitId"));
        Panier panier = getPanier(req);
        if (produitId != null) {
            panier.retirerArticle(produitId);
        }
        redirigerVersPanier(req, resp);
    }

    private void vider(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Panier panier = getPanier(req);
        panier.vider();
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

    /**
     * Reconstruit un Panier à partir du contenu brut du cookie.
     */
    public static Panier restaurerDepuisCookie(String cookieVal) {
        Panier panier = new Panier();
        if (cookieVal == null || cookieVal.isBlank())
            return panier;
        EntityManager em = JpaUtil.getEntityManager();
        try {
            for (String entry : cookieVal.split("\\|")) {
                String[] parts = entry.split(":");
                if (parts.length != 2)
                    continue;
                try {
                    long id = Long.parseLong(parts[0].trim());
                    int qty = Integer.parseInt(parts[1].trim());
                    if (qty <= 0)
                        continue;
                    Product p = em.find(Product.class, id);
                    if (p != null)
                        panier.ajouterArticle(p, qty);
                } catch (NumberFormatException ignored) {
                }
            }
        } finally {
            em.close();
        }
        return panier;
    }

    /**
     * Sérialise le panier dans un cookie : "id1:qty1|id2:qty2|..."
     */
    public static void sauvegarderCookie(Panier panier, HttpServletRequest req, HttpServletResponse resp) {
        String cookiePath = req.getContextPath().isEmpty() ? "/" : req.getContextPath();
        if (panier == null || panier.estVide()) {
            // Supprimer le cookie si panier vide
            Cookie c = new Cookie(COOKIE_PANIER, "");
            c.setMaxAge(0);
            c.setPath(cookiePath);
            c.setHttpOnly(true);
            resp.addCookie(c);
            return;
        }
        StringBuilder sb = new StringBuilder();
        for (LignePanier ligne : panier.getLignes()) {
            if (sb.length() > 0)
                sb.append("|");
            sb.append(ligne.getProduit().getId()).append(":").append(ligne.getQuantite());
        }
        Cookie c = new Cookie(COOKIE_PANIER, sb.toString());
        c.setMaxAge(COOKIE_MAX_AGE);
        c.setPath(cookiePath);
        c.setHttpOnly(true);
        resp.addCookie(c);
    }

    /**
     * Lit le cookie panier et retourne son contenu brut (peut être null).
     */
    public static String lireCookiePanier(HttpServletRequest req) {
        Cookie[] cookies = req.getCookies();
        if (cookies == null)
            return null;
        for (Cookie c : cookies) {
            if (COOKIE_PANIER.equals(c.getName()) && !c.getValue().isEmpty()) {
                return c.getValue();
            }
        }
        return null;
    }

    private void redirigerVersPanier(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/panier");
    }

    private Long parseLong(String s) {
        try {
            return s == null ? null : Long.parseLong(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private int parseInt(String s, int defaut) {
        try {
            return s == null ? defaut : Integer.parseInt(s.trim());
        } catch (NumberFormatException e) {
            return defaut;
        }
    }
}
