FROM ubuntu:22.04 AS builder

RUN apt update && apt install gcc make libpcre3-dev zlib1g-dev libssl-dev -y
RUN apt install software-properties-common -y
RUN add-apt-repository ppa:maxmind/ppa && apt update
RUN apt install libmaxminddb0 libmaxminddb-dev mmdb-bin -y


COPY . /src
WORKDIR /src/nginx-1.28.0

RUN ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --with-http_ssl_module \                 
    --with-http_v2_module \                  
    --with-http_realip_module \              
    --with-http_addition_module \            
    --with-http_sub_module \                 
    --with-http_gunzip_module \              
    --with-http_gzip_static_module \         
    --with-http_auth_request_module \        
    --with-http_random_index_module \        
    --with-http_secure_link_module \         
    --with-http_slice_module \               
    --with-http_stub_status_module \         
    --with-stream \                          
    --with-stream_ssl_module \               
    --with-stream_realip_module \            
    --with-threads \
    --with-file-aio \
    --with-http_ssl_module \                 
    --with-cc-opt='-O2 -g'  \
    --add-module=/src/ngx_http_geoip2_module-3.4                
RUN make
RUN make install

FROM ubuntu:22.04 AS final
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /lib/x86_64-linux-gnu/libmaxminddb.so.0 /lib/x86_64-linux-gnu/libmaxminddb.so.0
RUN mkdir -p /var/log/nginx && chmod 777 /var/log/nginx && chmod 777 /var/run
RUN mkdir -p /etc/nginx/geoip && chmod 777 /etc/nginx/geoip
COPY --from=builder /src/GeoLite2-Country.mmdb /etc/nginx/geoip/GeoLite2-Country.mmdb

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

