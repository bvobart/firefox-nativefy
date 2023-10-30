#!/bin/bash

set -euo pipefail
# cd "$(dirname "$0")"

version="0.1.0"

function print_help() {
  echo "firefox-nativefy.sh v$version"
  echo "source: https://github.com/bvobart/firefox-nativefy"
  echo
  echo "Turn a website into a \"native\" application using Firefox."
  echo
  echo "Usage: firefox-nativefy.sh <url> [name] [--icon <icon>]"
  echo "Where:"
  echo "  - <url> is the URL of the website to nativefy"
  echo "  - [name] is the name of the app (optional, can be inferred from URL in some cases, defaults to website hostname)"
  echo "  - --icon <icon> is the icon to use (optional, can be inferred from name in some cases, defaults to Firefox icon). Can be an icon name, e.g. firefox, or an absolute path, e.g. /home/user/.local/share/icons/custom.png"
  echo
  echo "Example: firefox-nativefy.sh https://web.whatsapp.com/ \"WhatsApp Desktop\""
}

#--------------------------------------------------------------------------------------------------

function parse_hostname() {
  echo "$1" | sed -e 's/[^/]*\/\/\([^@]*@\)\?\([^:/]*\).*/\2/' -e 's/^www\.//'
}

function find_name() {
  local url="$1"
  local name="$2"

  if [ -n "$name" ]; then
    echo "$name"
    return
  fi

  # strip https:// and www. and path from URL
  local hostname="$(parse_hostname "$url")"

  declare -A known_names=(
    ["web.whatsapp.com"]="WhatsApp Desktop"
    ["web.telegram.org"]="Telegram Desktop"
    ["notion.so"]="Notion"
  )

  if [ -n "${known_names[$hostname]+is_defined}" ]; then
    echo "${known_names[$hostname]}"
    return
  fi

  echo "$hostname"
}

#--------------------------------------------------------------------------------------------------

function find_icon() {
  local name="$1"
  local icon="$2"

  if [ -n "$icon" ]; then
    echo "$icon"
    return
  fi

  declare -A known_icons=(
    ["WhatsApp Desktop"]="whatsapp"
    ["Telegram Desktop"]="telegram"
    ["Notion"]="notion-desktop"
  )

  if [ -n "${known_icons[$name]+is_defined}" ]; then
    echo "${known_icons[$name]}"
    return
  fi

  echo "firefox"
}

#--------------------------------------------------------------------------------------------------

function setup_firefox_profile() {
  local name="$1"

  # Create custom Firefox profile for this app
  firefox -CreateProfile "$name"

  local profile_rel_path=$(awk "/Name=$name/{f=1} f && /Path=.*/ {print; exit}" "$HOME/.mozilla/firefox/profiles.ini" | sed 's/Path=//')
  local profile_path="$HOME/.mozilla/firefox/$profile_rel_path"

  touch "$profile_path/user.js"

  # Enable userChrome.css UI customizations
  echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$profile_path/user.js"
  # Enable desktop notifications by default
  echo 'user_pref("permissions.default.desktop-notification", 1);' >> "$profile_path/user.js"

  # Hide Firefox UI
  mkdir -p "$profile_path/chrome"
  touch "$profile_path/chrome/userChrome.css"
  cat >> "$profile_path/chrome/userChrome.css" <<EOF
@namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");
#TabsToolbar {visibility: collapse;}
#navigator-toolbox {visibility: collapse;}
browser {margin-right: -14px; margin-bottom: -14px;}
EOF
}

#--------------------------------------------------------------------------------------------------

function create_desktop_file() {
  local url="$1"
  local name="$2"
  local name_unspaced="$3"
  local icon="$4"
  local desktop="$HOME/.local/share/applications/$name_unspaced.desktop"

  # Create desktop file
  mkdir -p "$(dirname "$desktop")"
  cat > "$desktop" <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=$name
Comment=$name, nativefied from $url using firefox-nativefy.sh
# Both --name and --class are required for both Wayland and X11 to think that this is its own app, rather than being grouped with Firefox.
Exec=$(which firefox) --name "$name_unspaced" --class "$name_unspaced" --new-instance -P "$name_unspaced" -url "$url"
Icon=$icon
Categories=Network
Terminal=false
# StartupWMClass links the desktop file to the window, so that the window manager knows which app the window belongs to.
StartupWMClass=$name_unspaced
EOF
}

#--------------------------------------------------------------------------------------------------

# Main function
function main() {
  local url="${1:-}"
  local name="$(find_name "$url" "${2:-}")"
  local name_unspaced="$(echo "$name" | sed 's/ //g')"
  # remove url and name from arguments, if given.
  [ $# -gt 0 ] && shift;
  [ $# -gt 0 ] && shift;

  local icon
  while [ $# -gt 0 ]; do
    case "$1" in
      --icon)
        icon="$(find_icon "$name" "${2:-}")"
        shift
        ;;
    esac
    shift
  done

  if [ -z "$url" ] || [ "$url" == "--help" ] || [ "$url" == "-h" ] || [ "$url" == "help" ]; then
    print_help
    exit 1
  fi

  if [ -z "${icon:-}" ]; then
    icon="$(find_icon "$name" "")"
  fi

  local desktop="$HOME/.local/share/applications/$name.desktop"
  if [ -f "$desktop" ]; then
    echo "Error: application desktop file already exists: $desktop"
    echo "> Overwrite? (y/n)"
    read -r overwrite
    if [ "$overwrite" != "y" ]; then
      exit 1
    fi
    echo
  fi

  echo "> Nativefying $url as $name"
  echo
  echo "> Setting up Firefox profile..."
  setup_firefox_profile "$name_unspaced"
  echo "> Creating desktop file..."
  create_desktop_file "$url" "$name" "$name_unspaced" "$icon"
  echo "> Done!"
}

#--------------------------------------------------------------------------------------------------

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
