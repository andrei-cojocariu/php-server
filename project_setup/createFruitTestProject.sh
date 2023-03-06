#! /bin/bash
cloneFTTRepo="https://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@github.com/andrei-cojocariu/fruit-test-project.git"

function recreateFruitTestProject()
{
  phpContainerName=${phpContainerName}

  lxc exec ${phpContainerName} -- rm -rf /var/www/html/ -R
  lxc exec ${phpContainerName} -- git clone $cloneFTTRepo /var/www/html

  return
}
function createFruitTestProject() {
  echo ${phpContainerName}

  return
}

function updateFruitTestProject() {
  echo "Recreate Project = removes project files and resets it including mysql (git checkout, composer install)"
  echo "Full Update = redo database (repopulates) and code (git checkout, composer update etc)"
  echo "Git Update = clear cache and code update"
  phpContainerName=${phpContainerName}
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
##ToDo Remove this:
#updateFruitTestProject "FTT-PHP74"