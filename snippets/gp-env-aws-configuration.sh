#!/usr/bin/env bash

tmpfile="$(mktemp)"

echo "$AWS_CONFIGURATION" | jq -r > $tmpfile
code $tmpfile --wait

if [[ $? -eq 0 ]]; then
  gp env AWS_CONFIGURATION="$(cat "$tmpfile")"
  export AWS_CONFIGURATION="$(cat "$tmpfile")"

  source  "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/../lib/autoinit.sh"
  autoinit init
  autoinit configure aws
fi