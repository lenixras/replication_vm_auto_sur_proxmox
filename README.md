# Réplication Automatique de VM sur Proxmox

Ce dépôt contient un script Bash permettant d'automatiser la réplication (restauration) d'une machine virtuelle (VM) sur un hôte Proxmox à partir de sauvegardes existantes.

## Description

Le script `replication_winserv.sh` effectue les actions suivantes :
1. Recherche la sauvegarde la plus récente d'une VM source spécifiée dans un répertoire de sauvegarde (ex: NFS).
2. Arrête et détruit la VM de destination existante (si elle est présente).
3. Restaure la dernière sauvegarde vers le nouvel ID de VM de destination.
4. Désactive l'option "onboot" (démarrage automatique) pour la VM restaurée afin d'éviter les conflits d'IP ou de services.

## Prérequis

- Un serveur Proxmox (PVE).
- Les utilitaires `qm` et `qmrestore` (installés par défaut sur Proxmox).
- Un accès au répertoire de sauvegarde (ex: point de montage NFS).

## Configuration

Avant de lancer le script, modifiez les variables suivantes directement dans `replication_winserv.sh` :

```bash
BACKUP_DIR="/mnt/pve/NFSSTX2/dump"  # Répertoire contenant vos fichiers .vma.zst
SRC_VM_ID="418026"                 # ID de la VM source dont on récupère la sauvegarde
DEST_VM_ID="600026"                # ID de la VM de destination (sera écrasée)
```

Le stockage de destination est actuellement configuré sur `local-lvm` à la ligne 35 :
```bash
qmrestore $LATEST_BACKUP $DEST_VM_ID --storage local-lvm
```
Modifiez `--storage local-lvm` si vous utilisez un autre type de stockage (ex: `ceph`, `zfs`).

## Utilisation

Donnez les droits d'exécution au script :

```bash
chmod +x replication_winserv.sh
```

Exécutez le script :

```bash
./replication_winserv.sh
```

## Automatisation

Pour automatiser cette réplication (par exemple toutes les nuits), vous pouvez ajouter une tâche cron :

```bash
# Exemple : Lancement tous les jours à 03:00
0 3 * * * /chemin/vers/votre/repo/replication_winserv.sh
```
