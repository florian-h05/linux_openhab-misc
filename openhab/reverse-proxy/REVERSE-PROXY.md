# How to setup NGINX reverse proxy for openHAB:

## Two options for authorization:
* [BasicAuth](#BasicAuth) with username and password
* [client certificate](#client-certificate) auth with a certificate for each client

Client certificate auth is more secure than BasicAuth, but it is more work to use it in daily life.
***
## BasicAuth

NGINX [configuration file](/openhab/reverse-proxy/openhab-basicauth) for openHAB.
When using this file, you __must change__:
* line 14: ``<servername>`` to your servername
* line 51: ``<ip>`` to the ip which should access the log viewer

First, run ``sudo apt install apache2-utils``.

Then, adding and removing users:
* create the authentication file: ``sudo htpasswd -c /etc/nginx/.htpasswd-openhab username``
* add new users: ``sudo htpasswd /etc/nginx/.htpasswd-openhab username``
* remove users: ``sudo htpasswd -D /etc/nginx/.htpasswd-openhab username``

Next, please setup the ufw firewall, otherwise your access control has no sense.

***
## client certificate

NGINX [configuration file](/openhab/reverse-proxy/openhab-clientcert) for openHAB. When using this file, you __must change__:
* line 14: ``<servername>`` to your servername
* line 24: ``<ca>`` to the name or path of the certificate of your CA for client certificate authentication
* line 25: ``<crl>`` to the name ot path of the certificate revocation list of your CA for client certificate authentication

### Further setup:
* Work in a directory you created for the next steps.
* You need _openssl_: ``sudo apt install openssl``
* Create the Certificate Authority:
  * Generate the key: ``openssl genrsa -des3 -out ca.key 4096``
  * Create a CA Certificate: ``openssl req -new -x509 -days 730 -key ca.key -out ca.crt``
    * You will be asked a few questions: answer all except the _common name (CN)_ and the email
* ### Create a Client Certificate:
  * Create a key: ``openssl genrsa -des3 -out user.key 4096``
  * Create a _Certificate Signing Request (CSR)_: ``openssl req -new -key user.key -out user.csr``
    * You will be asked a few questions: answer _common name (CN)_ and the email.
  * Sign the CSR: ``openssl x509 -req -days 365 -in user.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out user.crt``

* ### Create a _PKCS #12 (PFX)_ bundle for your client:
  * ``openssl pkcs12 -export -out user.pfx -inkey user.key -in user.crt -certfile ca.crt``, supply the export password.


* Renewing a certificate: Just run the command you used to generate it. If you need to see what you entered in the old certificate, you can run: ``openssl -x509 -in ca.crt -noout -text``

* You can also use software like [XCA](https://hohnstaedt.de/xca/) for certificate management. 

### Install the client certificates on your clients:
* Copy the _PKCS #12 (PFX)_ bundles to your clients.
* For the iOS openHAB app, rename _client.p12_ to _client.ohp12_.