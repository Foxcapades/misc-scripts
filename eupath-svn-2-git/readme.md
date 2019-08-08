# Subversion to Git migration helpers

utils and wrappers to simplify my life while manually creating maintaining a one way sync between the EuPathDB SVN projects and git mirrors of those projects.

## Scripts

`sco.sh`: git svn checkout
`update.sh`: git svn rebase
`switch.sh`: helper to change the owner of the git repos from "EuPathDB-Infra" to "EuPathDB"

## Other stuff

Prep a repo for pushing to git. Prerequisites:

1. checked out with git svn
2. git remote added

```sh
git branch -D trunk
for i in `git branch --remotes | sed 's/origin\///;s/ //'`; do git checkout $i; done
```
