#!/bin/bash

echo "=== [SRV] Configuration du serveur LDAP ==="

# 1. Installation des paquets LDAP
echo "[+] Installation des paquets..."
sudo dnf install -y openldap-servers openldap-clients

# 2. Activation du service slapd
echo "[+] Activation du service slapd..."
sudo systemctl enable --now slapd

# 3. Configuration du pare-feu
echo "[+] Autorisation du service LDAP via le pare-feu..."
sudo firewall-cmd --permanent --add-service=ldap
sudo firewall-cmd --reload

# 4. Définition du mot de passe root (config backend)
echo "[+] Génération du mot de passe administrateur LDAP (mhello)..."
PASS_ADMIN=$(slappasswd -h '{SSHA}' -s hello)
echo "=> Mot de passe chiffré : $PASS_ADMIN"

# 5. Fichier pour modifier la configuration root LDAP
cat <<EOF | sudo tee change-root-password.ldif > /dev/null
dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $PASS_ADMIN
EOF

sudo ldapadd -Y EXTERNAL -H ldapi:/// -f change-root-password.ldif

# 6. Ajout des schémas nécessaires
echo "[+] Ajout des schémas LDAP..."
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

# 7. Configuration du domaine et des accès
cat <<EOF | sudo tee change-domain.ldif > /dev/null
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read by dn.base="cn=Manager,dc=idl,dc=xfr" read by * none

dn: olcDatabase={2}mdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=idl,dc=xfr

dn: olcDatabase={2}mdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=Manager,dc=idl,dc=xfr

dn: olcDatabase={2}mdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $PASS_ADMIN

dn: olcDatabase={2}mdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by dn="cn=Manager,dc=idl,dc=xfr" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by dn="cn=Manager,dc=idl,dc=xfr" write by * read
EOF

sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f change-domain.ldif

# 8. Création de la base de l'annuaire
cat <<EOF | sudo tee base-domain.ldif > /dev/null
dn: dc=idl,dc=xfr
objectClass: top
objectClass: dcObject
objectclass: organization
o: IDL domain
dc: idl

dn: cn=Manager,dc=idl,dc=xfr
objectClass: organizationalRole
cn: Manager
description: Directory Manager

dn: ou=People,dc=idl,dc=xfr
objectClass: organizationalUnit
ou: People

dn: ou=Group,dc=idl,dc=xfr
objectClass: organizationalUnit
ou: Group
EOF

sudo ldapadd -x -D cn=Manager,dc=idl,dc=xfr -w mhello -f base-domain.ldif

# 9. Importer les utilisateurs depuis /etc/passwd avec passwd2ldap
if [ ! -f passwd2ldap.sh ]; then
    echo "[+] Téléchargement du script passwd2ldap.sh..."
    curl -O https://jean-luc-massat.pedaweb.univ-amu.fr/ens/cca/passwd2ldap.zip
    unzip passwd2ldap.zip
    chmod +x passwd2ldap.sh
fi

# 10. Mise à jour manuelle du mot de passe si besoin
sed -i "s|-w .*|-w hello|g" passwd2ldap.sh

echo "[+] Import des utilisateurs locaux avec passwd2ldap.sh..."
sudo ./passwd2ldap.sh

# 11. Vérification
echo "[+] Vérification des utilisateurs ajoutés :"
ldapsearch -x -b "ou=People,dc=idl,dc=xfr" '(objectClass=posixAccount)' uid

echo "✅ Serveur LDAP entièrement configuré avec les utilisateurs locaux."
