#!/bin/bash

# === Configuration d'un certificat TLS pour le serveur LDAP (SRV) ===

# 1. Définir les variables de domaine
DOMAIN="idl.xfr"
SERVER="srv.$DOMAIN"

# 2. Vérifier que le serveur est joignable
ping -c 2 "$SERVER" || {
    echo "[!] Le serveur $SERVER n'est pas joignable."; exit 1;
}

# 3. Ajouter la section SAN (Subject Alternative Name) dans le fichier de conf OpenSSL
echo "[+] Ajout du SAN dans /etc/ssl/openssl.cnf..."
cat <<EOF | sudo tee -a /etc/ssl/openssl.cnf > /dev/null

[ $DOMAIN ]
subjectAltName = DNS:$SERVER,IP:192.168.0.1
EOF

# 4. Génération de la clé privée avec mot de passe
cd /etc/pki/tls/certs || exit 1
echo "[+] Génération de la clé privée chiffrée..."
sudo openssl genrsa -aes128 2048 | sudo tee server.key > /dev/null

# 5. Déchiffrement de la clé (nécessite le mot de passe précédent)
echo "[+] Déchiffrement de la clé privée..."
sudo openssl rsa -in server.key -out server.key

# 6. Génération de la CSR (Certificate Signing Request)
echo "[+] Création de la CSR (certificate signing request)..."
sudo openssl req -utf8 -new -key server.key \
  -out server.csr \
  -subj "/C=FR/ST=PACA/L=MARSEILLE/O=AMU/OU=IDL/CN=$SERVER"

# 7. Signature du certificat auto-signé
echo "[+] Signature du certificat (auto-signé)..."
sudo openssl x509 -in server.csr -out server.crt \
    -req -signkey server.key \
    -extfile /etc/ssl/openssl.cnf -extensions $DOMAIN -days 3650

# 8. Protection de la clé
sudo chmod 600 server.key

# 9. Vérification du certificat
sudo openssl x509 -text -in server.crt

# 10. Afficher les fichiers générés
ls -l /etc/pki/tls/certs/server.*

# === Déploiement dans OpenLDAP ===

echo "[+] Déploiement du certificat dans OpenLDAP..."

# 11. Copier les fichiers dans /etc/openldap/certs/
sudo cp /etc/pki/tls/certs/server.{crt,key} /etc/openldap/certs/

# 12. Droits pour OpenLDAP
sudo chown ldap:ldap /etc/openldap/certs/server.{crt,key}
sudo chmod 600 /etc/openldap/certs/server.key

# 13. Appliquer la configuration TLS dans LDAP via un LDIF
cat <<EOF | sudo tee mod_ssl.ldif > /dev/null
dn: cn=config
changetype: modify
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/openldap/certs/server.crt
-
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/openldap/certs/server.key
EOF

# 14. Appliquer le LDIF
sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f mod_ssl.ldif

# 15. Redémarrage du service
echo "[+] Redémarrage du service slapd..."
sudo systemctl restart slapd

# 16. Vérification de l'écoute TLS (port 636)
sudo ss -tulnp | grep slapd

echo -e "\n✅ TLS est activé sur le serveur LDAP avec STARTTLS ou LDAPS."
