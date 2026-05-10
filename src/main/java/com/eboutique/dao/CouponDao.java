package com.eboutique.dao;

import com.eboutique.modele.Coupon;
import com.eboutique.util.JpaUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;

import java.util.List;
import java.util.Optional;

public class CouponDao {

    public void ajouter(Coupon coupon) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(coupon);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive())
                em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public void mettreAJour(Coupon coupon) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            em.merge(coupon);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive())
                em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public Optional<Coupon> trouverParCode(String code) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            TypedQuery<Coupon> q = em.createQuery(
                    "SELECT c FROM Coupon c WHERE UPPER(c.code) = UPPER(:code) AND c.actif = true",
                    Coupon.class);
            q.setParameter("code", code);
            return q.getResultStream().findFirst();
        } finally {
            em.close();
        }
    }

    public List<Coupon> listerTous() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery("SELECT c FROM Coupon c ORDER BY c.dateCreation DESC", Coupon.class)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public Optional<Coupon> trouverParId(Long id) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return Optional.ofNullable(em.find(Coupon.class, id));
        } finally {
            em.close();
        }
    }
}
