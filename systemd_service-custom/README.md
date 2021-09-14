# _systemd .service_ files

A collection of custom _systemd service_ configuration with decreased exposure levels.

***
## Table Of Contents
- [Table Of Contents](#table-of-contents)
- [1. General information](#1-general-information)
  - [1.1. How to use](#11-how-to-use)
- [2. NGINX](#2-nginx)


## 1. General information
***

The goal of these _.service_ files is to provide more sandboxing than with the default _.service_ from the installation repo. As I am only a hobby Linux user and no Linux administrator or professional, I only understand the options I use to a degree. 


### 1.1. How to use

Run ```sudo systemctl edit <servicename>``` for _override.conf_ or ```sudo systemctl edit --full <servicename>``` for the main configuration. _override.conf_ is not used by all services.

Further information for how to use is on top of each _.service_ or _override.conf_ file.


## 2. NGINX
***

Setup steps:
* Create user _nginx_: ```sudo useradd nginx```
* Create group _acme_: ```sudo groupadd acme```
* Add _nginx_ to _acme_: ```sudo usermod -a -G acme nginx```
* Change owner of TLS certificate private keys: ```sudo chown nginx:acme <key-file>```
* Change permissions for TLS certificate private keys: ```sudo chmod 640 <key-file>```
* Change owner of __/var/lib/nginx__: ```sudo chown -R nginx:nginx /var/lib/nginx```
* Change permission for __/var/lib/nginx__: ```sudo chmod -R 770 /var/lib/nginx```
* Adjust the _nginx_ configuration __/etc/nginx/nginx.conf__:
  ```
  # user www-data;
  daemon off;
  pid /run/nginx/nginx.pid;
  ```
* Stop _nginx_: ```sudo systemctl stop nginx```
* Access your _nginx.service_ file: ```sudo systemctl edit --full nginx``` and replace the content with [_nginx.service_](etc/systemd/system/nginx.service)
* Reload system manager configuration: ```sudo systemctl daemon-reload```
* Start _nginx_: ```sudo systemctl start nginx```
* Check _syslog_ for _nginx_: ```tail /var/log/syslog```
