#!/bin/bash
cat <<EOS
{
        "credStore": "osxkeychain",
        "cliPluginsExtraDirs": [
                "$(brew --prefix)/lib/docker/cli-plugins"
        ]
}
EOS

