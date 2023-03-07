#! /bin/bash
function removeDataBase() {
  phpContainerName=${1}

  lxc exec ${phpContainerName} -- php /var/www/html/bin/console doctrine:database:drop --force
  return
}

function createFruitTestProject() {
  phpContainerName=${1}

  removeDataBase ${phpContainerName}

  lxc exec ${phpContainerName} -- git clone ${cloneFTTRepo} /var/www/html
  lxc exec ${phpContainerName} -- composer install -n --working-dir=/var/www/html

  #Conect Symfony To DB
  . ./temp/mysql.sh
  dbString="DATABASE_URL='${type}://${user}:${pass}@${host}:${port}/${database}?serverVersion=${version}&charset=utf8mb4'"

  lxc exec ${phpContainerName} -- sed -i '/DATABASE_URL=/d' /var/www/html/.env
  lxc exec ${phpContainerName} -- sed -i "/^###< doctrine\/doctrine-bundle ###.*/a ${dbString}" /var/www/html/.env
  lxc exec ${phpContainerName} -- php /var/www/html/bin/console doctrine:database:create
  lxc exec ${phpContainerName} -- php /var/www/html/bin/console doctrine:migrations:migrate

  updateFruitTestProject ${phpContainerName}
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
  echo "Git Update = clear cache composer update and code update"
  phpContainerName="$1"
  select yn in "recreate-project" "update" "exit"; do
    case $yn in
      recreate-project )
        recreateFruitTestProject ${phpContainerName}

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