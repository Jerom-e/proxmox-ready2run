# proxmox-ready2run

**Automated toolkit for Proxmox VE** – préparez un environnement prêt à l'emploi, sécurisé et automatisé.

---

## ​ Objectif

Ce projet applique les bonnes pratiques Infrastructure-as-Code sur Proxmox VE :

- Configuration sécurisée par défaut (dépôts, ports)
- Création automatisée d’utilisateurs et de tokens API
- Protection contre les intrusions via **Fail2ban**
- Génération de **templates VM** (AlmaLinux 9, Debian 12/13)
- Création de **pools Proxmox VE**
- Simplifie la gestion et le déploiement de nœuds Proxmox pour les équipes infra

---

##  Structure du dépôt

```text
├── variables.tf # Déclaration des variables
├── terraform.tfvars.sample # Exemple de configuration (sans données sensibles)
├── 01-Pve-initialization.tf # Initialisation des nœuds Proxmox VE
├── 02-Master-initialization.tf # Initialisation spécifique du nœud maître
├── conf/                        # Configuration des services
│   ├── jail.local               # Configuration Fail2ban
│   ├── proxmox.conf             # Configuration Proxmox spécifique Fail2ban
│   ├── sshd_config              # Paramètres SSH
├── sh/                          # Scripts d’automatisation
│   ├── 01-Repo-fix.sh           # Correction des dépôts Proxmox
│   ├── 02_create_pam_user.sh    # Création d’utilisateurs PAM
│   ├── 03_secure_access.sh      # Sécurisation de l’accès SSH
│   ├── 04_create_pve_user.sh    # Création d’utilisateurs Proxmox + tokens
│   └── 05_create_env.sh         # Création de templates et pools
└── README.md # Ce document
```


---

##  Mise en route

1. **Cloner le dépôt**
   ```bash
   git clone git@github.com:Jerom-e/proxmox-ready2run.git
   cd proxmox-ready2run

    Créer ton fichier de configuration personnalisé

Edite terraform.tfvars avec tes IPs, utilisateur SSH, chemin de la clé privée, etc.

Initialiser Terraform
Vérifier ta configuration


   ```bash
   terraform init
   terraform plan
   ```


   Appliquer
   ```bash
   terraform apply
   ```
   
Points forts (pour RH & équipes techniques)
Atout	Description
Documenté & structuré	Variables bien nommées, exemple .tfvars, instructions claires
Sécurisé	Ports personnalisés, utilisateurs non root, hardening Fail2ban
Automatisé	Onboarding de nœuds Proxmox sans scripts manuels
Extensible	Ajout de nouveaux templates ou pools facilement
À savoir

    N’incluez pas de secrets (IPs internes, clés privées…) dans Git : utilisez terraform.tfvars.sample comme modèle.

    Séparation des rôles bien claire :

        01-Pve-initialization.tf = configuration commune à tous les nœuds

        02-Master-initialization.tf = actions spécifiques au maître

Besoin d’aide ?

N’hésite pas à me contacter ou à ouvrir une issue sur ce repo. Je suis là pour t’accompagner !
