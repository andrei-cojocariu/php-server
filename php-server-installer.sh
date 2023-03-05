#! /bin/bash
source params.env
. ./src/requirements/check_install_apache.sh
. ./src/requirements/check_install_lxd.sh

echo "Checking server requirements..."
if checkApache; then
  if checkLXD-LXC; then
    echo "installing lxd"
  fi
fi