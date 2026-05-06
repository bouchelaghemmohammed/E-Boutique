package com.eboutique.dao;

import com.eboutique.modele.Product;
import com.eboutique.util.JpaUtil;
import jakarta.persistence.EntityManager;
import java.util.List;
import java.util.Optional;

public class ProductDao {

    public List<Product> listerTous() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery("SELECT p FROM Product p", Product.class).getResultList();
        } finally {
            em.close();
        }
    }

    public Optional<Product> trouverParId(Long id) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return Optional.ofNullable(em.find(Product.class, id));
        } finally {
            em.close();
        }
    }

    public void ajouter(Product p) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(p);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }
}
