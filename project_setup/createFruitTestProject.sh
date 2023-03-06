#! /bin/bash
source params.env

function createFruitTestProject() {
  phpContainerName=${1}

  lxc exec ${phpContainerName} -- git clone ${cloneFTTRepo} /var/www/html
  lxc exec ${phpContainerName} -- composer install -n --working-dir=/var/www/html

  return
}

function recreateFruitTestProject() {
  phpContainerName=${1}

  lxc exec ${phpContainerName} -- rm -rf /var/www/html/ * -R
  createFruitTestProject ${phpContainerName}

  return
}

function updateFruitTestProject() {
  echo "Recreate Project = removes project files and resets it including mysql (git clone, composer install)"
  echo "Full Update = redo database (repopulates) and code (git checkout, composer update etc)"
  echo "Git Update = clear cache and code update"
  phpContainerName="$1"
  select yn in "recreate-project" "full-update" "git-update" "exit"; do
    case $yn in
      recreate-project )
        recreateFruitTestProject ${phpContainerName}

        updateFruitTestProject ${phpContainerName}
        ;;
      full-update )
        updateFruitTestProject ${phpContainerName}
        ;;
      git-update )
        updateFruitTestProject ${phpContainerName}
        ;;
      exit )
        exit
    esac
  done

  return
}
#
#ToDo Remove this:
#updateFruitTestProject "FTT-PHP82"