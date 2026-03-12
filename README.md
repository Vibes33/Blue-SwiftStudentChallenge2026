# Blue — Swift Student Challenge 2026

Blue est une application iOS éducative sur la biodiversité marine.

Le projet propose une expérience immersive pour :
- découvrir des espèces marines par région,
- comprendre les écosystèmes,
- tester ses connaissances via des quiz,
- suivre sa progression (points, niveaux, succès),
- et orienter l’utilisateur vers des ONG de protection des océans.

---

## Table des matières

- [1) Aperçu du projet](#1-apercu-du-projet)
- [2) Technologies utilisées](#2-technologies-utilisees)
- [3) Arborescence du projet](#3-arborescence-du-projet)
- [4) Fonctionnalités de l’application](#4-fonctionnalites-de-lapplication)
- [5) Données et contenu pédagogique](#5-donnees-et-contenu-pedagogique)
- [6) Persistance et progression](#6-persistance-et-progression)
- [7) Accessibilité](#7-accessibilite)
- [8) Lancer le projet](#8-lancer-le-projet)
- [9) Pistes d’amélioration](#9-pistes-damelioration)

---

## 1) Aperçu du projet

Blue est une app SwiftUI orientée sensibilisation environnementale.

L’utilisateur peut naviguer entre plusieurs zones marines (Californie, Bretagne, Méditerranée, Norvège), consulter des fiches d’espèces, jouer à des quiz par difficulté, visualiser les effets d’une disparition d’espèce dans un simulateur d’écosystème, puis consulter son profil global.

L’interface est organisée autour de 5 onglets principaux :
- `Home`
- `Discover`
- `Quiz`
- `Map`
- `Profile`

---

## 2) Technologies utilisées

### Langage et architecture
- **Swift 6** (package déclaré avec `swift-tools-version: 6.0`)
- **SwiftUI** pour l’UI déclarative
- **Observation (`@Observable`)** pour la gestion d’état moderne

### Frameworks Apple
- **MapKit** : carte interactive, polygones de régions, annotations
- **Charts (Swift Charts)** : graphiques (timeline et simulation d’écosystème)
- **Metal Shader (`OceanShader.metal`)** : effet visuel de caustiques sous-marines
- **UIKit interop** : haptics (`UIImpactFeedbackGenerator`, `UINotificationFeedbackGenerator`), fenêtre overlay pour bannière de succès

### Persistance locale
- **UserDefaults** pour sauvegarder :
  - nom utilisateur,
  - région sélectionnée,
  - cartes lues,
  - quiz complétés,
  - progression par région,
  - succès débloqués,
  - préférences d’accessibilité,
  - état de l’onboarding.

### Dépendances externes
- Aucune dépendance tierce détectée (stack 100% Apple SDK).

---

## 3) Arborescence du projet

Arborescence fonctionnelle (simplifiée et commentée) :

```text
Blue 2/
├── .gitignore
├── BlueV2.zip
└── Blue.swiftpm/
    ├── BlueApp.swift
    ├── Package.swift
    ├── Assets.xcassets/
    │   ├── AppIcon.appiconset/
    │   ├── AccentColor.colorset/
    │   ├── Badge1.imageset/
    │   ├── Badge2.imageset/
    │   ├── Badge3.imageset/
    │   ├── imagecalifornie*.imageset/
    │   ├── imagebretagne*.imageset/
    │   ├── imagemed*.imageset/
    │   └── imagenor*.imageset/
    ├── Components/
    │   ├── HomeComponents.swift
    │   └── DiscoverComponents.swift
    ├── Managers/
    │   ├── AccessibilityManager.swift
    │   ├── ProgressManager.swift
    │   └── RegionManager.swift
    ├── Models/
    │   ├── Region.swift
    │   ├── RegionInfo.swift
    │   ├── Species.swift
    │   ├── Quiz.swift
    │   └── Ecosystem.swift
    ├── Views/
    │   ├── OnboardingView.swift
    │   ├── ContentView.swift
    │   ├── HomeView.swift
    │   ├── DiscoverView.swift
    │   ├── QuizView.swift
    │   ├── QuizSessionView.swift
    │   ├── MapView.swift
    │   ├── ProfileView.swift
    │   ├── SettingsView.swift
    │   ├── AboutView.swift
    │   └── EcosystemView.swift
    └── Shaders/
        ├── OceanBackgroundView.swift
        └── OceanShader.metal
```

### Rôle des dossiers
- `Views/` : écrans complets.
- `Components/` : composants réutilisables UI (cards, sections, badges, etc.).
- `Models/` : données métier (régions, espèces, quiz, simulation).
- `Managers/` : état global, logique de progression, accessibilité, sélection région.
- `Shaders/` : rendu visuel immersif de fond océanique.
- `Assets.xcassets/` : images des espèces, badges, icônes app.

---

## 4) Fonctionnalités de l’application

### 4.1 Onboarding
- Parcours multi-écrans (auto-progression + navigation manuelle).
- Présentation du concept, des quiz, de la carte, de l’accessibilité et des ONG.
- État sauvegardé (`hasCompletedOnboarding`).

### 4.2 Home
- Tableau de bord par région active.
- Carte de progression niveau/points.
- Statistiques locales (cartes lues, quiz complétés).
- Faits marquants et chiffres de la région.
- Accès direct au simulateur d’écosystème.

### 4.3 Discover
- Introduction contextuelle de la région.
- Listes d’espèces emblématiques et protégées.
- Fiches espèces détaillées (statut, habitat, menaces, profondeur, tendances de population).
- Lecture d’une fiche = progression + possibilité de débloquer des succès.
- Section ONG avec liens externes (ouverture Safari après confirmation).

### 4.4 Quiz
- Quiz par niveau de difficulté (`Easy`, `Intermediate`, `Hard`, `Expert`).
- Session immersive plein écran :
  - réponses mélangées,
  - feedback visuel + haptique,
  - score final,
  - confettis en cas de réussite.
- Attribution de points selon difficulté.

### 4.5 Map
- Carte mondiale interactive.
- Polygones pour zones marines + annotations cliquables.
- Sélection de région avec recentrage caméra.
- Distinction visuelle entre régions actives et « coming soon ».

### 4.6 Ecosystem Simulator
- Simulation de chaîne trophique interactive.
- Suppression d’une espèce -> cascade d’effets (prédateurs/proies, variations population).
- Indicateur de santé globale de l’écosystème.
- Journal d’événements + historique des populations.
- Visualisations via Charts.

### 4.7 Profile
- Édition du nom utilisateur.
- Niveau global + progression vers niveau suivant.
- Statistiques globales (points, cartes lues, régions visitées, succès).
- Liste des succès débloqués + grille complète des succès.
- Accès à `Settings` et `About`.

### 4.8 Système de succès (Achievements)
- Bannière globale au-dessus de toute l’UI (fenêtre overlay dédiée).
- File d’attente des notifications pour affichage séquentiel.
- Plusieurs familles de succès :
  - visite de région,
  - découverte d’espèces,
  - completion de cartes/quiz,
  - milestones,
  - secret.

---

## 5) Données et contenu pédagogique

D’après les modèles actuels du projet :

- **Régions modélisées** : 8
  - **Disponibles** : 4 (`california`, `bretagne`, `mediterranean`, `norway`)
  - **À venir** : 4 (`great_barrier_reef`, `caribbean`, `galapagos`, `japan`)
- **Espèces documentées** : 24 (6 par région disponible)
- **Quiz** : 16 au total (4 par région disponible)
- **Questions** : 80 (5 par quiz)
- **Succès (`AchievementType`)** : 45

---

## 6) Persistance et progression

### Système de points (ProgressManager)
- Lecture d’une fiche espèce : **+3 points**
- Quiz :
  - `Easy` : **+6**
  - `Intermediate` : **+9**
  - `Hard` : **+12**
  - `Expert` : **+18**
- Passage de niveau : tous les **18 points**.

### Ce qui est sauvegardé
- progression par région,
- cartes consultées,
- quiz validés,
- succès,
- préférences utilisateur et accessibilité.

---

## 7) Accessibilité

Le projet intègre une vraie couche accessibilité via `AccessibilityManager` :

- **Larger Text** (taille de police augmentée),
- **Reduce Animations** (désactive animations lourdes/confettis),
- **High Contrast** (opacités et contrastes renforcés),
- **Voice Descriptions** (labels adaptés, intégration VoiceOver).

Les composants UI s’adaptent dynamiquement à ces options.

---

## 8) Lancer le projet

### Prérequis
- Xcode récent avec support SwiftUI / MapKit / Charts / Metal.

### Ouverture
1. Ouvrir le dossier `Blue 2`.
2. Ouvrir `Blue.swiftpm` (package SwiftPM d’application iOS).
3. Lancer sur simulateur iPhone/iPad.

> Note : `Package.swift` déclare la plateforme iOS à `26.0`.

---

## 9) Pistes d’amélioration

- Ajouter une couche de persistance plus riche (ex. `SwiftData`) pour historique détaillé.
- Ajouter des tests unitaires ciblés sur `ProgressManager` et `EcosystemState`.
- Externaliser les contenus (`Species`, `Quiz`, `RegionInfo`) en JSON/API pour faciliter l’évolution.
- Ajouter une localisation complète FR/EN (les textes sont actuellement majoritairement en anglais dans le code source).
- Optimiser le poids des assets images et du zip embarqué dans le repo.

---

Si tu veux, je peux aussi te générer une **version courte orientée jury/portfolio** (1 page) et une **version technique développeur** (plus détaillée) en complément.