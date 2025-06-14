LIGHT_BLUE='\033[1;34m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

print () {
  echo -e "${LIGHT_BLUE}$1${NO_COLOR}"
}

print_start () {
  print "=> $1"
}

print_end () {
  print "=> $1"
}

print_status () {
  print "==> $1"
}

print_error () {
  echo -e "${RED}Error:${NO_COLOR} $1"
}

prompt_or_exit () {
  echo "$1 [y/N]"
  read -r response
  if [ "$response" != "y" ]; then
    exit 0
  fi
}
