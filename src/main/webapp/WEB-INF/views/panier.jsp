<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="header.jsp"/>

<div class="section-title">🛒 Mon Panier</div>

<c:choose>
    <c:when test="${panier == null || panier.estVide()}">
        <div class="cart-empty animate-fade">
            <div class="cart-empty__icon">🛒</div>
            <h2>Votre panier est vide</h2>
            <p class="text-muted">Découvrez nos produits et commencez vos achats !</p>
            <a class="btn btn-lg" href="${pageContext.request.contextPath}/catalogue">
                🛍 Voir le catalogue
            </a>
        </div>
    </c:when>
    <c:otherwise>
        <div class="cart-layout">

            <%-- ── Colonne articles ── --%>
            <div class="cart-items">
                <c:forEach var="ligne" items="${panier.lignes}">
                    <div class="cart-item animate-slide">

                        <%-- Image --%>
                        <div class="cart-item__img">
                            <c:choose>
                                <c:when test="${not empty ligne.produit.imagePath}">
                                    <img src="${ligne.produit.imagePath}" alt="<c:out value='${ligne.produit.name}'/>"/>
                                </c:when>
                                <c:otherwise>
                                    <div class="cart-item__no-img">📦</div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <%-- Infos produit --%>
                        <div class="cart-item__info">
                            <h3 class="cart-item__name"><c:out value="${ligne.produit.name}"/></h3>
                            <p class="text-muted text-sm">
                                <c:if test="${not empty ligne.produit.category}">
                                    ${ligne.produit.category.name}
                                </c:if>
                            </p>
                            <div class="text-muted text-sm">
                                <fmt:formatNumber value="${ligne.produit.price}" type="currency" currencySymbol="€"/> / unité
                            </div>
                        </div>

                        <%-- Contrôle quantité (form caché + stepper JS) --%>
                        <div class="cart-item__controls">
                            <%-- Form caché soumis par JS --%>
                            <form method="post"
                                  action="${pageContext.request.contextPath}/panier"
                                  id="form-${ligne.produit.id}">
                                <input type="hidden" name="action"    value="modifier"/>
                                <input type="hidden" name="produitId" value="${ligne.produit.id}"/>
                                <input type="hidden" name="quantite"
                                       id="qty-${ligne.produit.id}"
                                       value="${ligne.quantite}"
                                       class="cart-qty-input"
                                       data-price="${ligne.produit.price}"/>
                            </form>
                            <%-- Stepper visible --%>
                            <div class="qty-stepper">
                                <button type="button" class="qty-btn"
                                        onclick="changeQty(${ligne.produit.id}, -1, ${ligne.produit.price})">−</button>
                                <span class="qty-display"
                                      id="qty-display-${ligne.produit.id}">${ligne.quantite}</span>
                                <button type="button" class="qty-btn"
                                        onclick="changeQty(${ligne.produit.id}, 1, ${ligne.produit.price})">+</button>
                            </div>
                        </div>

                        <%-- Sous-total ligne --%>
                        <div class="cart-item__subtotal">
                            <span id="subtotal-${ligne.produit.id}">
                                <fmt:formatNumber value="${ligne.sousTotal}" type="currency" currencySymbol="€"/>
                            </span>
                        </div>

                        <%-- Supprimer --%>
                        <div class="cart-item__remove">
                            <form method="post" action="${pageContext.request.contextPath}/panier">
                                <input type="hidden" name="action"    value="retirer"/>
                                <input type="hidden" name="produitId" value="${ligne.produit.id}"/>
                                <button type="submit" class="btn-remove" title="Retirer cet article">✕</button>
                            </form>
                        </div>

                    </div>
                </c:forEach>
            </div>

            <%-- ── Colonne récapitulatif ── --%>
            <div class="cart-summary card animate-slide">
                <h2 class="section-title" style="font-size:1.05rem; margin-bottom:1rem;">
                    Récapitulatif
                </h2>
                <div class="cart-summary__line">
                    <span class="text-muted">Articles (${panier.nombreArticles})</span>
                    <span id="cart-subtotal">
                        <fmt:formatNumber value="${panier.total}" type="currency" currencySymbol="€"/>
                    </span>
                </div>
                <div class="cart-summary__line">
                    <span class="text-muted">Livraison</span>
                    <span class="text-green fw-bold">Gratuite</span>
                </div>
                <hr style="border-color:var(--border); margin:1rem 0;"/>
                <div class="cart-summary__line fw-bold" style="font-size:1.1rem;">
                    <span>Total</span>
                    <span id="cart-total">
                        <fmt:formatNumber value="${panier.total}" type="currency" currencySymbol="€"/>
                    </span>
                </div>

                <c:choose>
                    <c:when test="${not empty utilisateurConnecte}">
                        <a class="btn btn-full btn-lg mt-2"
                           href="${pageContext.request.contextPath}/checkout">
                            ✅ Passer la commande
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a class="btn btn-full btn-lg mt-2"
                           href="${pageContext.request.contextPath}/connexion?redirect=/checkout">
                            🔑 Se connecter pour commander
                        </a>
                    </c:otherwise>
                </c:choose>

                <a class="btn btn-outline btn-full mt-1"
                   href="${pageContext.request.contextPath}/catalogue">
                    ← Continuer mes achats
                </a>

                <form method="post" action="${pageContext.request.contextPath}/panier" class="mt-1">
                    <input type="hidden" name="action" value="vider"/>
                    <button type="submit" class="btn btn-danger btn-full"
                            onclick="return confirm('Vider tout le panier ?')">
                        🗑 Vider le panier
                    </button>
                </form>
            </div>

        </div><%-- /.cart-layout --%>
    </c:otherwise>
</c:choose>

<script>
// ── Mise à jour en temps réel des quantités ─────────────────────
function formatEuro(amount) {
    return new Intl.NumberFormat('fr-FR', {
        style: 'currency', currency: 'EUR'
    }).format(amount);
}

function recalcTotal() {
    let total = 0;
    document.querySelectorAll('.cart-qty-input').forEach(input => {
        const qty   = parseInt(input.value) || 0;
        const price = parseFloat(input.dataset.price) || 0;
        total += qty * price;
    });
    const sub = document.getElementById('cart-subtotal');
    const tot = document.getElementById('cart-total');
    if (sub) sub.textContent = formatEuro(total);
    if (tot) tot.textContent = formatEuro(total);
}

function changeQty(produitId, delta, unitPrice) {
    const input   = document.getElementById('qty-' + produitId);
    const display = document.getElementById('qty-display-' + produitId);
    const sub     = document.getElementById('subtotal-' + produitId);

    let qty = (parseInt(input.value) || 0) + delta;
    if (qty < 0) qty = 0;

    input.value = qty;
    if (display) display.textContent = qty;
    if (sub) sub.textContent = formatEuro(qty * unitPrice);

    recalcTotal();

    // Soumission automatique après 600 ms (debounce)
    clearTimeout(window['_debounce_' + produitId]);
    window['_debounce_' + produitId] = setTimeout(() => {
        document.getElementById('form-' + produitId).submit();
    }, 600);
}
</script>

<jsp:include page="footer.jsp"/>

