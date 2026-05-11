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
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service d'envoi d'emails via Jakarta Mail (SMTP).
 * Variables d'environnement :
 *   MAIL_SMTP_HOST  -- serveur SMTP (ex: smtp-relay.brevo.com)
 *   MAIL_SMTP_PORT  -- port SMTP (465 pour SSL, 587 pour STARTTLS)
 *   MAIL_SMTP_SSL   -- "true" pour SSL/TLS direct (port 465), "false" pour STARTTLS
 *   MAIL_USERNAME   -- identifiant SMTP
 *   MAIL_PASSWORD   -- mot de passe / cle SMTP
 *   MAIL_FROM       -- adresse expediteur
 */
public class MailService {

    private static final Logger LOG = Logger.getLogger(MailService.class.getName());

    private static String env(String key, String def) {
        String v = System.getenv(key);
        if (v != null && !v.isBlank())
            return v.trim();
        v = System.getProperty(key);
        if (v != null && !v.isBlank())
            return v.trim();
        return def;
    }

    public void envoyerConfirmationCommande(Order order) throws MessagingException {
        final String smtpHost = env("MAIL_SMTP_HOST", "");
        final String smtpPort = env("MAIL_SMTP_PORT", "465");
        final boolean useSsl  = !"false".equalsIgnoreCase(env("MAIL_SMTP_SSL", "true"));
        final String mailUser = env("MAIL_USERNAME", "");
        final String mailPass = env("MAIL_PASSWORD", "");
        final String mailFrom = env("MAIL_FROM", "");

        LOG.info(String.format("[MailService] SMTP=%s:%s ssl=%b user=%s from=%s passBlank=%b",
                smtpHost, smtpPort, useSsl, mailUser, mailFrom, mailPass.isBlank()));

        User client = order.getUser();
        if (client == null || client.getEmail() == null) {
            throw new MessagingException("Destinataire manquant");
        }
        if (mailPass.isBlank() || mailUser.isBlank() || smtpHost.isBlank()) {
            throw new MessagingException(
                    "SMTP non configure -- MAIL_SMTP_HOST='" + smtpHost +
                    "' MAIL_USERNAME='" + mailUser +
                    "' MAIL_PASSWORD blank=" + mailPass.isBlank());
        }

        Properties props = new Properties();
        props.put("mail.smtp.host", smtpHost);
        props.put("mail.smtp.port", smtpPort);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.connectiontimeout", "15000");
        props.put("mail.smtp.timeout", "15000");
        props.put("mail.smtp.writetimeout", "15000");

        if (useSsl) {
            // SSL/TLS direct (port 465)
            props.put("mail.smtp.ssl.enable", "true");
            props.put("mail.smtp.ssl.trust", smtpHost);
            props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        } else {
            // STARTTLS (port 587)
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.starttls.required", "true");
            props.put("mail.smtp.ssl.trust", smtpHost);
            props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        }

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(mailUser, mailPass);
            }
        });

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(mailFrom));
            message.setRecipients(Message.RecipientType.TO,
                    InternetAddress.parse(client.getEmail()));
            message.setSubject("Confirmation de votre commande #" + order.getId(), "UTF-8");
            message.setContent(construireCorps(order), "text/html; charset=UTF-8");

            Transport.send(message);
            LOG.info("[MailService] Email envoye avec succes a " + client.getEmail());

        } catch (MessagingException ex) {
            LOG.log(Level.SEVERE, "[MailService] Echec envoi email : " + ex.getMessage(), ex);
            throw ex;
        }
    }

    private String construireCorps(Order o) {
        NumberFormat fmt = NumberFormat.getCurrencyInstance(Locale.CANADA_FRENCH);
        StringBuilder html = new StringBuilder();
        html.append("<html><body style='font-family:sans-serif'>");
        html.append("<h2>Merci pour votre commande !</h2>");
        html.append("<p>Bonjour ").append(o.getUser().getFirstName()).append(",</p>");
        html.append("<p>Votre commande #").append(o.getId()).append(" a bien ete enregistree.</p>");
        html.append("<table border='1' cellpadding='8' cellspacing='0'>");
        html.append("<tr><th>Produit</th><th>Quantite</th><th>Prix unitaire</th><th>Sous-total</th></tr>");
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
        html.append("<p>Cordialement,<br>L'equipe E-Boutique</p>");
        html.append("</body></html>");
        return html.toString();
    }
}