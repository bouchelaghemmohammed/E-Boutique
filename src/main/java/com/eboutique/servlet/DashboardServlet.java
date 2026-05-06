package com.eboutique.servlet;

import com.eboutique.dao.OrderDao;
import com.eboutique.dao.UserDao;
import com.eboutique.modele.Order;
import com.eboutique.modele.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * Servlet du tableau de bord (GET /dashboard).
 */
@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {

    private final OrderDao orderDao = new OrderDao();
    private final UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session  = req.getSession(false);
        User connecte = (User) session.getAttribute("utilisateurConnecte");

        if (connecte.isAdmin()) {
            List<Order> toutesCommandes = orderDao.listerParUtilisateur(null); // Just an example, need listerTous
            List<User> tousUtilisateurs = userDao.listerTous();

            BigDecimal totalVentes = toutesCommandes.stream()
                    .map(Order::getTotal)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            req.setAttribute("toutesCommandes",   toutesCommandes);
            req.setAttribute("totalVentes",        totalVentes);
            req.setAttribute("nbUtilisateurs",     tousUtilisateurs.size());
            req.setAttribute("nbCommandes",        toutesCommandes.size());

        } else {
            List<Order> mesCommandes = orderDao.listerParUtilisateur(connecte.getId());

            BigDecimal totalDepense = mesCommandes.stream()
                    .map(Order::getTotal)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            List<Order> dernieres = mesCommandes.stream().limit(3).toList();

            req.setAttribute("mesCommandes",  mesCommandes);
            req.setAttribute("dernieres",     dernieres);
            req.setAttribute("totalDepense",  totalDepense);
            req.setAttribute("nbCommandes",   mesCommandes.size());
        }

        req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);
    }
}
