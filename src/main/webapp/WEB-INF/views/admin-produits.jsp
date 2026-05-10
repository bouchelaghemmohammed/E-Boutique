<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="header.jsp"/>

<%-- ── En-tête admin ── --%>
<div class="admin-header">
    <div>
        <div class="section-title">⚙️ Gestion des Produits</div>
        <p class="text-muted text-sm">Ajouter, modifier ou supprimer des produits du catalogue</p>
    </div>
    <a href="${pageContext.request.contextPath}/admin/produits?action=nouveau"
       class="btn">
        ＋ Nouveau produit
    </a>
</div>

<%-- Flash messages --%>
<c:if test="${not empty flashSuccess}">
    <div class="alert alert-success animate-slide">✅ <c:out value="${flashSuccess}"/></div>
</c:if>
<c:if test="${not empty flashError}">
    <div class="alert alert-danger animate-slide">⚠️ <c:out value="${flashError}"/></div>
</c:if>

<%-- ── Filtres stock ── --%>
<c:if test="${not empty produits}">
<div class="flex gap-1 mb-2 animate-fade" style="align-items:center; flex-wrap:wrap;">
    <span class="text-muted text-sm" style="margin-right:0.25rem;">Afficher :</span>
    <button class="btn btn-sm btn-outline" id="filtre-tous"      onclick="filtrerStock('tous')">
        📦 Tous
        <span class="badge badge-green" id="cnt-tous"     style="margin-left:0.3rem;">0</span>
    </button>
    <button class="btn btn-sm" id="filtre-limite"   onclick="filtrerStock('limite')" style="background:var(--yellow-500,#eab308);color:#000;">
        ⚠️ Stock limité (&lt; 5)
        <span id="cnt-limite"  style="margin-left:0.3rem; font-weight:bold;">0</span>
    </button>
    <button class="btn btn-sm btn-danger" id="filtre-rupture"  onclick="filtrerStock('rupture')">
        ❌ Rupture de stock
        <span id="cnt-rupture" style="margin-left:0.3rem; font-weight:bold;">0</span>
    </button>
</div>
</c:if>
<c:choose>
    <c:when test="${not empty produits}">
        <div class="table-wrapper animate-fade">
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Image</th>
                        <th>Nom</th>
                        <th>Catégorie</th>
                        <th>Prix</th>
                        <th>Stock</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="tbody-produits">
                    <c:forEach var="p" items="${produits}">
                        <tr data-stock="${p.stock}">
                            <td class="text-muted">${p.id}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty p.imagePath}">
                                        <img src="${p.imagePath}"
                                             alt="<c:out value='${p.name}'/>"
                                             class="admin-thumb"/>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="admin-thumb-placeholder">📦</div>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <strong><c:out value="${p.name}"/></strong>
                                <c:if test="${not empty p.description}">
                                    <div class="text-muted text-sm" style="max-width:200px; overflow:hidden; white-space:nowrap; text-overflow:ellipsis;">
                                        <c:out value="${p.description}"/>
                                    </div>
                                </c:if>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty p.category}">
                                        <span class="badge badge-green"><c:out value="${p.category.name}"/></span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">—</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="fw-bold text-green">
                                <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="€"/>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${p.stock == 0}">
                                        <span class="badge badge-red">Rupture</span>
                                    </c:when>
                                    <c:when test="${p.stock < 5}">
                                        <span class="badge badge-yellow">${p.stock}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-green">${p.stock}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="flex gap-1">
                                    <a href="${pageContext.request.contextPath}/admin/produits?action=modifier&id=${p.id}"
                                       class="btn btn-sm btn-outline">✏️ Modifier</a>
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/admin/produits?action=supprimer&id=${p.id}"
                                          style="margin:0;"
                                          onsubmit="return confirm('Supprimer « ${p.name} » ?')">
                                        <input type="hidden" name="action" value="supprimer"/>
                                        <input type="hidden" name="id"     value="${p.id}"/>
                                        <button type="submit" class="btn btn-sm btn-danger">🗑 Supprimer</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </c:when>
    <c:otherwise>
        <div class="alert alert-info animate-fade">
            Aucun produit enregistré. <a href="${pageContext.request.contextPath}/admin/produits?action=nouveau">Créer le premier produit →</a>
        </div>
    </c:otherwise>
</c:choose>

<script>
(function () {
    var tbody = document.getElementById('tbody-produits');
    if (!tbody) return;

    var rows = Array.from(tbody.querySelectorAll('tr'));

    // Compter les produits par catégorie de stock
    var cntTous    = rows.length;
    var cntLimite  = rows.filter(function(r){ var s = parseInt(r.dataset.stock, 10); return s > 0 && s < 5; }).length;
    var cntRupture = rows.filter(function(r){ return parseInt(r.dataset.stock, 10) <= 0; }).length;

    document.getElementById('cnt-tous').textContent    = cntTous;
    document.getElementById('cnt-limite').textContent  = cntLimite;
    document.getElementById('cnt-rupture').textContent = cntRupture;

    window.filtrerStock = function(mode) {
        rows.forEach(function(r) {
            var stock = parseInt(r.dataset.stock, 10);
            var visible = true;
            if (mode === 'limite')  visible = stock > 0 && stock < 5;
            if (mode === 'rupture') visible = stock <= 0;
            r.style.display = visible ? '' : 'none';
        });

        // Mettre à jour l'apparence des boutons actifs
        document.getElementById('filtre-tous').classList.toggle('btn-outline', mode !== 'tous');
        document.getElementById('filtre-tous').style.opacity = mode === 'tous' ? '1' : '0.6';
        document.getElementById('filtre-limite').style.opacity  = mode === 'limite'  ? '1' : '0.6';
        document.getElementById('filtre-rupture').style.opacity = mode === 'rupture' ? '1' : '0.6';
    };

    // Par défaut : afficher tous
    filtrerStock('tous');
})();
</script>

<jsp:include page="footer.jsp"/>
