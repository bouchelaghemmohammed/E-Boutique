package com.eboutique.servlet;

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
 * Servlet pour afficher le catalogue de produits.
 */
@WebServlet(name = "CatalogueServlet", urlPatterns = { "/catalogue" })
public class CatalogueServlet extends HttpServlet {

    private final ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Product> produits = productService.listerTousLesProduits();
        req.setAttribute("produits", produits);

        req.getRequestDispatcher("/WEB-INF/views/catalogue.jsp").forward(req, resp);
    }
}
