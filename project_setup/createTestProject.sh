#! /bin/bash
function removeDataBase() {
  phpContainerName=${1}

#  lxc exec ${phpContainerName} -- php /var/www/html/bin/console doctrine:database:drop --force
  return
}

function createTestProject() {
  phpContainerName=${1}

#  removeDataBase ${phpContainerName}

  lxc exec ${phpContainerName} -- rm -rf /var/www/html/ * -R

  lxc exec ${phpContainerName} -- git clone ${cloneFTTRepo} /var/www/html
  lxc exec ${phpContainerName} -- composer install -n --working-dir=/var/www/html

  #Conect Symfony To DB
  . ./temp/mysql.sh
#  dbString="DATABASE_URL='${type}://${user}:${pass}@${host}:${port}/${database}?serverVersion=${version}&charset=utf8mb4'"

#  lxc exec ${phpContainerName} -- sed -i '/DATABASE_URL=/d' /var/www/html/.env
#  lxc exec ${phpContainerName} -- sed -i "/^###< doctrine\/doctrine-bundle ###.*/a ${dbString}" /var/www/html/.env
#  lxc exec ${phpContainerName} -- php /var/www/html/bin/console doctrine:database:create
#  lxc exec ${phpContainerName} -- php /var/www/html/bin/console doctrine:migrations:migrate

  updateTestProject ${phpContainerName}
  return
}

function recreateTestProject() {
  phpContainerName=${1}

  createTestProject ${phpContainerName}

  return
}

function updateTestProject() {
  echo "Recreate Project = removes project files and resets it including mysql (git clone, composer install)"
  echo "Git Update = clear cache composer update and code update"
  phpContainerName="$1"
  select yn in "recreate-project" "update" "exit"; do
    case $yn in
      recreate-project )
        recreateTestProject ${phpContainerName}

        updateTestProject ${phpContainerName}
        ;;
      git-update )
        updateTestProject ${phpContainerName}
        ;;
      exit )
        exit
    esac
  done

  return
}
#
#ToDo Remove this:
#updateTestProject "FTT-PHP82"