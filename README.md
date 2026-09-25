<p align="center">
  <img src="assets/logo.png" alt="LevelUp-Bot Logo" width="650">
</p>

<h1 align="center">🌿 LevelUp-Bot</h1>

<p align="center">
  <strong>Bot d’automatisation pour Gen1Recomp sur Pokémon Rouge, Bleu et Jaune</strong>
</p>

<p align="center">
  ⚔️ Combats automatiques • 🎯 Captures • ✨ Détection shiny • 🧠 Choix intelligent des attaques
</p>

<p align="center">
  <a href="https://github.com/Leo0957/LevulUp-Bot/releases/latest">
    <img src="https://img.shields.io/github/v/release/Leo0957/LevulUp-Bot?style=for-the-badge&logo=github" alt="Release">
  </a>
  <img src="https://img.shields.io/badge/Lua-Mod-2C2D72?style=for-the-badge&logo=lua&logoColor=white" alt="Lua">
  <img src="https://img.shields.io/badge/Gen1Recomp-0.2.60+-success?style=for-the-badge" alt="Gen1Recomp">
</p>

<p align="center">
  <a href="https://github.com/Leo0957/LevulUp-Bot/releases/latest">⬇️ Télécharger</a>
  •
  <a href="#-installation">📦 Installation</a>
  •
  <a href="#-fonctionnalités">🚀 Fonctionnalités</a>
  •
  <a href="#️-configuration">⚙️ Configuration</a>
</p>

---

## 📖 Présentation

**LevelUp-Bot** est un mod développé en **Lua** pour **Gen1Recomp**.

Son objectif est d’automatiser les rencontres sauvages dans Pokémon Rouge, Bleu et Jaune.

Le bot peut notamment :

- 🌿 marcher automatiquement dans les hautes herbes ;
- ⚔️ gérer les combats sauvages ;
- 🧠 choisir automatiquement la meilleure attaque ;
- 🎯 capturer les Pokémon non possédés ;
- ✨ détecter les Pokémon shiny ;
- 📚 gérer certaines montées de niveau et nouvelles attaques ;
- 🏥 retourner se soigner dans certaines situations ;
- 📊 afficher des informations directement dans un HUD.

> 🟢 **Version actuelle : 3.0.2**  
> 🎮 Compatible avec **Gen1Recomp >= 0.2.60**

---

## 🚀 Fonctionnalités

| Fonctionnalité | État | Description |
|---|:---:|---|
| 🌿 Marche automatique | ✅ | Se déplace automatiquement dans les hautes herbes |
| ⚔️ Combat automatique | ✅ | Lance et gère automatiquement les combats sauvages |
| 🧠 Choix intelligent d’attaque | ✅ | Analyse dégâts, type, STAB, précision et PP |
| 🎯 Capture automatique | ✅ | Capture les Pokémon non possédés |
| ✨ Détection shiny | ✅ | Arrête immédiatement le bot si un shiny apparaît |
| 📈 Gestion XP | ✅ | Gère les écrans d’expérience et montées de niveau |
| 🧬 Évolution | ✅ | Laisse les évolutions se terminer normalement |
| 📚 Nouvelle attaque | ✅ | Compare les attaques avant d’en remplacer une |
| 📊 HUD | ✅ | Affiche l’état du bot et différentes statistiques |
| 🏥 Soin automatique | 🧪 | Peut retourner au Centre Pokémon dans certaines situations |
| ⏯️ Pause rapide | ✅ | Activation / pause avec F6 ou Tab |

---

## 📦 Installation

### 1️⃣ Télécharger le mod

Rendez-vous dans :

👉 **[Releases GitHub](https://github.com/Leo0957/LevulUp-Bot/releases/latest)**

Téléchargez :

```text
auto_grass_battler.zip
```

### 2️⃣ Installer dans Gen1Recomp

1. 🎮 Lancez **Gen1Recomp**
2. Ouvrez le menu **MODS**
3. Cliquez sur **Import mod .zip**
4. Sélectionnez `auto_grass_battler.zip`
5. Ne décompressez pas le fichier
6. Activez **Auto Grass Battler**
7. Lancez Pokémon Rouge, Bleu ou Jaune

> 💾 **Conseil :** sauvegardez votre partie avant la première utilisation.

---

## 🎮 Utilisation

Placez votre personnage dans les **hautes herbes**.

Idéalement, laissez :

```text
⬅️ 1 case libre | 🌿 Joueur 🌿 | 1 case libre ➡️
```

Le bot peut ensuite alterner entre la gauche et la droite afin de déclencher des rencontres sauvages.

### ⌨️ Commandes

| Action | Touche |
|---|---|
| ▶️ Activer le bot | `F6` |
| ⏸️ Mettre en pause | `F6` |
| 🔁 Touche secondaire | `Tab` |
| ⚙️ Ouvrir les options | `F10 → MODS → Auto Grass Battler → OPTIONS` |

Lorsque le bot fonctionne correctement, le HUD peut afficher :

```text
BOT ACTIF
HERBE DETECTEE - MARCHE ACTIVE
```

---

## 🧠 Comment fonctionne le bot ?

LevelUp-Bot utilise un système de priorités.

### 🔢 Ordre des priorités

```text
1. ✨ Pokémon shiny
        ↓
2. 🛑 Pokémon présent dans STOP ON SPECIES
        ↓
3. ❤️ PV trop faibles / PP épuisés
        ↓
4. 🎯 Pokémon non possédé
        ↓
5. ⚔️ Combat normal
```

---

## ✨ Protection shiny

La sécurité shiny possède la priorité maximale.

Lorsqu’un shiny est détecté :

```text
✨ SHINY DETECTED
🛑 BOT STOPPED
```

Le bot :

- arrête les déplacements ;
- n’attaque pas ;
- ne lance pas de capture automatique ;
- laisse le joueur reprendre le contrôle.

---

## ⚔️ Choix intelligent des attaques

Le bot attribue un score à chaque attaque disponible.

Il peut notamment prendre en compte :

- 💥 les dégâts estimés ;
- 🔥 le type de l’attaque ;
- 🧬 le type du Pokémon adverse ;
- ⭐ le bonus STAB ;
- 🎯 la précision ;
- 🔋 les PP restants ;
- ❤️ les PV adverses ;
- 🎯 le risque de mettre K.O. un Pokémon à capturer.

### Exemple simplifié

```text
Thunderbolt
Dégâts estimés : 68
STAB : Oui
Super efficace : Oui
Précision : 100 %
PP : 12

Score : ⭐⭐⭐⭐⭐
```

Le bot sélectionnera généralement l’attaque ayant le meilleur score.

---

## 🎯 Capture automatique

Le bot peut détecter si un Pokémon est déjà possédé.

### Pokémon non possédé

```text
🐾 Pokémon sauvage détecté
📖 Pokédex : NON POSSÉDÉ
🎯 Capture automatique activée
```

Selon les options, il peut :

- lancer directement une Ball ;
- affaiblir le Pokémon avant la capture ;
- éviter les attaques trop puissantes ;
- choisir une Ball adaptée.

---

## ⚙️ Configuration

Les options sont accessibles ici :

```text
F10
 ↓
MODS
 ↓
Auto Grass Battler
 ↓
OPTIONS
```

### Options principales

| Option | Défaut | Description |
|---|:---:|---|
| 🎯 `AUTO CAPTURE` | `UNOWNED` | Capture les Pokémon non possédés |
| ❤️ `CAPTURE BELOW %` | `35` | PV ciblés avant capture |
| ⚔️ `CAPTURE METHOD` | `WEAKEN` | Affaiblit la cible avant capture |
| 🔴 `BALL CHOICE` | `BEST` | Choisit automatiquement la Ball |
| 🏥 `AUTO CENTER WHEN NO PP` | `ON` | Tente d’aller se soigner |
| ❤️ `STOP BELOW HP %` | `25` | Seuil de sécurité PV |
| 🚶 `WALK SPEED` | `NORMAL` | Vitesse de déplacement |
| 💬 `TEXT SPEED` | `NORMAL` | Vitesse de validation des textes |
| ⌨️ `TOGGLE KEY` | `F6` | Touche d’activation |
| 🚀 `START AUTOMATICALLY` | `ON` | Démarrage automatique |
| 📊 `SHOW BOT HUD` | `ON` | Affiche le HUD |
| 🔊 `SHINY ALERT SOUND` | `ON` | Son lors d’un shiny |
| 🛑 `STOP ON SPECIES` | Vide | Arrêt sur certaines espèces |

---

## 🛑 STOP ON SPECIES

Il est possible de demander au bot de s’arrêter sur certains Pokémon.

Exemple :

```text
PIKACHU, EEVEE, DRATINI
```

Si l’un de ces Pokémon apparaît :

```text
🛑 ESPÈCE RECHERCHÉE DÉTECTÉE
BOT EN PAUSE
```

---

## 🏥 Soin automatique

> ⚠️ **Fonction expérimentale**

Lorsque les PP sont épuisés ou que les PV sont trop faibles, le bot peut tenter de :

1. 🏃 fuir le combat ;
2. 📍 mémoriser la position actuelle ;
3. 🏥 rejoindre un Centre Pokémon connu ;
4. ❤️ soigner l’équipe ;
5. ↩️ revenir à la zone précédente ;
6. 🌿 reprendre les rencontres.

---

## 📊 HUD

Le HUD peut afficher plusieurs informations comme :

```text
┌────────────────────────────┐
│ 🤖 LEVELUP-BOT             │
├────────────────────────────┤
│ 🟢 BOT ACTIF               │
│ 🌿 HERBE DÉTECTÉE          │
│ ⚔️ Combats : 42            │
│ 🏆 Victoires : 39          │
│ 🎯 Captures : 5            │
│ ✨ Shinies : 0             │
└────────────────────────────┘
```

---

## 🧩 Compatibilité

| Jeu / système | Compatible |
|---|:---:|
| 🔴 Pokémon Rouge | ✅ |
| 🔵 Pokémon Bleu | ✅ |
| 🟡 Pokémon Jaune | ✅ |
| 🎮 Gen1Recomp 0.2.60+ | ✅ |

---

## 📁 Structure du projet

```text
LevulUp-Bot/
│
├── 📁 assets/
│   └── 🖼️ logo.png
│
├── 📄 main.lua
├── 📄 manifest.json
├── 📄 mod.card
└── 📖 README.md
```

### Fichiers

**`main.lua`**

> 🧠 Contient la logique principale du bot.

**`manifest.json`**

> ⚙️ Contient les informations nécessaires à Gen1Recomp.

**`mod.card`**

> 🎮 Définit les informations du mod affichées dans Gen1Recomp.

---

## ⚠️ Limites actuelles

Le projet possède encore quelques limitations :

- 🧪 le soin automatique est expérimental ;
- 🗺️ le retour au Centre Pokémon dépend de certaines informations de carte ;
- 🎮 certaines sauvegardes peuvent produire des comportements différents ;
- 🤖 ce n’est pas un bot de speedrun complet ;
- 👀 il est recommandé de surveiller les premiers essais.

---

## 🗺️ Roadmap

Quelques améliorations possibles pour les prochaines versions :

- [ ] 🗺️ amélioration de la navigation automatique
- [ ] 🏥 système de soin plus naturel
- [ ] 🧠 meilleure analyse des combats
- [ ] 📊 HUD plus personnalisable
- [ ] 🎯 options avancées de capture
- [ ] 📝 historique des rencontres
- [ ] ✨ compteur et historique des shinies
- [ ] 🎮 meilleure compatibilité manette

---

## 📥 Télécharger

### 🚀 Dernière version

👉 **[Télécharger LevelUp-Bot](https://github.com/Leo0957/LevulUp-Bot/releases/latest)**

Fichier à utiliser :

```text
auto_grass_battler.zip
```

---

## 👨‍💻 Développeur

Projet développé par :

### **Leo0957**

🔗 [GitHub](https://github.com/Leo0957)

Si le projet vous plaît, n’hésitez pas à laisser une :

# ⭐

sur le dépôt.

Cela permet de soutenir le projet et son développement. 💚

---

## ℹ️ Disclaimer

LevelUp-Bot est un **projet communautaire non officiel**.

Pokémon, Nintendo, Game Freak et les différentes marques associées appartiennent à leurs propriétaires respectifs.

Ce projet n’est ni affilié, ni sponsorisé, ni approuvé officiellement par Nintendo, The Pokémon Company ou Game Freak.

---

<p align="center">
  🌿 <strong>LevelUp-Bot</strong> 🌿
</p>

<p align="center">
  Automate • Battle • Capture • Level Up
</p>
