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
import java.util.List;

// Catalogue public : recherche par nom + filtre par catégorie
@WebServlet(name = "CatalogueServlet", urlPatterns = { "/catalogue" })
public class CatalogueServlet extends HttpServlet {

    private final ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String q = req.getParameter("q");
        String catIdStr = req.getParameter("categorieId");
        Long categorieId = null;

        if (catIdStr != null && !catIdStr.isBlank()) {
            try {
                categorieId = Long.parseLong(catIdStr.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        List<Product> produits = productService.rechercherProduits(q, categorieId);
        List<Category> categories = productService.listerCategories();

        req.setAttribute("produits", produits);
        req.setAttribute("categories", categories);
        req.setAttribute("q", q != null ? q : "");
        req.setAttribute("categorieId", categorieId);

        req.getRequestDispatcher("/WEB-INF/views/catalogue.jsp").forward(req, resp);
    }
}
