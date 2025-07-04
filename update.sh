#!/bin/bash

# Location of the nginx config file that contains the CloudFlare IP addresses.
CF_NGINX_CONFIG="/etc/nginx/conf.d/cloudflare.conf"

# The URLs with the actual IP addresses used by CloudFlare.
CF_URL_IP4="https://www.cloudflare.com/ips-v4/"
CF_URL_IP6="https://www.cloudflare.com/ips-v6/"

# Custom IP file
CUSTOM_IP="$(dirname $0)/custom.txt"

# Temporary files.
CF_TEMP_IP4="/tmp/cloudflare-ips-v4.txt"
CF_TEMP_IP6="/tmp/cloudflare-ips-v6.txt"

# Download the files.
if [ -f /usr/bin/curl ];
then
    curl --silent --output $CF_TEMP_IP4 $CF_URL_IP4
    curl --silent --output $CF_TEMP_IP6 $CF_URL_IP6
elif [ -f /usr/bin/wget ];
then
    wget --quiet --output-document=$CF_TEMP_IP4 --no-check-certificate $CF_URL_IP4
    wget --quiet --output-document=$CF_TEMP_IP6 --no-check-certificate $CF_URL_IP6
else
    echo "Unable to download CloudFlare files."
    exit 1
fi


# Check number of lines. Sometimes CloudFlare shows captcha
CF_TEMP_IP4_LINES=$(wc -l < $CF_TEMP_IP4)
CF_TEMP_IP6_LINES=$(wc -l < $CF_TEMP_IP6)

MAX_LINES=20
if [[ "$CF_TEMP_IP4_LINES" -le "$MAX_LINES" ]] && [[ "$CF_TEMP_IP6_LINES" -le "$MAX_LINES" ]]; then

  # Generate the new config file.
  echo "# Generated at $(date) by $0" > $CF_NGINX_CONFIG
  echo "# Custom IP Ranges" >> $CF_NGINX_CONFIG

  echo "" >> $CF_NGINX_CONFIG

  awk '{ print "set_real_ip_from " $0 ";" }' $CUSTOM_IP >> $CF_NGINX_CONFIG

  echo "" >> $CF_NGINX_CONFIG


  echo "# CloudFlare IP Ranges" >> $CF_NGINX_CONFIG

  echo "" >> $CF_NGINX_CONFIG

  echo "# - IPv4 ($CF_URL_IP4)" >> $CF_NGINX_CONFIG
  awk '{ print "set_real_ip_from " $0 ";" }' $CF_TEMP_IP4 >> $CF_NGINX_CONFIG

  echo "" >> $CF_NGINX_CONFIG

  echo "# - IPv6 ($CF_URL_IP6)" >> $CF_NGINX_CONFIG
  awk '{ print "set_real_ip_from " $0 ";" }' $CF_TEMP_IP6 >> $CF_NGINX_CONFIG

  echo "" >> $CF_NGINX_CONFIG

  echo "real_ip_header CF-Connecting-IP;" >> $CF_NGINX_CONFIG

  echo "" >> $CF_NGINX_CONFIG

  # Remove the temporary files.
  rm $CF_TEMP_IP4 $CF_TEMP_IP6

  # Reload the nginx config.
  /usr/sbin/nginx -t && /usr/sbin/service nginx reload || rm $CF_NGINX_CONFIG

fi
