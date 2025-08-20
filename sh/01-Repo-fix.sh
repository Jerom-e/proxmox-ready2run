#!/bin/bash

set -euo pipefail

# Bannière stylée
cat <<'EOF'

██████╗ ██████╗  ██████╗ ██╗  ██╗███╗   ███╗ ██████╗ ██╗  ██╗
██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝████╗ ████║██╔═══██╗╚██╗██╔╝
██████╔╝██████╔╝██║   ██║ ╚███╔╝ ██╔████╔██║██║   ██║ ╚███╔╝
██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗ ██║╚██╔╝██║██║   ██║ ██╔██╗
██║     ██║  ██║╚██████╔╝██╔╝ ██╗██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
        ⚙️ NO-SUB FIX and Custom⚙️

EOF

# Fonction log
log() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# Patch du Web UI Proxmox
patch_proxmox_web() {
    log "🔧 Application du thème dark PVE Discord Dark..."
    bash <(curl -s https://raw.githubusercontent.com/Weilbyte/PVEDiscordDark/master/PVEDiscordDark.sh) install

    log "🔧 Patch JS pour suppression du message 'no subscription'..."
    sed -i.bak "s/.data.status.toLowerCase() !== 'active') {/.data.status.toLowerCase() !== 'active') { orig_cmd(); } else if ( false ) {/" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js

    if ! grep -q "show_subscription_warning: 0" /etc/pve/datacenter.cfg 2>/dev/null; then
        echo "datacenter: show_subscription_warning: 0" >> /etc/pve/datacenter.cfg
        log "✅ Bandeau 'no subscription' désactivé via datacenter.cfg"
    else
        log "ℹ️  Bandeau 'no subscription' déjà désactivé."
    fi

    log "🔁 Redémarrage de pveproxy.service..."
    systemctl restart pveproxy.service
    log "✅ Service pveproxy redémarré."
}

# Mise à jour des dépôts
log "📦 Mise à jour des dépôts Proxmox et Ceph..."

CEPH_LIST="/etc/apt/sources.list.d/ceph.list"
PVE_LIST="/etc/apt/sources.list.d/pve-enterprise.list"

mkdir -p archive

for file in "$CEPH_LIST" "$PVE_LIST"; do
    if [[ -f "$file" ]]; then
        cp -v "$file" "${file}.bak"
        mv "${file}.bak" archive/
    fi
done

echo "deb https://download.proxmox.com/debian/ceph-reef bookworm no-subscription" > "$CEPH_LIST"
echo "deb https://download.proxmox.com/debian/pve bookworm pve-no-subscription" > "$PVE_LIST"

log "✅ Fichiers de dépôts écrasés avec les URLs no-subscription."

# Mise à jour système
log "🔄 Exécution de apt update..."
apt update -y

log "⬆️  Exécution de apt full-upgrade..."
apt full-upgrade -y

log "✅ Système mis à jour avec succès."

# Application des patches UI
patch_proxmox_web
