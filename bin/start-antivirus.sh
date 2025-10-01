#!/bin/bash
#-------------------------------------------------------------------------------------
#
# IGT Pay Container antivirus (ClamAV) run script
# (c) 2022 IGT Plc
#
#-------------------------------------------------------------------------------------


function log2siem {
	logger -n onepaysyslog -T -P 514 "paycashier:clamAVrun: $*"
}

if [[ ! -f /usr/local/bin/clamscan ]]; then
	log2siem "Scanner executables not installed, aborting!"
	exit 1
fi


log2siem "Initialising scanner script..."

# every day at 2 AM run the virus scanner
while true
do
	difference=$(($(date -d "2:00" +%s) - $(date +%s)))
	if [ $difference -lt 0 ]
	then
		sleep $((86400 + difference))
	else
		sleep $difference
	fi
	log2siem "Loading virus definitions..."
	/usr/local/bin/freshclam
	log2siem "Starting virus scan..."
	/usr/local/bin/clamscan -i -r / --exclude-dir=/sys/ --exclude-dir=/opt/igt/pay/logshare/ 2> /tmp/clamav.err|logger -n onepaysyslog -T -P 514
	log2siem "Completed virus scan."
done
