package com.eboutique.servlet;

import com.eboutique.modele.Category;
import com.eboutique.modele.Product;
import com.eboutique.service.ProductService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * Servlet admin — CRUD produits.
 * Accessible uniquement aux ADMIN (protégé par RoleFilter).
 *
 * GET /admin/produits → liste des produits
 * GET /admin/produits?action=nouveau → formulaire création
 * GET /admin/produits?action=modifier&id=X → formulaire édition
 * POST /admin/produits → sauvegarder (créer ou modifier)
 * POST /admin/produits?action=supprimer&id=X → supprimer
 */
@WebServlet(name = "AdminProduitsServlet", urlPatterns = { "/admin/produits" })
public class AdminProduitsServlet extends HttpServlet {

    private final ProductService productService = new ProductService();

    /* ─────────────────── GET ─────────────────── */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("nouveau".equals(action)) {
            afficherFormulaire(req, resp, null);

        } else if ("modifier".equals(action)) {
            Long id = parseLong(req.getParameter("id"));
            if (id == null) {
                resp.sendRedirect(req.getContextPath() + "/admin/produits");
                return;
            }
            Product p = productService.trouverParId(id).orElse(null);
            if (p == null) {
                resp.sendRedirect(req.getContextPath() + "/admin/produits");
                return;
            }
            req.setAttribute("produit", p);
            afficherFormulaire(req, resp, id);

        } else {
            // Liste
            List<Product> produits = productService.listerTousLesProduits();
            req.setAttribute("produits", produits);

            // Flash messages
            recupererFlash(req);

            req.getRequestDispatcher("/WEB-INF/views/admin-produits.jsp").forward(req, resp);
        }
    }

    /* ─────────────────── POST ─────────────────── */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("supprimer".equals(action)) {
            Long id = parseLong(req.getParameter("id"));
            if (id != null) {
                try {
                    productService.supprimer(id);
                    req.getSession().setAttribute("_flash_success", "Produit supprimé avec succès.");
                } catch (Exception e) {
                    req.getSession().setAttribute("_flash_error", "Impossible de supprimer : " + e.getMessage());
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/produits");

        } else {
            // Sauvegarder (créer ou modifier)
            String idStr = req.getParameter("id");
            String nom = req.getParameter("nom");
            String description = req.getParameter("description");
            String prixStr = req.getParameter("prix");
            String stockStr = req.getParameter("stock");
            String imagePath = req.getParameter("imagePath");
            String catIdStr = req.getParameter("categorieId");

            // Validation minimale
            if (nom == null || nom.isBlank()) {
                req.setAttribute("erreurForm", "Le nom du produit est obligatoire.");
                afficherFormulaire(req, resp, parseLong(idStr));
                return;
            }

            BigDecimal prix;
            try {
                prix = new BigDecimal(prixStr.replace(",", ".").trim());
                if (prix.compareTo(BigDecimal.ZERO) < 0)
                    throw new NumberFormatException();
            } catch (Exception e) {
                req.setAttribute("erreurForm", "Le prix est invalide (ex : 19.99).");
                afficherFormulaire(req, resp, parseLong(idStr));
                return;
            }

            int stock;
            try {
                stock = Integer.parseInt(stockStr.trim());
            } catch (Exception e) {
                stock = 0;
            }

            Long produitId = parseLong(idStr);
            Long catId = parseLong(catIdStr);

            // Trouver la catégorie
            Category categorie = null;
            if (catId != null) {
                categorie = productService.listerCategories().stream()
                        .filter(c -> c.getId().equals(catId))
                        .findFirst().orElse(null);
            }
            // Si aucune catégorie choisie, prendre "Autre"
            if (categorie == null) {
                categorie = productService.listerCategories().stream()
                        .filter(c -> "Autre".equalsIgnoreCase(c.getName()))
                        .findFirst().orElse(null);
            }

            if (produitId != null) {
                // Mise à jour
                Product p = productService.trouverParId(produitId).orElse(null);
                if (p != null) {
                    p.setName(nom.trim());
                    p.setDescription(description);
                    p.setPrice(prix);
                    p.setStock(stock);
                    p.setImagePath(imagePath != null && !imagePath.isBlank() ? imagePath.trim() : null);
                    p.setCategory(categorie);
                    productService.mettreAJour(p);
                    req.getSession().setAttribute("_flash_success", "Produit modifié avec succès.");
                }
            } else {
                // Création
                Product p = new Product();
                p.setName(nom.trim());
                p.setDescription(description);
                p.setPrice(prix);
                p.setStock(stock);
                p.setImagePath(imagePath != null && !imagePath.isBlank() ? imagePath.trim() : null);
                p.setCategory(categorie);
                productService.creerProduit(p);
                req.getSession().setAttribute("_flash_success", "Produit créé avec succès.");
            }

            resp.sendRedirect(req.getContextPath() + "/admin/produits");
        }
    }

    /* ─────────────────── Helpers ─────────────────── */

    private void afficherFormulaire(HttpServletRequest req, HttpServletResponse resp, Long produitId)
            throws ServletException, IOException {
        List<Category> categories = productService.listerCategories();
        req.setAttribute("categories", categories);
        req.setAttribute("produitId", produitId);
        req.getRequestDispatcher("/WEB-INF/views/admin-produit-form.jsp").forward(req, resp);
    }

    private void recupererFlash(HttpServletRequest req) {
        Object success = req.getSession().getAttribute("_flash_success");
        Object error = req.getSession().getAttribute("_flash_error");
        if (success != null) {
            req.setAttribute("flashSuccess", success.toString());
            req.getSession().removeAttribute("_flash_success");
        }
        if (error != null) {
            req.setAttribute("flashError", error.toString());
            req.getSession().removeAttribute("_flash_error");
        }
    }

    private Long parseLong(String s) {
        if (s == null || s.isBlank())
            return null;
        try {
            return Long.parseLong(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
