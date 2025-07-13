#!/bin/sh

set -e

BASEDIR=$(cd "$(dirname "$0")/.." && pwd)

echo "👤 Instalando configurações do usuário"

# Restaurar .bashrc
if [ -f "$BASEDIR/home/.bashrc" ]; then
    echo "→ Copiando .bashrc para $HOME/"
    cp -v "$BASEDIR/home/.bashrc" "$HOME/"
else
    echo "⚠️  .bashrc não encontrado em $BASEDIR/home/"
fi

# Restaurar ~/.config diretórios
CONFIGS="sway foot rofi fontconfig gtk-3.0 gtk-4.0"
for DIR in $CONFIGS; do
    SRC="$BASEDIR/home/.config/$DIR"
    DEST="$HOME/.config/$DIR"
    if [ -d "$SRC" ]; then
        echo "→ Restaurando configuração: $DIR"
        mkdir -p "$DEST"
        cp -rv "$SRC/" "$DEST/"
    else
        echo "⚠️  Configuração não encontrada: $SRC"
    fi
done

echo "✅ Configurações do usuário restauradas."
