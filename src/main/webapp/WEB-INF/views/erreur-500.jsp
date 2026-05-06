<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp"/>

<div class="auth-page">
    <div class="auth-card animate-slide" style="text-align: center; max-width: 600px;">
        <div style="font-size: 5rem; margin-bottom: 1rem;">🚧</div>
        <h1 style="color: var(--red-400); font-weight: 800; margin-bottom: 1rem;">500 — Erreur Serveur</h1>
        <p class="text-muted" style="margin-bottom: 2rem;">
            Désolé, une erreur interne inattendue est survenue. Notre équipe technique a été prévenue (enfin, on l'espère).
        </p>
        
        <div style="text-align: left; background: rgba(239, 68, 68, 0.05); border: 1px solid rgba(239, 68, 68, 0.15); 
                    padding: 1rem; border-radius: 8px; font-family: monospace; font-size: 0.85rem; 
                    overflow-x: auto; margin-bottom: 2rem; color: var(--red-400);">
            <strong>Détails :</strong><br/>
            ${pageContext.exception.message != null ? pageContext.exception.message : "Erreur de connexion à la base de données ou configuration JPA invalide."}
        </div>
        
        <div class="flex flex-col gap-1">
            <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-full">
                🏠 Retour à l'accueil
            </a>
            <a href="mailto:support@eboutique.com" class="btn btn-outline btn-full">
                📧 Contacter le support
            </a>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp"/>
