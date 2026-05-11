<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="header.jsp"/>

<%-- ── En-tête ── --%>
<div class="dashboard-header animate-fade">
    <div>
        <h1>📜 Mes commandes</h1>
        <p class="text-muted">Historique de tous vos achats sur E-Boutique</p>
    </div>
    <a href="${pageContext.request.contextPath}/catalogue" class="btn btn-outline">
        🛍 Continuer mes achats
    </a>
</div>

<%-- ── Flash confirmation ── --%>
<c:if test="${not empty commandeConfirmee}">
    <div class="alert alert-success animate-slide">
        ✅ Commande <strong>#<c:out value="${commandeConfirmee}"/></strong> confirmée !
        Un email de confirmation vous a été envoyé.
    </div>
    <script>localStorage.removeItem('panier_data');</script>
</c:if>
<c:if test="${not empty flashInfo}">
    <div class="alert alert-success animate-slide">
        <c:out value="${flashInfo}"/>
    </div>
</c:if>

<c:choose>
    <c:when test="${empty commandes}">
        <div class="cart-empty animate-fade">
            <div class="cart-empty__icon">📭</div>
            <h2>Aucune commande pour le moment</h2>
            <p class="text-muted">Vous n'avez encore passé aucune commande.</p>
            <a href="${pageContext.request.contextPath}/catalogue" class="btn" style="margin-top:1rem;">
                🛍 Découvrir le catalogue
            </a>
        </div>
    </c:when>
    <c:otherwise>
        <c:forEach var="commande" items="${commandes}">
            <div class="order-card animate-fade">

                <%-- ── En-tête commande ── --%>
                <div class="order-card__header">
                    <div class="order-card__meta">
                        <span class="order-card__id">Commande #${commande.id}</span>
                        <span class="text-muted text-sm">
                            📅 ${commande.orderDateFormatted}
                        </span>
                    </div>
                    <div class="order-card__right">
                        <c:choose>
                            <c:when test="${commande.status == 'PENDING'}">
                                <span class="badge badge-yellow">⏳ En attente</span>
                            </c:when>
                            <c:when test="${commande.status == 'CONFIRMED'}">
                                <span class="badge badge-green">✅ Confirmée</span>
                            </c:when>
                            <c:when test="${commande.status == 'PREPARING'}">
                                <span class="badge badge-blue">📦 En préparation</span>
                            </c:when>
                            <c:when test="${commande.status == 'SHIPPED'}">
                                <span class="badge badge-blue">🚚 Expédiée</span>
                            </c:when>
                            <c:when test="${commande.status == 'DELIVERED'}">
                                <span class="badge badge-blue">&#128666; Livrée</span>
                            </c:when>
                            <c:when test="${commande.status == 'RECEIVED'}">
                                <span class="badge badge-green">&#9989; Réceptionnée</span>
                            </c:when>
                            <c:when test="${commande.status == 'CANCELLED'}">
                                <span class="badge badge-red">&#10060; Annulée</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge badge-yellow"><c:out value="${commande.status}"/></span>
                            </c:otherwise>
                        </c:choose>
                        <span class="order-card__total">
                            <fmt:formatNumber value="${commande.total}" type="currency" currencySymbol="€"/>
                        </span>
                    </div>
                </div>

                <%-- Barre de suivi (6 étapes maintenant : pend, conf, prep, ship, deliv, received) => 0..5 --%>
                <c:if test="${commande.status != 'CANCELLED'}">
                <div class="order-tracker">
                    <c:set var="activeIdx" value="0"/>
                    <c:if test="${commande.status == 'CONFIRMED'}"><c:set var="activeIdx" value="1"/></c:if>
                    <c:if test="${commande.status == 'PREPARING'}"><c:set var="activeIdx" value="2"/></c:if>
                    <c:if test="${commande.status == 'SHIPPED'}">  <c:set var="activeIdx" value="3"/></c:if>
                    <c:if test="${commande.status == 'DELIVERED'}"><c:set var="activeIdx" value="4"/></c:if>
                    <c:if test="${commande.status == 'RECEIVED'}"> <c:set var="activeIdx" value="5"/></c:if>

                    <c:forEach var="i" begin="0" end="5">
                        <c:choose>
                            <c:when test="${i == 0}"><c:set var="stepIcon" value="📥"/><c:set var="stepLabel" value="Reçue"/></c:when>
                            <c:when test="${i == 1}"><c:set var="stepIcon" value="✅"/><c:set var="stepLabel" value="Confirmée"/></c:when>
                            <c:when test="${i == 2}"><c:set var="stepIcon" value="📦"/><c:set var="stepLabel" value="En préparation"/></c:when>
                            <c:when test="${i == 3}"><c:set var="stepIcon" value="🚚"/><c:set var="stepLabel" value="Expédiée"/></c:when>
                            <c:when test="${i == 4}"><c:set var="stepIcon" value="📦"/><c:set var="stepLabel" value="Livrée"/></c:when>
                            <c:otherwise><c:set var="stepIcon" value="🎁"/><c:set var="stepLabel" value="Réceptionnée"/></c:otherwise>
                        </c:choose>
                        <div class="tracker-step ${i <= activeIdx ? 'tracker-done' : ''} ${i == activeIdx ? 'tracker-active' : ''}">
                            <div class="tracker-dot">${stepIcon}</div>
                            <div class="tracker-label">${stepLabel}</div>
                        </div>
                        <c:if test="${i < 5}">
                            <div class="tracker-line ${i < activeIdx ? 'tracker-line-done' : ''}"></div>
                        </c:if>
                    </c:forEach>
                </div>
                </c:if>

                <%-- ── Bouton Réceptionner (visible uniquement si SHIPPED ou DELIVERED) ── --%>
                <c:if test="${commande.status == 'SHIPPED' || commande.status == 'DELIVERED'}">
                    <div class="order-reception-bar">
                        <span class="text-muted text-sm">📬 Votre colis est en route — confirmez la réception quand vous l'avez reçu.</span>
                        <form method="post" action="${pageContext.request.contextPath}/historique"
                              id="form-reception-${commande.id}">
                            <input type="hidden" name="action"  value="receptionner"/>
                            <input type="hidden" name="orderId" value="${commande.id}"/>
                            <button type="button" class="btn btn-reception"
                                    onclick="showReceptionModal(${commande.id})">
                                &#127873; J'ai bien r&#233;ceptionn&#233; ma commande
                            </button>
                        </form>
                    </div>
                </c:if>

                <c:if test="${commande.status == 'CANCELLED'}">
                    <div style="padding:0.75rem 1.5rem;">
                        <span class="badge badge-red" style="font-size:0.9rem;">❌ Commande annulée</span>
                    </div>
                </c:if>

                <%-- ── Infos livraison + vendeur ── --%>
                <div class="order-card__info-row">
                    <div class="order-card__info-item">
                        <span class="order-card__info-label">🏪 Vendeur</span>
                        <span class="order-card__info-value">E-Boutique</span>
                    </div>
                    <div class="order-card__info-item">
                        <span class="order-card__info-label">📍 Livraison</span>
                        <span class="order-card__info-value">
                            <c:out value="${commande.shippingAddress}"/>
                        </span>
                    </div>
                </div>

                <%-- ── Articles ── --%>
                <c:if test="${not empty commande.items}">
                    <div class="order-card__items">
                        <c:forEach var="item" items="${commande.items}">
                            <div class="order-item">
                                <div class="order-item__img">
                                    <c:choose>
                                        <c:when test="${not empty item.product.imagePath}">
                                            <img src="${item.product.imagePath}"
                                                 alt="<c:out value='${item.product.name}'/>"/>
                                        </c:when>
                                        <c:otherwise>
                                            <span>📦</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="order-item__info">
                                    <a href="${pageContext.request.contextPath}/produit?id=${item.product.id}"
                                       class="order-item__name">
                                        <c:out value="${item.product.name}"/>
                                    </a>
                                    <c:if test="${not empty item.product.category}">
                                        <span class="text-muted text-sm">
                                            <c:out value="${item.product.category.name}"/>
                                        </span>
                                    </c:if>
                                </div>
                                <div class="order-item__qty text-muted text-sm">
                                    x${item.quantity}
                                </div>
                                <div class="order-item__price">
                                    <div class="fw-bold">
                                        <fmt:formatNumber value="${item.sousTotal}" type="currency" currencySymbol="€"/>
                                    </div>
                                    <div class="text-muted text-sm">
                                        <fmt:formatNumber value="${item.unitPrice}" type="currency" currencySymbol="€"/> / unité
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>

                <%-- ── Pied de commande ── --%>
                <div class="order-card__footer">
                    <span class="text-muted text-sm">
                        ${commande.items.size()} article(s)
                    </span>
                    <span class="order-card__total-line">
                        Total payé :
                        <strong class="text-green">
                            <fmt:formatNumber value="${commande.total}" type="currency" currencySymbol="€"/>
                        </strong>
                    </span>
                </div>
            </div>
        </c:forEach>
    </c:otherwise>
</c:choose>

<style>
/* ── Order tracker (suivi commande) ── */
.order-tracker {
    display: flex;
    align-items: center;
    padding: 1rem 1.5rem 0.5rem;
    gap: 0;
    overflow-x: auto;
    scrollbar-width: thin;
}
.tracker-step {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.35rem;
    min-width: 72px;
    opacity: 0.35;
    transition: opacity 0.3s;
}
.tracker-step.tracker-done  { opacity: 1; }
.tracker-step.tracker-active { opacity: 1; }
.tracker-dot {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    border: 2px solid var(--border);
    background: var(--bg-secondary);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.1rem;
    transition: border-color 0.3s, background 0.3s;
}
.tracker-done  .tracker-dot { border-color: var(--green-500); background: rgba(16,185,129,0.12); }
.tracker-active .tracker-dot {
    border-color: var(--green-400);
    background: rgba(52,211,153,0.2);
    box-shadow: 0 0 0 3px rgba(52,211,153,0.2);
    animation: pulse-dot 1.8s infinite;
}
@keyframes pulse-dot {
    0%,100% { box-shadow: 0 0 0 3px rgba(52,211,153,0.15); }
    50%      { box-shadow: 0 0 0 6px rgba(52,211,153,0.05); }
}
.tracker-label {
    font-size: 0.72rem;
    font-weight: 600;
    text-align: center;
    white-space: nowrap;
    color: var(--text-secondary);
}
.tracker-done  .tracker-label { color: var(--green-400); }
.tracker-active .tracker-label { color: var(--text-primary); font-weight: 700; }

.tracker-line {
    flex: 1;
    height: 2px;
    min-width: 20px;
    background: var(--border);
    margin-bottom: 1.5rem;
    transition: background 0.3s;
}
.tracker-line-done { background: var(--green-500); }

/* ── Barre de réception ── */
.order-reception-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
    flex-wrap: wrap;
    padding: 0.75rem 1.5rem;
    background: linear-gradient(90deg, rgba(16,185,129,0.06) 0%, rgba(16,185,129,0.01) 100%);
    border-top: 1px solid rgba(16,185,129,0.25);
    border-bottom: 1px solid rgba(16,185,129,0.15);
}
.btn-reception {
    background: var(--green-600);
    color: #fff;
    border: none;
    padding: 0.55rem 1.25rem;
    border-radius: var(--radius);
    font-weight: 700;
    cursor: pointer;
    font-size: 0.9rem;
    transition: background var(--transition), transform 0.1s;
    white-space: nowrap;
}
.btn-reception:hover  { background: var(--green-500); transform: translateY(-1px); }
.btn-reception:active { transform: translateY(0); }

/* ── Order card ── */
.order-card {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-lg);
    margin-bottom: 1.5rem;
    overflow: hidden;
}

.order-card__header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem 1.5rem;
    background: var(--bg-secondary);
    border-bottom: 1px solid var(--border);
    flex-wrap: wrap;
    gap: 0.75rem;
}
.order-card__meta {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
}
.order-card__id {
    font-size: 1rem;
    font-weight: 700;
    color: var(--green-400);
}
.order-card__right {
    display: flex;
    align-items: center;
    gap: 1rem;
}
.order-card__total {
    font-size: 1.2rem;
    font-weight: 800;
    color: var(--text-primary);
}

.order-card__info-row {
    display: flex;
    gap: 2rem;
    padding: 0.75rem 1.5rem;
    background: rgba(16,185,129,0.04);
    border-bottom: 1px solid var(--border);
    flex-wrap: wrap;
}
.order-card__info-item {
    display: flex;
    flex-direction: column;
    gap: 0.1rem;
}
.order-card__info-label {
    font-size: 0.78rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    color: var(--text-secondary);
}
.order-card__info-value {
    font-size: 0.9rem;
    color: var(--text-primary);
    font-weight: 500;
}

/* ── Articles ── */
.order-card__items {
    padding: 0.75rem 1.5rem;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
}
.order-item {
    display: grid;
    grid-template-columns: 60px 1fr auto auto;
    gap: 1rem;
    align-items: center;
    padding: 0.5rem 0;
    border-bottom: 1px solid var(--border);
}
.order-item:last-child { border-bottom: none; }

.order-item__img {
    width: 60px;
    height: 60px;
    border-radius: var(--radius-sm);
    overflow: hidden;
    border: 1px solid var(--border);
    display: flex;
    align-items: center;
    justify-content: center;
    background: var(--bg-secondary);
    font-size: 1.5rem;
}
.order-item__img img { width: 100%; height: 100%; object-fit: cover; }

.order-item__info {
    display: flex;
    flex-direction: column;
    gap: 0.15rem;
    min-width: 0;
}
.order-item__name {
    font-weight: 600;
    color: var(--text-primary);
    text-decoration: none;
    font-size: 0.95rem;
}
.order-item__name:hover { color: var(--green-400); }

.order-item__qty {
    white-space: nowrap;
    background: var(--bg-secondary);
    padding: 0.2rem 0.6rem;
    border-radius: 999px;
    border: 1px solid var(--border);
    font-weight: 600;
}
.order-item__price {
    text-align: right;
    white-space: nowrap;
}

/* ── Footer commande ── */
.order-card__footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.75rem 1.5rem;
    background: var(--bg-secondary);
    border-top: 1px solid var(--border);
}
.order-card__total-line { font-size: 0.95rem; }

@media (max-width: 600px) {
    .order-item { grid-template-columns: 50px 1fr; grid-template-rows: auto auto; }
    .order-item__qty  { grid-column: 2; }
    .order-item__price { grid-column: 2; }
}
</style>

<%-- ══ Modal confirmation réception ══ --%>
<div id="receptionModal" class="modal-overlay" style="display:none;" onclick="if(event.target===this)closeReceptionModal()">
    <div class="modal-box animate-fade">
        <div class="modal-icon">&#127873;</div>
        <h3 class="modal-title">Confirmer la réception</h3>
        <p id="receptionModalMsg" class="modal-msg"></p>
        <p class="text-muted text-sm" style="margin-bottom:1.5rem;">
            En confirmant, vous indiquez que votre colis est bien arrivé.
        </p>
        <div class="modal-actions">
            <button onclick="closeReceptionModal()" class="btn btn-outline">Non, pas encore</button>
            <button id="receptionModalConfirm" class="btn btn-reception" style="min-width:200px;">
                &#9989; Oui, j'ai bien reçu ma commande
            </button>
        </div>
    </div>
</div>

<style>
.modal-overlay {
    position: fixed; inset: 0;
    background: rgba(0,0,0,.55);
    display: flex; align-items: center; justify-content: center;
    z-index: 9999;
    backdrop-filter: blur(3px);
}
.modal-box {
    background: var(--bg-secondary);
    border: 1px solid var(--border);
    border-radius: calc(var(--radius) * 2);
    padding: 2rem 2.5rem;
    max-width: 460px;
    width: 90%;
    text-align: center;
    box-shadow: 0 20px 60px rgba(0,0,0,.4);
}
.modal-icon  { font-size: 3rem; margin-bottom: .75rem; }
.modal-title { font-size: 1.25rem; font-weight: 700; margin-bottom: .5rem; color: var(--text-primary); }
.modal-msg   { font-size: 1rem; font-weight: 600; margin-bottom: .5rem; color: var(--green-400); }
.modal-actions { display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap; }
</style>

<script>
var _pendingReceptionId = null;
function showReceptionModal(orderId) {
    document.getElementById('receptionModalMsg').textContent = 'Commande #' + orderId;
    _pendingReceptionId = orderId;
    document.getElementById('receptionModal').style.display = 'flex';
}
function closeReceptionModal() {
    document.getElementById('receptionModal').style.display = 'none';
    _pendingReceptionId = null;
}
document.getElementById('receptionModalConfirm').addEventListener('click', function(){
    if (_pendingReceptionId) document.getElementById('form-reception-' + _pendingReceptionId).submit();
});

/* ══ Polling temps réel — vérifie les statuts toutes les 12 secondes ══ */
<c:if test="${not empty commandes}">
var _statuts = {};
<c:forEach var="c" items="${commandes}">
_statuts[${c.id}] = '${c.status}';
</c:forEach>

var _pollingUrl = '${pageContext.request.contextPath}/historique?format=json';
var _pollingTimer = null;

function demarrerPolling() {
    _pollingTimer = setInterval(function () {
        fetch(_pollingUrl, { credentials: 'same-origin' })
            .then(function(r) {
                if (!r.ok) throw new Error('HTTP ' + r.status);
                return r.json();
            })
            .then(function(data) {
                var changed = false;
                data.forEach(function(o) {
                    if (_statuts[o.id] !== undefined && _statuts[o.id] !== o.status) {
                        changed = true;
                    }
                });
                if (changed) {
                    afficherNotifMaj();
                    setTimeout(function() { location.reload(); }, 1800);
                }
            })
            .catch(function() { /* silencieux */ });
    }, 12000);
}

function afficherNotifMaj() {
    clearInterval(_pollingTimer); // arrêter le polling pendant le rechargement
    var div = document.createElement('div');
    div.style.cssText = [
        'position:fixed', 'top:72px', 'right:1.2rem',
        'z-index:10000', 'max-width:320px',
        'background:var(--green-600)', 'color:#fff',
        'border-radius:var(--radius)', 'padding:0.75rem 1.2rem',
        'box-shadow:0 4px 20px rgba(0,0,0,.3)',
        'font-weight:600', 'font-size:0.9rem',
        'animation:pulse-dot 1.8s infinite'
    ].join(';');
    div.textContent = '\uD83D\uDD04 Mise à jour des commandes\u2026';
    document.body.appendChild(div);
}

// Démarrer le polling si la page est visible
if (typeof document.hidden !== 'undefined') {
    document.addEventListener('visibilitychange', function() {
        if (document.hidden) {
            clearInterval(_pollingTimer);
        } else {
            demarrerPolling();
        }
    });
}
demarrerPolling();
</c:if>
</script>

<jsp:include page="footer.jsp"/>

