package com.eboutique.modele;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * POJO stocké dans HttpSession - n'est PAS une entité JPA.
 */
public class Panier implements Serializable {

    private static final long serialVersionUID = 1L;

    private final Map<Long, LignePanier> lignes = new LinkedHashMap<>();

    public void ajouterArticle(Product produit, int quantite) {
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

    public Map<Long, Integer> getContenuPourService() {
        Map<Long, Integer> map = new HashMap<>();
        for (LignePanier lp : lignes.values()) {
            map.put(lp.getProduit().getId(), lp.getQuantite());
        }
        return map;
    }
}
