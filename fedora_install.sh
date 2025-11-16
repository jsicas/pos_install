#!/usr/bin/env bash 

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


# instalações =============================================
# pacotes para instalação -----------
dnf_install=(
	# RPM Fusion Freen e Nonfree
	https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm        # Free
	https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm  # Nonfree
	
	# gerais
    gnome-tweaks code rclone
	htop btop fastfetch # utilitário de sistema
    fira-code-fonts     # fontes
    libxcrypt-compat    # se não instalar da problema com as referência no LaTeX   

    # R e pacotes 
    R libcurl-devel openssl-devel libxml2-devel fontconfig-devel harfbuzz-devel fribidi-devel
    freetype-devel libpng-devel libtiff-devel libjpeg-devel libwebp-devel v8-devel
    gdal-devel proj-devel geos-devel sqlite-devel udunits2 udunits2-devel abseil-cpp-devel
)

flat_install=(
	com.discordapp.Discord
    com.valvesoftware.Steam
    com.mattjakeman.ExtensionManager
)

echo 'instalando aplicativos (dnf)...'
sudo dnf install -yq ${dnf_install[@]}

echo 'instalando aplicativos (flatpak)...'
flatpak install -y flathub ${flat_install[@]}


# instalações manuais ---------------
# Rstudio (Fedora 41)
echo 'Instalando Rstudio...'
wget -O rstudio.rpm https://download1.rstudio.org/electron/rhel9/x86_64/rstudio-2025.09.1-401-x86_64.rpm
sudo dnf install -y ./rstudio.rpm


# configurações do DE =====================================
gsettings set org.gnome.desktop.interface clock-format '24h'
gsettings set org.gnome.desktop.session idle-delay 600  # tempo para desligamento de tela por inatividade

# desativando funções de suspender
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'       # usando o carregador
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'  # na bateria

# atalho <super> + t para abrir terminal
# deve-se verificar antes quais atalhos já estão definidos, como não havia nenhum, foi utilizado custom0.
#gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings  # ver atalhos já definidos
slot='/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$slot name 'Abrir Terminal (Ptyxis)'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$slot command 'ptyxis'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$slot binding '<Super>t'
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$slot']"


# dotfiles ================================================
echo 'Baixando configurações (dotfiles)...'
git clone https://github.com/jsicas/dotfiles.git ~/.dotfiles
bash ~/.dotfiles/mk_config.sh


# TeX Live ================================================
echo 'Removendo TeX Live padrão...'
sudo dnf remove -y texlive*
echo 'Instalando TeX Live...'
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
zcat < install-tl-unx.tar.gz | tar xf -
cd install-tl-2*
perl ./install-tl -profile ../texlive.profile
# Após a instalação é necessário colocar o TeX Live no PATH, no geral isso envolve colocar as seguintes linhas no .profile (parece estar caindo em desuso) ou no .bash_profile:
#export PATH="$HOME/.texlive/2025/bin/x86_64-linux:$PATH"
#export MANPATH="$HOME/.texlive/2025/texmf-dist/doc/man:$MANPATH"
#export INFOPATH="$HOME/.texlive/2025/texmf-dist/doc/info:$INFOPATH"
# No meu caso, como já estão nos meus dotfiles, essa etapa será pulada.

source ~/.bash_profile  # aplicando configurações do PATH para tlmgr funcionar

# instalando pacotes do LaTeX
tlmgr_install=(
    mathtools multirow float csquotes xypic algorithm2e ifoddpage relsize
    caption appendix forest
)
tlmgr install ${tlmgr_install[@]}

# finalizar instalando as extensões
# - dash to panel: configurações da barra de tarefas;
# - search light: laucher de apps;
# - AppIndicator and KStatusNotifierItem Support: habilita suporte à indicadores na barra de tarefas;
# - Disable unredirect fullscreen windows: resolve problema de tearing em janelas que utilizam aceleração de hardware
# - Steal my focus window: ao invés de aparecer uma notificação, simplesmente já abre a janela, sem precisar ter que selecionar o popup. 
