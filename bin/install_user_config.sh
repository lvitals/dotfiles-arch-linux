#!/bin/sh

set -e

# Define the script's base directory, going up one level to the repository root.
BASEDIR=$(cd "$(dirname "$0")/.." && pwd)

echo "👤 Installing user configurations"

# --- Restore .bashrc ---
if [ -f "$BASEDIR/home/.bashrc" ]; then
    echo "→ Copying .bashrc to $HOME/"
    cp -v "$BASEDIR/home/.bashrc" "$HOME/"
else
    echo "⚠️  .bashrc not found in $BASEDIR/home/"
fi

echo

# --- Restore directories in ~/.config ---
CONFIGS="sway foot rofi fontconfig gtk-3.0 gtk-4.0"

for DIR in $CONFIGS; do
    # Path to the source directory in the backup
    SRC="$BASEDIR/home/.config/$DIR"
    # Path to the final destination directory
    DEST="$HOME/.config/$DIR"

    if [ -d "$SRC" ]; then
        echo "→ Restoring configuration: $DIR"
        # Ensure the destination directory exists
        mkdir -p "$DEST"
        
        # This prevents creating a subdirectory with the same name inside the destination.
        cp -rv "$SRC/." "$DEST/"
    else
        echo "⚠️  Configuration not found: $SRC"
    fi
done

echo
echo "✅ User configurations restored successfully."