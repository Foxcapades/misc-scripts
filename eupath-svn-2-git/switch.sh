#!/bin/bash

function dirs() {
  out=$(find . -maxdepth 1 -type d \
    | sed 's/.\/\?//' \
    | grep .)
  echo $out
}

for i in `dirs`; do
  echo -e "\e[0m\n\e[39;1mEntering \e[32m$i\e[0;2m"
  cd $i
  
  repo=$(git remote show origin | grep Push | awk '{print $3}')

  if [[ "$repo" == *"-Infra"* ]]; then
    repo=$(echo $repo | sed 's/-Infra//')
    git remote rm origin
    git remote add origin $repo
    git push --all origin -fu
  else
    echo -e "\e[0;31mSkipping: \e[0;33mNot pointed at EuPathDB-Infra\e[0;2m"
  fi

  echo -e "\e[35mLeaving $i\n"
  cd ..
done
