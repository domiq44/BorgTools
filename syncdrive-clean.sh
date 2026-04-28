#!/usr/bin/env bash
set -euo pipefail

TARGET="/media/${USER}/SyncDrive"
LOG_DIR="$HOME/logs-backup"
LOG_FILE="$LOG_DIR/clean_syncdrive-$(date +%Y-%m-%d_%H-%M-%S).log"

mkdir -p "$LOG_DIR"

log() {
    echo "$1" | tee -a "$LOG_FILE"
}

log "=== Nettoyage du disque externe ==="
log "Cible : $TARGET"
log "Log   : $LOG_FILE"
log "-----------------------------------"

# Vérification du montage
if [ ! -d "$TARGET" ]; then
    log "ERREUR : Le disque externe n'est pas monté à $TARGET"
    exit 1
fi

log "Suppression des fichiers parasites Windows..."

# Fichiers Windows classiques
find "$TARGET" -type f \( \
    -iname "desktop.ini" -o \
    -iname "thumbs.db" -o \
    -iname "ehthumbs.db" \
    \) -print -delete | tee -a "$LOG_FILE"

log "Suppression des dossiers Windows inutiles..."

# Dossiers Windows
sudo rm -rf "$TARGET/System Volume Information" 2>/dev/null || true
sudo rm -rf "$TARGET/\$RECYCLE.BIN" 2>/dev/null || true
sudo rm -f "$TARGET/autorun.inf" 2>/dev/null || true

log "Nettoyage terminé."
log "=== FIN ==="


