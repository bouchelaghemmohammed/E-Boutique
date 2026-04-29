package com.eboutique.service;

import com.eboutique.modele.Commande;
import com.eboutique.modele.LigneCommande;
import com.eboutique.modele.Utilisateur;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.text.NumberFormat;
import java.util.Locale;
import java.util.Properties;

// Configuration via variables d'environnement :
//   MAIL_SMTP_HOST  (defaut: smtp.gmail.com)
//   MAIL_SMTP_PORT  (defaut: 587)
//   MAIL_USERNAME   (votre adresse SMTP)
//   MAIL_PASSWORD   (mot de passe d'application, pas le vrai mdp)
//   MAIL_FROM       (defaut: noreply@eboutique.com)
//
// Pour les tests, utiliser Mailtrap.io (sandbox) :
//   MAIL_SMTP_HOST=sandbox.smtp.mailtrap.io
//   MAIL_SMTP_PORT=2525
public class MailService {

    private static final String SMTP_HOST = env("MAIL_SMTP_HOST", "smtp.gmail.com");
    private static final String SMTP_PORT = env("MAIL_SMTP_PORT", "587");
    private static final String MAIL_USER = env("MAIL_USERNAME", "");
    private static final String MAIL_PASS = env("MAIL_PASSWORD", "");
    private static final String MAIL_FROM = env("MAIL_FROM", "noreply@eboutique.com");

    public void envoyerConfirmationCommande(Commande commande) throws MessagingException {
        Utilisateur client = commande.getUtilisateur();
        if (client == null || client.getCourriel() == null) {
            throw new MessagingException("Destinataire manquant");
        }

        Session session = creerSession();
        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(MAIL_FROM));
        message.setRecipients(Message.RecipientType.TO, client.getCourriel());
        message.setSubject("Confirmation de votre commande #" + commande.getId(), "UTF-8");
        message.setContent(construireCorps(commande), "text/html; charset=UTF-8");

        Transport.send(message);
    }

    private Session creerSession() {
        Properties props = new Properties();
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(MAIL_USER, MAIL_PASS);
            }
        });
    }

    private String construireCorps(Commande c) {
        NumberFormat fmt = NumberFormat.getCurrencyInstance(Locale.CANADA_FRENCH);
        StringBuilder html = new StringBuilder();
        html.append("<html><body style='font-family:sans-serif'>");
        html.append("<h2>Merci pour votre commande !</h2>");
        html.append("<p>Bonjour ").append(c.getUtilisateur().getPrenom()).append(",</p>");
        html.append("<p>Votre commande #").append(c.getId()).append(" a bien ete enregistree.</p>");
        html.append("<table border='1' cellpadding='8' cellspacing='0'>");
        html.append("<tr><th>Produit</th><th>Quantite</th><th>Prix unitaire</th><th>Sous-total</th></tr>");
        for (LigneCommande l : c.getLignes()) {
            html.append("<tr>")
                .append("<td>").append(l.getProduit().getNom()).append("</td>")
                .append("<td>").append(l.getQuantite()).append("</td>")
                .append("<td>").append(fmt.format(l.getPrixUnitaire())).append("</td>")
                .append("<td>").append(fmt.format(l.getSousTotal())).append("</td>")
                .append("</tr>");
        }
        html.append("</table>");
        html.append("<p><strong>Total : ").append(fmt.format(c.getTotal())).append("</strong></p>");
        html.append("<p>Adresse de livraison : ").append(c.getAdresseLivraison()).append("</p>");
        html.append("<p>Cordialement,<br>L'equipe E-Boutique</p>");
        html.append("</body></html>");
        return html.toString();
    }

    private static String env(String cle, String defaut) {
        String v = System.getenv(cle);
        return (v == null || v.isBlank()) ? defaut : v;
    }
}
