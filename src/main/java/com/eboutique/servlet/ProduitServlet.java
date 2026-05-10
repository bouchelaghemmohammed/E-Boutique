package com.eboutique.servlet;

import com.eboutique.modele.Product;
import com.eboutique.service.ProductService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Optional;

/**
 * Servlet de détail produit — GET /produit?id=X
 * Accessible sans connexion (URL publique dans AuthFilter).
 */
@WebServlet(name = "ProduitServlet", urlPatterns = { "/produit" })
public class ProduitServlet extends HttpServlet {

    private final ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/catalogue");
            return;
        }

        long id;
        try {
            id = Long.parseLong(idParam.trim());
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Optional<Product> opt = productService.trouverParId(id);
        if (opt.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Produit introuvable");
            return;
        }

        req.setAttribute("produit", opt.get());
        req.getRequestDispatcher("/WEB-INF/views/detail-produit.jsp").forward(req, resp);
    }
}
