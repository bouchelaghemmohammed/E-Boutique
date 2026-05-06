package com.eboutique.modele;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.io.Serializable;
import java.util.Objects;

@Entity
@Table(name = "roles")
public class Role implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Size(max = 20)
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, unique = true)
    private NomRole name;

    public Role() {}

    public Role(NomRole name) {
        this.name = name;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public NomRole getName() {
        return name;
    }

    public void setName(NomRole name) {
        this.name = name;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Role role = (Role) o;
        return Objects.equals(id, role.id) || name == role.name;
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, name);
    }
}
