package com.eboutique.modele;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.Map;

// POJO stocke dans HttpSession - n'est PAS une entite JPA.
// Utilise une Map<produitId, LignePanier> pour fusionner automatiquement
// les ajouts du meme produit.
public class Panier implements Serializable {

    private static final long serialVersionUID = 1L;

    private final Map<Long, LignePanier> lignes = new LinkedHashMap<>();

    public void ajouterArticle(Produit produit, int quantite) {
        if (produit == null || quantite <= 0) return;
        LignePanier existante = lignes.get(produit.getId());
        if (existante != null) {
            existante.setQuantite(existante.getQuantite() + quantite);
        } else {
            lignes.put(produit.getId(), new LignePanier(produit, quantite));
        }
    }

    public void modifierQuantite(Long produitId, int nouvelleQuantite) {
        if (produitId == null) return;
        if (nouvelleQuantite <= 0) {
            lignes.remove(produitId);
            return;
        }
        LignePanier ligne = lignes.get(produitId);
        if (ligne != null) {
            ligne.setQuantite(nouvelleQuantite);
        }
    }

    public void retirerArticle(Long produitId) {
        if (produitId != null) {
            lignes.remove(produitId);
        }
    }

    public void vider() {
        lignes.clear();
    }

    public BigDecimal getTotal() {
        BigDecimal total = BigDecimal.ZERO;
        for (LignePanier l : lignes.values()) {
            total = total.add(l.getSousTotal());
        }
        return total;
    }

    public int getNombreArticles() {
        int n = 0;
        for (LignePanier l : lignes.values()) {
            n += l.getQuantite();
        }
        return n;
    }

    public boolean estVide() {
        return lignes.isEmpty();
    }

    public Collection<LignePanier> getLignes() {
        return lignes.values();
    }

    // Convertit le panier en Commande prete a etre persistee.
    // Le prix unitaire est fige a partir du Produit courant.
    public Commande versCommande(Utilisateur utilisateur, String adresseLivraison) {
        Commande commande = new Commande();
        commande.setUtilisateur(utilisateur);
        commande.setAdresseLivraison(adresseLivraison);
        for (LignePanier lp : lignes.values()) {
            LigneCommande ligne = new LigneCommande(
                    lp.getProduit(),
                    lp.getQuantite(),
                    lp.getProduit().getPrix()
            );
            commande.ajouterLigne(ligne);
        }
        commande.calculerTotal();
        return commande;
    }
}
