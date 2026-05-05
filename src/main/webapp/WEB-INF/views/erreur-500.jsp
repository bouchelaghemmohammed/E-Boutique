<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="header.jsp"/>
<div class="card text-center animate-slide" style="margin: 4rem auto; max-width: 600px; padding: 3rem;">
    <div style="font-size: 4rem; margin-bottom: 1rem;">🚧</div>
    <h1 style="color: var(--red-400); margin-bottom: 1rem;">Erreur 500</h1>
    <p class="text-muted mb-3">Oups ! Une erreur interne est survenue sur le serveur.</p>
    <div style="text-align: left; background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.2); padding: 1rem; border-radius: 8px; font-family: monospace; font-size: 0.8rem; overflow-x: auto;">
        ${pageContext.exception.message != null ? pageContext.exception.message : "Erreur de connexion à la base de données ou configuration manquante."}
    </div>
    <div class="mt-3">
        <a href="${pageContext.request.contextPath}/dashboard" class="btn">Retourner à l'accueil</a>
    </div>
</div>
<jsp:include page="footer.jsp"/>
