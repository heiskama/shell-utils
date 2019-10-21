#!/bin/bash

# Generate SES (SMTP) credentials from existing IAM credentials

# Check to see if OpenSSL is installed. If not, exit with errors.
if ! [[ -x "$(command -v openssl)" ]]; then
  echo "Error: OpenSSL isn't installed." >&2
  exit 1
fi

# These variables are required to calculate the SMTP password.
VERSION='\x02'
MESSAGE='SendRawEmail'
echo -n "Enter AWS_SECRET_ACCESS_KEY: "
read KEY
echo ""

# Calculate and show the SMTP password.
echo "SMTP username: (Same as AWS_ACCESS_KEY)"
echo -n "SMTP password: "
(echo -en $VERSION; echo -n $MESSAGE \
 | openssl dgst -sha256 -hmac "$KEY" -binary) \
 | openssl enc -base64

