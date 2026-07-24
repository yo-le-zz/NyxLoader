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
  couleur propre à l'OS sélectionné, voir plus bas).

- [x] **Fix Failed boot message et retour au menu avec Entrée**
  Écran `ui.error()` dédié aux échecs de boot, qui attend la touche
  **Entrée** pour revenir au menu.

- [x] **`configManager.default()` manquant**
  Plantage garanti au tout premier démarrage (sans
  `/boot/config.lua`) : la fonction n'existait pas. Ajoutée.

- [x] **`webinstall.lua` incomplet**
  `lib/loader.lua` puis `lib/uninstall.lua` n'étaient pas
  téléchargés par l'installateur web alors que NyxLoader en dépend.

## 💡 Idées ajoutées

- [x] **Désinstallation**
  `uninstall.lua` / `webuninstall.lua` (scripts autonomes) **et**
  une entrée "Desinstaller NyxLoader" directement dans le menu de
  boot (`lib/uninstall.lua`), avec confirmation avant suppression.

- [x] **Icône par OS → splash screen**
  Un champ `icon` dans `boot.json` (image `.nfp`) affiche un splash
  screen centré et ajusté à la taille de l'écran juste avant de
  démarrer l'OS. Le chemin de l'icône est maintenant correctement
  résolu par rapport au dossier du `boot.json` (bug corrigé au
  passage : il n'était jamais résolu avant).

- [x] **Couleur par OS**
  Un champ `color` dans `boot.json` (nom de couleur, ex. `"cyan"`)
  surligne l'entrée correspondante dans le menu avec sa propre
  couleur au lieu du bleu par défaut.

- [x] **OS d'exemple**
  [`examples/NyxTestOS`](examples/NyxTestOS) : un OS minimal (infos
  système, quelques commandes, retour au menu) avec son propre
  `boot.json`, `icon` et `color`, pour tester rapidement NyxLoader
  sans avoir à écrire un OS complet.

## 🔭 Pour plus tard

- [ ] Ajouter des tests automatisés (mock des API CC:Tweaked)
- [ ] Défilement du menu si la liste d'OS dépasse la hauteur de
      l'écran
- [ ] Bouton "Ignorer" (skip) sur le splash screen au lieu d'un
      délai fixe

---

⚠️ Tout ceci a été vérifié syntaxiquement (`luac -p`) mais n'a pas pu
être testé dans un vrai monde CC:Tweaked (pas d'accès à Minecraft
depuis cet environnement). Un test en jeu reste recommandé,
notamment pour le boot CraftOS Shell et le splash screen.
