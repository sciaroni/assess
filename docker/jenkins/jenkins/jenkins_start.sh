#!/bin/bash

ssh-agent -s | sed 's/^echo/#echo/' > /var/jenkins_home/.profile
chmod 600 /var/jenkins_home/.profile
. /var/jenkins_home/.profile

for filename in /etc/jenkins/ssh/*; do
    ssh-add "/etc/jenkins/ssh/$(basename "$filename")"
done

unset SSH_AGENT_PID
unset SSH_AUTH_SOCK

if [ ! -z $LDAP_ENABLED ] && [ "$LDAP_ENABLED" == 'true' ]; then
   cp /tmp/config.xml /var/jenkins_home/config.xml
   PASSWORD_BASE64=$(perl -e "use MIME::Base64; print encode_base64('$MANAGER_PASSWORD');")
   sed -i  -e "s#<useSecurity/>#<useSecurity>true</useSecurity>\n<authorizationStrategy class=\"hudson.security.FullControlOnceLoggedInAuthorizationStrategy\"/>\n<securityRealm class=\"hudson.security.LDAPSecurityRealm\" plugin=\"ldap@1.10.2\">\n<server>ldap://${LDAP_SERVER_URL}</server>\n<rootDN>${LDAP_BASE_DN}</rootDN>\n<inhibitInferRootDN>false</inhibitInferRootDN>\n<userSearchBase>${USER_SEARCH_BASE}</userSearchBase>\n<userSearch>${USER_SEARCH_FILTER}</userSearch>\n<groupSearchBase>${GROUP_SEARCH_BASE}</groupSearchBase>\n<groupSearchFilter>${GROUP_SEARCH_FILTER}</groupSearchFilter>\n<groupMembershipStrategy class=\"jenkins.security.plugins.ldap.FromGroupSearchLDAPGroupMembershipStrategy\">\n<filter></filter>\n</groupMembershipStrategy>\n<managerDN>${MANAGER_DN}</managerDN>\n<managerPassword>${PASSWORD_BASE64}</managerPassword>\n<disableMailAddressResolver>false</disableMailAddressResolver>\n<displayNameAttributeName>displayname</displayNameAttributeName>\n<mailAddressAttributeName>mail</mailAddressAttributeName>\n</securityRealm>#g" /var/jenkins_home/config.xml
fi

/bin/tini -- /usr/local/bin/jenkins.sh
