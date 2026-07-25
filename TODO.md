# TODO

## ✅ Corrigé

- [x] **Fix CratOS-Shell boot**
  Le `shell` global bricolé par `lib/loader.lua` n'implémentait pas
  `shell.run`, ce qui faisait planter le démarrage de tout OS. Le
  boot du CraftOS Shell repasse aussi sur le terminal natif (au lieu
  de rester sur un écran externe) et est protégé par un `pcall` : un
  plantage affiche l'écran d'erreur au lieu de casser NyxLoader.

- [x] **Fix Menu ui**
  Le cadre du menu est transparent à l'intérieur : seules les
  bordures sont dessinées, dans la couleur `bootColor` (ou la
  couleur propre à l'OS sélectionné).

- [x] **Fix Failed boot message et retour au menu avec Entrée**
  Écran `ui.error()` dédié aux échecs de boot, qui attend la touche
  **Entrée** pour revenir au menu.

- [x] **`configManager.default()` manquant**
  Plantage garanti au tout premier démarrage (sans
  `/boot/config.lua`) : la fonction n'existait pas. Ajoutée.

- [x] **`webinstall.lua` incomplet**
  `lib/loader.lua`, `lib/uninstall.lua` et `lib/isolation.lua`
  n'étaient pas téléchargés par l'installateur web, et le fichier de
  config généré n'écrivait ni `bootColor` ni `isolation`.

## 💡 Idées ajoutées

- [x] **Désinstallation**
  `uninstall.lua` / `webuninstall.lua` (scripts autonomes) **et**
  une entrée "Desinstaller NyxLoader" directement dans le menu de
  boot (`lib/uninstall.lua`), avec confirmation avant suppression.

- [x] **Icône par OS → splash screen**
  Un champ `icon` dans `boot.json` (image `.nfp`) affiche un splash
  screen centré et ajusté à la taille de l'écran juste avant de
  démarrer l'OS.

- [x] **Couleur par OS**
  Un champ `color` dans `boot.json` surligne l'entrée correspondante
  dans le menu avec sa propre couleur.

- [x] **OS d'exemple**
  [`examples/NyxTestOS`](examples/NyxTestOS) : OS minimal avec
  `boot.json`, `icon` et `color` pour tester NyxLoader rapidement.

- [x] **Mode isolation**
  Nouveau module `lib/isolation.lua`. NyxLoader peut devenir le seul
  élément présent sur le PC principal :
  - Optionnel, proposé à l'installation (`install.lua` /
    `webinstall.lua`), et activable ensuite via `isolation = true`
    dans `/boot/config.lua`.
  - À l'installation : déplace immédiatement tout ce qui existe déjà
    sur le PC vers un disque (en demandant d'en insérer un si
    besoin).
  - En continu : à chaque retour au menu, NyxLoader repère tout ce
    qui est apparu depuis (un OS qui vient de s'installer, un
    fichier téléchargé...) et le déplace vers un disque.
  - Ne touche jamais `/rom`, `/boot`, ni les disques déjà branchés.
  - Ne casse jamais les `boot.json` déplacés : `file`/`icon` sont
    toujours résolus par rapport à l'emplacement réel du dossier de
    l'OS, où qu'il soit.

## 🔭 Pour plus tard

- [ ] Ajouter des tests automatisés (mock des API CC:Tweaked)
- [ ] Défilement du menu si la liste d'OS dépasse la hauteur de
      l'écran
- [ ] Bouton "Ignorer" (skip) sur le splash screen au lieu d'un
      délai fixe
- [ ] Mode isolation : afficher le message d'attente de disque sur
      l'écran externe si un moniteur est utilisé (actuellement il
      s'affiche toujours sur l'écran natif de l'ordinateur)

---

⚠️ Tout ceci a été vérifié syntaxiquement (`luac -p`) mais n'a pas pu
être testé dans un vrai monde CC:Tweaked (pas d'accès à Minecraft
depuis cet environnement). Un test en jeu reste recommandé,
notamment pour le boot CraftOS Shell, le splash screen, et le mode
isolation (déplacement de fichiers, détection de disques).
