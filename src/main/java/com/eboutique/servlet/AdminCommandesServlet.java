package com.eboutique.servlet;

import com.eboutique.dao.OrderDao;
import com.eboutique.modele.Order;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

/**
 * Servlet admin — liste et gestion du statut des commandes.
 * Accessible uniquement aux ADMIN (protégé par RoleFilter).
 */
@WebServlet(name = "AdminCommandesServlet", urlPatterns = { "/admin/commandes" })
public class AdminCommandesServlet extends HttpServlet {

    /**
     * Progression valide des statuts (dans l'ordre).
     * L'admin ne peut avancer que jusqu'à DELIVERED.
     * C'est l'UTILISATEUR qui passe à RECEIVED en cliquant "Réceptionner".
     */
    private static final List<String> PROGRESSION = Arrays.asList(
            "PENDING", "CONFIRMED", "PREPARING", "SHIPPED", "DELIVERED");

    /** Statuts autorisés (inclut CANCELLED). */
    private static final List<String> STATUTS_VALIDES = Arrays.asList(
            "PENDING", "CONFIRMED", "PREPARING", "SHIPPED", "DELIVERED", "RECEIVED", "CANCELLED");

    private final OrderDao orderDao = new OrderDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String flash = (String) req.getSession().getAttribute("_flash_admin");
        if (flash != null) {
            req.setAttribute("flashMessage", flash);
            req.getSession().removeAttribute("_flash_admin");
        }

        List<Order> commandes = orderDao.listerParUtilisateur(null);
        req.setAttribute("commandes", commandes);
        req.getRequestDispatcher("/WEB-INF/views/admin-commandes.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String idStr = req.getParameter("orderId");
        if (idStr == null || action == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/commandes");
            return;
        }

        long orderId;
        try {
            orderId = Long.parseLong(idStr.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/commandes");
            return;
        }

        if ("avancer".equals(action)) {
            Order o = orderDao.trouverParId(orderId);
            if (o != null) {
                int idx = PROGRESSION.indexOf(o.getStatus());
                if (idx >= 0 && idx < PROGRESSION.size() - 1) {
                    String suivant = PROGRESSION.get(idx + 1);
                    orderDao.mettreAJourStatut(orderId, suivant);
                    req.getSession().setAttribute("_flash_admin",
                            "Commande #" + orderId + " → " + libelle(suivant));
                }
            }
        } else if ("annuler".equals(action)) {
            orderDao.mettreAJourStatut(orderId, "CANCELLED");
            req.getSession().setAttribute("_flash_admin", "Commande #" + orderId + " annulée.");
        } else if ("statut".equals(action)) {
            String statut = req.getParameter("statut");
            if (statut != null && STATUTS_VALIDES.contains(statut)) {
                orderDao.mettreAJourStatut(orderId, statut);
                req.getSession().setAttribute("_flash_admin",
                        "Commande #" + orderId + " mise à jour → " + libelle(statut));
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin/commandes");
    }

    public static String libelle(String statut) {
        return switch (statut) {
            case "PENDING" -> "En attente";
            case "CONFIRMED" -> "Confirmée";
            case "PREPARING" -> "En préparation";
            case "SHIPPED" -> "Expédiée";
            case "DELIVERED" -> "Livrée";
            case "RECEIVED" -> "Réceptionnée";
            case "CANCELLED" -> "Annulée";
            default -> statut;
        };
    }
}
