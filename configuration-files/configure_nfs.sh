#!/bin/bash

echo "=== Configuration du serveur NFS ==="

# 1. Installation des paquets nécessaires
echo "[+] Installation de rpcbind et nfs-utils..."
sudo dnf install -y rpcbind nfs-utils

# 2. Activation et démarrage des services
echo "[+] Activation des services..."
sudo systemctl enable --now rpcbind
sudo systemctl enable --now nfs-server

# 3. Création du répertoire exporté
EXPORT_DIR="/var/mes-exports"
echo "[+] Création du répertoire exporté : $EXPORT_DIR"
sudo mkdir -p $EXPORT_DIR

# 4. Création de fichiers de test dans le dossier exporté
echo "[+] Création de fichiers de test..."
echo "Contenu de test" | sudo tee $EXPORT_DIR/info.txt > /dev/null

# 5. Attribution des droits : root_squash est actif donc on prépare pour nfsnobody
echo "[+] Attribution des permissions (propriétaire: nobody, droits: 755)..."
sudo chown nobody:nobody $EXPORT_DIR
sudo chmod 755 $EXPORT_DIR

# 6. Configuration des exports NFS
echo "[+] Configuration du fichier /etc/exports..."
sudo tee /etc/exports > /dev/null <<EOF
$EXPORT_DIR 192.168.0.0/24(rw) 192.168.1.0/24(rw)
EOF

# 7. Application des exports
echo "[+] Application des exports NFS..."
sudo exportfs -a
sudo exportfs -v

# 8. Ouverture des ports dans le pare-feu
echo "[+] Ouverture des ports NFS dans firewalld..."
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --permanent --add-service=mountd
sudo firewall-cmd --permanent --add-service=rpc-bind
sudo firewall-cmd --reload

# 9. Vérification des services RPC enregistrés
echo "[+] Vérification des services RPC enregistrés..."
sudo rpcinfo -p localhost

echo "✅ Configuration NFS terminée avec succès !"
