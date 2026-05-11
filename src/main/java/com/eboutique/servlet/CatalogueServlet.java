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

// Catalogue public : recherche par nom + filtre par catégorie + pagination
@WebServlet(name = "CatalogueServlet", urlPatterns = { "/catalogue" })
public class CatalogueServlet extends HttpServlet {

    private static final int PAGE_SIZE = 8;

    private final ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String q = req.getParameter("q");
        String catIdStr = req.getParameter("categorieId");
        String pageStr = req.getParameter("page");
        Long categorieId = null;
        int page = 1;

        if (catIdStr != null && !catIdStr.isBlank()) {
            try {
                categorieId = Long.parseLong(catIdStr.trim());
            } catch (NumberFormatException ignored) {
            }
        }
        if (pageStr != null && !pageStr.isBlank()) {
            try {
                page = Math.max(1, Integer.parseInt(pageStr.trim()));
            } catch (NumberFormatException ignored) {
            }
        }

        List<Product> tous = productService.rechercherProduits(q, categorieId);
        List<Category> categories = productService.listerCategories();

        int total = tous.size();
        int totalPages = Math.max(1, (int) Math.ceil((double) total / PAGE_SIZE));
        page = Math.min(page, totalPages);
        int debut = (page - 1) * PAGE_SIZE;
        int fin = Math.min(debut + PAGE_SIZE, total);
        List<Product> produits = tous.subList(debut, fin);

        req.setAttribute("produits", produits);
        req.setAttribute("categories", categories);
        req.setAttribute("q", q != null ? q : "");
        req.setAttribute("categorieId", categorieId);
        req.setAttribute("page", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalProduits", total);

        req.getRequestDispatcher("/WEB-INF/views/catalogue.jsp").forward(req, resp);
    }
}
