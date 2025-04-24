
#!/bin/bash
echo "Création des utilisateurs locaux avec UID à partir de 2005..."

# Liste des utilisateurs à créer
USERS=("alice" "bob" "tom")
# Mot de passe pour tous les utilisateurs
PASSWORD="hello"
# UID de départ
START_UID=2005

# Création des utilisateurs
for i in "${!USERS[@]}"; do
    USER="${USERS[$i]}"
    USER_ID=$((START_UID + i))
    
    # Vérifier si l'utilisateur existe déjà
    if id "$USER" &>/dev/null; then
        echo "L'utilisateur $USER existe déjà."
    else
        echo "[+] Création de l'utilisateur $USER (UID=$USER_ID, GID=$USER_ID)..."
        
        # Créer d'abord le groupe
        sudo groupadd -g "$USER_ID" "$USER"
        
        # Ensuite créer l'utilisateur avec le groupe correct
        sudo useradd -m -s /bin/bash -u "$USER_ID" -g "$USER" "$USER"
        
        # Définir le mot de passe
        echo "$USER:$PASSWORD" | sudo chpasswd
        echo "Utilisateur $USER créé avec mot de passe '$PASSWORD'"
    fi
done

# Vérification
echo
echo "Vérification des utilisateurs créés:"
for USER in "${USERS[@]}"; do
    echo -n "Utilisateur $USER: "
    if id "$USER" &>/dev/null; then
        echo "OK"
        echo "  UID/GID: $(id -u $USER)/$(id -g $USER)"
        echo "  Répertoire d'accueil: $(eval echo ~$USER)"
    else
        echo "NON CRÉÉ"
    fi
done

echo
echo "✅ Configuration des utilisateurs terminée."
