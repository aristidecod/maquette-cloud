
#!/bin/bash
# Script de configuration DNSMasq utilisant le fichier /etc/hosts existant
# Installation de DNSMasq
echo "Installation de DNSMasq..."
sudo dnf -y install dnsmasq
# Installation des outils DNS (pour dig)
echo "Installation des outils DNS..."
sudo dnf -y install bind-utils
# Configuration de DNSMasq pour écouter sur les bonnes interfaces
echo "Configuration de DNSMasq..."
sudo sed -i 's/^interface=/#interface=/' /etc/dnsmasq.conf
sudo sed -i 's/^bind-/#bind-/' /etc/dnsmasq.conf
# Création du fichier de configuration personnalisé
sudo mkdir -p /etc/dnsmasq.d
sudo tee /etc/dnsmasq.d/my.conf > /dev/null << EOL
# Interfaces sur lesquelles DNSMasq doit écouter
interface=lo
interface=enp0s8  # Interface pour PV0
interface=enp0s9  # Interface pour PV1
interface=enp0s3  # Interface externe
# Écouter sur les interfaces spécifiées
bind-interfaces
# Configuration générale
domain-needed
bogus-priv
no-resolv
server=8.8.8.8
server=8.8.4.4
# Utiliser les entrées de /etc/hosts et les étendre aux domaines
expand-hosts
domain=idl.xfr
local=/idl.xfr/
EOL

# Configuration de systemd pour attendre le réseau avant de démarrer DNSMasq
echo "Configuration de systemd pour attendre le réseau..."
sudo mkdir -p /etc/systemd/system/dnsmasq.service.d
sudo tee /etc/systemd/system/dnsmasq.service.d/wait-for-network.conf > /dev/null << EOL
[Unit]
After=network-online.target
Wants=network-online.target
EOL

# Recharger systemd pour prendre en compte les modifications
sudo systemctl daemon-reload

# Activation et démarrage du service
echo "Activation et démarrage du service DNSMasq..."
sudo systemctl enable dnsmasq
sudo systemctl start dnsmasq

# Configuration du pare-feu
echo "Configuration du pare-feu..."
sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --reload

# Vérification du statut
echo "Vérification du statut de DNSMasq..."
sudo systemctl status dnsmasq

# Tests de résolution DNS
echo "Test de résolution DNS..."
echo "Test de résolution pour site1.idl.xfr:"
dig @127.0.0.1 site1.idl.xfr
echo "Test de résolution pour srv.pv0.idl.xfr:"
dig @127.0.0.1 srv.pv0.idl.xfr
echo "Test de résolution pour srv.pv1.idl.xfr:"
dig @127.0.0.1 srv.pv1.idl.xfr
echo "Test de résolution pour srv-alt.idl.xfr:"
dig @127.0.0.1 srv-alt.idl.xfr
echo "Test de résolution inverse pour 192.168.0.1:"
dig @127.0.0.1 -x 192.168.0.1

echo "Configuration DNSMasq terminée !"
