# 📱 **OtakuGo – Application Mobile de Recommandation d’Animes**

Projet réalisé dans le cadre du BUT Informatique – IUT de Villetaneuse

---

##  **Équipe du projet**

Ce projet a été construit par une équipe de 5 membres :

* **Manel Belaidouni**
* **Oumaima El Khadraoui**
* **Diarra Konté**
* **Séraphin Eyala**
* **Johann Zidee**

---

##  **Objectif du projet**

L’objectif d’**OtakuGo** est de proposer une **application mobile indépendante (no backend)** capable de recommander dynamiquement des animes **en fonction des préférences de l’utilisateur**, sans nécessiter de connexion internet.

Le concept repose sur un fonctionnement **mobile-first**, entièrement **local**, garantissant :

* la **souveraineté des données** de l’utilisateur,
* une utilisation hors ligne après chargement initial,
* des recommandations basées sur les **choix successifs** de l’utilisateur.

---

##  **Fonctionnalités principales**

###  Recommandation adaptative

L’utilisateur choisit entre deux animes. L’application apprend et affine ses recommandations en fonction :

* des genres,
* des thèmes,
* des catégories démographiques (Shounen, Seinen, etc.).

###  Base de données locale

Les animes proviennent d’un dataset Kaggle comportant :
`anime_id, image_url, name, english_name, score, genres, themes, demographics, synopsis, episodes, rating`

Le JSON est stocké localement dans `/assets/`.

###  Affichage visuel moderne

* Cartes d’animés avec :
  image,
  nom,
  genres
* Style sombre inspiré des plateformes otaku (Netflix, MAL, Crunchyroll).

###  Chargement optimisé

* Utilisation de `cached_network_image` pour charger et **mettre en cache** les images.
* Affichage rapide + support hors-ligne après premier affichage.

---

##  **Technologies utilisées**

| Domaine                | Technologie          |
| ---------------------- | -------------------- |
| Framework              | **Flutter**          |
| Langage                | **Dart**             |
| Gestion UI             | Material Design      |
| Cache des images       | cached_network_image |
| Base de données locale | JSON (assets)        |
| Plateforme             | Android              |

---

##  **Installation et exécution**

### 1️ Cloner le projet

```bash
git clone https://github.com/votre-repo/otakugo.git
cd otakugo
```

### 2️ Installer les dépendances Flutter

```bash
flutter pub get
```

### 3️ Exécuter sur un appareil ou un émulateur Android

```bash
flutter run
```

---

##  **Aperçu**

(à ajouter plus tard si vous voulez des captures d’écran)

---

##  **Défis rencontrés**

* Fichier JSON volumineux nécessitant nettoyage (`NaN`, valeurs manquantes).
* Optimisation du parsing (gestion des nulls, valeurs incohérentes).
* Mise en cache de milliers d’images pour un affichage fluide.
* Structuration d’une interface propre et scalable.

---

##  **Améliorations futures**

* Ajout d’un vrai système de recommandation (pondération multi-genres).
* Page de détails complète pour chaque anime.
* Mode 100 % hors-ligne (préchargement total des images).
* Filtrage par genres / thèmes.
* Animation lors du choix entre deux animes.

---
