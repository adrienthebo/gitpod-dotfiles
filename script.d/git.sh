#!/usr/bin/env bash

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
