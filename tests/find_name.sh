#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"
source test-utils.sh
source ../firefox-nativefy.sh

parse_hostname "https://web.whatsapp.com/" | returns "web.whatsapp.com"
parse_hostname "https://cv.bart.vanoort.is" | returns "cv.bart.vanoort.is"
parse_hostname "example.co.uk" | returns "example.co.uk"
parse_hostname "https://www.example.co.uk" | returns "example.co.uk"
parse_hostname "https://www.example.co.uk:8080" | returns "example.co.uk"
parse_hostname "https://example.co.uk:8080/" | returns "example.co.uk"

find_name "https://web.whatsapp.com/" "WhatsApp Desktop" | returns "WhatsApp Desktop"
find_name "https://web.whatsapp.com/" "WhatsApp" | returns "WhatsApp"
find_name "https://example.co.uk" "Example" | returns "Example"

find_name "https://web.whatsapp.com/" "" | returns "WhatsApp Desktop"
find_name "https://web.telegram.org/" "" | returns "Telegram Desktop"
find_name "https://notion.so/" "" | returns "Notion"

find_name "https://example.co.uk" "" | returns "example.co.uk"
