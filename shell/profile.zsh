#!/usr/bin/env zsh

if [[ ${+commands[byobu]} -eq 1 && $TERM_PROGRAM != "vscode" ]]; then
  byobu
fi
