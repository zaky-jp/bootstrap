# @define check functions
function check_file_exist() {
  local file=$1
  [[ -e $file || -h $file ]] # macos does not follow symlink with -e
  return $?
}
