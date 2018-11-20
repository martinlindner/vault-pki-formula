#!/bin/bash -xe

FQDN=$(hostname -f)
LIVE=/etc/vault_pki/live/$FQDN/

TEMP_KEYSTORE_PASS=$(openssl rand -base64 32)
DEST_KEYSTORE_PASS=$(cat /etc/tomcat/server.xml | sed -rn 's/.*keystorePass=\"([a-zA-Z0-9]*)\".*/\1/p')

openssl pkcs12 -export \
  -in $LIVE/fullchain.pem \
  -inkey $LIVE/privkey.pem \
  -out /tmp/$(hostname -f).p12 \
  -name tomcat \
  -caname intermediate \
  -password pass:$TEMP_KEYSTORE_PASS

keytool -importkeystore -noprompt \
  -destkeystore $LIVE/keystore.jks \
  -deststorepass $DEST_KEYSTORE_PASS \
  -destkeypass $DEST_KEYSTORE_PASS \
  -srckeystore /tmp/$(hostname -f).p12 \
  -srcstoretype PKCS12 \
  -srcstorepass $TEMP_KEYSTORE_PASS \
  -alias tomcat
