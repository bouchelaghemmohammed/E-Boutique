<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="header.jsp"/>

<h1>Mon panier</h1>

<c:choose>
    <c:when test="${panier == null || panier.estVide()}">
        <p>Votre panier est vide.</p>
        <p><a class="btn" href="${pageContext.request.contextPath}/catalogue">Voir le catalogue</a></p>
    </c:when>
    <c:otherwise>
        <table>
            <thead>
                <tr>
                    <th>Produit</th>
                    <th>Prix unitaire</th>
                    <th>Quantite</th>
                    <th>Sous-total</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="ligne" items="${panier.lignes}">
                    <tr>
                        <td>
                            <strong><c:out value="${ligne.produit.nom}"/></strong>
                        </td>
                        <td>
                            <fmt:formatNumber value="${ligne.produit.prix}" type="currency" currencySymbol="$"/>
                        </td>
                        <td>
                            <form method="post" action="${pageContext.request.contextPath}/panier" style="display:inline-flex; gap:0.5rem;">
                                <input type="hidden" name="action" value="modifier"/>
                                <input type="hidden" name="produitId" value="${ligne.produit.id}"/>
                                <input type="number" name="quantite" value="${ligne.quantite}" min="1" max="999" style="width:70px;"/>
                                <button type="submit" class="btn">Mettre a jour</button>
                            </form>
                        </td>
                        <td>
                            <fmt:formatNumber value="${ligne.sousTotal}" type="currency" currencySymbol="$"/>
                        </td>
                        <td>
                            <form method="post" action="${pageContext.request.contextPath}/panier">
                                <input type="hidden" name="action" value="retirer"/>
                                <input type="hidden" name="produitId" value="${ligne.produit.id}"/>
                                <button type="submit" class="btn btn-danger">Retirer</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
                <tr>
                    <td colspan="3" style="text-align:right;"><strong>Total</strong></td>
                    <td colspan="2"><strong><fmt:formatNumber value="${panier.total}" type="currency" currencySymbol="$"/></strong></td>
                </tr>
            </tbody>
        </table>

        <div style="margin-top:1.5rem; display:flex; gap:0.5rem;">
            <a class="btn" href="${pageContext.request.contextPath}/catalogue">Continuer mes achats</a>
            <a class="btn" href="${pageContext.request.contextPath}/checkout">Passer la commande</a>
            <form method="post" action="${pageContext.request.contextPath}/panier" style="margin-left:auto;">
                <input type="hidden" name="action" value="vider"/>
                <button type="submit" class="btn btn-danger">Vider le panier</button>
            </form>
        </div>
    </c:otherwise>
</c:choose>

<jsp:include page="footer.jsp"/>
