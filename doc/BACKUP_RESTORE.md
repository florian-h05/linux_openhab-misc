# Backup and restore script

## How to setup:
* download [backup_restore.bash](../backup_restore.bash)
* eventually, mount a network share on your system as backup target

## How to use:
* you must run it as root or with sudo
* ``sudo bash backup_restore.bash`` with following arguments:
  ```shell
  -m=* --mode=*               program mode, available: backup_all, backup_single, restore_all, restore_single
  -d=* --directory=*          directory for the backup archive
  -s=* --single-command=*     command for *_single modes, please use --help-single
  -f=* --file-name=*          name of the backup archive (only for restore, with .tar.gz)
  -i=* --install=*            install additional software, please use --help-single
  ```

## How to setup _backup_all_ and _restore_all:
* comment or uncomment single commands to enable or disable in __lines 480-528__ of [backup_restore.bash](../backup_restore.bash)

### Examples:
```shell
sudo bash backup_restore.bash -m=backup_all -d=/home
sudo bash backup_restore.bash -m=restore_all -d=/home -f=backup_all_2021-05-24_17-48-12.tar.gz``
sudo bash backup_restore.bash -m=backup_single -s=nginx_backup -d=/home``
sudo bash backup_restore.bash -m=restore_single -s=nginx_restore -d=/home -f=backup_all_2021-05-24_17-48-12.tar.gz
```