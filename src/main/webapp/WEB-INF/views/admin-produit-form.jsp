<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="header.jsp"/>

<c:set var="estNouveau" value="${empty produit}"/>

<div class="section-title">
    <c:choose>
        <c:when test="${estNouveau}">➕ Nouveau produit</c:when>
        <c:otherwise>✏️ Modifier le produit</c:otherwise>
    </c:choose>
</div>

<a href="${pageContext.request.contextPath}/admin/produits" class="auth-back mb-2">
    ← Retour à la liste
</a>

<c:if test="${not empty erreurForm}">
    <div class="alert alert-danger animate-slide">⚠️ <c:out value="${erreurForm}"/></div>
</c:if>

<div class="admin-form-wrapper card animate-slide">
    <form method="post" action="${pageContext.request.contextPath}/admin/produits"
          id="form-produit" novalidate>

        <%-- ID caché si modification --%>
        <c:if test="${not estNouveau}">
            <input type="hidden" name="id" value="${produit.id}"/>
        </c:if>

        <div class="form-row">
            <%-- Nom --%>
            <div class="form-group">
                <label class="form-label" for="nom">
                    Nom du produit <span class="required">*</span>
                </label>
                <input type="text" id="nom" name="nom"
                       class="form-control"
                       value="<c:out value='${produit.name}'/>"
                       placeholder="Ex : Clavier mécanique RGB"
                       required maxlength="150"/>
            </div>

            <%-- Catégorie --%>
            <div class="form-group">
                <label class="form-label" for="categorieId">Catégorie</label>
                <select id="categorieId" name="categorieId" class="form-control">
                    <option value="">— Choisir une catégorie —</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.id}"
                            <c:if test="${not empty produit && not empty produit.category && produit.category.id == cat.id}">selected</c:if>>
                            <c:out value="${cat.name}"/>
                        </option>
                    </c:forEach>
                </select>
            </div>
        </div>

        <%-- Description --%>
        <div class="form-group">
            <label class="form-label" for="description">Description</label>
            <textarea id="description" name="description" class="form-control" rows="3"
                      placeholder="Description du produit…"><c:out value="${produit.description}"/></textarea>
        </div>

        <div class="form-row">
            <%-- Prix --%>
            <div class="form-group">
                <label class="form-label" for="prix">
                    Prix (€) <span class="required">*</span>
                </label>
                <input type="text" id="prix" name="prix"
                       class="form-control"
                       value="<c:out value='${produit.price}'/>"
                       placeholder="Ex : 29.99"
                       required/>
            </div>

            <%-- Stock --%>
            <div class="form-group">
                <label class="form-label" for="stock">Stock</label>
                <input type="number" id="stock" name="stock"
                       class="form-control"
                       value="${empty produit ? 0 : produit.stock}"
                       min="0" placeholder="0"/>
            </div>
        </div>

        <%-- Image URL --%>
        <div class="form-group">
            <label class="form-label" for="imagePath">
                URL de l'image
                <span class="form-hint">Lien vers une image en ligne (ex : Unsplash, Imgur…)</span>
            </label>
            <input type="url" id="imagePath" name="imagePath"
                   class="form-control"
                   value="<c:out value='${produit.imagePath}'/>"
                   placeholder="https://images.unsplash.com/…"
                   oninput="previewImage(this.value)"/>
        </div>

        <%-- Aperçu image --%>
        <div class="form-group" id="img-preview-wrapper"
             style="${empty produit.imagePath ? 'display:none' : ''}">
            <label class="form-label">Aperçu</label>
            <img id="img-preview"
                 src="<c:out value='${produit.imagePath}'/>"
                 alt="Aperçu"
                 class="admin-img-preview"
                 onerror="this.parentElement.style.display='none'"/>
        </div>

        <%-- Boutons --%>
        <div class="flex gap-1 flex-wrap" style="margin-top:1.5rem;">
            <a href="${pageContext.request.contextPath}/admin/produits" class="btn btn-outline">
                Annuler
            </a>
            <button type="submit" class="btn">
                <c:choose>
                    <c:when test="${estNouveau}">➕ Créer le produit</c:when>
                    <c:otherwise>💾 Enregistrer les modifications</c:otherwise>
                </c:choose>
            </button>
        </div>
    </form>
</div>

<script>
function previewImage(url) {
    const wrapper = document.getElementById('img-preview-wrapper');
    const img     = document.getElementById('img-preview');
    if (url && url.startsWith('http')) {
        img.src = url;
        wrapper.style.display = '';
    } else {
        wrapper.style.display = 'none';
    }
}
</script>

<jsp:include page="footer.jsp"/>
