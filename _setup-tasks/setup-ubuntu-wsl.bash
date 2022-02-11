#!/bin/bash
# Script: setup-ubuntu-wsl.bash
# Purpose: Setup development evironment on WSL (Windows Subsystem for Linux) Ubuntu.
# Note: You can start VS Code from your Windows desktop and connect to WSL Targets via the Remote-Explorer (sidebar).
# Copyright (C) 2022 Florian Hotze under MIT License

# Colors for output
red=$(tput setaf 1)
green=$(tput setaf 2)
# shellcheck disable=SC2034
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
reset=$(tput sgr0)

if (( EUID == 0 )); then
    echo "${red}Please do not run as root!"
    echo "Instead, the script will use sudo when it is required and asks for password.${reset}"
    exit
fi

unset command_not_found_handle

run_with_echo() {
    cmd=${1}
    successMessage=${2}
    errorMessage=${3}
    if eval "${cmd}"; then echo "${green}${successMessage}${blue}"; else echo "${red}${errorMessage}${blue}"; fi
}

echo "${reset}Updating package list ...${blue}"
sudo apt update &> /dev/null

# Install git.
if ! command -v git &>/dev/null; then
    echo "${reset}Installing git ...${blue}"
    run_with_echo "sudo apt install -y git" "Installed git." "Failed to install git."
fi

configure_git() {
    echo -n "${reset}Set Git username (prename surname): "
    read -r gitUsername
    echo -n "Set Git email: "
    read -r gitEmail
    echo -n "${blue}"
    git config --global user.name "${gitUsername}"
    git config --global user.email "${gitEmail}"
    echo "${red}Please remember to set up the commit sigining key."
    echo "For reference, visit: https://docs.github.com/en/authentication/managing-commit-signature-verification ${reset}"
}

echo "${red}Do you want to configure git? (y/n)"
read -r choice
case "$choice" in 
    y|Y ) configure_git;;
    n|N ) ;;
    * ) echo "invalid";;
esac

# Install node version manager.
if ! [ -f "${NVM_DIR}/nvm.sh" ]; then
    echo "${reset}Installing node version manager (nvm-sh) ...${blue}"
    if command -v node; then
        echo "${reset}Node already installed.${blue}"
        run_with_echo "sudo apt remove -y nodejs" "Uninstalled node." "Failed to uninstall node."
    fi
    run_with_echo "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash" "Installed node version manager (nvm-sh)." "Failed to install node version manager!"
    # shellcheck disable=SC1091
    source "${HOME}/.bashrc"
fi

# shellcheck disable=SC2155 
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Install latest LTS and openHAB-used NodeJS versions, use latest.
echo "${green}Installing NodeJS versions ...${blue}"
run_with_echo "nvm install --lts" "Installed NodeJS latest LTS version using nvm." "Failed to install NodeJS latest LTS version using nvm!"
run_with_echo "npm install -g semistandard &>/dev/null" "Installed semistandard using npm." "Failed to install semistadard using npm."
run_with_echo "nvm install 12.16.1" "Installed NodeJS version 12.16.1 using nvm." "Failed to install NodeJS version 12.16.1 using nvm!"
run_with_echo "npm install -g semistandard &>/dev/null" "Installed semistandard using npm." "Failed to install semistadard using npm."
nvm use --lts

# Install Java 11.
run_with_echo "sudo apt install -y openjdk-11-jdk" "Installed Java 11 JDK (OpenJDK)." "Failed to install Java 11 JDK (OpenJDK)!"

# Install Apache Maven.
run_with_echo "sudo apt install -y maven" "Installed Maven Build System." "Failed to install Maven Build System."
