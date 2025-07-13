#!/bin/sh

# Cores Catppuccin Mocha
mantle='#181825'
text='#cdd6f4'
mauve='#cba6f7'
surface0='#313244'
mod='Mod4'

# Lista de atalhos
shortcut_data_string="\
 Terminal;$mod+Enter
 Fechar janela;$mod+Shift+Q
 Menu de apps;$mod+D
 Alternar janelas;$mod+Tab
 Mostrar atalhos;$mod+F1
 Menu energia;$mod+Shift+E
 Sair da sessão;$mod+Shift+E
 Bloquear tela;$mod+L
 Mover foco;$mod+H/J/K/L
 Mover foco (setas);$mod+Left/Down/Up/Right
 Foco na saída dir.;$mod+Ctrl+Right
 Foco na saída esq.;$mod+Ctrl+Left
 Mover janela;$mod+Shift+H/J/K/L
 Mover janela (setas);$mod+Shift+Left/Down/Up/Right
 Redimensionar;$mod+R
 Split horizontal;$mod+B
 Split vertical;$mod+V
 Layouts (S/W/E);$mod+S/W/E
 Tela cheia;$mod+F
 Modo empilhado;$mod+S
 Modo tabulado;$mod+W
 Modo split;$mod+E
 Flutuante;$mod+Shift+Space
 Alternar layout;$mod+Space
 Trocar workspace;$mod+1..9
 Mover p/ workspace;$mod+Shift+1..9
 Próximo workspace;$mod+Ctrl+Right
 Anterior workspace;$mod+Ctrl+Left
 Alternar flutuante;$mod+Shift+Space
 Mover flutuante (mouse);$mod+LeftClick
 Redimensionar flut.;$mod+RightClick
 Print tela;Print
 Print seleção;Shift+Print
 Copiar seleção;Ctrl+Print
 Copiar tela inteira;Ctrl+Shift+Print
 Volume +/-;XF86AudioRaise/Lower
 Mudo;XF86AudioMute
 Play/Pause;XF86AudioPlay
 Parar;XF86AudioStop
 Anterior;XF86AudioPrev
 Próxima;XF86AudioNext
 Brilho +/-;XF86MonBrightnessUp/Down
 Recarregar config;$mod+Shift+C
 Reiniciar sway;$mod+Shift+R"

# Descobre o maior tamanho da primeira coluna (em caracteres)
maxlen=0
maxlen=$(
  _current_maxlen=0
  echo "$shortcut_data_string" | while IFS=';' read -r label key; do
    len=$(printf "%s" "$label" | wc -m)
    [ "$len" -gt "$_current_maxlen" ] && _current_maxlen=$len
  done
  echo "$_current_maxlen"
)

# Adiciona um espaçamento fixo entre as colunas.
fixed_gap_spaces=30 

# Gera a lista formatada
formatted_shortcuts=$(
  echo "$shortcut_data_string" | while IFS=';' read -r label key; do
    len=$(printf "%s" "$label" | wc -m)

    padding_length=$((maxlen - len + fixed_gap_spaces))

    padding=""
    i=0
    while [ "$i" -lt "$padding_length" ]; do
        padding="${padding} "
        i=$((i + 1))
    done

    echo "${label}${padding}<span foreground=\"$mauve\">${key}</span>"
  done
)

# Exibe no rofi
if [ -z "$formatted_shortcuts" ]; then
    notify-send -t 5000 "Shortcuts" "Nenhum atalho encontrado."
    exit 1
fi

printf "%s" "$formatted_shortcuts" | rofi -dmenu -p '󰍉' -i -markup-rows -theme-str "
window {
    width: 60%;
    height: 80%;
    background-color: $mantle;
    padding: 0px;
    border: 2px;
    border-color: $mauve;
    border-radius: 0px;
}
inputbar {
    enabled: true;
    spacing: 0px;
    padding: 0px;
}
prompt {
    text-color: $mauve;
}
listview {
    columns: 1;
    spacing: 5px;
    layout: vertical;
}
element {
    padding: 0px 0px;
    spacing: 0px;
}
element-text {
    font: 'JetBrainsMono Nerd Font Mono 12';
    text-color: $text;
}
element selected {
    background-color: $surface0;
    text-color: $mantle;
}
"