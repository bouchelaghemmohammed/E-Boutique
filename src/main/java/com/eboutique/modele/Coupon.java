package com.eboutique.modele;

import jakarta.persistence.*;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Coupon de réduction.
 * type = "POURCENTAGE" → reduction = ex. 15 (= 15%)
 * type = "MONTANT" → reduction = ex. 10.00 (= 10 $)
 */
@Entity
@Table(name = "coupons")
public class Coupon implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String code;

    /** "POURCENTAGE" ou "MONTANT" */
    @Column(nullable = false, length = 20)
    private String type;

    /** Valeur de la réduction (% ou $ selon type) */
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal reduction;

    @Column(nullable = false)
    private boolean actif = true;

    @Column(name = "date_creation", nullable = false, updatable = false)
    private LocalDateTime dateCreation;

    @PrePersist
    protected void onCreate() {
        dateCreation = LocalDateTime.now();
    }

    // --- Getters / Setters ---

    public Long getId() {
        return id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code != null ? code.toUpperCase().trim() : null;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public BigDecimal getReduction() {
        return reduction;
    }

    public void setReduction(BigDecimal reduction) {
        this.reduction = reduction;
    }

    public boolean isActif() {
        return actif;
    }

    public void setActif(boolean actif) {
        this.actif = actif;
    }

    public LocalDateTime getDateCreation() {
        return dateCreation;
    }

    /**
     * Calcule le montant de la réduction à appliquer sur un sous-total.
     */
    public BigDecimal calculerReduction(BigDecimal sousTotal) {
        if (sousTotal == null || sousTotal.compareTo(BigDecimal.ZERO) <= 0)
            return BigDecimal.ZERO;
        if ("POURCENTAGE".equals(type)) {
            return sousTotal.multiply(reduction).divide(BigDecimal.valueOf(100), 2, java.math.RoundingMode.HALF_UP);
        } else if ("MONTANT".equals(type)) {
            // La réduction ne peut pas dépasser le sous-total
            return reduction.min(sousTotal);
        }
        return BigDecimal.ZERO;
    }
}
