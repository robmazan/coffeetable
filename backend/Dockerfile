FROM openresty/openresty:buster-fat

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y libimage-exiftool-perl

ENV OPM_PACKAGES_PATH "/usr/local/openresty/site"

RUN opm install zmartzone/lua-resty-openidc

COPY docker-entrypoint.sh /

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD ["/usr/bin/openresty", "-g", "daemon off;"]
