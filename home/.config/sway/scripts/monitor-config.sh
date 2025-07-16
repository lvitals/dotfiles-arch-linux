#!/bin/bash

# Script to configure monitors in Sway with relative positioning
# Supports directions: right, left, top, bottom
# Automatically corrects negative coordinates to avoid swaymsg errors
# Supports global --position and per-monitor --relative

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --position <direction>   Sets the global relative position (right, left, top, bottom)"
    echo "  --monitor <name>         Adds a monitor (e.g., eDP-1, HDMI-A-1), can be repeated"
    echo "  --scale <value>          Sets the scale for the last added monitor (e.g., 1.2)"
    echo "  --relative <direction>   Sets the relative position (right, left, top, bottom) of the last monitor"
    echo "  --help                   Show this help message"
    exit 1
}

POSITION="right"
MONITOR_LIST=()
declare -A SCALES
declare -A RELATIVES

PARSED=$(getopt -o h --long monitor:,scale:,relative:,position:,help -n "$0" -- "$@")
if [ $? -ne 0 ]; then
    usage
fi

eval set -- "$PARSED"

CURRENT_MONITOR=""

while true; do
    case "$1" in
        --monitor)
            CURRENT_MONITOR="$2"
            MONITOR_LIST+=("$CURRENT_MONITOR")
            shift 2
            ;;
        --scale)
            if [ -z "$CURRENT_MONITOR" ]; then
                echo "Error: --scale must follow a --monitor"
                exit 1
            fi
            SCALES["$CURRENT_MONITOR"]="$2"
            shift 2
            ;;
        --relative)
            if [ -z "$CURRENT_MONITOR" ]; then
                echo "Error: --relative must follow a --monitor"
                exit 1
            fi
            RELATIVES["$CURRENT_MONITOR"]="$2"
            shift 2
            ;;
        --position)
            POSITION="$2"
            shift 2
            ;;
        --help)
            usage
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Invalid option: $1"
            usage
            ;;
    esac
done

# Default configuration if no monitor is specified
if [ ${#MONITOR_LIST[@]} -eq 0 ]; then
    MONITOR_LIST=("eDP-1" "HDMI-A-1")
    SCALES["eDP-1"]=1.2
    SCALES["HDMI-A-1"]=1.6
    RELATIVES["HDMI-A-1"]="right"
    echo "No monitors specified. Using default: eDP-1 (1.2), HDMI-A-1 (1.6)"
fi

declare -A RES_X RES_Y POS_X POS_Y LOGICAL_X LOGICAL_Y

# Gather resolutions of connected monitors
OUTPUTS=$(swaymsg -t get_outputs | jq -r '.[] | .name, .current_mode.width, .current_mode.height')
readarray -t OUTPUT_INFO <<< "$OUTPUTS"

for ((i = 0; i < ${#OUTPUT_INFO[@]}; i += 3)); do
    NAME=${OUTPUT_INFO[i]}
    WIDTH=${OUTPUT_INFO[i+1]}
    HEIGHT=${OUTPUT_INFO[i+2]}
    for MON in "${MONITOR_LIST[@]}"; do
        if [ "$MON" = "$NAME" ]; then
            RES_X["$NAME"]=$WIDTH
            RES_Y["$NAME"]=$HEIGHT
        fi
    done
done

# Check that all specified monitors are connected
for MON in "${MONITOR_LIST[@]}"; do
    if [ -z "${RES_X[$MON]}" ]; then
        echo "Error: Monitor $MON not found in swaymsg output."
        exit 1
    fi
done

# Compute relative positions and logical sizes
FIRST="${MONITOR_LIST[0]}"
POS_X["$FIRST"]=0
POS_Y["$FIRST"]=0
SCALE="${SCALES[$FIRST]:-1.0}"
LOGICAL_X["$FIRST"]=$(bc -l <<< "${RES_X[$FIRST]} / $SCALE" | awk '{printf "%.0f", $1}')
LOGICAL_Y["$FIRST"]=$(bc -l <<< "${RES_Y[$FIRST]} / $SCALE" | awk '{printf "%.0f", $1}')

PREV="$FIRST"

for ((i = 1; i < ${#MONITOR_LIST[@]}; i++)); do
    MON="${MONITOR_LIST[i]}"
    SCALE="${SCALES[$MON]:-1.0}"
    RELATIVE="${RELATIVES[$MON]:-$POSITION}"
    LOGICAL_X["$MON"]=$(bc -l <<< "${RES_X[$MON]} / $SCALE" | awk '{printf "%.0f", $1}')
    LOGICAL_Y["$MON"]=$(bc -l <<< "${RES_Y[$MON]} / $SCALE" | awk '{printf "%.0f", $1}')

    case "$RELATIVE" in
        right)
            POS_X["$MON"]=$((POS_X[$PREV] + LOGICAL_X[$PREV]))
            POS_Y["$MON"]=${POS_Y[$PREV]}
            ;;
        left)
            POS_X["$MON"]=$((POS_X[$PREV] - LOGICAL_X[$MON]))
            POS_Y["$MON"]=${POS_Y[$PREV]}
            ;;
        top)
            POS_X["$MON"]=${POS_X[$PREV]}
            POS_Y["$MON"]=$((POS_Y[$PREV] - LOGICAL_Y[$MON]))
            ;;
        bottom)
            POS_X["$MON"]=${POS_X[$PREV]}
            POS_Y["$MON"]=$((POS_Y[$PREV] + LOGICAL_Y[$PREV]))
            ;;
        *)
            echo "Error: Invalid relative position for $MON. Use: right, left, top, bottom"
            exit 1
            ;;
    esac

    PREV="$MON"
done

# Adjust to avoid negative coordinates
MIN_X=0
MIN_Y=0
for MON in "${MONITOR_LIST[@]}"; do
    (( POS_X[$MON] < MIN_X )) && MIN_X=${POS_X[$MON]}
    (( POS_Y[$MON] < MIN_Y )) && MIN_Y=${POS_Y[$MON]}
done

# Apply configurations
for i in "${!MONITOR_LIST[@]}"; do
    MON="${MONITOR_LIST[i]}"
    POS_X[$MON]=$((POS_X[$MON] - MIN_X))
    POS_Y[$MON]=$((POS_Y[$MON] - MIN_Y))
    SCALE="${SCALES[$MON]:-1.0}"

    swaymsg output "$MON" pos ${POS_X[$MON]} ${POS_Y[$MON]} scale "$SCALE"
    echo "Applied configuration: $MON -> pos ${POS_X[$MON]} ${POS_Y[$MON]}, scale $SCALE"

    # Move workspace
    WORKSPACE=$((i + 1))
    swaymsg -- "workspace $WORKSPACE output $MON"
done
