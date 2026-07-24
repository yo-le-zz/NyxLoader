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
    "file": "/boot/start.lua"
}
```

## Explication :

- `name` : nom affiché dans le menu NyxLoader
- `file` : fichier Lua exécuté pour démarrer l'OS

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
    secureBoot = true
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

# 📁 Structure du projet

```
NyxLoader
│
├── install.lua
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