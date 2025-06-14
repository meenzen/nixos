LIGHT_BLUE='\033[1;34m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

print () {
  echo -e "${LIGHT_BLUE}$1${NO_COLOR}"
}

print_error () {
  echo -e "${RED}Error:${NO_COLOR} $1"
}
