# zsh-function: require
## Concept
module-like autoloading of zsh functions
## Usage
Paste below snippet to use require module
```shell
autoload -Uz "${PLAYGROUND_DIR}/common/zsh-functions/require" && require
```
Then you can call `require` function; For example
```shell
require 'log' # no verb will assume common
require common 'apt-utils' # common would load common/zsh-functions
require apt 'nvim' # apt would check certain package is already installed
require brew 'mas' # similar, but use brew to check
require cask '1password' # casks
require snap 'lxd' # snaps
```
## Documentation rules (for zsh-functions)
### functions should follow below naming rules:
- names start with module name, then followed by action e.g. *path.get_dirname*
- actions should have four types:
  - `_get` functions, which provides results via stdout
  - `_do` functions, which executes certain commands with appropriate logging via stdout
  - *plain* functions without prefix, which provides status via exit code
  - `_` fucntions, which should not be called outside of the module; treated like private functions

exception is `log` module where it uses *plain* names but actually calls `_do` functions, mainly to reduce text size.

### functions should include below annotation to document usage
- **@function**: provides function summary, with name and # of arguments
- **@description**: provides textual description
- **@param:*N***: *N* provides internal variable name and its description in a form of `$var as 'description'` for each argument, *N* being argumental positions
- **@return:*N***: provides description of exit code, *N* being code returned
- **@stdout**: explains what stdout is used for

TODO: create parser so that editor is aware of above annotation
```