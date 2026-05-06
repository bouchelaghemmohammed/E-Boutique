package com.eboutique.dao;

import com.eboutique.modele.User;
import com.eboutique.util.JpaUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import java.util.List;
import java.util.Optional;

public class UserDao {

    public void ajouter(User user) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(user);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public Optional<User> trouverParEmail(String email) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            TypedQuery<User> q = em.createQuery(
                    "SELECT u FROM User u WHERE LOWER(u.email) = LOWER(:email)", 
                    User.class);
            q.setParameter("email", email);
            return q.getResultStream().findFirst();
        } finally {
            em.close();
        }
    }

    public List<User> listerTous() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery("SELECT u FROM User u", User.class).getResultList();
        } finally {
            em.close();
        }
    }
}
