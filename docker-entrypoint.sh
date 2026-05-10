#!/bin/bash
# ─────────────────────────────────────────────────────────────────
# Script de démarrage WildFly
# Injecte les variables d'environnement DB_URL / DB_USER / DB_PASSWORD
# comme propriétés système lues par persistence.xml via ${db.url} etc.
# ─────────────────────────────────────────────────────────────────

# Valeurs par défaut (développement local)
DB_URL="${DB_URL:-jdbc:mysql://localhost:3306/eboutique?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true}"
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-root}"

exec /opt/jboss/wildfly/bin/standalone.sh \
    -b 0.0.0.0 \
    "-Ddb.url=${DB_URL}" \
    "-Ddb.user=${DB_USER}" \
    "-Ddb.password=${DB_PASSWORD}"
