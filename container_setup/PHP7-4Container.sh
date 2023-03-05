#! /bin/bash
phpContainerName="FTT-PHP74"

function createPHPContainer() {
  lxc launch ubuntu:20.04 ${phpContainerName}

  lxc exec ${phpContainerName} -- apt install apache2

}

function checkPHPContainer() {
    if ( lxc info ${phpContainerName} > /dev/null 2>&1 ); then
      echo -n "PHP Container: ${phpContainerName} exists! What do you wish to do with it: "
      echo

      select yn in "update" "recreate" "skip"; do
        case $yn in
          update )
            return ;;
          recreate )
            lxc stop ${phpContainerName}
            lxc delete ${phpContainerName}

            echo "ReCreating PHP Container ${phpContainerName};"
            createPHPContainer
            return ;;
          skip )
            return
        esac
      done
    fi

    echo "Creating PHP Container ${phpContainerName};"
    createPHPContainer
}

checkPHPContainer