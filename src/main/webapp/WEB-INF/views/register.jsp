<%@ page contentType="text/html;charset=UTF-8" language="java"
pageEncoding="UTF-8" %> <%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="E-Boutique — Créez votre compte client" />
    <title>Inscription — E-Boutique</title>
    <link
      rel="stylesheet"
      href="${pageContext.request.contextPath}/assets/css/style.css"
    />
    <link
      rel="icon"
      href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🛍</text></svg>"
    />
  </head>
  <body>
    <div class="auth-page">
      <div class="auth-card auth-card--wide animate-slide">
        <%-- Back to home --%>
        <a href="${pageContext.request.contextPath}/accueil" class="auth-back">
          ← Retour à l'accueil
        </a>

        <%-- Logo --%>
        <div class="auth-logo">
          <h1>🛒 E-<span>Boutique</span></h1>
          <p>Créez votre compte et commencez à magasiner</p>
        </div>

        <%-- Message d'erreur --%>
        <c:if test="${not empty erreur}">
          <div class="alert alert-danger" id="alert-erreur">
            ⚠️ <c:out value="${erreur}" />
          </div>
        </c:if>

        <%-- Formulaire d'inscription --%>
        <form
          method="post"
          action="${pageContext.request.contextPath}/inscription"
          id="form-inscription"
          novalidate
        >
          <div class="form-row">
            <div class="form-group">
              <label class="form-label" for="prenom">
                Prénom <span class="required">*</span>
              </label>
              <input
                type="text"
                id="prenom"
                name="prenom"
                class="form-control"
                value="<c:out value='${prenom}'/>"
                placeholder="Saisir votre prénom"
                required
                maxlength="80"
              />
            </div>
            <div class="form-group">
              <label class="form-label" for="nom">
                Nom <span class="required">*</span>
              </label>
              <input
                type="text"
                id="nom"
                name="nom"
                class="form-control"
                value="<c:out value='${nom}'/>"
                placeholder="Saisir votre nom"
                required
                maxlength="80"
              />
            </div>
          </div>

          <div class="form-group">
            <label class="form-label" for="courriel">
              Adresse courriel <span class="required">*</span>
            </label>
            <input
              type="email"
              id="courriel"
              name="courriel"
              class="form-control"
              value="<c:out value='${email}'/>"
              placeholder="saisir votre adresse courriel"
              required
              maxlength="150"
            />
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="form-label" for="motDePasse">
                Mot de passe <span class="required">*</span>
              </label>
              <input
                type="password"
                id="motDePasse"
                name="motDePasse"
                class="form-control"
                placeholder="••••••••"
                required
                minlength="3"
              />
              <span class="form-hint">Minimum 3 caractères</span>
            </div>
            <div class="form-group">
              <label class="form-label" for="motDePasseConfirm">
                Confirmer le mot de passe <span class="required">*</span>
              </label>
              <input
                type="password"
                id="motDePasseConfirm"
                name="motDePasseConfirm"
                class="form-control"
                placeholder="••••••••"
                required
                minlength="3"
              />
            </div>
          </div>

          <button type="submit" class="btn btn-full btn-lg" id="btn-inscrire">
            🚀 Créer mon compte
          </button>
        </form>

        <div class="auth-footer">
          Déjà un compte ?
          <a href="${pageContext.request.contextPath}/connexion"
            >Se connecter</a
          >
        </div>
      </div>
    </div>

    <script>
      // Validation de base côté client
      document
        .getElementById("form-inscription")
        .addEventListener("submit", function (e) {
          const mdp = document.getElementById("motDePasse").value;
          const conf = document.getElementById("motDePasseConfirm").value;
          if (mdp !== conf) {
            e.preventDefault();
            alert("Les mots de passe ne correspondent pas.");
          }
        });
    </script>
  </body>
</html>
