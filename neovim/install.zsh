#!/usr/bin/env zsh
set -eu

## 0. read lib files
## outcome: zsh-functions under $PLAYGROUND_DIR/common/zsh-functions/ sourced
if [[ ! -v "PLAYGROUND_DIR" ]]; then
  echo "\$PLAYGROUND_DIR not set. aborting..." 2>&1
  exit 1
elif [[ ! -d "${PLAYGROUND_DIR}" ]]; then
  echo "\$PLAYGROUND_DIR do not exist. aborting..." 2>&1
  exit 1
else
  () {
  emulate -L zsh -o extended_glob
  local f
  for f in ${PLAYGROUND_DIR}/common/zsh-functions/*(.); do
    echo "loading ${f}"
    source "${f}"
  done
  }
fi
test_constant

## 1. initialisation
## outcome: $NVIM_CONFIG and $NVIM_DATA set and directories created
local NVIM_CONFIG="${NVIM_CONFIG:-${XDG_CONFIG_HOME}/nvim}"
local NVIM_DATA="${NVIM_DATA:-${XDG_DATA_HOME}/nvim}"
mkdir -p "${NVIM_CONFIG}"
mkdir -p "${NVIM_DATA}"
log_notice "Installing neovim..."

## 2. install neovim
## outcome: neovim installed by appropriate package manager
local pkg="neovim"
if ! test_command nvim; then
  case "$RUNOS" in
    "macos")
      brew install "${pkg}"
      ;;
    "ubuntu")
      apt install "${pkg}"
      ;;
    *)
      log_fatal "Please install ${pkg} manually. aborting..."
      ;;
  esac
fi

## 3. install neovim package manager
## outcome: jetpack.vim installed
local JETPACK_PATH="${NVIM_DATA}/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim"
if [[ -e ${JETPACK_PATH} ]]; then
  log_info "jetpack already installed"
else
  log_info "installing jetpack..."
  mkdir -p "$(get_dirname ${JETPACK_PATH})"
  cp "${PLAYGROUND_DIR}/neovim/jetpack/plugin/jetpack.vim" "${JETPACK_PATH}"
fi

## 4. symlinking configuration file
## outcome: init.vim symlinked under $NVIM_CONFIG
safe_symlink "${PLAYGROUND_DIR}/neovim/init.vim" "${NVIM_CONFIG}/init.vim"

## 5. [if ubuntu] configuring update-alternatives
## outcome: update-alternative sets neovim as first choice editor
if [[ "$RUNOS" == "ubuntu" ]]; then
  local NVIM_LIBEXEC="/usr/libexec/neovim" # hardcoded
  if [[ ! -x "${NVIM_LIBEXEC}" ]]; then
    log_warn "neovim library not found. skipping update-alternatives..."
  else
    log_info "configuring update-alternatives..."
    local list=(editor vi vim)
    for tool in "${list[@]}"; do
      sudo update-alternatives --set "${tool}" "$commands[nvim]"
    done
    list=(ex view rview rvim vimdiff)
    for tool in "${list[@]}"; do
      sudo update-alternatives --set "${tool}" "${NVIM_LIBEXEC}/${tool}"
    done
  fi
fi