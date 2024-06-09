# [@linuxserver](https://github.com/linuxserver)'s [SWAG](https://github.com/linuxserver/docker-swag) as reverse proxy

## General information

From [SWAG's GitHub repo](https://github.com/linuxserver/docker-swag):
```
SWAG - Secure Web Application Gateway (formerly known as letsencrypt, no relation to Let's Encrypt™) sets up an Nginx webserver and reverse proxy with php support and a built-in certbot client that automates free SSL server certificate generation and renewal processes (Let's Encrypt and ZeroSSL). It also contains fail2ban for intrusion prevention.
```

As SWAG is using the popular NGINX web server, it is highly flexible in proxying and serving, but it is more complicated to configure than [Traefik](https://traefik.io/).

This guide is a basic setup for SWAG with mTLS-based client authentication.

## Preparations

Create the Docker network _traefik_: `sudo docker network create traefik`
  
Download the [docker-compose file](docker-compose.yml) and create the `config` folder on your host.

## Setup

Get a domain name from [DuckDNS](https://duckdns.org).
Set up the DynDNS service in your router or on your server.

Do not forget to open the following ports:
- Outside port `80` to `8080` of your Docker host.
- Outside port `443` to `8443` of your Docker host.

Edit the docker-compose file's environment variables:

- `URL` to your DuckDNS domain.
- `DUCKDNSTOKEN` to your DuckDNS token.

Finally, run ```sudo docker-compose up -d```.

After SWAG has started the first time, open the *config/nginx* folder:
- Copy [mtls.conf](config/nginx/mtls.conf) to the root.
- Place the required files in the [mTLS](config/nginx/mTLS) folder.
- Add the mTLS configuration to the `default.conf` file in the `site-confs` folder:
    ```nginx
    # Client Certificate Authentication
    include /config/nginx/mtls.conf;
    ```
- Copy [grafana.subdomain.conf] to the `proxy-confs` folder.

For further proxying, have a look at the `.conf.sample` files in `config/nginx/proxy-confs`.
