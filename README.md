NGX - NGinx docker image
==============================

[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://git.thebarrens.nu/wolvie/ngx/blob/master/LICENSE) [!["Get your own image badge on microbadger.com"](https://images.microbadger.com/badges/image/tandrade/ngx.svg)](https://microbadger.com/images/tandrade/ngx) [!["Get your own image badge on microbadger.com"](https://images.microbadger.com/badges/image/tandrade/ngx:latest-modsec.svg)](https://microbadger.com/images/tandrade/ngx:latest-modsec)

NGInx docker image with some extra packages included, based on the official [NGInx](https://github.com/nginxinc/docker-nginx) docker images

Compilation Flags
-----------------

```shell
  --prefix=/etc/nginx \
  --sbin-path=/usr/sbin/nginx \
  --modules-path=/usr/lib/nginx/modules \
  --conf-path=/etc/nginx/nginx.conf \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log \
  --pid-path=/var/run/nginx.pid \
  --lock-path=/var/run/nginx.lock \
  --http-client-body-temp-path=/var/cache/nginx/client_temp \
  --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
  --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
  --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
  --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
  --user=nginx \
  --group=nginx \
  --with-http_ssl_module \
  --with-http_realip_module \
  --with-http_addition_module \
  --with-http_sub_module \
  --with-http_dav_module \
  --with-http_flv_module \
  --with-http_mp4_module \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_random_index_module \
  --with-http_secure_link_module \
  --with-http_stub_status_module \
  --with-http_auth_request_module \
  --with-http_xslt_module=dynamic \
  --with-http_image_filter_module=dynamic \
  --with-http_geoip_module=dynamic \
  --with-pcre \
  --with-threads \
  --with-stream \
  --with-stream_ssl_module \
  --with-stream_ssl_preread_module \
  --with-stream_realip_module \
  --with-stream_geoip_module=dynamic \
  --with-http_slice_module \
  --with-mail \
  --with-mail_ssl_module \
  --with-compat \
  --with-file-aio \
  --with-http_v2_module \
  --add-module=external_module/headers-more-nginx-module-${MORE_SET_HEADER_VERSION} \
  --add-module=external_module/ngx_metrics-${HTTP_METRICS_MODULE_VERSION} \
  --add-module=external_module/modsecurity-nginx \
```

Usage
-----

Usage should follow the same lines as the default nginx image, you can check it [here](https://hub.docker.com/_/nginx/)

ModSecurity
-----------

There's also the -modsec tags that are built with Modsecurity and with the OWASP CRS ruleset, to enable this feature on your vhost add something like:

```conf
server {
    # ...
    modsecurity on;
    modsecurity_rules_file /etc/nginx/modsec/main.conf;
}
```
