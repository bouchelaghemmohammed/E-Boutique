<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta name="description" content="E-Boutique — Votre boutique en ligne Jakarta EE"/>
    <title>E-Boutique</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css"/>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🛍</text></svg>"/>
    <script>
        // Appliquer le thème immédiatement avant le rendu du body
        const savedTheme = localStorage.getItem('theme') || 'light';
        if (savedTheme === 'dark') {
            document.documentElement.classList.add('dark-mode');
        }
    </script>
</head>
<body>

<nav class="navbar">
    <div class="navbar__inner">
        <a href="${pageContext.request.contextPath}/dashboard" class="navbar__brand">
<%--            🛍--%>
            🛒 E-<span>Boutique</span>
        </a>

        <div class="navbar__links">
            <a href="${pageContext.request.contextPath}/accueil"
               class="${pageContext.request.servletPath.contains('accueil') || pageContext.request.servletPath.equals('/') ? 'active' : ''}">
                🏠 Accueil
            </a>
            <a href="${pageContext.request.contextPath}/catalogue"
               class="${pageContext.request.servletPath.contains('catalogue') ? 'active' : ''}">
                📦 Catalogue
            </a>
            <c:if test="${not empty utilisateurConnecte}">
                <a href="${pageContext.request.contextPath}/dashboard"
                   class="${pageContext.request.servletPath.contains('dashboard') ? 'active' : ''}">
                    📊 Dashboard
                </a>
            </c:if>
            <c:if test="${not empty utilisateurConnecte && utilisateurConnecte.admin}">
                <div class="navbar__dropdown">
                    <button class="navbar__dropdown-btn
                        ${pageContext.request.servletPath.contains('admin') ? 'active' : ''}">
                        &#9881;&#65039; Admin &#9660;
                    </button>
                    <div class="navbar__dropdown-menu">
                        <a href="${pageContext.request.contextPath}/admin/produits">
                            &#128230; Produits
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/commandes">
                            &#128666; Commandes
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/coupons">
                            &#127915; Coupons
                        </a>
                    </div>
                </div>
            </c:if>
        </div>

        <div class="navbar__right">
            <%-- Bouton Theme --%>
            <button id="themeToggle" class="theme-toggle" title="Changer de thème">
                <span class="sun-icon">☀️</span>
                <span class="moon-icon">🌙</span>
            </button>
            <c:choose>
                <c:when test="${not empty utilisateurConnecte}">
                    <%-- Badge panier --%>
                    <a href="${pageContext.request.contextPath}/panier" class="cart-badge">
                        🛒
                        <c:if test="${not empty sessionScope.panier && !sessionScope.panier.estVide()}">
                            <span class="badge">${sessionScope.panier.nombreArticles}</span>
                        </c:if>
                        Panier
                    </a>

                    <%-- Profil utilisateur --%>
                    <a href="${pageContext.request.contextPath}/profil" class="user-chip">
                        <span class="avatar">
                            <c:out value="${utilisateurConnecte.firstName.substring(0,1).toUpperCase()}"/>
                        </span>
                        <c:out value="${utilisateurConnecte.firstName}"/>
                        <c:if test="${utilisateurConnecte.admin}">
                            &nbsp;<span class="badge badge-admin">Admin</span>
                        </c:if>
                    </a>

                    <a href="${pageContext.request.contextPath}/deconnexion"
                       onclick="localStorage.removeItem('panier_data')"
                       class="btn btn-outline btn-sm">Déconnexion</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/connexion"
                       class="btn btn-outline btn-sm">Connexion</a>
                    <a href="${pageContext.request.contextPath}/inscription"
                       class="btn btn-sm">Inscription</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</nav>

<script>
    // Theme Manager
    const themeBtn = document.getElementById('themeToggle');
    
    // On applique aussi sur body au chargement pour être sûr
    if (localStorage.getItem('theme') === 'dark') {
        document.body.classList.add('dark-mode');
    }

    themeBtn.addEventListener('click', () => {
        document.body.classList.toggle('dark-mode');
        // On synchronise html et body
        document.documentElement.classList.toggle('dark-mode');
        
        const isDark = document.body.classList.contains('dark-mode');
        localStorage.setItem('theme', isDark ? 'dark' : 'light');
    });
</script>

<%-- Sync panier vers localStorage (persiste même si le serveur redémarre) --%>
<script>
(function() {
    var d = '';
    <c:forEach var="lg" items="${sessionScope.panier.lignes}">
    if (d) d += '|';
    d += '${lg.produit.id}:${lg.quantite}';
    </c:forEach>
    if (d) {
        // Le serveur a un panier → on met à jour localStorage
        localStorage.setItem('panier_data', d);
    } else if (${not empty utilisateurConnecte}) {
        // Utilisateur connecté mais panier vide côté serveur → on efface localStorage
        localStorage.removeItem('panier_data');
    }
    // Si non connecté et panier serveur vide → on garde localStorage tel quel
})();
</script>

<main>
    <div class="container">
