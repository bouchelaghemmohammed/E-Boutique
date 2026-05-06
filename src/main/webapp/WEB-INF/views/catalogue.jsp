<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="header.jsp"/>

<div class="section-title" style="margin-bottom:1.5rem;">
    🛍 Catalogue
</div>

<c:choose>
    <c:when test="${not empty produits}">
        <div class="product-grid">
            <c:forEach var="p" items="${produits}">
                <div class="product-card">
                    <div class="product-card__image">
                        <c:choose>
                            <c:when test="${not empty p.imagePath}">
                                <img src="${p.imagePath}" alt="${p.name}">
                            </c:when>
                            <c:otherwise>
                                <div class="text-muted flex-center" style="height:100%">Image indisponible</div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="product-card__content">
                        <div class="product-card__category">${p.category.name}</div>
                        <h3 class="product-card__title">${p.name}</h3>
                        <p class="text-sm text-muted mb-2">
                            ${p.description.length() > 80 ? p.description.substring(0, 80).concat('...') : p.description}
                        </p>
                        <div class="product-card__price">
                            <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="€"/>
                        </div>

                        <c:choose>
                            <c:when test="${not empty utilisateurConnecte}">
                                <form action="${pageContext.request.contextPath}/panier" method="POST">
                                    <input type="hidden" name="action" value="ajouter">
                                    <input type="hidden" name="produitId" value="${p.id}">
                                    <button type="submit" class="btn btn-full">
                                        🛒 Ajouter au panier
                                    </button>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/connexion?redirect=/catalogue"
                                   class="btn btn-full btn-outline">
                                    🔑 Se connecter pour acheter
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:forEach>
        </div>
    </c:when>
    <c:otherwise>
        <div class="alert alert-info">
            Aucun produit n'est disponible pour le moment.
        </div>
    </c:otherwise>
</c:choose>

<jsp:include page="footer.jsp"/>
