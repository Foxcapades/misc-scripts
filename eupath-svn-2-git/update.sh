#! /bin/bash

debug=1

function dirs() {
  out=$(find . -maxdepth 1 -type d \
    | sed 's/.\/\?//' \
    | grep .)
  deb "Directories: $out"
  echo $out
}

function deb() {
  if [ ${debug:-0} -eq 1 ]; then
    >&2 echo $1
  fi
}

IN_ERROR_STATE=""
OUT_OF_SYNC=""

# Check for merge issues
function stat() {
  issues=`git status --short`
  if [ ! -z "$issues" ]; then
    if [ -z "$IN_ERROR_STATE" ]; then
      IN_ERROR_STATE="  $1"
    else
      IN_ERROR_STATE="$IN_ERROR_STATE
  $1"
    fi
  fi
}

for i in `dirs`; do
  echo -e "\e[0m\n\e[39;1mProcessing \e[32m$i\e[0;2m"

  cd $i
  branches=$(git svn fetch \
    | grep '^r' \
    | sed 's/r[0-9]\+ = [a-z0-9]\+ //;s/(\|)//g;s/refs\/remotes\/origin\///;s/trunk/master/' \
    | sort \
    | uniq)

  deb $branches

  if [ -z "$branches" ]; then
    stat $i
    deb "empty branches
returning to parent directory
continue"
    cd ..
    continue
  fi

  for j in $branches; do
    deb "checking out branch '$j'"
    git checkout $j

    deb "svn rebasing '$j'"
    git svn rebase 2>&1 |\
      grep -Pv '^([\s\t]|Found (merge|branch|possible)|Following|W: ([\-+]empty_dir|Refspec|Ignoring|Do not be alarmed)|expected path:|This may|Continuing|Initializing|Use of|Successfully)'
  done

  stat $i

  deb "returning to master branch"
  git checkout master

  deb "pushing all branches to git"
  git push --all origin -f

  deb "returning to parent directory"
  cd ..
done

if [ ! -z "$IN_ERROR_STATE" ]; then
  echo
  echo -e "\e[0m\n\e[39;1mMerge issues in:\e[0;2m\n"
  echo "$IN_ERROR_STATE"
fi

echo -e "\e[0m"
