
#!/bin/bash

echo "🔐 Application des règles iptables..."

# Interdire les connexions SSH vers SRV depuis PV1
sudo iptables -A INPUT -p tcp --dport 22 -s 192.168.1.0/24 -j REJECT --reject-with icmp-port-unreachable
echo "[+] Règle INPUT : interdiction SSH de PV1 vers SRV"

# Interdire les connexions SSH de PV1 vers PV0
# sudo iptables -A FORWARD -p tcp --dport 22 -s 192.168.1.0/24 -d 192.168.0.0/24 -j REJECT --reject-with icmp-port-unreachable
# echo "[+] Règle FORWARD : interdiction SSH de PV1 vers PV0"

# Sauvegarde des règles de manière persistante
echo "[*] Sauvegarde des règles dans /etc/sysconfig/iptables"
sudo iptables-save | sudo tee /etc/sysconfig/iptables > /dev/null

# Activation du service iptables au démarrage
sudo systemctl enable iptables
sudo systemctl restart iptables

echo "✅ Règles iptables appliquées et rendues persistantes via iptables-services."
