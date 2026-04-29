<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="header.jsp"/>

<h1>Historique de mes commandes</h1>

<c:if test="${not empty commandeConfirmee}">
    <div class="alert alert-success">
        Votre commande #<c:out value="${commandeConfirmee}"/> a bien ete enregistree.
        Un courriel de confirmation vous a ete envoye.
    </div>
</c:if>

<c:choose>
    <c:when test="${empty commandes}">
        <p>Vous n'avez encore passe aucune commande.</p>
        <p><a class="btn" href="${pageContext.request.contextPath}/catalogue">Voir le catalogue</a></p>
    </c:when>
    <c:otherwise>
        <c:forEach var="commande" items="${commandes}">
            <div class="card" style="margin-bottom:1rem;">
                <h3>Commande #${commande.id}</h3>
                <p>
                    <strong>Date :</strong>
                    <fmt:parseDate value="${commande.dateCommande}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="dateParsee" type="both"/>
                    <fmt:formatDate value="${dateParsee}" pattern="dd/MM/yyyy HH:mm"/>
                    &nbsp; &mdash; &nbsp;
                    <strong>Statut :</strong> <c:out value="${commande.statut}"/>
                    &nbsp; &mdash; &nbsp;
                    <strong>Total :</strong> <fmt:formatNumber value="${commande.total}" type="currency" currencySymbol="$"/>
                </p>
                <p><strong>Livraison :</strong> <c:out value="${commande.adresseLivraison}"/></p>

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
                        <c:forEach var="ligne" items="${commande.lignes}">
                            <tr>
                                <td><c:out value="${ligne.produit.nom}"/></td>
                                <td>${ligne.quantite}</td>
                                <td><fmt:formatNumber value="${ligne.prixUnitaire}" type="currency" currencySymbol="$"/></td>
                                <td><fmt:formatNumber value="${ligne.sousTotal}" type="currency" currencySymbol="$"/></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:forEach>
    </c:otherwise>
</c:choose>

<jsp:include page="footer.jsp"/>
