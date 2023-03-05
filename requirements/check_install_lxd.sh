#! /bin/bash

function checkLXD-LXC() {
  lxdVersion=$(lxd --version 2>/dev/null)

  if [[ ${lxdVersion} ]]; then
    echo "Great! You are running LXD/LXC:"
    echo "${lxdVersion}"
  else
      command -v lxd >/dev/null 2>&1 ||
    {
      echo >&2 "LXD/LXC Containers are not installed. Installing..."
      apt install lxd
    }
  fi
  return
}