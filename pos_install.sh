#!/bin/bash

# script para automatizar a pós instalação do popOS 22

set -e  # exit on error

echo '========== Iniciando Pós-Intalação =========='

# definindo arrays de aplicativos para instalar, extensões para desabilitar...

# apps para instalar
apt_apps=(
    gnome-software
    flatpak gnome-software-plugin-flatpak
    steam-installer
    nvidia-driver-libs:i386 # steam precisa de drivers 32-bits para funcionar
)

flat_apps=(
    com.discordapp.Discord
)

# extensões para desabilitar
gnome_extension_disable=(
    ding@rastersoft.com     # retira icones do Desktop
)


# atualização e downloads ---------------------------------
# apps disponíveis no apt ===========
echo 'Atualizando repositórios...'
sudo dpkg --add-architecture i386  # habilita 32-bits support para a steam
sudo apt update -qq
sudo apt upgrade -yqq

echo 'Download dos aplicativos...'
sudo apt install -yqq ${apt_apps[@]}

echo 'habilitando flathub e instalando aplicativos...'
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo  # adiciona flathub
flatpak install -y flathub ${flat_apps[@]}


# demais apps =======================
cd $(mktemp -d)  # vai para um diretório temporário

# R (Ubuntu e derivados)
echo 'Instalando R...'
sudo apt install -qq --no-install-recommends software-properties-common dirmngr
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
sudo add-apt-repository -y "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
sudo apt install -yqq --no-install-recommends r-base r-base-dev

# Rstudio (Ubuntu 24)
echo 'Instalando Rstudio...'
wget -O rstudio.deb https://download1.rstudio.org/electron/jammy/amd64/rstudio-2025.09.1-401-amd64.deb
sudo apt install -yqq ./rstudio.deb


# baixando fontes ===================
# Fira Code

# JetBrains Mono


# download, config e desabilitando extensões --------------
echo 'Configurando extensões...'

# baixando

# configurando

# desabilitando
for extension in ${gnome_extension_disable[@]}; do
    gnome-extensions disable "$extension"
done


echo 'Fim da Pós-Instalação.'
