package com.eboutique.modele;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * POJO stocké dans HttpSession - n'est PAS une entité JPA.
 */
public class LignePanier implements Serializable {

    private static final long serialVersionUID = 1L;

    private Product produit;
    private int quantite;

    public LignePanier() {}

    public LignePanier(Product produit, int quantite) {
        this.produit = produit;
        this.quantite = quantite;
    }

    public BigDecimal getSousTotal() {
        if (produit == null || produit.getPrice() == null) {
            return BigDecimal.ZERO;
        }
        return produit.getPrice().multiply(BigDecimal.valueOf(quantite));
    }

    public Product getProduit() { return produit; }
    public void setProduit(Product produit) { this.produit = produit; }

    public int getQuantite() { return quantite; }
    public void setQuantite(int quantite) { this.quantite = quantite; }
}
