<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="header.jsp"/>

<div class="dashboard-header animate-fade">
    <div>
        <h1>📋 Gestion des commandes</h1>
        <p class="text-muted">Avancez chaque commande dans son cycle de vie</p>
    </div>
</div>

<%-- Flash --%>
<c:if test="${not empty flashMessage}">
    <div class="alert alert-success animate-slide">✅ <c:out value="${flashMessage}"/></div>
</c:if>

<%-- Légende progression --%>
<div class="tracking-legend animate-fade">
    <span class="tl-step tl-pending">⏳ En attente</span>
    <span class="tl-arrow">→</span>
    <span class="tl-step tl-confirmed">✅ Confirmée</span>
    <span class="tl-arrow">→</span>
    <span class="tl-step tl-preparing">📦 En préparation</span>
    <span class="tl-arrow">→</span>
    <span class="tl-step tl-shipped">🚚 Expédiée</span>
    <span class="tl-arrow">→</span>
    <span class="tl-step tl-delivered">📦 Livrée</span>
    <span class="tl-arrow">→</span>
    <span class="tl-step tl-received">🎉 Réceptionnée</span>
</div>

<c:choose>
    <c:when test="${not empty commandes}">
        <div class="table-wrapper animate-fade">
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Client</th>
                        <th>Date</th>
                        <th>Total</th>
                        <th>Statut</th>
                        <th>Articles</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="commande" items="${commandes}">
                        <tr>
                            <td class="fw-bold text-green">#${commande.id}</td>
                            <td>
                                <div class="fw-bold"><c:out value="${commande.user.firstName}"/> <c:out value="${commande.user.lastName}"/></div>
                                <div class="text-muted text-sm"><c:out value="${commande.user.email}"/></div>
                            </td>
                            <td class="text-muted text-sm">${commande.orderDateFormatted}</td>
                            <td class="fw-bold text-green">
                                <fmt:formatNumber value="${commande.total}" type="currency" currencySymbol="€"/>
                            </td>
                            <td>
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
                                        <span class="badge badge-blue">&#128666; Livr&#233;e</span>
                                    </c:when>
                                    <c:when test="${commande.status == 'RECEIVED'}">
                                        <span class="badge badge-green">&#9989; R&#233;ceptionn&#233;e (client)</span>
                                    </c:when>
                                    <c:when test="${commande.status == 'CANCELLED'}">
                                        <span class="badge badge-red">❌ Annulée</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge"><c:out value="${commande.status}"/></span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-muted text-sm">${commande.items.size()} article(s)</td>
                            <td>
                                <%-- Avancer : uniquement de PENDING → ... → DELIVERED --%>
                                <c:if test="${commande.status != 'DELIVERED' && commande.status != 'RECEIVED' && commande.status != 'CANCELLED'}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin/commandes"
                                          style="display:inline;">
                                        <input type="hidden" name="action"  value="avancer"/>
                                        <input type="hidden" name="orderId" value="${commande.id}"/>
                                        <button type="submit" class="btn btn-sm"
                                                title="Passer à l'étape suivante">▶ Avancer</button>
                                    </form>
                                </c:if>
                                <%-- Annuler : disponible uniquement avant DELIVERED --%>
                                <c:if test="${commande.status != 'CANCELLED' && commande.status != 'RECEIVED' && commande.status != 'DELIVERED'}">
                                    <form id="form-annuler-${commande.id}" method="post"
                                          action="${pageContext.request.contextPath}/admin/commandes"
                                          style="display:inline;">
                                        <input type="hidden" name="action"  value="annuler"/>
                                        <input type="hidden" name="orderId" value="${commande.id}"/>
                                        <button type="button" class="btn btn-sm btn-danger"
                                                onclick="showConfirmModal('Annuler la commande #${commande.id} ?','form-annuler-${commande.id}')">
                                            &#10005; Annuler
                                        </button>
                                    </form>
                                </c:if>
                                <%-- En attente de réception client --%>
                                <c:if test="${commande.status == 'DELIVERED' || commande.status == 'SHIPPED'}">
                                    <span class="text-muted text-sm" style="display:block;margin-top:0.25rem;">⏳ Client doit réceptionner</span>
                                </c:if>
                                <c:if test="${commande.status == 'RECEIVED' || commande.status == 'CANCELLED'}">
                                    <span class="text-muted text-sm">—</span>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        <p class="text-muted text-sm mt-2">
            Total : <strong>${commandes.size()}</strong> commande(s)
        </p>
    </c:when>
    <c:otherwise>
        <div class="alert alert-info animate-fade">Aucune commande enregistrée pour le moment.</div>
    </c:otherwise>
</c:choose>

<style>
.tracking-legend {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    flex-wrap: wrap;
    margin-bottom: 1.5rem;
    padding: 0.75rem 1rem;
    background: var(--bg-secondary);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    font-size: 0.85rem;
}
.tl-step {
    padding: 0.25rem 0.75rem;
    border-radius: 999px;
    font-weight: 600;
    border: 1px solid transparent;
}
.tl-arrow { color: var(--text-secondary); font-weight: 700; }
.tl-pending   { background: #78350f22; color: #fbbf24; border-color: #78350f55; }
.tl-confirmed { background: #05503022; color: var(--green-400); border-color: #05503055; }
.tl-preparing { background: #1e3a5f22; color: #60a5fa; border-color: #1e3a5f55; }
.tl-shipped   { background: #1e40af22; color: #93c5fd; border-color: #1e40af55; }
.tl-delivered { background: #3b82f622; color: #60a5fa; border-color: #3b82f655; }
.tl-received  { background: #14532d22; color: #4ade80; border-color: #14532d55; }
.btn-danger   { background: var(--red-500); color: #fff; border-color: var(--red-500); }
.btn-danger:hover { background: var(--red-400); }
</style>

<%-- ══ Modal confirmation ══ --%>
<div id="confirmModal" class="modal-overlay" style="display:none;" onclick="if(event.target===this)closeModal()">
    <div class="modal-box animate-fade">
        <div class="modal-icon">&#9888;&#65039;</div>
        <p id="modalMessage" class="modal-msg"></p>
        <div class="modal-actions">
            <button onclick="closeModal()" class="btn btn-outline">Non, revenir</button>
            <button id="modalConfirm" class="btn btn-danger">Oui, confirmer</button>
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
    max-width: 420px;
    width: 90%;
    text-align: center;
    box-shadow: 0 20px 60px rgba(0,0,0,.4);
}
.modal-icon { font-size: 2.5rem; margin-bottom: .75rem; }
.modal-msg  { font-size: 1.1rem; font-weight: 600; margin-bottom: 1.5rem; color: var(--text-primary); }
.modal-actions { display: flex; gap: 1rem; justify-content: center; }
</style>

<script>
var _pendingForm = null;
function showConfirmModal(msg, formId) {
    document.getElementById('modalMessage').textContent = msg;
    _pendingForm = formId;
    document.getElementById('confirmModal').style.display = 'flex';
}
function closeModal() {
    document.getElementById('confirmModal').style.display = 'none';
    _pendingForm = null;
}
document.getElementById('modalConfirm').addEventListener('click', function(){
    if (_pendingForm) document.getElementById(_pendingForm).submit();
});
</script>

<jsp:include page="footer.jsp"/>

