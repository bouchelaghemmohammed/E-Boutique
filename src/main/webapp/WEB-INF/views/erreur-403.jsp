<%@ page contentType="text/html;charset=UTF-8" language="java"
pageEncoding="UTF-8" %> <%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp" />

<div class="auth-page">
  <div
    class="auth-card animate-slide"
    style="text-align: center; max-width: 500px"
  >
    <div style="font-size: 5rem; margin-bottom: 1rem">🚫</div>
    <h1 style="color: var(--red-400); font-weight: 800; margin-bottom: 1rem">
      403 — Accès Refusé
    </h1>
    <p class="text-muted" style="margin-bottom: 2rem">
      Désolé, vous n'avez pas les permissions nécessaires pour accéder à cette
      page. Cette zone est réservée aux administrateurs.
    </p>

    <div class="flex flex-col gap-1">
      <a
        href="${pageContext.request.contextPath}/dashboard"
        class="btn btn-full"
      >
        🏠 Retour au tableau de bord
      </a>
      <a
        href="${pageContext.request.contextPath}/catalogue"
        class="btn btn-outline btn-full"
      >
        🛒 Continuer mes achats
      </a>
    </div>
  </div>
</div>

<jsp:include page="footer.jsp" />
