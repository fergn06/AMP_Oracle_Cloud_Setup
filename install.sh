#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root: sudo su -"
  exit 1
fi

arch=$(uname -m)
os_id=$(grep "^ID=" /etc/os-release | cut -d= -f2)
os_version=$(grep "^VERSION_ID=" /etc/os-release | cut -d= -f2 | tr -d '"')

if [ "$os_id" != "ubuntu" ] || [ "${os_version%%.*}" -lt 22 ]; then
  echo "Warning: This script is intended for Ubuntu Server 22+."
  echo "  Detected: $os_id $os_version | Architecture: $arch"
  read -p "Continue anyway? [Y/n]: " force
  force=${force:-Y}
  if [[ ! "$force" =~ ^[Yy]$ ]]; then
    echo "Installation canceled."
    exit 1
  fi
fi

echo "Welcome to the AMP setup assistant for Oracle Cloud Instances"
echo "This script will set up the networking rules for installing AMP"

if command -v ampinstmgr &>/dev/null || [ -d "/opt/cubecoders/amp" ]; then
  echo "AMP is already installed on this system."
  exit 1
fi

read -p "Proceed with AMP installation [Y/n]: " confirm
confirm=${confirm:-Y}
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Installation has been canceled."
  exit 0
fi

read -p "Are you going to use a domain? [Y/n]: " use_domain
use_domain=${use_domain:-Y}
if [[ "$use_domain" =~ ^[Yy]$ ]]; then
  echo "Make sure your domain points to this server's public IP and that ports 80/443"
  echo "are open in Oracle Cloud: Compute > Instances > [Server] > Virtual Cloud Network"
  echo "> Security > Default Security List > Add Ingress Rules"
  read -p "Ready to continue? [Y/n]: " ready
  ready=${ready:-Y}
  if [[ ! "$ready" =~ ^[Yy]$ ]]; then
    echo "Installation canceled."
    exit 0
  fi
fi

run_step() {
  local msg="$1"
  shift
  echo "$msg"
  local output
  output=$("$@" 2>&1) || {
    echo "  ✗ Error:"
    echo "$output"
    exit 1
  }
}

echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections

run_step "Updating repositories"          apt update
run_step "Updating packages"              apt upgrade -y
run_step "Installing iptables-persistent" apt install iptables-persistent -y

if [[ "$use_domain" =~ ^[Yy]$ ]]; then
  run_step "Allowing port 80"   iptables -I INPUT -p tcp --dport 80 -j ACCEPT
  run_step "Allowing port 443"  iptables -I INPUT -p tcp --dport 443 -j ACCEPT
else
  run_step "Allowing port 8080" iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
fi

run_step "Saving firewall rules" netfilter-persistent save

echo "Installing AMP"
bash <(curl -fsSL getamp.sh)

if [[ "$use_domain" =~ ^[Yy]$ ]]; then
  run_step "Closing port 80"       iptables -D INPUT -p tcp --dport 80 -j ACCEPT
  run_step "Saving firewall rules" netfilter-persistent save
fi

if [[ "$use_domain" =~ ^[Yy]$ ]]; then
  echo "AMP is now installed. Access the web UI at https://yourdomain.com to finish setup."
else
  echo "AMP is now installed. Access the web UI at http://$(curl -fsSL ifconfig.me):8080 to finish setup."
fi
