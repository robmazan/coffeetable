FROM openresty/openresty:buster-fat

ENV OPM_PACKAGES_PATH "/usr/local/openresty/site"

RUN opm install zmartzone/lua-resty-openidc

COPY docker-entrypoint.sh /

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD ["/usr/bin/openresty", "-g", "daemon off;"]
