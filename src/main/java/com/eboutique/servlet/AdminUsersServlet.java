package com.eboutique.servlet;

import com.eboutique.dao.UserDao;
import com.eboutique.modele.User;
import com.eboutique.service.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Servlet admin — gestion des utilisateurs.
 * Accessible uniquement aux ADMIN (protégé par RoleFilter).
 */
@WebServlet(name = "AdminUsersServlet", urlPatterns = { "/admin/utilisateurs" })
public class AdminUsersServlet extends HttpServlet {

    private final UserDao userDao = new UserDao();
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Messages flash
        String flash = (String) req.getSession().getAttribute("_flash_users");
        if (flash != null) {
            req.setAttribute("flashMessage", flash);
            req.getSession().removeAttribute("_flash_users");
        }
        String flashError = (String) req.getSession().getAttribute("_flash_users_error");
        if (flashError != null) {
            req.setAttribute("flashError", flashError);
            req.getSession().removeAttribute("_flash_users_error");
        }

        List<User> utilisateurs = userDao.listerTousOrdreCreation();
        req.setAttribute("utilisateurs", utilisateurs);
        req.getRequestDispatcher("/WEB-INF/views/admin-utilisateurs.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        User adminConnecte = (User) req.getSession().getAttribute("utilisateurConnecte");
        String action = req.getParameter("action");
        String idStr = req.getParameter("userId");

        if (idStr == null || action == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/utilisateurs");
            return;
        }

        try {
            Long targetId = Long.parseLong(idStr);

            switch (action) {
                case "modifier" -> {
                    String prenom = req.getParameter("firstName");
                    String nom = req.getParameter("lastName");
                    String email = req.getParameter("email");
                    String roleNom = req.getParameter("role");
                    boolean enabled = "on".equals(req.getParameter("enabled"))
                            || "true".equals(req.getParameter("enabled"));
                    String newPass = req.getParameter("newPassword");

                    userService.adminModifierUtilisateur(
                            targetId, prenom, nom, email, roleNom, enabled, adminConnecte.getId());

                    if (newPass != null && !newPass.isBlank()) {
                        if (newPass.length() < 4) {
                            req.getSession().setAttribute("_flash_users_error",
                                    "❌ Mot de passe trop court (min. 4 caractères).");
                            resp.sendRedirect(req.getContextPath() + "/admin/utilisateurs");
                            return;
                        }
                        userService.adminResetPassword(targetId, newPass);
                    }
                    req.getSession().setAttribute("_flash_users", "✅ Compte modifié avec succès.");
                }

                case "supprimer" -> {
                    if (targetId.equals(adminConnecte.getId())) {
                        req.getSession().setAttribute("_flash_users_error",
                                "❌ Impossible de supprimer votre propre compte.");
                    } else {
                        userService.adminSupprimerUtilisateur(targetId);
                        req.getSession().setAttribute("_flash_users", "✅ Compte supprimé.");
                    }
                }

                case "toggle" -> {
                    if (targetId.equals(adminConnecte.getId())) {
                        req.getSession().setAttribute("_flash_users_error",
                                "❌ Impossible de désactiver votre propre compte.");
                    } else {
                        userService.adminToggleActif(targetId);
                        req.getSession().setAttribute("_flash_users", "✅ Statut du compte mis à jour.");
                    }
                }

                default -> {
                }
            }

        } catch (NumberFormatException e) {
            req.getSession().setAttribute("_flash_users_error", "❌ Identifiant invalide.");
        } catch (Exception e) {
            req.getSession().setAttribute("_flash_users_error", "❌ Erreur : " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/utilisateurs");
    }
}
