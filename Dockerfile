FROM ubuntu


RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget libreadline-dev libncurses5-dev libpcre3-dev \
    libssl-dev perl make build-essential zlib1g-dev zlib1g openssl && rm -rf /var/lib/apt/lists/*
RUN groupadd -r nginx && useradd -r -g nginx -s /sbin/nologin -d /var/cache/nginx -c "nginx user" nginx 

ENV PCRE_V 8.41
ENV ZLIB_V 1.2.11
ENV OPENSSL_V 1.0.2k
ENV NGINX_V 1.13.7
ENV PG_MAJOR 9.6
ENV LUA_NGINX_MODULE_VERSION 0.10.11
ENV NGX_DEVEL_KIT_VERSION 0.3.0
ENV LUAJIT_VERSION 2.0.4

RUN wget http://luajit.org/download/LuaJIT-${LUAJIT_VERSION}.tar.gz && tar xvf LuaJIT-${LUAJIT_VERSION}.tar.gz && cd ./LuaJIT-${LUAJIT_VERSION} && make install && cd ..
RUN wget https://github.com/simpl/ngx_devel_kit/archive/v${NGX_DEVEL_KIT_VERSION}.tar.gz -O ngx_devel_kit-${NGX_DEVEL_KIT_VERSION}.tar.gz && tar xvf ngx_devel_kit-${NGX_DEVEL_KIT_VERSION}.tar.gz
RUN wget https://github.com/openresty/lua-nginx-module/archive/v${LUA_NGINX_MODULE_VERSION}.tar.gz -O lua-nginx-module-${LUA_NGINX_MODULE_VERSION}.tar.gz && tar xvf lua-nginx-module-${LUA_NGINX_MODULE_VERSION}.tar.gz
#RUN wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$PCRE_V.tar.gz && tar -zxf pcre-$PCRE_V.tar.gz && cd pcre-$PCRE_V && ./configure && make && make install && cd -
#RUN wget http://zlib.net/zlib-$ZLIB_V.tar.gz && tar -zxf zlib-$ZLIB_V.tar.gz && cd zlib-$ZLIB_V && ./configure && make && make install && cd -
#RUN wget http://www.openssl.org/source/openssl-$OPENSSL_V.tar.gz && tar -zxf openssl-$OPENSSL_V.tar.gz && cd openssl-$OPENSSL_V && ./config --prefix=/usr && make && make install && cd -
RUN wget http://nginx.org/download/nginx-$NGINX_V.tar.gz &&  tar zxf nginx-$NGINX_V.tar.gz && cd nginx-$NGINX_V && \
    ./configure \ 
#--sbin-path=/usr/local/nginx/nginx --conf-path=/usr/local/nginx/nginx.conf --pid-path=/usr/local/nginx/nginx.pid --with-pcre=../pcre-$PCRE_V --with-zlib=../zlib-$ZLIB_V --with-http_ssl_module --with-stream --with-mail && \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=${modules_path} \
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
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-http_slice_module \
    --with-file-aio \
    --with-ipv6 \
    --with-http_v2_module \    
    --with-pcre-jit \
    --add-module=../ngx_devel_kit-$NGX_DEVEL_KIT_VERSION \
    --add-module=../lua-nginx-module-$LUA_NGINX_MODULE_VERSION \
    --with-ld-opt='-Wl,-rpath,/usr/local/lib/lua' \
    && make  &&  make install

RUN mkdir -p /var/log/nginx/ && mkdir -p  /var/cache/nginx/client_temp && mkdir -p /var/cache/nginx/proxy_temp && mkdir -p /var/cache/nginx/fastcgi_temp && mkdir -p /var/cache/nginx/uwsgi_temp && mkdir -p /var/cache/nginx/scgi_temp

RUN apt-get remove --purge --auto-remove ca-certificates wget -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo 'debconf debconf/frontend select Dialog' | debconf-set-selections \
    && rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin

RUN nginx -V

COPY index.html /etc/nginx/html/ 
COPY mime.types /etc/nginx/
COPY nginx.conf /etc/nginx/
EXPOSE 80 443 
CMD ["nginx", "-g","daemon off;"]
