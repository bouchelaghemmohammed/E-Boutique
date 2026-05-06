package com.eboutique.service;

import com.eboutique.dao.ProductDao;
import com.eboutique.modele.Product;
import java.util.List;
import java.util.Optional;

public class ProductService {

    private final ProductDao productDao = new ProductDao();

    public List<Product> listerTousLesProduits() {
        return productDao.listerTous();
    }

    public Optional<Product> trouverParId(Long id) {
        return productDao.trouverParId(id);
    }
}
