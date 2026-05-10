<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="header.jsp"/>

<div class="section-title">&#127915; Gestion des coupons</div>

<c:if test="${not empty param.succes}">
    <div class="alert alert-success animate-slide">&#10003; Coupon créé avec succès !</div>
</c:if>
<c:if test="${not empty param.erreur}">
    <div class="alert alert-danger animate-slide"><c:out value="${param.erreur}"/></div>
</c:if>

<div style="display:grid; grid-template-columns:1fr 420px; gap:2rem; align-items:start;">

    <%-- Liste des coupons --%>
    <div class="card animate-slide">
        <h2 class="section-title" style="font-size:1.05rem; margin-bottom:1rem;">&#128203; Liste des coupons</h2>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Code</th>
                        <th>Type</th>
                        <th>Réduction</th>
                        <th>Statut</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty coupons}">
                            <tr><td colspan="5" class="text-center text-muted">Aucun coupon créé.</td></tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="c" items="${coupons}">
                                <tr>
                                    <td><code class="text-green" style="font-size:1rem;"><c:out value="${c.code}"/></code></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${c.type == 'POURCENTAGE'}">&#128200; Pourcentage</c:when>
                                            <c:otherwise>&#128176; Montant fixe</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <strong>
                                            <c:choose>
                                                <c:when test="${c.type == 'POURCENTAGE'}">
                                                    <fmt:formatNumber value="${c.reduction}" maxFractionDigits="2"/> %
                                                </c:when>
                                                <c:otherwise>
                                                    <fmt:formatNumber value="${c.reduction}" type="currency" currencySymbol="$"/>
                                                </c:otherwise>
                                            </c:choose>
                                        </strong>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${c.actif}">
                                                <span class="badge badge-green">&#10003; Actif</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-red">&#10060; Inactif</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <form method="post" action="${pageContext.request.contextPath}/admin/coupons" style="display:inline;">
                                            <input type="hidden" name="action" value="toggle"/>
                                            <input type="hidden" name="id" value="${c.id}"/>
                                            <button type="submit" class="btn btn-sm ${c.actif ? 'btn-outline' : 'btn'}">
                                                ${c.actif ? 'Désactiver' : 'Activer'}
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>

    <%-- Formulaire de création --%>
    <div class="card animate-slide">
        <h2 class="section-title" style="font-size:1.05rem; margin-bottom:1rem;">&#10133; Créer un coupon</h2>
        <form method="post" action="${pageContext.request.contextPath}/admin/coupons">

            <div class="form-group">
                <label class="form-label" for="code">Code <span class="required">*</span></label>
                <div style="display:flex; gap:0.5rem;">
                    <input type="text" id="code" name="code"
                           class="form-control" placeholder="EX: PROMO10"
                           value="<c:out value='${param.genere}'/>"
                           required style="text-transform:uppercase; letter-spacing:0.08em; flex:1;"/>
                    <button type="button" onclick="genererCodeClient()"
                            class="btn btn-outline btn-sm" style="white-space:nowrap;">
                        &#9881; G&#233;n&#233;rer
                    </button>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="type">Type de réduction <span class="required">*</span></label>
                <select id="type" name="type" class="form-control" required onchange="toggleUnite(this.value)">
                    <option value="POURCENTAGE">&#128200; Pourcentage (%)</option>
                    <option value="MONTANT">&#128176; Montant fixe ($)</option>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label" for="reduction">
                    Valeur <span class="required">*</span>
                    <span id="unite-label" style="color:var(--text-muted); font-size:0.85rem;">(en %)</span>
                </label>
                <input type="number" id="reduction" name="reduction"
                       class="form-control" placeholder="ex: 15"
                       min="0.01" step="0.01" required/>
            </div>

            <button type="submit" name="action" value="creer" class="btn btn-full">&#10133; Cr&#233;er le coupon</button>
        </form>
    </div>
</div>

<script>
function genererCodeClient() {
    var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    var code = '';
    for (var i = 0; i < 8; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    document.getElementById('code').value = code;
}
function toggleUnite(val) {
    document.getElementById('unite-label').textContent = val === 'POURCENTAGE' ? '(en %)' : '(en $)';
    var input = document.getElementById('reduction');
    if (val === 'POURCENTAGE') {
        input.setAttribute('max', '100');
        input.placeholder = 'ex: 15';
    } else {
        input.removeAttribute('max');
        input.placeholder = 'ex: 10.00';
    }
}
</script>

<jsp:include page="footer.jsp"/>
