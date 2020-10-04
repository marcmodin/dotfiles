#!/bin/bash

# pretty format print functions
info() { echo -e "${CYAN}${*}${RESET}"; }
question() { printf "${YELLOW}${*} [Y/n]: ${RESET}";}
error() { echo -e "${RED}${*}${RESET}"; }
valid() { echo -e "${GREEN}${*}${RESET}"; }
warning() { echo -e "${YELLOW}${*}${RESET}"; }

# Get user input 
ask() {
  question "${*}" && read answer
  echo
  # if not y then exit program
  if [[ "${answer}" != "Y" ]]; then
    question "do you want to continue(Y) or abort (n)" && read answer
    if [[ "${answer}" == "n" ]]; then
      error "You have aborted: Exited program!"
      echo
      exit 1
    fi
    return 100
  fi
}

# Main functions
start_script() {
  
  info "                                                       "
  info "   ______                               _              "
  info "  / _____) _                 _         | |             " 
  info " ( (____ _| |_ _____  ____ _| |_    ___| |__           "
  info "  \____ (_   _|____ |/ ___|_   _)  /___)  _ \          "
  info "  _____) )| |_/ ___ | |     | |_ _|___ | | | |         "
  info " (______/  \__)_____|_|      \__|_|___/|_| |_|         "
  info "                                                       "

  info "🎉 Welcome! This script will guide you through setting up your new system"
  
  ask "Do you want to continue or exit?" 
}


main(){
  start_script
  source install.sh
}

main "$*"
