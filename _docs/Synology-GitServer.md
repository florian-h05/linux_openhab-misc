# Install Git Server on Synology NAS

This guide shows you how to install the git server on your NAS and access your repos with pubkey auth.

***
## Table Of Contents
- [Table Of Contents](#table-of-contents)
- [Install ``Git Server`` Package](#install-git-server-package)
- [Allow pubkey authentication](#allow-pubkey-authentication)
- [Access the ``Git Server``](#access-the-git-server)

***
## Install ``Git Server`` Package

- Install the ``Git Server`` package from Synology Package Manager.
- Enable SSH.
- Create a new Shared Folder, e.g. ``git``.
- Create a new user to access your repositories, e.g. ``git``.
  - Password should be strong, as you don`t have to remember it.
  - Give this user only access to the Shared Folder you created (e.g. ``git``) and the ``homes`` folder.
- SSH into your NAS as the admin user and initialize a new repo.
  ```shell
  mkdir new-repo
  cd new-repo
  git init --bare --shared --initial-branch=main
  ```
- Log in to DSM as the admin, open Git Server and allow the user you created (e.g. ``git``) access.
- 

***
## Allow pubkey authentication

- SSH into your NAS as the admin user.
- Add the *authorized_keys* file for your user (e.g. ``git``) and set all required permissions:
  ```shell
  chmod 0755 /volume1/homes/git # Synology NAS requires that (normally not required).
  cd /volume1/homes/git
  mkdir .ssh
  chmod 0711 .ssh
  touch .ssh/authorized_keys
  chmod 0600 ssh/authorized_keys # Required for all ssh servers.
  chown -R git:users .ssh
  ```
- Add your ssh-keys to the *authorized_keys* file.
- Configure the SSH Server for pubkey authentication: edit ``/etc/ssh/sshd_config``:
  - Set *PubkeyAuthentication* to yes.
  - Uncomment out *AuthorizedKeysFile .ssh/authorized_keys* to enable it.
  - **Make sure, that *PasswordAuthentication* is set to yes.** Otherwise you could lock yourself out.
- Restart the SSH Server with ``sudo systemctl restart sshd``.

***
## Access the ``Git Server``

You can access push/pull from hosts which ssh key is added to *authorized_keys*.

Example:
You have initialized the repo called new-repo.
Access it with the git URL ``ssh://git@<nas-ip>:<ssh-port>/volume1/git/new-repo``.