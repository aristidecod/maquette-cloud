#!/bin/bash

# Script de configuration du serveur DHCP

# Mise à jour du système
echo "Mise à jour du système..."
sudo dnf update -y

# Installation du serveur DHCP
echo "Installation du serveur DHCP..."
sudo dnf install -y dhcp-server

# Création du fichier de configuration DHCP
echo "Configuration du fichier dhcpd.conf..."
sudo tee /etc/dhcp/dhcpd.conf > /dev/null << EOL
# Configuration DHCP pour le serveur

authoritative;
ddns-update-style none;

# Configuration DHCP pour le réseau PV0
subnet 192.168.0.0 netmask 255.255.255.0 {
    range 192.168.0.100 192.168.0.200;
    option domain-name-servers 192.168.0.1;
    option domain-name "pv0.idl.xfr";
    option routers 192.168.0.1;
    default-lease-time 600;
    max-lease-time 7200;
}

# Configuration DHCP pour le réseau PV1
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.100 192.168.1.200;
    option domain-name-servers 192.168.1.1;
    option domain-name "pv1.idl.xfr";
    option routers 192.168.1.1;
    default-lease-time 600;
    max-lease-time 7200;
}
EOL

# Configuration du routage IP
echo "Configuration du routage IP..."
sudo sysctl -w net.ipv4.ip_forward=1
sudo bash -c 'echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf'

# Configuration du pare-feu
echo "Configuration du pare-feu..."
sudo firewall-cmd --permanent --add-service=dhcp
sudo firewall-cmd --permanent --add-masquerade
sudo firewall-cmd --reload

# Démarrage et activation du service DHCP
echo "Démarrage du service DHCP..."
sudo systemctl start dhcpd
sudo systemctl enable dhcpd

# Vérification de la configuration
echo "Vérification de la configuration DHCP..."
sudo dhcpd -t

# Affichage du statut du service
sudo systemctl status dhcpd

echo "Configuration DHCP terminée !"
