# _tmpfs_ for _/var/log_ on Raspberry Pi

Continous writing to an SD card can reduce the lifetime of the card. To reduce the load on the SD card, _var/log_ can be stored in the RAM with _tmpfs_.

## How to setup:

* Create the script: ```sudo nano /etc/init.d/varlog``` and paste the content of [varlog](etc/init.d/varlog)
* Make it executable: ```sudo chmod +x /etc/init.d/varlog```
* Execute the script the first time to save _/var/log_: ```sudo /etc/init.d/varlog stop```
* Setup _/var/log_ as _tmpfs_ in __/etc/fstab__: ```sudo nano /etc/fstab```
  ```
  tmpfs /var/log tmpfs defaults,noatime,nodiratime size=70M 0 0
  ```
* Create the _systemd service_ configuration (to automatically execute): ```sudo nano /etc/systemd/system/varlog.service``` and paste the content of [varlog.service](etc/systemd/system/varlog.service)
* Enable the service: ```sudo systemctl enable varlog.service```