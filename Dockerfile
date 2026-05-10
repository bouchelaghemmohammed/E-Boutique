# ─────────────────────────────────────────────────────────────────
# Étape 1 : Build WAR + provision WildFly 30 avec Maven
# Le plugin wildfly-maven-plugin télécharge et provisionne WildFly
# dans target/server/ (voir <provisioning-dir> dans pom.xml)
# ─────────────────────────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

# Cache des dépendances Maven
COPY pom.xml .
RUN mvn dependency:go-offline -q

# Compilation + WAR + WildFly provisionné dans target/server/
COPY src ./src
RUN mvn clean package wildfly:provision -DskipTests -q

# ─────────────────────────────────────────────────────────────────
# Étape 2 : Image runtime JRE 17 léger
# On copie le serveur WildFly provisionné + le WAR compilé
# ─────────────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre-jammy

ENV WILDFLY_HOME=/opt/wildfly

# Copier WildFly provisionné par Maven
COPY --from=build /app/target/server ${WILDFLY_HOME}

# ROOT.war → WildFly déploie à la racine "/" (URL = https://xxx.up.railway.app/)
# Au lieu de /eboutique/ (URL = https://xxx.up.railway.app/eboutique/)
COPY --from=build /app/target/eboutique.war ${WILDFLY_HOME}/standalone/deployments/ROOT.war

RUN chmod +x ${WILDFLY_HOME}/bin/standalone.sh

EXPOSE 8080

# Exec form : pas de shell → pas de eval → le & dans l'URL JDBC ne pose pas de problème
# Les propriétés DB sont injectées via JAVA_TOOL_OPTIONS dans docker-compose.yml
# JAVA_TOOL_OPTIONS est lu directement par la JVM, jamais passé dans eval
CMD ["/opt/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
