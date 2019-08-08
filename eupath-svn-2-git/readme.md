# Subversion to Git migration helpers

utils and wrappers to simplify my life while manually creating and maintaining a one way sync between the EuPathDB SVN projects and git mirrors of those projects.

## Scripts

`sco.sh`: git svn checkout
`update.sh`: git svn rebase
`switch.sh`: helper to change the owner of the git repos from "EuPathDB-Infra" to "EuPathDB"

## Other stuff

Prep a repo for pushing to git. Prerequisites:

1. checked out with git svn
2. git remote added

```sh
for i in `git branch --remotes | sed 's/origin\///;s/ //'`; do git checkout $i; done
git branch -D trunk
```

## Notes

### New Mirror

```sh
./sco.sh <svn root> <project name>
cd <project name>
git remote add origin git@github.com:<org>/<project name>
for i in `git branch --remotes | sed 's/origin\///;s/ //'`; do git checkout $i; done
  ... a bunch of text ...
git branch -D trunk
git push --all origin -fu
```

### Update

#### Step 1:

```sh
./update.sh
```

#### Step 2:

fix the broken repo using git rebase/merge followed by
```sh
git push --all origin -fu
```
