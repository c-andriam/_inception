# 📚 Guide Complet : Infrastructure Web avec Docker
## De zéro à expert en administration système moderne

*Version 1.0 - Juillet 2025*
*Auteur : Guide d'apprentissage structuré*

---

## 📖 Table des matières

1. [Introduction générale](#1-introduction-générale)
2. [🐳 Docker Basics](#2--docker-basics)
3. [📝 YAML et Docker Compose](#3--yaml-et-docker-compose)
4. [🌐 Nginx - Serveur Web](#4--nginx---serveur-web)
5. [💾 MariaDB - Base de données](#5--mariadb---base-de-données)
6. [🎨 WordPress - Application Web](#6--wordpress---application-web)
7. [🔧 Bash - Automatisation](#7--bash---automatisation)
8. [🏗️ Architecture complète](#8-️-architecture-complète)
9. [📚 Annexes et références](#9--annexes-et-références)

---

## 1. Introduction générale

### 🎯 Objectifs de ce guide

Ce guide vous accompagne dans l'apprentissage complet de l'administration système moderne, en vous enseignant à construire une infrastructure web professionnelle de A à Z.

**À la fin de ce parcours, vous saurez :**
- Conteneuriser des applications avec Docker
- Orchestrer des services multiples
- Configurer un serveur web sécurisé
- Administrer une base de données
- Déployer une application web complète
- Automatiser les tâches d'administration
- Concevoir une architecture robuste

### 🛣️ Parcours d'apprentissage

```
Débutant                    Intermédiaire                Expert
    │                           │                          │
    ├─ Docker basics            ├─ Nginx config            ├─ Architecture
    ├─ YAML syntax             ├─ Database admin          ├─ Sécurité
    └─ Concepts base           ├─ WordPress setup         └─ Automatisation
                               └─ Bash scripting
```

### 📋 Prérequis

**Connaissances de base :**
- Utilisation basique de Linux/Unix
- Concepts réseau élémentaires (IP, ports)
- Ligne de commande (terminal)

**Outils nécessaires :**
- Docker et Docker Compose installés
- Éditeur de texte (nano, vim, ou VS Code)
- Terminal/CLI

---

## 2. 🐳 Docker Basics

### 2.1 Concepts fondamentaux

#### Qu'est-ce que Docker ?

Docker est une plateforme de conteneurisation qui permet d'empaqueter une application avec toutes ses dépendances dans un conteneur léger et portable.

**Analogie :** Imaginez Docker comme un système de containers maritimes pour le logiciel :
- **Image** = Blueprint du container
- **Conteneur** = Container en cours d'exécution
- **Registry** = Port où sont stockés les containers
- **Docker Engine** = Le navire qui transporte les containers

#### Architecture Docker

```
┌─────────────────────────────────────────┐
│              Docker Host                │
│  ┌─────────────────────────────────────┐│
│  │         Docker Engine              ││
│  │  ┌───────────┐  ┌───────────┐      ││
│  │  │Container 1│  │Container 2│ ...  ││
│  │  │   App A   │  │   App B   │      ││
│  │  └───────────┘  └───────────┘      ││
│  └─────────────────────────────────────┘│
│  ┌─────────────────────────────────────┐│
│  │           Host OS                   ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

### 2.2 Images Docker

#### Comprendre les images

Une **image Docker** est un template en lecture seule utilisé pour créer des conteneurs.

**Structure en couches :**
```
┌─────────────────┐  ← Votre application (Couche finale)
├─────────────────┤  ← Configuration personnalisée
├─────────────────┤  ← Installation des dépendances
├─────────────────┤  ← Mise à jour du système
└─────────────────┘  ← Image de base (ex: Alpine Linux)
```

#### Commandes essentielles

```bash
# Lister les images locales
docker images

# Télécharger une image
docker pull alpine:3.19

# Supprimer une image
docker rmi image_name

# Inspecter une image
docker inspect alpine:3.19

# Historique des couches
docker history alpine:3.19
```

### 2.3 Dockerfile - Créer ses propres images

#### Structure d'un Dockerfile

```dockerfile
# Dockerfile exemple complet
FROM alpine:3.19

# Métadonnées
LABEL maintainer="votre-email@example.com"
LABEL description="Serveur web Nginx personnalisé"

# Variables d'environnement
ENV NGINX_VERSION=1.24.0
ENV DOCUMENT_ROOT=/var/www/html

# Installation des packages
RUN apk update && \
    apk add --no-cache \
        nginx \
        openssl && \
    rm -rf /var/cache/apk/*

# Création des répertoires
RUN mkdir -p $DOCUMENT_ROOT && \
    mkdir -p /var/log/nginx && \
    mkdir -p /etc/ssl/private

# Copie des fichiers de configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html $DOCUMENT_ROOT/

# Permissions
RUN chown -R nginx:nginx /var/www/html && \
    chmod -R 755 /var/www/html

# Port exposé
EXPOSE 80 443

# Volume pour persistance
VOLUME ["/var/log/nginx"]

# Utilisateur non-root
USER nginx

# Point d'entrée
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
```

#### Instructions Dockerfile détaillées

| Instruction | Utilisation | Exemple |
|-------------|-------------|---------|
| `FROM` | Image de base | `FROM alpine:3.19` |
| `RUN` | Exécuter une commande | `RUN apk add nginx` |
| `COPY` | Copier fichiers locaux | `COPY . /app` |
| `ADD` | Copier + extraction | `ADD archive.tar.gz /app` |
| `WORKDIR` | Répertoire de travail | `WORKDIR /app` |
| `ENV` | Variables d'environnement | `ENV NODE_ENV=production` |
| `EXPOSE` | Port d'écoute | `EXPOSE 80` |
| `VOLUME` | Point de montage | `VOLUME ["/data"]` |
| `USER` | Utilisateur d'exécution | `USER www-data` |
| `ENTRYPOINT` | Point d'entrée fixe | `ENTRYPOINT ["nginx"]` |
| `CMD` | Commande par défaut | `CMD ["-g", "daemon off;"]` |

#### Bonnes pratiques Dockerfile

```dockerfile
# ✅ BONNES PRATIQUES

# 1. Image de base légère
FROM alpine:3.19

# 2. Combiner les RUN pour réduire les couches
RUN apk update && \
    apk add --no-cache nginx && \
    rm -rf /var/cache/apk/*

# 3. Utiliser un utilisateur non-root
RUN adduser -D -s /bin/sh nginx
USER nginx

# 4. Utiliser COPY plutôt qu'ADD quand possible
COPY nginx.conf /etc/nginx/

# 5. Ordonner les instructions par fréquence de changement
# (les moins changeantes en premier)

# ❌ À ÉVITER
# RUN apk update
# RUN apk add nginx
# RUN rm -rf /var/cache/apk/*  # 3 couches au lieu d'une
```

### 2.4 Conteneurs

#### Cycle de vie d'un conteneur

```
Création → Démarrage → Exécution → Arrêt → Suppression
    │         │          │         │         │
 docker    docker     docker    docker   docker
 create     start      exec      stop      rm
```

#### Commandes de gestion des conteneurs

```bash
# Créer et démarrer un conteneur
docker run -d --name mon-nginx -p 8080:80 nginx

# Lister les conteneurs en cours
docker ps

# Lister tous les conteneurs (y compris arrêtés)
docker ps -a

# Exécuter une commande dans un conteneur en cours
docker exec -it mon-nginx /bin/sh

# Voir les logs
docker logs mon-nginx
docker logs -f mon-nginx  # En temps réel

# Arrêter un conteneur
docker stop mon-nginx

# Redémarrer un conteneur
docker restart mon-nginx

# Supprimer un conteneur
docker rm mon-nginx

# Supprimer un conteneur en cours de fonctionnement
docker rm -f mon-nginx
```

#### Options importantes de `docker run`

```bash
# Exécution détachée avec nom
docker run -d --name app nginx

# Mapping de ports (host:container)
docker run -p 8080:80 nginx

# Variables d'environnement
docker run -e "ENV=production" nginx

# Montage de volumes
docker run -v /host/path:/container/path nginx

# Réseau personnalisé
docker run --network mon-reseau nginx

# Limitation des ressources
docker run --memory="256m" --cpus="0.5" nginx

# Redémarrage automatique
docker run --restart unless-stopped nginx
```

### 2.5 Volumes et persistance

#### Types de volumes

```
Host System                    Container
┌─────────────────┐           ┌─────────────────┐
│                 │           │                 │
│ /host/data ────────────────→│ /app/data       │ Bind Mount
│                 │           │                 │
│ Docker Volume ─────────────→│ /var/lib/data   │ Named Volume
│                 │           │                 │
└─────────────────┘           └─────────────────┘
```

#### Exemples pratiques

```bash
# Volume nommé (géré par Docker)
docker volume create mon-volume
docker run -v mon-volume:/data alpine

# Bind mount (dossier host)
docker run -v /home/user/data:/app/data alpine

# Volume temporaire (tmpfs)
docker run --tmpfs /tmp alpine
```

### 2.6 Réseaux Docker

#### Types de réseaux

```bash
# Lister les réseaux
docker network ls

# Créer un réseau personnalisé
docker network create mon-reseau

# Connecter un conteneur à un réseau
docker run --network mon-reseau nginx

# Inspecter un réseau
docker network inspect mon-reseau
```

#### Communication entre conteneurs

```bash
# Créer un réseau
docker network create app-network

# Démarrer une base de données
docker run -d --name db --network app-network mysql

# Démarrer une app qui se connecte à "db"
docker run -d --name app --network app-network \
  -e DB_HOST=db mon-app
```

---

## 3. 📝 YAML et Docker Compose

### 3.1 Syntaxe YAML

#### Concepts de base

YAML (YAML Ain't Markup Language) est un format de sérialisation de données lisible par l'humain.

**Règles fondamentales :**
- Indentation avec des espaces (jamais de tabulations)
- Structure hiérarchique
- Sensible à la casse
- Les commentaires commencent par `#`

#### Structure YAML

```yaml
# Commentaire
# Scalaires (valeurs simples)
nom: "Jean Dupont"
age: 30
actif: true
salaire: 45000.50

# Listes (arrays)
langages:
  - Python
  - JavaScript
  - Go

# Alternative pour les listes
fruits: ["pomme", "banane", "orange"]

# Objets (mappings)
adresse:
  rue: "123 Rue de la Paix"
  ville: "Paris"
  code_postal: 75001

# Listes d'objets
employes:
  - nom: "Alice"
    poste: "Développeur"
    langages:
      - Python
      - JavaScript
  - nom: "Bob"
    poste: "DevOps"
    langages:
      - Docker
      - Kubernetes

# Variables et références
variables: &variables
  env: "production"
  debug: false

application:
  <<: *variables  # Hérite des variables
  nom: "Mon App"
```

#### Types de données avancés

```yaml
# Chaînes multilignes
description: |
  Ceci est une description
  sur plusieurs lignes
  qui préserve les retours à la ligne.

# Chaînes pliées
message: >
  Cette longue phrase
  sera pliée sur une
  seule ligne.

# Valeurs nulles
valeur_nulle: null
valeur_vide: ~

# Booléens (différentes façons)
actif: true
test: yes
debug: on
maintenance: false
production: no
```

### 3.2 Docker Compose - Concepts

#### Qu'est-ce que Docker Compose ?

Docker Compose est un outil pour définir et gérer des applications multi-conteneurs à l'aide d'un fichier YAML.

**Avantages :**
- Configuration déclarative
- Gestion simplifiée de multiple conteneurs
- Réseaux et volumes automatiques
- Environnements reproductibles

#### Structure d'un fichier docker-compose.yml

```yaml
version: '3.8'  # Version du format de fichier

# Définition des services
services:
  service_name:
    # Configuration du service

# Définition des réseaux personnalisés (optionnel)
networks:
  network_name:
    # Configuration du réseau

# Définition des volumes (optionnel)
volumes:
  volume_name:
    # Configuration du volume
```

### 3.3 Configuration des services

#### Service basique

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html
    environment:
      - NGINX_HOST=localhost
      - NGINX_PORT=80
```

#### Service avec build personnalisé

```yaml
services:
  app:
    build:
      context: ./app          # Dossier contenant le Dockerfile
      dockerfile: Dockerfile  # Nom du Dockerfile (optionnel)
      args:                   # Arguments de build
        - NODE_ENV=production
        - API_URL=https://api.example.com
    ports:
      - "3000:3000"
    volumes:
      - ./app:/usr/src/app
      - /usr/src/app/node_modules  # Volume anonyme
    environment:
      - NODE_ENV=production
    restart: unless-stopped
```

#### Configuration avancée d'un service

```yaml
services:
  database:
    image: mariadb:10.6
    container_name: my-database  # Nom fixe du conteneur
    hostname: db-server          # Nom d'hôte dans le réseau
    restart: always              # Politique de redémarrage
    
    # Variables d'environnement
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
    
    # Fichier d'environnement
    env_file:
      - .env
      - .env.local
    
    # Volumes
    volumes:
      - db_data:/var/lib/mysql           # Volume nommé
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql  # Bind mount
      - ./config/my.cnf:/etc/mysql/my.cnf
    
    # Ports (host:container)
    ports:
      - "3306:3306"
    
    # Réseau
    networks:
      - backend
    
    # Vérification de santé
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 20s
      interval: 30s
      retries: 3
      start_period: 60s
    
    # Limitations de ressources
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

### 3.4 Exemple complet - Stack LEMP

```yaml
version: '3.8'

services:
  # Serveur web Nginx
  nginx:
    build:
      context: ./nginx
      dockerfile: Dockerfile
    container_name: nginx-server
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf:/etc/nginx/conf.d
      - ./nginx/ssl:/etc/ssl/nginx
      - wordpress_data:/var/www/html
    depends_on:
      - wordpress
    networks:
      - frontend
      - backend
    restart: unless-stopped

  # Application WordPress
  wordpress:
    build:
      context: ./wordpress
      dockerfile: Dockerfile
    container_name: wordpress-app
    volumes:
      - wordpress_data:/var/www/html
    environment:
      WORDPRESS_DB_HOST: mariadb:3306
      WORDPRESS_DB_NAME: ${DB_NAME}
      WORDPRESS_DB_USER: ${DB_USER}
      WORDPRESS_DB_PASSWORD: ${DB_PASSWORD}
    depends_on:
      mariadb:
        condition: service_healthy
    networks:
      - backend
    restart: unless-stopped

  # Base de données MariaDB
  mariadb:
    build:
      context: ./mariadb
      dockerfile: Dockerfile
    container_name: mariadb-server
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
    volumes:
      - mariadb_data:/var/lib/mysql
      - ./mariadb/conf:/etc/mysql/conf.d
    networks:
      - backend
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 20s
      interval: 30s
      retries: 3
    restart: unless-stopped

# Réseaux
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # Réseau interne uniquement

# Volumes
volumes:
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${PWD}/data/wordpress
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${PWD}/data/mariadb
```

### 3.5 Commandes Docker Compose

#### Commandes essentielles

```bash
# Démarrer tous les services
docker-compose up

# Démarrer en arrière-plan
docker-compose up -d

# Construire les images avant démarrage
docker-compose up --build

# Démarrer un service spécifique
docker-compose up nginx

# Arrêter tous les services
docker-compose down

# Arrêter et supprimer volumes
docker-compose down -v

# Voir l'état des services
docker-compose ps

# Voir les logs
docker-compose logs
docker-compose logs -f nginx  # Logs en temps réel d'un service

# Exécuter une commande dans un service
docker-compose exec nginx /bin/sh

# Construire les images
docker-compose build

# Construire sans cache
docker-compose build --no-cache

# Redémarrer un service
docker-compose restart nginx

# Voir la configuration finale
docker-compose config
```

#### Variables d'environnement

**Fichier .env :**
```bash
# Base de données
DB_NAME=wordpress
DB_USER=wpuser
DB_PASSWORD=secure_password
DB_ROOT_PASSWORD=root_password

# WordPress
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=admin_password
WP_ADMIN_EMAIL=admin@example.com

# Domaine
DOMAIN=monsite.com
```

**Utilisation dans docker-compose.yml :**
```yaml
services:
  app:
    environment:
      - DB_NAME=${DB_NAME}
      - DB_USER=${DB_USER:-defaultuser}  # Valeur par défaut
      - DEBUG=${DEBUG:-false}
```

---

## 4. 🌐 Nginx - Serveur Web

### 4.1 Introduction à Nginx

#### Qu'est-ce que Nginx ?

Nginx (prononcé "engine-x") est un serveur web haute performance qui peut également fonctionner comme :
- **Serveur web** statique
- **Reverse proxy**
- **Load balancer**
- **Serveur de cache**

#### Architecture de Nginx

```
                    Internet
                       │
                       ▼
┌─────────────────────────────────────┐
│           Nginx (Port 80/443)       │
│  ┌─────────┐  ┌─────────┐  ┌──────┐ │
│  │ Worker  │  │ Worker  │  │ ...  │ │
│  │Process 1│  │Process 2│  │      │ │
│  └─────────┘  └─────────┘  └──────┘ │
│           Master Process            │
└─────────────────────────────────────┘
                       │
                       ▼
            ┌─────────────────────┐
            │   Backend Services   │
            │  ┌─────┐  ┌─────┐   │
            │  │App 1│  │App 2│   │
            │  └─────┘  └─────┘   │
            └─────────────────────┘
```

### 4.2 Configuration de base

#### Structure des fichiers de configuration

```
/etc/nginx/
├── nginx.conf              # Configuration principale
├── conf.d/                 # Configurations additionnelles
│   ├── default.conf
│   └── mysite.conf
├── sites-available/        # Sites disponibles
├── sites-enabled/          # Sites activés (symlinks)
└── snippets/              # Fragments réutilisables
```

#### Configuration minimale

```nginx
# /etc/nginx/nginx.conf

# Utilisateur qui exécute nginx
user nginx;

# Nombre de processus worker (auto = nombre de CPU)
worker_processes auto;

# Fichier PID
pid /var/run/nginx.pid;

# Configuration des événements
events {
    worker_connections 1024;    # Connexions par worker
    use epoll;                  # Méthode d'E/O efficace sur Linux
}

# Configuration HTTP
http {
    # Types MIME
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Format des logs
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    # Fichiers de log
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;

    # Optimisations
    sendfile on;                # Transfert de fichiers efficace
    tcp_nopush on;             # Optimise les paquets TCP
    tcp_nodelay on;            # Désactive l'algorithme de Nagle
    keepalive_timeout 65;      # Timeout des connexions persistantes

    # Compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;

    # Inclusion des configurations de sites
    include /etc/nginx/conf.d/*.conf;
}
```

### 4.3 Serveur web statique

#### Configuration basique

```nginx
server {
    listen 80;                              # Port d'écoute
    server_name example.com www.example.com; # Noms de domaine
    root /var/www/html;                     # Répertoire racine
    index index.html index.htm;             # Fichiers d'index

    # Gestion des fichiers statiques
    location / {
        try_files $uri $uri/ =404;
    }

    # Optimisation pour les assets statiques
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|pdf)$ {
        expires 1y;                         # Cache 1 an
        add_header Cache-Control "public, immutable";
        add_header Vary Accept-Encoding;
    }

    # Logs spécifiques
    access_log /var/log/nginx/example.com.access.log;
    error_log /var/log/nginx/example.com.error.log;
}
```

#### Gestion des erreurs personnalisées

```nginx
server {
    listen 80;
    server_name example.com;
    root /var/www/html;

    # Pages d'erreur personnalisées
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;

    location = /404.html {
        internal;
        root /var/www/errors;
    }

    location = /50x.html {
        internal;
        root /var/www/errors;
    }

    # Interdire l'accès aux fichiers sensibles
    location ~ /\.(htaccess|htpasswd|git) {
        deny all;
        return 404;
    }
}
```

### 4.4 SSL/TLS et HTTPS

#### Génération de certificats auto-signés

```bash
# Création du répertoire
mkdir -p /etc/ssl/nginx

# Génération de la clé privée
openssl genrsa -out /etc/ssl/nginx/nginx.key 2048

# Génération du certificat auto-signé
openssl req -new -x509 -key /etc/ssl/nginx/nginx.key \
    -out /etc/ssl/nginx/nginx.crt -days 365 \
    -subj "/C=FR/ST=Paris/L=Paris/O=MonOrg/CN=example.com"

# Permissions sécurisées
chmod 600 /etc/ssl/nginx/nginx.key
chmod 644 /etc/ssl/nginx/nginx.crt
```

#### Configuration HTTPS

```nginx
# Redirection HTTP vers HTTPS
server {
    listen 80;
    server_name example.com www.example.com;
    return 301 https://$server_name$request_uri;
}

# Configuration HTTPS
server {
    listen 443 ssl http2;
    server_name example.com www.example.com;
    root /var/www/html;
    index index.html;

    # Certificats SSL
    ssl_certificate /etc/ssl/nginx/nginx.crt;
    ssl_certificate_key /etc/ssl/nginx/nginx.key;

    # Configuration SSL sécurisée
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Sécurité SSL avancée
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_session_tickets off;

    # OCSP Stapling (pour certificats réels)
    # ssl_stapling on;
    # ssl_stapling_verify on;

    # Headers de sécurité
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options SAMEORIGIN always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

### 4.5 Reverse Proxy

#### Concepts du reverse proxy

```
Client ──────► Nginx (Reverse Proxy) ──────► Backend Server
               (example.com)                  (localhost:3000)
```

#### Configuration PHP-FPM

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    root /var/www/html;
    index index.php index.html;

    # Gestion des fichiers PHP
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        
        # Connexion au service PHP-FPM
        fastcgi_pass wordpress:9000;  # Nom du service Docker
        fastcgi_index index.php;
        
        # Paramètres FastCGI
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        
        # Timeouts
        fastcgi_connect_timeout 60s;
        fastcgi_send_timeout 60s;
        fastcgi_read_timeout 60s;
        
        # Buffers
        fastcgi_buffer_size 128k;
        fastcgi_buffers 4 256k;
        fastcgi_busy_buffers_size 256k;
    }

    # Fichiers statiques (bypass PHP)
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # WordPress configuration
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
}
```

#### Proxy vers application Node.js

```nginx
upstream nodejs_backend {
    server app1:3000;
    server app2:3000;
    server app3:3000;
}

server {
    listen 443 ssl http2;
    server_name api.example.com;

    location / {
        proxy_pass http://nodejs_backend;
        
        # Headers pour le backend
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # Buffers
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
    }

    # WebSocket support
    location /socket.io/ {
        proxy_pass http://nodejs_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
```

### 4.6 Load Balancing

#### Configuration d'équilibrage de charge

```nginx
# Définition du pool de serveurs
upstream backend_pool {
    # Méthodes d'équilibrage :
    # - round-robin (défaut)
    # - least_conn (moins de connexions)
    # - ip_hash (basé sur l'IP client)
    
    least_conn;  # Méthode d'équilibrage
    
    server backend1:8080 weight=3 max_fails=3 fail_timeout=30s;
    server backend2:8080 weight=2 max_fails=3 fail_timeout=30s;
    server backend3:8080 weight=1 max_fails=3 fail_timeout=30s;
    server backend4:8080 backup;  # Serveur de secours
}

server {
    listen 80;
    server_name app.example.com;

    location / {
        proxy_pass http://backend_pool;
        
        # Configuration de santé
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
        proxy_next_upstream_tries 3;
        proxy_next_upstream_timeout 30s;
        
        # Headers standards
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### 4.7 Optimisations et sécurité

#### Configuration de performance

```nginx
http {
    # Optimisations générales
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;  # Masquer la version Nginx

    # Buffers
    client_body_buffer_size 128k;
    client_max_body_size 50M;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 4k;

    # Timeouts
    client_body_timeout 12;
    client_header_timeout 12;
    send_timeout 10;

    # Compression avancée
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/m;
    limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;

    server {
        listen 443 ssl http2;
        server_name example.com;

        # Application du rate limiting
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            proxy_pass http://backend;
        }

        location /login {
            limit_req zone=login burst=5 nodelay;
            proxy_pass http://backend;
        }
    }
}
```

#### Sécurité avancée

```nginx
server {
    listen 443 ssl http2;
    server_name secure.example.com;

    # Restriction géographique (nécessite le module GeoIP)
    # allow country FR;
    # allow country DE;
    # deny all;

    # Restriction par IP
    allow 192.168.1.0/24;
    allow 10.0.0.0/8;
    deny all;

    # Protection contre les attaques
    location / {
        # Anti-DDoS basique
        limit_req zone=api burst=20 nodelay;
        
        # Filtrage des user agents malveillants
        if ($http_user_agent ~* (bot|spider|crawler|wget|curl)) {
            return 403;
        }
        
        # Protection contre les injections
        if ($args ~* (union|select|insert|delete|update|cast|set|declare)) {
            return 403;
        }
        
        proxy_pass http://backend;
    }

    # Authentification HTTP Basic
    location /admin/ {
        auth_basic "Zone Administrateur";
        auth_basic_user_file /etc/nginx/.htpasswd;
        proxy_pass http://backend;
    }
}
```

---

## 5. 💾 MariaDB - Base de données

### 5.1 Introduction aux bases de données relationnelles

#### Concepts fondamentaux

Une **base de données relationnelle** organise les données en **tables** liées entre elles par des **relations**.

**Structure hiérarchique :**
```
Serveur MariaDB
├── Base de données 1
│   ├── Table 1
│   │   ├── Ligne 1 (enregistrement)
│   │   ├── Ligne 2
│   │   └── ...
│   ├── Table 2
│   └── ...
├── Base de données 2
└── ...
```

#### Modèle relationnel exemple

```
Table: utilisateurs                Table: articles
┌────┬──────────┬─────────┐       ┌────┬─────────────┬────────────┬────────────┐
│ id │ nom      │ email   │       │ id │ titre       │ contenu    │ auteur_id  │
├────┼──────────┼─────────┤       ├────┼─────────────┼────────────┼────────────┤
│ 1  │ Alice    │ a@ex.co │       │ 1  │ Mon article │ Contenu... │ 1          │
│ 2  │ Bob      │ b@ex.co │       │ 2  │ Guide SQL   │ Tutorial...│ 2          │
│ 3  │ Charlie  │ c@ex.co │       │ 3  │ Docker tips │ Conseils...│ 1          │
└────┴──────────┴─────────┘       └────┴─────────────┴────────────┴────────────┘
                                         │                                   │
                                         └───────── Relation (FK) ──────────┘
```

### 5.2 Installation et configuration MariaDB

#### Dockerfile pour MariaDB

```dockerfile
FROM alpine:3.19

# Installation de MariaDB
RUN apk update && \
    apk add --no-cache \
        mariadb \
        mariadb-client \
        mariadb-server-utils && \
    rm -rf /var/cache/apk/*

# Création des répertoires
RUN mkdir -p /var/lib/mysql && \
    mkdir -p /var/log/mysql && \
    mkdir -p /run/mysqld

# Configuration des permissions
RUN chown -R mysql:mysql /var/lib/mysql && \
    chown -R mysql:mysql /var/log/mysql && \
    chown -R mysql:mysql /run/mysqld

# Copie de la configuration
COPY conf/my.cnf /etc/my.cnf
COPY tools/init-db.sh /usr/local/bin/

# Permissions d'exécution
RUN chmod +x /usr/local/bin/init-db.sh

# Port MySQL
EXPOSE 3306

# Volume pour les données
VOLUME ["/var/lib/mysql"]

# Utilisateur mysql
USER mysql

# Point d'entrée
ENTRYPOINT ["/usr/local/bin/init-db.sh"]
```

#### Configuration MariaDB (my.cnf)

```ini
# /etc/my.cnf

[client]
port = 3306
socket = /run/mysqld/mysqld.sock
default-character-set = utf8mb4

[mysql]
default-character-set = utf8mb4

[mysqld]
# Configuration de base
user = mysql
port = 3306
socket = /run/mysqld/mysqld.sock
datadir = /var/lib/mysql
tmpdir = /tmp

# Réseau
bind-address = 0.0.0.0  # Accepter toutes les connexions
skip-networking = 0

# Charset et collation
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
init-connect = 'SET NAMES utf8mb4'

# Logs
log-error = /var/log/mysql/error.log
slow-query-log = 1
slow-query-log-file = /var/log/mysql/slow.log
long-query-time = 2

# Performance
max_connections = 100
thread_cache_size = 16
table_open_cache = 2000
query_cache_type = 1
query_cache_size = 32M

# InnoDB (moteur de stockage)
default-storage-engine = InnoDB
innodb_buffer_pool_size = 256M
innodb_log_file_size = 64M
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit = 2

# Sécurité
local-infile = 0
skip-show-database
sql-mode = STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_AUTO_VALUE_ON_ZERO

[mysqldump]
quick
quote-names
max_allowed_packet = 16M
```

#### Script d'initialisation

```bash
#!/bin/sh
# /usr/local/bin/init-db.sh

set -e

# Fonction de log
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Vérifier si la base est déjà initialisée
if [ ! -d "/var/lib/mysql/mysql" ]; then
    log "Initialisation de la base de données..."
    
    # Installation des tables système
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    log "Base de données initialisée"
fi

# Démarrage temporaire pour la configuration
log "Démarrage temporaire de MariaDB..."
mysqld_safe --skip-networking --socket=/run/mysqld/mysqld.sock &
MYSQL_PID=$!

# Attendre que MySQL soit prêt
while ! mysqladmin ping --socket=/run/mysqld/mysqld.sock --silent; do
    sleep 1
done

log "Configuration de la base de données..."

# Configuration sécurisée
mysql --socket=/run/mysqld/mysqld.sock << EOF
-- Suppression des utilisateurs anonymes
DELETE FROM mysql.user WHERE User='';

-- Suppression de la base test
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Configuration du mot de passe root
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');

-- Création de la base de données application
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Création de l'utilisateur application
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

-- Application des privilèges
FLUSH PRIVILEGES;
EOF

log "Configuration terminée"

# Arrêt du processus temporaire
kill $MYSQL_PID
wait $MYSQL_PID

# Démarrage final
log "Démarrage de MariaDB..."
exec mysqld --user=mysql
```

### 5.3 Langage SQL - Les bases

#### Types de données principaux

```sql
-- Types numériques
INT                    -- Entier (-2,147,483,648 à 2,147,483,647)
BIGINT                 -- Grand entier
DECIMAL(10,2)         -- Décimal précis (10 chiffres, 2 décimales)
FLOAT                 -- Nombre flottant
DOUBLE                -- Double précision

-- Types de texte
CHAR(10)              -- Chaîne fixe (10 caractères)
VARCHAR(255)          -- Chaîne variable (max 255)
TEXT                  -- Texte long
LONGTEXT              -- Très long texte

-- Types de date
DATE                  -- Date (YYYY-MM-DD)
TIME                  -- Heure (HH:MM:SS)
DATETIME              -- Date et heure
TIMESTAMP             -- Horodatage (timestamp Unix)

-- Types booléens
BOOLEAN               -- Vrai/Faux (0/1)
TINYINT(1)           -- Alternative pour booléen

-- Types binaires
BLOB                  -- Données binaires
LONGBLOB             -- Grandes données binaires
```

#### Création de base et tables

```sql
-- Création d'une base de données
CREATE DATABASE blog_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Utilisation de la base
USE blog_db;

-- Création de la table utilisateurs
CREATE TABLE utilisateurs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    role ENUM('admin', 'editeur', 'lecteur') DEFAULT 'lecteur',
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    actif BOOLEAN DEFAULT TRUE,
    
    -- Index pour améliorer les performances
    INDEX idx_email (email),
    INDEX idx_role (role)
);

-- Création de la table articles
CREATE TABLE articles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    contenu LONGTEXT NOT NULL,
    resume TEXT,
    auteur_id INT NOT NULL,
    statut ENUM('brouillon', 'publie', 'archive') DEFAULT 'brouillon',
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_publication TIMESTAMP NULL,
    vues INT DEFAULT 0,
    
    -- Clé étrangère vers utilisateurs
    FOREIGN KEY (auteur_id) REFERENCES utilisateurs(id) ON DELETE RESTRICT,
    
    -- Index
    INDEX idx_auteur (auteur_id),
    INDEX idx_statut (statut),
    INDEX idx_date_publication (date_publication),
    FULLTEXT(titre, contenu)  -- Index de recherche textuelle
);

-- Table de liaison pour les catégories (relation many-to-many)
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    couleur VARCHAR(7) DEFAULT '#000000'  -- Code couleur hex
);

CREATE TABLE article_categories (
    article_id INT,
    categorie_id INT,
    PRIMARY KEY (article_id, categorie_id),
    FOREIGN KEY (article_id) REFERENCES articles(id) ON DELETE CASCADE,
    FOREIGN KEY (categorie_id) REFERENCES categories(id) ON DELETE CASCADE
);
```

#### Opérations CRUD (Create, Read, Update, Delete)

**CREATE - Insertion de données :**

```sql
-- Insertion d'utilisateurs
INSERT INTO utilisateurs (nom, email, mot_de_passe, role) VALUES
('Alice Martin', 'alice@example.com', 'hash_password_1', 'admin'),
('Bob Durand', 'bob@example.com', 'hash_password_2', 'editeur'),
('Charlie Moreau', 'charlie@example.com', 'hash_password_3', 'lecteur');

-- Insertion avec sous-requête
INSERT INTO articles (titre, slug, contenu, auteur_id, statut)
SELECT 
    'Mon premier article',
    'mon-premier-article',
    'Contenu de l\'article...',
    id,
    'publie'
FROM utilisateurs 
WHERE email = 'alice@example.com';

-- Insertion multiple
INSERT INTO categories (nom, description) VALUES
('Technologie', 'Articles sur les nouvelles technologies'),
('Lifestyle', 'Articles sur le mode de vie'),
('Tutoriels', 'Guides et tutoriels pratiques');
```

**READ - Lecture de données :**

```sql
-- Sélection simple
SELECT * FROM utilisateurs;

-- Sélection avec colonnes spécifiques
SELECT nom, email, role FROM utilisateurs;

-- Filtrage avec WHERE
SELECT * FROM utilisateurs WHERE role = 'admin';

-- Tri avec ORDER BY
SELECT * FROM articles ORDER BY date_creation DESC;

-- Limitation avec LIMIT
SELECT * FROM articles ORDER BY vues DESC LIMIT 5;

-- Recherche textuelle
SELECT * FROM articles 
WHERE titre LIKE '%docker%' 
   OR contenu LIKE '%conteneur%';

-- Recherche avec MATCH (index FULLTEXT)
SELECT *, MATCH(titre, contenu) AGAINST('docker conteneur') as score
FROM articles 
WHERE MATCH(titre, contenu) AGAINST('docker conteneur')
ORDER BY score DESC;

-- Jointures
SELECT 
    a.titre,
    a.date_creation,
    u.nom as auteur,
    u.email
FROM articles a
JOIN utilisateurs u ON a.auteur_id = u.id
WHERE a.statut = 'publie'
ORDER BY a.date_creation DESC;

-- Jointure avec agrégation
SELECT 
    u.nom,
    COUNT(a.id) as nombre_articles,
    AVG(a.vues) as moyenne_vues
FROM utilisateurs u
LEFT JOIN articles a ON u.id = a.auteur_id
GROUP BY u.id, u.nom
HAVING nombre_articles > 0
ORDER BY nombre_articles DESC;
```

**UPDATE - Modification de données :**

```sql
-- Mise à jour simple
UPDATE utilisateurs 
SET role = 'editeur' 
WHERE email = 'charlie@example.com';

-- Mise à jour multiple
UPDATE articles 
SET vues = vues + 1 
WHERE id = 1;

-- Mise à jour conditionnelle
UPDATE articles 
SET statut = 'archive' 
WHERE date_creation < DATE_SUB(NOW(), INTERVAL 1 YEAR)
  AND vues < 100;

-- Mise à jour avec jointure
UPDATE articles a
JOIN utilisateurs u ON a.auteur_id = u.id
SET a.statut = 'archive'
WHERE u.actif = FALSE;
```

**DELETE - Suppression de données :**

```sql
-- Suppression simple
DELETE FROM articles WHERE statut = 'brouillon';

-- Suppression avec jointure
DELETE a FROM articles a
JOIN utilisateurs u ON a.auteur_id = u.id
WHERE u.actif = FALSE;

-- Suppression avec sauvegarde
CREATE TABLE articles_supprimes AS
SELECT * FROM articles WHERE statut = 'archive';

DELETE FROM articles WHERE statut = 'archive';
```

### 5.4 Requêtes avancées

#### Sous-requêtes

```sql
-- Sous-requête dans WHERE
SELECT * FROM articles 
WHERE auteur_id IN (
    SELECT id FROM utilisateurs WHERE role = 'admin'
);

-- Sous-requête correlée
SELECT u.nom, u.email,
    (SELECT COUNT(*) FROM articles a WHERE a.auteur_id = u.id) as nb_articles
FROM utilisateurs u;

-- EXISTS
SELECT * FROM utilisateurs u
WHERE EXISTS (
    SELECT 1 FROM articles a 
    WHERE a.auteur_id = u.id AND a.statut = 'publie'
);
```

#### Fonctions d'agrégation et GROUP BY

```sql
-- Statistiques de base
SELECT 
    COUNT(*) as total_articles,
    COUNT(DISTINCT auteur_id) as nombre_auteurs,
    AVG(vues) as moyenne_vues,
    MAX(vues) as max_vues,
    MIN(date_creation) as premier_article
FROM articles;

-- Groupement par auteur
SELECT 
    u.nom,
    COUNT(a.id) as nombre_articles,
    SUM(a.vues) as total_vues,
    AVG(a.vues) as moyenne_vues,
    MAX(a.date_creation) as dernier_article
FROM utilisateurs u
LEFT JOIN articles a ON u.id = a.auteur_id
GROUP BY u.id, u.nom
ORDER BY nombre_articles DESC;

-- Groupement par date
SELECT 
    DATE_FORMAT(date_creation, '%Y-%m') as mois,
    COUNT(*) as articles_publies,
    SUM(vues) as vues_totales
FROM articles 
WHERE statut = 'publie'
GROUP BY DATE_FORMAT(date_creation, '%Y-%m')
ORDER BY mois DESC;
```

#### Fonctions de fenêtrage (Window Functions)

```sql
-- Ranking
SELECT 
    titre,
    vues,
    ROW_NUMBER() OVER (ORDER BY vues DESC) as rang,
    RANK() OVER (ORDER BY vues DESC) as rang_avec_egalites,
    DENSE_RANK() OVER (ORDER BY vues DESC) as rang_dense
FROM articles;

-- Partition
SELECT 
    u.nom as auteur,
    a.titre,
    a.vues,
    ROW_NUMBER() OVER (PARTITION BY a.auteur_id ORDER BY a.vues DESC) as rang_auteur,
    SUM(a.vues) OVER (PARTITION BY a.auteur_id) as total_vues_auteur
FROM articles a
JOIN utilisateurs u ON a.auteur_id = u.id;

-- Fonctions d'agrégation mobile
SELECT 
    date_creation,
    vues,
    AVG(vues) OVER (ORDER BY date_creation ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as moyenne_mobile_7j
FROM articles
ORDER BY date_creation;
```

### 5.5 Administration et maintenance

#### Gestion des utilisateurs

```sql
-- Création d'utilisateurs
CREATE USER 'app_user'@'%' IDENTIFIED BY 'secure_password';
CREATE USER 'read_only'@'localhost' IDENTIFIED BY 'readonly_pass';

-- Attribution de privilèges
GRANT ALL PRIVILEGES ON blog_db.* TO 'app_user'@'%';
GRANT SELECT ON blog_db.* TO 'read_only'@'localhost';

-- Privilèges spécifiques
GRANT SELECT, INSERT, UPDATE ON blog_db.articles TO 'editor'@'%';
GRANT SELECT ON blog_db.utilisateurs TO 'editor'@'%';

-- Voir les privilèges
SHOW GRANTS FOR 'app_user'@'%';

-- Révoquer des privilèges
REVOKE INSERT ON blog_db.articles FROM 'editor'@'%';

-- Supprimer un utilisateur
DROP USER 'old_user'@'localhost';

-- Recharger les privilèges
FLUSH PRIVILEGES;
```

#### Sauvegarde et restauration

```bash
# Sauvegarde complète
mysqldump -u root -p blog_db > blog_backup.sql

# Sauvegarde avec structure seulement
mysqldump -u root -p --no-data blog_db > blog_structure.sql

# Sauvegarde avec données seulement
mysqldump -u root -p --no-create-info blog_db > blog_data.sql

# Sauvegarde d'une table spécifique
mysqldump -u root -p blog_db articles > articles_backup.sql

# Restauration
mysql -u root -p blog_db < blog_backup.sql

# Restauration avec création de base
mysql -u root -p -e "CREATE DATABASE blog_db_restore;"
mysql -u root -p blog_db_restore < blog_backup.sql
```

#### Optimisation et maintenance

```sql
-- Analyser les tables
ANALYZE TABLE articles;

-- Optimiser les tables
OPTIMIZE TABLE articles;

-- Réparer une table
REPAIR TABLE articles;

-- Vérifier l'intégrité
CHECK TABLE articles;

-- Statistiques des index
SHOW INDEX FROM articles;

-- Voir les processus en cours
SHOW PROCESSLIST;

-- Voir les variables de configuration
SHOW VARIABLES LIKE 'innodb%';

-- Voir le statut du serveur
SHOW STATUS LIKE 'Threads%';
```

---

## 6. 🎨 WordPress - Application Web

### 6.1 Architecture et concepts WordPress

#### Structure WordPress

```
WordPress Installation
├── wp-admin/              # Interface d'administration
├── wp-includes/           # Fichiers du core WordPress
├── wp-content/            # Contenu personnalisable
│   ├── themes/           # Thèmes
│   ├── plugins/          # Extensions
│   ├── uploads/          # Fichiers médias
│   └── languages/        # Fichiers de traduction
├── wp-config.php         # Configuration principale
├── index.php            # Point d'entrée
├── .htaccess           # Configuration Apache (si applicable)
└── autres fichiers...
```

#### Cycle de vie d'une requête WordPress

```
1. Requête HTTP → index.php
2. Chargement → wp-config.php
3. Initialisation → wp-settings.php
4. Thème → functions.php
5. Requête → WP_Query
6. Template → theme files
7. Réponse HTML → Navigateur
```

### 6.2 Installation manuelle WordPress

#### Dockerfile WordPress

```dockerfile
FROM alpine:3.19

# Installation des dépendances
RUN apk update && \
    apk add --no-cache \
        php82 \
        php82-fpm \
        php82-mysqli \
        php82-json \
        php82-openssl \
        php82-curl \
        php82-zlib \
        php82-xml \
        php82-phar \
        php82-intl \
        php82-dom \
        php82-xmlreader \
        php82-xmlwriter \
        php82-simplexml \
        php82-ctype \
        php82-mbstring \
        php82-gd \
        php82-session \
        php82-fileinfo \
        wget \
        tar && \
    rm -rf /var/cache/apk/*

# Création des liens symboliques pour PHP
RUN ln -sf /usr/bin/php82 /usr/bin/php && \
    ln -sf /usr/sbin/php-fpm82 /usr/sbin/php-fpm

# Installation de WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/wp-cli/v2.8.1/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Configuration des répertoires
RUN mkdir -p /var/www/html && \
    mkdir -p /var/log/php && \
    chown -R www-data:www-data /var/www/html

# Configuration PHP-FPM
COPY conf/php-fpm.conf /etc/php82/php-fpm.conf
COPY conf/www.conf /etc/php82/php-fpm.d/www.conf

# Script d'installation WordPress
COPY tools/install-wordpress.sh /usr/local/bin/
COPY tools/wp-config-template.php /tmp/

RUN chmod +x /usr/local/bin/install-wordpress.sh

# Port PHP-FPM
EXPOSE 9000

# Volume pour WordPress
VOLUME ["/var/www/html"]

# Utilisateur www-data
USER www-data

# Point d'entrée
ENTRYPOINT ["/usr/local/bin/install-wordpress.sh"]
```

#### Configuration PHP-FPM

**Fichier `/etc/php82/php-fpm.conf` :**
```ini
[global]
; PID file
pid = /var/run/php-fpm.pid

; Error log
error_log = /var/log/php/error.log

; Log level
log_level = notice

; Process management
process.max = 128

; Include pool configurations
include=/etc/php82/php-fpm.d/*.conf
```

**Fichier `/etc/php82/php-fpm.d/www.conf` :**
```ini
[www]
; Pool user/group
user = www-data
group = www-data

; Socket listen
listen = 9000
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

; Process management
pm = dynamic
pm.max_children = 20
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
pm.max_requests = 500

; Timeouts
request_terminate_timeout = 60s

; PHP values
php_admin_value[sendmail_path] = /usr/sbin/sendmail -t -i -f www@example.com
php_flag[display_errors] = off
php_admin_value[error_log] = /var/log/php/www-error.log
php_admin_flag[log_errors] = on
php_admin_value[memory_limit] = 256M
php_admin_value[upload_max_filesize] = 50M
php_admin_value[post_max_size] = 50M
php_admin_value[max_execution_time] = 60
php_admin_value[max_input_time] = 60
```

### 6.3 Configuration wp-config.php

#### Template wp-config.php complet

```php
<?php
/**
 * Configuration WordPress pour l'environnement Docker
 */

// =============================================================================
// CONFIGURATION DE LA BASE DE DONNÉES
// =============================================================================

/** Nom de la base de données */
define('DB_NAME', '${MYSQL_DATABASE}');

/** Utilisateur de la base de données */
define('DB_USER', '${MYSQL_USER}');

/** Mot de passe de la base de données */
define('DB_PASSWORD', '${MYSQL_PASSWORD}');

/** Adresse de l'hébergement MySQL */
define('DB_HOST', 'mariadb:3306');

/** Jeu de caractères à utiliser par la base de données lors de la création des tables */
define('DB_CHARSET', 'utf8mb4');

/** Type de collation de la base de données */
define('DB_COLLATE', 'utf8mb4_unicode_ci');

// =============================================================================
// CONFIGURATION DES URLS
// =============================================================================

/** URL de base du site */
define('WP_HOME', '${WP_HOME}');

/** URL de WordPress */
define('WP_SITEURL', '${WP_SITEURL}');

/** URL du contenu (thèmes, plugins, uploads) */
define('WP_CONTENT_URL', '${WP_HOME}/wp-content');

/** Chemin absolu vers le répertoire de contenu */
define('WP_CONTENT_DIR', dirname(__FILE__) . '/wp-content');

// =============================================================================
// CLÉS DE SÉCURITÉ
// =============================================================================

/** Clés d'authentification uniques */
define('AUTH_KEY',         '${WP_AUTH_KEY}');
define('SECURE_AUTH_KEY',  '${WP_SECURE_AUTH_KEY}');
define('LOGGED_IN_KEY',    '${WP_LOGGED_IN_KEY}');
define('NONCE_KEY',        '${WP_NONCE_KEY}');
define('AUTH_SALT',        '${WP_AUTH_SALT}');
define('SECURE_AUTH_SALT', '${WP_SECURE_AUTH_SALT}');
define('LOGGED_IN_SALT',   '${WP_LOGGED_IN_SALT}');
define('NONCE_SALT',       '${WP_NONCE_SALT}');

// =============================================================================
// CONFIGURATION AVANCÉE
// =============================================================================

/** Préfixe de table */
$table_prefix = 'wp_';

/** Mode debug */
define('WP_DEBUG', ${WP_DEBUG:-false});
define('WP_DEBUG_LOG', ${WP_DEBUG_LOG:-false});
define('WP_DEBUG_DISPLAY', ${WP_DEBUG_DISPLAY:-false});

/** Révisions et corbeille */
define('WP_POST_REVISIONS', 3);
define('EMPTY_TRASH_DAYS', 30);

/** Mise à jour automatique */
define('WP_AUTO_UPDATE_CORE', false);
define('DISALLOW_FILE_EDIT', true);
define('DISALLOW_FILE_MODS', false);

/** Configuration des uploads */
define('UPLOADS', 'wp-content/uploads');

/** Configuration mémoire */
define('WP_MEMORY_LIMIT', '256M');
define('WP_MAX_MEMORY_LIMIT', '512M');

/** Configuration cache */
define('WP_CACHE', true);

/** Configuration multisite (si nécessaire) */
// define('WP_ALLOW_MULTISITE', true);

/** Configuration SSL */
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
}

// =============================================================================
// CHEMINS ABSOLUS
// =============================================================================

/** Chemin absolu vers le répertoire de WordPress */
if (!defined('ABSPATH')) {
    define('ABSPATH', dirname(__FILE__) . '/');
}

/** Réglage des variables de WordPress et de ses fichiers inclus */
require_once ABSPATH . 'wp-settings.php';
```

#### Script d'installation WordPress

```bash
#!/bin/sh
# /usr/local/bin/install-wordpress.sh

set -e

# Variables d'environnement avec valeurs par défaut
WP_HOME=${WP_HOME:-"https://localhost"}
WP_SITEURL=${WP_SITEURL:-"https://localhost"}
WP_TITLE=${WP_TITLE:-"Mon Site WordPress"}
WP_ADMIN_USER=${WP_ADMIN_USER:-"admin"}
WP_ADMIN_PASSWORD=${WP_ADMIN_PASSWORD:-"admin123"}
WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL:-"admin@example.com"}
WP_USER=${WP_USER:-"user"}
WP_USER_PASSWORD=${WP_USER_PASSWORD:-"user123"}
WP_USER_EMAIL=${WP_USER_EMAIL:-"user@example.com"}

# Fonction de log
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Fonction pour générer des clés de sécurité
generate_keys() {
    export WP_AUTH_KEY=$(openssl rand -base64 64)
    export WP_SECURE_AUTH_KEY=$(openssl rand -base64 64)
    export WP_LOGGED_IN_KEY=$(openssl rand -base64 64)
    export WP_NONCE_KEY=$(openssl rand -base64 64)
    export WP_AUTH_SALT=$(openssl rand -base64 64)
    export WP_SECURE_AUTH_SALT=$(openssl rand -base64 64)
    export WP_LOGGED_IN_SALT=$(openssl rand -base64 64)
    export WP_NONCE_SALT=$(openssl rand -base64 64)
}

# Attendre que la base de données soit prête
log "Attente de la base de données..."
while ! wp db check --path=/var/www/html --allow-root 2>/dev/null; do
    log "Base de données non accessible, nouvelle tentative dans 5 secondes..."
    sleep 5
done

log "Base de données accessible !"

# Vérifier si WordPress est déjà installé
if [ ! -f "/var/www/html/wp-config.php" ]; then
    log "Installation de WordPress..."
    
    # Télécharger WordPress si pas encore fait
    if [ ! -f "/var/www/html/wp-load.php" ]; then
        log "Téléchargement de WordPress..."
        wp core download --path=/var/www/html --allow-root --locale=fr_FR
    fi
    
    # Générer les clés de sécurité
    log "Génération des clés de sécurité..."
    generate_keys
    
    # Créer wp-config.php à partir du template
    log "Configuration de WordPress..."
    envsubst < /tmp/wp-config-template.php > /var/www/html/wp-config.php
    
    # Installer WordPress
    if ! wp core is-installed --path=/var/www/html --allow-root; then
        log "Installation du core WordPress..."
        wp core install \
            --path=/var/www/html \
            --url="$WP_HOME" \
            --title="$WP_TITLE" \
            --admin_user="$WP_ADMIN_USER" \
            --admin_password="$WP_ADMIN_PASSWORD" \
            --admin_email="$WP_ADMIN_EMAIL" \
            --allow-root
            
        log "WordPress installé avec succès !"
        
        # Créer un utilisateur supplémentaire
        log "Création de l'utilisateur '$WP_USER'..."
        wp user create "$WP_USER" "$WP_USER_EMAIL" \
            --role=author \
            --user_pass="$WP_USER_PASSWORD" \
            --path=/var/www/html \
            --allow-root
            
        log "Utilisateur '$WP_USER' créé avec succès !"
        
        # Configuration supplémentaire
        log "Configuration supplémentaire..."
        
        # Supprimer le contenu par défaut
        wp post delete 1 --force --path=/var/www/html --allow-root  # Hello World
        wp post delete 2 --force --path=/var/www/html --allow-root  # Sample Page
        wp comment delete 1 --force --path=/var/www/html --allow-root  # Hello Comment
        
        # Créer du contenu de base
        wp post create --post_type=page --post_title="Accueil" --post_content="Bienvenue sur notre site !" --post_status=publish --path=/var/www/html --allow-root
        wp post create --post_type=page --post_title="À propos" --post_content="Page à propos de notre site." --post_status=publish --path=/var/www/html --allow-root
        wp post create --post_type=post --post_title="Premier article" --post_content="Ceci est notre premier article de blog." --post_status=publish --path=/var/www/html --allow-root
        
        # Configuration des permaliens
        wp rewrite structure '/%postname%/' --path=/var/www/html --allow-root
        
        # Configuration de la timezone
        wp option update timezone_string 'Europe/Paris' --path=/var/www/html --allow-root
        
        # Configuration de la langue
        wp language core install fr_FR --path=/var/www/html --allow-root
        wp site switch-language fr_FR --path=/var/www/html --allow-root
        
        log "Configuration supplémentaire terminée !"
    fi
else
    log "WordPress déjà installé, vérification de la configuration..."
    
    # Vérifier et mettre à jour les URLs si nécessaire
    CURRENT_HOME=$(wp option get home --path=/var/www/html --allow-root)
    if [ "$CURRENT_HOME" != "$WP_HOME" ]; then
        log "Mise à jour des URLs de $CURRENT_HOME vers $WP_HOME"
        wp option update home "$WP_HOME" --path=/var/www/html --allow-root
        wp option update siteurl "$WP_SITEURL" --path=/var/www/html --allow-root
    fi
fi

# S'assurer des bonnes permissions
log "Configuration des permissions..."
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;
chmod 600 /var/www/html/wp-config.php

log "Démarrage de PHP-FPM..."
exec php-fpm --nodaemonize --fpm-config /etc/php82/php-fpm.conf
```

### 6.4 PHP de base pour WordPress

#### Concepts PHP essentiels

**Variables et types :**
```php
<?php
// Variables (commencent par $)
$nom = "WordPress";
$version = 6.4;
$actif = true;
$utilisateurs = array("Alice", "Bob", "Charlie");

// Tableaux associatifs
$config = array(
    'db_host' => 'localhost',
    'db_name' => 'wordpress',
    'db_user' => 'wp_user'
);

// Syntaxe courte (PHP 5.4+)
$options = [
    'theme' => 'twentytwentyfour',
    'plugins' => ['contact-form', 'seo']
];
?>
```

**Fonctions et classes :**
```php
<?php
// Fonction simple
function saluer($nom) {
    return "Bonjour " . $nom . " !";
}

// Fonction avec paramètres par défaut
function creer_utilisateur($nom, $email, $role = 'subscriber') {
    return [
        'nom' => $nom,
        'email' => $email,
        'role' => $role,
        'date_creation' => date('Y-m-d H:i:s')
    ];
}

// Classe simple
class Article {
    private $titre;
    private $contenu;
    private $auteur;
    
    public function __construct($titre, $contenu, $auteur) {
        $this->titre = $titre;
        $this->contenu = $contenu;
        $this->auteur = $auteur;
    }
    
    public function getTitre() {
        return $this->titre;
    }
    
    public function afficher() {
        echo "<h2>" . $this->titre . "</h2>";
        echo "<p>Par : " . $this->auteur . "</p>";
        echo "<div>" . $this->contenu . "</div>";
    }
}

// Utilisation
$article = new Article("Mon Article", "Contenu de l'article", "Alice");
$article->afficher();
?>
```

#### Interaction avec la base de données

**Connexion PDO :**
```php
<?php
class DatabaseConnection {
    private $pdo;
    
    public function __construct($host, $dbname, $username, $password) {
        try {
            $dsn = "mysql:host=$host;dbname=$dbname;charset=utf8mb4";
            $this->pdo = new PDO($dsn, $username, $password, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false
            ]);
        } catch (PDOException $e) {
            throw new Exception("Connexion échouée : " . $e->getMessage());
        }
    }
    
    public function query($sql, $params = []) {
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt;
    }
    
    public function fetchAll($sql, $params = []) {
        return $this->query($sql, $params)->fetchAll();
    }
    
    public function fetchOne($sql, $params = []) {
        return $this->query($sql, $params)->fetch();
    }
}

// Utilisation
$db = new DatabaseConnection(
    DB_HOST, 
    DB_NAME, 
    DB_USER, 
    DB_PASSWORD
);

// Récupérer tous les articles
$articles = $db->fetchAll("
    SELECT p.*, u.display_name as auteur
    FROM wp_posts p
    JOIN wp_users u ON p.post_author = u.ID
    WHERE p.post_status = 'publish' 
    AND p.post_type = 'post'
    ORDER BY p.post_date DESC
    LIMIT 10
");

foreach ($articles as $article) {
    echo "<h3>" . htmlspecialchars($article['post_title']) . "</h3>";
    echo "<p>Par : " . htmlspecialchars($article['auteur']) . "</p>";
    echo "<div>" . wp_trim_words($article['post_content'], 50) . "</div>";
}
?>
```

#### Hooks WordPress essentiels

**Actions (do_action) :**
```php
<?php
// Dans functions.php du thème

// Hook d'initialisation
add_action('init', function() {
    // Code à exécuter à l'initialisation
    load_theme_textdomain('mon-theme', get_template_directory() . '/languages');
});

// Hook après activation du thème
add_action('after_setup_theme', function() {
    // Support des images à la une
    add_theme_support('post-thumbnails');
    
    // Support des menus
    add_theme_support('menus');
    
    // Enregistrer les menus
    register_nav_menus([
        'primary' => 'Menu Principal',
        'footer' => 'Menu Pied de page'
    ]);
});

// Enqueue des scripts et styles
add_action('wp_enqueue_scripts', function() {
    // Style principal
    wp_enqueue_style(
        'theme-style',
        get_stylesheet_uri(),
        [],
        wp_get_theme()->get('Version')
    );
    
    // JavaScript
    wp_enqueue_script(
        'theme-script',
        get_template_directory_uri() . '/js/main.js',
        ['jquery'],
        wp_get_theme()->get('Version'),
        true
    );
    
    // Localisation pour AJAX
    wp_localize_script('theme-script', 'ajax_object', [
        'ajax_url' => admin_url('admin-ajax.php'),
        'nonce' => wp_create_nonce('ajax_nonce')
    ]);
});

// Hook pour l'admin
add_action('admin_menu', function() {
    add_options_page(
        'Options du Thème',
        'Mon Thème',
        'manage_options',
        'mon-theme-options',
        'afficher_page_options'
    );
});

function afficher_page_options() {
    echo '<div class="wrap">';
    echo '<h1>Options du Thème</h1>';
    echo '<form method="post" action="options.php">';
    settings_fields('mon_theme_options');
    do_settings_sections('mon_theme_options');
    submit_button();
    echo '</form>';
    echo '</div>';
}
?>
```

**Filtres (apply_filters) :**
```php
<?php
// Modifier la longueur des extraits
add_filter('excerpt_length', function($length) {
    return 30; // Limite à 30 mots
});

// Modifier le texte "Lire la suite"
add_filter('excerpt_more', function($more) {
    return ' <a href="' . get_permalink() . '">[Lire la suite...]</a>';
});

// Ajouter des classes CSS au body
add_filter('body_class', function($classes) {
    if (is_home()) {
        $classes[] = 'page-accueil';
    }
    if (is_user_logged_in()) {
        $classes[] = 'utilisateur-connecte';
    }
    return $classes;
});

// Modifier le titre de la page
add_filter('wp_title', function($title, $sep, $seplocation) {
    if (is_home()) {
        return get_bloginfo('name') . ' - ' . get_bloginfo('description');
    }
    return $title;
}, 10, 3);

// Ajouter des métadonnées personnalisées
add_filter('wp_head', function() {
    if (is_singular()) {
        echo '<meta property="og:title" content="' . get_the_title() . '">';
        echo '<meta property="og:description" content="' . get_the_excerpt() . '">';
        if (has_post_thumbnail()) {
            echo '<meta property="og:image" content="' . get_the_post_thumbnail_url() . '">';
        }
    }
});
?>
```

### 6.5 Customisation et thèmes

#### Structure d'un thème WordPress

```
mon-theme/
├── style.css              # Styles principaux + informations du thème
├── index.php             # Template principal
├── functions.php         # Fonctions du thème
├── header.php           # En-tête
├── footer.php           # Pied de page
├── sidebar.php          # Barre latérale
├── single.php           # Article individuel
├── page.php             # Page statique
├── archive.php          # Archives
├── search.php           # Résultats de recherche
├── 404.php              # Page d'erreur 404
├── front-page.php       # Page d'accueil
├── home.php             # Page du blog
├── category.php         # Archive de catégorie
├── tag.php              # Archive de tag
├── author.php           # Archive d'auteur
├── date.php             # Archive de date
├── comments.php         # Commentaires
├── screenshot.png       # Capture d'écran du thème
├── js/                  # Fichiers JavaScript
├── css/                 # Fichiers CSS supplémentaires
├── images/              # Images du thème
└── languages/           # Fichiers de traduction
```

#### Template de base

**style.css :**
```css
/*
Theme Name: Mon Thème Personnalisé
Description: Un thème WordPress personnalisé pour l'apprentissage
Author: Votre Nom
Version: 1.0
Text Domain: mon-theme
*/

/* Reset et base */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    line-height: 1.6;
    color: #333;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
}

/* Header */
.site-header {
    background: #2c3e50;
    color: white;
    padding: 1rem 0;
}

.site-title {
    font-size: 2rem;
    margin: 0;
}

.site-title a {
    color: white;
    text-decoration: none;
}

/* Navigation */
.main-navigation ul {
    list-style: none;
    display: flex;
    gap: 2rem;
}

.main-navigation a {
    color: white;
    text-decoration: none;
    padding: 0.5rem 1rem;
    border-radius: 4px;
    transition: background 0.3s;
}

.main-navigation a:hover {
    background: rgba(255, 255, 255, 0.1);
}

/* Content */
.site-main {
    padding: 2rem 0;
}

.article {
    margin-bottom: 3rem;
    padding-bottom: 2rem;
    border-bottom: 1px solid #eee;
}

.article-title {
    font-size: 1.8rem;
    margin-bottom: 1rem;
}

.article-meta {
    color: #666;
    margin-bottom: 1rem;
    font-size: 0.9rem;
}

.article-content {
    line-height: 1.8;
}

/* Footer */
.site-footer {
    background: #34495e;
    color: white;
    text-align: center;
    padding: 2rem 0;
    margin-top: 3rem;
}
```

**index.php :**
```php
<?php get_header(); ?>

<main class="site-main">
    <div class="container">
        <?php if (have_posts()) : ?>
            <div class="articles-grid">
                <?php while (have_posts()) : the_post(); ?>
                    <article class="article" id="post-<?php the_ID(); ?>">
                        <header class="article-header">
                            <h2 class="article-title">
                                <a href="<?php the_permalink(); ?>">
                                    <?php the_title(); ?>
                                </a>
                            </h2>
                            <div class="article-meta">
                                <span class="article-date">
                                    <?php echo get_the_date(); ?>
                                </span>
                                <span class="article-author">
                                    par <?php the_author(); ?>
                                </span>
                                <span class="article-categories">
                                    dans <?php the_category(', '); ?>
                                </span>
                            </div>
                        </header>
                        
                        <div class="article-content">
                            <?php if (has_post_thumbnail()) : ?>
                                <div class="article-thumbnail">
                                    <a href="<?php the_permalink(); ?>">
                                        <?php the_post_thumbnail('medium'); ?>
                                    </a>
                                </div>
                            <?php endif; ?>
                            
                            <?php the_excerpt(); ?>
                            
                            <a href="<?php the_permalink(); ?>" class="read-more">
                                Lire la suite →
                            </a>
                        </div>
                        
                        <footer class="article-footer">
                            <div class="article-tags">
                                <?php the_tags('Tags: ', ', ', ''); ?>
                            </div>
                        </footer>
                    </article>
                <?php endwhile; ?>
            </div>
            
            <!-- Pagination -->
            <div class="pagination">
                <?php
                the_posts_pagination([
                    'prev_text' => '← Précédent',
                    'next_text' => 'Suivant →',
                ]);
                ?>
            </div>
            
        <?php else : ?>
            <div class="no-posts">
                <h2>Aucun article trouvé</h2>
                <p>Désolé, aucun article ne correspond à votre recherche.</p>
            </div>
        <?php endif; ?>
    </div>
</main>

<?php get_sidebar(); ?>
<?php get_footer(); ?>
```

**header.php :**
```php
<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?php wp_title('|', true, 'right'); ?><?php bloginfo('name'); ?></title>
    
    <?php wp_head(); ?>
</head>

<body <?php body_class(); ?>>
    <?php wp_body_open(); ?>
    
    <header class="site-header">
        <div class="container">
            <div class="header-content">
                <h1 class="site-title">
                    <a href="<?php echo home_url('/'); ?>">
                        <?php bloginfo('name'); ?>
                    </a>
                </h1>
                
                <?php if (get_bloginfo('description')) : ?>
                    <p class="site-description">
                        <?php bloginfo('description'); ?>
                    </p>
                <?php endif; ?>
                
                <nav class="main-navigation">
                    <?php
                    wp_nav_menu([
                        'theme_location' => 'primary',
                        'menu_class' => 'primary-menu',
                        'container' => false,
                        'fallback_cb' => function() {
                            echo '<ul class="primary-menu">';
                            echo '<li><a href="' . home_url('/') . '">Accueil</a></li>';
                            wp_list_pages([
                                'title_li' => '',
                                'depth' => 1
                            ]);
                            echo '</ul>';
                        }
                    ]);
                    ?>
                </nav>
            </div>
        </div>
    </header>
```

**functions.php :**
```php
<?php
/**
 * Fonctions du thème Mon Thème
 */

// Empêcher l'accès direct
if (!defined('ABSPATH')) {
    exit;
}

/**
 * Configuration du thème
 */
function mon_theme_setup() {
    // Support de la traduction
    load_theme_textdomain('mon-theme', get_template_directory() . '/languages');
    
    // Support des flux RSS automatiques
    add_theme_support('automatic-feed-links');
    
    // Support du titre dynamique
    add_theme_support('title-tag');
    
    // Support des images à la une
    add_theme_support('post-thumbnails');
    
    // Tailles d'images personnalisées
    add_image_size('hero-image', 1200, 600, true);
    add_image_size('card-image', 400, 300, true);
    
    // Support des formats d'articles
    add_theme_support('post-formats', [
        'aside', 'gallery', 'link', 'image', 'quote', 'status', 'video', 'audio', 'chat'
    ]);
    
    // Support HTML5
    add_theme_support('html5', [
        'search-form', 'comment-form', 'comment-list', 'gallery', 'caption'
    ]);
    
    // Support de la personnalisation
    add_theme_support('customize-selective-refresh-widgets');
    
    // Enregistrement des menus
    register_nav_menus([
        'primary' => __('Menu Principal', 'mon-theme'),
        'footer' => __('Menu Pied de page', 'mon-theme'),
        'social' => __('Menu Réseaux Sociaux', 'mon-theme')
    ]);
}
add_action('after_setup_theme', 'mon_theme_setup');

/**
 * Enregistrement des widgets
 */
function mon_theme_widgets_init() {
    register_sidebar([
        'name'          => __('Barre latérale', 'mon-theme'),
        'id'            => 'sidebar-1',
        'description'   => __('Widgets de la barre latérale principale', 'mon-theme'),
        'before_widget' => '<section id="%1$s" class="widget %2$s">',
        'after_widget'  => '</section>',
        'before_title'  => '<h3 class="widget-title">',
        'after_title'   => '</h3>',
    ]);
    
    register_sidebar([
        'name'          => __('Pied de page', 'mon-theme'),
        'id'            => 'footer-1',
        'description'   => __('Widgets du pied de page', 'mon-theme'),
        'before_widget' => '<div id="%1$s" class="footer-widget %2$s">',
        'after_widget'  => '</div>',
        'before_title'  => '<h4 class="footer-widget-title">',
        'after_title'   => '</h4>',
    ]);
}
add_action('widgets_init', 'mon_theme_widgets_init');

/**
 * Enqueue des scripts et styles
 */
function mon_theme_scripts() {
    // Style principal
    wp_enqueue_style(
        'mon-theme-style',
        get_stylesheet_uri(),
        [],
        wp_get_theme()->get('Version')
    );
    
    // Google Fonts
    wp_enqueue_style(
        'mon-theme-fonts',
        'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap',
        [],
        null
    );
    
    // JavaScript principal
    wp_enqueue_script(
        'mon-theme-script',
        get_template_directory_uri() . '/js/main.js',
        ['jquery'],
        wp_get_theme()->get('Version'),
        true
    );
    
    // Script pour les commentaires
    if (is_singular() && comments_open() && get_option('thread_comments')) {
        wp_enqueue_script('comment-reply');
    }
    
    // Variables JavaScript
    wp_localize_script('mon-theme-script', 'monTheme', [
        'ajaxUrl' => admin_url('admin-ajax.php'),
        'nonce' => wp_create_nonce('mon_theme_nonce'),
        'strings' => [
            'loading' => __('Chargement...', 'mon-theme'),
            'error' => __('Une erreur est survenue', 'mon-theme')
        ]
    ]);
}
add_action('wp_enqueue_scripts', 'mon_theme_scripts');

/**
 * Personnalisations supplémentaires
 */

// Longueur des extraits
function mon_theme_excerpt_length($length) {
    return 25;
}
add_filter('excerpt_length', 'mon_theme_excerpt_length');

// Texte "Lire la suite"
function mon_theme_excerpt_more($more) {
    return ' <a href="' . get_permalink() . '" class="read-more">' . 
           __('Lire la suite →', 'mon-theme') . '</a>';
}
add_filter('excerpt_more', 'mon_theme_excerpt_more');

// Classes CSS personnalisées pour le body
function mon_theme_body_classes($classes) {
    // Ajouter une classe pour les appareils mobiles
    if (wp_is_mobile()) {
        $classes[] = 'mobile-device';
    }
    
    // Ajouter une classe pour les utilisateurs connectés
    if (is_user_logged_in()) {
        $classes[] = 'logged-in-user';
    }
    
    // Ajouter une classe basée sur le template
    if (is_front_page()) {
        $classes[] = 'front-page-template';
    }
    
    return $classes;
}
add_filter('body_class', 'mon_theme_body_classes');

/**
 * Fonction utilitaire : obtenir l'URL de l'image à la une
 */
function mon_theme_get_featured_image_url($size = 'full') {
    if (has_post_thumbnail()) {
        return get_the_post_thumbnail_url(get_the_ID(), $size);
    }
    return get_template_directory_uri() . '/images/default-featured.jpg';
}

/**
 * Fonction utilitaire : temps de lecture estimé
 */
function mon_theme_reading_time() {
    $content = get_post_field('post_content', get_the_ID());
    $word_count = str_word_count(strip_tags($content));
    $reading_time = ceil($word_count / 200); // 200 mots par minute
    
    if ($reading_time == 1) {
        return '1 minute de lecture';
    } else {
        return $reading_time . ' minutes de lecture';
    }
}

/**
 * AJAX : Chargement d'articles
 */
function mon_theme_load_more_posts() {
    // Vérification du nonce
    if (!wp_verify_nonce($_POST['nonce'], 'mon_theme_nonce')) {
        wp_die('Sécurité : Nonce invalide');
    }
    
    $page = intval($_POST['page']);
    $posts_per_page = 6;
    
    $args = [
        'post_type' => 'post',
        'post_status' => 'publish',
        'posts_per_page' => $posts_per_page,
        'paged' => $page
    ];
    
    $query = new WP_Query($args);
    
    if ($query->have_posts()) {
        while ($query->have_posts()) {
            $query->the_post();
            get_template_part('template-parts/content', 'excerpt');
        }
    }
    
    wp_reset_postdata();
    wp_die();
}
add_action('wp_ajax_load_more_posts', 'mon_theme_load_more_posts');
add_action('wp_ajax_nopriv_load_more_posts', 'mon_theme_load_more_posts');
?>
```

---

## 7. 🔧 Bash - Automatisation

### 7.1 Fondamentaux du scripting Bash

#### Structure d'un script Bash

```bash
#!/bin/bash
# Shebang - indique l'interpréteur à utiliser

# =============================================================================
# SCRIPT: deploy-stack.sh
# DESCRIPTION: Déploie une stack complète Docker pour WordPress
# AUTEUR: Votre nom
# VERSION: 1.0
# DATE: 2025-07-07
# =============================================================================

set -e  # Arrêter le script en cas d'erreur
set -u  # Traiter les variables non définies comme des erreurs
set -o pipefail  # Propager les erreurs dans les pipes

# =============================================================================
# VARIABLES GLOBALES
# =============================================================================

# Couleurs pour les messages
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_NAME="inception"
readonly COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.yml"
readonly ENV_FILE="${SCRIPT_DIR}/.env"

# =============================================================================
# FONCTIONS UTILITAIRES
# =============================================================================

# Fonction de logging
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "INFO")
            echo -e "${GREEN}[${timestamp}] INFO:${NC} $message"
            ;;
        "WARN")
            echo -e "${YELLOW}[${timestamp}] WARN:${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[${timestamp}] ERROR:${NC} $message" >&2
            ;;
        "DEBUG")
            [[ "${DEBUG:-}" == "true" ]] && echo -e "${BLUE}[${timestamp}] DEBUG:${NC} $message"
            ;;
    esac
}

# Fonction pour afficher l'aide
show_help() {
    cat << EOF
Usage: $0 [OPTION]

Déploie et gère une stack WordPress avec Docker

OPTIONS:
    -h, --help          Afficher cette aide
    -d, --deploy        Déployer la stack
    -s, --stop          Arrêter la stack
    -r, --restart       Redémarrer la stack
    -c, --clean         Nettoyer (supprimer containers et volumes)
    -l, --logs          Afficher les logs
    -t, --test          Tester la connectivité
    -b, --backup        Sauvegarder les données
    --debug             Mode debug

EXAMPLES:
    $0 --deploy         # Déployer la stack
    $0 --logs nginx     # Voir les logs de nginx
    $0 --backup         # Créer une sauvegarde

EOF
}

# Vérification des prérequis
check_prerequisites() {
    log "INFO" "Vérification des prérequis..."
    
    local missing_tools=()
    
    # Vérifier Docker
    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    fi
    
    # Vérifier Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        missing_tools+=("docker-compose")
    fi
    
    # Vérifier les fichiers nécessaires
    if [[ ! -f "$COMPOSE_FILE" ]]; then
        log "ERROR" "Fichier docker-compose.yml non trouvé : $COMPOSE_FILE"
        exit 1
    fi
    
    if [[ ! -f "$ENV_FILE" ]]; then
        log "WARN" "Fichier .env non trouvé, création d'un fichier par défaut..."
        create_default_env
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log "ERROR" "Outils manquants : ${missing_tools[*]}"
        log "ERROR" "Veuillez installer ces outils avant de continuer"
        exit 1
    fi
    
    log "INFO" "Tous les prérequis sont satisfaits ✓"
}
```

#### Variables et paramètres

```bash
#!/bin/bash

# =============================================================================
# VARIABLES ET TYPES
# =============================================================================

# Variables simples
nom="WordPress"
version="6.4"
port=443

# Variables en lecture seule
readonly DOMAIN="example.com"
readonly MAX_RETRIES=5

# Variables d'environnement avec valeurs par défaut
DB_HOST="${DB_HOST:-mariadb}"
DB_PORT="${DB_PORT:-3306}"
DEBUG="${DEBUG:-false}"

# Tableaux
services=("nginx" "wordpress" "mariadb")
ports=(80 443 3306)

# Tableaux associatifs (Bash 4+)
declare -A config
config[db_host]="mariadb"
config[db_port]="3306"
config[db_name]="wordpress"

# =============================================================================
# PARAMÈTRES DE LIGNE DE COMMANDE
# =============================================================================

# Variables pour les options
DEPLOY=false
STOP=false
RESTART=false
CLEAN=false
SHOW_LOGS=false
SERVICE_NAME=""
BACKUP=false
DEBUG=false

# Traitement des paramètres
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|--deploy)
            DEPLOY=true
            shift
            ;;
        -s|--stop)
            STOP=true
            shift
            ;;
        -r|--restart)
            RESTART=true
            shift
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -l|--logs)
            SHOW_LOGS=true
            if [[ -n "${2:-}" && "${2:0:1}" != "-" ]]; then
                SERVICE_NAME="$2"
                shift
            fi
            shift
            ;;
        -t|--test)
            TEST=true
            shift
            ;;
        -b|--backup)
            BACKUP=true
            shift
            ;;
        --debug)
            DEBUG=true
            set -x  # Mode trace
            shift
            ;;
        -*)
            log "ERROR" "Option inconnue : $1"
            show_help
            exit 1
            ;;
        *)
            log "ERROR" "Paramètre inattendu : $1"
            show_help
            exit 1
            ;;
    esac
done

# =============================================================================
# VALIDATION DES PARAMÈTRES
# =============================================================================

validate_parameters() {
    local action_count=0
    
    # Compter les actions demandées
    [[ "$DEPLOY" == "true" ]] && ((action_count++))
    [[ "$STOP" == "true" ]] && ((action_count++))
    [[ "$RESTART" == "true" ]] && ((action_count++))
    [[ "$CLEAN" == "true" ]] && ((action_count++))
    [[ "$SHOW_LOGS" == "true" ]] && ((action_count++))
    [[ "$BACKUP" == "true" ]] && ((action_count++))
    [[ "$TEST" == "true" ]] && ((action_count++))
    
    if [[ $action_count -eq 0 ]]; then
        log "ERROR" "Aucune action spécifiée"
        show_help
        exit 1
    fi
    
    if [[ $action_count -gt 1 ]]; then
        log "ERROR" "Une seule action peut être spécifiée à la fois"
        exit 1
    fi
}
```

### 7.2 Conditions et boucles

#### Structures conditionnelles

```bash
#!/bin/bash

# =============================================================================
# CONDITIONS SIMPLES
# =============================================================================

# Test de fichier
check_file() {
    local file="$1"
    
    if [[ -f "$file" ]]; then
        log "INFO" "Fichier trouvé : $file"
        return 0
    elif [[ -d "$file" ]]; then
        log "WARN" "$file est un répertoire, pas un fichier"
        return 1
    else
        log "ERROR" "Fichier non trouvé : $file"
        return 1
    fi
}

# Test de service Docker
check_service_status() {
    local service="$1"
    
    if docker-compose ps "$service" | grep -q "Up"; then
        log "INFO" "Service $service est en cours d'exécution"
        return 0
    else
        log "WARN" "Service $service n'est pas en cours d'exécution"
        return 1
    fi
}

# Conditions multiples
validate_environment() {
    local errors=0
    
    # Vérifier les variables requises
    if [[ -z "${MYSQL_DATABASE:-}" ]]; then
        log "ERROR" "Variable MYSQL_DATABASE non définie"
        ((errors++))
    fi
    
    if [[ -z "${MYSQL_USER:-}" ]]; then
        log "ERROR" "Variable MYSQL_USER non définie"
        ((errors++))
    fi
    
    if [[ -z "${MYSQL_PASSWORD:-}" ]]; then
        log "ERROR" "Variable MYSQL_PASSWORD non définie"
        ((errors++))
    fi
    
    # Vérifier la longueur du mot de passe
    if [[ -n "${MYSQL_PASSWORD:-}" ]] && [[ ${#MYSQL_PASSWORD} -lt 8 ]]; then
        log "ERROR" "Le mot de passe doit contenir au moins 8 caractères"
        ((errors++))
    fi
    
    # Vérifier le format de l'email
    if [[ -n "${WP_ADMIN_EMAIL:-}" ]]; then
        if [[ ! "$WP_ADMIN_EMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            log "ERROR" "Format d'email invalide : $WP_ADMIN_EMAIL"
            ((errors++))
        fi
    fi
    
    if [[ $errors -gt 0 ]]; then
        log "ERROR" "$errors erreur(s) de validation détectée(s)"
        return 1
    fi
    
    log "INFO" "Validation de l'environnement réussie"
    return 0
}

# =============================================================================
# CONDITIONS AVANCÉES
# =============================================================================

# Test avec case
handle_action() {
    local action="$1"
    
    case "$action" in
        "deploy"|"start")
            deploy_stack
            ;;
        "stop"|"down")
            stop_stack
            ;;
        "restart"|"reload")
            restart_stack
            ;;
        "clean"|"purge")
            if confirm_action "Êtes-vous sûr de vouloir supprimer tous les données ?"; then
                clean_stack
            else
                log "INFO" "Nettoyage annulé"
            fi
            ;;
        "backup"|"save")
            create_backup
            ;;
        "test"|"check")
            run_tests
            ;;
        *)
            log "ERROR" "Action inconnue : $action"
            return 1
            ;;
    esac
}

# Confirmation interactive
confirm_action() {
    local message="$1"
    local response
    
    echo -n "$message [y/N]: "
    read -r response
    
    case "$response" in
        [yY]|[yY][eE][sS])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
```

#### Boucles

```bash
#!/bin/bash

# =============================================================================
# BOUCLES FOR
# =============================================================================

# Boucle sur un tableau
deploy_services() {
    local services=("mariadb" "wordpress" "nginx")
    
    log "INFO" "Déploiement des services..."
    
    for service in "${services[@]}"; do
        log "INFO" "Démarrage du service : $service"
        
        if docker-compose up -d "$service"; then
            log "INFO" "Service $service démarré avec succès"
        else
            log "ERROR" "Échec du démarrage du service $service"
            return 1
        fi
        
        # Attendre que le service soit prêt
        wait_for_service "$service"
    done
    
    log "INFO" "Tous les services sont démarrés"
}

# Boucle sur des fichiers
backup_configurations() {
    local backup_dir="./backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    log "INFO" "Sauvegarde des configurations dans $backup_dir"
    
    # Boucle sur les fichiers de configuration
    for config_file in nginx/conf/* mariadb/conf/* wordpress/conf/*; do
        if [[ -f "$config_file" ]]; then
            local dest="$backup_dir/$(basename "$config_file")"
            cp "$config_file" "$dest"
            log "DEBUG" "Sauvegardé : $config_file -> $dest"
        fi
    done
}

# Boucle numérique
wait_for_service() {
    local service="$1"
    local max_attempts=30
    local attempt=1
    
    log "INFO" "Attente du service $service..."
    
    for ((attempt=1; attempt<=max_attempts; attempt++)); do
        if check_service_health "$service"; then
            log "INFO" "Service $service prêt après ${attempt}s"
            return 0
        fi
        
        if [[ $attempt -lt $max_attempts ]]; then
            log "DEBUG" "Tentative $attempt/$max_attempts - En attente..."
            sleep 1
        fi
    done
    
    log "ERROR" "Timeout : le service $service n'est pas prêt après ${max_attempts}s"
    return 1
}

# =============================================================================
# BOUCLES WHILE
# =============================================================================

# Attente avec condition
wait_for_database() {
    local host="$1"
    local port="$2"
    local timeout="${3:-60}"
    local elapsed=0
    
    log "INFO" "Attente de la base de données sur $host:$port"
    
    while ! nc -z "$host" "$port" 2>/dev/null; do
        if [[ $elapsed -ge $timeout ]]; then
            log "ERROR" "Timeout : impossible de se connecter à $host:$port"
            return 1
        fi
        
        log "DEBUG" "Base de données non accessible, nouvelle tentative dans 2s..."
        sleep 2
        ((elapsed += 2))
    done
    
    log "INFO" "Base de données accessible sur $host:$port"
    return 0
}

# Lecture de fichier ligne par ligne
process_env_file() {
    local env_file="$1"
    
    if [[ ! -f "$env_file" ]]; then
        log "ERROR" "Fichier d'environnement non trouvé : $env_file"
        return 1
    fi
    
    log "INFO" "Traitement du fichier d'environnement : $env_file"
    
    while IFS='=' read -r key value; do
        # Ignorer les commentaires et lignes vides
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Supprimer les espaces
        key=$(echo "$key" | tr -d '[:space:]')
        value=$(echo "$value" | tr -d '[:space:]')
        
        # Exporter la variable
        export "$key"="$value"
        log "DEBUG" "Variable exportée : $key"
        
    done < "$env_file"
}

# =============================================================================
# BOUCLES UNTIL
# =============================================================================

# Attente jusqu'à condition
wait_until_healthy() {
    local service="$1"
    local max_wait="${2:-300}"  # 5 minutes par défaut
    local start_time=$(date +%s)
    
    log "INFO" "Attente que $service soit en bonne santé..."
    
    until check_service_health "$service"; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [[ $elapsed -ge $max_wait ]]; then
            log "ERROR" "Timeout : $service n'est pas en bonne santé après ${max_wait}s"
            return 1
        fi
        
        log "DEBUG" "Service $service pas encore prêt (${elapsed}s écoulées)"
        sleep 5
    done
    
    log "INFO" "Service $service est en bonne santé"
    return 0
}
```

### 7.3 Fonctions et gestion d'erreurs

#### Fonctions avancées

```bash
#!/bin/bash

# =============================================================================
# FONCTIONS DE DÉPLOIEMENT
# =============================================================================

# Fonction principale de déploiement
deploy_stack() {
    log "INFO" "Début du déploiement de la stack $PROJECT_NAME"
    
    # Étapes de déploiement
    local steps=(
        "validate_environment"
        "create_networks"
        "create_volumes"
        "deploy_database"
        "deploy_wordpress"
        "deploy_nginx"
        "verify_deployment"
    )
    
    local total_steps=${#steps[@]}
    local current_step=1
    
    for step in "${steps[@]}"; do
        log "INFO" "Étape $current_step/$total_steps : $step"
        
        if ! "$step"; then
            log "ERROR" "Échec de l'étape : $step"
            rollback_deployment
            return 1
        fi
        
        ((current_step++))
    done
    
    log "INFO" "Déploiement terminé avec succès !"
    show_deployment_info
}

# Fonction de création des réseaux
create_networks() {
    local networks=("frontend" "backend")
    
    for network in "${networks[@]}"; do
        if docker network ls | grep -q "${PROJECT_NAME}_${network}"; then
            log "DEBUG" "Réseau ${PROJECT_NAME}_${network} existe déjà"
        else
            log "INFO" "Création du réseau : ${PROJECT_NAME}_${network}"
            docker network create "${PROJECT_NAME}_${network}" || {
                log "ERROR" "Impossible de créer le réseau ${network}"
                return 1
            }
        fi
    done
    
    return 0
}

# Fonction de création des volumes
create_volumes() {
    local volumes=(
        "wordpress_data:/home/$(whoami)/data/wordpress"
        "mariadb_data:/home/$(whoami)/data/mariadb"
    )
    
    for volume_mapping in "${volumes[@]}"; do
        local volume_name="${volume_mapping%%:*}"
        local host_path="${volume_mapping##*:}"
        
        # Créer le répertoire hôte
        if [[ ! -d "$host_path" ]]; then
            log "INFO" "Création du répertoire : $host_path"
            mkdir -p "$host_path" || {
                log "ERROR" "Impossible de créer le répertoire $host_path"
                return 1
            }
        fi
        
        # Vérifier/créer le volume Docker
        if docker volume ls | grep -q "${PROJECT_NAME}_${volume_name}"; then
            log "DEBUG" "Volume ${PROJECT_NAME}_${volume_name} existe déjà"
        else
            log "INFO" "Création du volume : ${PROJECT_NAME}_${volume_name}"
            docker volume create "${PROJECT_NAME}_${volume_name}" || {
                log "ERROR" "Impossible de créer le volume ${volume_name}"
                return 1
            }
        fi
    done
    
    return 0
}

# Fonction de déploiement de la base de données
deploy_database() {
    log "INFO" "Déploiement de MariaDB..."
    
    # Construire l'image
    if ! docker-compose build mariadb; then
        log "ERROR" "Échec de la construction de l'image MariaDB"
        return 1
    fi
    
    # Démarrer le service
    if ! docker-compose up -d mariadb; then
        log "ERROR" "Échec du démarrage de MariaDB"
        return 1
    fi
    
    # Attendre que la base soit prête
    if ! wait_for_database "localhost" "3306" 120; then
        log "ERROR" "MariaDB n'est pas accessible"
        return 1
    fi
    
    # Vérifier la connectivité
    if ! test_database_connection; then
        log "ERROR" "Test de connexion à la base échoué"
        return 1
    fi
    
    log "INFO" "MariaDB déployée avec succès"
    return 0
}

# =============================================================================
# FONCTIONS DE TEST
# =============================================================================

# Test de connexion à la base de données
test_database_connection() {
    log "INFO" "Test de connexion à la base de données..."
    
    local max_attempts=10
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if docker-compose exec -T mariadb mysql \
            -h localhost \
            -u "$MYSQL_USER" \
            -p"$MYSQL_PASSWORD" \
            -e "SELECT 1;" "$MYSQL_DATABASE" &>/dev/null; then
            log "INFO" "Connexion à la base réussie"
            return 0
        fi
        
        log "DEBUG" "Tentative de connexion $attempt/$max_attempts échouée"
        sleep 3
        ((attempt++))
    done
    
    log "ERROR" "Impossible de se connecter à la base après $max_attempts tentatives"
    return 1
}

# Test de santé des services
check_service_health() {
    local service="$1"
    
    case "$service" in
        "mariadb")
            docker-compose exec -T mariadb mysqladmin ping -h localhost --silent
            ;;
        "wordpress")
            docker-compose exec -T wordpress php-fpm82 -t &>/dev/null
            ;;
        "nginx")
            docker-compose exec -T nginx nginx -t &>/dev/null
            ;;
        *)
            log "ERROR" "Service inconnu pour le test de santé : $service"
            return 1
            ;;
    esac
}

# Tests de connectivité HTTP
test_http_connectivity() {
    local urls=(
        "https://localhost"
        "https://localhost/wp-admin"
    )
    
    log "INFO" "Test de connectivité HTTP..."
    
    for url in "${urls[@]}"; do
        log "DEBUG" "Test de $url"
        
        local response_code
        response_code=$(curl -s -k -o /dev/null -w "%{http_code}" "$url" || echo "000")
        
        case "$response_code" in
            "200"|"301"|"302")
                log "INFO" "✓ $url - Réponse : $response_code"
                ;;
            "000")
                log "ERROR" "✗ $url - Pas de réponse"
                return 1
                ;;
            *)
                log "WARN" "⚠ $url - Réponse inattendue : $response_code"
                ;;
        esac
    done
    
    return 0
}

# =============================================================================
# GESTION D'ERREURS ET ROLLBACK
# =============================================================================

# Fonction de rollback
rollback_deployment() {
    log "WARN" "Début du rollback..."
    
    # Arrêter tous les services
    log "INFO" "Arrêt des services..."
    docker-compose down || log "WARN" "Erreur lors de l'arrêt des services"
    
    # Nettoyer les réseaux créés
    log "INFO" "Nettoyage des réseaux..."
    local networks=("frontend" "backend")
    for network in "${networks[@]}"; do
        if docker network ls | grep -q "${PROJECT_NAME}_${network}"; then
            docker network rm "${PROJECT_NAME}_${network}" 2>/dev/null || true
        fi
    done
    
    log "WARN" "Rollback terminé"
}

# Gestionnaire de signaux
cleanup() {
    local exit_code=$?
    
    log "INFO" "Nettoyage en cours..."
    
    # Arrêter les processus en arrière-plan
    jobs -p | xargs -r kill 2>/dev/null || true
    
    # Nettoyer les fichiers temporaires
    [[ -n "${TEMP_DIR:-}" ]] && rm -rf "$TEMP_DIR"
    
    if [[ $exit_code -ne 0 ]]; then
        log "ERROR" "Script terminé avec une erreur (code: $exit_code)"
    else
        log "INFO" "Script terminé avec succès"
    fi
    
    exit $exit_code
}

# Capture des signaux
trap cleanup EXIT
trap 'log "ERROR" "Script interrompu par l'\''utilisateur"; exit 130' INT TERM

# =============================================================================
# FONCTIONS UTILITAIRES
# =============================================================================

# Fonction de retry
retry() {
    local max_attempts="$1"
    shift
    local command="$*"
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        log "DEBUG" "Tentative $attempt/$max_attempts : $command"
        
        if eval "$command"; then
            return 0
        fi
        
        if [[ $attempt -lt $max_attempts ]]; then
            local wait_time=$((attempt * 2))
            log "DEBUG" "Échec, nouvelle tentative dans ${wait_time}s..."
            sleep $wait_time
        fi
        
        ((attempt++))
    done
    
    log "ERROR" "Commande échouée après $max_attempts tentatives : $command"
    return 1
}

# Fonction de mesure de temps
time_function() {
    local func_name="$1"
    shift
    local start_time=$(date +%s.%N)
    
    log "DEBUG" "Début de $func_name"
    
    if "$func_name" "$@"; then
        local end_time=$(date +%s.%N)
                local duration=$(echo "$end_time - $start_time" | bc -l)
        log "INFO" "$func_name terminé en ${duration}s"
        return 0
    else
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc -l)
        log "ERROR" "$func_name échoué après ${duration}s"
        return 1
    fi
}

# Fonction de création de fichier .env par défaut
create_default_env() {
    local env_file="$1"
    
    log "INFO" "Création du fichier .env par défaut : $env_file"
    
    cat > "$env_file" << 'EOF'
# =============================================================================
# CONFIGURATION DE LA BASE DE DONNÉES
# =============================================================================
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=secure_wp_password_123
MYSQL_ROOT_PASSWORD=secure_root_password_123

# =============================================================================
# CONFIGURATION WORDPRESS
# =============================================================================
WP_HOME=https://c-andriam.42.fr
WP_SITEURL=https://c-andriam.42.fr
WP_TITLE=Inception WordPress
WP_ADMIN_USER=c-andriam
WP_ADMIN_PASSWORD=admin_password_123
WP_ADMIN_EMAIL=c-andriam@student.42.fr
WP_USER=visitor
WP_USER_PASSWORD=visitor_password_123
WP_USER_EMAIL=visitor@example.com

# =============================================================================
# CONFIGURATION DEBUG
# =============================================================================
WP_DEBUG=false
WP_DEBUG_LOG=false
WP_DEBUG_DISPLAY=false

# =============================================================================
# CONFIGURATION SYSTÈME
# =============================================================================
DOMAIN=c-andriam.42.fr
USER_ID=1000
GROUP_ID=1000
EOF
    
    log "INFO" "Fichier .env créé avec des valeurs par défaut"
    log "WARN" "IMPORTANT: Modifiez les mots de passe avant le déploiement !"
}
```

### 7.4 Scripts de maintenance et monitoring

#### Script de sauvegarde

```bash
#!/bin/bash
# backup-system.sh - Script de sauvegarde automatisée

set -euo pipefail

# =============================================================================
# CONFIGURATION DE SAUVEGARDE
# =============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BACKUP_BASE_DIR="/home/c-andriam/backups"
readonly RETENTION_DAYS=30
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly BACKUP_DIR="$BACKUP_BASE_DIR/$TIMESTAMP"

# Couleurs
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# =============================================================================
# FONCTIONS DE LOGGING
# =============================================================================

log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "INFO")  echo -e "${GREEN}[${timestamp}] INFO:${NC} $message" ;;
        "WARN")  echo -e "${YELLOW}[${timestamp}] WARN:${NC} $message" ;;
        "ERROR") echo -e "${RED}[${timestamp}] ERROR:${NC} $message" >&2 ;;
    esac
    
    # Log vers fichier
    echo "[${timestamp}] $level: $message" >> "$BACKUP_DIR/backup.log"
}

# =============================================================================
# FONCTIONS DE SAUVEGARDE
# =============================================================================

# Créer la structure de sauvegarde
create_backup_structure() {
    log "INFO" "Création de la structure de sauvegarde..."
    
    mkdir -p "$BACKUP_DIR"/{database,wordpress,configs,logs}
    
    # Fichier de métadonnées
    cat > "$BACKUP_DIR/backup_info.txt" << EOF
Sauvegarde créée le: $(date)
Utilisateur: $(whoami)
Hostname: $(hostname)
Version Docker: $(docker --version)
Version Docker Compose: $(docker-compose --version)
Répertoire source: $SCRIPT_DIR
EOF
    
    log "INFO" "Structure créée dans : $BACKUP_DIR"
}

# Sauvegarde de la base de données
backup_database() {
    log "INFO" "Sauvegarde de la base de données..."
    
    local db_backup_file="$BACKUP_DIR/database/wordpress_$(date +%Y%m%d_%H%M%S).sql"
    
    # Vérifier si MariaDB est en cours d'exécution
    if ! docker-compose ps mariadb | grep -q "Up"; then
        log "ERROR" "MariaDB n'est pas en cours d'exécution"
        return 1
    fi
    
    # Sauvegarde avec mysqldump
    if docker-compose exec -T mariadb mysqldump \
        -u root \
        -p"$MYSQL_ROOT_PASSWORD" \
        --single-transaction \
        --routines \
        --triggers \
        --all-databases > "$db_backup_file"; then
        
        # Compression de la sauvegarde
        gzip "$db_backup_file"
        local compressed_file="${db_backup_file}.gz"
        local size=$(du -h "$compressed_file" | cut -f1)
        
        log "INFO" "Base de données sauvegardée : $compressed_file ($size)"
        
        # Vérification de l'intégrité
        if gunzip -t "$compressed_file"; then
            log "INFO" "Intégrité de la sauvegarde vérifiée"
        else
            log "ERROR" "Erreur d'intégrité de la sauvegarde"
            return 1
        fi
    else
        log "ERROR" "Échec de la sauvegarde de la base de données"
        return 1
    fi
}

# Sauvegarde des fichiers WordPress
backup_wordpress_files() {
    log "INFO" "Sauvegarde des fichiers WordPress..."
    
    local wp_data_dir="/home/c-andriam/data/wordpress"
    local wp_backup_file="$BACKUP_DIR/wordpress/wordpress_files_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    if [[ ! -d "$wp_data_dir" ]]; then
        log "WARN" "Répertoire WordPress non trouvé : $wp_data_dir"
        return 1
    fi
    
    # Créer l'archive tar avec compression
    if tar -czf "$wp_backup_file" \
        -C "$(dirname "$wp_data_dir")" \
        "$(basename "$wp_data_dir")" \
        --exclude='*.log' \
        --exclude='cache/*' \
        --exclude='*.tmp'; then
        
        local size=$(du -h "$wp_backup_file" | cut -f1)
        log "INFO" "Fichiers WordPress sauvegardés : $wp_backup_file ($size)"
    else
        log "ERROR" "Échec de la sauvegarde des fichiers WordPress"
        return 1
    fi
}

# Sauvegarde des configurations
backup_configurations() {
    log "INFO" "Sauvegarde des configurations..."
    
    local config_files=(
        "docker-compose.yml"
        ".env"
        "nginx/conf/nginx.conf"
        "mariadb/conf/my.cnf"
        "wordpress/tools/wp-config-template.php"
    )
    
    for config_file in "${config_files[@]}"; do
        local source_path="$SCRIPT_DIR/$config_file"
        local dest_path="$BACKUP_DIR/configs/$(basename "$config_file")"
        
        if [[ -f "$source_path" ]]; then
            cp "$source_path" "$dest_path"
            log "INFO" "Configuration sauvegardée : $config_file"
        else
            log "WARN" "Fichier de configuration non trouvé : $config_file"
        fi
    done
    
    # Sauvegarde des Dockerfiles
    find "$SCRIPT_DIR" -name "Dockerfile" -exec cp {} "$BACKUP_DIR/configs/" \;
}

# Sauvegarde des logs
backup_logs() {
    log "INFO" "Sauvegarde des logs..."
    
    # Logs des conteneurs
    local services=("nginx" "wordpress" "mariadb")
    
    for service in "${services[@]}"; do
        local log_file="$BACKUP_DIR/logs/${service}_$(date +%Y%m%d_%H%M%S).log"
        
        if docker-compose logs --no-color "$service" > "$log_file" 2>&1; then
            log "INFO" "Logs de $service sauvegardés"
        else
            log "WARN" "Impossible de récupérer les logs de $service"
        fi
    done
    
    # Logs système (si disponibles)
    if [[ -d "/var/log/nginx" ]]; then
        cp -r /var/log/nginx "$BACKUP_DIR/logs/nginx_system_logs" 2>/dev/null || true
    fi
}

# =============================================================================
# FONCTIONS DE NETTOYAGE
# =============================================================================

# Nettoyage des anciennes sauvegardes
cleanup_old_backups() {
    log "INFO" "Nettoyage des sauvegardes anciennes (>${RETENTION_DAYS} jours)..."
    
    if [[ ! -d "$BACKUP_BASE_DIR" ]]; then
        log "INFO" "Aucun répertoire de sauvegarde à nettoyer"
        return 0
    fi
    
    local deleted_count=0
    
    # Trouver et supprimer les anciennes sauvegardes
    while IFS= read -r -d '' backup_dir; do
        local backup_name=$(basename "$backup_dir")
        
        # Extraire la date du nom du répertoire (format: YYYYMMDD_HHMMSS)
        if [[ "$backup_name" =~ ^[0-9]{8}_[0-9]{6}$ ]]; then
            local backup_date="${backup_name:0:8}"
            local current_date=$(date +%Y%m%d)
            
            # Calculer la différence en jours
            local backup_timestamp=$(date -d "$backup_date" +%s 2>/dev/null || echo 0)
            local current_timestamp=$(date -d "$current_date" +%s)
            local age_days=$(( (current_timestamp - backup_timestamp) / 86400 ))
            
            if [[ $age_days -gt $RETENTION_DAYS ]]; then
                log "INFO" "Suppression de l'ancienne sauvegarde : $backup_dir ($age_days jours)"
                rm -rf "$backup_dir"
                ((deleted_count++))
            fi
        fi
    done < <(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -print0)
    
    log "INFO" "$deleted_count ancienne(s) sauvegarde(s) supprimée(s)"
}

# =============================================================================
# FONCTION PRINCIPALE
# =============================================================================

main() {
    log "INFO" "Début de la sauvegarde automatisée"
    
    # Chargement des variables d'environnement
    if [[ -f "$SCRIPT_DIR/.env" ]]; then
        source "$SCRIPT_DIR/.env"
    else
        log "ERROR" "Fichier .env non trouvé dans $SCRIPT_DIR"
        exit 1
    fi
    
    # Vérifications préalables
    if ! command -v docker-compose &> /dev/null; then
        log "ERROR" "Docker Compose non trouvé"
        exit 1
    fi
    
    # Création de la structure
    create_backup_structure
    
    # Exécution des sauvegardes
    local backup_steps=(
        "backup_database"
        "backup_wordpress_files"
        "backup_configurations"
        "backup_logs"
        "cleanup_old_backups"
    )
    
    local failed_steps=()
    
    for step in "${backup_steps[@]}"; do
        if ! "$step"; then
            failed_steps+=("$step")
            log "ERROR" "Échec de l'étape : $step"
        fi
    done
    
    # Rapport final
    if [[ ${#failed_steps[@]} -eq 0 ]]; then
        log "INFO" "Sauvegarde terminée avec succès !"
        
        # Afficher la taille totale
        local total_size=$(du -sh "$BACKUP_DIR" | cut -f1)
        log "INFO" "Taille totale de la sauvegarde : $total_size"
        
        # Créer un symlink vers la dernière sauvegarde
        ln -sfn "$BACKUP_DIR" "$BACKUP_BASE_DIR/latest"
        
        exit 0
    else
        log "ERROR" "Sauvegarde terminée avec des erreurs"
        log "ERROR" "Étapes échouées : ${failed_steps[*]}"
        exit 1
    fi
}

# Exécution du script principal
main "$@"
```

#### Script de monitoring

```bash
#!/bin/bash
# monitor-stack.sh - Script de monitoring de la stack

set -euo pipefail

# =============================================================================
# CONFIGURATION DU MONITORING
# =============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/var/log/inception-monitor.log"
readonly ALERT_EMAIL="c-andriam@student.42.fr"
readonly CHECK_INTERVAL=60
readonly MAX_MEMORY_PERCENT=80
readonly MAX_CPU_PERCENT=80
readonly MAX_DISK_PERCENT=85

# Couleurs
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# =============================================================================
# FONCTIONS DE MONITORING
# =============================================================================

# Logging avec niveaux
log_monitor() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "INFO")  echo -e "${GREEN}[${timestamp}] INFO:${NC} $message" ;;
        "WARN")  echo -e "${YELLOW}[${timestamp}] WARN:${NC} $message" ;;
        "ERROR") echo -e "${RED}[${timestamp}] ERROR:${NC} $message" ;;
        "DEBUG") echo -e "${BLUE}[${timestamp}] DEBUG:${NC} $message" ;;
    esac
    
    # Log vers fichier
    echo "[${timestamp}] $level: $message" >> "$LOG_FILE"
}

# Vérification de l'état des conteneurs
check_containers_status() {
    local services=("nginx" "wordpress" "mariadb")
    local issues=()
    
    log_monitor "DEBUG" "Vérification de l'état des conteneurs..."
    
    for service in "${services[@]}"; do
        local status=$(docker-compose ps -q "$service" 2>/dev/null | xargs docker inspect --format='{{.State.Status}}' 2>/dev/null || echo "not_found")
        
        case "$status" in
            "running")
                log_monitor "DEBUG" "Service $service : OK (running)"
                ;;
            "not_found")
                issues+=("$service: conteneur non trouvé")
                log_monitor "ERROR" "Service $service : conteneur non trouvé"
                ;;
            *)
                issues+=("$service: état $status")
                log_monitor "ERROR" "Service $service : état anormal ($status)"
                ;;
        esac
    done
    
    if [[ ${#issues[@]} -gt 0 ]]; then
        send_alert "Problèmes de conteneurs détectés" "$(printf '%s\n' "${issues[@]}")"
        return 1
    fi
    
    return 0
}

# Vérification de la santé des services
check_services_health() {
    log_monitor "DEBUG" "Vérification de la santé des services..."
    
    # Test MariaDB
    if ! docker-compose exec -T mariadb mysqladmin ping -h localhost --silent 2>/dev/null; then
        log_monitor "ERROR" "MariaDB ne répond pas"
        send_alert "MariaDB indisponible" "La base de données ne répond pas au ping"
        return 1
    fi
    
    # Test WordPress (PHP-FPM)
    if ! docker-compose exec -T wordpress php-fpm82 -t 2>/dev/null; then
        log_monitor "ERROR" "PHP-FPM a un problème de configuration"
        return 1
    fi
    
    # Test Nginx
    if ! docker-compose exec -T nginx nginx -t 2>/dev/null; then
        log_monitor "ERROR" "Nginx a un problème de configuration"
        return 1
    fi
    
    log_monitor "DEBUG" "Tous les services sont en bonne santé"
    return 0
}

# Vérification de la connectivité réseau
check_network_connectivity() {
    local urls=(
        "https://localhost"
        "https://localhost/wp-admin"
    )
    
    log_monitor "DEBUG" "Vérification de la connectivité réseau..."
    
    for url in "${urls[@]}"; do
        local response_code=$(curl -s -k -o /dev/null -w "%{http_code}" --max-time 10 "$url" 2>/dev/null || echo "000")
        
        case "$response_code" in
            "200"|"301"|"302")
                log_monitor "DEBUG" "URL $url : OK ($response_code)"
                ;;
            "000")
                log_monitor "ERROR" "URL $url : Pas de réponse"
                send_alert "Connectivité web perdue" "L'URL $url ne répond pas"
                return 1
                ;;
            *)
                log_monitor "WARN" "URL $url : Réponse inattendue ($response_code)"
                ;;
        esac
    done
    
    return 0
}

# Monitoring des ressources système
check_system_resources() {
    log_monitor "DEBUG" "Vérification des ressources système..."
    
    # Utilisation CPU
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    cpu_usage=${cpu_usage%.*}  # Supprimer les décimales
    
    if [[ $cpu_usage -gt $MAX_CPU_PERCENT ]]; then
        log_monitor "WARN" "Utilisation CPU élevée : ${cpu_usage}%"
        send_alert "CPU élevé" "Utilisation CPU : ${cpu_usage}% (seuil: ${MAX_CPU_PERCENT}%)"
    fi
    
    # Utilisation mémoire
    local memory_info=$(free | grep Mem)
    local total_mem=$(echo $memory_info | awk '{print $2}')
    local used_mem=$(echo $memory_info | awk '{print $3}')
    local memory_percent=$((used_mem * 100 / total_mem))
    
    if [[ $memory_percent -gt $MAX_MEMORY_PERCENT ]]; then
        log_monitor "WARN" "Utilisation mémoire élevée : ${memory_percent}%"
        send_alert "Mémoire élevée" "Utilisation mémoire : ${memory_percent}% (seuil: ${MAX_MEMORY_PERCENT}%)"
    fi
    
    # Utilisation disque
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
    
    if [[ $disk_usage -gt $MAX_DISK_PERCENT ]]; then
        log_monitor "WARN" "Utilisation disque élevée : ${disk_usage}%"
        send_alert "Disque plein" "Utilisation disque : ${disk_usage}% (seuil: ${MAX_DISK_PERCENT}%)"
    fi
    
    log_monitor "DEBUG" "Ressources : CPU ${cpu_usage}%, MEM ${memory_percent}%, DISK ${disk_usage}%"
}

# Monitoring des conteneurs individuels
check_container_resources() {
    local services=("nginx" "wordpress" "mariadb")
    
    log_monitor "DEBUG" "Vérification des ressources des conteneurs..."
    
    for service in "${services[@]}"; do
        local container_id=$(docker-compose ps -q "$service" 2>/dev/null)
        
        if [[ -n "$container_id" ]]; then
            # Statistiques du conteneur
            local stats=$(docker stats --no-stream --format "table {{.CPUPerc}},{{.MemUsage}},{{.MemPerc}}" "$container_id" 2>/dev/null | tail -1)
            
            if [[ -n "$stats" ]]; then
                local cpu_perc=$(echo "$stats" | cut -d',' -f1 | tr -d '%')
                local mem_usage=$(echo "$stats" | cut -d',' -f2)
                local mem_perc=$(echo "$stats" | cut -d',' -f3 | tr -d '%')
                
                log_monitor "DEBUG" "Conteneur $service : CPU ${cpu_perc}%, MEM ${mem_perc}% ($mem_usage)"
                
                # Alertes pour utilisation excessive
                if (( $(echo "$cpu_perc > 90" | bc -l) )); then
                    log_monitor "WARN" "Conteneur $service : CPU élevé (${cpu_perc}%)"
                fi
                
                if (( $(echo "$mem_perc > 90" | bc -l) )); then
                    log_monitor "WARN" "Conteneur $service : Mémoire élevée (${mem_perc}%)"
                fi
            fi
        fi
    done
}

# Vérification de la base de données
check_database_health() {
    log_monitor "DEBUG" "Vérification de la santé de la base de données..."
    
    # Test de connexion avec timeout
    if timeout 10 docker-compose exec -T mariadb mysql \
        -u "$MYSQL_USER" \
        -p"$MYSQL_PASSWORD" \
        -e "SELECT 1;" "$MYSQL_DATABASE" &>/dev/null; then
        
        # Vérifier les processus MySQL
        local process_count=$(docker-compose exec -T mariadb mysql \
            -u root -p"$MYSQL_ROOT_PASSWORD" \
            -e "SHOW PROCESSLIST;" 2>/dev/null | wc -l)
        
        log_monitor "DEBUG" "Base de données : OK ($process_count processus actifs)"
        
        # Alerter si trop de connexions
        if [[ $process_count -gt 50 ]]; then
            log_monitor "WARN" "Nombre élevé de processus MySQL : $process_count"
        fi
        
        return 0
    else
        log_monitor "ERROR" "Impossible de se connecter à la base de données"
        send_alert "Base de données inaccessible" "Impossible de se connecter à MySQL/MariaDB"
        return 1
    fi
}

# =============================================================================
# SYSTÈME D'ALERTES
# =============================================================================

# Envoyer une alerte
send_alert() {
    local subject="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    log_monitor "ERROR" "ALERTE: $subject - $message"
    
    # Créer le fichier d'alerte
    local alert_file="/tmp/inception_alert_$(date +%s).txt"
    cat > "$alert_file" << EOF
ALERTE INCEPTION STACK
======================

Date/Heure: $timestamp
Serveur: $(hostname)
Utilisateur: $(whoami)

Sujet: $subject

Message:
$message

---
Détails système:
- Uptime: $(uptime)
- Load Average: $(cat /proc/loadavg)
- Mémoire: $(free -h | grep Mem)
- Disque: $(df -h /)

État des conteneurs:
$(docker-compose ps 2>/dev/null || echo "Erreur lors de la récupération de l'état")
EOF
    
    # Envoyer par email si mail est disponible
    if command -v mail &> /dev/null; then
        mail -s "[INCEPTION] $subject" "$ALERT_EMAIL" < "$alert_file"
        log_monitor "INFO" "Alerte envoyée par email à $ALERT_EMAIL"
    fi
    
    # Garder l'alerte pour consultation
    mv "$alert_file" "/tmp/inception_last_alert.txt"
}

# =============================================================================
# FONCTIONS DE RÉCUPÉRATION AUTOMATIQUE
# =============================================================================

# Tentative de récupération automatique
auto_recovery() {
    local service="$1"
    
    log_monitor "INFO" "Tentative de récupération automatique pour : $service"
    
    case "$service" in
        "all")
            log_monitor "INFO" "Redémarrage complet de la stack..."
            if docker-compose restart; then
                log_monitor "INFO" "Stack redémarrée avec succès"
                sleep 30  # Attendre la stabilisation
                return 0
            else
                log_monitor "ERROR" "Échec du redémarrage de la stack"
                return 1
            fi
            ;;
        *)
            log_monitor "INFO" "Redémarrage du service : $service"
            if docker-compose restart "$service"; then
                log_monitor "INFO" "Service $service redémarré avec succès"
                sleep 10  # Attendre la stabilisation
                return 0
            else
                log_monitor "ERROR" "Échec du redémarrage du service $service"
                return 1
            fi
            ;;
    esac
}

# =============================================================================
# FONCTION PRINCIPALE DE MONITORING
# =============================================================================

# Cycle de monitoring complet
monitoring_cycle() {
    local checks=(
        "check_containers_status"
        "check_services_health"
        "check_network_connectivity"
        "check_system_resources"
        "check_container_resources"
        "check_database_health"
    )
    
    local failed_checks=()
    
    log_monitor "INFO" "Début du cycle de monitoring"
    
    for check in "${checks[@]}"; do
        if ! "$check"; then
            failed_checks+=("$check")
        fi
    done
    
    if [[ ${#failed_checks[@]} -eq 0 ]]; then
        log_monitor "INFO" "Cycle de monitoring terminé : Tout est OK"
        return 0
    else
        log_monitor "WARN" "Cycle de monitoring terminé avec ${#failed_checks[@]} problème(s)"
        log_monitor "WARN" "Vérifications échouées : ${failed_checks[*]}"
        
        # Tentative de récupération si problème critique
        if [[ " ${failed_checks[*]} " =~ " check_containers_status " ]]; then
            auto_recovery "all"
        fi
        
        return 1
    fi
}

# Mode daemon
run_daemon() {
    log_monitor "INFO" "Démarrage du monitoring en mode daemon (intervalle: ${CHECK_INTERVAL}s)"
    
    while true; do
        monitoring_cycle
        
        log_monitor "DEBUG" "Attente de ${CHECK_INTERVAL} secondes..."
        sleep "$CHECK_INTERVAL"
    done
}

# Mode check unique
run_single_check() {
    log_monitor "INFO" "Exécution d'un check unique"
    monitoring_cycle
}

# =============================================================================
# GESTION DES PARAMÈTRES
# =============================================================================

show_help() {
    cat << EOF
Usage: $0 [OPTION]

Script de monitoring de la stack Inception

OPTIONS:
    -h, --help          Afficher cette aide
    -d, --daemon        Exécuter en mode daemon (monitoring continu)
    -c, --check         Exécuter un check unique
    -s, --status        Afficher le statut actuel
    -a, --alert-test    Tester le système d'alertes
    --interval SECONDS  Définir l'intervalle de check (défaut: 60s)

EXAMPLES:
    $0 --check                    # Check unique
    $0 --daemon                   # Monitoring continu
    $0 --daemon --interval 30     # Monitoring toutes les 30s
    $0 --status                   # Statut actuel

EOF
}

# Fonction principale
main() {
    local mode="check"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--daemon)
                mode="daemon"
                shift
                ;;
            -c|--check)
                mode="check"
                shift
                ;;
            -s|--status)
                mode="status"
                shift
                ;;
            -a|--alert-test)
                mode="alert_test"
                shift
                ;;
            --interval)
                CHECK_INTERVAL="$2"
                shift 2
                ;;
            *)
                log_monitor "ERROR" "Option inconnue : $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Créer le fichier de log si nécessaire
    touch "$LOG_FILE"
    
    # Chargement des variables d'environnement
    if [[ -f "$SCRIPT_DIR/.env" ]]; then
        source "$SCRIPT_DIR/.env"
    fi
    
    case "$mode" in
        "daemon")
            run_daemon
            ;;
        "check")
            run_single_check
            ;;
        "status")
            echo "=== STATUT DE LA STACK INCEPTION ==="
            docker-compose ps
            echo "=== UTILISATION DES RESSOURCES ==="
            docker stats --no-stream
            ;;
        "alert_test")
            send_alert "Test d'alerte" "Ceci est un test du système d'alertes"
            ;;
    esac
}

# Piège pour nettoyage
cleanup() {
    log_monitor "INFO" "Arrêt du monitoring"
    exit 0
}

trap cleanup EXIT INT TERM

# Exécution
main "$@"
```

---

## 8. 🏗️ Architecture complète

### 8.1 Conception d'une architecture robuste

#### Principes de conception

**Architecture en couches :**
```
┌─────────────────────────────────────────────────────────────┐
│                     COUCHE PRÉSENTATION                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Nginx     │  │ Load Balancer│  │    SSL/TLS  │         │
│  │ Reverse     │  │   (Optionnel)│  │ Termination │         │
│  │   Proxy     │  │              │  │             │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                    COUCHE APPLICATION                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │ WordPress   │  │ WordPress   │  │ WordPress   │         │
│  │ Instance 1  │  │ Instance 2  │  │ Instance 3  │         │
│  │ (PHP-FPM)   │  │ (PHP-FPM)   │  │ (PHP-FPM)   │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                     COUCHE DONNÉES                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   MariaDB   │  │    Redis    │  │ Stockage    │         │
│  │  Principal  │  │    Cache    │  │  Fichiers   │         │
│  │             │  │             │  │             │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

#### Architecture Docker Compose complète

```yaml
version: '3.8'

# =============================================================================
# SERVICES
# =============================================================================

services:
  # ---------------------------------------------------------------------------
  # REVERSE PROXY ET LOAD BALANCER
  # ---------------------------------------------------------------------------
  
  nginx:
    build:
      context: ./requirements/nginx
      dockerfile: Dockerfile
      args:
        - NGINX_VERSION=1.24
    container_name: ${PROJECT_NAME}_nginx
    hostname: nginx-server
    
    ports:
      - "80:80"
      - "443:443"
    
    volumes:
      # Configuration
      - ./requirements/nginx/conf/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./requirements/nginx/conf/conf.d:/etc/nginx/conf.d:ro
      
      # Certificats SSL
      - nginx_ssl:/etc/ssl/nginx:ro
      
      # Contenu statique
      - wordpress_data:/var/www/html:ro
      
      # Logs
      - nginx_logs:/var/log/nginx
    
    environment:
      - NGINX_WORKER_PROCESSES=auto
      - NGINX_WORKER_CONNECTIONS=1024
    
    depends_on:
      wordpress_app_1:
        condition: service_healthy
      wordpress_app_2:
        condition: service_healthy
    
    networks:
      - frontend
      - backend
    
    restart: unless-stopped
    
    healthcheck:
      test: ["CMD", "nginx", "-t"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    
    labels:
      - "traefik.enable=false"
      - "com.inception.service=nginx"
      - "com.inception.description=Reverse proxy and load balancer"

  # ---------------------------------------------------------------------------
  # APPLICATIONS WORDPRESS (MULTI-INSTANCE)
  # ---------------------------------------------------------------------------
  
  wordpress_app_1: &wordpress_template
    build:
      context: ./requirements/wordpress
      dockerfile: Dockerfile
      args:
        - PHP_VERSION=8.2
        - WP_VERSION=latest
    container_name: ${PROJECT_NAME}_wordpress_1
    hostname: wordpress-app-1
    
    volumes:
      # Code WordPress partagé
      - wordpress_data:/var/www/html
      
      # Configuration PHP
      - ./requirements/wordpress/conf/php.ini:/etc/php82/php.ini:ro
      - ./requirements/wordpress/conf/php-fpm.conf:/etc/php82/php-fpm.conf:ro
      
      # Uploads et contenu
      - wordpress_uploads:/var/www/html/wp-content/uploads
      
      # Logs
      - wordpress_logs:/var/log/php
    
    environment:
      # Base de données
      - WORDPRESS_DB_HOST=mariadb_primary:3306
      - WORDPRESS_DB_NAME=${MYSQL_DATABASE}
      - WORDPRESS_DB_USER=${MYSQL_USER}
      - WORDPRESS_DB_PASSWORD=${MYSQL_PASSWORD}
      
      # Configuration WordPress
      - WORDPRESS_CONFIG_EXTRA=define('WP_REDIS_HOST', 'redis');
      
      # URLs
      - WP_HOME=${WP_HOME}
      - WP_SITEURL=${WP_SITEURL}
      
      # Admin
      - WP_ADMIN_USER=${WP_ADMIN_USER}
      - WP_ADMIN_PASSWORD=${WP_ADMIN_PASSWORD}
      - WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL}
      
      # Performance
      - PHP_MEMORY_LIMIT=256M
      - PHP_MAX_EXECUTION_TIME=300
      - PHP_UPLOAD_MAX_FILESIZE=50M
      
      # Instance ID pour différenciation
      - WP_INSTANCE_ID=1
    
    depends_on:
      mariadb_primary:
        condition: service_healthy
      redis:
        condition: service_healthy
    
    networks:
      - backend
    
    restart: unless-stopped
    
    healthcheck:
      test: ["CMD", "php-fpm82", "-t"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 120s
    
    labels:
      - "com.inception.service=wordpress"
      - "com.inception.instance=1"
      - "com.inception.description=WordPress application instance 1"

  wordpress_app_2:
    <<: *wordpress_template
    container_name: ${PROJECT_NAME}_wordpress_2
    hostname: wordpress-app-2
    environment:
      # Hériter de wordpress_template et modifier l'instance ID
      - WORDPRESS_DB_HOST=mariadb_primary:3306
      - WORDPRESS_DB_NAME=${MYSQL_DATABASE}
      - WORDPRESS_DB_USER=${MYSQL_USER}
      - WORDPRESS_DB_PASSWORD=${MYSQL_PASSWORD}
      - WORDPRESS_CONFIG_EXTRA=define('WP_REDIS_HOST', 'redis');
      - WP_HOME=${WP_HOME}
      - WP_SITEURL=${WP_SITEURL}
      - WP_ADMIN_USER=${WP_ADMIN_USER}
      - WP_ADMIN_PASSWORD=${WP_ADMIN_PASSWORD}
      - WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL}
      - PHP_MEMORY_LIMIT=256M
      - PHP_MAX_EXECUTION_TIME=300
      - PHP_UPLOAD_MAX_FILESIZE=50M
      - WP_INSTANCE_ID=2
    labels:
      - "com.inception.service=wordpress"
      - "com.inception.instance=2"
      - "com.inception.description=WordPress application instance 2"

  # ---------------------------------------------------------------------------
  # BASE DE DONNÉES PRINCIPALE
  # ---------------------------------------------------------------------------
  
  mariadb_primary:
    build:
      context: ./requirements/mariadb
      dockerfile: Dockerfile
      args:
        - MARIADB_VERSION=10.11
    container_name: ${PROJECT_NAME}_mariadb_primary
    hostname: mariadb-primary
    
    volumes:
      # Données persistantes
      - mariadb_data:/var/lib/mysql
      
      # Configuration
      - ./requirements/mariadb/conf/my.cnf:/etc/mysql/my.cnf:ro
      - ./requirements/mariadb/conf/conf.d:/etc/mysql/conf.d:ro
      
      # Scripts d'initialisation
      - ./requirements/mariadb/init:/docker-entrypoint-initdb.d:ro
      
      # Logs
      - mariadb_logs:/var/log/mysql
      
      # Sauvegardes
      - mariadb_backups:/backups
    
    environment:
      # Configuration principale
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=${MYSQL_DATABASE}
      - MYSQL_USER=${MYSQL_USER}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
      
      # Configuration avancée
      - MYSQL_INITDB_SKIP_TZINFO=1
      - MYSQL_CHARACTER_SET_SERVER=utf8mb4
      - MYSQL_COLLATION_SERVER=utf8mb4_unicode_ci
      
      # Réplication (pour setup master-slave futur)
      - MYSQL_REPLICATION_MODE=master
      - MYSQL_REPLICATION_USER=replicator
      - MYSQL_REPLICATION_PASSWORD=${MYSQL_REPLICATION_PASSWORD}
    
    networks:
      - backend
    
    restart: unless-stopped
    
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "--silent"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s
    
    labels:
      - "com.inception.service=mariadb"
      - "com.inception.role=primary"
      - "com.inception.description=Primary MariaDB database server"

  # ---------------------------------------------------------------------------
  # CACHE REDIS
  # ---------------------------------------------------------------------------
  
  redis:
    build:
      context: ./requirements/redis
      dockerfile: Dockerfile
      args:
        - REDIS_VERSION=7.0
    container_name: ${PROJECT_NAME}_redis
    hostname: redis-cache
    
    volumes:
      # Configuration
      - ./requirements/redis/conf/redis.conf:/etc/redis/redis.conf:ro
      
      # Données persistantes (optionnel pour cache)
      - redis_data:/data
      
      # Logs
      - redis_logs:/var/log/redis
    
    environment:
      - REDIS_PASSWORD=${REDIS_PASSWORD}
      - REDIS_MAX_MEMORY=256mb
      - REDIS_MAX_MEMORY_POLICY=allkeys-lru
    
    networks:
      - backend
    
    restart: unless-stopped
    
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    
    labels:
      - "com.inception.service=redis"
      - "com.inception.description=Redis cache server"

  # ---------------------------------------------------------------------------
  # SERVICES DE SUPPORT (OPTIONNELS)
  # ---------------------------------------------------------------------------
  
  # Service de monitoring
  monitoring:
    build:
      context: ./requirements/monitoring
      dockerfile: Dockerfile
    container_name: ${PROJECT_NAME}_monitoring
    hostname: monitoring-server
    
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - monitoring_data:/var/lib/monitoring
      - ./scripts/monitor-stack.sh:/usr/local/bin/monitor-stack.sh:ro
    
    environment:
      - MONITOR_INTERVAL=60
      - ALERT_EMAIL=${ALERT_EMAIL}
    
    networks:
      - backend
    
    restart: unless-stopped
    
    depends_on:
      - nginx
      - mariadb_primary
    
    labels:
      - "com.inception.service=monitoring"
      - "com.inception.description=System monitoring and alerting"

  # Service de sauvegarde automatique
  backup:
    build:
      context: ./requirements/backup
      dockerfile: Dockerfile
    container_name: ${PROJECT_NAME}_backup
    hostname: backup-service
    
    volumes:
      - mariadb_data:/source/mariadb:ro
      - wordpress_data:/source/wordpress:ro
      - backup_storage:/backups
      - ./scripts/backup-system.sh:/usr/local/bin/backup-system.sh:ro
    
    environment:
      - BACKUP_SCHEDULE=${BACKUP_SCHEDULE:-"0 2 * * *"}  # 2h du matin quotidien
      - BACKUP_RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-30}
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
    
    networks:
      - backend
    
    restart: unless-stopped
    
    depends_on:
      - mariadb_primary
    
    labels:
      - "com.inception.service=backup"
      - "com.inception.description=Automated backup service"

# =============================================================================
# RÉSEAUX
# =============================================================================

networks:
  # Réseau frontend (accessible depuis l'extérieur)
  frontend:
    driver: bridge
    name: ${PROJECT_NAME}_frontend
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/16
          gateway: 172.20.0.1
    labels:
      - "com.inception.network=frontend"
      - "com.inception.description=External facing network"

  # Réseau backend (interne uniquement)
  backend:
    driver: bridge
    name: ${PROJECT_NAME}_backend
    internal: true
    ipam:
      driver: default
      config:
        - subnet: 172.21.0.0/16
          gateway: 172.21.0.1
    labels:
      - "com.inception.network=backend"
      - "com.inception.description=Internal services network"

# =============================================================================
# VOLUMES
# =============================================================================

volumes:
  # Données WordPress
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH}/wordpress
    labels:
      - "com.inception.volume=wordpress_data"
      - "com.inception.description=WordPress core files and themes"

  wordpress_uploads:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH}/wordpress/wp-content/uploads
    labels:
      - "com.inception.volume=wordpress_uploads"
      - "com.inception.description=WordPress uploaded media files"

  # Données MariaDB
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH}/mariadb
    labels:
      - "com.inception.volume=mariadb_data"
      - "com.inception.description=MariaDB database files"

  # Données Redis
  redis_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH}/redis
    labels:
      - "com.inception.volume=redis_data"
      - "com.inception.description=Redis cache data"

  # Certificats SSL
  nginx_ssl:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH}/ssl
    labels:
      - "com.inception.volume=nginx_ssl"
      - "com.inception.description=SSL certificates and keys"

  # Logs
  nginx_logs:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH}/logs/nginx
    labels:
      - "com.inception.volume=nginx_logs"

  wordpress_logs:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH}/logs/wordpress
    labels:
      - "com.inception.volume=wordpress_logs"

  mariadb_logs:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH}/logs/mariadb
    labels:
      - "com.inception.volume=mariadb_logs"

  redis_logs:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH}/logs/redis
    labels:
      - "com.inception.volume=redis_logs"

  # Sauvegardes
  mariadb_backups:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH}/backups/mariadb
    labels:
      - "com.inception.volume=mariadb_backups"

  backup_storage:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH}/backups/system
    labels:
      - "com.inception.volume=backup_storage"

  # Monitoring
  monitoring_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH}/monitoring
    labels:
      - "com.inception.volume=monitoring_data"
```

### 8.2 Organisation des fichiers et structure

#### Structure complète du projet

```
inception/
├── README.md                           # Documentation principale
├── Makefile                           # Automatisation build/deploy
├── docker-compose.yml                 # Orchestration principale
├── .env                              # Variables d'environnement
├── .env.example                      # Exemple de configuration
├── .gitignore                        # Fichiers à ignorer
├── .dockerignore                     # Contexte Docker
│
├── docs/                             # Documentation
│   ├── architecture.md
│   ├── deployment.md
│   ├── troubleshooting.md
│   └── api.md
│
├── scripts/                          # Scripts d'automatisation
│   ├── deploy.sh                     # Script de déploiement
│   ├── backup-system.sh              # Sauvegarde automatisée
│   ├── monitor-stack.sh              # Monitoring système
│   ├── restore.sh                    # Restauration
│   ├── ssl-renew.sh                  # Renouvellement SSL
│   ├── dev-setup.sh                  # Setup développement
│   └── utils/
│       ├── log-analyzer.sh           # Analyse des logs
│       ├── performance-test.sh       # Tests de performance
│       └── security-check.sh         # Vérifications sécurité
│
├── requirements/                     # Définitions des services
│   ├── nginx/
│   │   ├── Dockerfile
│   │   ├── conf/
│   │   │   ├── nginx.conf            # Configuration principale
│   │   │   ├── conf.d/
│   │   │   │   ├── default.conf      # Site par défaut
│   │   │   │   ├── ssl.conf          # Configuration SSL
│   │   │   │   ├── security.conf     # Headers sécurité
│   │   │   │   └── performance.conf   # Optimisations
│   │   │   └── snippets/
│   │   │       ├── ssl-params.conf
│   │   │       └── fastcgi-params.conf
│   │   └── tools/
│   │       ├── entrypoint.sh         # Script de démarrage
│   │       ├── ssl-generator.sh      # Génération certificats
│   │       └── nginx-reload.sh       # Rechargement config
│   │
│   ├── wordpress/
│   │   ├── Dockerfile
│   │   ├── conf/
│   │   │   ├── php.ini              # Configuration PHP
│   │   │   ├── php-fpm.conf         # Configuration FPM
│   │   │   └── wp-config-template.php
│   │   ├── tools/
│   │   │   ├── entrypoint.sh        # Installation WordPress
│   │   │   ├── wp-cli-setup.sh      # Configuration WP-CLI
│   │   │   └── health-check.sh      # Vérification santé
│   │   └── themes/                  # Thèmes personnalisés
│   │       └── inception-theme/
│   │           ├── style.css
│   │           ├── index.php
│   │           ├── functions.php
│   │           └── assets/
│   │
│   ├── mariadb/
│   │   ├── Dockerfile
│   │   ├── conf/
│   │   │   ├── my.cnf               # Configuration principale
│   │   │   └── conf.d/
│   │   │       ├── performance.cnf   # Optimisations
│   │   │       ├── security.cnf      # Sécurité
│   │   │       └── replication.cnf   # Réplication
│   │   ├── init/
│   │   │   ├── 01-create-databases.sql
│   │   │   ├── 02-create-users.sql
│   │   │   └── 03-grant-privileges.sql
│   │   └── tools/
│   │       ├── entrypoint.sh        # Initialisation DB
│   │       ├── backup.sh            # Script sauvegarde
│   │       └── health-check.sh      # Vérification santé
│   │
│   ├── redis/                       # Service cache (bonus)
│   │   ├── Dockerfile
│   │   ├── conf/
│   │   │   └── redis.conf
│   │   └── tools/
│   │       └── entrypoint.sh
│   │
│   ├── monitoring/                  # Service monitoring (bonus)
│   │   ├── Dockerfile
│   │   ├── conf/
│   │   │   └── monitoring.conf
│   │   └── tools/
│   │       └── monitor.sh
│   │
│   └── backup/                      # Service sauvegarde (bonus)
│       ├── Dockerfile
│       ├── conf/
│       │   └── backup.conf
│       └── tools/
│           └── backup-cron.sh
│
├── data/                            # Données persistantes (gitignore)
│   ├── wordpress/
│   ├── mariadb/
│   ├── redis/
│   ├── ssl/
│   ├── logs/
│   │   ├── nginx/
│   │   ├── wordpress/
│   │   ├── mariadb/
│   │   └── system/
│   ├── backups/
│   │   ├── mariadb/
│   │   ├── wordpress/
│   │   └── system/
│   └── monitoring/
│
├── tests/                           # Tests automatisés
│   ├── unit/
│   │   ├── test-docker-images.sh
│   │   └── test-configurations.sh
│   ├── integration/
│   │   ├── test-services.sh
│   │   └── test-connectivity.sh
│   ├── performance/
│   │   ├── load-test.sh
│   │   └── stress-test.sh
│   └── security/
│       ├── security-scan.sh
│       └── vulnerability-check.sh
│
├── config/                          # Configurations environnement
│   ├── development/
│   │   ├── .env.dev
│   │   └── docker-compose.override.yml
│   ├── staging/
│   │   ├── .env.staging
│   │   └── docker-compose.staging.yml
│   └── production/
│       ├── .env.prod
│       └── docker-compose.prod.yml
│
└── tools/                           # Outils développement
    ├── setup-dev.sh                # Setup environnement dev
    ├── cleanup.sh                  # Nettoyage système
    ├── logs-viewer.sh              # Visualiseur logs
    └── performance-monitor.sh       # Monitoring performance
```

### 8.3 Makefile complet pour l'automatisation

```makefile
# =============================================================================
# MAKEFILE INCEPTION - Automatisation complète
# =============================================================================

# Variables par défaut
PROJECT_NAME ?= inception
COMPOSE_FILE ?= docker-compose.yml
ENV_FILE ?= .env
DATA_PATH ?= $(HOME)/data

# Couleurs pour l'affichage
RESET = \033[0m
GREEN = \033[32m
YELLOW = \033[33m
RED = \033[31m
BLUE = \033[34m

# Variables dérivées
USER_ID := $(shell id -u)
GROUP_ID := $(shell id -g)
TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)

# =============================================================================
# CIBLES PRINCIPALES
# =============================================================================

.PHONY: help
help: ## Afficher l'aide
	@echo "$(BLUE)Makefile Inception - Gestion de la stack WordPress$(RESET)"
	@echo ""
	@echo "$(GREEN)Cibles disponibles :$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-20s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: all
all: setup build up ## Installation complète

.PHONY: install
install: all ## Alias pour 'all'

# =============================================================================
# SETUP ET CONFIGURATION
# =============================================================================

.PHONY: setup
setup: ## Préparer l'environnement
	@echo "$(GREEN)🔧 Préparation de l'environnement...$(RESET)"
	@mkdir -p $(DATA_PATH)/{wordpress,mariadb,redis,ssl,logs/{nginx,wordpress,mariadb,redis,system},backups/{mariadb,wordpress,system},monitoring}
	@[ -f $(ENV_FILE) ] || cp .env.example $(ENV_FILE)
	@echo "$(GREEN)✅ Environnement préparé$(RESET)"

.PHONY: setup-ssl
setup-ssl: ## Générer les certificats SSL
	@echo "$(GREEN)🔐 Génération des certificats SSL...$(RESET)"
	@mkdir -p $(DATA_PATH)/ssl
	@docker run --rm -v $(DATA_PATH)/ssl:/ssl alpine/openssl req -x509 -nodes -days 365 \
		-newkey rsa:2048 -keyout /ssl/nginx.key -out /ssl/nginx.crt \
		-subj "/C=FR/ST=Paris/L=Paris/O=42School/CN=c-andriam.42.fr"
	@chmod 600 $(DATA_PATH)/ssl/nginx.key
	@chmod 644 $(DATA_PATH)/ssl/nginx.crt
	@echo "$(GREEN)✅ Certificats SSL générés$(RESET)"

.PHONY: setup-dev
setup-dev: ## Configuration pour le développement
	@echo "$(GREEN)🛠️ Configuration développement...$(RESET)"
	@cp config/development/.env.dev $(ENV_FILE)
	@cp config/development/docker-compose.override.yml .
	@echo "$(GREEN)✅ Configuration développement appliquée$(RESET)"

# =============================================================================
# BUILD ET DÉPLOIEMENT
# =============================================================================

.PHONY: build
build: ## Construire toutes les images
	@echo "$(GREEN)🏗️ Construction des images Docker...$(RESET)"
	@docker-compose build --parallel
	@echo "$(GREEN)✅ Images construites$(RESET)"

.PHONY: build-no-cache
build-no-cache: ## Construire sans cache
	@echo "$(GREEN)🏗️ Construction des images sans cache...$(RESET)"
	@docker-compose build --no-cache --parallel
	@echo "$(GREEN)✅ Images construites$(RESET)"

.PHONY: up
up: ## Démarrer tous les services
	@echo "$(GREEN)🚀 Démarrage des services...$(RESET)"
	@docker-compose up -d
	@echo "$(GREEN)✅ Services démarrés$(RESET)"
	@$(MAKE) status

.PHONY: up-build
up-build: ## Construire et démarrer
	@echo "$(GREEN)🏗️🚀 Construction et démarrage...$(RESET)"
	@docker-compose up -d --build
	@echo "$(GREEN)✅ Services construits et démarrés$(RESET)"
	@$(MAKE) status

.PHONY: down
down: ## Arrêter tous les services
	@echo "$(YELLOW)⏹️ Arrêt des services...$(RESET)"
	@docker-compose down
	@echo "$(YELLOW)✅ Services arrêtés$(RESET)"

.PHONY: restart
restart: down up ## Redémarrer tous les services

.PHONY: reload
reload: ## Recharger les configurations
	@echo "$(BLUE)🔄 Rechargement des configurations...$(RESET)"
	@docker-compose exec nginx nginx -s reload
	@docker-compose restart wordpress_app_1 wordpress_app_2
	@echo "$(BLUE)✅ Configurations rechargées$(RESET)"

# =============================================================================
# SERVICES INDIVIDUELS
# =============================================================================

.PHONY: nginx-up
nginx-up: ## Démarrer Nginx
	@docker-compose up -d nginx

.PHONY: nginx-restart
nginx-restart: ## Redémarrer Nginx
	@docker-compose restart nginx

.PHONY: wordpress-up
wordpress-up: ## Démarrer WordPress
	@docker-compose up -d wordpress_app_1 wordpress_app_2

.PHONY: wordpress-restart
wordpress-restart: ## Redémarrer WordPress
	@docker-compose restart wordpress_app_1 wordpress_app_2

.PHONY: mariadb-up
mariadb-up: ## Démarrer MariaDB
	@docker-compose up -d mariadb_primary

.PHONY: mariadb-restart
mariadb-restart: ## Redémarrer MariaDB
	@docker-compose restart mariadb_primary

# =============================================================================
# MONITORING ET STATUT
# =============================================================================

.PHONY: status
status: ## Afficher le statut des services
	@echo "$(BLUE)📊 Statut des services$(RESET)"
	@docker-compose ps
	@echo ""
	@echo "$(BLUE)🌐 URLs d'accès :$(RESET)"
	@echo "  Site principal : https://c-andriam.42.fr"
	@echo "  Administration : https://c-andriam.42.fr/wp-admin"
	@echo ""

.PHONY: logs
logs: ## Afficher tous les logs
	@docker-compose logs -f

.PHONY: logs-nginx
logs-nginx: ## Logs Nginx
	@docker-compose logs -f nginx

.PHONY: logs-wordpress
logs-wordpress: ## Logs WordPress
	@docker-compose logs -f wordpress_app_1 wordpress_app_2

.PHONY: logs-mariadb
logs-mariadb: ## Logs MariaDB
	@docker-compose logs -f mariadb_primary

.PHONY: stats
stats: ## Afficher les statistiques des conteneurs
	@echo "$(BLUE)📈 Statistiques des conteneurs$(RESET)"
	@docker stats --no-stream

.PHONY: health
health: ## Vérifier la santé des services
	@echo "$(BLUE)🏥 Vérification de la santé des services$(RESET)"
	@./scripts/monitor-stack.sh --check

# =============================================================================
# TESTS ET VALIDATION
# =============================================================================

.PHONY: test
test: test-connectivity test-services ## Exécuter tous les tests

.PHONY: test-connectivity
test-connectivity: ## Tester la connectivité
	@echo "$(BLUE)🔗 Test de connectivité...$(RESET)"
	@curl -sk https://localhost >/dev/null && echo "$(GREEN)✅ Site principal accessible$(RESET)" || echo "$(RED)❌ Site principal inaccessible$(RESET)"
	@curl -sk https://localhost/wp-admin >/dev/null && echo "$(GREEN)✅ Administration accessible$(RESET)" || echo "$(RED)❌ Administration inaccessible$(RESET)"

.PHONY: test-services
test-services: ## Tester les services individuels
	@echo "$(BLUE)🔍 Test des services...$(RESET)"
	@docker-compose exec -T nginx nginx -t && echo "$(GREEN)✅ Nginx configuration OK$(RESET)" || echo "$(RED)❌ Nginx configuration KO$(RESET)"
	@docker-compose exec -T wordpress_app_1 php-fpm82 -t && echo "$(GREEN)✅ PHP-FPM configuration OK$(RESET)" || echo "$(RED)❌ PHP-FPM configuration KO$(RESET)"
	@docker-compose exec -T mariadb_primary mysqladmin ping -h localhost --silent && echo "$(GREEN)✅ MariaDB accessible$(RESET)" || echo "$(RED)❌ MariaDB inaccessible$(RESET)"

.PHONY: test-performance
test-performance: ## Test de performance
	@echo "$(BLUE)⚡ Test de performance...$(RESET)"
	@./tests/performance/load-test.sh

.PHONY: test-security
test-security: ## Test de sécurité
	@echo "$(BLUE)🛡️ Test de sécurité...$(RESET)"
	@./tests/security/security-scan.sh

# =============================================================================
# SAUVEGARDE ET RESTAURATION
# =============================================================================

.PHONY: backup
backup: ## Créer une sauvegarde complète
	@echo "$(GREEN)💾 Création d'une sauvegarde...$(RESET)"
	@./scripts/backup-system.sh
	@echo "$(GREEN)✅ Sauvegarde terminée$(RESET)"

.PHONY: backup-db
backup-db: ## Sauvegarder la base de données uniquement
	@echo "$(GREEN)💾 Sauvegarde de la base de données...$(RESET)"
	@mkdir -p $(DATA_PATH)/backups/mariadb
	@docker-compose exec -T mariadb_primary mysqldump -u root -p${MYSQL_ROOT_PASSWORD} --all-databases | gzip > $(DATA_PATH)/backups/mariadb/backup_$(TIMESTAMP).sql.gz
	@echo "$(GREEN)✅ Base sauvegardée : backup_$(TIMESTAMP).sql.gz$(RESET)"

.PHONY: restore
restore: ## Restaurer depuis une sauvegarde
	@echo "$(YELLOW)🔄 Restauration depuis sauvegarde...$(RESET)"
	@./scripts/restore.sh
	@echo "$(GREEN)✅ Restauration terminée$(RESET)"

.PHONY: list-backups
list-backups: ## Lister les sauvegardes disponibles
	@echo "$(BLUE)📋 Sauvegardes disponibles :$(RESET)"
	@ls -la $(DATA_PATH)/backups/system/ 2>/dev/null || echo "Aucune sauvegarde système trouvée"
	@ls -la $(DATA_PATH)/backups/mariadb/ 2>/dev/null || echo "Aucune sauvegarde MariaDB trouvée"

# =============================================================================
# DÉVELOPPEMENT ET DEBUG
# =============================================================================

.PHONY: shell-nginx
shell-nginx: ## Shell dans le conteneur Nginx
	@docker-compose exec nginx /bin/sh

.PHONY: shell-wordpress
shell-wordpress: ## Shell dans le conteneur WordPress
	@docker-compose exec wordpress_app_1 /bin/sh

.PHONY: shell-mariadb
shell-mariadb: ## Shell dans le conteneur MariaDB
	@docker-compose exec mariadb_primary /bin/sh

.PHONY: mysql
mysql: ## Accès à la console MySQL
	@docker-compose exec mariadb_primary mysql -u root -p${MYSQL_ROOT_PASSWORD}

.PHONY: wp-cli
wp-cli: ## Accès à WP-CLI
	@docker-compose exec wordpress_app_1 wp --path=/var/www/html --allow-root

.PHONY: debug
debug: ## Mode debug (affichage des logs en temps réel)
	@echo "$(YELLOW)🐛 Mode debug activé...$(RESET)"
	@docker-compose logs -f

.PHONY: debug-errors
debug-errors: ## Afficher uniquement les erreurs
	@echo "$(RED)🚨 Erreurs détectées :$(RESET)"
	@docker-compose logs | grep -i error || echo "Aucune erreur trouvée"

# =============================================================================
# NETTOYAGE ET MAINTENANCE
# =============================================================================

.PHONY: clean
clean: ## Nettoyage léger (containers arrêtés)
	@echo "$(YELLOW)🧹 Nettoyage des containers arrêtés...$(RESET)"
	@docker container prune -f
	@echo "$(GREEN)✅ Nettoyage terminé$(RESET)"

.PHONY: clean-images
clean-images: ## Supprimer les images non utilisées
	@echo "$(YELLOW)🧹 Nettoyage des images...$(RESET)"
	@docker image prune -f
	@echo "$(GREEN)✅ Images nettoyées$(RESET)"

.PHONY: clean-volumes
clean-volumes: ## Supprimer les volumes non utilisés
	@echo "$(RED)⚠️ ATTENTION : Cela supprimera TOUTES les données !$(RESET)"
	@read -p "Êtes-vous sûr ? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	@docker volume prune -f
	@echo "$(GREEN)✅ Volumes nettoyés$(RESET)"

.PHONY: clean-all
clean-all: down clean clean-images ## Nettoyage complet (sans les volumes)
	@echo "$(GREEN)✅ Nettoyage complet terminé$(RESET)"

.PHONY: purge
purge: down ## Suppression complète (avec données)
	@echo "$(RED)⚠️ SUPPRESSION COMPLÈTE DE TOUTES LES DONNÉES !$(RESET)"
	@read -p "Tapez 'DELETE' pour confirmer : " confirm && [ "$$confirm" = "DELETE" ] || exit 1
	@docker-compose down -v --remove-orphans
	@docker system prune -af --volumes
	@sudo rm -rf $(DATA_PATH)
	@echo "$(RED)✅ Suppression complète terminée$(RESET)"

# =============================================================================
# UTILITAIRES
# =============================================================================

.PHONY: update
update: ## Mettre à jour les images Docker
	@echo "$(BLUE)🔄 Mise à jour des images...$(RESET)"
	@docker-compose pull
	@$(MAKE) build-no-cache
	@echo "$(GREEN)✅ Images mises à jour$(RESET)"

.PHONY: ssl-renew
ssl-renew: ## Renouveler les certificats SSL
	@echo "$(GREEN)🔐 Renouvellement des certificats SSL...$(RESET)"
	@./scripts/ssl-renew.sh
	@docker-compose restart nginx
	@echo "$(GREEN)✅ Certificats renouvelés$(RESET)"

.PHONY: permissions
permissions: ## Corriger les permissions des fichiers
	@echo "$(BLUE)🔧 Correction des permissions...$(RESET)"
	@sudo chown -R $(USER_ID):$(GROUP_ID) $(DATA_PATH)
	@find $(DATA_PATH) -type d -exec chmod 755 {} \;
	@find $(DATA_PATH) -type f -exec chmod 644 {} \;
	@chmod 600 $(DATA_PATH)/ssl/*.key 2>/dev/null || true
	@echo "$(GREEN)✅ Permissions corrigées$(RESET)"

.PHONY: config-check
config-check: ## Vérifier la configuration
	@echo "$(BLUE)🔍 Vérification de la configuration...$(RESET)"
	@docker-compose config
	@echo "$(GREEN)✅ Configuration valide$(RESET)"

# =============================================================================
# PRODUCTION ET DÉPLOIEMENT
# =============================================================================

.PHONY: deploy-prod
deploy-prod: ## Déploiement en production
	@echo "$(GREEN)🚀 Déploiement en production...$(RESET)"
	@cp config/production/.env.prod $(ENV_FILE)
	@$(MAKE) setup-ssl
	@$(MAKE) build-no-cache
	@$(MAKE) up
	@$(MAKE) test
	@echo "$(GREEN)✅ Déploiement production terminé$(RESET)"

.PHONY: deploy-staging
deploy-staging: ## Déploiement en staging
	@echo "$(BLUE)🚀 Déploiement en staging...$(RESET)"
	@cp config/staging/.env.staging $(ENV_FILE)
	@$(MAKE) up-build
	@echo "$(BLUE)✅ Déploiement staging terminé$(RESET)"

.PHONY: rollback
rollback: ## Revenir à la dernière sauvegarde
	@echo "$(YELLOW)⏪ Rollback en cours...$(RESET)"
	@$(MAKE) down
	@$(MAKE) restore
	@$(MAKE) up
	@echo "$(GREEN)✅ Rollback terminé$(RESET)"

# =============================================================================
# MONITORING CONTINU
# =============================================================================

.PHONY: monitor
monitor: ## Démarrer le monitoring continu
	@echo "$(BLUE)📊 Démarrage du monitoring...$(RESET)"
	@./scripts/monitor-stack.sh --daemon

.PHONY: monitor-stop
monitor-stop: ## Arrêter le monitoring
	@echo "$(YELLOW)⏹️ Arrêt du monitoring...$(RESET)"
	@pkill -f monitor-stack.sh || true

# =============================================================================
# INFORMATIONS ET AIDE
# =============================================================================

.PHONY: info
info: ## Afficher les informations système
	@echo "$(BLUE)ℹ️ Informations système$(RESET)"
	@echo "Projet : $(PROJECT_NAME)"
	@echo "Utilisateur : c-andriam ($(USER_ID):$(GROUP_ID))"
	@echo "Répertoire données : $(DATA_PATH)"
	@echo "Docker version : $(shell docker --version)"
	@echo "Docker Compose version : $(shell docker-compose --version)"
	@echo "Espace disque : $(shell df -h $(DATA_PATH) | tail -1 | awk '{print $$4}') disponible"

.PHONY: urls
urls: ## Afficher les URLs d'accès
	@echo "$(BLUE)🌐 URLs d'accès :$(RESET)"
	@echo "Site principal :"
	@echo "  - https://c-andriam.42.fr"
	@echo "  - https://localhost"
	@echo "  - https://$(shell hostname -I | cut -d' ' -f1)"
	@echo ""
	@echo "Administration WordPress :"
	@echo "  - https://c-andriam.42.fr/wp-admin"
	@echo "  - https://localhost/wp-admin"
	@echo ""
	@echo "Identifiants par défaut :"
	@echo "  - Utilisateur : c-andriam"
	@echo "  - Mot de passe : (voir fichier .env)"

.PHONY: troubleshoot
troubleshoot: ## Guide de dépannage
	@echo "$(YELLOW)🔧 Guide de dépannage$(RESET)"
	@echo ""
	@echo "1. Vérifier l'état des services :"
	@echo "   make status"
	@echo ""
	@echo "2. Vérifier les logs :"
	@echo "   make logs"
	@echo ""
	@echo "3. Tester la connectivité :"
	@echo "   make test-connectivity"
	@echo ""
	@echo "4. Redémarrer les services :"
	@echo "   make restart"
	@echo ""
	@echo "5. Reconstruction complète :"
	@echo "   make down && make build-no-cache && make up"
	@echo ""
	@echo "Pour plus d'aide : make help"

# =============================================================================
# CIBLES PAR DÉFAUT
# =============================================================================

.DEFAULT_GOAL := help

# Éviter l'exécution accidentelle de commandes dangereuses
.PHONY: confirm-dangerous
confirm-dangerous:
	@echo "$(RED)⚠️ ATTENTION : Cette action est irréversible !$(RESET)"
	@read -p "Tapez 'CONFIRM' pour continuer : " confirm && [ "$$confirm" = "CONFIRM" ]

# Ajouter la confirmation aux commandes dangereuses
clean-volumes: confirm-dangerous
purge: confirm-dangerous
```

### 8.4 Sécurité et bonnes pratiques

#### Configuration sécurisée

**Dockerfile sécurisé pour Nginx :**
```dockerfile
FROM alpine:3.19

# Installation avec utilisateur non-root
RUN addgroup -g 1001 nginx && \
    adduser -D -s /bin/sh -u 1001 -G nginx nginx

# Installation des packages
RUN apk update && \
    apk add --no-cache \
        nginx \
        openssl \
        curl && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

# Configuration des répertoires
RUN mkdir -p /var/log/nginx && \
    mkdir -p /var/cache/nginx && \
    mkdir -p /etc/ssl/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /etc/ssl/nginx

# Copie des configurations
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/conf.d/ /etc/nginx/conf.d/
COPY tools/entrypoint.sh /usr/local/bin/

# Permissions sécurisées
RUN chmod 644 /etc/nginx/nginx.conf && \
    chmod 644 /etc/nginx/conf.d/*.conf && \
    chmod +x /usr/local/bin/entrypoint.sh

# Test de configuration
RUN nginx -t

# Utilisateur non-root
USER nginx

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

EXPOSE 80 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
```

**Configuration Nginx sécurisée :**
```nginx
# Configuration sécurisée complète
user nginx;
worker_processes auto;
worker_rlimit_nofile 65535;

# Masquer la version
server_tokens off;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    # Configuration de base
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Optimisations
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    
    # Buffers et timeouts sécurisés
    client_max_body_size 50M;
    client_body_buffer_size 128k;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 4k;
    client_body_timeout 12;
    client_header_timeout 12;
    send_timeout 10;
    
    # Sécurité globale
    add_header X-Frame-Options SAMEORIGIN always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self';" always;
    
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/m;
    limit_req_zone $binary_remote_addr zone=general:10m rate=50r/m;
    
    # Géo-blocking (exemple)
    geo $blocked_country {
        default 0;
        # Bloquer certains pays si nécessaire
        # CN 1;  # Chine
        # RU 1;  # Russie
    }
    
    # Bloquer les bad bots
    map $http_user_agent $blocked_agent {
        default 0;
        ~*bot 1;
        ~*crawler 1;
        ~*spider 1;
        ~*wget 1;
        ~*curl 1;
        "~*python" 1;
    }
    
    # Logs sécurisés
    log_format secure '$remote_addr - $remote_user [$time_local] '
                     '"$request" $status $body_bytes_sent '
                     '"$http_referer" "$http_user_agent" '
                     '$request_time $upstream_response_time '
                     '$request_id';
    
    access_log /var/log/nginx/access.log secure;
    error_log /var/log/nginx/error.log warn;
    
    # Redirection HTTP vers HTTPS
    server {
        listen 80;
        server_name c-andriam.42.fr localhost;
        
        # Bloquer les agents malveillants
        if ($blocked_agent) {
            return 403;
        }
        
        return 301 https://$server_name$request_uri;
    }
    
    # Configuration HTTPS principale
    server {
        listen 443 ssl http2;
        server_name c-andriam.42.fr localhost;
        root /var/www/html;
        index index.php index.html;
        
        # Certificats SSL
        ssl_certificate /etc/ssl/nginx/nginx.crt;
        ssl_certificate_key /etc/ssl/nginx/nginx.key;
        
        # Configuration SSL sécurisée
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-CHACHA20-POLY1305;
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;
        ssl_session_tickets off;
        
        # HSTS
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
        
        # Blocage géographique
        if ($blocked_country) {
            return 403;
        }
        
        # Blocage des agents malveillants
        if ($blocked_agent) {
            return 403;
        }
        
        # Rate limiting général
        limit_req zone=general burst=20 nodelay;
        
        # Interdire l'accès aux fichiers sensibles
        location ~ /\.(ht|git|svn) {
            deny all;
            return 404;
        }
        
        location ~ /wp-config\.php {
            deny all;
            return 404;
        }
        
        location ~ /readme\.html {
            deny all;
            return 404;
        }
        
        # Sécuriser wp-admin
        location ^~ /wp-admin/ {
            # Rate limiting pour l'admin
            limit_req zone=login burst=5 nodelay;
            
            # Optionnel : Restriction IP pour l'admin
            # allow 192.168.1.0/24;
            # deny all;
            
            location ~ \.php$ {
                try_files $uri =404;
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass wordpress_app_1:9000;
                fastcgi_index index.php;
                include fastcgi_params;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                fastcgi_param PATH_INFO $fastcgi_path_info;
                
                # Timeouts sécurisés
                fastcgi_connect_timeout 60s;
                fastcgi_send_timeout 60s;
                fastcgi_read_timeout 60s;
            }
        }
        
        # Configuration PHP générale
        location ~ \.php$ {
            try_files $uri =404;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass wordpress_app_1:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param PATH_INFO $fastcgi_path_info;
            fastcgi_param HTTPS on;
        }
        
        # Fichiers statiques avec cache et sécurité
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            add_header Vary Accept-Encoding;
            
            # Sécurité pour les assets
            add_header X-Content-Type-Options nosniff always;
        }
        
        # Configuration WordPress
        location / {
            try_files $uri $uri/ /index.php?$args;
        }
        
        # Endpoint de santé
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
```

#### Variables d'environnement sécurisées

**Fichier .env.example :**
```bash
# =============================================================================
# CONFIGURATION INCEPTION - EXEMPLE SÉCURISÉ
# =============================================================================

# IMPORTANT: Copiez ce fichier vers .env et modifiez les valeurs !
# NE JAMAIS commiter le fichier .env en production !

# =============================================================================
# CONFIGURATION GÉNÉRALE
# =============================================================================
PROJECT_NAME=inception
DOMAIN=c-andriam.42.fr
USER_ID=1000
GROUP_ID=1000
DATA_PATH=/home/c-andriam/data

# =============================================================================
# CONFIGURATION MYSQL/MARIADB
# =============================================================================
MYSQL_ROOT_PASSWORD=CHANGEME_root_password_very_secure_123!
MYSQL_DATABASE=wordpress_db
MYSQL_USER=wp_user
MYSQL_PASSWORD=CHANGEME_wp_password_secure_456!

# Configuration réplication (pour setup master-slave)
MYSQL_REPLICATION_PASSWORD=CHANGEME_replication_password_789!

# =============================================================================
# CONFIGURATION WORDPRESS
# =============================================================================
WP_HOME=https://c-andriam.42.fr
WP_SITEURL=https://c-andriam.42.fr

# Utilisateur administrateur
WP_ADMIN_USER=c-andriam
WP_ADMIN_PASSWORD=CHANGEME_admin_password_secure_ABC!
WP_ADMIN_EMAIL=c-andriam@student.42.fr

# Utilisateur standard
WP_USER=visitor
WP_USER_PASSWORD=CHANGEME_user_password_secure_DEF!
WP_USER_EMAIL=visitor@example.com

# Clés de sécurité WordPress (générées automatiquement)
WP_AUTH_KEY=your-unique-auth-key-here
WP_SECURE_AUTH_KEY=your-unique-secure-auth-key-here
WP_LOGGED_IN_KEY=your-unique-logged-in-key-here
WP_NONCE_KEY=your-unique-nonce-key-here
WP_AUTH_SALT=your-unique-auth-salt-here
WP_SECURE_AUTH_SALT=your-unique-secure-auth-salt-here
WP_LOGGED_IN_SALT=your-unique-logged-in-salt-here
WP_NONCE_SALT=your-unique-nonce-salt-here

# =============================================================================
# CONFIGURATION REDIS (BONUS)
# =============================================================================
REDIS_PASSWORD=CHANGEME_redis_password_secure_GHI!

# =============================================================================
# CONFIGURATION MONITORING
# =============================================================================
ALERT_EMAIL=c-andriam@student.42.fr
BACKUP_SCHEDULE="0 2 * * *"  # 2h du matin chaque jour
BACKUP_RETENTION_DAYS=30

# =============================================================================
# CONFIGURATION DÉVELOPPEMENT
# =============================================================================
WP_DEBUG=false
WP_DEBUG_LOG=false
WP_DEBUG_DISPLAY=false

# Mode développement (true/false)
DEV_MODE=false

# =============================================================================
# NOTES DE SÉCURITÉ
# =============================================================================
# 1. Changez TOUS les mots de passe par défaut !
# 2. Utilisez des mots de passe longs et complexes (min 16 caractères)
# 3. Générez de nouvelles clés WordPress via https://api.wordpress.org/secret-key/1.1/salt/
# 4. En production, utilisez un gestionnaire de secrets (ex: Docker Secrets)
# 5. Ne jamais exposer ce fichier publiquement
# 6. Auditez régulièrement les accès et permissions
```

---

## 9. 📚 Annexes et références

### 9.1 Commandes de référence rapide

#### Docker essentiels

```bash
# Images
docker images                          # Lister les images
docker build -t nom:tag .              # Construire une image
docker rmi image_id                     # Supprimer une image
docker pull image:tag                   # Télécharger une image

# Conteneurs
docker ps                              # Conteneurs en cours
docker ps -a                           # Tous les conteneurs
docker run -d --name nom image         # Créer et démarrer
docker start/stop/restart nom          # Contrôler un conteneur
docker exec -it nom /bin/sh           # Shell dans conteneur
docker logs -f nom                     # Logs en temps réel
docker rm nom                          # Supprimer conteneur

# Volumes et réseaux
docker volume ls                       # Lister volumes
docker network ls                      # Lister réseaux
docker system prune                    # Nettoyage général
```

#### Docker Compose essentiels

```bash
# Gestion des services
docker-compose up -d                   # Démarrer en arrière-plan
docker-compose down                    # Arrêter et supprimer
docker-compose restart service         # Redémarrer un service
docker-compose build --no-cache        # Reconstruire sans cache
docker-compose logs -f service         # Logs d'un service

# Maintenance
docker-compose ps                      # État des services
docker-compose exec service cmd        # Exécuter commande
docker-compose config                  # Valider configuration
```

#### Nginx essentiels

```bash
# Test et rechargement
nginx -t                              # Tester configuration
nginx -s reload                       # Recharger configuration
nginx -s stop                         # Arrêter Nginx

# Logs
tail -f /var/log/nginx/access.log     # Logs d'accès
tail -f /var/log/nginx/error.log      # Logs d'erreurs
```

#### MySQL/MariaDB essentiels

```bash
# Connexion
mysql -u user -p database             # Se connecter
mysqladmin ping                        # Tester connexion

# Sauvegarde/Restauration
mysqldump -u user -p db > backup.sql  # Sauvegarder
mysql -u user -p db < backup.sql      # Restaurer

# Monitoring
SHOW PROCESSLIST;                     # Processus actifs
SHOW STATUS;                          # Statut serveur
```

### 9.2 Résolution de problèmes courants

#### Problèmes Docker

**Erreur "permission denied" :**
```bash
# Solution 1: Ajouter utilisateur au groupe docker
sudo usermod -aG docker $USER
newgrp docker

# Solution 2: Corriger permissions
sudo chown $USER:$USER ~/.docker -R
sudo chmod g+rwx ~/.docker -R
```

**Erreur "no space left on device" :**
```bash
# Nettoyer Docker
docker system prune -af --volumes
docker builder prune -af

# Vérifier l'espace
df -h
du -sh /var/lib/docker/*
```

**Port déjà utilisé :**
```bash
# Trouver qui utilise le port
sudo netstat -tulpn | grep :80
sudo lsof -i :80

# Arrêter le service
sudo systemctl stop apache2  # ou nginx
```

#### Problèmes Nginx

**Erreur de configuration :**
```bash
# Tester la configuration
nginx -t

# Vérifier la syntaxe
docker-compose exec nginx nginx -t

# Logs détaillés
docker-compose logs nginx
```

**Problème SSL :**
```bash
# Vérifier certificats
openssl x509 -in cert.crt -text -noout
openssl verify cert.crt

# Tester SSL
openssl s_client -connect localhost:443 -servername c-andriam.42.fr
```

#### Problèmes WordPress

**Erreur de connexion base de données :**
```bash
# Vérifier variables environnement
docker-compose exec wordpress env | grep DB

# Tester connexion manuelle
docker-compose exec wordpress mysql -h mariadb -u $MYSQL_USER -p$MYSQL_PASSWORD
```

**Problème de permissions :**
```bash
# Corriger permissions WordPress
docker-compose exec wordpress chown -R www-data:www-data /var/www/html
docker-compose exec wordpress find /var/www/html -type d -exec chmod 755 {} \;
docker-compose exec wordpress find /var/www/html -type f -exec chmod 644 {} \;
```

### 9.3 Ressources et documentation

#### Documentation officielle

- **Docker :** https://docs.docker.com/
- **Docker Compose :** https://docs.docker.com/compose/
- **Nginx :** https://nginx.org/en/docs/
- **MariaDB :** https://mariadb.org/documentation/
- **WordPress :** https://developer.wordpress.org/
- **Alpine Linux :** https://wiki.alpinelinux.org/

#### Outils utiles

**Générateurs :**
- Certificats SSL : `openssl` ou Let's Encrypt
- Mots de passe : `openssl rand -base64 32`
- Clés WordPress : https://api.wordpress.org/secret-key/1.1/salt/

**Monitoring :**
- Logs : `docker-compose logs`
- Ressources : `docker stats`
- Réseau : `netstat`, `ss`, `lsof`

**Testing :**
- HTTP : `curl`, `wget`
- SSL : `openssl s_client`
- Performance : `ab` (Apache Bench), `wrk`

#### Commandes de diagnostic

```bash
# Informations système
uname -a                              # Kernel
free -h                               # Mémoire
df -h                                 # Disque
ps aux                                # Processus
netstat -tulpn                        # Ports réseau

# Docker diagnostic
docker version                        # Version Docker
docker info                          # Info système Docker
docker-compose version               # Version Compose

# Vérification services
systemctl status docker              # État Docker
journalctl -u docker                 # Logs Docker système
```

### 9.4 Checklist de déploiement

#### Pré-déploiement

- [ ] Variables d'environnement configurées
- [ ] Mots de passe sécurisés changés
- [ ] Certificats SSL générés
- [ ] Permissions des fichiers correctes
- [ ] Tests de configuration passés
- [ ] Sauvegarde des données existantes

#### Déploiement

- [ ] `make setup` exécuté
- [ ] `make build` réussi
- [ ] `make up` démarré sans erreurs
- [ ] Services en état "healthy"
- [ ] Tests de connectivité OK
- [ ] Administration WordPress accessible

#### Post-déploiement

- [ ] Monitoring activé
- [ ] Sauvegardes automatiques configurées
- [ ] Logs correctement générés
- [ ] Performance acceptable
- [ ] Sécurité vérifiée
- [ ] Documentation mise à jour

---

## 🎯 Conclusion

Ce guide complet vous a accompagné dans l'apprentissage de toutes les technologies nécessaires pour créer une infrastructure web moderne et robuste. Vous maîtrisez maintenant :

### **Compétences acquises :**

✅ **Docker et conteneurisation** - Création d'images optimisées et gestion de conteneurs
✅ **Orchestration avec Docker Compose** - Déploiement de stacks multi-services
✅ **Administration web avec Nginx** - Configuration sécurisée et performante
✅ **Gestion de bases de données** - MariaDB/MySQL en production
✅ **Développement WordPress** - Installation, configuration et customisation
✅ **Automatisation avec Bash** - Scripts de déploiement et maintenance
✅ **Architecture système** - Conception d'infrastructures scalables

### **Projet Inception réussi :**

Votre stack WordPress est maintenant :
- **Sécurisée** avec HTTPS, headers de sécurité et isolation réseau
- **Performante** avec optimisations Nginx et cache Redis
- **Maintenable** avec scripts d'automatisation et monitoring
- **Robuste** avec sauvegardes automatiques et recovery
- **Conforme aux exigences 42** et aux standards professionnels

### **Prochaines étapes :**

1. **Approfondissement :** Kubernetes, CI/CD, Infrastructure as Code
2. **Spécialisation :** DevOps, SRE, Cloud Architecture
3. **Certifications :** Docker, Kubernetes, Cloud Providers
4. **Projets avancés :** Microservices, Service Mesh, Observability

**Félicitations ! Vous avez les bases solides pour devenir un expert en infrastructure moderne.** 🎉

---

*Guide créé pour la formation 42 - Version 1.0 - Juillet 2025*
*Pour toute question ou amélioration : créez une issue ou contribuez au projet*
