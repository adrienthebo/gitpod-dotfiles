#!/usr/bin/env bash
#
git config --global init.defaultBranch main

git config --global core.excludesFile "$HOME/.gitignore"

git config --global push.autoSetupRemote true
git config --global push.default current

git config --global color.diff.meta yellow bold
git config --global color.diff.commit green bold
git config --global color.diff.frag magenta bold
git config --global color.diff.old red bold
git config --global color.diff.new green bold
git config --global color.diff.whitespace red reverse
git config --global color.diff.newMoved cyan
git config --global color.diff.oldMoved blue

git config --global color.branch.current yellow reverse
git config --global color.branch.local yellow
git config --global color.branch.remote green

git config --global color.status.added yellow
git config --global color.status.untracked cyan

git config --global diff.mnemonicprefix true

git config --global commit.verbose true

git config --global alias.ci 'commit -v'
git config --global alias.st 'status --short --branch'
git config --global alias.wat 'log --stat -p'
git config --global alias.lg "log --pretty=format:'%C(yellow)%h%C(reset) %C(blue)%an%C(reset) %C(cyan)%cr%C(reset) %s %C(green)%d%C(reset)' --graph"
git config --global alias.forward 'pull --ff-only'
git config --global alias.redo 'commit --amend -C HEAD'
git config --global alias.where 'rev-parse --abbrev-ref HEAD'
git config --global alias.co "! bash -c \"f() { git branch | tr -cd '[[:alnum:]-_/\n]' |fzf --preview 'git log --color=always -1 -p {}' | xargs --no-run-if-empty git checkout ; } ; f\""