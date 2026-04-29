# E-Boutique

Application e-commerce Jakarta EE developpee dans le cadre du cours
**Programmation Web Serveur III** (Hiver 2026).

## Stack technique

| Composant | Version |
|---|---|
| Java | 17 |
| Jakarta EE | 10 |
| Hibernate ORM | 6.4 |
| MySQL | 8.x |
| Serveur d'application | WildFly 30+ |
| Build | Maven (packaging WAR) |

## Prerequis

Avant de commencer, installer :

1. **JDK 17** : https://adoptium.net/
2. **Maven 3.9+** : https://maven.apache.org/download.cgi
3. **MySQL 8** : https://dev.mysql.com/downloads/installer/ (ou XAMPP)
4. **WildFly 30+** : https://www.wildfly.org/downloads/
5. **Git**

Verifier les installations :

```bash
java -version       # doit afficher 17
mvn -version
mysql --version
```

## Equipe et modules

| Dev | Branche | Module | Responsabilites |
|---|---|---|---|
| Mohammed | `mohammed` | Authentification (Dev A) | Inscription, connexion, sessions, cookie remember-me, profil, filtres `AuthFilter` et `RoleFilter`, entites `Utilisateur` et `Role` |
| ? | `?` | Catalogue (Dev B) | Liste publique, recherche, detail, CRUD admin produits, entites `Produit` et `Categorie` |
| Emile | `emile` | Panier &amp; Commande (Dev C) | Panier en session, checkout, envoi email, historique, entites `Commande` et `LigneCommande` |

## Mise en place locale (premiere fois)

### 1. Cloner le projet

```bash
git clone https://github.com/bouchelaghemmohammed/E-Boutique.git
cd E-Boutique
```

### 2. Creer la base de donnees

Lancer MySQL et executer le script :

```bash
mysql -u root -p < src/main/resources/schema.sql
```

Cela cree la base `eboutique` avec les tables et quelques donnees de demo.

### 3. Adapter les identifiants MySQL si besoin

Editer `src/main/resources/META-INF/persistence.xml` :

```xml
<property name="jakarta.persistence.jdbc.user"     value="root"/>
<property name="jakarta.persistence.jdbc.password" value="root"/>
```

### 4. Compiler et packager

```bash
mvn clean package
```

Le fichier WAR est genere dans `target/eboutique.war`.

### 5. Deployer sur WildFly

Demarrer WildFly :

```bash
cd WILDFLY_HOME/bin
./standalone.sh         # Linux/Mac
standalone.bat          # Windows
```

Copier le WAR dans le dossier de deploiement :

```bash
cp target/eboutique.war WILDFLY_HOME/standalone/deployments/
```

### 6. Verifier

Ouvrir http://localhost:8080/eboutique/

Si tout marche, tu vois la page d'accueil avec les 3 modules.

## Workflow Git

```bash
git checkout -b feature/ma-feature   # nouvelle branche depuis sa branche perso
# ... travailler ...
git add .
git commit -m "feat: ajout de X"
git push origin feature/ma-feature
# ouvrir une Pull Request vers main sur GitHub
```

**Regles d'or** :
- Ne **jamais** push directement sur `main` sans PR
- Une feature = une PR
- Une PR doit etre review par au moins un coequipier avant merge
- Toujours `git pull origin main` avant de creer une nouvelle branche

## Structure du projet

```
E-Boutique/
|-- pom.xml                              # config Maven
|-- README.md
|-- .gitignore
|-- src/main/
|   |-- java/com/eboutique/
|   |   |-- modele/                      # entites JPA (a remplir)
|   |   |-- dao/                         # acces donnees
|   |   |-- service/                     # logique metier
|   |   |-- servlet/                     # controleurs (Servlets)
|   |   |   `-- AccueilServlet.java
|   |   |-- filtre/                      # filtres securite
|   |   `-- util/                        # utilitaires
|   |-- resources/
|   |   |-- META-INF/persistence.xml     # config JPA
|   |   `-- schema.sql                   # script DB
|   `-- webapp/
|       |-- index.jsp
|       |-- assets/css/style.css
|       `-- WEB-INF/
|           |-- web.xml                  # config servlets
|           |-- jboss-deployment-structure.xml
|           `-- views/                   # JSP protegees
|               |-- accueil.jsp
|               |-- header.jsp
|               `-- footer.jsp
`-- target/                              # genere par Maven (ignore par Git)
```

## Conventions

### Nommage

- **Classes Java** : `PascalCase` en francais (`Utilisateur`, `Produit`, `LigneCommande`)
- **Attributs / methodes** : `camelCase` en francais (`prenom`, `dateCreation`, `calculerTotal`)
- **Tables SQL** : `snake_case` en francais (`utilisateurs`, `lignes_commande`)
- **Servlets** : suffixe `Servlet` (`PanierServlet`, `LoginServlet`)

### JSP

- **JSP publiques** : dans `webapp/`
- **JSP protegees** : dans `webapp/WEB-INF/views/` (accessibles seulement via Servlet)

## Compte admin par defaut

| Champ | Valeur |
|---|---|
| Courriel | `admin@eboutique.com` |
| Mot de passe | `admin123` |

A regenerer dans le code avec un hash BCrypt frais des qu'on a un endpoint d'inscription
qui fonctionne.

## Commandes Maven utiles

| Commande | Effet |
|---|---|
| `mvn clean compile` | Verifie que le code Java compile |
| `mvn clean package` | Genere `target/eboutique.war` |
| `mvn dependency:tree` | Affiche l'arbre des dependances |
| `mvn clean test` | Lance les tests JUnit |

## Notes WildFly

Le fichier `WEB-INF/jboss-deployment-structure.xml` exclut le module Hibernate
fourni par WildFly pour eviter les conflits avec celui qu'on bundle dans le WAR.

Le driver MySQL doit etre disponible sur WildFly. Si erreur au demarrage,
ajouter le driver via la console de management :

```bash
WILDFLY_HOME/bin/jboss-cli.sh --connect
[standalone@localhost:9990 /] module add --name=com.mysql --resources=mysql-connector-j-8.3.0.jar --dependencies=javax.api,javax.transaction.api
```

Ou plus simple : laisser Hibernate utiliser le driver JDBC bundle dans le WAR
(deja le cas avec la config actuelle en RESOURCE_LOCAL).
