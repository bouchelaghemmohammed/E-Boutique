<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="header.jsp"/>

<section class="home-landing">
    <div class="home-landing__inner">

        <%-- ── Brand ── --%>
        <div class="home-brand">
            <span class="home-brand__icon">🛒</span>
            <h1 class="home-brand__name">E-<span>Boutique</span></h1>
            <p class="home-brand__tagline">Votre boutique en ligne</p>
        </div>

        <%-- ── Primary CTAs ── --%>
        <div class="home-cta-row">
            <a href="${pageContext.request.contextPath}/catalogue" class="home-cta home-cta--primary">
                <span class="home-cta__icon">🛍</span>
                Explore Market
            </a>
            <c:choose>
                <c:when test="${not empty utilisateurConnecte}">
                    <a href="${pageContext.request.contextPath}/dashboard" class="home-cta home-cta--outline">
                        <span class="home-cta__icon">📊</span>
                        Dashboard
                    </a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/inscription" class="home-cta home-cta--outline">
                        <span class="home-cta__icon">✨</span>
                        Join Now
                    </a>
                </c:otherwise>
            </c:choose>
        </div>

        <%-- ── Quick links (logged in) ── --%>
        <div class="home-actions">

            <c:if test="${not empty utilisateurConnecte}">
                <a href="${pageContext.request.contextPath}/panier" class="home-action-btn">
                    <span class="home-action-btn__icon">🛒</span>
                    <span class="home-action-btn__label">Mon Panier
                        <c:if test="${not empty sessionScope.panier && !sessionScope.panier.estVide()}">
                            <span class="home-action-btn__badge">${sessionScope.panier.nombreArticles}</span>
                        </c:if>
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/profil" class="home-action-btn">
                    <span class="home-action-btn__icon">👤</span>
                    <span class="home-action-btn__label">Mon Compte</span>
                </a>
                <a href="${pageContext.request.contextPath}/historique" class="home-action-btn">
                    <span class="home-action-btn__icon">📦</span>
                    <span class="home-action-btn__label">Mes Commandes</span>
                </a>
                <c:if test="${utilisateurConnecte.admin}">
                    <a href="${pageContext.request.contextPath}/dashboard" class="home-action-btn">
                        <span class="home-action-btn__icon">📊</span>
                        <span class="home-action-btn__label">Dashboard Admin</span>
                    </a>
                </c:if>
            </c:if>
        </div>

        <%-- ── 6 Feature Widgets ── --%>
        <div class="home-features">
            <div class="hf-card hf-card--green">
                <div class="hf-card__icon">🛍</div>
                <div class="hf-card__body">
                    <h3>Catalogue Riche</h3>
                    <p>Explorez des centaines de produits triés par catégorie, avec filtres et recherche instantanée.</p>
                </div>
            </div>
            <div class="hf-card hf-card--blue">
                <div class="hf-card__icon">🔒</div>
                <div class="hf-card__body">
                    <h3>Plateforme Sécurisée</h3>
                    <p>Vos données sont protégées par une authentification robuste et des sessions chiffrées.</p>
                </div>
            </div>
            <div class="hf-card hf-card--purple">
                <div class="hf-card__icon">🛒</div>
                <div class="hf-card__body">
                    <h3>Panier Intelligent</h3>
                    <p>Ajoutez, modifiez vos quantités et passez commande en quelques clics seulement.</p>
                </div>
            </div>
            <div class="hf-card hf-card--orange">
                <div class="hf-card__icon">🏪</div>
                <div class="hf-card__body">
                    <h3>Espace Vendeur</h3>
                    <p>Gérez vos produits, suivez vos ventes et recevez vos notifications depuis le dashboard.</p>
                </div>
            </div>
            <div class="hf-card hf-card--teal">
                <div class="hf-card__icon">📦</div>
                <div class="hf-card__body">
                    <h3>Suivi des Commandes</h3>
                    <p>Consultez l'historique complet de vos achats et le statut de chaque livraison.</p>
                </div>
            </div>
            <div class="hf-card hf-card--rose">
                <div class="hf-card__icon">🎧</div>
                <div class="hf-card__body">
                    <h3>Support Client</h3>
                    <p>Une équipe disponible pour répondre à toutes vos questions et résoudre vos problèmes.</p>
                </div>
            </div>
        </div>

    </div>
</section>

<style>
/* ── Page layout ── */
.home-landing {
    display: flex;
    justify-content: center;
    padding: 3rem 1rem 4rem;
}

.home-landing__inner {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 3rem;
    width: 100%;
    max-width: 900px;
}

/* ── Brand ── */
.home-brand { text-align: center; }

.home-brand__icon {
    font-size: 4rem;
    display: block;
    margin-bottom: 0.5rem;
    filter: drop-shadow(0 4px 16px rgba(16,185,129,0.45));
}

.home-brand__name {
    font-size: 2.8rem;
    font-weight: 800;
    color: var(--text-primary);
    letter-spacing: -1px;
}

.home-brand__name span { color: var(--green-500); }

.home-brand__tagline {
    margin-top: 0.4rem;
    font-size: 1rem;
    color: var(--text-secondary);
}

/* ── Hero CTA row ── */
.home-cta-row {
    display: flex;
    gap: 1rem;
    flex-wrap: wrap;
    justify-content: center;
}

.home-cta {
    display: inline-flex;
    align-items: center;
    gap: 0.6rem;
    padding: 0.9rem 2rem;
    border-radius: var(--radius);
    font-size: 1.05rem;
    font-weight: 700;
    text-decoration: none;
    transition: transform var(--transition), box-shadow var(--transition), background var(--transition);
    letter-spacing: 0.01em;
}

.home-cta--primary {
    background: var(--green-500);
    color: #fff;
    border: 2px solid var(--green-500);
}

.home-cta--primary:hover {
    background: var(--green-600);
    border-color: var(--green-600);
    color: #fff;
    transform: translateY(-2px);
    box-shadow: 0 8px 24px rgba(16,185,129,0.35);
}

.home-cta--outline {
    background: transparent;
    color: var(--green-500);
    border: 2px solid var(--green-500);
}

.home-cta--outline:hover {
    background: var(--green-500);
    color: #fff;
    transform: translateY(-2px);
    box-shadow: 0 8px 24px rgba(16,185,129,0.25);
}

.home-cta__icon { font-size: 1.2rem; }

/* ── Quick-link action buttons ── */
.home-actions {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 0.9rem;
    width: 100%;
    max-width: 560px;
}

.home-action-btn {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 1rem 1.25rem;
    background: var(--bg-card);
    border: 1.5px solid var(--border);
    border-radius: var(--radius);
    color: var(--text-primary);
    font-weight: 500;
    font-size: 0.95rem;
    text-decoration: none;
    transition: border-color var(--transition), box-shadow var(--transition), transform var(--transition);
}

.home-action-btn:hover {
    border-color: var(--green-500);
    box-shadow: 0 4px 18px rgba(16,185,129,0.18);
    transform: translateY(-2px);
    color: var(--text-primary);
}

.home-action-btn__icon { font-size: 1.35rem; flex-shrink: 0; }

.home-action-btn__label {
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.home-action-btn__badge {
    background: #fff;
    color: var(--green-600);
    border-radius: 999px;
    font-size: 0.7rem;
    font-weight: 700;
    padding: 1px 7px;
    line-height: 1.4;
}

/* ── Feature widgets ── */
.home-features {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 1rem;
    width: 100%;
}

.hf-card {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    padding: 1.8rem 1.5rem;
    border-radius: var(--radius-lg);
    border: 1.5px solid transparent;
    background: var(--bg-card);
    transition: transform var(--transition), box-shadow var(--transition);
    position: relative;
    overflow: hidden;
}

.hf-card::before {
    content: '';
    position: absolute;
    inset: 0;
    opacity: 0.06;
    border-radius: inherit;
}

.hf-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 28px rgba(0,0,0,0.12);
}

.hf-card__icon {
    font-size: 2.2rem;
    line-height: 1;
    width: 3.4rem;
    height: 3.4rem;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: var(--radius-sm);
}

.hf-card__body h3 {
    font-size: 1.05rem;
    font-weight: 700;
    margin-bottom: 0.4rem;
    color: var(--text-primary);
}

.hf-card__body p {
    font-size: 0.88rem;
    color: var(--text-secondary);
    line-height: 1.6;
}

/* Colour variants */
.hf-card--green  { border-color: rgba(16,185,129,0.3); }
.hf-card--green .hf-card__icon  { background: rgba(16,185,129,0.12); }
.hf-card--green::before          { background: #10b981; }

.hf-card--blue   { border-color: rgba(59,130,246,0.3); }
.hf-card--blue .hf-card__icon   { background: rgba(59,130,246,0.12); }
.hf-card--blue::before           { background: #3b82f6; }

.hf-card--purple { border-color: rgba(139,92,246,0.3); }
.hf-card--purple .hf-card__icon { background: rgba(139,92,246,0.12); }
.hf-card--purple::before         { background: #8b5cf6; }

.hf-card--orange { border-color: rgba(249,115,22,0.3); }
.hf-card--orange .hf-card__icon { background: rgba(249,115,22,0.12); }
.hf-card--orange::before         { background: #f97316; }

.hf-card--teal   { border-color: rgba(20,184,166,0.3); }
.hf-card--teal .hf-card__icon   { background: rgba(20,184,166,0.12); }
.hf-card--teal::before           { background: #14b8a6; }

.hf-card--rose   { border-color: rgba(244,63,94,0.3); }
.hf-card--rose .hf-card__icon   { background: rgba(244,63,94,0.12); }
.hf-card--rose::before           { background: #f43f5e; }

/* ── Responsive ── */
@media (max-width: 768px) {
    .home-features { grid-template-columns: repeat(2, 1fr); }
    .home-brand__name { font-size: 2.2rem; }
}

@media (max-width: 480px) {
    .home-brand__name { font-size: 1.8rem; }
    .home-brand__icon { font-size: 3rem; }
    .home-cta { width: 100%; justify-content: center; }
    .home-cta-row { flex-direction: column; align-items: stretch; }
    .home-actions { grid-template-columns: 1fr; }
    .home-features { grid-template-columns: 1fr; }
}
</style>

<jsp:include page="footer.jsp"/>
