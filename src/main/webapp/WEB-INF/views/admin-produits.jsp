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

<%-- ── Tableau des produits ── --%>
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
                <tbody>
                    <c:forEach var="p" items="${produits}">
                        <tr>
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

<jsp:include page="footer.jsp"/>
