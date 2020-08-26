#!/bin/sh

set -e

vars='$OPM_PACKAGES_PATH
$APP_ROOT
$APP_CERT_FILE
$APP_CERT_KEY_FILE
$APP_SERVER_NAME
$AUTH_CERT_FILE
$AUTH_CERT_KEY_FILE
$AUTH_SERVER_NAME
$MEDIA_CERT_FILE
$MEDIA_CERT_KEY_FILE
$MEDIA_SERVER_NAME
$KEYCLOAK_ADDRESS
$OIDC_DISCOVERY_URL
$OIDC_CLIENT_ID
$OIDC_CLIENT_SECRET'

for template in /etc/nginx/templates/*.conf; do
    name=`basename $template`
    echo "Processing NGINX configuration template file $name..."

    envsubst "$vars" < $template > "/etc/nginx/conf.d/$name"

    cat "/etc/nginx/conf.d/$name"
done

exec "$@"
