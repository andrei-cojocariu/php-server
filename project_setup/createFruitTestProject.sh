#! /bin/bash

function updateFruitTestProject() {
    select yn in "full-update" "git-update" "recreate" "skip"; do
      case $yn in
        full-update )
          return ;;
        git-update )
          return ;;
        recreate )
          return ;;
        skip )
          return
      esac
    done

  return
}