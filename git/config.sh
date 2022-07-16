#!/usr/bin/env bash
set -eu

###################
# Configuration
###################
COMMIT_EMAIL='105104188+zaky-jp@users.noreply.github.com'
COMMIT_NAME='Rintaro Kanzaki'

git config --global user.name "${COMMIT_NAME}"
git config --global user.email "${COMMIT_EMAIL}"
