#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root: sudo su -"
  exit 1
fi

show_ports() {
  echo ""
  echo "Open TCP ports (iptables INPUT ACCEPT):"
  local ports
  ports=$(iptables -L INPUT -n --line-numbers | awk '/ACCEPT.*tcp.*dpt:/{print "  - Port " $NF}' | sed 's/.*dpt://')
  if [ -z "$ports" ]; then
    echo "  No open ports found."
  else
    echo "$ports"
  fi
  echo ""
}

show_ports

while true; do
  echo "What do you want to do?"
  echo "  1) Open a port"
  echo "  2) Close a port"
  echo "  3) Exit"
  read -p "Select an option [1/2/3]: " option

  case $option in
    1)
      read -p "Port to open: " port
      if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo "  ✗ Invalid port."
        continue
      fi
      iptables -I INPUT -p tcp --dport "$port" -j ACCEPT
      netfilter-persistent save &>/dev/null
      echo "  ✓ Port $port opened."
      show_ports
      ;;
    2)
      read -p "Port to close: " port
      if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo "  ✗ Invalid port."
        continue
      fi
      if iptables -C INPUT -p tcp --dport "$port" -j ACCEPT 2>/dev/null; then
        iptables -D INPUT -p tcp --dport "$port" -j ACCEPT
        netfilter-persistent save &>/dev/null
        echo "  ✓ Port $port closed."
      else
        echo "  ✗ Port $port is not open."
      fi
      show_ports
      ;;
    3)
      echo "Bye."
      exit 0
      ;;
    *)
      echo "  ✗ Invalid option."
      ;;
  esac
done
