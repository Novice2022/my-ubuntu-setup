# my-ubuntu-setup

Портативный инсталлятор терминального окружения для Ubuntu.

## Что делает

Запусти `./install.sh` — и получишь идентично настроенный терминал со всем необходимым для web-разработки.

## Что устанавливает

| Категория | Компоненты |
|-----------|------------|
| Базовые утилиты | `zsh`, `fzf`, `bat`/`batcat`, `eza`, `fd-find`, `ripgrep`, `btop`, `jq` |
| Рекомендованные | `gh`, `yq`, `jc`, `ripgrep-all` |
| Shell | oh-my-zsh + плагины (git, docker, node, laravel, zoxide, autosuggestions, completions, syntax-highlighting) |
| Prompt | Starship (GitHub Dark тема) |
| Навигация | zoxide |
| Редактор | Neovim (latest, в `/opt/nvim-linux-x86_64`) |
| Шрифт | JetBrains Mono Nerd Font |

## Запуск

```bash
git clone https://github.com/izabrodin/my-ubuntu-setup.git
cd my-ubuntu-setup
./install.sh
```

Требования: Ubuntu, `sudo`.

## Структура

```
.
├── install.sh              # основной инсталлятор
├── .zshrc                 # конфиг Zsh (копируется в ~/.zshrc)
└── .config/starship.toml  # конфиг Starship (копируется в ~/.config/)
```
