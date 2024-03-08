# @define path.push function
# @output append to the beginning of the $path
function path.push() {
  local new_path=$1
  echo "debug: adding '$new_path' to PATH"
  path=($new_path $path)
}
# @end