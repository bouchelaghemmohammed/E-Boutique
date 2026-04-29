package com.eboutique.servlet;

import com.eboutique.dao.CommandeDao;
import com.eboutique.modele.Commande;
import com.eboutique.modele.Panier;
import com.eboutique.modele.Produit;
import com.eboutique.modele.Utilisateur;
import com.eboutique.service.MailService;
import com.eboutique.util.JpaUtil;

import jakarta.mail.MessagingException;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

    private final CommandeDao commandeDao = new CommandeDao();
    private final MailService mailService = new MailService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Panier panier = getPanier(req);
        if (panier == null || panier.estVide()) {
            resp.sendRedirect(req.getContextPath() + "/panier");
            return;
        }
        if (getUtilisateurConnecte(req) == null) {
            resp.sendRedirect(req.getContextPath() + "/connexion");
            return;
        }

        req.setAttribute("panier", panier);
        req.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Panier panier = getPanier(req);
        Utilisateur utilisateur = getUtilisateurConnecte(req);

        if (panier == null || panier.estVide()) {
            resp.sendRedirect(req.getContextPath() + "/panier");
            return;
        }
        if (utilisateur == null) {
            resp.sendRedirect(req.getContextPath() + "/connexion");
            return;
        }

        String adresse = req.getParameter("adresseLivraison");
        if (adresse == null || adresse.isBlank()) {
            req.setAttribute("erreur", "L'adresse de livraison est obligatoire.");
            req.setAttribute("panier", panier);
            req.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(req, resp);
            return;
        }

        // On rattache les Produit a un EntityManager pour avoir des entites managees.
        Commande commande = construireCommande(panier, utilisateur, adresse);

        try {
            commandeDao.sauvegarder(commande);
        } catch (RuntimeException e) {
            req.setAttribute("erreur", "Erreur lors de l'enregistrement de la commande.");
            req.setAttribute("panier", panier);
            req.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(req, resp);
            return;
        }

        // Email de confirmation - n'echoue pas la commande si l'envoi plante.
        try {
            mailService.envoyerConfirmationCommande(commande);
        } catch (MessagingException e) {
            getServletContext().log("Echec envoi email pour commande " + commande.getId(), e);
        }

        // Vider le panier apres validation
        panier.vider();

        resp.sendRedirect(req.getContextPath() + "/historique?confirmee=" + commande.getId());
    }

    private Commande construireCommande(Panier panier, Utilisateur utilisateur, String adresse) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            Utilisateur utilisateurManaged = em.find(Utilisateur.class, utilisateur.getId());
            Commande commande = new Commande();
            commande.setUtilisateur(utilisateurManaged);
            commande.setAdresseLivraison(adresse);
            for (var lp : panier.getLignes()) {
                Produit produitManaged = em.find(Produit.class, lp.getProduit().getId());
                if (produitManaged == null) continue;
                var ligne = new com.eboutique.modele.LigneCommande(
                        produitManaged, lp.getQuantite(), produitManaged.getPrix());
                commande.ajouterLigne(ligne);
            }
            commande.calculerTotal();
            return commande;
        } finally {
            em.close();
        }
    }

    private Panier getPanier(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (Panier) session.getAttribute("panier");
    }

    private Utilisateur getUtilisateurConnecte(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (Utilisateur) session.getAttribute("utilisateurConnecte");
    }
}
