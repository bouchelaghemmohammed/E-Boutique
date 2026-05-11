package com.eboutique.service;

import com.eboutique.dao.RoleDao;
import com.eboutique.dao.UserDao;
import com.eboutique.modele.NomRole;
import com.eboutique.modele.Role;
import com.eboutique.modele.User;
import com.eboutique.util.JpaUtil;
import com.eboutique.util.PasswordHasher;
import jakarta.persistence.EntityManager;
import java.util.Optional;

public class UserService {

    private final UserDao userDao = new UserDao();
    private final RoleDao roleDao = new RoleDao();

    public Optional<User> connecter(String email, String motDePasseClair) {
        if (email == null || motDePasseClair == null)
            return Optional.empty();

        Optional<User> optUser = userDao.trouverParEmail(email.trim());
        if (optUser.isPresent()) {
            User u = optUser.get();
            if (!u.isEnabled())
                return Optional.empty(); // compte désactivé
            if (PasswordHasher.verifier(motDePasseClair, u.getPasswordHash())) {
                return Optional.of(u);
            }
        }
        return Optional.empty();
    }

    public void inscrire(String prenom, String nom, String email, String motDePasseClair) {
        User u = new User();
        u.setFirstName(prenom);
        u.setLastName(nom);
        u.setEmail(email.trim().toLowerCase());
        u.setPasswordHash(PasswordHasher.hacher(motDePasseClair));

        Role roleUser = roleDao.trouverParNom(NomRole.USER)
                .orElseThrow(() -> new IllegalStateException("Rôle USER non configuré en base."));
        u.setRole(roleUser);

        userDao.ajouter(u);
    }

    public User mettreAJourProfil(Long id, String firstName, String lastName, String email, String adresseLivraison) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            User u = em.find(User.class, id);
            if (u != null) {
                u.setFirstName(firstName);
                u.setLastName(lastName);
                if (email != null && !email.isBlank()) {
                    u.setEmail(email.trim().toLowerCase());
                }
                if (adresseLivraison != null) {
                    u.setAdresseLivraison(adresseLivraison.isBlank() ? null : adresseLivraison.trim());
                }
            }
            em.getTransaction().commit();
            return u;
        } catch (Exception e) {
            if (em.getTransaction().isActive())
                em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public void changerMotDePasse(Long id, String ancienMdp, String nouveauMdp) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            User u = em.find(User.class, id);
            if (u != null) {
                if (!PasswordHasher.verifier(ancienMdp, u.getPasswordHash())) {
                    throw new IllegalArgumentException("L'ancien mot de passe est incorrect.");
                }
                u.setPasswordHash(PasswordHasher.hacher(nouveauMdp));
            }
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive())
                em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    // ── Opérations réservées à l'admin ───────────────────────────────────────

    public void adminModifierUtilisateur(Long targetId, String prenom, String nom,
            String email, String roleNom, boolean enabled, Long adminId) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            User u = em.find(User.class, targetId);
            if (u == null)
                throw new IllegalArgumentException("Utilisateur introuvable.");
            if (prenom != null && !prenom.isBlank())
                u.setFirstName(prenom.trim());
            if (nom != null && !nom.isBlank())
                u.setLastName(nom.trim());
            if (email != null && !email.isBlank())
                u.setEmail(email.trim().toLowerCase());
            // L'admin ne peut pas changer son propre rôle/statut via ce panneau
            if (!targetId.equals(adminId)) {
                NomRole nomRole = ("ADMIN".equalsIgnoreCase(roleNom)) ? NomRole.ADMIN : NomRole.USER;
                Role role = roleDao.trouverParNom(nomRole)
                        .orElseThrow(() -> new IllegalStateException("Rôle non trouvé."));
                u.setRole(role);
                u.setEnabled(enabled);
            }
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive())
                em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public void adminSupprimerUtilisateur(Long targetId) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            User u = em.find(User.class, targetId);
            if (u != null)
                em.remove(u);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive())
                em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public void adminToggleActif(Long targetId) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            User u = em.find(User.class, targetId);
            if (u != null)
                u.setEnabled(!u.isEnabled());
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive())
                em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public void adminResetPassword(Long targetId, String newPassword) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            User u = em.find(User.class, targetId);
            if (u != null)
                u.setPasswordHash(PasswordHasher.hacher(newPassword));
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive())
                em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }
}
