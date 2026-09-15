# Auto Grass Battler

Bot d'automatisation pour **Gen1Recomp** sur Pokemon Rouge, Bleu et Jaune.

Le mod fait marcher le joueur dans les hautes herbes, gere les combats sauvages, peut capturer les especes non possedees, s'arrete devant un shiny, choisit les attaques automatiquement et peut retourner au Centre Pokemon quand les PP sont epuises.

> Version actuelle : **3.0.2**  
> Compatible avec Gen1Recomp **0.2.60+** (`>=0.2.60 <2.0.0`)

## Fonctionnalites

| Fonction | Etat | Description |
| --- | --- | --- |
| Marche automatique | Oui | Le joueur alterne gauche/droite dans l'herbe pour declencher des rencontres sauvages. |
| Toggle en jeu | Oui | **F6** ou **Tab** met le bot en pause ou le relance. |
| Demarrage automatique | Oui | Le bot peut se lancer tout seul au chargement de la partie. |
| Combat automatique | Oui | Le bot selectionne FIGHT puis la meilleure attaque utilisable. |
| Choix intelligent d'attaque | Oui | Score base sur degats estimes, types, STAB, precision, PP et stats du combat. |
| Capture automatique | Oui | Peut capturer les Pokemon absents du Pokedex selon les options. |
| Protection shiny | Oui | Le bot s'arrete immediatement si le Pokemon sauvage est shiny. |
| Fin de combat | Oui | Valide les textes de victoire, experience et montee de niveau. |
| Evolution | Oui | Laisse l'evolution se terminer et evite d'appuyer sur B. |
| Apprentissage d'attaque | Oui | Compare la nouvelle attaque aux attaques actuelles et oublie la moins utile si necessaire. |
| Soin automatique | Experimental | Si les PP sont epuises ou les PV bas, le bot peut aller au Centre Pokemon, soigner, puis revenir. |
| HUD | Oui | Affiche l'etat du bot, les rencontres, victoires, captures, shinies et l'etat de l'herbe. |

## Installation

1. Telecharger `auto_grass_battler.zip` depuis la page des releases GitHub.
2. Ouvrir **Gen1Recomp**.
3. Aller dans **MODS**.
4. Choisir **Import mod .zip**.
5. Selectionner `auto_grass_battler.zip` sans le decompresser.
6. Activer **Auto Grass Battler**.
7. Lancer Pokemon Rouge, Bleu ou Jaune.

## Utilisation

Placez le personnage dans les hautes herbes, avec au moins une case libre a gauche et une case libre a droite.

Le bot demarre automatiquement si l'option **START AUTOMATICALLY** est active. Sinon, appuyez sur **F6** ou **Tab** pour l'activer.

| Action | Commande |
| --- | --- |
| Activer / pause | `F6` |
| Activer / pause de secours | `Tab` |
| Desactiver completement | Menu des mods Gen1Recomp |
| Modifier les options | `F10` > `MODS` > `Auto Grass Battler` > `OPTIONS` |

Quand tout fonctionne, le HUD doit afficher :

```text
BOT ACTIF
HERBE DETECTEE - MARCHE ACTIVE
```

## Options

| Option | Valeur par defaut | Effet |
| --- | --- | --- |
| `AUTO CAPTURE` | `UNOWNED` | Capture les especes absentes du Pokedex, ou desactive la capture. |
| `CAPTURE METHOD` | `WEAKEN` | Lance une Ball directement ou affaiblit d'abord la cible. |
| `CAPTURE BELOW %` | `35` | Pourcentage de PV adverse vise avant capture. |
| `BALL CHOICE` | `BEST` | Choisit la meilleure Ball, economise les meilleures Balls ou utilise seulement des Poke Balls. |
| `AUTO CENTER WHEN NO PP` | `ON` | Tente de fuir puis de soigner au Centre Pokemon si les attaques n'ont plus de PP. |
| `STOP BELOW HP %` | `25` | Seuil de securite pour les PV du Pokemon actif. |
| `WALK SPEED` | `NORMAL` | Vitesse du mouvement gauche/droite. |
| `TEXT SPEED` | `NORMAL` | Vitesse de validation des textes. |
| `TOGGLE KEY` | `F6` | Touche principale pour activer ou mettre en pause. |
| `GAMEPAD BACK TOGGLE` | `OFF` | Active le bouton Back/Select de la manette comme toggle. |
| `START AUTOMATICALLY` | `ON` | Lance le bot automatiquement au chargement. |
| `SHOW BOT HUD` | `ON` | Affiche ou masque le HUD. |
| `SHINY ALERT SOUND` | `ON` | Joue un son lorsque le bot detecte un shiny. |
| `STOP ON SPECIES` | vide | Arrete le bot sur certains Pokemon, par exemple `PIKACHU, EEVEE`. |

## Priorites du bot

Le bot suit toujours cet ordre :

| Priorite | Situation | Reaction |
| --- | --- | --- |
| 1 | Pokemon shiny | Stop immediat, aucune attaque, aucune capture automatique. |
| 2 | Espece dans `STOP ON SPECIES` | Stop immediat. |
| 3 | PV trop bas ou PP epuises | Fuite puis tentative de soin si l'option est active. |
| 4 | Pokemon non possede | Capture selon les options. |
| 5 | Combat normal | Selection de la meilleure attaque disponible. |

## Detection shiny

Le mod utilise la logique shiny de Gen1Recomp, basee sur les **DV** du Pokemon sauvage.

En Generation 1, un Pokemon n'a pas une couleur shiny visible comme dans les jeux plus recents. La detection depend donc des valeurs internes du Pokemon. Le bot lit ces donnees via le moteur, puis appelle la logique shiny du jeu. Si le resultat est positif, il s'arrete avant toute action dangereuse.

## Choix des attaques

Pour combattre, le bot donne un score a chaque attaque utilisable.

| Critere | Pris en compte |
| --- | --- |
| Degats estimes | Oui |
| Type du Pokemon adverse | Oui |
| STAB | Oui |
| Precision | Oui |
| PP restants | Oui |
| Attaques de statut utiles | Oui |
| Risque de K.O. pendant une capture | Oui |
| CS/HM a oublier | Non, le bot evite de les oublier |

Pendant une capture, le bot evite une attaque si son degat critique maximum peut mettre la cible K.O.

## Soin automatique

Si **AUTO CENTER WHEN NO PP** est active, le bot peut :

1. Reconnaitre que toutes les attaques utilisables sont a 0 PP.
2. Revenir au menu principal du combat.
3. Choisir FLEE jusqu'a sortir du combat.
4. Memoriser la position d'herbe.
5. Trouver un Centre Pokemon connu.
6. Soigner l'equipe.
7. Revenir a la position memorisee.
8. Reprendre la marche gauche/droite.

Cette partie est marquee comme experimentale car elle depend davantage de l'etat de la sauvegarde, de la carte et des menus.

## Limites connues

| Limite | Detail |
| --- | --- |
| Test reel requis | Le mod a ete verifie en chargement/syntaxe, mais chaque sauvegarde peut avoir des cas particuliers. |
| Soin automatique experimental | Le retour au Centre Pokemon fonctionne par transfert interne fiable, pas par marche naturelle sur toute la carte. |
| Pas un bot de speedrun | Le but est l'automatisation des rencontres sauvages, pas une completion complete du jeu. |
| Surveillance conseillee | Sauvegardez avant utilisation et surveillez les premiers essais. |

## Structure du mod

```text
auto_grass_battler/
├── manifest.json
├── main.lua
├── mod.card
└── README.md
```

## Publication GitHub

Pour publier le mod proprement :

1. Mettre ce dossier dans un depot GitHub.
2. Garder `manifest.json`, `main.lua`, `mod.card` et `README.md` a la racine du dossier du mod.
3. Creer une release GitHub.
4. Ajouter `auto_grass_battler.zip` comme fichier telechargeable.
5. Indiquer dans la release la version du mod, par exemple `v3.0.2`.

## Licence

Ajoutez une licence avant publication publique si vous voulez que d'autres personnes puissent reutiliser ou modifier le mod clairement.

Exemples possibles :

| Licence | Quand l'utiliser |
| --- | --- |
| MIT | Simple, permissive, facile pour les petits projets open source. |
| GPL-3.0 | Les modifications publiques doivent rester open source. |
| Tous droits reserves | Si vous ne voulez pas autoriser la reutilisation sans votre accord. |
