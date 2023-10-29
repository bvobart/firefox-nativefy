#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"
source test-utils.sh
source ../firefox-nativefy.sh

find_icon "WhatsApp Desktop" "" | returns "whatsapp"
find_icon "Telegram Desktop" "" | returns "telegram"
find_icon "Notion" "" | returns "notion-desktop"
find_icon "Example" "" | returns "firefox"

find_icon "WhatsApp Desktop" "custom" | returns "custom"
find_icon "WhatsApp Desktop" "/home/user/.local/share/icons/custom.png" | returns "/home/user/.local/share/icons/custom.png"
