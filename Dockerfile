FROM alpine:3.19

LABEL maintainer="Thomas Andrade <wolvie@gmail.com>"

ENV NGINX_VERSION="1.25.5" \
	MORE_SET_HEADER_VERSION="0.34" \
	HTTP_METRICS_MODULE_VERSION="0.1.1" \
	PROXY_CONNECT_VERSION="master"

COPY nginx.conf nginx.vh.default.conf /tmp/

RUN GPG_KEYS="43387825DDB1BB97EC36BA5D007C8D7C15D87369" \
	&& CONFIG="\
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
	--add-module=external_module/ngx_http_proxy_connect_module-${PROXY_CONNECT_VERSION} \
	" \
	&& addgroup -S nginx \
	&& adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
	&& apk add --no-cache --virtual .build-deps \
	build-base \
	openssl-dev \
	pcre2-dev \
	zlib-dev \
	linux-headers \
	curl \
	gnupg \
	libxslt-dev \
	gd-dev \
	geoip-dev \
	yajl-dev \
	&& curl -sfSL https://github.com/openresty/headers-more-nginx-module/archive/v${MORE_SET_HEADER_VERSION}.tar.gz -o /tmp/${MORE_SET_HEADER_VERSION}.tar.gz \
	--next -sfSL https://github.com/liquidm/ngx_metrics/archive/v${HTTP_METRICS_MODULE_VERSION}.tar.gz -o /tmp/${HTTP_METRICS_MODULE_VERSION}.tar.gz \
	--next -sfSL https://github.com/chobits/ngx_http_proxy_connect_module/tarball/master -o /tmp/${PROXY_CONNECT_VERSION}.tar.gz \
	--next -sfSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
	--next -sfSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& found=''; \
	for server in \
	hkp://keyserver.ubuntu.com:80 \
	ha.pool.sks-keyservers.net \
	hkp://p80.pool.sks-keyservers.net:80 \
	pgp.mit.edu \
	; do \
	echo "Fetching GPG key $GPG_KEYS from $server"; \
	gpg --batch --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
	done; \
	test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
	gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
	&& rm -rf "$GNUPGHOME" nginx.tar.gz.asc \
	&& mkdir -p /usr/src \
	&& tar -zxC /usr/src -f nginx.tar.gz \
	&& rm nginx.tar.gz \
	&& cd /usr/src/nginx-$NGINX_VERSION \
	&& mkdir external_module \
	&& tar xvf /tmp/${MORE_SET_HEADER_VERSION}.tar.gz -C external_module \
	&& rm /tmp/$MORE_SET_HEADER_VERSION.tar.gz \
	&& tar xvf /tmp/${HTTP_METRICS_MODULE_VERSION}.tar.gz -C external_module \
	&& rm /tmp/${HTTP_METRICS_MODULE_VERSION}.tar.gz \
	&& mkdir external_module/ngx_http_proxy_connect_module-${PROXY_CONNECT_VERSION} \
	&& tar xvf /tmp/${PROXY_CONNECT_VERSION}.tar.gz -C external_module/ngx_http_proxy_connect_module-${PROXY_CONNECT_VERSION} --strip-components 1 \
	&& rm /tmp/${PROXY_CONNECT_VERSION}.tar.gz \
	&& patch -d /usr/src/nginx-$NGINX_VERSION -p 1 < /usr/src/nginx-$NGINX_VERSION/external_module/ngx_http_proxy_connect_module-${PROXY_CONNECT_VERSION}/patch/proxy_connect_rewrite_102101.patch \
	&& ./configure $CONFIG \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& rm -rf /etc/nginx/html/ \
	&& mkdir /etc/nginx/conf.d/ \
	&& mkdir -p /usr/share/nginx/html/ \
	&& install -m644 html/index.html /usr/share/nginx/html/ \
	&& install -m644 html/50x.html /usr/share/nginx/html/ \
	&& ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
	&& strip /usr/sbin/nginx* \
	&& strip /usr/lib/nginx/modules/*.so \
	&& rm -rf /usr/src/nginx-$NGINX_VERSION \
	\
	# Bring in gettext so we can get `envsubst`, then throw
	# the rest away. To do this, we need to install `gettext`
	# then move `envsubst` out of the way so `gettext` can
	# be deleted completely, then move `envsubst` back.
	&& apk add --no-cache --virtual .gettext gettext \
	&& mv /usr/bin/envsubst /tmp/ \
	\
	&& runDeps="$( \
	scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
	| tr ',' '\n' \
	| sort -u \
	| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apk add --no-cache --virtual .nginx-rundeps $runDeps \
	&& apk del .build-deps \
	&& apk del .gettext \
	&& mv /tmp/envsubst /usr/local/bin/ \
	\
	# Bring in tzdata so users could set the timezones through the environment
	# variables
	&& apk add --no-cache tzdata \
	\
	# forward request and error logs to docker log collector
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log \
	&& mv /tmp/nginx.conf /etc/nginx/nginx.conf \
	&& mv /tmp/nginx.vh.default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443
STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
