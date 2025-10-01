#!/bin/bash
#-------------------------------------------------------------------------------------
#
# IGT Pay Container Wazuh agent start
# (c) 2025 IGT Plc
#
#-------------------------------------------------------------------------------------

if [ -n "$IGTPAY_HOST_WAZUH_KEY" ]; then
	echo "$IGTPAY_HOST_WAZUH_KEY" > /var/ossec/etc/client.keys
	chown wazuh:wazuh /var/ossec/etc/client.keys
	chmod 640 /var/ossec/etc/client.keys
fi

if [ -n "$IGTPAY_HOST_WAZUH_MANAGER" ]; then
	# give the applications few minutes to start up and unpack all .war files to not triger file integrity alarms
	sleep 180
	/var/ossec/bin/wazuh-control start
else
	echo "Wazuh agent not configured!"
fi
