#! /bin/bash

# Expected messages and errors that can be skipped
SKIPLIST='^([\s\t]|Found (merge|branch|possible)|Following|W: ([\-+]empty_dir|Refspec|Ignoring|Do not be alarmed)|expected path:|This may|Continuing|Initializing|Use of|Successfully)'

# Github org for the git mirrors
ORGANIZATION="EuPathDB"

HOME=$1
PROJECT=$2

shift 2

function filter() {
  local tmp=`join '|' "${SKIPLIST[@]}"`
  echo "grep -Pv '^(${tmp})'"
}

function gitsvn() {
  git svn clone https://cbilsvn.pmacs.upenn.edu/svn/${1:?}/${2:?} \
    --stdlayout \
    --authors-file=authors.txt
}

function showUsage() {
  echo "Usage:
  sco.sh <(gus|apidb)> <{project_name}>"
}

# Git checkout all the svn remote branches to prep them all for pushing to git
function prepBranches() {
  for i in `git branch --remotes | sed 's/origin\///;s/ //'`; do
    git checkout $i;
  done
}

# Perform any post-svn-checkout, pre-git-push cleanup steps
function cleanup() {
  git branch -D trunk
}

# Verify inputs
if [[ -z ${HOME} ]] || [[ -z ${PROJECT} ]]; then
 showUsage
 exit 1
fi;


# Perform the checkout
gitsvn $HOME $PROJECT 2>&1 | grep -Pv "${SKIPLIST}" \
  && cd $PROJECT \
  && prepBranches \
  && cleanup \
  && git push --all origin -fu \
  && cd ..

