package com.eboutique.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Utilitaire pour le hachage et la vérification des mots de passe
 * via l'algorithme BCrypt (facteur de coût 12).
 */
public class PasswordHasher {

    private static final int COST = 12;

    private PasswordHasher() {}

    /**
     * Hache un mot de passe en clair avec BCrypt.
     *
     * @param motDePasseClair mot de passe en clair
     * @return hash BCrypt (commence par $2a$12$...)
     */
    public static String hacher(String motDePasseClair) {
        if (motDePasseClair == null || motDePasseClair.isBlank()) {
            throw new IllegalArgumentException("Le mot de passe ne peut pas être vide.");
        }
        return BCrypt.hashpw(motDePasseClair, BCrypt.gensalt(COST));
    }

    /**
     * Vérifie qu'un mot de passe en clair correspond au hash stocké.
     *
     * @param motDePasseClair mot de passe saisi par l'utilisateur
     * @param hash            hash BCrypt stocké en base
     * @return true si le mot de passe correspond
     */
    public static boolean verifier(String motDePasseClair, String hash) {
        if (motDePasseClair == null || hash == null) return false;
        try {
            return BCrypt.checkpw(motDePasseClair, hash);
        } catch (IllegalArgumentException e) {
            return false;
        }
    }
}
