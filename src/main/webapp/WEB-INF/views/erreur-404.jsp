<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="header.jsp"/>
<div class="card text-center animate-slide" style="margin: 4rem auto; max-width: 600px; padding: 3rem;">
    <div style="font-size: 4rem; margin-bottom: 1rem;">🔍</div>
    <h1 style="color: var(--green-400); margin-bottom: 1rem;">Page non trouvée (404)</h1>
    <p class="text-muted mb-3">La page que vous recherchez semble avoir disparu dans le cloud.</p>
    <a href="${pageContext.request.contextPath}/dashboard" class="btn">Retourner au magasin</a>
</div>
<jsp:include page="footer.jsp"/>
