#! /bin/bash
mysqlContainerName="FTT-DB"

function createMySQLContainer() {
  lxc launch ubuntu:20.04 ${mysqlContainerName}
  lxc exec ${mysqlContainerName} -- apt install mysql-server
  lxc exec ${mysqlContainerName} -- systemctl start mysql.service
  ips=($(lxc exec ${mysqlContainerName} -- hostname -I))
  echo "${ips[0]}"
}

function checkMySQLContainer() {
  if ( lxc info ${mysqlContainerName} > /dev/null 2>&1 ); then
    echo -n "MySQL Container: ${mysqlContainerName} exists! Do you wish to recreate: "
    echo

    select yn in "recreate" "cancel"; do
      case $yn in
        recreate )
          echo "Stopping ${mysqlContainerName};"
          lxc stop ${mysqlContainerName}
          lxc delete ${mysqlContainerName}

          echo "ReCreating MySQL ${mysqlContainerName};"
          createMySQLContainer
          return ;;
        cancel )
          return
      esac
    done
  fi

  echo "Creating MySQL ${mysqlContainerName};"
  createMySQLContainer

  return
}

checkMySQLContainer