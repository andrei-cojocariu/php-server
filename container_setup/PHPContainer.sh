#! /bin/bash
. ./src/project_setup/createFruitTestProject.sh

phpContainerName="FTT-PHP82"

function createPHPContainer() {
  lxc launch ubuntu:20.04 ${phpContainerName}

  # Temporarily add a known DNS (Google's DNS server)
  lxc exec ${phpContainerName} -- echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null
  lxc exec ${phpContainerName} -- apt-get update
  lxc exec ${phpContainerName} -- apt -y update && apt -y upgrade

  #Install Apache2 LTS
  lxc exec ${phpContainerName} -- apt -y install apache2
  lxc exec ${phpContainerName} -- rm -rf /var/www/html/ * -R

  #install PHP8.2
  lxc exec ${phpContainerName} -- apt -y install software-properties-common
  lxc exec ${phpContainerName} -- add-apt-repository -y ppa:ondrej/php
  lxc exec ${phpContainerName} -- apt-get update
  lxc exec ${phpContainerName} -- apt -y install php8.2
  lxc exec ${phpContainerName} -- apt-get install -y php8.2-cli php8.2-common php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath

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

  #Update Document Root for Symfony public and Restart apache2 server
  lxc exec ${phpContainerName} -- sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/public/g' /etc/apache2/sites-enabled/000-default.conf
  lxc exec ${phpContainerName} -- service apache2 restart

  file="temp/php82.tmp"
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

  echo "Creating Fruit Test Project;"
  createFruitTestProject ${phpContainerName}

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

            return
            ;;
          skip )
            return
        esac
      done
    fi

    echo "Creating PHP Container ${phpContainerName};"
    createPHPContainer

    return
}