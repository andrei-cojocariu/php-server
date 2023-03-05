#! /bin/bash
source params.env
. ./requirements/check_install_apache.sh

echo "Checking server requirements..."
if checkApache; then
  echo $ApacheMinVer;
fi