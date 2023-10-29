#!/bin/bash

set -euo pipefail

function returns {
  if [[ "$(cat)" == "$1" ]]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

function contains {
  if [[ "$(cat)" == *"$1"* ]]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}
