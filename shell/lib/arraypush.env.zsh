function aarray.push_path() {
	local assoc_array=$1; shift
  # fail fast
	if [[ ${${(t)assoc_array}%%-*} != "association" ]]; then
    echo "error: argument is not associative array."
    return 1
  fi

  # parse
  local key
  local file_path
  case $# in
    1)
      file_path=$1
      key=${file_path:t:r}
      ;;
    2)
      key=$1
      file_path=$2
      ;;
    *)
      echo "error: invalid number of arguments."
      return 1
      ;;
  esac

  if [[ -e $file_path ]]; then
    assoc_array[${key}]="${file_path}"
  else
    echo "trace: $file_path does not exist. skipping..."
  fi
}
