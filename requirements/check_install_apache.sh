#! /bin/bash

function checkApache() {
  apacheVersion=$(apache2 --version 2>/dev/null)

  if [[ ! ${apacheVersion} ]]; then
    echo "Apache2 Not Install. Installing... "
    apt install apache2-bin
  else
    echo "Great! You are running: ${apacheVersion} ."
    return
  fi
  return
}