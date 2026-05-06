package com.eboutique.dao;

import com.eboutique.modele.NomRole;
import com.eboutique.modele.Role;
import com.eboutique.util.JpaUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import java.util.Optional;

/**
 * Accès aux données pour l'entité Role.
 */
public class RoleDao {

    /**
     * Trouve un rôle par son nom (énumération NomRole).
     */
    public Optional<Role> trouverParNom(NomRole nom) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            Role role = em.createQuery("SELECT r FROM Role r WHERE r.name = :nom", Role.class)
                    .setParameter("nom", nom)
                    .getSingleResult();
            return Optional.of(role);
        } catch (NoResultException e) {
            return Optional.empty();
        } finally {
            em.close();
        }
    }
}
