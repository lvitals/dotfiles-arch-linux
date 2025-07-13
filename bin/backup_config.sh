#!/bin/sh

HOSTNAME=$(hostname)
DOTDIR=$(pwd)

echo "Iniciando backup do sistema Arch Linux para: $DOTDIR"

# Backups /etc
mkdir -p "$DOTDIR/etc/$HOSTNAME"
cp -v /etc/vconsole.conf "$DOTDIR/etc/$HOSTNAME/" 2>/dev/null || echo "vconsole.conf não encontrado"

# Backups /home
mkdir -p "$DOTDIR/home/"
cp -v "$HOME/.bashrc" "$DOTDIR/home/" 2>/dev/null || echo ".bashrc não encontrado"

# Backups ~/.config
CONFIGS="sway rofi foot fontconfig gtk-3.0 gtk-4.0"
mkdir -p "$DOTDIR/home/.config"
for DIR in $CONFIGS; do
  SRC="$HOME/.config/$DIR"
  if [ -d "$SRC" ]; then
    cp -rv "$SRC" "$DOTDIR/home/.config/"
  else
    echo "Diretório não encontrado: $SRC"
  fi
done

# Lista de pacotes instalados
mkdir -p "$DOTDIR/pkg/$HOSTNAME"
pacman -Qqe > "$DOTDIR/pkg/$HOSTNAME/pkglist.txt"

echo "Backup concluído com sucesso."

