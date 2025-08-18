# SupraTree : Un Gestionnaire de Fichiers Puissant pour Vim9.0+

<img src="data_git/readme.png">

SupraTree est un plugin Vim9Script moderne et performant, conçu exclusivement pour **Vim9.0 et versions ultérieures**. Inspiré par des outils comme `vim-oil` de Neovim et `nerdtree`, il offre une exploration de fichiers complète et éditable directement dans Vim.

<img src="data_git/SupraWater.gif">

---

## ✨ Fonctionnalités Clés

* **Explorateur de fichiers puissant** : Naviguez et gérez facilement votre arborescence de fichiers.
* **Intégration transparente** : Conçu spécifiquement pour le moteur Vim9, garantissant vitesse et stabilité.
* **Arborescence éditable** : Renommez vos fichiers et dossiers directement depuis l'explorateur.
* **Personnalisable** : Configurez aisément l'affichage et les raccourcis clavier selon votre workflow.

---

## 🚀 Installation

Pour installer SupraTree, vous pouvez utiliser un gestionnaire de plugins Vim9 comme `vim-plug` ou `dein.vim`, ou un gestionnaire basé sur les fichiers comme `supraload` ou `pathogen`.

### Avec `vim-plug`

Ajoutez la ligne suivante dans votre fichier `.vimrc` ou `init.vim` :

```vim
Plug 'your_github_username/supraTree'
```

Ensuite, redémarrez Vim et lancez `:PlugInstall`.

### Avec `supraload` (ou `pathogen`)

1.  Rendez-vous dans le dossier de vos plugins Vim. Pour `supraload`, il s'agit généralement de `~/.vim/bundle/` (ou similaire selon votre configuration).
2.  Clonez le dépôt directement dans ce dossier :

```bash
cd ~/.vim/bundle/
git clone https://github.com/your_github_username/supraTree.git
```

Cette méthode charge automatiquement le plugin au démarrage de Vim, comme le fait `pathogen`.

---
## 📚 Dépendances

Installez également ce plugin : https://github.com/nda-cunh/SupraPopup

## 🛠️ Configuration

Vous pouvez personnaliser le comportement de SupraTree dans votre fichier de configuration Vim.

### Options disponibles

* `g:SupraTreeIgnoreTree`: Une liste de motifs (regex) pour ignorer des fichiers ou dossiers spécifiques dans l'arborescence.
	**Exemple**: `g:SupraTreeIgnoreTree = ['\.png$', '\.jpg$', '\.o$']`
* `g:SupraTreeWinSize`: La largeur de la fenêtre de l'explorateur en colonnes. Par défaut, c'est `26`.
* `g:SupraTreeSymbolSigns`: Un symbole utilisés en cas d'erreur dans l'arborescence. Par défaut, c'est `✖`.
* `g:SupraTreeForceColor`: Forcer un thème de couleur spécifique pour l'arborescence.
* `g:SupraTreeDarkenAmount`: Le niveau d'assombrissement de la couleur de fond de la fenêtre de l'arborescence. Par défaut, c'est `15` (%).
* `g:SupraTreeShowHidden`: Afficher les fichiers et dossiers cachés (par défaut, c'est `false`).
* `g:SupraTreeSortAscending`: Trier les fichiers et dossiers par ordre croissant (par défaut, c'est `true`).

---

## ⌨️ Commandes et Raccourcis

SupraTree fournit plusieurs commandes pour interagir avec l'explorateur de fichiers. Vous pouvez les mapper aux raccourcis clavier de votre choix.

### Commandes

* `:SupraTreeToggle` : Ouvre ou ferme la fenêtre de l'arborescence.
* `:SupraTreeOpen` : Ouvre l'explorateur de fichiers.
* `:SupraTreeClose` : Ferme l'explorateur de fichiers.

### Raccourcis clavier (dans la fenêtre de l'arborescence)

* `<C-q>` : Quitter l'explorateur.
* `<BackSpace>` / `-` : Revenir au dossier parent.
* `<Enter>` / `<Click>` : Entrer dans le dossier ou ouvrir le fichier sélectionné.
* `<C-h>` : Ouvrir le fichier/dossier en split horizontal.
* `<C-v>` : Ouvrir le fichier/dossier en split vertical.
* `<C-t>` : Ouvrir le fichier/dossier dans un nouvel onglet.
* `<C-p>` : Prévisualiser le fichier.
* `<C-.>`: Basculer la visibilité des fichiers et dossiers cachés.
* `<C-=>`: Basculer le tri croissant/décroissant.
* `~` : Aller dans le dossier personnel.
* `_` : Entrer dans le dossier et sauter à la dernière position.
