#!/usr/bin/env bash
set -euo pipefail

###############################################
# CONFIGURATION
###############################################

SRC="$HOME/"
DEVICE="/dev/sda1"
EXPECTED_MOUNT="/media/${USER}/SyncDrive"
USER_NAME="$USER"

LOG_DIR="$HOME/logs-backup"
LOG_FILE="$LOG_DIR/syncdrive-backup-$(date +%Y-%m-%d_%H-%M-%S).log"

mkdir -p "$LOG_DIR"

###############################################
# FONCTION DE LOG
###############################################

log() {
    echo "$1" | tee -a "$LOG_FILE"
}

###############################################
# EN-TÊTE
###############################################

log "=== Sauvegarde HOME → EXTERNE ==="
log "Utilisateur   : $USER_NAME"
log "Source        : $SRC"
log "Log           : $LOG_FILE"
log "-------------------------------------"

###############################################
# VÉRIFICATION SOURCE
###############################################

if [[ ! -d "$SRC" ]]; then
    log "ERREUR : Le dossier source $SRC n'existe pas."
    exit 1
fi

###############################################
# DÉTECTION AUTOMATIQUE DU POINT DE MONTAGE
###############################################

log "Détection du point de montage du disque..."

REAL_MOUNT=$(lsblk -no MOUNTPOINT "$DEVICE" | head -n 1)

if [[ -z "$REAL_MOUNT" ]]; then
    log "Le disque n'est pas monté. Tentative de montage sur $EXPECTED_MOUNT..."

    if [[ ! -d "$EXPECTED_MOUNT" ]]; then
        sudo mkdir -p "$EXPECTED_MOUNT"
    fi

    sudo mount "$DEVICE" "$EXPECTED_MOUNT"
    REAL_MOUNT="$EXPECTED_MOUNT"
else
    log "Le disque est déjà monté sur : $REAL_MOUNT"
fi

###############################################
# VÉRIFICATION DES DROITS D'ÉCRITURE
###############################################

if [[ ! -w "$REAL_MOUNT" ]]; then
    log "ERREUR : Le point de montage $REAL_MOUNT n'est pas accessible en écriture."
    log "Essayez : sudo chown -R $USER_NAME:$USER_NAME $REAL_MOUNT"
    exit 1
fi

DEST="$REAL_MOUNT"
log "Destination détectée : $DEST"
log "-------------------------------------"

###############################################
# SYNCHRONISATION RSYNC
###############################################

log "Début de la synchronisation..."

rsync -avh --info=progress2 --delete \
    --exclude=".cache/" \
    --exclude=".local/share/Trash/" \
    --exclude=".local/share/flatpak/" \
    --exclude=".local/share/gvfs-metadata/" \
    --exclude=".local/share/recently-used.xbel" \
    --exclude=".thumbnails/" \
    --exclude="Downloads/" \
    --exclude="VirtualBox VMs/" \
    --exclude=".mozilla/firefox/*.default-release/cache2/" \
    --exclude=".config/google-chrome/Default/Cache/" \
    --exclude=".config/chromium/Default/Cache/" \
    --exclude=".npm/_cacache/" \
    --exclude=".cargo/registry/" \
    --exclude=".rustup/toolchains/" \
    --exclude=".rustup/update-hashes/" \
    --exclude=".android/" \
    --exclude=".gradle/" \
    --exclude=".vscode/" \
    --exclude=".local/state/" \
    --exclude="*.tmp" \
    "$SRC" "$DEST" \
    | tee -a "$LOG_FILE"

log "=== Sauvegarde HOME → EXTERNE terminée ==="



