#! /bin/bash

function createFruitTestProject() {
    select yn in "git update" "recreate" "skip"; do
      case $yn in
        git_update )
          return ;;
        recreate )
          return ;;
        skip )
          return
      esac
    done

  return
}