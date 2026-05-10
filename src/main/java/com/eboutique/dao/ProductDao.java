package com.eboutique.dao;

import com.eboutique.modele.Category;
import com.eboutique.modele.Product;
import com.eboutique.util.JpaUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import java.util.List;
import java.util.Optional;

public class ProductDao {

    public List<Product> listerTous() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT p FROM Product p LEFT JOIN FETCH p.category ORDER BY p.name",
                    Product.class).getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Recherche des produits par nom (LIKE), catégorie et filtre stock.
     * stockFiltre: "disponible" (stock>0), "rupture" (stock=0), null/vide = tous.
     */
    public List<Product> rechercher(String nom, Long categorieId, String stockFiltre) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            StringBuilder jpql = new StringBuilder(
                    "SELECT p FROM Product p LEFT JOIN FETCH p.category WHERE 1=1");
            if (nom != null && !nom.isBlank())
                jpql.append(" AND LOWER(p.name) LIKE LOWER(:nom)");
            if (categorieId != null)
                jpql.append(" AND p.category.id = :catId");
            if ("disponible".equals(stockFiltre))
                jpql.append(" AND p.stock > 0");
            else if ("rupture".equals(stockFiltre))
                jpql.append(" AND p.stock <= 0");
            jpql.append(" ORDER BY p.name");

            TypedQuery<Product> q = em.createQuery(jpql.toString(), Product.class);
            if (nom != null && !nom.isBlank())
                q.setParameter("nom", "%" + nom.trim() + "%");
            if (categorieId != null)
                q.setParameter("catId", categorieId);

            return q.getResultList();
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
            if (em.getTransaction().isActive())
                em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public void mettreAJour(Product p) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            em.merge(p);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive())
                em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public void supprimer(Long id) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            Product p = em.find(Product.class, id);
            if (p != null)
                em.remove(p);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive())
                em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public List<Category> listerCategories() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT c FROM Category c ORDER BY CASE WHEN c.name = 'Autre' THEN 1 ELSE 0 END, c.name",
                    Category.class)
                    .getResultList();
        } finally {
            em.close();
        }
    }
}
