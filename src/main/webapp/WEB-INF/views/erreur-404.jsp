<%@ page contentType="text/html;charset=UTF-8" language="java"
pageEncoding="UTF-8" %> <%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp" />

<div class="auth-page">
  <div
    class="auth-card animate-slide"
    style="text-align: center; max-width: 500px"
  >
    <div style="font-size: 5rem; margin-bottom: 1rem">🔍</div>
    <h1 style="color: var(--green-400); font-weight: 800; margin-bottom: 1rem">
      404 — Page Perdue
    </h1>
    <p class="text-muted" style="margin-bottom: 2rem">
      Désolé, la page que vous recherchez semble avoir disparu dans le cloud ou
      n'a jamais existé.
    </p>

    <div class="flex flex-col gap-1">
      <a
        href="${pageContext.request.contextPath}/dashboard"
        class="btn btn-full"
      >
        🏠 Retour à l'accueil
      </a>
      <a
        href="${pageContext.request.contextPath}/catalogue"
        class="btn btn-outline btn-full"
      >
        🛒 Voir le catalogue
      </a>
    </div>
  </div>
</div>

<jsp:include page="footer.jsp" />
