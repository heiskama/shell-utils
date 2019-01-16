#!/bin/bash

# Build a bash function bootstrapping file

# Settings
DIR=~/bin/
FILE=bootstrap.sh
INCLUDES="require orig ipinfo whereami genpass linuxtime humantime coin dice aws-whoami aws-profiles"

# Begin code
function create_bootstrap() {
  rm -f $FILE
  while test $# -gt 0
    do
      case "$1" in
        *)
         # Check if the file exists
         if [ -f "$1" ]; then
           echo "function $1() {" >> $FILE
           cat "$1" >> $FILE
           echo "}" >> $FILE
           printf "\n\n\n" >> $FILE
         else
           echo "File $1 doesn't exist."
           exit 1
         fi
        ;;
    esac
    shift
  done
  echo "echo Bootstrap complete: $INCLUDES" >> $FILE
}

# Main
OLDPWD=$(pwd)
cd "$DIR" || { echo "Can't access $DIR"; cd $OLDPWD; exit 1; }
create_bootstrap $INCLUDES
echo "Done. $FILE created."
cd $OLDPWD

# Using the bootstrap file:
#
# $ curl bash.dyn.link
# source <(curl -s https://raw.githubusercontent.com/heiskama/bash-utils/master/bootstrap.sh)
#
# Copy/paste the output into the current shell to bootstrap various helper functions
