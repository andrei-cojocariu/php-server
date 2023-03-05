#! /bin/bash
mysqlContainerName="FTT-DB"

function createMySQLContainer() {
  lxc launch ubuntu:20.04 ${mysqlContainerName}

  lxc exec ${mysqlContainerName} -- apt install mysql-server
  lxc exec FTT-DB -- sed -i '/bind-address/,/bind-address/ s/^/#/' /etc/mysql/mysql.conf.d/mysqld.cnf
  lxc exec ${mysqlContainerName} -- mysql -e "CREATE USER 'root'@'%' IDENTIFIED BY ''; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'; FLUSH PRIVILEGES;"
  lxc exec ${mysqlContainerName} -- systemctl restart mysql.service

  ips=($(lxc exec ${mysqlContainerName} -- hostname -I))

  file="src/temp/mysql.tmp"
  if [[ ! -f $file ]]; then
    mkdir "src/temp/"
    cat /dev/null > ${file}
  fi

  cat >> $file <<EOF
  mysql_host=${ips[0]}
  mysql_port=3306
  mysql_user=root
  mysql_pass=
EOF

  return
}

function checkMySQLContainer() {
  if ( lxc info ${mysqlContainerName} > /dev/null 2>&1 ); then
    echo -n "MySQL Container: ${mysqlContainerName} exists! Do you wish to recreate: "
    echo

    select yn in "recreate" "skip"; do
      case $yn in
        recreate )
          lxc stop ${mysqlContainerName}
          lxc delete ${mysqlContainerName}

          echo "ReCreating MySQL Container ${mysqlContainerName};"
          createMySQLContainer
          return ;;
        skip )
          return
      esac
    done
  fi

  echo "Creating MySQL Container ${mysqlContainerName};"
  createMySQLContainer

  return
}