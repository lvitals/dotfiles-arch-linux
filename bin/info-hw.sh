#!/bin/sh

HOSTNAME=$(hostname)
DOTDIR=$(pwd)
OUTPUT_DIR="$DOTDIR/info"
OUTPUT_FILE="$OUTPUT_DIR/info-hw-$HOSTNAME.txt"
TMP_FILE="$OUTPUT_DIR/info-hw-$HOSTNAME.tmp"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "🔍 Generating hardware report for $HOSTNAME..."
printf "Hardware Report - %s\n" "$HOSTNAME" > "$TMP_FILE"
printf "Generated on: %s\n" "$(date)" >> "$TMP_FILE"
printf -- "------------------------------------------\n\n" >> "$TMP_FILE"

# Hostname (masked)
printf "[ Hostname ]\n" >> "$TMP_FILE"
printf "HOSTNAME_REDACTED\n\n" >> "$TMP_FILE"

# System info
printf "[ System Information ]\n" >> "$TMP_FILE"
uname -a >> "$TMP_FILE"
printf "\n" >> "$TMP_FILE"

# CPU info
printf "[ CPU ]\n" >> "$TMP_FILE"
lscpu >> "$TMP_FILE"
printf "\n" >> "$TMP_FILE"

# Memory
printf "[ Memory ]\n" >> "$TMP_FILE"
free -h >> "$TMP_FILE"
printf "\n" >> "$TMP_FILE"

# Disks
printf "[ Disks ]\n" >> "$TMP_FILE"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT >> "$TMP_FILE"
printf "\n" >> "$TMP_FILE"

# Filesystems
printf "[ Filesystems ]\n" >> "$TMP_FILE"
df -hT >> "$TMP_FILE"
printf "\n" >> "$TMP_FILE"

# Network interfaces
printf "[ Network Interfaces ]\n" >> "$TMP_FILE"
ip addr >> "$TMP_FILE"
printf "\n" >> "$TMP_FILE"

# PCI devices
printf "[ PCI Devices ]\n" >> "$TMP_FILE"
lspci -nn >> "$TMP_FILE"
printf "\n" >> "$TMP_FILE"

# USB devices
printf "[ USB Devices ]\n" >> "$TMP_FILE"
lsusb >> "$TMP_FILE"
printf "\n" >> "$TMP_FILE"

# Loaded kernel modules
printf "[ Kernel Modules ]\n" >> "$TMP_FILE"
lsmod >> "$TMP_FILE"
printf "\n" >> "$TMP_FILE"

# Mask sensitive data (MACs, IPs, SSIDs, hostname)
sed -E \
    -e 's/ether ([0-9a-f]{2}(:[0-9a-f]{2}){5})/ether XX:XX:XX:XX:XX:XX/gI' \
    -e 's/(inet )([0-9]{1,3}(\.[0-9]{1,3}){3})/\1XXX.XXX.XXX.XXX/g' \
    -e 's/(inet6 )([0-9a-f:]+)/\1XXX:XXX:XXX:XXX:XXX/g' \
    -e 's/(ssid )[^ ]+/\1SSID_REDACTED/gI' \
    -e "s/$HOSTNAME/HOSTNAME_REDACTED/g" \
    "$TMP_FILE" > "$OUTPUT_FILE"

rm "$TMP_FILE"

printf "✅ Report saved to: %s\n" "$OUTPUT_FILE"
