#! /bin/bash

function createFruitTestProject() {
  echo "doing something"

  return
}

function updateFruitTestProject() {
  echo "Recreate Project = removes project files and resets it (git checkout, composer install)"
  echo "Full Update = redo database and code (git checkout, composer install etc)"
  echo "Git Update = clear cache and code update"

  select yn in "recreate-project" "full-update" "git-update" "exit"; do
    case $yn in
      recreate-project )
        return ;;
      full-update )
        return ;;
      git-update )
        return ;;
      exit )
        return
    esac
  done

  return
}