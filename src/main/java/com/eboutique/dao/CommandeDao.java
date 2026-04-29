package com.eboutique.dao;

import com.eboutique.modele.Commande;
import com.eboutique.modele.Utilisateur;
import com.eboutique.util.JpaUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;

import java.util.List;

public class CommandeDao {

    public Commande sauvegarder(Commande commande) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(commande);
            tx.commit();
            return commande;
        } catch (RuntimeException e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public Commande trouverParId(Long id) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.find(Commande.class, id);
        } finally {
            em.close();
        }
    }

    public List<Commande> trouverParUtilisateur(Utilisateur utilisateur) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            TypedQuery<Commande> query = em.createQuery(
                    "SELECT c FROM Commande c WHERE c.utilisateur = :u ORDER BY c.dateCommande DESC",
                    Commande.class);
            query.setParameter("u", utilisateur);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    public List<Commande> trouverToutes() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery("SELECT c FROM Commande c ORDER BY c.dateCommande DESC", Commande.class)
                     .getResultList();
        } finally {
            em.close();
        }
    }
}
