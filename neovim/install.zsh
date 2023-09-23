#!/usr/bin/env zsh
set -eu

## 0. read lib files
## outcome: zsh-functions under $PLAYGROUND_DIR/common/zsh-functions/ sourced
if [[ ! -d "${PLAYGROUND_DIR}" ]]; then
  echo "\$PLAYGROUND_DIR do not exist. aborting..." 2>&1
  exit 1
fi
source "${PLAYGROUND_DIR}/common/zsh-functions/init"

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
      snap install nvim --classic
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
  eval "${PLAYGROUND_DIR}/neovim/sparcecheckout.sh"
  mkdir -p "$(get_dirname ${JETPACK_PATH})"
  cp "${PLAYGROUND_DIR}/neovim/jetpack/plugin/jetpack.vim" "${JETPACK_PATH}"
fi

## 4. symlinking configuration file
## outcome: init.lua symlinked under $NVIM_CONFIG
safe_symlink "${PLAYGROUND_DIR}/neovim/init.lua" "${NVIM_CONFIG}/init.lua"

## 5. installing packages
## outcome: neovim packages installed
nvim --headless "+JetpackSync" "+qa"

## 6. [if ubuntu] configuring update-alternatives
## outcome: update-alternative sets neovim as first choice editor
if [[ "$RUNOS" == "ubuntu" ]]; then
  local NVIM_PATH="/snap/nvim/current/usr/bin/nvim" # hardcoded
  if [[ ! -x "${NVIM_PATH}" ]]; then
    log_warn "neovim is not installed by snap. skipping update-alternatives..."
  else
    log_info "configuring update-alternatives..."
    local list=(editor vi vim)
    for tool in "${list[@]}"; do
      sudo update-alternatives --install "$(which ${tool})" "${tool}" "${NVIM_PATH}" 100
      sudo update-alternatives --set "${tool}" "${NVIM_PATH}"
    done
    # ToDo need to manually create shellscript files, as they are created as a part of ubuntu release
    # https://git.launchpad.net/ubuntu/+source/neovim/tree/debian/scripts?h=ubuntu/jammy&id=803f15ab5ac9163f38abe7bce43c9aaa5ec093be
    #list=(ex view rview rvim vimdiff)
    #for tool in "${list[@]}"; do
    #  sudo update-alternatives --set "${tool}" "${NVIM_LIBEXEC}/${tool}"
    #done
  fi
fi
