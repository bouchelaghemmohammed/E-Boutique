<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="header.jsp"/>

<%-- Message "accès refusé" si redirigé depuis RoleFilter --%>
<c:if test="${param.erreur == 'acces_refuse'}">
    <div class="alert alert-danger animate-slide">
        🚫 Accès refusé — Cette section est réservée aux administrateurs.
    </div>
</c:if>

<%-- =========================================================
     En-tête du Dashboard
     ========================================================= --%>
<div class="dashboard-header animate-fade">
    <h1>
        Bonjour, <span><c:out value="${utilisateurConnecte.firstName}"/></span> 👋
    </h1>
    <p class="text-muted">
        <c:choose>
            <c:when test="${utilisateurConnecte.admin}">
                Tableau de bord administrateur — Gérez votre boutique
            </c:when>
            <c:otherwise>
                Votre espace personnel E-Boutique
            </c:otherwise>
        </c:choose>
    </p>
</div>

<%-- =========================================================
     Cartes de statistiques
     ========================================================= --%>
<div class="stats-grid">
    <c:choose>
        <c:when test="${utilisateurConnecte.admin}">
            <%-- Stats ADMIN --%>
            <div class="stat-card animate-slide">
                <div class="stat-card__icon">📦</div>
                <div class="stat-card__value">${nbCommandes}</div>
                <div class="stat-card__label">Commandes totales</div>
            </div>
            <div class="stat-card animate-slide">
                <div class="stat-card__icon">💰</div>
                <div class="stat-card__value">
                    <fmt:formatNumber value="${totalVentes}" type="currency" currencySymbol="€" maxFractionDigits="0"/>
                </div>
                <div class="stat-card__label">Revenus totaux</div>
            </div>
            <div class="stat-card animate-slide">
                <div class="stat-card__icon">👥</div>
                <div class="stat-card__value">${nbUtilisateurs}</div>
                <div class="stat-card__label">Utilisateurs inscrits</div>
            </div>
            <div class="stat-card animate-slide">
                <div class="stat-card__icon">🛍</div>
                <div class="stat-card__value">
                    <c:choose>
                        <c:when test="${nbCommandes > 0}">
                            <fmt:formatNumber value="${totalVentes / nbCommandes}" type="currency" currencySymbol="€" maxFractionDigits="0"/>
                        </c:when>
                        <c:otherwise>—</c:otherwise>
                    </c:choose>
                </div>
                <div class="stat-card__label">Panier moyen</div>
            </div>
        </c:when>
        <c:otherwise>
            <%-- Stats USER --%>
            <div class="stat-card animate-slide">
                <div class="stat-card__icon">📦</div>
                <div class="stat-card__value">${nbCommandes}</div>
                <div class="stat-card__label">Mes commandes</div>
            </div>
            <div class="stat-card animate-slide">
                <div class="stat-card__icon">💳</div>
                <div class="stat-card__value">
                    <fmt:formatNumber value="${totalDepense}" type="currency" currencySymbol="€" maxFractionDigits="0"/>
                </div>
                <div class="stat-card__label">Total dépensé</div>
            </div>
            <div class="stat-card animate-slide">
                <div class="stat-card__icon">🛒</div>
                <div class="stat-card__value">
                    <c:choose>
                        <c:when test="${not empty sessionScope.panier}">
                            ${sessionScope.panier.nombreArticles}
                        </c:when>
                        <c:otherwise>0</c:otherwise>
                    </c:choose>
                </div>
                <div class="stat-card__label">Articles dans le panier</div>
            </div>
            <div class="stat-card animate-slide">
                <div class="stat-card__icon">⭐</div>
                <div class="stat-card__value">
                    <c:choose>
                        <c:when test="${nbCommandes >= 10}">Gold</c:when>
                        <c:when test="${nbCommandes >= 3}">Silver</c:when>
                        <c:otherwise>Nouveau</c:otherwise>
                    </c:choose>
                </div>
                <div class="stat-card__label">Statut fidélité</div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<%-- =========================================================
     Accès rapide
     ========================================================= --%>
<h2 class="section-title">Accès rapide</h2>

<div class="quick-actions">
    <a href="${pageContext.request.contextPath}/catalogue" class="action-card">
        <span class="action-card__icon">🛍</span>
        <span class="action-card__label">Catalogue</span>
    </a>
    <a href="${pageContext.request.contextPath}/panier" class="action-card">
        <span class="action-card__icon">🛒</span>
        <span class="action-card__label">Mon Panier</span>
    </a>
    <a href="${pageContext.request.contextPath}/historique" class="action-card">
        <span class="action-card__icon">📜</span>
        <span class="action-card__label">Historique</span>
    </a>
    <a href="${pageContext.request.contextPath}/profil" class="action-card">
        <span class="action-card__icon">👤</span>
        <span class="action-card__label">Mon Profil</span>
    </a>
    <c:if test="${utilisateurConnecte.admin}">
        <a href="${pageContext.request.contextPath}/admin/produits" class="action-card">
            <span class="action-card__icon">⚙️</span>
            <span class="action-card__label">Gérer Produits</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/commandes" class="action-card">
            <span class="action-card__icon">📋</span>
            <span class="action-card__label">Toutes commandes</span>
        </a>
    </c:if>
</div>

<%-- =========================================================
     Dernières commandes (USER) / Toutes les commandes (ADMIN)
     ========================================================= --%>
<c:choose>
    <c:when test="${utilisateurConnecte.admin && not empty toutesCommandes}">
        <h2 class="section-title">Dernières commandes</h2>
        <div class="table-wrapper mb-3">
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Client</th>
                        <th>Date</th>
                        <th>Total</th>
                        <th>Statut</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="cmd" items="${toutesCommandes}" begin="0" end="4">
                        <tr>
                            <td><strong class="text-green">#${cmd.id}</strong></td>
                            <td><c:out value="${cmd.user.fullName}"/></td>
                            <td>${cmd.orderDateFormatted}</td>
                            <td><fmt:formatNumber value="${cmd.total}" type="currency" currencySymbol="€"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${cmd.status == 'PENDING'}">
                                        <span class="badge badge-yellow">&#9203; En attente</span>
                                    </c:when>
                                    <c:when test="${cmd.status == 'CONFIRMED'}">
                                        <span class="badge badge-green">&#9989; Confirm&#233;e</span>
                                    </c:when>
                                    <c:when test="${cmd.status == 'PREPARING'}">
                                        <span class="badge badge-blue">&#128230; En pr&#233;paration</span>
                                    </c:when>
                                    <c:when test="${cmd.status == 'SHIPPED'}">
                                        <span class="badge badge-blue">&#128666; Exp&#233;di&#233;e</span>
                                    </c:when>
                                    <c:when test="${cmd.status == 'DELIVERED'}">
                                        <span class="badge badge-blue">&#128230; Livr&#233;e</span>
                                    </c:when>
                                    <c:when test="${cmd.status == 'RECEIVED'}">
                                        <span class="badge badge-green">&#127873; R&#233;ceptionn&#233;e</span>
                                    </c:when>
                                    <c:when test="${cmd.status == 'CANCELLED'}">
                                        <span class="badge badge-red">&#10060; Annul&#233;e</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge"><c:out value="${cmd.status}"/></span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </c:when>
    <c:when test="${not utilisateurConnecte.admin && not empty dernieres}">
        <h2 class="section-title">Mes dernières commandes</h2>
        <div class="table-wrapper mb-3">
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Date</th>
                        <th>Total</th>
                        <th>Statut</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="cmd" items="${dernieres}">
                        <tr>
                            <td><strong class="text-green">#${cmd.id}</strong></td>
                            <td>${cmd.orderDateFormatted}</td>
                            <td><fmt:formatNumber value="${cmd.total}" type="currency" currencySymbol="€"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${cmd.status == 'PENDING'}">
                                        <span class="badge badge-yellow">⏳ En attente</span>
                                    </c:when>
                                    <c:when test="${cmd.status == 'CONFIRMED'}">
                                        <span class="badge badge-green">&#9989; Confirm&#233;e</span>
                                    </c:when>
                                    <c:when test="${cmd.status == 'PREPARING'}">
                                        <span class="badge badge-blue">&#128230; En pr&#233;paration</span>
                                    </c:when>
                                    <c:when test="${cmd.status == 'SHIPPED'}">
                                        <span class="badge badge-blue">&#128666; Exp&#233;di&#233;e</span>
                                    </c:when>
                                    <c:when test="${cmd.status == 'DELIVERED'}">
                                        <span class="badge badge-blue">&#128230; Livr&#233;e</span>
                                    </c:when>
                                    <c:when test="${cmd.status == 'RECEIVED'}">
                                        <span class="badge badge-green">&#127873; R&#233;ceptionn&#233;e</span>
                                    </c:when>
                                    <c:when test="${cmd.status == 'CANCELLED'}">
                                        <span class="badge badge-red">&#10060; Annul&#233;e</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge"><c:out value="${cmd.status}"/></span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        <div class="text-right">
            <a href="${pageContext.request.contextPath}/historique" class="btn btn-outline btn-sm">
                Voir tout l'historique →
            </a>
        </div>
    </c:when>
    <c:otherwise>
        <c:if test="${not utilisateurConnecte.admin}">
            <div class="card text-center" style="padding: 3rem 2rem;">
                <div style="font-size: 3rem; margin-bottom: 1rem;">🛍</div>
                <h3 style="color: var(--green-400); margin-bottom: 0.5rem;">Prêt à magasiner ?</h3>
                <p class="text-muted mb-2">Vous n'avez pas encore passé de commande.</p>
                <a href="${pageContext.request.contextPath}/catalogue" class="btn">
                    Découvrir le catalogue
                </a>
            </div>
        </c:if>
    </c:otherwise>
</c:choose>

<jsp:include page="footer.jsp"/>
