#!/bin/bash

set -euo pipefail

version="0.2.2"

script_path="$(dirname "$0")"

# Default names for nativefied web applications by URL hostname
declare -A known_names=(
  ["web.whatsapp.com"]="WhatsApp Desktop"
  ["web.telegram.org"]="Telegram Desktop"
  ["notion.so"]="Notion"
  ["soundcloud.com"]="SoundCloud"
)

# Default icons for nativefied web applications by URL hostname
declare -A known_icons=(
  ["web.whatsapp.com"]="whatsapp"
  ["web.telegram.org"]="telegram"
  ["notion.so"]="notion-app"
  ["soundcloud.com"]="soundcloud"
)

function print_help() {
  echo "firefox-nativefy.sh v$version"
  echo "source: https://github.com/bvobart/firefox-nativefy"
  echo
  echo "Turn a website into a \"native\" application using Firefox."
  echo
  echo "Usage: firefox-nativefy.sh <url> [--name <name>] [--icon <icon>]"
  echo "Where:"
  echo "  - <url> is the URL of the website to nativefy"
  echo "  - --name [name] is the name of the app (optional, can be inferred from URL in some cases, defaults to website hostname)"
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

  if [ -n "${known_names[$hostname]+is_defined}" ]; then
    echo "${known_names[$hostname]}"
    return
  fi

  echo "$hostname"
}

#--------------------------------------------------------------------------------------------------

function find_icon() {
  local url="$1"
  local icon="$2"

  if [ -n "$icon" ]; then
    echo "$icon"
    return
  fi

  if [ -n "${known_icons[$url]+is_defined}" ]; then
    echo "${known_icons[$url]}"
    return
  fi

  echo "firefox"
}

#--------------------------------------------------------------------------------------------------

function install_open_in_default_browser_extension() {
  local profile_path="$1"
  local firefox_extensions_path="$profile_path/extensions"
  local extensions_dir="$script_path/extensions"

  python3 "$extensions_dir/open-in-default-browser/native/open_default_browser.py" install

  mkdir -p "$firefox_extensions_path"
  cp "$extensions_dir/open-in-default-browser@example.org.xpi" "$firefox_extensions_path"

  echo "Installed Firefox extension to open external links in default browser"
}

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
EOF

  # Install extension to open external links in default browser
  install_open_in_default_browser_extension "$profile_path"
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
  local url
  local name
  local name_unspaced
  local icon

  url="${1:-}"
  if [ -z "$url" ] || [ "$url" == "--help" ] || [ "$url" == "-h" ] || [ "$url" == "help" ]; then
    print_help
    exit 1
  fi
  shift

  while [ $# -gt 0 ]; do
    case "$1" in
      --name)
        name="$(find_name "$url" "${2:-}")"
        name_unspaced="$(echo "$name" | sed 's/ //g')"
        shift
        ;;
    esac

    case "$1" in
      --icon)
        icon="$(find_icon "$url" "${2:-}")"
        shift
        ;;
    esac

    shift
  done

  if [ -z "${name:-}" ]; then
    name="$(find_name "$url" "")"
    name_unspaced="$(echo "$name" | sed 's/ //g')"
  fi
  if [ -z "${icon:-}" ]; then
    icon="$(find_icon "$url" "")"
  fi

  echo "> Nativefying $url as $name with icon $icon"
  echo
  
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

  echo "> Setting up Firefox profile..."
  setup_firefox_profile "$name_unspaced"
  echo "> Creating desktop file..."
  create_desktop_file "$url" "$name" "$name_unspaced" "$icon"
  echo
  echo "> Done!"
}

#--------------------------------------------------------------------------------------------------

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
