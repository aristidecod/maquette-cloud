# ☁️ Maquette Cloud – Projet Réseau et Services

Ce dépôt contient les scripts et fichiers de configuration permettant de déployer une infrastructure complète avec serveur central (SRV) et trois clients (C1, C2, C3), dans le cadre du devoir de virtualisation réseau.

## 📦 Objectif

> L'objectif est de construire une maquette réseau complète avec :
- services réseau (DHCP, DNS, SSH, routage, etc.),
- services systèmes (LDAP, quotas, NFS, mail),
- déploiement d'une application web Java (films) en 2 instances via Docker Compose.

## 🔧 Déploiement

Les scripts sont fournis pour automatiser l’installation et la configuration sur les VMs.

Les VMs prêtes à l’emploi sont disponibles ici :

🔗 [Télécharger les machines virtuelles (.ova)](https://1drv.ms/f/c/5968be9927cfc2a1/EpWS9nbqJXlIkjoOMUPNGd8BrbnhdI3zwNEK9Fg8yAq_rg?e=tx7lLw)

## 📁 Structure du dépôt

```
maquette-cloud/
├── configuration-files/
│   ├── cat configure_ldap_srv.sh
│   ├── config_grub.sh
│   ├── config_network.sh
│   ├── configure_autofs_c1.sh
│   ├── configure_dhcp.sh
│   ├── configure_dnsmasq.sh
│   ├── configure_httpd.sh
│   ├── configure_nfs.sh
│   ├── configure_quotas.sh
│   ├── create_users.sh
│   ├── generate_ldap_tls_cert.sh
│   ├── iptables_rules.sh
│   ├── setup_movie_app.sh
│   └── setup-quotas-home-service.sh
└── README.md
```

## 🧪 Services en place

✅ DHCP  
✅ DNSMasq  
✅ NFS  
✅ LDAP + TLS  
✅ Serveur Mail centralisé (Postfix)  
✅ Quotas disque (/home et /)  
✅ SSH avec redirection de ports  
✅ Serveur HTTP avec VirtualHosts  
✅ Routage & NAT  
✅ Application de gestion de films (SpringBoot + MySQL + HAProxy) déployée en 2 instances avec Docker Compose

## 👨‍💻 Auteur

Projet réalisé par **Ouattara Aristide** dans le cadre du module Virtualisation Réseau et Services.
