#! /bin/bash

function createFruitTestProject() {
  echo "doing something"

  return
}

function updateFruitTestProject() {
  echo "Full Update = redo database and code (git checkout, composer install etc)"
  echo "Git Update = clear cache and code update"
  echo "Recreate = removes project files and resets is (git checkout, composer install)"

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