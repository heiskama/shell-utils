function require() {
#!/bin/bash

# This script checks whether the commands/tools matching the input parameters can be found in the system.
# A missing one will produce an error message and result in exit status 1.

# The case of no input parameters or empty input
if [[ $# -eq 0 ]] || [[ -z $@ ]]; then
  NAME=$0
  echo "Usage: ${NAME##*/} [command] ..."
  exit 0
fi

# Check for required commands/tools
for i in $@; do
  command -v $i > /dev/null 2>&1 || { echo >&2 "'$i' is needed but could not be found."; exit 1; } 
done;
}



function orig() {
#!/bin/bash

# Make backups with a timestamp.
# file -> file.orig.YYYY-MM-DD_HH.MM.SS

while test $# -gt 0
do
  case "$1" in
    *)
      cp -vpi $1 $1.orig.$(date +%F_%H.%M.%S)
      ;;
  esac
  shift
done
}



function ipinfo() {
#!/bin/bash

## Installation, country database file update and city database file addition:
# sudo apt-get install geoip-bin
# wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
# gunzip GeoIP.dat.gz
# sudo cp GeoIP.dat /usr/share/GeoIP/
# wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
# gunzip GeoLiteCity.dat.gz
# sudo cp GeoLiteCity.dat /usr/share/GeoIP/

require geoiplookup

IP=$1

# Default is own ip
if [ -z $IP ]; then
  IP=$(curl -s http://checkip.amazonaws.com)
fi

HOST=$(dig @8.8.8.8 +noall +answer -x "$IP" | awk '{print $5}')

if [ -z "$HOST" ]; then
  HOST="---"
else
  HOST=$(echo $HOST | sed '1s/.$//') # Trim the last char
fi

COUNTRY=$(geoiplookup $IP)

if [ -f /usr/share/GeoIP/GeoLiteCity.dat ]; then
  CITY=$(geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat $IP)
fi

echo $IP, $HOST, $COUNTRY, $CITY | sed -e 's/GeoIP Country Edition: //g; s/GeoIP City Edition, Rev [0-9]*: //g'
}



function whereami() {
#!/bin/bash

# Alias to ipinfo
require ipinfo
ipinfo
}



function genpass() {
#!/bin/bash
if [[ $# -eq 1 ]]; then
	cat /dev/urandom | tr -dc 'a-zA-Z0-9' | tr -d 'iloILO10' | fold -w $1 | head -n 1
else
	NAME=$0
	echo "Generate passwords."
	echo "Usage: ${NAME##*/} [length]"
fi
}



function linuxtime() {
#!/bin/bash
# Convert human readable time to Linux time
# Input format: YYYY-MM-DD HH:MM:SS
if [ -n "$2" ]; then
  date --date="$1 $2" +%s
else
  date --date="$1" +%s
fi
}



function humantime() {
#!/bin/bash
# Convert Linux time to human readable time
# Output format: YYYY-MM-DD HH:MM:SS
date -d @$1 +%F_%T | tr _ " "
}



function coin() {
#!/bin/bash
COIN=$(cat /dev/urandom | tr -dc "0-1" | head -c 1)

if [ "$COIN" == "1" ]; then
	echo "Heads"
else
	echo "Tails"
fi
}



function dice() {
#!/bin/bash
cat /dev/urandom | tr -dc "1-6" | head -c 1 | xargs
}



function aws-whoami() {
#!/bin/bash
if [ -n "$AWS_PROFILE" ]; then
  echo "Current profile: $AWS_PROFILE"
else
  echo "No profile set."
fi

aws sts get-caller-identity
}



function aws-profiles() {
#!/bin/bash
PROFILES=$(grep -e "^\[profile " ~/.aws/config | cut -d " " -f 2 | tr -d "]" | sed 's/.*/export AWS_PROFILE=&/')
echo "Current profile is ($AWS_PROFILE) and available profiles are:"
echo "$PROFILES"
echo "export AWS_PROFILE="
}



function file-attributes() {
#!/bin/bash

# This script can be used to take a backup of file permissions and ownership a restore them later

function file-attibutes-save() {
	find . | xargs -i sh -c "stat --format=\"%a %A %u %g %U %G %n\" \"{}\"" > "$1"
}

function file-attibutes-restore() {
	cat "$1" | while read i; do
	  MODE=$(echo "$i" | cut -d " " -f 1)
	  USER=$(echo "$i" | cut -d " " -f 3)
	  GROUP=$(echo "$i" | cut -d " " -f 4)
	  FILENAME=$(echo "$i" | cut -d " " -f 7-)
	  chmod -v "$MODE" "$FILENAME"
	  chown -v "$USER":"$GROUP" "$FILENAME"
	done
}

# The case of no input parameters or empty input
if [[ $# -eq 0 ]] || [[ -z $@ ]]; then
  NAME=$0
  echo "Usage: ${NAME##*/} [--save-to|--restore-from] filename"
  exit 0
fi


# Correct number of parameters
if [[ $# -eq 2 ]]; then
	if [[ "$1" == "--save-to" ]]; then
		file-attibutes-save "$2"
	elif [[ "$1" == "--restore-from" ]]; then
		file-attibutes-restore "$2"
	fi
fi
}



echo Bootstrap complete: require orig ipinfo whereami genpass linuxtime humantime coin dice aws-whoami aws-profiles file-attributes
