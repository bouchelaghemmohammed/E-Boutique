-- =====================================================
-- E-Boutique — Schéma de base de données
-- SGBD cible : MySQL 8.x
-- =====================================================
 
DROP DATABASE IF EXISTS eboutique;
CREATE DATABASE eboutique CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE eboutique;
 
-- -----------------------------------------------------
-- Table : roles
-- -----------------------------------------------------
CREATE TABLE roles (
    id          BIGINT       AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(20)  NOT NULL UNIQUE
) ENGINE=InnoDB;
 
-- -----------------------------------------------------
-- Table : users
-- -----------------------------------------------------
CREATE TABLE users (
    id              BIGINT        AUTO_INCREMENT PRIMARY KEY,
    email           VARCHAR(150)  NOT NULL UNIQUE,
    password_hash   VARCHAR(255)  NOT NULL,         -- BCrypt
    first_name      VARCHAR(80)   NOT NULL,
    last_name       VARCHAR(80)   NOT NULL,
    role_id         BIGINT        NOT NULL,
    enabled         BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_role FOREIGN KEY (role_id) REFERENCES roles(id)
) ENGINE=InnoDB;
 
CREATE INDEX idx_users_email ON users(email);
 
-- -----------------------------------------------------
-- Table : categories
-- -----------------------------------------------------
CREATE TABLE categories (
    id          BIGINT        AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(80)   NOT NULL UNIQUE,
    description VARCHAR(255)
) ENGINE=InnoDB;
 
-- -----------------------------------------------------
-- Table : products
-- -----------------------------------------------------
CREATE TABLE products (
    id           BIGINT         AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(150)   NOT NULL,
    description  TEXT,
    price        DECIMAL(10,2)  NOT NULL CHECK (price >= 0),
    stock        INT            NOT NULL DEFAULT 0 CHECK (stock >= 0),
    image_path   VARCHAR(255),                       -- chemin relatif vers /assets/products/
    category_id  BIGINT,
    created_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_product_category FOREIGN KEY (category_id)
        REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB;
 
CREATE INDEX idx_products_name     ON products(name);
CREATE INDEX idx_products_category ON products(category_id);
 
-- -----------------------------------------------------
-- Table : orders
-- -----------------------------------------------------
CREATE TABLE orders (
    id                BIGINT         AUTO_INCREMENT PRIMARY KEY,
    user_id           BIGINT         NOT NULL,
    order_date        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total             DECIMAL(10,2)  NOT NULL CHECK (total >= 0),
    status            VARCHAR(20)    NOT NULL DEFAULT 'PENDING',
                                     -- PENDING / CONFIRMED / SHIPPED / CANCELLED
    shipping_address  VARCHAR(255)   NOT NULL,
    CONSTRAINT fk_order_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;
 
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_date ON orders(order_date);
 
-- -----------------------------------------------------
-- Table : order_items
-- (snapshot du prix au moment de la commande — important !)
-- -----------------------------------------------------
CREATE TABLE order_items (
    id          BIGINT         AUTO_INCREMENT PRIMARY KEY,
    order_id    BIGINT         NOT NULL,
    product_id  BIGINT         NOT NULL,
    quantity    INT            NOT NULL CHECK (quantity > 0),
    unit_price  DECIMAL(10,2)  NOT NULL CHECK (unit_price >= 0),
    CONSTRAINT fk_oi_order   FOREIGN KEY (order_id)
        REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_oi_product FOREIGN KEY (product_id)
        REFERENCES products(id) ON DELETE RESTRICT
) ENGINE=InnoDB;
 
CREATE INDEX idx_oi_order ON order_items(order_id);
 
-- -----------------------------------------------------
-- Table : coupons (BONUS — coupons de réduction)
-- -----------------------------------------------------
CREATE TABLE coupons (
    id                BIGINT        AUTO_INCREMENT PRIMARY KEY,
    code              VARCHAR(40)   NOT NULL UNIQUE,
    discount_percent  INT           NOT NULL CHECK (discount_percent BETWEEN 1 AND 100),
    valid_until       DATE          NOT NULL,
    active            BOOLEAN       NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;
 
-- =====================================================
-- Données initiales
-- =====================================================
 
INSERT INTO roles (name) VALUES ('ADMIN'), ('USER');
 
-- Compte admin par défaut
-- mot de passe = "admin123"
INSERT INTO users (email, password_hash, first_name, last_name, role_id)
VALUES (
  'admin@eboutique.com',
  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
  'Admin', 'Root',
  (SELECT id FROM roles WHERE name = 'ADMIN')
);
 
INSERT INTO categories (name, description) VALUES
  ('Livres',       'Romans, BD, manuels'),
  ('Électronique', 'Accessoires informatiques et téléphonie'),
  ('Vêtements',    'Mode homme et femme');
 
INSERT INTO products (name, description, price, stock, category_id) VALUES
  ('Clavier mécanique RGB', 'Clavier gaming switch bleu',           89.99, 25,
     (SELECT id FROM categories WHERE name='Électronique')),
  ('Souris sans fil',       'Bluetooth, autonomie 6 mois',          29.50, 60,
     (SELECT id FROM categories WHERE name='Électronique')),
  ('T-shirt Java',          'Coton bio, taille M',                  19.99, 100,
     (SELECT id FROM categories WHERE name='Vêtements')),
  ('Effective Java',        'Joshua Bloch, 3e édition',             45.00, 15,
     (SELECT id FROM categories WHERE name='Livres'));
