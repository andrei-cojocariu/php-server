#! /bin/bash
source params.env
. ./src/requirements/check_install_apache.sh
. ./src/requirements/check_install_lxd.sh
. ./src/container_setup/MySQLContainer.sh
. ./src/container_setup/PHP7-4Container.sh

echo "Checking server requirements..."
if checkApache; then
  if checkLXD-LXC; then
    checkMySQLContainer
    checkPHPContainer
  fi
fi