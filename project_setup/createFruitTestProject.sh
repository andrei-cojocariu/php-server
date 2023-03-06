#! /bin/bash

function createFruitTestProject() {
  echo ${phpContainerName}

  return
}

function updateFruitTestProject() {
  echo "Recreate Project = removes project files and resets it (git checkout, composer install)"
  echo "Full Update = redo database and code (git checkout, composer install etc)"
  echo "Git Update = clear cache and code update"
  echo ${phpContainerName}
  select yn in "recreate-project" "full-update" "git-update" "exit"; do
    case $yn in
      recreate-project )
        updateFruitTestProject
        ;;
      full-update )
        updateFruitTestProject
        ;;
      git-update )
        updateFruitTestProject
        ;;
      exit )
        exit
    esac
  done

  return
}