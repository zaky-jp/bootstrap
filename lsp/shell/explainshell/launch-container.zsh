#!/usr/bin/env zsh
set -eu

## 0. Fail fast when neccessary commands are unavailable
## outcome: exit if limactl or jq is not installed
local REQ_CMDS=(limactl jq)
for c in "${(@)REQ_CMDS}"; do
  if [[ $+commands[${c}] -ne 1 ]]; then
    echo "Required command \`${c}\` not found. aborting..."
    exit 1
  fi
done

## 1. Set appropriate values to constants
## outcome: $DUMP_PATH
local DUMP_PATH='./db-dump/data.gz'
local UPSTREAM_URL='https://github.com/idank/explainshell/releases/download/db-dump/dump.gz'

## 2. Download db dump to $DUMP_PATH
## outcome: download db file if updated at upstream
if [[ -e ${DUMP_PATH} ]]; then
  curl -L -z "${DUMP_PATH}" -o "${DUMP_PATH}" "${UPSTREAM_URL}"
else
  # runs when there is no previous download
  curl -L -o "${DUMP_PATH}" "${UPSTREAM_URL}"
fi

## 3. Build and start container
## outcome: explainshell containers launched
if [[ $(limactl list --format json | jq -r '.status') != 'Running' ]]; then
  echo "Lima is not running. Try \`limactl start\`"
  exit 1
fi

lima nerdctl compose build
lima nerdctl compose up -d

## 4. Restore dump db
## outcome: dump file restored to db container and test passed
lima nerdctl compose exec -d --interactive=false --tty=false db mongorestore -- --archive --gzip /var/cache/db-dump/data.gz
lima nerdctl compose exec -d --interactive=false --tty=false web make -- tests

## 5. Show ip address
echo "explainshell should be accessible from: \
http://$(lima ip -4 -j a show dev lima0 | jq -j '.[].addr_info | .[].local'):5000"


