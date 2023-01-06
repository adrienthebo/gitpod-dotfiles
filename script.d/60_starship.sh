#!/usr/bin/env bash

curl -sS https://starship.rs/install.sh | sh -s - --yes

starship_init='eval "$(starship init bash)"'
if ! grep -q "$starship_init" ~/.bashrc; then
  echo "$starship_init" >> ~/.bashrc
fi

mkdir -p "$HOME/.config" || true
cat - > ~/.config/starship.toml <<'EOD'
format = """
$kubernetes\
$directory\
$time\
$vcsh\
$git_branch\
$git_commit\
$git_state\
$git_metrics\
$git_status\
$docker_context\
$golang\
$helm\
$nodejs\
$php\
$pulumi\
$rust\
$terraform\
$aws\
$gcloud\
$azure\
$sudo\
$cmd_duration\
$line_break\
$jobs\
$os\
$character"""

[time]
format = ' [$time]($style) '
disabled = false
EOD