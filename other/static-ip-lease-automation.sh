#!/bin/bash

LOG_FILE="/var/log/dnsmasq.log"
LEASE_FILE="/var/lib/misc/dnsmasq.leases"
OUTPUT_FILE="/etc/dnsmasq.d/static-ip-leases.conf"
KEYWORD="dnsmasq-dhcp"

inotifywait -m -e modify "$LOG_FILE" | \
while read -r _; do
   if tail -n 1 "$LOG_FILE" | grep -q "$KEYWORD"; then
        truncate -s 0 OUTPUT_FILE #clears leases file
        awk '{print "dhcp-host=" $2 "," $3 ",infinite"}' $LEASE_FILE > $OUTPUT_FILE
        systemctl restart dnsmasq.service
   fi
done
