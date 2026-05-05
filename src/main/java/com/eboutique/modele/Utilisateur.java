package com.eboutique.modele;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "utilisateurs")
public class Utilisateur implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Le prénom est obligatoire.")
    @Size(max = 80)
    @Column(nullable = false, length = 80)
    private String prenom;

    @NotBlank(message = "Le nom est obligatoire.")
    @Size(max = 80)
    @Column(nullable = false, length = 80)
    private String nom;

    @NotBlank(message = "L'adresse courriel est obligatoire.")
    @Email
    @Size(max = 150)
    @Column(nullable = false, unique = true, length = 150)
    private String email; // Match diagram

    @Column(name = "mot_de_passe_hash", nullable = false, length = 72)
    private String motDePasseHash; // Match diagram

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private Role role = Role.USER;

    @Column(nullable = false)
    private boolean actif = true; // Match diagram

    @Column(name = "cree_le", nullable = false, updatable = false)
    private LocalDateTime creeLe; // Match diagram

    @Column(length = 20)
    private String telephone;

    @Column(columnDefinition = "TEXT")
    private String adresse;

    public Utilisateur() {}

    @PrePersist
    protected void avantPersistance() {
        if (this.creeLe == null) this.creeLe = LocalDateTime.now();
    }

    // Getters / Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getPrenom() { return prenom; }
    public void setPrenom(String prenom) { this.prenom = prenom; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getMotDePasseHash() { return motDePasseHash; }
    public void setMotDePasseHash(String motDePasseHash) { this.motDePasseHash = motDePasseHash; }
    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }
    public boolean isActif() { return actif; }
    public void setActif(boolean actif) { this.actif = actif; }
    public LocalDateTime getCreeLe() { return creeLe; }
    public void setCreeLe(LocalDateTime creeLe) { this.creeLe = creeLe; }
    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }
    public String getAdresse() { return adresse; }
    public void setAdresse(String adresse) { this.adresse = adresse; }

    public String getNomComplet() { return prenom + " " + nom; }
    public boolean isAdmin() { return Role.ADMIN.equals(this.role); }
}
