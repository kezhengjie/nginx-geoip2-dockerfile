# nginx-geoip2-dockerfile
此仓库包含一个 Docker 化的 Nginx 1.28.0 版本，其中包含 ngx_http_geoip2_module (v3.4) 模块，并已预先配置为使用 MaxMind GeoLite2 国家/地区数据库来实现 Nginx 中基于地理位置的逻辑。

## 概述
此项目提供了一种简单的方法来构建和运行自定义 Nginx 服务器，该服务器可直接在其配置中执行地理位置查找。这对于以下任务非常有用：

根据用户所在国家/地区重定向用户。

设置用于日志记录或访问控制的变量。

向来自特定地区的用户提供不同的内容。

Dockerfile 使用多阶段构建来确保最终镜像精简，仅包含必要的运行时组件。

## 特性
**Nginx 1.28.0**：Nginx Web 服务器的最新稳定版本。

**GeoIP2 模块**：用于集成原生 GeoIP2 数据库的第三方 ngx_http_geoip2_module。

**GeoLite2 数据库**：包含 GeoLite2-Country.mmdb 数据库（注意：您可能需要定期更新此文件）。

**启用常用模块**：使用常用的 Nginx 模块构建，例如 SSL、HTTP/2、Real IP、Gzip 等。

## 先决条件
* **Docker**：已安装在您的本地计算机或服务器上。
* **Git**：用于克隆此代码库。

## 快速入门
### 克隆仓库：
```bash
git clone https://github.com/kezhengjie/nginx-geoip2-dockerfile
cd nginx-geoip2-dockerfile
```

### 构建 Docker 镜像：

```bash
docker build -t nginx-geoip2 .
```
### 运行容器：

```bash
docker run -d -p 80:80 --name my-nginx nginx-geoip2
```
**您的 Nginx 服务器已启用 GeoIP2 功能，现已启动。**

## 配置和使用
GeoLite2 数据库位于容器内：

```
/etc/nginx/geoip/GeoLite2-Country.mmdb
```
## Nginx 配置示例
要使用 GeoIP2 功能，您需要配置 nginx.conf 文件。以下是一个简单的示例，它根据客户端的 IP 地址设置变量 $country_code 并记录该值。

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

## 重要说明
* 数据库更新：包含的 GeoLite2-Country.mmdb 是一个静态文件。MaxMind 会定期更新其数据库。为了获得准确的结果，您应该实现一个流程来下载最新的数据库并重建镜像，或者将更新后的卷挂载到 /etc/nginx/geoip/。

* 自定义构建：如果您需要启用不同的 Nginx 模块或更改构建选项，请修改 Dockerfile 中的 ./configure 命令。

* 卷：对于生产部署，请考虑使用 Docker 卷来存储持久日志 (/var/log/nginx) 和配置。

## 许可证
本代码库中的代码遵循 MIT 许可证。请注意，其中包含的软件组件（Nginx、ngx_http_geoip2_module 和 MaxMind GeoLite2 数据库）均遵循其各自的许可证。

* **Nginx**：BSD-2-Clause 许可证
* **ngx_http_geoip2_module**：BSD-3-Clause 许可证
* **MaxMind GeoLite2 数据库**：知识共享署名-相同方式共享 4.0 国际许可证