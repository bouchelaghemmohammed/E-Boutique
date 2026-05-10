<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="header.jsp"/>

<%-- ── Fil d'Ariane ── --%>
<nav class="breadcrumb animate-fade">
    <a href="${pageContext.request.contextPath}/catalogue">← Retour au catalogue</a>
    <span class="breadcrumb__sep">/</span>
    <c:if test="${not empty produit.category}">
        <a href="${pageContext.request.contextPath}/catalogue?categorieId=${produit.category.id}">
            <c:out value="${produit.category.name}"/>
        </a>
        <span class="breadcrumb__sep">/</span>
    </c:if>
    <span><c:out value="${produit.name}"/></span>
</nav>

<%-- ── Layout deux colonnes ── --%>
<div class="product-detail-layout animate-fade">

    <%-- ── Image ── --%>
    <div class="product-detail__image-wrap">
        <c:choose>
            <c:when test="${not empty produit.imagePath}">
                <img src="${produit.imagePath}"
                     alt="<c:out value='${produit.name}'/>"
                     class="product-detail__img"/>
            </c:when>
            <c:otherwise>
                <div class="product-detail__img-placeholder">
                    <span>🖼</span>
                    <p>Image indisponible</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <%-- ── Informations produit ── --%>
    <div class="product-detail__info">

        <c:if test="${not empty produit.category}">
            <span class="product-detail__badge">
                <c:out value="${produit.category.name}"/>
            </span>
        </c:if>

        <h1 class="product-detail__name"><c:out value="${produit.name}"/></h1>

        <div class="product-detail__price">
            <fmt:formatNumber value="${produit.price}" type="currency" currencySymbol="€"/>
        </div>

        <p class="product-detail__description">
            <c:choose>
                <c:when test="${not empty produit.description}">
                    <c:out value="${produit.description}"/>
                </c:when>
                <c:otherwise>
                    <em class="text-muted">Aucune description disponible.</em>
                </c:otherwise>
            </c:choose>
        </p>

        <%-- Stock --%>
        <div class="product-detail__stock">
            <c:choose>
                <c:when test="${produit.stock > 10}">
                    <span class="badge-stock badge-stock--ok">✓ En stock (${produit.stock} disponibles)</span>
                </c:when>
                <c:when test="${produit.stock > 0}">
                    <span class="badge-stock badge-stock--low">⚠ Stock limité (${produit.stock} restants)</span>
                </c:when>
                <c:otherwise>
                    <span class="badge-stock badge-stock--out">✗ Rupture de stock</span>
                </c:otherwise>
            </c:choose>
        </div>

        <%-- ── Actions ── --%>
        <div class="product-detail__actions">
            <c:choose>
                <c:when test="${produit.stock <= 0}">
                    <button class="btn btn-full" disabled>Rupture de stock</button>
                </c:when>
                <c:when test="${not empty utilisateurConnecte}">
                    <form action="${pageContext.request.contextPath}/panier" method="POST"
                          class="product-detail__add-form">
                        <input type="hidden" name="action"    value="ajouter"/>
                        <input type="hidden" name="produitId" value="${produit.id}"/>
                        <div class="product-detail__qty-row">
                            <label for="qty">Quantité :</label>
                            <input type="number" id="qty" name="quantite"
                                   value="1" min="1" max="${produit.stock}"
                                   class="product-detail__qty-input"/>
                        </div>
                        <button type="submit" class="btn btn-full">
                            🛒 Ajouter au panier
                        </button>
                    </form>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/connexion?redirect=/produit?id=${produit.id}"
                       class="btn btn-full">
                        🔑 Se connecter pour acheter
                    </a>
                </c:otherwise>
            </c:choose>

            <a href="${pageContext.request.contextPath}/catalogue"
               class="btn btn-outline btn-full">
                ← Continuer mes achats
            </a>
        </div>

        <%-- Accès rapide admin --%>
        <c:if test="${not empty utilisateurConnecte && utilisateurConnecte.admin}">
            <div class="product-detail__admin-bar">
                <a href="${pageContext.request.contextPath}/admin/produits?action=modifier&id=${produit.id}"
                   class="btn btn-sm btn-outline">⚙️ Modifier ce produit (admin)</a>
            </div>
        </c:if>
    </div>
</div>

<style>
/* ── Breadcrumb ── */
.breadcrumb {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin-bottom: 2rem;
    font-size: 0.9rem;
    color: var(--text-secondary);
    flex-wrap: wrap;
}
.breadcrumb a { color: var(--green-500); }
.breadcrumb a:hover { color: var(--green-400); }
.breadcrumb__sep { color: var(--text-secondary); opacity: 0.5; }

/* ── Layout deux colonnes ── */
.product-detail-layout {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 3rem;
    align-items: start;
}
@media (max-width: 700px) {
    .product-detail-layout { grid-template-columns: 1fr; gap: 1.5rem; }
}

/* ── Image ── */
.product-detail__image-wrap {
    border-radius: var(--radius-lg);
    overflow: hidden;
    border: 1px solid var(--border);
    background: var(--bg-card);
    aspect-ratio: 1;
    display: flex;
    align-items: center;
    justify-content: center;
}
.product-detail__img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.4s ease;
}
.product-detail__image-wrap:hover .product-detail__img { transform: scale(1.04); }
.product-detail__img-placeholder {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    color: var(--text-secondary);
    padding: 3rem;
}
.product-detail__img-placeholder span { font-size: 4rem; opacity: 0.4; }

/* ── Infos ── */
.product-detail__badge {
    display: inline-block;
    background: rgba(16,185,129,0.12);
    color: var(--green-400);
    font-size: 0.8rem;
    font-weight: 600;
    padding: 0.25rem 0.75rem;
    border-radius: 999px;
    border: 1px solid rgba(16,185,129,0.25);
    margin-bottom: 0.75rem;
}
.product-detail__name {
    font-size: 2rem;
    font-weight: 800;
    line-height: 1.2;
    color: var(--text-primary);
    margin-bottom: 1rem;
}
.product-detail__price {
    font-size: 2.2rem;
    font-weight: 800;
    color: var(--green-500);
    margin-bottom: 1.25rem;
}
.product-detail__description {
    font-size: 0.95rem;
    line-height: 1.8;
    color: var(--text-secondary);
    margin-top: 0;
    margin-bottom: 1.5rem;
    white-space: pre-wrap;
}
.product-detail__stock { margin-bottom: 1.5rem; }

/* Badges stock */
.badge-stock {
    display: inline-flex;
    align-items: center;
    gap: 0.35rem;
    font-size: 0.87rem;
    font-weight: 600;
    padding: 0.35rem 0.9rem;
    border-radius: var(--radius-sm);
}
.badge-stock--ok  { background: var(--success-bg);           color: var(--green-500); }
.badge-stock--low { background: rgba(245,158,11,0.12);        color: #f59e0b; }
.badge-stock--out { background: rgba(239,68,68,0.1);          color: var(--red-400); }

/* ── Actions ── */
.product-detail__actions {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
}
.product-detail__add-form {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
}
.product-detail__qty-row {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    font-size: 0.95rem;
    font-weight: 600;
}
.product-detail__qty-input {
    width: 90px;
    padding: 0.45rem 0.6rem;
    border: 1.5px solid var(--border);
    border-radius: var(--radius-sm);
    background: var(--bg-secondary);
    color: var(--text-primary);
    font-size: 0.95rem;
    font-weight: 600;
}
.product-detail__admin-bar {
    margin-top: 1.5rem;
    padding-top: 1rem;
    border-top: 1px solid var(--border);
}
</style>

<jsp:include page="footer.jsp"/>
