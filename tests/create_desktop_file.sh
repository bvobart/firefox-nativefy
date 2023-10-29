#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"
source test-utils.sh
source ../firefox-nativefy.sh

# Prevent the test from creating .desktop files in my actual home directory.
HOME="/tmp"

url="https://web.whatsapp.com/"
name="WhatsApp Desktop"
name_unspaced="WhatsAppDesktop"
icon="whatsapp"

create_desktop_file "$url" "$name" "$name_unspaced" "$icon"
destination_file="/tmp/.local/share/applications/WhatsApp Desktop.desktop"

cat "$destination_file" | contains "Name=$name"
cat "$destination_file" | contains "Comment=$name, nativefied from $url using firefox-nativefy.sh"
cat "$destination_file" | contains "--name $name_unspaced"
cat "$destination_file" | contains "--class $name_unspaced"
cat "$destination_file" | contains "-P \"$name_unspaced\""
cat "$destination_file" | contains "-url \"$url\""
cat "$destination_file" | contains "Icon=$icon"
cat "$destination_file" | contains "StartupWMClass=$name_unspaced"

rm -rf "$destination_file"
