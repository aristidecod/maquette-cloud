#!/bin/bash

echo "=== [C1] Configuration du montage automatique des répertoires utilisateurs via autofs ==="

# 1. Installer les paquets nécessaires
echo "[+] Installation de autofs et nfs-utils..."
sudo dnf install -y autofs nfs-utils

# 2. Créer la configuration pour que /home soit géré automatiquement
echo "[+] Configuration du fichier /etc/auto.master.d/home.autofs..."
echo "/home   /etc/auto.home" | sudo tee /etc/auto.master.d/home.autofs > /dev/null

# 3. Configurer les montages automatiques depuis srv.pv0.idl.xfr
echo "[+] Règle de montage dans /etc/auto.home (réseau PV0)..."
echo '*  srv.pv0.idl.xfr:/home/&' | sudo tee /etc/auto.home > /dev/null

# 4. Activer et démarrer le service autofs
echo "[+] Activation et démarrage d'autofs..."
sudo systemctl enable --now autofs

# 5. Vérification
echo "[+] Test avec l’utilisateur alice (le montage se déclenchera automatiquement si tout est OK)..."
su - alice -c "echo 'Répertoire d\'accueil monté automatiquement si la configuration est correcte.'"

echo "✅ Montage automatique via autofs sur C1 configuré avec succès (serveur : srv.pv0.idl.xfr)."
