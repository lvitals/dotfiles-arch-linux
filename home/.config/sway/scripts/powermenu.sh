#!/bin/sh

# Cores do Catppuccin Mocha
base='#1e1e2e'
mantle='#181825'
text='#cdd6f4'
surface1='#45475a'
mauve='#cba6f7'

# Opções com ícones coloridos usando Pango
opcoes="<span color='#f38ba8'></span>   Desligar\n<span color='#f9e2af'></span>   Reiniciar\n<span color='#89b4fa'></span>   Suspender\n<span color='#a6e3a1'></span>   Sair do Sway"

selecionado=$(echo -e "$opcoes" | rofi -dmenu -p "" \
    -markup-rows \
    -theme-str "window {
        background-color: $mantle;
        border: 2px;
        border-color: $mauve;
        width: 300px;
        padding: 0px;
    }" \
    -theme-str "listview {
        lines: 4;
        columns: 1;
        spacing: 5px;
        margin: 0px;
        padding: 0px;
    }" \
    -theme-str "element {
        padding: 0px;
        text-color: $text;
    }" \
    -theme-str "element-text {
        font: 'JetBrainsMono Nerd Font 12';
        text-color: inherit;
        vertical-align: 0.5;
        markup: true;
    }" \
    -theme-str "element selected {
        background-color: $surface1;
        text-color: $mauve;
    }" \
    -theme-str "inputbar {
        enabled: false;
    }")

# Ações com base na opção selecionada
case "$selecionado" in
    *Desligar*)
        shutdown -p now
        ;;
    *Reiniciar*)
        shutdown -r now
        ;;
    *Suspender*)
        acpiconf -s 3
        ;;
    *Sair*)
        swaymsg exit
        ;;
esac
