<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="header.jsp"/>

<div style="max-width: 900px; margin: 0 auto;">

    <%-- =====================================================
         En-tête Profil
         ===================================================== --%>
    <div class="flex items-center gap-2 mb-3 animate-fade">
        <div class="profil-avatar">
            <c:out value="${utilisateurConnecte.firstName.substring(0,1).toUpperCase()}"/>
        </div>
        <div>
            <h1 style="font-size:1.6rem; font-weight:800; letter-spacing:-0.02em;">
                <c:out value="${utilisateurConnecte.fullName}"/>
            </h1>
            <div class="flex items-center gap-1 mt-1">
                <span class="text-muted text-sm">
                    <c:out value="${utilisateurConnecte.email}"/>
                </span>
                <c:choose>
                    <c:when test="${utilisateurConnecte.admin}">
                        <span class="badge badge-admin">Admin</span>
                    </c:when>
                    <c:otherwise>
                        <span class="badge badge-green">Client</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <div class="profil-grid">

        <%-- =====================================================
             Section 1 : Informations personnelles
             ===================================================== --%>
        <div class="card animate-slide">
            <div class="card__header">
                <h2 class="card__title">👤 Informations personnelles</h2>
            </div>

            <c:if test="${not empty succesInfos}">
                <div class="alert alert-success">✅ <c:out value="${succesInfos}"/></div>
            </c:if>
            <c:if test="${not empty erreurInfos}">
                <div class="alert alert-danger">⚠️ <c:out value="${erreurInfos}"/></div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/profil" id="form-profil">
                <input type="hidden" name="action" value="mettreAJour"/>

                <div class="form-group">
                    <label class="form-label" for="prenom">Prénom</label>
                    <input type="text" id="prenom" name="prenom"
                           class="form-control"
                           value="<c:out value='${utilisateurConnecte.firstName}'/>"
                           required maxlength="80"/>
                </div>

                <div class="form-group">
                    <label class="form-label" for="nom">Nom</label>
                    <input type="text" id="nom" name="nom"
                           class="form-control"
                           value="<c:out value='${utilisateurConnecte.lastName}'/>"
                           required maxlength="80"/>
                </div>

                <div class="form-group">
                    <label class="form-label">Courriel</label>
                    <input type="email" class="form-control"
                           value="<c:out value='${utilisateurConnecte.email}'/>"
                           disabled style="opacity:0.6; cursor:not-allowed;"/>
                    <span class="form-hint">Le courriel ne peut pas être modifié.</span>
                </div>

                <button type="submit" class="btn btn-full" id="btn-sauvegarder">
                    💾 Sauvegarder les modifications
                </button>
            </form>
        </div>

        <%-- =====================================================
             Section 2 : Changer de mot de passe
             ===================================================== --%>
        <div class="card animate-slide">
            <div class="card__header">
                <h2 class="card__title">🔒 Sécurité</h2>
            </div>

            <c:if test="${not empty succesMdp}">
                <div class="alert alert-success">✅ <c:out value="${succesMdp}"/></div>
            </c:if>
            <c:if test="${not empty erreurMdp}">
                <div class="alert alert-danger">⚠️ <c:out value="${erreurMdp}"/></div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/profil"
                  id="form-mdp" novalidate>
                <input type="hidden" name="action" value="changerMotDePasse"/>

                <div class="form-group">
                    <label class="form-label" for="ancienMotDePasse">Mot de passe actuel</label>
                    <input type="password" id="ancienMotDePasse" name="ancienMotDePasse"
                           class="form-control"
                           placeholder="••••••••"
                           required/>
                </div>

                <div class="form-group">
                    <label class="form-label" for="nouveauMotDePasse">Nouveau mot de passe</label>
                    <input type="password" id="nouveauMotDePasse" name="nouveauMotDePasse"
                           class="form-control"
                           placeholder="••••••••"
                           required minlength="6"/>
                    <span class="form-hint">Minimum 6 caractères</span>
                </div>

                <div class="form-group">
                    <label class="form-label" for="confirmerMotDePasse">Confirmer le nouveau mot de passe</label>
                    <input type="password" id="confirmerMotDePasse" name="confirmerMotDePasse"
                           class="form-control"
                           placeholder="••••••••"
                           required minlength="6"/>
                </div>

                <button type="submit" class="btn btn-outline btn-full" id="btn-mdp">
                    🔐 Changer le mot de passe
                </button>
            </form>

            <%-- Info du compte --%>
            <div style="margin-top:2rem; padding:1rem; background: rgba(16,185,129,0.05);
                        border:1px solid rgba(16,185,129,0.15); border-radius: 8px;">
                <p class="text-sm text-muted">
                    <strong style="color:var(--green-400);">📅 Membre depuis :</strong><br/>
                    <c:out value="${utilisateurConnecte.createdAt}"/>
                </p>
            </div>

            <%-- Déconnexion rapide --%>
            <div style="margin-top: 1rem;">
                <a href="${pageContext.request.contextPath}/deconnexion"
                   class="btn btn-danger btn-full btn-sm"
                   onclick="return confirm('Voulez-vous vous déconnecter ?');">
                    🚪 Se déconnecter
                </a>
            </div>
        </div>
    </div><%-- /profil-grid --%>

</div>

<script>
    // Validation confirmation mot de passe
    document.getElementById('form-mdp').addEventListener('submit', function(e) {
        const nv   = document.getElementById('nouveauMotDePasse').value;
        const conf = document.getElementById('confirmerMotDePasse').value;
        if (nv !== conf) {
            e.preventDefault();
            alert('Les nouveaux mots de passe ne correspondent pas.');
        }
    });
</script>

<jsp:include page="footer.jsp"/>
