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
 * Servlet d'historique (GET + POST /historique).
 */
@WebServlet(name = "HistoriqueServlet", urlPatterns = { "/historique" })
public class HistoriqueServlet extends HttpServlet {

    private final OrderDao orderDao = new OrderDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User connecte = (User) session.getAttribute("utilisateurConnecte");

        List<Order> orders = orderDao.listerParUtilisateur(connecte.getId());
        req.setAttribute("commandes", orders);

        // Flash message
        Object flash = session.getAttribute("_flash_commandeConfirmee");
        if (flash != null) {
            req.setAttribute("commandeConfirmee", flash.toString());
            session.removeAttribute("_flash_commandeConfirmee");
        }
        Object flashInfo = session.getAttribute("_flash_historique");
        if (flashInfo != null) {
            req.setAttribute("flashInfo", flashInfo.toString());
            session.removeAttribute("_flash_historique");
        }
        // Compatibilité : paramètre URL
        String confirmeeId = req.getParameter("confirmee");
        if (confirmeeId != null && flash == null) {
            req.setAttribute("commandeConfirmee", confirmeeId);
        }

        req.getRequestDispatcher("/WEB-INF/views/historique-commandes.jsp").forward(req, resp);
    }

    /**
     * POST /historique — action=receptionner&orderId=X
     * L'utilisateur confirme la réception de sa commande expédiée.
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User connecte = (User) session.getAttribute("utilisateurConnecte");

        String action = req.getParameter("action");
        String idParam = req.getParameter("orderId");

        if ("receptionner".equals(action) && idParam != null) {
            try {
                long orderId = Long.parseLong(idParam.trim());
                Order order = orderDao.trouverParId(orderId);

                // Sécurité : l'ordre doit appartenir à l'utilisateur connecté
                if (order != null
                        && order.getUser() != null
                        && order.getUser().getId().equals(connecte.getId())
                        && ("SHIPPED".equals(order.getStatus()) || "DELIVERED".equals(order.getStatus()))) {
                    orderDao.mettreAJourStatut(orderId, "RECEIVED");
                    session.setAttribute("_flash_historique",
                            "✅ Commande #" + orderId + " marquée comme réceptionnée. Merci !");
                }
            } catch (NumberFormatException ignored) {
            }
        }

        resp.sendRedirect(req.getContextPath() + "/historique");
    }
}
