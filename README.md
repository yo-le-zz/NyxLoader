# 🚀 NyxLoader

**Créateur : yo-le-zz**

NyxLoader est un bootloader pour **CC:Tweaked** inspiré de GRUB.  
Il permet de démarrer plusieurs systèmes CC:Tweaked avec une interface graphique, une détection automatique des OS et un système de Secure Boot cryptographique. 🔐

---

# ✨ Fonctionnalités

- 🖥️ Interface de boot type GRUB
- 💽 Détection automatique des systèmes installés
- 📂 Support multi-disques
- 🔎 Recherche automatique des fichiers `boot.json`
- 🌐 Installation depuis GitHub
- 📦 Installation depuis un disque
- 🗑️ Désinstallation propre (disque, GitHub, ou depuis le menu de boot)
- 🖼️ Splash screen avec logo par OS (`icon` dans `boot.json`)
- 🎨 Couleur de menu personnalisable par OS (`color` dans `boot.json`)
- 🧹 Mode isolation : NyxLoader reste seul sur le PC principal
- 🖼️ Support des écrans externes
- ⏱️ Timeout configurable
- 🔐 Secure Boot avec Cryptographic Accelerator (Classic Peripherals)

---

# 📥 Installation

## 💽 Installation depuis un disque

Téléchargez la dernière release puis copiez le dossier `NyxLoader` à la racine d'un disque CC:Tweaked :

```
disk/
├── install.lua
└── nyxloader/
```

Lancez ensuite :

```lua
install.lua
```

L'installateur va automatiquement :

✅ Déplacer NyxLoader dans :

```
/boot/nyxloader
```

✅ Créer le fichier de démarrage :

```
/startup.lua
```

✅ Créer la configuration :

```
/boot/config.lua
```

✅ Configurer le Secure Boot si un Cryptographic Accelerator est disponible.

---

# 🌐 Installation Web

NyxLoader peut être installé directement depuis GitHub.

Sur une machine CC:Tweaked connectée à Internet :

```lua
wget run https://raw.githubusercontent.com/yo-le-zz/NyxLoader/main/webinstall.lua
```

L'installation va :

1. 📡 Télécharger NyxLoader depuis GitHub
2. 📂 Installer les fichiers dans :

```
/boot/nyxloader
```

3. ⚙️ Configurer le démarrage automatique
4. 🔐 Initialiser le Secure Boot si possible

---

# 🗑️ Désinstallation

## 💽 Depuis un disque

Copiez `uninstall.lua` à la racine du disque, puis lancez :

```lua
uninstall.lua
```

## 🌐 Depuis GitHub

```lua
wget run https://raw.githubusercontent.com/yo-le-zz/NyxLoader/main/webuninstall.lua
```

Dans les deux cas, après confirmation, l'installateur supprime :

- `/boot/nyxloader`
- `/boot/config.lua`
- `/boot/secureboot.hash`
- `/startup.lua` (uniquement s'il appartient à NyxLoader — un
  `startup.lua` personnalisé n'est jamais touché)

---

# 🧹 Mode Isolation

Le mode isolation fait en sorte que **NyxLoader soit le seul élément
présent sur le disque dur principal** de l'ordinateur. Tout le
reste — un OS existant, un fichier qu'un programme installe, un
téléchargement fait depuis le CraftOS Shell — est automatiquement
déplacé vers un disque.

## Activation

Le mode isolation est **optionnel** et se propose lors de
l'installation (disque ou GitHub) :

```
Activer le mode isolation ? (o/n)
```

Il peut aussi être activé plus tard en éditant
`/boot/config.lua` :

```lua
isolation = true
```

## Fonctionnement

- **À l'installation** : si des fichiers existent déjà sur le PC,
  NyxLoader les déplace immédiatement vers un disque (en demandant
  d'en insérer un si aucun n'est disponible).
- **En continu** : à chaque retour au menu NyxLoader (après avoir
  quitté un OS, ou au démarrage), NyxLoader revérifie la racine du
  PC. Si quelque chose de nouveau est apparu (un OS qui vient de
  s'installer, un fichier téléchargé...), il est déplacé
  automatiquement vers un disque déjà inséré, ou NyxLoader demande
  d'en insérer un.
- **Rien n'est jamais perdu** : NyxLoader ne touche jamais à
  `/rom`, `/boot` (lui-même), ni aux disques déjà branchés — seuls
  les éléments "en trop" à la racine du PC sont déplacés.
- **Les chemins restent valides** : le champ `file` (et `icon`) d'un
  `boot.json` est toujours résolu par rapport à l'endroit où se
  trouve ce `boot.json`. Déplacer tout le dossier d'un OS vers un
  disque ne casse donc jamais son démarrage — aucune réécriture du
  `boot.json` n'est nécessaire.

---

# 🔐 Secure Boot

NyxLoader possède un système de vérification d'intégrité du bootloader.

Lors de l'installation :

1. 🔎 Recherche d'un périphérique :

```
cryptographic_accelerator
```

2. 🧮 Calcul d'un hash SHA-256 du dossier :

```
/boot/nyxloader
```

3. 💾 Sauvegarde du hash :

```
/boot/secureboot.hash
```

Au démarrage :

- Le hash actuel est recalculé.
- Il est comparé au hash original.
- Si NyxLoader a été modifié, une alerte est affichée.

Si le Cryptographic Accelerator est retiré :

⚠️ NyxLoader indique que la vérification Secure Boot est impossible.

L'utilisateur peut :

- 🔓 Désactiver Secure Boot
- ▶️ Continuer sans vérification
- 🛑 Bloquer le démarrage

---

# 🖥️ Créer un OS compatible NyxLoader

Pour qu'un OS soit détecté par NyxLoader, il doit posséder un fichier :

```
boot.json
```

Exemple :

```json
{
    "name": "Mon OS",
    "file": "/boot/start.lua",
    "icon": "logo.nfp",
    "color": "cyan"
}
```

## Explication :

- `name` : nom affiché dans le menu NyxLoader
- `file` : fichier Lua exécuté pour démarrer l'OS
- `icon` *(optionnel)* : chemin vers une image `.nfp` (format
  `paintutils`), relatif au dossier du `boot.json`. Si elle est
  présente, un splash screen affiche cette image centrée à l'écran
  (ajustée à la taille de l'écran) juste avant de démarrer l'OS.
- `color` *(optionnel)* : nom d'une couleur CC:Tweaked (`white`,
  `orange`, `magenta`, `lightBlue`, `yellow`, `lime`, `pink`, `gray`,
  `lightGray`, `cyan`, `purple`, `blue`, `brown`, `green`, `red`,
  `black`). Utilisée pour surligner l'OS dans le menu quand il est
  sélectionné.

---

## 🧪 OS d'exemple

Le dossier [`examples/NyxTestOS`](examples/NyxTestOS) contient un OS
minimal (`NyxTestOS`) qui ne sert qu'à tester NyxLoader : détection,
splash screen avec logo, démarrage, et retour au menu. Il inclut un
`boot.json` avec `icon` et `color` déjà configurés.

Pour l'essayer : copiez le dossier `NyxTestOS` à la racine d'un
disque (ou dans `/`) déjà équipé de NyxLoader. Il sera détecté
automatiquement au prochain démarrage.

---

## Exemple de structure d'un OS :

```
MonOS/
├── boot.json
└── boot/
    └── start.lua
```

Quand NyxLoader démarre, il scanne :

- 💽 Les disques connectés
- 🖥️ Le stockage principal

Il recherche tous les fichiers `boot.json` et ajoute automatiquement les OS trouvés dans le menu.

---

# ⚙️ Configuration

La configuration de NyxLoader se trouve dans :

```
/boot/config.lua
```

Exemple :

```lua
return {
    title = "NyxLoader",
    timeout = 10,
    secureBoot = true,
    isolation = false
}
```

## Options :

### 🏷️ Titre

```lua
title = "NyxLoader"
```

Nom affiché en haut du menu.

---

### ⏱️ Timeout

```lua
timeout = 10
```

Temps avant le démarrage automatique.

---

### 🔐 Secure Boot

```lua
secureBoot = true
```

Active la vérification cryptographique.

---

### 🧹 Mode isolation

```lua
isolation = true
```

Voir la section [Mode Isolation](#-mode-isolation) plus haut.

---

# 📁 Structure du projet

```
NyxLoader
│
├── install.lua
│   💽 Installateur (depuis un disque)
│
├── uninstall.lua
│   🗑️ Désinstallateur (depuis un disque)
│
├── webinstall.lua
│   🌐 Installateur (depuis GitHub)
│
├── webuninstall.lua
│   🌐 Désinstallateur (depuis GitHub)
│
├── examples
│   │
│   └── NyxTestOS
│       🧪 OS d'exemple pour tester NyxLoader
│
└── nyxloader
    │
    ├── nyxloader.lua
    │   🚀 Point d'entrée du bootloader
    │
    ├── ui.lua
    │   🖼️ Interface graphique
    │
    ├── config.lua
    │   ⚙️ Gestion de configuration
    │
    └── lib
        │
        ├── basalt.lua
        │   🎨 Librairie UI
        │
        ├── loader.lua
        │   📦 Chargeur de modules / API shell minimale
        │
        ├── uninstall.lua
        │   🗑️ Désinstallation (utilisé par le menu de boot)
        │
        ├── isolation.lua
        │   🧹 Mode isolation
        │
        ├── hash.lua
        │   🔐 Fonctions de hash
        │
        └── scanner.lua
            🔎 Détection des systèmes
```

---

# 🛠️ Technologies utilisées

- 🟦 Lua
- 🟩 CC:Tweaked
- 🎨 Basalt
- 🔐 Classic Peripherals

---

# 👨‍💻 Auteur

Créé par **yo-le-zz**

GitHub :

https://github.com/yo-le-zz/NyxLoader

---

# 📜 Licence

GNU GPL-3.0