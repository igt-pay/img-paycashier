ARG base_version=25.2
FROM igtpaygamdevacr.azurecr.io/igtpay/paytomcat10:${base_version}


COPY bin/ /opt/igt/pay/bin/
COPY conf/ /opt/tomcat/conf/
COPY artefacts/ /opt/tomcat/webapps/

USER root

# Expose the ports we're interested in
EXPOSE 8080

CMD ["/bin/bash","/opt/igt/pay/bin/start-paycashier.sh"]
