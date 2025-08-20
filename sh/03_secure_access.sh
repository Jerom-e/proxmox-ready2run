#!/bin/bash

set -euo pipefail

######################################################################
# 🔐 SCRIPT DE DURCISSEMENT DES PORTS PROXMOX ET SSH                 #
# - SSH : passe de 22 → port personnalisé (via sshd_config fourni)   #
# - Proxmox GUI : passe de 8006 → $NEW_GUI_PORT                      #
# - Active fail2ban + journalisation dans /home/adminpam/keyvault/  #
# Auteur : Jérôme Quandalle                                          #
######################################################################

### === CONFIGURATION === ###
NEW_GUI_PORT="64086"
SSH_CONFIG="/etc/ssh/sshd_config"
DATE_TAG=$(date +%Y%m%d%H%M%S)

LOG_DIR="/home/adminpam/keyvault"
FINAL_LOG="${LOG_DIR}/port_de_connexion.log"

PVE_FILES_TO_PATCH=(
    "/usr/share/perl5/PVE/Firewall.pm"
    "/usr/share/perl5/PVE/Cluster/Setup.pm"
    "/usr/share/perl5/PVE/APIServer/AnyEvent.pm"
    "/usr/share/perl5/PVE/API2/LXC.pm"
    "/usr/share/perl5/PVE/API2/Qemu.pm"
    "/usr/share/perl5/PVE/APIClient/LWP.pm"
    "/usr/share/perl5/PVE/CLI/pct.pm"
    "/usr/share/perl5/PVE/CLI/qm.pm"
    "/usr/share/perl5/PVE/Service/pveproxy.pm"
)

### === LOGGING === ###
log() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cp "$file" "${file}.bak-${DATE_TAG}"
        log "📦 Backup : $file → ${file}.bak-${DATE_TAG}"
    fi
}

### === CONFIGURATION SSH === ###
secure_ssh_port() {
    log "🔧 Reconfiguration de SSH via $SSH_CONFIG"

    backup_file "$SSH_CONFIG"

    if [[ -f /tmp/sshd_config ]]; then
        cp /tmp/sshd_config "$SSH_CONFIG"
        log "✅ Nouveau sshd_config appliqué"
    else
        log "❌ Fichier /tmp/sshd_config introuvable. Abandon."
        exit 1
    fi

    apt update -y && apt install -y fail2ban

    # Ajout de la config fail2ban
    [[ -f /tmp/jail.local ]] && cp /tmp/jail.local /etc/fail2ban/
    [[ -f /tmp/proxmox.conf ]] && cp /tmp/proxmox.conf /etc/fail2ban/

    systemctl restart sshd
    log "✅ SSH redémarré avec succès"
}

### === MODIFICATION DU PORT GUI PROXMOX === ###
change_pve_gui_port() {
    log "🌐 Changement du port Web GUI Proxmox → $NEW_GUI_PORT"

    for file in "${PVE_FILES_TO_PATCH[@]}"; do
        backup_file "$file"
        sed -i "s|8006|${NEW_GUI_PORT}|g" "$file"
    done

    systemctl restart pveproxy
    systemctl restart pvedaemon

    log "✅ Proxmox GUI réactivé sur le port : $NEW_GUI_PORT"
}

### === ÉCRITURE DU JOURNAL FINAL === ###
write_final_log() {
    mkdir -p "$LOG_DIR"
    chown adminpam:adminpam "$LOG_DIR"
    chmod 700 "$LOG_DIR"

    cat <<EOF > "$FINAL_LOG"
┌──────────────────────────────────────────────────────┐
│         🔐 CONFIGURATION DE SÉCURITÉ APPLIQUÉE         │
├──────────────────────────────────────────────────────┤
│   🕒 Date : $(date '+%Y-%m-%d %H:%M:%S')                        
│                                                      
│   ✅ Fail2ban installé et activé                      
│   ✅ Proxmox UI accessible sur le port : ${NEW_GUI_PORT} 
│                                                      
│   📂 Ce fichier : $FINAL_LOG                         
└──────────────────────────────────────────────────────┘

⚠️ Pense à mettre à jour tes règles de pare-feu si nécessaire !
EOF

    chown adminpam:adminpam "$FINAL_LOG"
    chmod 600 "$FINAL_LOG"

    log "📝 Journal de configuration enregistré dans : $FINAL_LOG"
}

### === EXÉCUTION === ###
cat <<'EOF'
███████╗███████╗ ██████╗██╗   ██╗██████╗ ███████╗     █████╗  ██████╗ ██████╗███████╗███████╗███████╗
██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██╔════╝    ██╔══██╗██╔════╝██╔════╝██╔════╝██╔════╝██╔════╝
███████╗█████╗  ██║     ██║   ██║██████╔╝█████╗      ███████║██║     ██║     █████╗  ███████╗███████╗
╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██╔══╝      ██╔══██║██║     ██║     ██╔══╝  ╚════██║╚════██║
███████║███████╗╚██████╗╚██████╔╝██║  ██║███████╗    ██║  ██║╚██████╗╚██████╗███████╗███████║███████║
╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝╚══════╝╚══════╝╚══════╝
      🔒 DURCISSEMENT DES PORTS SSH & GUI PROXMOX
EOF
echo

log "🚀 Début du durcissement système"
secure_ssh_port
change_pve_gui_port
write_final_log
log "✅ Script terminé avec succès"
