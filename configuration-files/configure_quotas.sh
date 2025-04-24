#!/bin/bash
# Script pour configurer proprement les quotas sur /home uniquement

echo "📦 Installation des paquets nécessaires..."
sudo dnf install -y quota

echo "📄 Sauvegarde de /etc/fstab..."
sudo cp /etc/fstab /etc/fstab.backup

echo "🛠️ Modification de /etc/fstab pour activer les quotas sur /home..."
sudo sed -i '/\/home/ s/defaults/defaults,usrquota,grpquota/' /etc/fstab

echo "🔄 Remontage de /home avec les bonnes options..."
sudo mount -o remount /home

echo "📂 Création des fichiers de quota..."
sudo quotacheck -cugm /home

echo "✅ Activation des quotas sur /home..."
sudo quotaon /home

echo "🧑‍💻 Définition des quotas utilisateurs sur /home..."

# Définir les quotas en blocs (1 bloc = 1 Ko)
sudo setquota -u etud 1000000 1200000 0 0 /home   # 1 GB soft / 1.2 GB hard
for USER in alice bob tom; do
    sudo setquota -u $USER 500000 600000 0 0 /home
done

echo "📊 Vérification des quotas configurés :"
sudo repquota /home

echo "✅ Configuration des quotas terminée avec succès !"
