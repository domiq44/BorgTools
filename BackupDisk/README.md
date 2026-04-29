```markdown
# BorgTools — Gestion complète des sauvegardes BorgBackup

BorgTools est un ensemble de scripts Bash destinés à automatiser la gestion d’un
système de sauvegarde personnel basé sur **BorgBackup**.  
Il fournit trois commandes principales :

- **borg-diskforge** — Préparation d’un disque externe pour BorgBackup  
- **borg-homeshield** — Sauvegarde complète du répertoire `$HOME`  
- **borg-restore** — Restauration sécurisée d’une archive Borg  

Ces outils sont conçus pour fonctionner sur **Fedora Linux**, mais sont compatibles
avec toute distribution moderne utilisant `udisksctl`.

---

## 📦 Fonctionnalités principales

- Détection automatique du disque externe via **LABEL=BackupDisk**
- Montage automatique via `udisksctl`
- Sauvegarde complète de `$HOME` avec exclusions intelligentes
- Rotation automatique des sauvegardes (daily/weekly/monthly)
- Vérification mensuelle du dépôt Borg
- Restauration sécurisée avec confirmations explicites
- Journalisation complète (global + session)
- Verrouillage pour éviter les exécutions simultanées
- Scripts robustes (`errexit`, `pipefail`, `nounset`)

---

# 🛠 Installation

Placez les scripts dans un répertoire présent dans votre `$PATH`, par exemple :

```bash
mkdir -p ~/.local/bin
cp borg-diskforge borg-homeshield borg-restore ~/.local/bin/
chmod +x ~/.local/bin/borg-*
```

Assurez-vous que BorgBackup est installé :

```bash
sudo dnf install borgbackup
```

---

# 📀 1. borg-diskforge — Préparation d’un disque externe

`borg-diskforge` initialise un disque externe pour être utilisé comme dépôt BorgBackup.

Il effectue automatiquement :

- vérification du périphérique bloc  
- affichage des informations du disque  
- confirmation explicite avant formatage  
- démontage si nécessaire  
- formatage en **ext4** avec un label personnalisé  
- montage automatique via `udisksctl`  
- attribution des permissions à l’utilisateur  
- création du dépôt Borg (`borg init`)  

## 🔥 Usage

```bash
borg-diskforge
```

> ⚠️ Le script formate le disque défini dans sa configuration interne (`DEVICE=/dev/...`).

## 📁 Structure créée

```
/run/media/$USER/BackupDisk/
└── borg_repo/
```

## 📌 Exemple de sortie

```
[INFO] Formatage en ext4...
[INFO] Dépôt Borg créé : /run/media/user/BackupDisk/borg_repo
```

---

# 🛡 2. borg-homeshield — Sauvegarde complète de $HOME

`borg-homeshield` est le script principal de sauvegarde.  
Il crée une archive Borg contenant l’intégralité du répertoire `$HOME`, en excluant :

- caches  
- containers (Flatpak, Podman, Toolbox)  
- machines virtuelles  
- dépendances de build (npm, cargo, maven…)  
- métadonnées JetBrains  
- fichiers temporaires  

Il gère également :

- montage automatique du disque  
- création du dépôt si nécessaire  
- rotation des sauvegardes  
- vérification mensuelle  
- logs complets  
- verrouillage anti-concurrence  

## 🔥 Usage

```bash
borg-homeshield
```

## 📁 Logs

```
~/.local/log/borgbackup/
├── borg_backup.log        # log global
└── borg_YYYY-MM-DD_HH-MM.log
```

## 🗂 Rotation automatique

- 7 sauvegardes **daily**
- 4 sauvegardes **weekly**
- 6 sauvegardes **monthly**

---

# ♻️ 3. borg-restore — Restauration d’une archive Borg

`borg-restore` permet de restaurer une archive Borg dans un répertoire choisi.

Il propose :

- détection automatique du disque BackupDisk  
- montage automatique  
- sélection interactive de l’archive  
- mode `--latest` pour restaurer la dernière archive  
- protections contre les restaurations dangereuses  
- confirmations explicites  

## 🔥 Usage

### Restaurer la dernière archive

```bash
borg-restore --latest ~/restauration
```

### Restaurer une archive spécifique

```bash
borg-restore ~/restauration
```

Le script affiche alors la liste des archives et demande laquelle restaurer.

---

# 🧪 Exemples de workflow complet

## 1. Préparer un disque neuf

```bash
borg-diskforge
```

## 2. Lancer une sauvegarde

```bash
borg-homeshield
```

## 3. Restaurer une archive

```bash
borg-restore --latest ~/restaure
```

---

# 🧰 Dépendances

- `bash`
- `borgbackup`
- `udisksctl` (udisks2)
- `lsblk`
- `df`
- `ts` (paquet `moreutils`)

Sur Fedora :

```bash
sudo dnf install borgbackup udisks2 moreutils
```

---

# 🔒 Sécurité

Les scripts incluent :

- confirmations explicites avant toute action destructive  
- verrouillage (`flock`) pour éviter les exécutions simultanées  
- protections contre la restauration dans un dossier non vide  
- gestion stricte des erreurs Bash  

---

# 📄 Licence

MIT — © Dominique CRETEL

---

# 🤝 Contributions

Les contributions sont les bienvenues :  
améliorations, nouvelles exclusions, support multi-disques, timers systemd, etc.

---

# ⭐ Remerciements

Merci d’utiliser BorgTools !  
Ces scripts ont été conçus pour offrir une solution simple, robuste et fiable pour les sauvegardes personnelles sous Linux.
```


