<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="header.jsp"/>

<h1>Validation de la commande</h1>

<c:if test="${not empty erreur}">
    <div class="alert alert-error"><c:out value="${erreur}"/></div>
</c:if>

<h2>Recapitulatif</h2>
<table>
    <thead>
        <tr>
            <th>Produit</th>
            <th>Quantite</th>
            <th>Prix unitaire</th>
            <th>Sous-total</th>
        </tr>
    </thead>
    <tbody>
        <c:forEach var="ligne" items="${panier.lignes}">
            <tr>
                <td><c:out value="${ligne.produit.nom}"/></td>
                <td>${ligne.quantite}</td>
                <td><fmt:formatNumber value="${ligne.produit.prix}" type="currency" currencySymbol="$"/></td>
                <td><fmt:formatNumber value="${ligne.sousTotal}" type="currency" currencySymbol="$"/></td>
            </tr>
        </c:forEach>
        <tr>
            <td colspan="3" style="text-align:right;"><strong>Total</strong></td>
            <td><strong><fmt:formatNumber value="${panier.total}" type="currency" currencySymbol="$"/></strong></td>
        </tr>
    </tbody>
</table>

<h2 style="margin-top:2rem;">Adresse de livraison</h2>
<form method="post" action="${pageContext.request.contextPath}/checkout">
    <div class="form-group">
        <label for="adresseLivraison">Adresse complete</label>
        <textarea id="adresseLivraison" name="adresseLivraison" rows="4" required
                  placeholder="123 rue Exemple, Ville, Province, Code postal"></textarea>
    </div>
    <div style="display:flex; gap:0.5rem;">
        <a class="btn" href="${pageContext.request.contextPath}/panier">Retour au panier</a>
        <button type="submit" class="btn">Confirmer la commande</button>
    </div>
</form>

<jsp:include page="footer.jsp"/>
