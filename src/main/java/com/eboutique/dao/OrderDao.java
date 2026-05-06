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
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public List<Order> listerParUtilisateur(Long userId) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            if (userId == null) {
                return em.createQuery("SELECT o FROM Order o", Order.class).getResultList();
            }
            return em.createQuery("SELECT o FROM Order o WHERE o.user.id = :uid", Order.class)
                    .setParameter("uid", userId)
                    .getResultList();
        } finally {
            em.close();
        }
    }
}
