#!/bin/bash
#-------------------------------------------------------------------------------------
#
# IGT Pay Container PAYCASHIER startup with Wazuh agent
# (c) 2021-2021 IGT Plc
#
#-------------------------------------------------------------------------------------

export NSS_WRAPPER_PASSWD=

if [ -n "$IGTPAY_HOST_ONEPAYSYSLOG" ]; then
        echo "$IGTPAY_HOST_ONEPAYSYSLOG onepaysyslog" >> /etc/hosts
fi

if [ -n "$IGTPAY_HOST_WAZUH_MANAGER" ]; then
        echo "$IGTPAY_HOST_WAZUH_MANAGER        wazuhmanager" >> /etc/hosts
fi

find /opt/tomcat/webapps/* -exec chown tomcat:tomcat {} \;

/opt/igt/pay/bin/start-antivirus.sh & 
/opt/igt/pay/bin/start-wazuhagent.sh & 

sha256sum /opt/tomcat/webapps/*.war | sed 's@/opt/tomcat/webapps/@@'
su tomcat /opt/tomcat/bin/catalina.sh run
