#!/usr/bin/env bash

###
### VARS
###
####COLORS
RESET="\033[0m"
BLUE="\033[94m"    # INFO
GREEN="\033[92m"  # DEBUG
YELLOW="\033[93m" # WARN
RED="\033[91m"    # CRIT

_PACKAGES_LIST=('direnv' 'stow' 'jq' 'ripgrep' 'zoxide' 'fd' 'nushell' 'unzip' 'fzf' 'fish' 'starship' 'zsh'te)

_OS=$(grep '^NAME=' /etc/os-release | cut -d "=" -f 2 | tr -d '"')

###
### FUNCTIONS
###
info() {
        echo -e "${BLUE}INFO${RESET}  - $*"
}

debug() {
        echo -e "${GREEN}DEBUG${RESET} - $*"
}

warn() {
        echo -e "${YELLOW}WARN${RESET}  - $*"
}

crit() {
        echo -e "${RED}CRIT${RESET}  - $*"
		exit 2
}

add_nushell_repo_fedora() {
	info "Adding NuShell Repo"
	
	_REPO_FILE="/etc/yum.repos.d/fury-nushell.repo"
	if [[ ! -e "$_REPO_FILE" ]]; then
		echo """[gemfury-nushell]
name=Gemfury Nushell Repo
baseurl=https://yum.fury.io/nushell/
enabled=1
gpgcheck=0
gpgkey=https://yum.fury.io/nushell/gpg.key""" | sudo tee "$_REPO_FILE" && { 
	debug "✅ repo file $_REPO_FILE creation OK"
	} || { 
		crit "❌ Error while creating repo file "
	}

else
	debug "⏩ Skipping - Repo file $_REPO_FILE already exist"
fi
}

fedora_install_package() {
	debug "Launching DNF update"
	sudo dnf update --assumeyes
	# debug "Installing ${_PACKAGES_LIST[@]}"
    sudo dnf install --assumeyes "${_PACKAGES_LIST[@]}"
}

symlink_generator_folder() {
	package="$1"
	dest="$2"
	_CURRENT_FOLDER=$(pwd)

	info "Handling $package"
	if ! find "$HOME/.config" -type l | grep "$HOME/.config/$package" > /dev/null ;then
		rm -rf "$HOME/.config/$package"
		ln -s "$(pwd)/config/$package" "$HOME/.config/$package" && { 
	debug "✅ Symlink /.config/$package done"
	} || { 
		crit "❌ Error while creating symlink ~/.config/$package"
	}
	else
		debug "⏩ Skipping - Folder ~/.config/$package already exist"
	fi
}

enable_bash_aliases() {
	info "Creating alias for CONFIG files"

	info "Handling bashrc.d"
	if ! find "$HOME/.bashrc.d" -type l | grep "$HOME/.bashrc.d" > /dev/null ;then
		rm -rf "$HOME/.bashrc.d"
		ln -s "$(pwd)/config/bashrc.d" "$HOME/.bashrc.d" && { 
	debug "✅ Symlink ~/.bashrc.d done"
	} || { 
		crit "❌ Error while creating symlink ~/.bashrc.d"
	}
	else
		debug "⏩ Skipping - Folder ~/.bashrc.d already exist"
	fi

	# Doing it with find since a symfile is not detected well by -e or -f
	info "Handling starship"
	if ! find "$HOME/.config" -type l | grep "$HOME/.config/starship.toml" > /dev/null ;then
		rm "$HOME/.config/starship.toml"
		ln -s "$(pwd)/config/starship.toml" "$HOME/.config/starship.toml" && { 
	debug "✅ Symlink ~/.config/starship.toml done"
	} || { 
		crit "❌ Error while creating symlink ~/.config/starship.toml"
	}
	else
		debug "⏩ Skipping - Folder ~/.config/starship.toml already exist"
	fi

	symlink_generator_folder "nvim"
	symlink_generator_folder "fish"
	symlink_generator_folder "wezterm"
	
}

install_jiracode_nerdfonts() {
	info "Ensure JiraCode-Mono NerdFronts are installed"
	if ls "$FONT_DIR"/JetBrains*.ttf 1> /dev/null 2>&1 || ls "$FONT_DIR"/JetBrains*.otf 1> /dev/null 2>&1;then
		font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
		curl -L -o /tmp/police.zip "$font_url"
		unzip /tmp/police.zip -d /tmp/police
		mkdir -p ~/.local/share/fonts
		cp /tmp/police/*.ttf ~/.local/share/fonts/
		# TODO - Add MacOs ~/Library/Fonts/
		debug "Update Font Cache"
		fc-cache -fv
	else
		debug "⏩ SKIPPED - Fonts already installed"
	fi
}

debug "Source .envrc"
source .env

echo "### ### ### ###"
echo "### CONFIG  ###"
echo "### ### ### ###"
enable_bash_aliases

echo "### ### ### ###"
echo "###  SHELL  ###"
echo "### ### ### ###"
add_nushell_repo_fedora
case $_OS in
	Fedora*)
		debug "Trigger $_OS	"
		fedora_install_package
	;;
esac

echo "### ### ### ###"
echo "###   GIT   ###"
echo "### ### ### ###"
info "Ensure git is well configured"
git config --global user.name "$GIT_USERNAME" && { 
	debug "✅ git config user name OK" 
	} || {
		 crit "❌ Error while configured git user name"
	}
git config --global user.email "$GIT_EMAIL" && { 
	debug "✅ git config user email OK"
	} || { 
		crit "❌ Error while configured git user email"
	}

install_jiracode_nerdfonts
