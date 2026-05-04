<div align="center">

# 🎮 AMP Setup for Oracle Cloud

**Install AMP on Oracle Cloud in one script.**
**Instala AMP en Oracle Cloud con un solo script.**

[![Bash](https://img.shields.io/badge/Bash-5.0+-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Oracle%20Cloud-F80000?logo=oracle&logoColor=white)](https://www.oracle.com/cloud/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22%2B-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

> ⚠️ **Unofficial project.** This is not affiliated with or endorsed by [CubeCoders](https://cubecoders.com/). It is a community tool to simplify the AMP installation process on Oracle Cloud instances.

</div>

---

## 🇬🇧 English

### What is this?

A set of scripts that automate the installation of [AMP (Application Management Panel) by CubeCoders](https://cubecoders.com/AMP) on Oracle Cloud instances. They handle the firewall configuration that Oracle Cloud requires and that differs from a standard Ubuntu installation.

### Why does Oracle Cloud need special treatment?

Installing AMP on a standard Ubuntu VM is straightforward — you run the one-line installer and you're done. On Oracle Cloud, it's a different story.

Oracle Cloud instances ship with a heavily customized `iptables` configuration. Even if you open ports in the Oracle Cloud dashboard (Security Lists), traffic will still be blocked at the OS level, because Oracle's images include default `iptables` rules with a `DROP` policy on the `INPUT` chain.

This means any port not explicitly allowed in `iptables` is silently dropped, regardless of what the cloud firewall allows — which is not how a typical VPS or local VM behaves.

| | Standard Ubuntu VM | Oracle Cloud Ubuntu |
|---|---|---|
| Default iptables policy | ACCEPT | DROP |
| Port management | Cloud dashboard only | Cloud dashboard + OS iptables |
| Ports open after install | Most common ones | Only SSH (22) |

### Scripts

- **`install.sh`** — Full AMP installation with automated firewall setup
- **`ports.sh`** — Interactive port manager to open and close ports after installation

### Requirements

- Oracle Cloud instance (ARM or x86_64)
- Ubuntu Server 22.04 or later
- Ports 80 and 443 (or 8080) open in the Oracle Cloud Security List

> ⚠️ **Important:** Make sure to open the required ports in the Oracle Cloud dashboard **before** running the script: **Compute → Instances → [Your instance] → Virtual Cloud Network → Security → Default Security List → Add Ingress Rules**

### Installation

```bash
sudo su -
curl -fsSL https://raw.githubusercontent.com/fergn06/AMP_Oracle_Cloud_Setup/refs/heads/main/install.sh -o install.sh
chmod +x install.sh
./install.sh
```

### How does it work?

1. Run `install.sh` as root
2. Confirm you want to proceed with the installation
3. Choose whether you'll use a domain (ports 80/443) or not (port 8080)
4. If using a domain, make sure it points to your server's public IP before continuing
5. The script installs dependencies, opens the necessary ports and runs the official AMP installer
6. Once AMP is installed, port 80 is automatically closed (it was only needed for SSL certificate generation)
7. Access the AMP web UI at the URL shown at the end of the script

### Port manager

```bash
sudo su -
chmod +x ports.sh
./ports.sh
```

Lists all currently open TCP ports and lets you open or close them interactively. Changes are saved automatically.

### Notes

- The AMP installer must run as root without `sudo` — this is a requirement from CubeCoders, not a bug in the script
- Port 80 is only needed temporarily when using a domain, for Let's Encrypt SSL certificate generation
- If you're not using a domain, AMP will be accessible on port 8080 without SSL

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 👤 Credits

Created by **Fernando Guerrero Nuez** — Systems Administrator

🌐 [fernandoguerreronuez.com](https://fernandoguerreronuez.com/)

---

## 🇪🇸 Español

### ¿Qué es esto?

Un conjunto de scripts que automatizan la instalación de [AMP (Application Management Panel) de CubeCoders](https://cubecoders.com/AMP) en instancias de Oracle Cloud. Gestionan la configuración del firewall que Oracle Cloud requiere y que difiere de una instalación estándar de Ubuntu.

### ¿Por qué Oracle Cloud necesita un trato especial?

Instalar AMP en una VM Ubuntu estándar es sencillo: ejecutas el instalador de una línea y listo. En Oracle Cloud, la historia es diferente.

Las instancias de Oracle Cloud vienen con una configuración de `iptables` muy personalizada. Aunque abras los puertos en el panel de Oracle Cloud (Security Lists), el tráfico seguirá siendo bloqueado a nivel del sistema operativo, porque las imágenes de Oracle incluyen reglas de `iptables` con política `DROP` en la cadena `INPUT`.

Esto significa que cualquier puerto no permitido explícitamente en `iptables` se descarta silenciosamente, independientemente de lo que permita el firewall cloud — lo cual no es el comportamiento habitual en un VPS o una VM local.

| | Ubuntu VM estándar | Ubuntu en Oracle Cloud |
|---|---|---|
| Política iptables por defecto | ACCEPT | DROP |
| Gestión de puertos | Solo panel cloud | Panel cloud + iptables del SO |
| Puertos abiertos tras instalar | La mayoría de los comunes | Solo SSH (22) |

### Scripts

- **`install.sh`** — Instalación completa de AMP con configuración automática del firewall
- **`ports.sh`** — Gestor interactivo de puertos para abrir y cerrar puertos tras la instalación

### Requisitos

- Instancia de Oracle Cloud (ARM o x86_64)
- Ubuntu Server 22.04 o superior
- Puertos 80 y 443 (o 8080) abiertos en la Security List de Oracle Cloud

> ⚠️ **Importante:** Asegúrate de abrir los puertos necesarios en el panel de Oracle Cloud **antes** de ejecutar el script: **Compute → Instances → [Tu instancia] → Virtual Cloud Network → Security → Default Security List → Add Ingress Rules**

### Instalación

```bash
sudo su -
curl -fsSL https://raw.githubusercontent.com/fergn06/AMP_Oracle_Cloud_Setup/refs/heads/main/install.sh -o install.sh
chmod +x install.sh
./install.sh
```

### ¿Cómo funciona?

1. Ejecuta `install.sh` como root
2. Confirma que quieres proceder con la instalación
3. Elige si vas a usar un dominio (puertos 80/443) o no (puerto 8080)
4. Si usas un dominio, asegúrate de que apunta a la IP pública del servidor antes de continuar
5. El script instala las dependencias, abre los puertos necesarios y ejecuta el instalador oficial de AMP
6. Una vez instalado AMP, el puerto 80 se cierra automáticamente (solo era necesario para generar el certificado SSL)
7. Accede al panel web de AMP en la URL que muestra el script al final

### Gestor de puertos

```bash
sudo su -
chmod +x ports.sh
./ports.sh
```

Lista todos los puertos TCP abiertos actualmente y permite abrirlos o cerrarlos de forma interactiva. Los cambios se guardan automáticamente.

### Notas

- El instalador de AMP debe ejecutarse como root sin `sudo` — es un requisito de CubeCoders, no un error del script
- El puerto 80 solo es necesario temporalmente cuando se usa un dominio, para la generación del certificado SSL con Let's Encrypt
- Si no se usa un dominio, AMP será accesible por el puerto 8080 sin SSL

---

## 👤 Créditos

Creado por **Fernando Guerrero Nuez** — Administrador de Sistemas

🌐 [fernandoguerreronuez.com](https://fernandoguerreronuez.com/)
