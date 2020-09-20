#!/bin/sh

set -e

vars=`printf '${%s} ' $(env | cut -d= -f1)`

for template in /etc/nginx/templates/*.template; do
    name=`basename $template`
    echo "Processing NGINX configuration template file $name..."
    outfile=`echo "$name" | sed 's/\.template$//g'`

    envsubst "$vars" < $template > "/etc/nginx/conf.d/$outfile"

    cat "/etc/nginx/conf.d/$outfile"
done

exec "$@"
