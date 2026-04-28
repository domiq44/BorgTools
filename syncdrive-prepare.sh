#!/usr/bin/env bash
set -euo pipefail

DEVICE="/dev/sda1"
MOUNT_POINT="/media/${USER}/SyncDrive"
LABEL="SyncDrive"
LOG_DIR="$HOME/logs-syncdrive"
LOG_FILE="$LOG_DIR/syncdrive-prepare-$(date +%Y-%m-%d_%H-%M-%S).log"

mkdir -p "$LOG_DIR"

log() {
    echo "$1" | tee -a "$LOG_FILE"
}

clear
log "==============================================================="
log "   SCRIPT DE PRÉPARATION DU DISQUE DE SAUVEGARDE : $LABEL"
log "==============================================================="
log "ATTENTION : ce script va FORMATER le disque : $DEVICE"
log "TOUTES les données présentes sur ce disque seront PERDUES."
log "Log : $LOG_FILE"
log "---------------------------------------------------------------"

# Vérification du device
if [ ! -b "$DEVICE" ]; then
    log "ERREUR : Le device $DEVICE n'existe pas."
    exit 1
fi

# Affichage d'information sur le disque
log "Informations sur le disque :"
lsblk -f "$DEVICE" | tee -a "$LOG_FILE"
log "---------------------------------------------------------------"

# Première confirmation
read -rp "CONFIRMATION 1/2 : Voulez-vous vraiment formater $DEVICE ? (oui/non) : " CONFIRM1
if [[ "$CONFIRM1" != "oui" ]]; then
    log "Annulation."
    exit 0
fi

# Deuxième confirmation
read -rp "CONFIRMATION 2/2 : Tapez EXACTEMENT : JE CONFIRME : " CONFIRM2
if [[ "$CONFIRM2" != "JE CONFIRME" ]]; then
    log "Annulation."
    exit 0
fi

log "Dernière chance d'annuler (5 secondes)..."
sleep 5

# Démontage si monté
if mount | grep -q "$DEVICE"; then
    log "Le disque est monté, démontage..."
    sudo umount "$DEVICE" 2>&1 | tee -a "$LOG_FILE"
else
    log "Le disque n'est pas monté, OK."
fi

# Formatage
log "Formatage en ext4 avec label '$LABEL'..."
sudo mkfs.ext4 -L "$LABEL" "$DEVICE" 2>&1 | tee -a "$LOG_FILE"

log "Recherche du disque fraîchement formaté..."

# Attente active jusqu'à 10 secondes
FOUND=0
for i in {1..10}; do
    if blkid | grep -q "LABEL=\"$LABEL\""; then
        log "Disque détecté avec le label $LABEL."
        FOUND=1
        break
    fi
    log "En attente de la détection du disque... ($i/10)"
    sleep 1
done

if [[ "$FOUND" -eq 0 ]]; then
    log "ERREUR : Le disque avec le label $LABEL n'a pas été détecté."
    exit 1
fi

# Création du point de montage si nécessaire
if [ ! -d "$MOUNT_POINT" ]; then
    log "Création du point de montage $MOUNT_POINT..."
    sudo mkdir -p "$MOUNT_POINT"
fi

# Montage manuel
log "Montage du disque..."
sudo mount "$DEVICE" "$MOUNT_POINT" 2>&1 | tee -a "$LOG_FILE"

# Permissions
log "Application des permissions pour l'utilisateur $USER..."
sudo chown -R "$USER:$USER" "$MOUNT_POINT" 2>&1 | tee -a "$LOG_FILE"
sudo chmod -R u+rwX "$MOUNT_POINT" 2>&1 | tee -a "$LOG_FILE"

log "---------------------------------------------------------------"
log "État final du point de montage :"
ls -ld "$MOUNT_POINT" | tee -a "$LOG_FILE"

log "==============================================================="
log "   DISQUE SyncDrive PRÊT À L'EMPLOI"
log "==============================================================="

