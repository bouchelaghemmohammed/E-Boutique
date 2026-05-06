package com.eboutique.filter;

import com.eboutique.modele.User;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Filtre de journalisation.
 * Enregistre chaque requête HTTP : méthode, URI, utilisateur, durée d'exécution.
 */
@WebFilter(filterName = "LogFilter", urlPatterns = {"/*"})
public class LogFilter implements Filter {

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;

        long debut = System.currentTimeMillis();

        chain.doFilter(request, response);

        long duree = System.currentTimeMillis() - debut;

        // Identifier l'utilisateur connecté (si disponible)
        String utilisateur = "anonyme";
        HttpSession session = req.getSession(false);
        if (session != null) {
            User u = (User) session.getAttribute("utilisateurConnecte");
            if (u != null) {
                utilisateur = u.getEmail() + " [" + u.getRole().getName() + "]";
            }
        }

        String log = String.format("[%s] %s %s | user=%s | %dms",
                LocalDateTime.now().format(FMT),
                req.getMethod(),
                req.getRequestURI(),
                utilisateur,
                duree);

        req.getServletContext().log(log);
    }
}
