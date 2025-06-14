COLOR_LIGHT_BLUE='\033[1;34m'
COLOR_RED='\033[0;31m'
COLOR_NONE='\033[0m'

print () {
  echo -e "${COLOR_LIGHT_BLUE}$1${COLOR_NONE}"
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

print_warning () {
  echo -e "Warning: ${COLOR_RED}$1${COLOR_NONE}"
}

print_error () {
  echo -e "${COLOR_RED}==> Error:${COLOR_NONE} $1"
}

print_divider () {
  local columns=${COLUMNS:-80}
  local divider_char="${1:-─}"
  local color="${2:-$COLOR_LIGHT_BLUE}"
  local divider_line=""
  for ((i=0; i<columns; i++)); do
    divider_line+="$divider_char"
  done
  echo -e "${color}${divider_line}${COLOR_NONE}"
}

print_divider_error () {
  print_divider "" "$COLOR_RED"
}

prompt_or_exit () {
  echo "$1 [y/N]"
  read -r response
  if [ "$response" != "y" ]; then
    exit 0
  fi
}

alejandra_format () {
  print_status "Formatting Code"
  if ! alejandra . >/dev/null 2>&1; then
    print_error "Alejandra formatting failed."

    # Run alejandra again so that the user can see the error message
    print_divider_error
    alejandra . || true
    print_divider_error

    exit 1
  fi
}
