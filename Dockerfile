FROM buildpack-deps:stretch

LABEL maintainer="Alexandre Simoes <al.simoes@outlook.com"


# Install dependencies
RUN apt-get update && \ 
    apt-get install -y curl build-essential libpcre3-dev libpcre++-dev zlib1g-dev libcurl4-openssl-dev libssl-dev   && \
    apt-get -y install nginx   && \
    apt-get -y install git   && \
    apt-get -y remove nginx   && \
    rm -rf /var/lib/apt/lists/* 

# Download and decompress Nginx nad Ngnix rtmp
RUN mkdir -p /usr/src/nginx && \
    cd /usr/src/nginx && \
    git clone git://github.com/arut/nginx-rtmp-module.git  && \
    wget http://nginx.org/download/nginx-1.15.0.tar.gz && \
    tar xzf nginx-1.15.0.tar.gz && \
    cd nginx-1.15.0 && \
    mkdir -p /var/www 
  



# Build and install Nginx
# The default puts everything under /usr/local/nginx, so it's needed to change
# it explicitly. Not just for order but to have it in the PATH
RUN cd  /usr/src/nginx/nginx-1.15.0 && \ 
            ./configure --prefix=/var/www  \  
            --sbin-path=/usr/local/sbin/nginx  \  
            --conf-path=/etc/nginx/nginx.conf  \  
            --pid-path=/var/run/nginx.pid  \  
            --error-log-path=/var/log/nginx/error.log  \  
            --http-log-path=/var/log/nginx/access.log  \  
            --with-http_ssl_module  \  
            --without-http_proxy_module  \  
            --add-module=/usr/src/nginx/nginx-rtmp-module && \
make && \
make install

# Set up config file
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 1935
CMD ["nginx", "-g", "daemon off;"]
