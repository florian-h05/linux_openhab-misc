# How to setup __openHAB failover__:

## Requirements:
* main openHAB host of course
* a failover host with Docker installed, e.g. a Synology NAS
* mounted directory from failover host on main host
* Make sure, that your openHAB main host has write access to the full mount path of the failover host

## Setup the script on the main host:
* Copy the [openhab-to-failover-host.bash](openhab-to-failover-host.bash) script to your main host, e.g. to ``/opt``
* Configure [openhab-to-failover-host.bash](openhab-to-failover-host.bash):
  * line 7: set ``mountPath`` to your path, e.g. ``/path/to/docker-container``
  * line 8: set ``knx`` to ``"true"`` or ``"false"``
    * if `knx="true"`` in lines 9 + 10:
       ```shell
       knxIP='"<ip-of-your-knx-gateway>"'
       failoverHost='"<ip-of-your-failover-host"
       ```
## Setup the docker container:
* Create the directory for your container, e.g. ``openhab``
* ``cd <directory-of-container>``
* Create in this directory the folders ``conf``, ``addons`` and ``userdata``
* copy the [docker-compose.yml](docker-compose.yml) in your directory
* run the container the first time: ``sudo docker-compose up -d``
* configure your log-in in the browser at [http://ip-of-your-failover-host:15000](http://ip-of-your-failover-host:15000)
* stop the container: ``sudo docker stop openhab_openhab_1``
* protect your openHAB with a firewall: block ``15000:15001/tcp``

## Run the script on the main host:
* ``cd /opt``
* uncomment lines 64 + 65:
  ```shell
  copy_folder "/var/lib/openhab" "openhabcloud"
  copy_file "/var/lib/openhab "uuid"
  ```
* run: ``sudo bash openhab-to-failover-host.bash``
* comment lines 65 + 65 out:
  ```shell
  #copy_folder "/var/lib/openhab" "openhabcloud"
  #copy_file "/var/lib/openhab "uuid"
  ```

## Setup the script on the failover host:
* for use with basic authentication:
    * Copy the [openhab-failover_basicAuth.bash](openhab-failover_basicAuth.bash) script to your failover host, e.g. to ``/volume1/homes/<username>``
    * Configure [openhab-failover_basicAuth.bash](openhab-failover_basicAuth.bash):
        * lines 9 to 12:
            * set ``basicAuth_*`` to username and password for NGINX basic auth, you should create a new user -- only when using BasicAuth
            * set ``hostname`` to the ip-address/hostname of your main openHAB host
            * set ``openhab_token`` to a valid API token for openHAB
        * line 16: set ``container`` only when you have changed the [docker-compose.yml](docker-compose.yml), else the default is good
        * line 17: set ``notify`` to ``"true"`` or ``"false"`` to turn on/off notifications via Signal, when turned on, set ``recipient``
        * line 19: set ``path`` to the absolute path of your script, e.g. ``volume1/home/<username>``, only needed when ``notify="true"`` or you use ``--cacert``
        * line 19: set ``CA_cert``
        * line 70: set ``--cacert`` or ``-insecure`` for curl when using self-signed certs, more information in the script itself
* for use with client certificate authentication:
    * Copy the [openhab-failover_clientCert.bash](openhab-failover_clientCert.bash) script to your failover host, e.g. to ``/volume1/homes/<username>``
    * Configure [openhab-failover_clientCert.bash](openhab-failover_clientCert.bash):
        * line 10: set ``openhab_token`` to a valid API token for openHAB
        * line 14: set ``container`` only when you have changed the [docker-compose.yml](docker-compose.yml), else the default is good
        * line 15: set ``notify`` to ``"true"`` or ``"false"`` to turn on/off notifications via Signal, when turned on, set ``recipient``
        * line 197: set ``path`` to the absolute path of your script, e.g. ``volume1/home/<username>``, only needed when ``notify="true"`` or you use ``--cacert``
        * lines 18 + 19: set ``client_certName`` and ``CA_cert``
        * line 69: set ``--cacert`` or ``-insecure`` for curl when using self-signed certs, more information in the script itself
* run this script regularly, e.g. with _root's crontab_ or with _Task Scheduler_ on your Synology NAS
