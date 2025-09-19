# nginx-geoip2-dockerfile
This repository contains a Dockerized build of Nginx 1.28.0 with the ngx_http_geoip2_module (v3.4) module, pre-configured to use the MaxMind GeoLite2 Country database for geolocation-based logic within Nginx.

[README](README.md) | [中文文档](README.zh-CN.md)

## Overview 
This project provides a simple way to build and run a custom Nginx server that can perform geolocation lookups directly within its configuration. This is useful for tasks such as:

* Redirecting users based on their country.

* Setting variables for logging or access control.

* Delivering different content to users from specific regions.

The Dockerfile uses a multi-stage build to ensure the final image is lean, containing only the necessary runtime components.

## Features
**Nginx 1.28.0**: The latest stable version of the Nginx web server.

**GeoIP2 Module**: The 3rd-party ngx_http_geoip2_module for native GeoIP2 database integration.

**GeoLite2 Database**: Includes the GeoLite2-Country.mmdb database (Note: You may need to update this file regularly).

**Common Modules Enabled**: Built with common Nginx modules like SSL, HTTP/2, Real IP, Gzip, and more.

## Prerequisites
* **Docker**: Installed on your local machine or server.
* **Git**: To clone this repository.

## Quick Start
### Clone the repository:
```bash
git clone https://github.com/kezhengjie/nginx-geoip2-dockerfile  
cd nginx-geoip2-dockerfile
```

### Build the Docker image:

```bash
docker build -t nginx-geoip2 .
```
### Run the container:

```bash
docker run -d -p 80:80 --name my-nginx nginx-geoip2
```
**Your Nginx server with GeoIP2 capabilities is now running.**


## Configuration and Usage
The GeoLite2 database is located inside the container at:

```
/etc/nginx/geoip/GeoLite2-Country.mmdb
```
## Example Nginx Configuration
To use the GeoIP2 functionality, you need to configure your nginx.conf file. Here is a basic example that sets a variable $country_code based on the client's IP address and logs it.

```nginx
# Inside your http{} block
http {
    # Load the GeoIP2 database
    geoip2 /etc/nginx/geoip/GeoLite2-Country.mmdb {
        $country_code source=$remote_addr country iso_code;
    }

    # Map the country code to a variable (optional)
    map $country_code $is_international {
        default 1;
        US 0;
    }

    # Log the country code (for debugging)
    log_format main_with_geoip '$remote_addr - $remote_user [$time_local] "$request" '
                               '$status $body_bytes_sent "$http_referer" '
                               '"$http_user_agent" "$country_code"';

    access_log /var/log/nginx/access.log main_with_geoip;

    server {
        listen 80;

        # Use the variable for logic (e.g., in an if statement, proxy_set_header, etc.)
        location / {
            add_header X-Country-Code $country_code always;
            proxy_set_header X-Country-Code $country_code;
            # ... rest of your config
        }
    }
}
```

## Important Notes
* Database Updates: The included GeoLite2-Country.mmdb is a static file. MaxMind updates its databases regularly. For accurate results, you should implement a process to download the latest database and rebuild the image or mount an updated volume to /etc/nginx/geoip/.

* Custom Build: If you need to enable different Nginx modules or change build options, modify the ./configure command in the Dockerfile.

* Volumes: For a production deployment, consider using Docker volumes for persistent logs (/var/log/nginx) and configuration.

## License
The code in this repository is licensed under the MIT License. Please be aware that the software components included (Nginx, ngx_http_geoip2_module, MaxMind GeoLite2 databases) are subject to their respective licenses.

* **Nginx**: BSD-2-Clause License
* **ngx_http_geoip2_module**: BSD-3-Clause License
* **MaxMind GeoLite2 Databases**: Creative Commons Attribution-ShareAlike 4.0 International License
