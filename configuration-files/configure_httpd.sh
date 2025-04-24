
#!/bin/bash
# Mise à jour du système et installation d'Apache (httpd)
echo "Mise à jour du système et installation d'Apache..."
sudo dnf update -y
sudo dnf install httpd -y

# Démarrer et activer Apache
echo "Démarrage et activation d'Apache..."
sudo systemctl start httpd
sudo systemctl enable httpd

# Créer les répertoires pour les sites
echo "Création des répertoires pour les sites..."
sudo mkdir -p /var/www/html/site1
sudo mkdir -p /var/www/html/site2

# Créer les fichiers index.html pour les deux sites
echo "Création des fichiers index.html..."
echo "<html><body><h1>Site 1 - Serveur principal</h1></body></html>" | sudo tee /var/www/html/site1/index.html
echo "<html><body><h1>Site 2 - Serveur secondaire</h1></body></html>" | sudo tee /var/www/html/site2/index.html

# Configuration du premier site virtuel sur l'adresse principale
echo "Configuration du premier site virtuel..."
echo "<VirtualHost 10.0.2.15:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/site1
    ServerName site1.idl.xfr
    ErrorLog /var/log/httpd/site1_error.log
    CustomLog /var/log/httpd/site1_access.log combined
</VirtualHost>" | sudo tee /etc/httpd/conf.d/site1.conf

# Configuration du deuxième site virtuel sur l'adresse supplémentaire
echo "Configuration du deuxième site virtuel..."
echo "<VirtualHost 10.0.2.14:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/site2
    ServerName site2.idl.xfr
    ErrorLog /var/log/httpd/site2_error.log
    CustomLog /var/log/httpd/site2_access.log combined
</VirtualHost>" | sudo tee /etc/httpd/conf.d/site2.conf

# Assurez-vous que les entrées sont dans /etc/hosts (sans les dupliquer si elles existent déjà)
echo "Vérification des entrées dans /etc/hosts..."
if ! grep -q "site1.idl.xfr" /etc/hosts; then
    echo "10.0.2.15 site1.idl.xfr" | sudo tee -a /etc/hosts
fi
if ! grep -q "site2.idl.xfr" /etc/hosts; then
    echo "10.0.2.14 site2.idl.xfr" | sudo tee -a /etc/hosts
fi

# SELinux - Ajustement des contextes pour les répertoires web
echo "Configuration des contextes SELinux..."
sudo semanage fcontext -a -t httpd_sys_content_t "/var/www/html/site1(/.*)?"
sudo semanage fcontext -a -t httpd_sys_content_t "/var/www/html/site2(/.*)?"
sudo restorecon -Rv /var/www/html/site1
sudo restorecon -Rv /var/www/html/site2

# Ajustement du pare-feu pour permettre l'accès HTTP
echo "Configuration du pare-feu..."
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload

# Redémarrage d'Apache pour appliquer les modifications
echo "Redémarrage d'Apache pour appliquer les modifications..."
sudo systemctl restart httpd

# Vérification finale
echo "Configuration terminée!"
echo "Site 1 disponible à : http://site1.idl.xfr ou http://10.0.2.15"
echo "Site 2 disponible à : http://site2.idl.xfr ou http://10.0.2.14"
