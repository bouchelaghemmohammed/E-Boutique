package com.eboutique.util;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

// Fournit l'EntityManagerFactory partage par toute l'application.
// L'EMF est cree une seule fois et reste ouvert pendant la duree de vie du WAR.
public class JpaUtil {

    private static final Logger LOG = Logger.getLogger(JpaUtil.class.getName());
    private static final String UNITE_PERSISTANCE = "eboutiquePU";
    private static EntityManagerFactory emf;

    // Valeurs par defaut pour le developpement local (IntelliJ + WildFly)
    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/eboutique?useSSL=false&serverTimezone=UTC" +
            "&allowPublicKeyRetrieval=true&characterEncoding=UTF-8&useUnicode=true";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASS = "root";

    private JpaUtil() {
    }

    /**
     * Lit d'abord la propriete systeme (-Dkey=val via JAVA_TOOL_OPTIONS ou JVM
     * args),
     * puis la variable d'environnement, puis retourne la valeur par defaut.
     */
    private static String cfg(String sysProp, String envVar, String def) {
        String v = System.getProperty(sysProp);
        if (v != null && !v.isBlank())
            return v.trim();
        v = System.getenv(envVar);
        if (v != null && !v.isBlank())
            return v.trim();
        return def;
    }

    public static synchronized EntityManagerFactory getEntityManagerFactory() {
        if (emf == null || !emf.isOpen()) {
            String url = cfg("db.url", "DB_URL", DEFAULT_URL);
            String user = cfg("db.user", "DB_USER", DEFAULT_USER);
            String pass = cfg("db.password", "DB_PASSWORD", DEFAULT_PASS);

            LOG.info(String.format("[JpaUtil] Connexion BD : url=%s user=%s", url, user));

            Map<String, Object> overrides = new HashMap<>();
            overrides.put("jakarta.persistence.jdbc.url", url);
            overrides.put("jakarta.persistence.jdbc.user", user);
            overrides.put("jakarta.persistence.jdbc.password", pass);

            emf = Persistence.createEntityManagerFactory(UNITE_PERSISTANCE, overrides);
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
