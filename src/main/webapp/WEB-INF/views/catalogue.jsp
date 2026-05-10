<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="header.jsp"/>

<%-- ── Barre de recherche + filtre catégorie (formulaire unique) ── --%>
<div class="catalogue-toolbar animate-fade">
    <form method="get" action="${pageContext.request.contextPath}/catalogue"
          id="form-catalogue" class="catalogue-search-row">

        <%-- Recherche textuelle --%>
        <input type="text"
               name="q"
               id="catalogue-q"
               value="<c:out value='${q}'/>"
               class="form-control"
               placeholder="🔍 Rechercher un produit..."
               autocomplete="off"/>

        <%-- Dropdown catégorie --%>
        <select name="categorieId"
                id="catalogue-cat"
                class="form-control catalogue-select"
                onchange="document.getElementById('form-catalogue').submit()">
            <option value="">— Toutes les catégories —</option>
            <c:forEach var="cat" items="${categories}">
                <option value="${cat.id}"
                    <c:if test="${not empty categorieId && categorieId == cat.id}">selected</c:if>>
                    <c:out value="${cat.name}"/>
                </option>
            </c:forEach>
        </select>

        <button type="submit" class="btn">Rechercher</button>

        <c:if test="${not empty q || not empty categorieId}">
            <a href="${pageContext.request.contextPath}/catalogue" class="btn btn-outline" title="Effacer les filtres">✕</a>
        </c:if>
    </form>
</div>

<%-- ── Résultats info ── --%>
<div class="catalogue-results-info text-muted text-sm mb-2">
    <c:choose>
        <c:when test="${not empty q && not empty produits}">
            <strong>${produits.size()}</strong> résultat(s) pour "<c:out value='${q}'/>"
        </c:when>
        <c:when test="${not empty q && empty produits}">
            Aucun résultat pour "<c:out value='${q}'/>" —
            <a href="${pageContext.request.contextPath}/catalogue">voir tout le catalogue</a>
        </c:when>
        <c:when test="${not empty categorieId && not empty produits}">
            <strong>${produits.size()}</strong> produit(s) dans cette catégorie
        </c:when>
    </c:choose>
</div>

<c:choose>
    <c:when test="${not empty produits}">
        <div class="product-grid">
            <c:forEach var="p" items="${produits}">
                <div class="product-card animate-fade">
                    <%-- Image cliquable vers le détail --%>
                    <a href="${pageContext.request.contextPath}/produit?id=${p.id}"
                       class="product-card__image">
                        <c:choose>
                            <c:when test="${not empty p.imagePath}">
                                <img src="${p.imagePath}" alt="<c:out value='${p.name}'/>">
                            </c:when>
                            <c:otherwise>
                                <div class="text-muted flex-center" style="height:100%;font-size:3rem;">📦</div>
                            </c:otherwise>
                        </c:choose>
                    </a>
                    <div class="product-card__content">
                        <c:if test="${not empty p.category}">
                            <div class="product-card__category">
                                <c:out value="${p.category.name}"/>
                            </div>
                        </c:if>
                        <h3 class="product-card__title">
                            <a href="${pageContext.request.contextPath}/produit?id=${p.id}"
                               style="color:inherit;text-decoration:none;">
                                <c:out value="${p.name}"/>
                            </a>
                        </h3>
                        <p class="text-sm text-muted mb-2">
                            <c:choose>
                                <c:when test="${not empty p.description && p.description.length() > 80}">
                                    ${p.description.substring(0, 80)}…
                                </c:when>
                                <c:otherwise>
                                    <c:out value="${p.description}"/>
                                </c:otherwise>
                            </c:choose>
                        </p>
                        <div class="product-card__price">
                            <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="€"/>
                        </div>
                        <c:choose>
                            <c:when test="${p.stock <= 0}">
                                <span class="badge badge-red" style="margin-bottom:0.5rem;">Rupture de stock</span>
                            </c:when>
                            <c:when test="${p.stock < 5}">
                                <span class="badge badge-yellow" style="margin-bottom:0.5rem;">Stock limité (${p.stock})</span>
                            </c:when>
                        </c:choose>
                        <%-- Boutons action --%>
                        <div class="product-card__btns">
                            <a href="${pageContext.request.contextPath}/produit?id=${p.id}"
                               class="btn btn-outline btn-sm">👁 Détail</a>
                            <c:choose>
                                <c:when test="${p.stock <= 0}">
                                    <button class="btn btn-sm" disabled>Indisponible</button>
                                </c:when>
                                <c:when test="${not empty utilisateurConnecte}">
                                    <form action="${pageContext.request.contextPath}/panier" method="POST"
                                          style="margin:0;flex:1;display:flex;">
                                        <input type="hidden" name="action"    value="ajouter">
                                        <input type="hidden" name="produitId" value="${p.id}">
                                        <button type="submit" class="btn btn-sm" style="width:100%;">🛒 Ajouter</button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/connexion?redirect=/catalogue"
                                       class="btn btn-sm btn-outline">🔑 Connexion</a>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </c:when>
    <c:otherwise>
        <div class="alert alert-info animate-fade">
            Aucun produit disponible pour le moment.
        </div>
    </c:otherwise>
</c:choose>

<jsp:include page="footer.jsp"/>

