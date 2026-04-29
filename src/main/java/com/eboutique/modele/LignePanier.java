package com.eboutique.modele;

import java.io.Serializable;
import java.math.BigDecimal;

// POJO stocke dans HttpSession - n'est PAS une entite JPA.
public class LignePanier implements Serializable {

    private static final long serialVersionUID = 1L;

    private Produit produit;
    private int quantite;

    public LignePanier() {}

    public LignePanier(Produit produit, int quantite) {
        this.produit = produit;
        this.quantite = quantite;
    }

    public BigDecimal getSousTotal() {
        if (produit == null || produit.getPrix() == null) {
            return BigDecimal.ZERO;
        }
        return produit.getPrix().multiply(BigDecimal.valueOf(quantite));
    }

    public Produit getProduit() { return produit; }
    public void setProduit(Produit produit) { this.produit = produit; }

    public int getQuantite() { return quantite; }
    public void setQuantite(int quantite) { this.quantite = quantite; }
}
