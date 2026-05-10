package com.eboutique.servlet;

import com.eboutique.dao.CouponDao;
import com.eboutique.modele.Coupon;
import com.eboutique.modele.Panier;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Optional;

/**
 * Validation d'un coupon lors du checkout — /coupon/valider (POST, JSON)
 */
@WebServlet(name = "CouponServlet", urlPatterns = { "/coupon/valider" })
public class CouponServlet extends HttpServlet {

    private final CouponDao couponDao = new CouponDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String code = req.getParameter("code");
        if (code == null || code.isBlank()) {
            resp.getWriter().write("{\"ok\":false,\"message\":\"Code vide.\"}");
            return;
        }

        // Code spécial pour retirer le coupon
        if ("__RESET__".equals(code)) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.removeAttribute("couponCode");
                session.removeAttribute("couponReduction");
            }
            resp.getWriter().write("{\"ok\":true,\"reset\":true}");
            return;
        }

        Optional<Coupon> opt = couponDao.trouverParCode(code.trim());
        if (opt.isEmpty()) {
            resp.getWriter().write("{\"ok\":false,\"message\":\"Code invalide ou expiré.\"}");
            return;
        }

        Coupon coupon = opt.get();

        // Lire le panier pour calculer la réduction
        HttpSession session = req.getSession(false);
        Panier panier = session != null ? (Panier) session.getAttribute("panier") : null;
        BigDecimal sousTotal = (panier != null) ? panier.getTotal() : BigDecimal.ZERO;
        BigDecimal montantReduction = coupon.calculerReduction(sousTotal);

        // Sauvegarder le coupon en session pour le checkout POST
        if (session != null) {
            session.setAttribute("couponCode", coupon.getCode());
            session.setAttribute("couponReduction", montantReduction);
        }

        String libelle = coupon.getType().equals("POURCENTAGE")
                ? coupon.getReduction().stripTrailingZeros().toPlainString() + " %"
                : coupon.getReduction().setScale(2).toPlainString() + " $";

        resp.getWriter().write(
                "{\"ok\":true," +
                        "\"code\":\"" + coupon.getCode() + "\"," +
                        "\"libelle\":\"" + libelle + "\"," +
                        "\"reduction\":" + montantReduction.setScale(2) + "}");
    }
}
