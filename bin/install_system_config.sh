#!/bin/sh

set -e

BASEDIR=$(cd "$(dirname "$0")/.." && pwd)
HOSTNAME=$(uname -n)

echo "🔧 Instalando configurações de sistema para host: $HOSTNAME"

# Restaurar /etc/vconsole.conf
VCFILE="$BASEDIR/etc/$HOSTNAME/vconsole.conf"
if [ -f "$VCFILE" ]; then
    echo "→ Copiando $VCFILE para /etc/vconsole.conf"
    sudo cp -v "$VCFILE" /etc/vconsole.conf
else
    echo "⚠️  Arquivo etc/$HOSTNAME/vconsole.conf não encontrado."
fi

# Restaurar lista de pacotes
PKGLIST="$BASEDIR/pkg/$HOSTNAME/pkglist.txt"
if [ -f "$PKGLIST" ]; then
    echo "📦 Instalando pacotes com pacman..."
    sudo pacman -Syu --needed - < "$PKGLIST"
else
    echo "⚠️  Lista de pacotes não encontrada em $PKGLIST"
fi

echo "✅ Configurações de sistema restauradas."
