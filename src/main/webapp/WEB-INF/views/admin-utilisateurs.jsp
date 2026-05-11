<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="header.jsp"/>

<%-- ── En-tête ── --%>
<div class="dashboard-header animate-fade">
    <div>
        <h1>&#128101; Gestion des utilisateurs</h1>
        <p class="text-muted">Consulter, modifier, désactiver ou supprimer les comptes</p>
    </div>
    <div class="flex gap-1">
        <span class="badge badge-blue" style="font-size:0.9rem;padding:0.4rem 0.9rem;">
            ${utilisateurs.size()} compte(s)
        </span>
    </div>
</div>

<%-- ── Flash ── --%>
<c:if test="${not empty flashMessage}">
    <div class="alert alert-success animate-slide"><c:out value="${flashMessage}"/></div>
</c:if>
<c:if test="${not empty flashError}">
    <div class="alert alert-danger animate-slide"><c:out value="${flashError}"/></div>
</c:if>

<%-- ── Barre de recherche ── --%>
<div class="flex gap-1 mb-2" style="align-items:center;">
    <input type="text" id="searchUser" class="form-control"
           placeholder="&#128269; Rechercher par nom, prénom ou courriel…"
           oninput="filtrerUsers()" style="max-width:380px;"/>
    <div class="flex gap-1 ml-auto">
        <button class="btn btn-sm ${param.filter == 'admin' ? '' : 'btn-outline'}"
                onclick="filtrerRole('admin')" id="btn-admin">
            &#128081; Admin
        </button>
        <button class="btn btn-sm ${param.filter == 'user' ? '' : 'btn-outline'}"
                onclick="filtrerRole('user')" id="btn-user">
            &#128100; Utilisateurs
        </button>
        <button class="btn btn-sm btn-outline" onclick="filtrerRole('tous')" id="btn-tous">
            Tous
        </button>
    </div>
</div>

<c:choose>
    <c:when test="${empty utilisateurs}">
        <div class="alert alert-info animate-fade">Aucun utilisateur enregistré.</div>
    </c:when>
    <c:otherwise>
        <div class="table-wrapper animate-fade">
            <table id="usersTable">
                <thead>
                    <tr>
                        <th style="width:3rem">#</th>
                        <th>Nom complet</th>
                        <th>Courriel</th>
                        <th>Rôle</th>
                        <th>Statut</th>
                        <th>Inscrit le</th>
                        <th style="width:13rem">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="u" items="${utilisateurs}">
                        <tr data-name="${u.firstName} ${u.lastName}"
                            data-email="${u.email}"
                            data-role="${u.admin ? 'admin' : 'user'}">
                            <td><strong class="text-green">${u.id}</strong></td>
                            <td>
                                <div style="display:flex;align-items:center;gap:0.5rem;">
                                    <span class="user-avatar">${u.firstName.charAt(0)}${u.lastName.charAt(0)}</span>
                                    <div>
                                        <div class="fw-bold"><c:out value="${u.firstName}"/> <c:out value="${u.lastName}"/></div>
                                        <c:if test="${u.id == utilisateurConnecte.id}">
                                            <span class="text-muted text-sm">(vous)</span>
                                        </c:if>
                                    </div>
                                </div>
                            </td>
                            <td class="text-sm"><c:out value="${u.email}"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${u.admin}">
                                        <span class="badge badge-yellow">&#128081; Admin</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-blue">&#128100; Utilisateur</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${u.enabled}">
                                        <span class="badge badge-green">&#9989; Actif</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-red">&#128683; Désactivé</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-sm text-muted">${u.createdAtFormatted}</td>
                            <td>
                                <div class="flex gap-1" style="flex-wrap:wrap;">
                                    <%-- Éditer --%>
                                    <button type="button" class="btn btn-sm"
                                            onclick="ouvrirModalEdit(
                                                ${u.id},
                                                '<c:out value="${u.firstName}" escapeXml="true"/>',
                                                '<c:out value="${u.lastName}"  escapeXml="true"/>',
                                                '<c:out value="${u.email}"     escapeXml="true"/>',
                                                '${u.admin ? "ADMIN" : "USER"}',
                                                ${u.enabled},
                                                ${u.id == utilisateurConnecte.id}
                                            )"
                                            title="Modifier">
                                        &#9998; Modifier
                                    </button>

                                    <%-- Activer / Désactiver (pas sur soi) --%>
                                    <c:if test="${u.id != utilisateurConnecte.id}">
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/admin/utilisateurs"
                                              style="display:inline;"
                                              id="form-toggle-${u.id}">
                                            <input type="hidden" name="action"  value="toggle"/>
                                            <input type="hidden" name="userId"  value="${u.id}"/>
                                            <button type="button"
                                                    class="btn btn-sm ${u.enabled ? 'btn-warning' : 'btn-success'}"
                                                    onclick="showConfirmUserModal(
                                                        '${u.enabled ? 'Désactiver' : 'Activer'} le compte de <c:out value="${u.firstName} ${u.lastName}"/> ?',
                                                        'form-toggle-${u.id}')"
                                                    title="${u.enabled ? 'Désactiver' : 'Activer'}">
                                                ${u.enabled ? '&#128683;' : '&#9989;'}
                                                ${u.enabled ? 'Désactiver' : 'Activer'}
                                            </button>
                                        </form>

                                        <%-- Supprimer --%>
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/admin/utilisateurs"
                                              style="display:inline;"
                                              id="form-suppr-${u.id}">
                                            <input type="hidden" name="action"  value="supprimer"/>
                                            <input type="hidden" name="userId"  value="${u.id}"/>
                                            <button type="button" class="btn btn-sm btn-danger"
                                                    onclick="showConfirmUserModal(
                                                        'Supprimer définitivement le compte de <c:out value="${u.firstName} ${u.lastName}"/> ?',
                                                        'form-suppr-${u.id}')"
                                                    title="Supprimer">
                                                &#128465;
                                            </button>
                                        </form>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        <p class="text-muted text-sm mt-2">
            Total : <strong id="userCount">${utilisateurs.size()}</strong> compte(s) affiché(s)
        </p>
    </c:otherwise>
</c:choose>

<%-- ══ Modal : confirmation (désactiver / supprimer) ══ --%>
<div id="confirmUserModal" class="modal-overlay" style="display:none;"
     onclick="if(event.target===this) closeConfirmUserModal()">
    <div class="modal-box animate-fade">
        <div class="modal-icon">&#9888;&#65039;</div>
        <p id="confirmUserMsg" class="modal-msg"></p>
        <div class="modal-actions">
            <button onclick="closeConfirmUserModal()" class="btn btn-outline">Non, annuler</button>
            <button id="confirmUserBtn" class="btn btn-danger">Oui, confirmer</button>
        </div>
    </div>
</div>

<%-- ══ Modal : modifier un utilisateur ══ --%>
<div id="editUserModal" class="modal-overlay" style="display:none;"
     onclick="if(event.target===this) closeEditModal()">
    <div class="modal-box modal-box--lg animate-fade">
        <h3 class="modal-title">&#9998; Modifier le compte</h3>
        <form method="post" action="${pageContext.request.contextPath}/admin/utilisateurs"
              id="editUserForm">
            <input type="hidden" name="action" value="modifier"/>
            <input type="hidden" name="userId" id="editUserId"/>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Prénom</label>
                    <input type="text" name="firstName" id="editFirstName"
                           class="form-control" required maxlength="80"/>
                </div>
                <div class="form-group">
                    <label class="form-label">Nom</label>
                    <input type="text" name="lastName" id="editLastName"
                           class="form-control" required maxlength="80"/>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Courriel</label>
                <input type="email" name="email" id="editEmail"
                       class="form-control" required maxlength="150"/>
            </div>

            <div id="editRoleEnabledSection">
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Rôle</label>
                        <select name="role" id="editRole" class="form-control">
                            <option value="USER">&#128100; Utilisateur</option>
                            <option value="ADMIN">&#128081; Administrateur</option>
                        </select>
                    </div>
                    <div class="form-group" style="justify-content:flex-end;padding-top:1.8rem;">
                        <label class="flex gap-1" style="align-items:center;cursor:pointer;">
                            <input type="checkbox" name="enabled" id="editEnabled" value="on"
                                   style="width:18px;height:18px;accent-color:var(--green-500);"/>
                            <span class="form-label" style="margin:0;">Compte actif</span>
                        </label>
                    </div>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">
                    Nouveau mot de passe
                    <span class="text-muted text-sm">(laisser vide pour ne pas changer)</span>
                </label>
                <input type="password" name="newPassword" id="editNewPassword"
                       class="form-control" placeholder="min. 4 caractères" minlength="4" maxlength="100"
                       autocomplete="new-password"/>
            </div>

            <div class="modal-actions" style="margin-top:1.5rem;">
                <button type="button" onclick="closeEditModal()" class="btn btn-outline">
                    Annuler
                </button>
                <button type="submit" class="btn">
                    &#10003; Enregistrer
                </button>
            </div>
        </form>
    </div>
</div>

<style>
/* ── User avatar ── */
.user-avatar {
    width: 36px; height: 36px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--green-600), var(--green-400));
    color: #fff;
    font-weight: 800;
    font-size: 0.78rem;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    text-transform: uppercase;
    letter-spacing: 0.02em;
}
/* ── Modal styles (cohérents avec admin-commandes) ── */
.modal-overlay {
    position: fixed; inset: 0;
    background: rgba(0,0,0,.55);
    display: flex; align-items: center; justify-content: center;
    z-index: 9999;
    backdrop-filter: blur(3px);
}
.modal-box {
    background: var(--bg-secondary);
    border: 1px solid var(--border);
    border-radius: calc(var(--radius) * 2);
    padding: 2rem 2.5rem;
    max-width: 420px;
    width: 90%;
    text-align: center;
    box-shadow: 0 20px 60px rgba(0,0,0,.4);
}
.modal-box--lg {
    max-width: 560px;
    text-align: left;
}
.modal-icon  { font-size: 2.5rem; margin-bottom: .75rem; }
.modal-title { font-size: 1.2rem; font-weight: 700; margin-bottom: 1.25rem; color: var(--text-primary); }
.modal-msg   { font-size: 1.05rem; font-weight: 600; margin-bottom: 1.5rem; color: var(--text-primary); }
.modal-actions { display: flex; gap: 1rem; justify-content: center; }
.modal-box--lg .modal-actions { justify-content: flex-end; }
/* ── Extra button colors ── */
.btn-danger  { background: var(--red-500,#ef4444); color:#fff; border-color: var(--red-500,#ef4444); }
.btn-danger:hover { background: var(--red-400,#f87171); }
.btn-warning { background: #d97706; color:#fff; border-color:#d97706; }
.btn-warning:hover { background: #b45309; }
.btn-success { background: var(--green-600); color:#fff; border-color:var(--green-600); }
.btn-success:hover { background: var(--green-500); }
/* ── Form row ── */
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
@media(max-width:500px) { .form-row { grid-template-columns: 1fr; } }
</style>

<script>
/* ── Confirmation modale ── */
var _pendingFormId = null;
function showConfirmUserModal(msg, formId) {
    document.getElementById('confirmUserMsg').textContent = msg;
    _pendingFormId = formId;
    document.getElementById('confirmUserModal').style.display = 'flex';
}
function closeConfirmUserModal() {
    document.getElementById('confirmUserModal').style.display = 'none';
    _pendingFormId = null;
}
document.getElementById('confirmUserBtn').addEventListener('click', function () {
    if (_pendingFormId) document.getElementById(_pendingFormId).submit();
});

/* ── Modale édition ── */
function ouvrirModalEdit(id, prenom, nom, email, role, enabled, isSelf) {
    document.getElementById('editUserId').value    = id;
    document.getElementById('editFirstName').value = prenom;
    document.getElementById('editLastName').value  = nom;
    document.getElementById('editEmail').value     = email;
    document.getElementById('editRole').value      = role;
    document.getElementById('editEnabled').checked = enabled;
    document.getElementById('editNewPassword').value = '';
    // Si c'est l'admin lui-même : masquer rôle/statut
    document.getElementById('editRoleEnabledSection').style.display = isSelf ? 'none' : '';
    document.getElementById('editUserModal').style.display = 'flex';
}
function closeEditModal() {
    document.getElementById('editUserModal').style.display = 'none';
}

/* ── Recherche + filtres ── */
var _activeRole = 'tous';
function filtrerUsers() {
    var q = document.getElementById('searchUser').value.toLowerCase();
    var rows = document.querySelectorAll('#usersTable tbody tr');
    var visible = 0;
    rows.forEach(function (row) {
        var name  = (row.getAttribute('data-name')  || '').toLowerCase();
        var email = (row.getAttribute('data-email') || '').toLowerCase();
        var role  = (row.getAttribute('data-role')  || '');
        var matchSearch = !q || name.includes(q) || email.includes(q);
        var matchRole   = _activeRole === 'tous' || role === _activeRole;
        var show = matchSearch && matchRole;
        row.style.display = show ? '' : 'none';
        if (show) visible++;
    });
    var counter = document.getElementById('userCount');
    if (counter) counter.textContent = visible;
}
function filtrerRole(role) {
    _activeRole = role;
    ['admin','user','tous'].forEach(function(r) {
        var btn = document.getElementById('btn-' + r);
        if (btn) {
            btn.classList.toggle('btn-outline', r !== role);
            btn.classList.toggle('btn-active',  r === role);
        }
    });
    filtrerUsers();
}
// Init actif par défaut
document.getElementById('btn-tous').classList.remove('btn-outline');
</script>

<jsp:include page="footer.jsp"/>
