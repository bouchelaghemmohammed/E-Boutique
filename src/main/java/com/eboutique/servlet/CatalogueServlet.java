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

/**
 * Servlet du catalogue — supporte la recherche par nom et le filtre par
 * catégorie.
 * GET /catalogue?q=recherche&categorieId=2
 */
@WebServlet(name = "CatalogueServlet", urlPatterns = { "/catalogue" })
public class CatalogueServlet extends HttpServlet {

    private final ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String q = req.getParameter("q");
        String catIdStr = req.getParameter("categorieId");
        String stockFiltre = req.getParameter("stockFiltre");
        Long categorieId = null;

        if (catIdStr != null && !catIdStr.isBlank()) {
            try {
                categorieId = Long.parseLong(catIdStr.trim());
            } catch (NumberFormatException ignored) {
            }
        }
        if (stockFiltre != null && stockFiltre.isBlank())
            stockFiltre = null;

        List<Product> produits = productService.rechercherProduits(q, categorieId, stockFiltre);
        List<Category> categories = productService.listerCategories();

        req.setAttribute("produits", produits);
        req.setAttribute("categories", categories);
        req.setAttribute("q", q != null ? q : "");
        req.setAttribute("categorieId", categorieId);
        req.setAttribute("stockFiltre", stockFiltre != null ? stockFiltre : "");

        req.getRequestDispatcher("/WEB-INF/views/catalogue.jsp").forward(req, resp);
    }
}
