<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="header.jsp"/>

<div class="section-title">&#10003; Validation de la commande</div>

<c:if test="${not empty erreur}">
    <div class="alert alert-danger animate-slide"><c:out value="${erreur}"/></div>
</c:if>

<%-- Panier vide --%>
<c:if test="${empty panier || panier.estVide()}">
    <div class="card text-center animate-slide" style="padding:3rem 2rem; max-width:520px; margin:2rem auto;">
        <div style="font-size:3rem; margin-bottom:1rem;">&#128722;</div>
        <h3 style="color:var(--green-400); margin-bottom:0.5rem;">Votre panier est vide</h3>
        <p class="text-muted mb-2">Ajoutez des produits avant de passer une commande.</p>
        <a href="${pageContext.request.contextPath}/catalogue" class="btn">D&#233;couvrir le catalogue</a>
    </div>
</c:if>

<c:if test="${not empty panier && not panier.estVide()}">

<%-- Calcul taxes --%>
<c:set var="sousTotalNum" value="${panier.total}"/>
<c:set var="tps" value="${sousTotalNum * 0.05}"/>
<c:set var="tvq" value="${sousTotalNum * 0.09975}"/>
<c:set var="totalAvantCoupon" value="${sousTotalNum + tps + tvq}"/>

<div class="checkout-page-grid">

    <%-- ══════════ COLONNE GAUCHE ══════════ --%>
    <div class="checkout-left">

        <%-- 1. R&#233;capitulatif panier --%>
        <div class="card animate-slide mb-2">
            <h2 class="checkout-section-title">&#128203; R&#233;capitulatif de votre panier</h2>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr><th>Produit</th><th>Qt&#233;</th><th>Prix unit.</th><th>Sous-total</th></tr>
                    </thead>
                    <tbody>
                        <c:forEach var="ligne" items="${panier.lignes}">
                            <tr>
                                <td><strong><c:out value="${ligne.produit.name}"/></strong></td>
                                <td>${ligne.quantite}</td>
                                <td><fmt:formatNumber value="${ligne.produit.price}" type="currency" currencySymbol="$"/></td>
                                <td><fmt:formatNumber value="${ligne.sousTotal}" type="currency" currencySymbol="$"/></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            <%-- Taxes --%>
            <div class="checkout-tax-box">
                <div class="checkout-tax-row">
                    <span>Sous-total</span>
                    <span><fmt:formatNumber value="${sousTotalNum}" type="currency" currencySymbol="$"/></span>
                </div>
                <div class="checkout-tax-row">
                    <span>TPS (5&#160;%)</span>
                    <span><fmt:formatNumber value="${tps}" type="currency" currencySymbol="$"/></span>
                </div>
                <div class="checkout-tax-row">
                    <span>TVQ (9,975&#160;%)</span>
                    <span><fmt:formatNumber value="${tvq}" type="currency" currencySymbol="$"/></span>
                </div>
                <c:if test="${not empty couponCode}">
                    <div class="checkout-tax-row" style="color:var(--green-400);">
                        <span>&#127881; Coupon <strong><c:out value="${couponCode}"/></strong></span>
                        <span>&#8722; <fmt:formatNumber value="${couponReduction}" type="currency" currencySymbol="$"/></span>
                    </div>
                </c:if>
                <%-- Ligne coupon ajoutée dynamiquement par JS si session vide --%>
                <div id="coupon-tax-row" class="checkout-tax-row" style="color:var(--green-400);display:none;">
                    <span>&#127881; Coupon <strong id="coupon-tax-code"></strong></span>
                    <span>&#8722;&nbsp;<span id="coupon-tax-amount"></span></span>
                </div>
                <div class="checkout-tax-row checkout-tax-total" id="totalDisplay">
                    <span><strong>Total (TTC)</strong></span>
                    <span>
                        <strong class="text-green">
                            <fmt:formatNumber
                                value="${not empty couponReduction ? totalAvantCoupon - couponReduction : totalAvantCoupon}"
                                type="currency" currencySymbol="$"/>
                        </strong>
                    </span>
                </div>
            </div>
        </div>

        <%-- 2. Coupon de r&#233;duction --%>
        <div class="card animate-slide mb-2">
            <h2 class="checkout-section-title">&#127881; Coupon de r&#233;duction</h2>
            <div id="coupon-body">
            <c:choose>
                <c:when test="${not empty couponCode}">
                    <div class="coupon-applied">
                        <span>&#10003; Coupon <strong><c:out value="${couponCode}"/></strong> appliqu&#233; !
                            (-&#160;<fmt:formatNumber value="${couponReduction}" type="currency" currencySymbol="$"/>)
                        </span>
                        <button type="button" class="btn btn-sm btn-outline" onclick="retirerCoupon()">Retirer</button>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="flex gap-1" style="align-items:flex-end;">
                        <div class="form-group" style="flex:1; margin-bottom:0;">
                            <label class="form-label" for="couponInput">Entrez votre code coupon</label>
                            <input type="text" id="couponInput" class="form-control"
                                   placeholder="EX: PROMO10" style="text-transform:uppercase; letter-spacing:0.08em;"/>
                        </div>
                        <button type="button" class="btn" onclick="appliquerCoupon()" style="height:42px;">
                            Appliquer
                        </button>
                    </div>
                    <div id="couponMsg" style="margin-top:0.5rem; font-size:0.85rem;"></div>
                </c:otherwise>
            </c:choose>
            </div><%-- /coupon-body --%>
        </div>

        <%-- 3. Adresse de livraison --%>
        <div class="card animate-slide mb-2">
            <h2 class="checkout-section-title">&#128230; Adresse de livraison</h2>
            <form id="checkoutForm" method="post" action="${pageContext.request.contextPath}/checkout"
                  onsubmit="return validerFormulaire()">
                <div class="form-group">
                    <label class="form-label" for="adresseLivraison">
                        Adresse compl&#232;te <span class="required">*</span>
                    </label>
                    <textarea id="adresseLivraison" name="adresseLivraison"
                              class="form-control" rows="3" required
                              placeholder="123 rue Exemple, Ville, Province, Code postal"><c:out value='${utilisateurConnecte.adresseLivraison}'/></textarea>
                </div>
                <div class="alert alert-info" style="font-size:0.85rem; word-break:break-all; overflow-wrap:anywhere; margin-bottom:0;">
                    &#128231; Confirmation &#224; : <strong><c:out value="${utilisateurConnecte.email}"/></strong>
                </div>
            </form>
        </div>
    </div>

    <%-- ══════════ COLONNE DROITE ══════════ --%>
    <div class="checkout-right">

        <%-- 4. Informations carte de cr&#233;dit --%>
        <div class="card animate-slide mb-2">
            <h2 class="checkout-section-title">&#128179; Paiement par carte</h2>
            <div style="display:flex; gap:0.4rem; margin-bottom:1rem;">
                <span class="payment-brand">VISA</span>
                <span class="payment-brand">MC</span>
                <span class="payment-brand">AMEX</span>
            </div>

            <div class="form-group">
                <label class="form-label" for="cardName">Nom sur la carte <span class="required">*</span></label>
                <input type="text" id="cardName" name="cardName" class="form-control"
                       placeholder="Jean Tremblay" autocomplete="off" form="checkoutForm" required/>
            </div>
            <div class="form-group">
                <label class="form-label" for="cardNumber">Num&#233;ro de carte <span class="required">*</span></label>
                <input type="text" id="cardNumber" name="cardNumber" class="form-control"
                       placeholder="1234 5678 9012 3456" maxlength="19"
                       autocomplete="off" form="checkoutForm" required
                       oninput="formatCard(this)"/>
            </div>
            <div class="flex gap-1">
                <div class="form-group" style="flex:1;">
                    <label class="form-label" for="cardExpiry">Expiration <span class="required">*</span></label>
                    <input type="text" id="cardExpiry" name="cardExpiry" class="form-control"
                           placeholder="MM/AA" maxlength="5"
                           autocomplete="off" form="checkoutForm" required
                           oninput="formatExpiry(this)"/>
                </div>
                <div class="form-group" style="flex:1;">
                    <label class="form-label" for="cardCvv">CVV <span class="required">*</span></label>
                    <input type="text" id="cardCvv" name="cardCvv" class="form-control"
                           placeholder="123" maxlength="4"
                           autocomplete="off" form="checkoutForm" required
                           oninput="this.value=this.value.replace(/\D/g,'')"/>
                </div>
            </div>
            <div class="payment-secure-note">
                &#128274; Informations s&#233;curis&#233;es — aucun paiement r&#233;el n'est trait&#233;.
            </div>
        </div>

        <%-- 5. Bouton confirmer (en dernier, bien visible) --%>
        <div class="card animate-slide checkout-confirm-box">
            <div class="checkout-confirm-total" id="confirmTotalLabel">
                Total &#224; payer :
                <strong class="text-green" id="confirmTotalAmount">
                    <fmt:formatNumber
                        value="${not empty couponReduction ? totalAvantCoupon - couponReduction : totalAvantCoupon}"
                        type="currency" currencySymbol="$"/>
                </strong>
            </div>
            <div class="flex gap-1 flex-wrap" style="margin-top:1rem;">
                <a class="btn btn-outline" href="${pageContext.request.contextPath}/panier">
                    &#8592; Modifier le panier
                </a>
                <button type="submit" form="checkoutForm" class="btn btn-lg" style="flex:1; min-width:200px;">
                    &#10003; Confirmer la commande
                </button>
            </div>
        </div>

    </div>
</div><%-- /.checkout-page-grid --%>

</c:if>

<style>
.checkout-page-grid {
    display: grid;
    grid-template-columns: 1fr 360px;
    gap: 1.5rem;
    align-items: start;
    margin-bottom: 2rem;
}
.checkout-left, .checkout-right { display: flex; flex-direction: column; gap: 0; }
.mb-2 { margin-bottom: 1.25rem !important; }
.checkout-section-title {
    font-size: 1rem;
    font-weight: 600;
    margin-bottom: 1rem;
    padding-bottom: 0.5rem;
    border-bottom: 1px solid var(--border);
}
.checkout-tax-box {
    margin-top: 1.25rem;
    border-top: 1px solid var(--border);
    padding-top: 0.75rem;
}
.checkout-tax-row {
    display: flex;
    justify-content: space-between;
    padding: 0.3rem 0;
    font-size: 0.9rem;
    color: var(--text-muted);
}
.checkout-tax-total {
    border-top: 1px solid var(--border);
    margin-top: 0.4rem;
    padding-top: 0.5rem;
    font-size: 1.05rem;
    color: var(--text);
}
.coupon-applied {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.75rem 1rem;
    background: rgba(34,197,94,0.08);
    border: 1px solid var(--green-400);
    border-radius: 8px;
    color: var(--green-400);
    font-size: 0.9rem;
}
.payment-brand {
    display: inline-block;
    border: 1px solid var(--border);
    border-radius: 4px;
    padding: 0.2rem 0.5rem;
    font-size: 0.78rem;
    font-weight: 700;
    letter-spacing: 0.05em;
    color: var(--text-muted);
}
.payment-secure-note {
    margin-top: 0.75rem;
    font-size: 0.78rem;
    color: var(--text-muted);
    line-height: 1.5;
}
.checkout-confirm-box {
    position: sticky;
    top: 1rem;
    background: var(--surface);
    border: 2px solid var(--green-400);
}
.checkout-confirm-total {
    font-size: 1.1rem;
    text-align: center;
    padding: 0.5rem 0;
}
@media (max-width: 900px) {
    .checkout-page-grid { grid-template-columns: 1fr; }
    .checkout-confirm-box { position: static; }
}
</style>

<script>
var sousTotal = ${sousTotalNum};
var tps = ${tps};
var tvq = ${tvq};
var couponReduction = ${not empty couponReduction ? couponReduction : 0};
var totalBrut = sousTotal + tps + tvq;

function updateTotalDisplay(reduction) {
    var total = Math.max(0, totalBrut - reduction);
    var formatted = total.toLocaleString('fr-CA', {style:'currency', currency:'CAD'});
    var el = document.getElementById('confirmTotalAmount');
    if (el) el.textContent = formatted;
}

function appliquerCoupon() {
    var code = document.getElementById('couponInput').value.trim().toUpperCase();
    if (!code) { showCouponMsg('Veuillez entrer un code.', 'red'); return; }
    showCouponMsg('V\u00e9rification...', 'muted');

    var params = new URLSearchParams();
    params.append('code', code);
    fetch('${pageContext.request.contextPath}/coupon/valider', { method:'POST', body: params })
        .then(r => r.json())
        .then(data => {
            if (data.ok) {
                // 1. Remplacer la zone coupon par la banni\u00e8re \u00ab appliqu\u00e9 \u00bb
                var body = document.getElementById('coupon-body');
                if (body) {
                    body.innerHTML = '<div class="coupon-applied">' +
                        '<span>&#10003; Coupon <strong>' + code + '</strong> appliqu\u00e9\u00a0!' +
                        ' (\u2212\u00a0' + data.reduction.toLocaleString('fr-CA', {minimumFractionDigits:2, maximumFractionDigits:2}) + '\u00a0$' +
                        (data.libelle ? ' \u2014 ' + data.libelle : '') + ')' +
                        '</span>' +
                        '<button type="button" class="btn btn-sm btn-outline" onclick="retirerCoupon()">Retirer</button>' +
                        '</div>';
                }
                // 2. Afficher la ligne coupon dans le r\u00e9capitulatif des taxes
                var taxRow = document.getElementById('coupon-tax-row');
                if (taxRow) {
                    taxRow.style.display = 'flex';
                    document.getElementById('coupon-tax-code').textContent = code;
                    document.getElementById('coupon-tax-amount').textContent =
                        data.reduction.toLocaleString('fr-CA', {minimumFractionDigits:2, maximumFractionDigits:2}) + '\u00a0$';
                }
                // 3. Mettre \u00e0 jour le total
                updateTotalDisplay(data.reduction);
                couponReduction = data.reduction;
            } else {
                showCouponMsg(data.message, 'red');
            }
        })
        .catch(() => showCouponMsg('Erreur de connexion.', 'red'));
}

function showCouponMsg(text, color) {
    var el = document.getElementById('couponMsg');
    if (!el) return;
    el.textContent = text;
    el.style.color = color === 'green' ? 'var(--green-400)'
        : color === 'muted' ? 'var(--text-muted)'
        : 'var(--red-400, #f87171)';
}

function retirerCoupon() {
    fetch('${pageContext.request.contextPath}/coupon/valider', {
        method:'POST',
        body: new URLSearchParams({code: '__RESET__'})
    }).finally(() => location.reload());
}

function formatCard(input) {
    var v = input.value.replace(/\D/g, '').substring(0, 16);
    input.value = v.replace(/(.{4})/g, '$1 ').trim();
}
function formatExpiry(input) {
    var v = input.value.replace(/\D/g, '').substring(0, 4);
    if (v.length >= 3) v = v.substring(0,2) + '/' + v.substring(2);
    input.value = v;
}
function validerFormulaire() {
    var adresse = document.getElementById('adresseLivraison').value.trim();
    if (!adresse) { alert('L\'adresse de livraison est obligatoire.'); return false; }
    var expiry = document.getElementById('cardExpiry').value;
    if (!/^\d{2}\/\d{2}$/.test(expiry)) { alert('Format d\'expiration invalide (MM/AA).'); return false; }
    return true;
}

// Init : si coupon d\u00e9j\u00e0 appliqu\u00e9 depuis session
if (couponReduction > 0) { updateTotalDisplay(couponReduction); }
</script>

<jsp:include page="footer.jsp"/>
