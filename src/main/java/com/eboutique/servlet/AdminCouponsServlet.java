package com.eboutique.servlet;

import com.eboutique.dao.CouponDao;
import com.eboutique.modele.Coupon;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.security.SecureRandom;
import java.util.List;
import java.util.Optional;

/**
 * Gestion des coupons côté admin — /admin/coupons
 */
@WebServlet(name = "AdminCouponsServlet", urlPatterns = { "/admin/coupons" })
public class AdminCouponsServlet extends HttpServlet {

    private static final String CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    private final CouponDao couponDao = new CouponDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<Coupon> coupons = couponDao.listerTous();
        req.setAttribute("coupons", coupons);
        req.getRequestDispatcher("/WEB-INF/views/admin-coupons.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if ("creer".equals(action)) {
            creer(req, resp);
        } else if ("toggle".equals(action)) {
            toggle(req, resp);
        } else if ("generer".equals(action)) {
            // Retourne un code aléatoire via redirect avec param
            String code = genererCode(8);
            resp.sendRedirect(req.getContextPath() + "/admin/coupons?genere=" + code);
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/coupons");
        }
    }

    private void creer(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        String code = req.getParameter("code");
        String type = req.getParameter("type");
        String reductionStr = req.getParameter("reduction");

        if (code == null || code.isBlank() || type == null || reductionStr == null) {
            redirectWithError(req, resp, "Tous les champs sont obligatoires.");
            return;
        }
        if (!"POURCENTAGE".equals(type) && !"MONTANT".equals(type)) {
            redirectWithError(req, resp, "Type de coupon invalide.");
            return;
        }

        BigDecimal reduction;
        try {
            reduction = new BigDecimal(reductionStr.replace(",", ".").trim());
        } catch (NumberFormatException e) {
            redirectWithError(req, resp, "Valeur de réduction invalide.");
            return;
        }

        if ("POURCENTAGE".equals(type)
                && (reduction.compareTo(BigDecimal.ZERO) <= 0 || reduction.compareTo(BigDecimal.valueOf(100)) > 0)) {
            redirectWithError(req, resp, "Le pourcentage doit être entre 1 et 100.");
            return;
        }
        if ("MONTANT".equals(type) && reduction.compareTo(BigDecimal.ZERO) <= 0) {
            redirectWithError(req, resp, "Le montant doit être supérieur à 0.");
            return;
        }

        // Vérifier unicité du code
        if (couponDao.trouverParCode(code).isPresent()) {
            redirectWithError(req, resp, "Ce code existe déjà.");
            return;
        }

        Coupon coupon = new Coupon();
        coupon.setCode(code.toUpperCase().trim());
        coupon.setType(type);
        coupon.setReduction(reduction);
        coupon.setActif(true);
        couponDao.ajouter(coupon);

        resp.sendRedirect(req.getContextPath() + "/admin/coupons?succes=1");
    }

    private void toggle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idStr = req.getParameter("id");
        try {
            Long id = Long.parseLong(idStr);
            Optional<Coupon> opt = couponDao.trouverParId(id);
            if (opt.isPresent()) {
                Coupon c = opt.get();
                c.setActif(!c.isActif());
                couponDao.mettreAJour(c);
            }
        } catch (Exception ignored) {
        }
        resp.sendRedirect(req.getContextPath() + "/admin/coupons");
    }

    private void redirectWithError(HttpServletRequest req, HttpServletResponse resp, String msg)
            throws IOException {
        resp.sendRedirect(req.getContextPath() + "/admin/coupons?erreur=" +
                java.net.URLEncoder.encode(msg, "UTF-8"));
    }

    private String genererCode(int longueur) {
        SecureRandom rnd = new SecureRandom();
        StringBuilder sb = new StringBuilder(longueur);
        for (int i = 0; i < longueur; i++) {
            sb.append(CHARS.charAt(rnd.nextInt(CHARS.length())));
        }
        return sb.toString();
    }
}
