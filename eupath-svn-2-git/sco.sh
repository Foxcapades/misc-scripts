#! /bin/bash

# Expected messages and errors that can be skipped
SKIPLIST='^([\s\t]|Found (merge|branch|possible)|Following|W: ([\-+]empty_dir|Refspec|Ignoring|Do not be alarmed)|expected path:|This may|Continuing|Initializing|Use of|Successfully)'

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


# Verify inputs
if [[ -z ${HOME} ]] || [[ -z ${PROJECT} ]]; then
 showUsage
 exit 1
fi;

gitsvn $HOME $PROJECT 2>&1 |\
  grep -Pv "${SKIPLIST}"
