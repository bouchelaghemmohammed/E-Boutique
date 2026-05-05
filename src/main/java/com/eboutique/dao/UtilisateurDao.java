package com.eboutique.dao;

import com.eboutique.modele.Utilisateur;
import com.eboutique.util.JpaUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.NoResultException;
import jakarta.persistence.TypedQuery;

import java.util.List;
import java.util.Optional;

/**
 * Accès aux données pour l'entité {@link Utilisateur}.
 * Toutes les méthodes gèrent leur propre EntityManager et ferment la connexion après usage.
 */
public class UtilisateurDao {

    /**
     * Persiste un nouvel utilisateur en base.
     */
    public Utilisateur creer(Utilisateur utilisateur) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(utilisateur);
            tx.commit();
            return utilisateur;
        } catch (RuntimeException e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /**
     * Met à jour un utilisateur existant (profil, mot de passe, rôle…).
     */
    public Utilisateur mettreAJour(Utilisateur utilisateur) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Utilisateur gere = em.merge(utilisateur);
            tx.commit();
            return gere;
        } catch (RuntimeException e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /**
     * Trouve un utilisateur par son identifiant.
     */
    public Optional<Utilisateur> trouverParId(Long id) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return Optional.ofNullable(em.find(Utilisateur.class, id));
        } finally {
            em.close();
        }
    }

    /**
     * Trouve un utilisateur par son adresse courriel (insensible à la casse).
     */
    public Optional<Utilisateur> trouverParCourriel(String email) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            TypedQuery<Utilisateur> q = em.createQuery(
                    "SELECT u FROM Utilisateur u WHERE LOWER(u.email) = LOWER(:email)",
                    Utilisateur.class);
            q.setParameter("email", email);
            return Optional.of(q.getSingleResult());
        } catch (NoResultException e) {
            return Optional.empty();
        } finally {
            em.close();
        }
    }

    /**
     * Vérifie si un courriel est déjà utilisé.
     */
    public boolean existeParCourriel(String email) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            Long count = em.createQuery(
                    "SELECT COUNT(u) FROM Utilisateur u WHERE LOWER(u.email) = LOWER(:email)",
                    Long.class)
                    .setParameter("email", email)
                    .getSingleResult();
            return count > 0;
        } finally {
            em.close();
        }
    }

    /**
     * Retourne tous les utilisateurs (usage admin uniquement).
     */
    public List<Utilisateur> trouverTous() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT u FROM Utilisateur u ORDER BY u.creeLe DESC",
                    Utilisateur.class)
                    .getResultList();
        } finally {
            em.close();
        }
    }
}
