#!/bin/bash

# script para automatizar a pós instalação do Fedora Workstation 42 com Gnome.

echo '========== Iniciando Pós-Intalação =========='

# configurações
set -e           # exit on error
cd $(mktemp -d)  # vai para um diretório temporário

# atualizando apps e repositórios
sudo dnf upgrade
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo  # habilita flatpak (se preciso)


# instalações ---------------------------------------------
# dnf e flatpak =====================
dnf_install=(
	# gerais
	gnome-tweaks
    R
	htop btop fastfetch # utilitário de sistema

	# RPM Fusion Freen e Nonfree
	https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm        # Free
	https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm  # Nonfree
)

flat_install=(
	com.discordapp.Discord
	com.valvesoftware.Steam

)

# instalando aplicativos
sudo dnf install -yq ${dnf_install[@]}
flatpak install -y flathub ${flat_install[@]}


# instalações manuais ================
# Rstudio (Fedora 41)
echo 'Instalando Rstudio...'
if 
wget -O rstudio.deb https://download1.rstudio.org/electron/rhel9/x86_64/rstudio-2025.09.1-401-x86_64.rpm
sudo dnf install  ./rstudio.deb


# baixando e aplicando dotfiles ---------------------------
echo 'Baixando configurações (dotfiles)...'
git clone https://github.com/jsicas/dotfiles.git ~/.dotfiles
bash ~/.dotfiles/mk_config.sh
