#########################################################################
# File Name: ldap.sh
# Author: zouguoyin
# mail: 995637339@qq.com
# Created Time: 2020年12月15日 星期二 14时29分55秒
#########################################################################
#!/bin/bash -e
SERVICE=ldap-service
HOST_NAME=ldap-server
LDAP_DOMAIN=zgy.com
LDAP_DC=zgy
LDAP_DC_ORG=com
NETWORK_ADAPTER=eth0
PASSWORD=654321
OPENLDAP="1.3.0"
PHPLDAPADMIN="0.9.0"
HTTPS_PORT=8080
OPENLDAP_PORT=389
docker run \
	    -p ${OPENLDAP_PORT}:389 \
	    --name ${SERVICE} \
	    --hostname ${HOST_NAME} \
	    --env LDAP_ORGANISATION="WPT-Group" \
		--env LDAP_DOMAIN=${LDAP_DOMAIN} \
	    --env LDAP_ADMIN_PASSWORD=${PASSWORD} \
	    --detach osixia/openldap:${OPENLDAP}
docker run \
	    -p ${HTTPS_PORT}:80 \
	    --name ${SERVICE}-admin \
	    --hostname ${HOST_NAME}-admin \
	    --link ${SERVICE}:${HOST_NAME} \
	    --env PHPLDAPADMIN_LDAP_HOSTS=${HOST_NAME} \
	    --env PHPLDAPADMIN_HTTPS=false \
		--detach \
		osixia/phpldapadmin:${PHPLDAPADMIN}
sleep 1
echo "-----------------------------------"
PHPLDAP_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" ${SERVICE})
docker exec ${SERVICE} ldapsearch -x -H ldap://${PHPLDAP_IP}:389 -b "dc=${LDAP_DC},dc=${LDAP_DC_ORG}" -D "cn=admin,dc=${LDAP_DC},dc=${LDAP_DC_ORG}" -w ${PASSWORD}
 echo "-----------------------------------"
 PUB_IP=$(ifconfig ${NETWORK_ADAPTER} |grep "inet"|awk '{
 print $2}')
 echo "Go to: https://${PUB_IP}:${HTTPS_PORT}"
 echo "Login DN: cn=admin,dc=${LDAP_DC},dc=${LDAP_DC_ORG}"
 echo "Password: ${PASSWORD}"

