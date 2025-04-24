#!/bin/bash
# Script de configuration des interfaces réseau pour SRV

echo "Configuration des interfaces réseau..."

# Configuration de l'interface PV0 (enp0s8)
sudo nmcli con modify "Connexion filaire 1" ipv4.method manual ipv4.addresses 192.168.0.1/24 connection.id PV0
echo "Interface PV0 configurée avec l'adresse 192.168.0.1/24"

# Configuration de l'interface PV1 (enp0s9)
sudo nmcli con modify "Connexion filaire 2" ipv4.method manual ipv4.addresses 192.168.1.1/24 connection.id PV1
echo "Interface PV1 configurée avec l'adresse 192.168.1.1/24"

# Ajout de l'adresse IP supplémentaire à l'interface principale
sudo nmcli con modify "enp0s3" +ipv4.addresses 10.0.2.14/24
echo "Adresse supplémentaire 10.0.2.14/24 ajoutée à enp0s3"

# Ajout des entrées dans /etc/hosts
echo "10.0.2.14 srv-alt" | sudo tee -a /etc/hosts
echo "10.0.2.15 srv" | sudo tee -a /etc/hosts
echo "Entrées ajoutées à /etc/hosts"

# Activation des connexions
sudo nmcli con up PV0
sudo nmcli con up PV1
sudo nmcli con up "enp0s3"
echo "Toutes les interfaces ont été activées"

# Vérification
echo "Configuration terminée. Voici l'état actuel des interfaces:"
ip addr show