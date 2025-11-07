# ----------------------------
# Network configuration
# ----------------------------
ip_pves = [
  "192.168.0.101", # IP du nœud Proxmox 1
  "192.168.0.102", # IP du nœud Proxmox 2
  "192.168.0.103"  # IP du nœud Proxmox 3
]

# Adresse IP du nœud maître Proxmox (ex: premier nœud de la liste)
pve_master_ip = "192.168.0.101"


# ----------------------------
# SSH connection
# ----------------------------
# Nom d'utilisateur SSH (souvent "root")
ssh_user = "root"

# Chemin local vers la clé privée SSH (ex: ~/.ssh/id_ed25519)
ssh_private_key = "~/.ssh/id_ed25519"
