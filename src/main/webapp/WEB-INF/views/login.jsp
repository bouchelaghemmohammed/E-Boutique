<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta name="description" content="E-Boutique — Connectez-vous à votre compte"/>
    <title>Connexion — E-Boutique</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css"/>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🛍</text></svg>"/>
</head>
<body>

<div class="auth-page">
    <div class="auth-card animate-slide">

        <%-- Back to home --%>
        <a href="${pageContext.request.contextPath}/accueil" class="auth-back">
            ← Retour à l'accueil
        </a>

        <%-- Logo --%>
        <div class="auth-logo">
            <h1>🛒 E-<span>Boutique</span></h1>
            <p>Bienvenue ! Connectez-vous pour continuer</p>
        </div>

        <%-- Message de succès (ex: après inscription) --%>
        <c:if test="${not empty messageSucces}">
            <div class="alert alert-success" id="alert-succes">
                ✅ <c:out value="${messageSucces}"/>
            </div>
        </c:if>

        <%-- Message d'erreur --%>
        <c:if test="${not empty erreur}">
            <div class="alert alert-danger" id="alert-erreur">
                ⚠️ <c:out value="${erreur}"/>
            </div>
        </c:if>

        <%-- Formulaire de connexion --%>
        <form method="post" action="${pageContext.request.contextPath}/connexion" id="form-connexion" >
            <%-- Paramètre de redirection --%>
            <c:if test="${not empty param.redirect}">
                <input type="hidden" name="redirect" value="${param.redirect}"/>
            </c:if>

            <div class="form-group">
                <label class="form-label" for="courriel">
                    Adresse courriel
                </label>
                <input type="email" id="courriel" name="courriel"
                       class="form-control"
                       value="<c:out value='${not empty courriel ? courriel : courrielSauvegarde}'/>"
                       placeholder="votre@courriel.com"
                       required autocomplete="email"/>
            </div>

            <div class="form-group">
                <label class="form-label" for="motDePasse">
                    Mot de passe
                </label>
                <input type="password" id="motDePasse" name="motDePasse"
                       class="form-control"
                       placeholder="••••••••"
                       required autocomplete="current-password"/>
            </div>

            <div class="form-group">
                <div class="form-check">
                    <input type="checkbox" id="rememberMe" name="rememberMe"
                           value="on"
                           ${not empty courrielSauvegarde ? 'checked' : ''}/>
                    <label for="rememberMe">Se souvenir de moi (30 jours)</label>
                </div>
            </div>

            <button type="submit" class="btn btn-full btn-lg" id="btn-connexion">
                🔑 Se connecter
            </button>
        </form>

        <div class="auth-divider">ou</div>

        <div class="auth-footer">
            Pas encore de compte ?
            <a href="${pageContext.request.contextPath}/inscription">
                <strong>Créer un compte gratuitement</strong>
            </a>
        </div>

    </div>
</div>

</body>
</html>
