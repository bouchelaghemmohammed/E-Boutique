package com.eboutique.service;

import com.eboutique.dao.ProductDao;
import com.eboutique.modele.Category;
import com.eboutique.modele.Product;
import java.util.List;
import java.util.Optional;

public class ProductService {

    private final ProductDao productDao = new ProductDao();

    public List<Product> listerTousLesProduits() {
        return productDao.listerTous();
    }

    public List<Product> rechercherProduits(String nom, Long categorieId, String stockFiltre) {
        return productDao.rechercher(nom, categorieId, stockFiltre);
    }

    public Optional<Product> trouverParId(Long id) {
        return productDao.trouverParId(id);
    }

    public void creerProduit(Product p) {
        productDao.ajouter(p);
    }

    public void mettreAJour(Product p) {
        productDao.mettreAJour(p);
    }

    public void supprimer(Long id) {
        productDao.supprimer(id);
    }

    public List<Category> listerCategories() {
        return productDao.listerCategories();
    }
}
