#! /bin/bash
source params.env
. ./src/requirements/check_install_apache.sh

echo "Checking server requirements..."
if checkApache; then
  echo $ApacheMinVer;
fi