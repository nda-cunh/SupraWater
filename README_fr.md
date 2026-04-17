# 🌊 SupraWater

SupraWater est un explorateur de fichiers interactif pour Vim 9.1, écrit
en Vim9script. Il offre une expérience proche de nvim-oil, mais
nativement pour Vim.

[SupraWater](data_git/SupraWater.gif)

## ✨ Fonctionnalités

- 📁 Navigation dans le système de fichiers
- ✍️ Édition directe des chemins/fichiers
- 🪟 Ouverture en split / vsplit / tab
- 👁️ Preview des fichiers
- ↩️  Undo / Redo des actions
- 📋 Copier / Coller
- 🏠 Accès rapide au $HOME
- 🔍 Affichage des fichiers cachés
- 🔃 Tri ascendant / descendant
- 🎨 Support des icônes (vim-devicons or SupraIcons)
- 🧠 Popup d’aide intégrée

## ⚙️ Prérequis

-   Vim 9.1
-   (Optionnel) SupraIcons ou vim-devicons

## ⌨️ Raccourcis

### Ouverture

-   **Enter / Double clic** : Ouvrir
-   **Ctrl-t** : Nouvel onglet
-   **<Leader>-h** : Split horizontal
-   **<Leader>-v** : Split vertical
-   **Ctrl-p** : Preview

### Navigation / Quitter

-   **Ctrl-q** : Quitter
-   **Backspace / -** : Dossier parent
-   **Alt-Up / Alt-Down** : Déplacer élément
-   **~** : HOME
-   **_** : Premier chemin

### Édition

-   **Ctrl-s** : Sauvegarder
-   **p** : Coller
-   **dw / db** : Supprimer mot
-   **yw / yb** : Copier mot
-   **u** : Undo
-   **Ctrl-r** : Redo

### Options

-   **=** : Toggle tri

-   **g.**  : Toggle fichiers cachés

-   **?** : Aide

## 🔧 Configuration

| Variables | Par défaut | Description |
| --------- | ---------- | ----------- |
|  g:suprawater_icons_glyph_func | 'g:WebDevIconsGetFileTypeSymbol' | Fonction pour obtenir les icônes |
|  g:suprawater_filter_files     | []     | Liste des fichiers à filtrer  ['*.o', '*.tmp']|
|  g:suprawater_sortascending    | true   | Tri ascendant par défaut |
|  g:suprawater_show_hidden      | true   | Afficher les fichiers cachés par défaut |
|  g:SupraWaterForceColor        |  ''    | Forcer une couleur spécifique (ex: '#RRGGBB') |
|  g:SupraWaterDarkenAmount      |  25    | Pourcentage de foncé pour la couleur du fond |
