#! /bin/bash
. ./src/project_setup/createTestProject.sh

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
  
  #install PHP8.3
  lxc exec ${phpContainerName} -- apt -y install software-properties-common
  lxc exec ${phpContainerName} -- add-apt-repository -y ppa:ondrej/php
  lxc exec ${phpContainerName} -- apt-get update
  lxc exec ${phpContainerName} -- apt -y install php8.3
  lxc exec ${phpContainerName} -- apt-get install -y php8.3-cli php8.3-common php8.3-mysql php8.3-zip php8.3-gd php8.3-mbstring php8.3-curl php8.3-xml php8.3-bcmath  php8.3-mbstring php8.3-xml
  lxc exec ${phpContainerName} -- apt-get install -y php-intl
  lxc exec ${phpContainerName} -- phpenmod mbstring

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
#  lxc exec ${phpContainerName} -- curl -sS 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' -o /tmp/symfony-setup.sh
#  lxc exec ${phpContainerName} -- bash /tmp/symfony-setup.sh
#  lxc exec ${phpContainerName} -- apt install symfony-cli

  #Update Document Root for Symfony public and Restart apache2 server
#  lxc exec ${phpContainerName} -- sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/public/g' /etc/apache2/sites-enabled/000-default.conf
#  lxc exec ${phpContainerName} -- sed -i '/^<\/VirtualHost>.*/i <Directory \/var\/www\/html> \n AllowOverride All \n <\/Directory>' /etc/apache2/sites-enabled/000-default.conf
#  lxc exec ${phpContainerName} -- a2enmod rewrite
#  lxc exec ${phpContainerName} -- service apache2 restart

  #Activate FTP Account
  lxc exec ${phpContainerName} -- apt-get install -y vsftpd
  lxc exec ${phpContainerName} -- sed -i 's/root/#root/g' /etc/ftpusers
  lxc exec ${phpContainerName} -- sed -i '/write_enable=YES/s/^#//g' /etc/vsftpd.conf
  lxc exec ${phpContainerName} -- systemctl restart vsftpd
  lxc file push installer/add_lxc_root_password.sh ${phpContainerName}/home/
  lxc exec ${phpContainerName} -- bash /home/add_lxc_root_password.sh

  ips=($(lxc exec ${phpContainerName} -- hostname -I))

  file="temp/php82.sh"
  if [[ ! -f $file ]]; then
    mkdir "temp/"
    cat /dev/null > ${file}
  fi

  cat > $file <<EOF
  #! /bin/bash

  ftp_host=${ips[0]}
  ftp_port=21
  ftp_user=ftp_user
  ftp_pass=ftp_pass
EOF

  echo "Creating Test Project;"
  createTestProject ${phpContainerName}

  return
}

function checkPHPContainer() {
    if ( lxc info ${phpContainerName} > /dev/null 2>&1 ); then
      echo -n "PHP Container: ${phpContainerName} exists! What do you wish to do with it: "
      echo

      select yn in "update-project" "recreate-container" "skip"; do
        case $yn in
          update-project)
              echo "Update Test Project;"
              updateTestProject ${phpContainerName}
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
