#!/bin/bash
# Script pour configurer le mot de passe GRUB

echo "Configuration du mot de passe GRUB..."

# Définir le mot de passe GRUB
echo "Vous allez être invité à définir le mot de passe GRUB."
sudo grub2-setpassword

# Vérifier le fichier user.cfg
echo "Contenu du fichier user.cfg:"
sudo cat /boot/grub2/user.cfg

# Reconstruire la configuration GRUB
echo "Reconstruction de la configuration GRUB..."
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
echo "Configuration GRUB mise à jour."

echo "Configuration du mot de passe GRUB terminée."
