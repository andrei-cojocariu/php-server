#! /bin/bash

function checkApache() {
  apacheFullVersion=$(apache2 -v 2>/dev/null)

  if [[ ${apacheFullVersion} ]]; then
    echo "Great! You are running:"
    echo "${apacheFullVersion}"
  else
      command -v apache2 >/dev/null 2>&1 ||
    {
      echo >&2 "Apache2 is not installed. Installing..."
      apt install apache2
    }
  fi

  return
}