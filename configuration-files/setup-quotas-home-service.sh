#!/bin/bash

echo "[*] Création du script de gestion des quotas..."

# 1. Créer le script shell
sudo tee /usr/local/sbin/enable-quotas.sh > /dev/null << 'EOF'
#!/bin/bash

# Désactiver les quotas si déjà actifs (optionnel mais propre)
quotaoff /home

# Nettoyer les fichiers temporaires de quota
rm -f /home/aquota.user.new /home/aquota.group.new

# Forcer la vérification même si les fichiers existent
quotacheck -f -ug /home

# Activer les quotas
quotaon /home
EOF

# Rendre le script exécutable
sudo chmod +x /usr/local/sbin/enable-quotas.sh

echo "[*] Script de quotas installé dans /usr/local/sbin/enable-quotas.sh"

# 2. Créer le fichier de service systemd
echo "[*] Création du service systemd..."

sudo tee /etc/systemd/system/quotas-home.service > /dev/null << 'EOF'
[Unit]
Description=Enable quotas on /home at boot
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/enable-quotas.sh

[Install]
WantedBy=multi-user.target
EOF

# 3. Recharger systemd
echo "[*] Rechargement de systemd et activation du service..."
sudo systemctl daemon-reload
sudo systemctl enable --now quotas-home.service

echo "[✅] Service quotas-home.service créé, activé et démarré."
