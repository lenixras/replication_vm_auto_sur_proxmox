#!/bin/bash
export PATH=$PATH:/usr/sbin
# Configuration
BACKUP_DIR="/mnt/pve/NFSSTX2/dump"  # Répertoire de sauvegarde partagé
SRC_VM_ID="418026"
DEST_VM_ID="600026"

# Trouver la dernière sauvegarde
LATEST_BACKUP=$(ls -t $BACKUP_DIR/vzdump-qemu-$SRC_VM_ID-*.vma.zst | head -n 1)

if [[ -z "$LATEST_BACKUP" ]]; then
  echo "Aucune sauvegarde trouvée pour la VM $SRC_VM_ID dans $BACKUP_DIR"
  exit 1
fi

# Supprimer la VM restaurée précédemment, si elle existe
qm stop $DEST_VM_ID 2>/dev/null

#Attendre que la VM soit arrêtée
while qm status $DEST_VM_ID | grep -q "running"; do
  echo "Attente de l'arrêt de la VM $DEST_VM_ID..."
  sleep 5
done

qm set $DEST_VM_ID --delete protection
qm destroy $DEST_VM_ID 2>/dev/null

# Vérifier que la VM a été détruite
if qm status $DEST_VM_ID 2>/dev/null; then
  echo "Erreur: La VM $DEST_VM_ID existe toujours."
  exit 1
fi

# Restaurer la nouvelle sauvegarde
qmrestore $LATEST_BACKUP $DEST_VM_ID --storage local-lvm

# Désactiver le démarrage automatique de la VM restaurée
qm set $DEST_VM_ID --onboot 0

echo "Restauration terminée pour la sauvegarde: $(basename $LATEST_BACKUP)"
echo "La VM $DEST_VM_ID est restaurée mais n'est pas démarrée."
