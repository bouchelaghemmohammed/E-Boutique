package com.eboutique.servlet;

import com.eboutique.modele.Order;
import com.eboutique.modele.Panier;
import com.eboutique.modele.User;
import com.eboutique.service.OrderService;
import com.eboutique.service.MailService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;

@WebServlet(name = "CheckoutServlet", urlPatterns = { "/checkout" })
public class CheckoutServlet extends HttpServlet {

    private final OrderService orderService = new OrderService();
    private final MailService mailService = new MailService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Panier panier = getPanier(req);
        if (panier == null || panier.estVide()) {
            resp.sendRedirect(req.getContextPath() + "/panier");
            return;
        }
        if (getUtilisateurConnecte(req) == null) {
            resp.sendRedirect(req.getContextPath() + "/connexion");
            return;
        }

        req.setAttribute("panier", panier);
        // Exposer le coupon déjà appliqué (si l'utilisateur revient sur la page)
        HttpSession sess = req.getSession(false);
        if (sess != null) {
            req.setAttribute("couponCode", sess.getAttribute("couponCode"));
            req.setAttribute("couponReduction", sess.getAttribute("couponReduction"));
        }
        req.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Panier panier = getPanier(req);
        User user = getUtilisateurConnecte(req);

        if (panier == null || panier.estVide()) {
            resp.sendRedirect(req.getContextPath() + "/panier");
            return;
        }
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/connexion");
            return;
        }

        String adresse = req.getParameter("adresseLivraison");
        if (adresse == null || adresse.isBlank()) {
            req.setAttribute("erreur", "L'adresse de livraison est obligatoire.");
            req.setAttribute("panier", panier);
            req.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(req, resp);
            return;
        }

        try {
            // Récupérer la réduction coupon depuis la session
            HttpSession session = req.getSession(false);
            BigDecimal reduction = BigDecimal.ZERO;
            if (session != null && session.getAttribute("couponReduction") != null) {
                reduction = (BigDecimal) session.getAttribute("couponReduction");
            }

            Order order = orderService.passerCommande(user, panier.getContenuPourService(), adresse, reduction);

            try {
                mailService.envoyerConfirmationCommande(order);
            } catch (Exception e) {
                // Journaliser le détail complet dans les logs WildFly/Railway
                getServletContext().log("Echec envoi email pour commande " + order.getId()
                        + " — " + e.getClass().getSimpleName() + ": " + e.getMessage(), e);
                // Stocker un avertissement visible dans la session (flash)
                req.getSession().setAttribute("_flash_mail_error",
                        e.getClass().getSimpleName() + ": " + e.getMessage());
            }

            panier.vider();
            PanierServlet.sauvegarderCookie(panier, req, resp);

            // Nettoyer le coupon de la session
            if (session != null) {
                session.removeAttribute("couponCode");
                session.removeAttribute("couponReduction");
            }

            req.getSession().setAttribute("_flash_commandeConfirmee", order.getId());
            resp.sendRedirect(req.getContextPath() + "/historique");

        } catch (Exception e) {
            req.setAttribute("erreur", "Erreur lors de l'enregistrement de la commande : " + e.getMessage());
            req.setAttribute("panier", panier);
            req.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(req, resp);
        }
    }

    private Panier getPanier(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (Panier) session.getAttribute("panier");
    }

    private User getUtilisateurConnecte(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (User) session.getAttribute("utilisateurConnecte");
    }
}
