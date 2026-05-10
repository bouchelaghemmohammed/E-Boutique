package com.eboutique.dao;

import com.eboutique.modele.Order;
import com.eboutique.util.JpaUtil;
import jakarta.persistence.EntityManager;
import java.util.List;

public class OrderDao {

    public void ajouter(Order order) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(order);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive())
                em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /**
     * Progression des statuts : PENDING → CONFIRMED → PREPARING → SHIPPED →
     * DELIVERED.
     * Retourne true si la mise à jour a réussi.
     */
    public boolean mettreAJourStatut(Long orderId, String nouveauStatut) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            Order o = em.find(Order.class, orderId);
            if (o == null)
                return false;
            o.setStatus(nouveauStatut);
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive())
                em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public Order trouverParId(Long id) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT DISTINCT o FROM Order o " +
                            "LEFT JOIN FETCH o.user " +
                            "LEFT JOIN FETCH o.items i " +
                            "LEFT JOIN FETCH i.product " +
                            "WHERE o.id = :id",
                    Order.class)
                    .setParameter("id", id)
                    .getSingleResult();
        } catch (Exception e) {
            return null;
        } finally {
            em.close();
        }
    }

    public List<Order> listerParUtilisateur(Long userId) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            if (userId == null) {
                // Charge user + items + product en une seule requête (évite
                // LazyInitializationException)
                return em.createQuery(
                        "SELECT DISTINCT o FROM Order o " +
                                "LEFT JOIN FETCH o.user u " +
                                "LEFT JOIN FETCH o.items i " +
                                "LEFT JOIN FETCH i.product " +
                                "ORDER BY o.orderDate DESC",
                        Order.class).getResultList();
            }
            return em.createQuery(
                    "SELECT DISTINCT o FROM Order o " +
                            "LEFT JOIN FETCH o.user u " +
                            "LEFT JOIN FETCH o.items i " +
                            "LEFT JOIN FETCH i.product " +
                            "WHERE o.user.id = :uid " +
                            "ORDER BY o.orderDate DESC",
                    Order.class)
                    .setParameter("uid", userId)
                    .getResultList();
        } finally {
            em.close();
        }
    }
}
