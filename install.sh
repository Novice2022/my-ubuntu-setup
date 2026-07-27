#!/usr/bin/env bash

set -Eeuo pipefail

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
    tmux \
    btop \
    jq \
    ipython3

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
    TMP_DIR="$(mktemp -d)"

    mkdir -p "$FONT_DIR"

    cd "$TMP_DIR"

    curl -LO \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz

    mkdir font

    tar -xf JetBrainsMono.tar.xz -C font

    cp font/*.ttf "$FONT_DIR"

    fc-cache -fv

    rm -rf "$TMP_DIR"
fi

echo "=== Generating Starship config ==="

mkdir -p "$HOME/.config"

cat > "$HOME/.config/starship.toml" <<'EOF'
"$schema" = 'https://starship.rs/config-schema.json'

add_newline = false

format = """
$os\
$time \
$directory\
$git_branch\
$git_status\
$nodejs\
$php\
$docker_context\
$cmd_duration\
$line_break\
$character
"""

[os]
disabled = false

[os.symbols]
Ubuntu = " "
Linux = " "

[time]
disabled = false
time_format = "%H:%M"
format = "[$time](#FF7B72) "

[directory]
style = "bold #58A6FF"
truncation_length = 3
read_only = " 󰌾"

[git_branch]
symbol = " "
style = "bold #D2A8FF"

[git_status]
style = "#E3B341"

[nodejs]
symbol = " "
style = "#7EE787"

[php]
symbol = " "
style = "#79C0FF"

[docker_context]
symbol = " "
style = "#58A6FF"

[cmd_duration]
min_time = 1000
style = "#E3B341"

[character]
success_symbol = "[❯](bold #7EE787)"
error_symbol = "[❯](bold #FF7B72)"
vimcmd_symbol = "[❮](bold #58A6FF)"

[aws]
disabled = true

[azure]
disabled = true

[gcloud]
disabled = true

[kubernetes]
disabled = true

[terraform]
disabled = true

[openstack]
disabled = true

[memory_usage]
disabled = true

[package]
disabled = true

[container]
disabled = true
EOF

echo "=== Generating .zshrc ==="

cat > "$HOME/.zshrc" <<'EOF'
export PATH="$HOME/.local/bin:$PATH"

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

plugins=(
    git
    zsh-autosuggestions
    zsh-completions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && \
source /usr/share/doc/fzf/examples/key-bindings.zsh

[ -f /usr/share/doc/fzf/examples/completion.zsh ] && \
source /usr/share/doc/fzf/examples/completion.zsh

alias ls='eza --icons'
alias ll='eza -la --icons'
alias tree='eza --tree --icons'

alias fd='fdfind'

alias bat='batcat'
alias cat='batcat'

typeset -A ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[command]='fg=#58A6FF'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#D2A8FF'
ZSH_HIGHLIGHT_STYLES[path]='fg=#7EE787'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#79C0FF'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF7B72'
EOF

echo "=== Setting Zsh as default shell ==="

if [ "$SHELL" != "$(command -v zsh)" ]; then
    chsh -s "$(command -v zsh)"
fi

echo "=== Applying GitHub Dark GNOME Terminal theme ==="

PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")

if [ -n "$PROFILE_ID" ]; then

    BASE="/org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/"

    dconf write "${BASE}use-theme-colors" "false"
    dconf write "${BASE}use-system-font" "false"

    dconf write "${BASE}font" "'JetBrainsMono Nerd Font 13'"

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
