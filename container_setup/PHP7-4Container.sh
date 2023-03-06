#! /bin/bash
. ./src/project_setup/createFruitTestProject.sh

phpContainerName="FTT-PHP74"

function createPHPContainer() {
  lxc launch ubuntu:20.04 ${phpContainerName}

  # Temporarily add a known DNS (Google's DNS server)
  lxc exec ${phpContainerName} -- echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null
  lxc exec ${phpContainerName} -- apt-get update
  lxc exec ${phpContainerName} -- apt -y update && apt -y upgrade

  #Install Apache2 LTS
  lxc exec ${phpContainerName} -- apt -y install apache2

  #install PHP7.4
  lxc exec ${phpContainerName} -- apt -y install software-properties-common
  lxc exec ${phpContainerName} -- add-apt-repository -y ppa:ondrej/php
  lxc exec ${phpContainerName} -- apt-get update
  lxc exec ${phpContainerName} -- apt -y install php7.4
  lxc exec ${phpContainerName} -- apt-get install -y php7.4-cli php7.4-json php7.4-common php7.4-mysql php7.4-zip php7.4-gd php7.4-mbstring php7.4-curl php7.4-xml php7.4-bcmath php-xml

  #Install Curl
  lxc exec ${phpContainerName} -- apt -y install curl

  #install GIT
  lxc exec ${phpContainerName} -- apt -y install git
  lxc exec ${phpContainerName} -- git config --global user.name andrei-cojocariu
  lxc exec ${phpContainerName} -- git config --global user.email cojocariu.andrei@gmail.com

  #Install Composer
  lxc exec ${phpContainerName} -- apt -y install php-cli unzip
  lxc exec ${phpContainerName} -- curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
  lxc exec ${phpContainerName} -- php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

  #Install Symfony CLI
  lxc exec ${phpContainerName} -- curl -sS 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' -o /tmp/symfony-setup.sh
  lxc exec ${phpContainerName} -- bash /tmp/symfony-setup.sh
  lxc exec ${phpContainerName} -- apt install symfony-cli

  ips=($(lxc exec ${phpContainerName} -- hostname -I))

  file="temp/php74.tmp"
  if [[ ! -f $file ]]; then
    mkdir "temp/"
    cat /dev/null > ${file}
  fi

  cat > $file <<EOF
  php_host=${ips[0]}
  ftp_port=
  ftp_user=root
  ftp_pass=
EOF

  return
}

function checkPHPContainer() {
    if ( lxc info ${phpContainerName} > /dev/null 2>&1 ); then
      echo -n "PHP Container: ${phpContainerName} exists! What do you wish to do with it: "
      echo

      select yn in "update-project" "recreate-container" "skip"; do
        case $yn in
          update-project)
              echo "Update Fruit Test Project;"
              updateFruitTestProject ${phpContainerName}
              return
            ;;
          recreate-container )
            lxc stop ${phpContainerName}
            lxc delete ${phpContainerName}

            echo "ReCreating PHP Container ${phpContainerName};"
            createPHPContainer

            echo "Creating Fruit Test Project;"
            createFruitTestProject ${phpContainerName}
            return
            ;;
          skip )
            return
        esac
      done
    fi

    echo "Creating PHP Container ${phpContainerName};"
    createPHPContainer

    echo "Creating Fruit Test Project;"
    createFruitTestProject ${phpContainerName}

    return
}