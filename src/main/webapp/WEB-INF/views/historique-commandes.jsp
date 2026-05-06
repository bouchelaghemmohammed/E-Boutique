<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="header.jsp"/>

<h1>Historique de mes commandes</h1>

<c:if test="${not empty commandeConfirmee}">
    <div class="alert alert-success">
        Votre commande #<c:out value="${commandeConfirmee}"/> a bien été enregistrée.
        Un courriel de confirmation vous a été envoyé.
    </div>
</c:if>

<c:choose>
    <c:when test="${empty commandes}">
        <p>Vous n'avez encore passé aucune commande.</p>
        <p><a class="btn" href="${pageContext.request.contextPath}/catalogue">Voir le catalogue</a></p>
    </c:when>
    <c:otherwise>
        <c:forEach var="commande" items="${commandes}">
            <div class="card" style="margin-bottom:1rem;">
                <h3>Commande #${commande.id}</h3>
                <p>
                    <strong>Date :</strong>
                    <c:out value="${commande.orderDate}"/>
                    &nbsp; &mdash; &nbsp;
                    <strong>Statut :</strong> <c:out value="${commande.status}"/>
                    &nbsp; &mdash; &nbsp;
                    <strong>Total :</strong> <fmt:formatNumber value="${commande.total}" type="currency" currencySymbol="$"/>
                </p>
                <p><strong>Livraison :</strong> <c:out value="${commande.shippingAddress}"/></p>

                <table>
                    <thead>
                        <tr>
                            <th>Produit</th>
                            <th>Quantité</th>
                            <th>Prix unitaire</th>
                            <th>Sous-total</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="item" items="${commande.items}">
                            <tr>
                                <td><c:out value="${item.product.name}"/></td>
                                <td>${item.quantity}</td>
                                <td><fmt:formatNumber value="${item.unitPrice}" type="currency" currencySymbol="$"/></td>
                                <td><fmt:formatNumber value="${item.sousTotal}" type="currency" currencySymbol="$"/></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:forEach>
    </c:otherwise>
</c:choose>

<jsp:include page="footer.jsp"/>
