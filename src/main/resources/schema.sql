-- =====================================================
-- E-Boutique - Schema de la base de donnees
-- SGBD : MySQL 8.x
-- =====================================================

DROP DATABASE IF EXISTS eboutique;
CREATE DATABASE eboutique CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE eboutique;

-- -----------------------------------------------------
-- Table : roles
-- -----------------------------------------------------
CREATE TABLE roles (
    id  BIGINT       AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(20)  NOT NULL UNIQUE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table : utilisateurs
-- -----------------------------------------------------
CREATE TABLE utilisateurs (
    id                 BIGINT        AUTO_INCREMENT PRIMARY KEY,
    courriel           VARCHAR(150)  NOT NULL UNIQUE,
    mot_de_passe_hash  VARCHAR(255)  NOT NULL,
    prenom             VARCHAR(80)   NOT NULL,
    nom                VARCHAR(80)   NOT NULL,
    role_id            BIGINT        NOT NULL,
    actif              BOOLEAN       NOT NULL DEFAULT TRUE,
    date_creation      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_utilisateur_role FOREIGN KEY (role_id) REFERENCES roles(id)
) ENGINE=InnoDB;

CREATE INDEX idx_utilisateurs_courriel ON utilisateurs(courriel);

-- -----------------------------------------------------
-- Table : categories
-- -----------------------------------------------------
CREATE TABLE categories (
    id          BIGINT       AUTO_INCREMENT PRIMARY KEY,
    nom         VARCHAR(80)  NOT NULL UNIQUE,
    description VARCHAR(255)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table : produits
-- -----------------------------------------------------
CREATE TABLE produits (
    id            BIGINT         AUTO_INCREMENT PRIMARY KEY,
    nom           VARCHAR(150)   NOT NULL,
    description   TEXT,
    prix          DECIMAL(10,2)  NOT NULL CHECK (prix >= 0),
    stock         INT            NOT NULL DEFAULT 0 CHECK (stock >= 0),
    chemin_image  VARCHAR(255),
    categorie_id  BIGINT,
    date_creation TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_produit_categorie FOREIGN KEY (categorie_id)
        REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE INDEX idx_produits_nom       ON produits(nom);
CREATE INDEX idx_produits_categorie ON produits(categorie_id);

-- -----------------------------------------------------
-- Table : commandes
-- -----------------------------------------------------
CREATE TABLE commandes (
    id                BIGINT         AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id    BIGINT         NOT NULL,
    date_commande     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total             DECIMAL(10,2)  NOT NULL CHECK (total >= 0),
    statut            VARCHAR(20)    NOT NULL DEFAULT 'EN_ATTENTE',
                                     -- EN_ATTENTE / CONFIRMEE / EXPEDIEE / ANNULEE
    adresse_livraison VARCHAR(255)   NOT NULL,
    CONSTRAINT fk_commande_utilisateur FOREIGN KEY (utilisateur_id)
        REFERENCES utilisateurs(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_commandes_utilisateur ON commandes(utilisateur_id);
CREATE INDEX idx_commandes_date        ON commandes(date_commande);

-- -----------------------------------------------------
-- Table : lignes_commande
-- (snapshot du prix au moment de la commande)
-- -----------------------------------------------------
CREATE TABLE lignes_commande (
    id            BIGINT         AUTO_INCREMENT PRIMARY KEY,
    commande_id   BIGINT         NOT NULL,
    produit_id    BIGINT         NOT NULL,
    quantite      INT            NOT NULL CHECK (quantite > 0),
    prix_unitaire DECIMAL(10,2)  NOT NULL CHECK (prix_unitaire >= 0),
    CONSTRAINT fk_ligne_commande FOREIGN KEY (commande_id)
        REFERENCES commandes(id) ON DELETE CASCADE,
    CONSTRAINT fk_ligne_produit FOREIGN KEY (produit_id)
        REFERENCES produits(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_lignes_commande_cmd ON lignes_commande(commande_id);

-- -----------------------------------------------------
-- Table : coupons (BONUS - coupons de reduction)
-- -----------------------------------------------------
CREATE TABLE coupons (
    id                    BIGINT       AUTO_INCREMENT PRIMARY KEY,
    code                  VARCHAR(40)  NOT NULL UNIQUE,
    pourcentage_reduction INT          NOT NULL CHECK (pourcentage_reduction BETWEEN 1 AND 100),
    valide_jusqua         DATE         NOT NULL,
    actif                 BOOLEAN      NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- =====================================================
-- Donnees initiales
-- =====================================================

INSERT INTO roles (nom) VALUES ('ADMIN'), ('UTILISATEUR');

-- Compte admin par defaut
-- Mot de passe = "admin123" (hash BCrypt - a regenerer dans le code)
INSERT INTO utilisateurs (courriel, mot_de_passe_hash, prenom, nom, role_id)
VALUES (
  'admin@eboutique.com',
  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
  'Admin', 'Root',
  (SELECT id FROM roles WHERE nom = 'ADMIN')
);

INSERT INTO categories (nom, description) VALUES
  ('Livres',       'Romans, BD, manuels'),
  ('Electronique', 'Accessoires informatiques et telephonie'),
  ('Vetements',    'Mode homme et femme');

INSERT INTO produits (nom, description, prix, stock, categorie_id) VALUES
  ('Clavier mecanique RGB', 'Clavier gaming switch bleu',           89.99, 25,
     (SELECT id FROM categories WHERE nom='Electronique')),
  ('Souris sans fil',       'Bluetooth, autonomie 6 mois',          29.50, 60,
     (SELECT id FROM categories WHERE nom='Electronique')),
  ('T-shirt Java',          'Coton bio, taille M',                  19.99, 100,
     (SELECT id FROM categories WHERE nom='Vetements')),
  ('Effective Java',        'Joshua Bloch, 3e edition',             45.00, 15,
     (SELECT id FROM categories WHERE nom='Livres'));
