package com.eboutique.util;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

// Fournit l'EntityManagerFactory partage par toute l'application.
// L'EMF est cree une seule fois et reste ouvert pendant la duree de vie du WAR.
public class JpaUtil {

    private static final String UNITE_PERSISTANCE = "eboutiquePU";
    private static EntityManagerFactory emf;

    private JpaUtil() {}

    public static synchronized EntityManagerFactory getEntityManagerFactory() {
        if (emf == null || !emf.isOpen()) {
            emf = Persistence.createEntityManagerFactory(UNITE_PERSISTANCE);
        }
        return emf;
    }

    public static EntityManager getEntityManager() {
        return getEntityManagerFactory().createEntityManager();
    }

    public static synchronized void fermer() {
        if (emf != null && emf.isOpen()) {
            emf.close();
        }
    }
}
