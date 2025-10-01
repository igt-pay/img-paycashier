#!/bin/bash
#-------------------------------------------------------------------------------------
#
# IGT Pay Cashier container liveness probe script
# (c) 2025 IGT Plc
#
#-------------------------------------------------------------------------------------
function log2siem {
	logger -n onepaysyslog -T -P 514 "${IGTPAY_CASHIER_INSTANCE_NAME}:liveness-probe: $*"
}


#
# check if Tomcat is up and running and serving content by fetching robots.txt file from the first identified cashier containing it
#
# TODO: rewrite status check
for CINS in $(find /opt/tomcat/webapps/cashier*/status.html)
do
	IFS='/' read -r -a SEGS <<< "$CINS"
		PAYPROBE=$(curl -IL http://localhost:8080/${SEGS[4]}/status.html 2> /dev/null | head -n 1 | sed 's/HTTP.* \([0-9]\+\).*/\1/')
	if [ "$PAYPROBE" != "200" ]; then
		log2siem "Cashier IGT Pay probe failed"
		exit 1 
	fi
	break # only check one cashier that has status page
done

#
# Intrusion detection system activity check
#

WAZUH_DELAY_ALERT=60
WAZUH_DELAY_FAIL=86400 # 24 hours, which is less than 36 hours as per PCI SSF 9.1.b

WAZUH_LAST_ACK="$(grep last_ack /var/ossec/var/run/wazuh-agentd.state |cut -c11-29)"
WAZUH_DELAY_SECONDS=$(("$(date +%s)" - "$(date -d "$WAZUH_LAST_ACK" +%s)"))
echo $WAZUH_DELAY_SECONDS

if [ "$WAZUH_DELAY_SECONDS" -gt "$WAZUH_DELAY_ALERT" ]; then
	log2siem "Intrusion detection system has missed ACK for over $WAZUH_DELAY_ALERT seconds"
fi

if [ "$WAZUH_DELAY_SECONDS" -gt "$WAZUH_DELAY_FAIL" ]; then
	log2siem "Intrusion detection system has missed ACK for over $WAZUH_DELAY_FAIL seconds - marking node as not healthy"
	exit 2
fi
