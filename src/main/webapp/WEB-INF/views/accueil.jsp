<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp"/>

<section class="hero">
    <h1><c:out value="${titre}"/></h1>
    <p>Bienvenue sur la mini-boutique en ligne developpee dans le cadre du cours
       de Programmation Web Serveur III.</p>
    <p>Le projet est en place. Chaque developpeur peut maintenant ajouter
       son module sur sa branche dediee.</p>

    <div class="cards">
        <div class="card">
            <h3>Module Authentification</h3>
            <p>Inscription, connexion, sessions, filtres de securite.</p>
            <small>Dev A &mdash; Mohammed</small>
        </div>
        <div class="card">
            <h3>Module Catalogue</h3>
            <p>Liste, recherche, detail, CRUD admin des produits.</p>
            <small>Dev B</small>
        </div>
        <div class="card">
            <h3>Module Panier &amp; Commande</h3>
            <p>Panier session, commande, email de confirmation.</p>
            <small>Dev C &mdash; Emile</small>
        </div>
    </div>
</section>

<jsp:include page="footer.jsp"/>
