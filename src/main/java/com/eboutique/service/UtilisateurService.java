package com.eboutique.service;

import com.eboutique.dao.UtilisateurDao;
import com.eboutique.modele.Role;
import com.eboutique.modele.Utilisateur;
import com.eboutique.util.PasswordHasher;

import java.util.Optional;

public class UtilisateurService {

    private final UtilisateurDao utilisateurDao = new UtilisateurDao();

    public Utilisateur inscrire(String prenom, String nom, String email,
                                 String motDePasseClair, String telephone, String adresse) {

        validerChampsObligatoires(prenom, nom, email, motDePasseClair);

        if (utilisateurDao.existeParCourriel(email.trim())) {
            throw new IllegalArgumentException("Cette adresse courriel est déjà utilisée.");
        }

        validerMotDePasse(motDePasseClair);
        validerCourriel(email);

        Utilisateur u = new Utilisateur();
        u.setPrenom(prenom.trim());
        u.setNom(nom.trim());
        u.setEmail(email.trim().toLowerCase());
        u.setMotDePasseHash(PasswordHasher.hacher(motDePasseClair));
        u.setRole(Role.USER);
        u.setActif(true);
        u.setTelephone(telephone != null ? telephone.trim() : null);
        u.setAdresse(adresse != null ? adresse.trim() : null);

        return utilisateurDao.creer(u);
    }

    public Optional<Utilisateur> connecter(String email, String motDePasseClair) {
        if (email == null || motDePasseClair == null) return Optional.empty();

        Optional<Utilisateur> optUtil = utilisateurDao.trouverParCourriel(email.trim());
        if (optUtil.isEmpty()) return Optional.empty();

        Utilisateur u = optUtil.get();
        if (!u.isActif()) return Optional.empty();
        
        if (!PasswordHasher.verifier(motDePasseClair, u.getMotDePasseHash())) {
            return Optional.empty();
        }
        return Optional.of(u);
    }

    public Utilisateur mettreAJourProfil(Long id, String prenom, String nom,
                                          String telephone, String adresse) {
        Utilisateur u = utilisateurDao.trouverParId(id)
                .orElseThrow(() -> new IllegalArgumentException("Utilisateur introuvable."));

        if (prenom != null && !prenom.isBlank()) u.setPrenom(prenom.trim());
        if (nom != null && !nom.isBlank())       u.setNom(nom.trim());
        u.setTelephone(telephone != null ? telephone.trim() : null);
        u.setAdresse(adresse != null ? adresse.trim() : null);

        return utilisateurDao.mettreAJour(u);
    }

    public void changerMotDePasse(Long id, String ancienMdp, String nouveauMdp) {
        Utilisateur u = utilisateurDao.trouverParId(id)
                .orElseThrow(() -> new IllegalArgumentException("Utilisateur introuvable."));

        if (!PasswordHasher.verifier(ancienMdp, u.getMotDePasseHash())) {
            throw new IllegalArgumentException("L'ancien mot de passe est incorrect.");
        }
        validerMotDePasse(nouveauMdp);

        u.setMotDePasseHash(PasswordHasher.hacher(nouveauMdp));
        utilisateurDao.mettreAJour(u);
    }

    private void validerChampsObligatoires(String prenom, String nom, String email, String mdp) {
        if (prenom == null || prenom.isBlank())   throw new IllegalArgumentException("Le prénom est obligatoire.");
        if (nom == null || nom.isBlank())         throw new IllegalArgumentException("Le nom est obligatoire.");
        if (email == null || email.isBlank()) throw new IllegalArgumentException("Le courriel est obligatoire.");
        if (mdp == null || mdp.isBlank())         throw new IllegalArgumentException("Le mot de passe est obligatoire.");
    }

    private void validerMotDePasse(String mdp) {
        if (mdp == null || mdp.length() < 6) {
            throw new IllegalArgumentException("Le mot de passe doit contenir au moins 6 caractères.");
        }
    }

    private void validerCourriel(String email) {
        if (!email.matches("^[\\w.+\\-]+@[\\w\\-]+\\.[a-zA-Z]{2,}$")) {
            throw new IllegalArgumentException("L'adresse courriel n'est pas valide.");
        }
    }
}
