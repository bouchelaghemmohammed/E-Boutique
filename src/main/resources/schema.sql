-- ==============================================================
--  E-Boutique — Script de création de la base de données MySQL
--  Utilisateur : root / root
--  Base        : eboutique
-- ==============================================================

CREATE DATABASE IF NOT EXISTS eboutique
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE eboutique;

-- --------------------------------------------------------------
-- Table : utilisateurs
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS utilisateurs (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    prenom           VARCHAR(80)  NOT NULL,
    nom              VARCHAR(80)  NOT NULL,
    email            VARCHAR(150) NOT NULL UNIQUE,
    mot_de_passe_hash VARCHAR(72)  NOT NULL,          -- hash BCrypt ($2a$...)
    role             ENUM('USER','ADMIN') NOT NULL DEFAULT 'USER',
    actif            BOOLEAN      NOT NULL DEFAULT TRUE,
    telephone        VARCHAR(20),
    adresse          TEXT,
    cree_le          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Compte administrateur par défaut (mdp: admin1234)
INSERT IGNORE INTO utilisateurs (prenom, nom, email, mot_de_passe_hash, role)
VALUES ('Admin', 'E-Boutique', 'admin@eboutique.com',
        '$2a$12$aTn3QGLqtlP0Vm23ZvJSLuyvd5VqxJiaCwU2CXhvhFe.PFl9pPV5W', 'ADMIN');

-- --------------------------------------------------------------
-- Table : produits
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS produits (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    nom          VARCHAR(150) NOT NULL,
    description  TEXT,
    prix         DECIMAL(10,2) NOT NULL,
    stock        INT          NOT NULL DEFAULT 0,
    categorie    VARCHAR(80),
    chemin_image VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Données de démonstration
INSERT IGNORE INTO produits (nom, description, prix, stock, categorie) VALUES
('Laptop Pro 15"', 'Ordinateur portable haute performance 15 pouces, Core i7, 16GB RAM', 1299.99, 25, 'Informatique'),
('Smartphone X12',  'Smartphone Android 5G, 128GB, triple caméra 108MP',              799.99, 50, 'Téléphonie'),
('Casque Audio BT', 'Casque Bluetooth sans fil, réduction de bruit active, 30h autonomie', 149.99, 100, 'Audio'),
('Clavier Mécanique', 'Clavier gaming RGB, switches Cherry MX Red, disposition AZERTY', 89.99, 75, 'Périphériques'),
('Écran 27" 4K',    'Moniteur 4K UHD 27 pouces, dalle IPS, 144Hz, HDR400',           449.99, 30, 'Écrans'),
('Souris Gaming',   'Souris gaming optique 16000 DPI, 6 boutons programmables, RGB',    59.99, 120, 'Périphériques');

-- --------------------------------------------------------------
-- Table : commandes
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS commandes (
    id                BIGINT AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id    BIGINT        NOT NULL,
    date_commande     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total             DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    statut            ENUM('EN_ATTENTE','CONFIRMEE','EXPEDIEE','LIVREE','ANNULEE')
                        NOT NULL DEFAULT 'EN_ATTENTE',
    adresse_livraison TEXT          NOT NULL,
    CONSTRAINT fk_commandes_utilisateur
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------
-- Table : lignes_commande
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lignes_commande (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    commande_id BIGINT        NOT NULL,
    produit_id  BIGINT        NOT NULL,
    quantite    INT           NOT NULL DEFAULT 1,
    prix_unitaire DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_lc_commande
        FOREIGN KEY (commande_id) REFERENCES commandes(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_lc_produit
        FOREIGN KEY (produit_id) REFERENCES produits(id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
