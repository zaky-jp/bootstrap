# playground
Personalised environment all in a single repository.

**tl;dr**: Run ```curl -sSfL 'https://raw.githubusercontent.com/zaky-jp/playground/main/setup-playground.sh' | bash +x```

## Concept
A mixture of *dotfiles*, *IaC*, personal utils... that can be cloned and run across different environments: regardless of the machine types, whether it's a laptop, a server, or even insider a container.

- Be idempotent
  - nothing should assume something is run only once, or only after.
  - always produce desired results even `install.zsh` is run multiple times.
- Assume different architecture
  - should produce desired results for `amd64` and `arm64`, or `macos` and `ubuntu`, and likewise.
- Fail if anything goes wrong
  - ensure to check and fail fast

## A set of rules
### shellscript
Any script to run before installing `zsh` should assume `bash` compatibility, with `.sh` extension.
Otherwise, scripts should assume `zsh` compatibility, with `.zsh` extension.

Scripts should *always* call ```set -eu``` to ensure it fails if anything goes wrong.

Use `#!/usr/bin/env zsh` shellbang rather than `#!/bin/zsh`, as OS may not have latest version installed to `/bin`.

### git
All commit messages should follow *conventional commits* rules. 

Refer [specification][conv_commit_specs] for further details.

[conv_commit_specs]: https://www.conventionalcommits.org/ja/v1.0.0/
