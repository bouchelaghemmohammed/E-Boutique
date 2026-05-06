package com.eboutique.servlet;

import com.eboutique.dao.OrderDao;
import com.eboutique.modele.Order;
import com.eboutique.modele.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Servlet d'historique (GET /historique).
 */
@WebServlet(name = "HistoriqueServlet", urlPatterns = {"/historique"})
public class HistoriqueServlet extends HttpServlet {

    private final OrderDao orderDao = new OrderDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User connecte = (User) session.getAttribute("utilisateurConnecte");

        List<Order> orders = orderDao.listerParUtilisateur(connecte.getId());
        req.setAttribute("commandes", orders);

        String confirmeeId = req.getParameter("confirmee");
        if (confirmeeId != null) {
            req.setAttribute("commandeConfirmee", confirmeeId);
        }

        req.getRequestDispatcher("/WEB-INF/views/historique-commandes.jsp").forward(req, resp);
    }
}
