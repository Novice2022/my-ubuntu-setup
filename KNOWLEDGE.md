# Project: my-ubuntu-setup

## Карта проекта

- [инсталлятор] `install.sh` — основной скрипт: apt-пакеты, oh-my-zsh, плагины, zoxide, starship, шрифт, Neovim, копирование конфигов, GNOME Terminal тема
- [конфиг Zsh] `.zshrc` — oh-my-zsh с плагинами, алиасы (eza, batcat), starship, zsh-syntax-highlighting, fzf, opencode completions, настройки истории
- [конфиг Starship] `.config/starship.toml` — GitHub Dark промпт: OS, время, директория, git, nodejs, php, docker

## Архитектура

Репо — портативный инсталлятор для воспроизведения терминального окружения на Ubuntu. Не использует симлинки/stow/chezmoi — конфиги копируются напрямую `install.sh`. Перед копированием создаётся бэкап существующих файлов с таймстемпом.

## Команды

- `./install.sh` — полная установка (требуется `sudo`)

## Соглашения

- Конфиги (.zshrc, starship.toml) в репо — канонические. Правки в них → `install.sh` развернёт на целевой машине
- Секреты и машино-специфичные блоки (`.opencode/.env`) в репо не попадают
- `install.sh` использует временные директории для скачиваний, не мусорит в рабочей
- Не-GNOME окружения: блок темы GNOME Terminal пропускается без ошибки

## Зависимости

- Ubuntu
- `sudo`
- Доступ в интернет (curl, git clone, apt)
