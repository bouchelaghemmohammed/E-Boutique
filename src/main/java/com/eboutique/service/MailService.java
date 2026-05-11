package com.eboutique.service;

import com.eboutique.modele.Order;
import com.eboutique.modele.OrderItem;
import com.eboutique.modele.User;

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

/**
 * Service d'envoi d'emails.
 */
public class MailService {

    private static final String SMTP_HOST = env("MAIL_SMTP_HOST", "smtp.gmail.com");
    private static final String SMTP_PORT = env("MAIL_SMTP_PORT", "587");
    private static final String MAIL_USER = env("MAIL_USERNAME", "");
    private static final String MAIL_PASS = env("MAIL_PASSWORD", "");
    private static final String MAIL_FROM = env("MAIL_FROM", "");

    public void envoyerConfirmationCommande(Order order) throws MessagingException {
        User client = order.getUser();
        if (client == null || client.getEmail() == null) {
            throw new MessagingException("Destinataire manquant");
        }

        // Si pas de mot de passe SMTP configuré, on ne tente pas la connexion
        if (MAIL_PASS == null || MAIL_PASS.isBlank()) {
            throw new MessagingException("SMTP non configuré (MAIL_PASSWORD manquant)");
        }

        Session session = creerSession();
        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(MAIL_FROM));
        message.setRecipients(Message.RecipientType.TO,
                InternetAddress.parse(client.getEmail()));
        message.setSubject("Confirmation de votre commande #" + order.getId(), "UTF-8");
        message.setContent(construireCorps(order), "text/html; charset=UTF-8");

        Transport.send(message);
    }

    private Session creerSession() {
        Properties props = new Properties();
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.starttls.required", "true");
        // Brevo relay — accepter le certificat TLS
        props.put("mail.smtp.ssl.trust", "smtp-relay.brevo.com");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        // Timeouts (10 s) — Brevo peut être lent sur Railway
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");
        props.put("mail.smtp.writetimeout", "10000");

        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(MAIL_USER, MAIL_PASS);
            }
        });
    }

    private String construireCorps(Order o) {
        NumberFormat fmt = NumberFormat.getCurrencyInstance(Locale.CANADA_FRENCH);
        StringBuilder html = new StringBuilder();
        html.append("<html><body style='font-family:sans-serif'>");
        html.append("<h2>Merci pour votre commande !</h2>");
        html.append("<p>Bonjour ").append(o.getUser().getFirstName()).append(",</p>");
        html.append("<p>Votre commande #").append(o.getId()).append(" a bien été enregistrée.</p>");
        html.append("<table border='1' cellpadding='8' cellspacing='0'>");
        html.append("<tr><th>Produit</th><th>Quantité</th><th>Prix unitaire</th><th>Sous-total</th></tr>");
        for (OrderItem l : o.getItems()) {
            html.append("<tr>")
                    .append("<td>").append(l.getProduct().getName()).append("</td>")
                    .append("<td>").append(l.getQuantity()).append("</td>")
                    .append("<td>").append(fmt.format(l.getUnitPrice())).append("</td>")
                    .append("<td>").append(fmt.format(l.getSousTotal())).append("</td>")
                    .append("</tr>");
        }
        html.append("</table>");
        html.append("<p><strong>Total : ").append(fmt.format(o.getTotal())).append("</strong></p>");
        html.append("<p>Adresse de livraison : ").append(o.getShippingAddress()).append("</p>");
        html.append("<p>Cordialement,<br>L'équipe E-Boutique</p>");
        html.append("</body></html>");
        return html.toString();
    }

    private static String env(String cle, String defaut) {
        String v = System.getenv(cle);
        return (v == null || v.isBlank()) ? defaut : v;
    }
}
