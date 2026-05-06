package com.eboutique.service;

import com.eboutique.dao.OrderDao;
import com.eboutique.dao.ProductDao;
import com.eboutique.modele.Order;
import com.eboutique.modele.OrderItem;
import com.eboutique.modele.Product;
import com.eboutique.modele.User;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public class OrderService {

    private final OrderDao orderDao = new OrderDao();
    private final ProductDao productDao = new ProductDao();

    public Order passerCommande(User user, Map<Long, Integer> panier, String adresse) {
        if (panier == null || panier.isEmpty()) {
            throw new IllegalArgumentException("Le panier est vide.");
        }

        Order order = new Order();
        order.setUser(user);
        order.setShippingAddress(adresse);
        order.setStatus("PENDING");

        BigDecimal total = BigDecimal.ZERO;

        for (Map.Entry<Long, Integer> entry : panier.entrySet()) {
            Product p = productDao.trouverParId(entry.getKey())
                    .orElseThrow(() -> new RuntimeException("Produit introuvable : " + entry.getKey()));
            
            OrderItem item = new OrderItem();
            item.setProduct(p);
            item.setQuantity(entry.getValue());
            item.setUnitPrice(p.getPrice());
            
            order.addItem(item);
            
            BigDecimal ligneTotal = p.getPrice().multiply(new BigDecimal(entry.getValue()));
            total = total.add(ligneTotal);
        }

        order.setTotal(total);
        orderDao.ajouter(order);
        
        return order;
    }

    public List<Order> listerCommandesUtilisateur(Long userId) {
        return orderDao.listerParUtilisateur(userId);
    }
}
