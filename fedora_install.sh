#!/bin/bash

# script para automatizar a pós instalação do Fedora Workstation 42 com Gnome.

echo '========== Iniciando Pós-Intalação =========='

# configurações
set -e           # exit on error
cd $(mktemp -d)  # vai para um diretório temporário

# atualizando apps e repositórios
sudo dnf upgrade
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo  # habilita flatpak (se preciso)

# para o VScode
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null


# instalações ---------------------------------------------
# dnf e flatpak =====================
dnf_install=(
	# RPM Fusion Freen e Nonfree
	https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm        # Free
	https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm  # Nonfree
	
	# gerais
    gnome-tweaks
    code R
	htop btop fastfetch # utilitário de sistema
    fira-code-fonts     # fontes
)

flat_install=(
	com.discordapp.Discord
    com.valvesoftware.Steam
    com.mattjakeman.ExtensionManager
)

echo 'instalando aplicativos...'
sudo dnf install -yq ${dnf_install[@]}
flatpak install -y flathub ${flat_install[@]}


# instalações manuais ================
# Rstudio (Fedora 41)
echo 'Instalando Rstudio...'
wget -O rstudio.rpm https://download1.rstudio.org/electron/rhel9/x86_64/rstudio-2025.09.1-401-x86_64.rpm
sudo dnf install -y ./rstudio.rpm


# configurações do DE -------------------------------------
gsettings set org.gnome.desktop.interface clock-format '24h'


# dotfiles ------------------------------------------------
echo 'Baixando configurações (dotfiles)...'
git clone https://github.com/jsicas/dotfiles.git ~/.dotfiles
bash ~/.dotfiles/mk_config.sh

# finalizar instalando as extensões
# dash to panel, search light
