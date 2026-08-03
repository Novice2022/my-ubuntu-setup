#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Installing bootstrap dependencies ==="

sudo apt install -y \
    git \
    curl \
    ca-certificates

echo "=== Updating packages ==="

sudo apt update

echo "=== Installing terminal tools ==="

sudo apt install -y \
    zsh \
    fzf \
    bat \
    eza \
    fd-find \
    ripgrep \
    btop \
    jq

echo "=== Installing recommended AGENTS.md tools ==="

sudo apt install -y \
    gh \
    yq \
    jc \
    ripgrep-all

echo "=== Installing Oh My Zsh ==="

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "=== Installing plugins ==="

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
    git clone https://github.com/zsh-users/zsh-completions \
        "$ZSH_CUSTOM/plugins/zsh-completions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

echo "=== Installing zoxide ==="

if ! command -v zoxide >/dev/null 2>&1; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

echo "=== Installing Starship ==="

if ! command -v starship >/dev/null 2>&1; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

echo "=== Installing JetBrains Mono Nerd Font ==="

if ! fc-list | grep -qi "JetBrainsMono Nerd"; then

    FONT_DIR="$HOME/.local/share/fonts"

    mkdir -p "$FONT_DIR"

    (
        TMP_DIR="$(mktemp -d)"
        cd "$TMP_DIR"
        curl -LO \
            https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
        mkdir font
        tar -xf JetBrainsMono.tar.xz -C font
        cp font/*.ttf "$FONT_DIR"
        rm -rf "$TMP_DIR"
    )

    fc-cache -fv
fi

echo "=== Installing Neovim ==="

if ! command -v nvim >/dev/null 2>&1; then
    (
        TMP_DIR="$(mktemp -d)"
        cd "$TMP_DIR"
        NVIM_VERSION="nvim-linux-x86_64"
        curl -LO "https://github.com/neovim/neovim/releases/latest/download/${NVIM_VERSION}.tar.gz"
        sudo rm -rf "/opt/${NVIM_VERSION}"
        sudo tar -C /opt -xzf "${NVIM_VERSION}.tar.gz"
        rm -rf "$TMP_DIR"
    )
fi

echo "=== Copying configs ==="

mkdir -p "$HOME/.config"

if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%Y%m%d%H%M%S)"
    echo "  Backup: ~/.zshrc -> ~/.zshrc.bak.$(date +%Y%m%d%H%M%S)"
fi
cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"

if [ -f "$HOME/.config/starship.toml" ]; then
    cp "$HOME/.config/starship.toml" "$HOME/.config/starship.toml.bak.$(date +%Y%m%d%H%M%S)"
    echo "  Backup: ~/.config/starship.toml -> ~/.config/starship.toml.bak.$(date +%Y%m%d%H%M%S)"
fi
cp "$SCRIPT_DIR/.config/starship.toml" "$HOME/.config/starship.toml"

echo "=== Setting Zsh as default shell ==="

if [ "$SHELL" != "$(command -v zsh)" ]; then
    chsh -s "$(command -v zsh)"
fi

echo "=== Applying GitHub Dark GNOME Terminal theme ==="

if command -v dconf >/dev/null 2>&1 && command -v gsettings >/dev/null 2>&1; then

PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")

if [ -n "$PROFILE_ID" ]; then

    BASE="/org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/"

    dconf write "${BASE}use-theme-colors" "false"
    dconf write "${BASE}use-system-font" "false"

    dconf write "${BASE}font" "'JetBrainsMono Nerd Font 10'"

    dconf write "${BASE}background-color" "'#0D1117'"
    dconf write "${BASE}foreground-color" "'#C9D1D9'"

    dconf write "${BASE}palette" "[
'#484F58',
'#FF7B72',
'#7EE787',
'#D29922',
'#58A6FF',
'#BC8CFF',
'#39C5CF',
'#B1BAC4',
'#6E7681',
'#FFA198',
'#56D364',
'#E3B341',
'#79C0FF',
'#D2A8FF',
'#56D4DD',
'#F0F6FC'
]"
fi

else
    echo "  Skipping GNOME Terminal theme (dconf/gsettings not found)"
fi

echo "=== Done! Restart your terminal or run 'zsh' ==="
