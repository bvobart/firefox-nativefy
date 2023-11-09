#!/bin/bash

set -euo pipefail

script_dir="$(dirname "$0")"
cd "$script_dir"

# Requirements for this function to work correctly:
# - web-ext must be installed
# - WEB_EXT_API_KEY is set to the JWT issuer
# - WEB_EXT_API_SECRET is set to the JWT secret
# JWT issuer and secret can be found on Mozilla Addons Developer Hub:
# https://addons.mozilla.org/en-GB/developers/addon/api/key/
function build_open_in_default_browser() {
  cd open-in-default-browser
  web-ext build --overwrite-dest
  web-ext sign

  mv ./*.xpi open-in-default-browser.xpi
}

build_open_in_default_browser
