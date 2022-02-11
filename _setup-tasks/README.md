# Setup tasks and scripts

## Table Of Contents
***
- [Table Of Contents](#table-of-contents)
- [General information](#general-information)
- [Windows Subsystem for Linux](#windows-subsystem-for-linux)
  - [Backup distribution](#backup-distribution)
  - [Setup for Development](#setup-for-development)

## General information
***
These scripts provide fast setup for specific environments.

## Windows Subsystem for Linux
***
```

The Windows Subsystem for Linux lets developers run a GNU/Linux environment -- including most 
command-line tools, utilities, and applications -- directly on Windows, unmodified, without 
the overhead of a traditional virtual machine or dualboot setup.
```
*- Microsoft at [https://docs.microsoft.com/en-us/windows/wsl/about](https://docs.microsoft.com/en-us/windows/wsl/about)*

For available commands, visit the [Basic commands for WSL](https://docs.microsoft.com/en-us/windows/wsl/basic-commands) docs from Microsoft.
### Backup distribution
- Navigate to your folder where you want to store the backup.
- List installed distributions: ``wsl -l -v``
- Export/Backup a distribution: ``wsl --export <distribution> <filename>.tar``

### Setup for Development
[setup-ubuntu-wsl.bash](setup-ubuntu-wsl.bash) installs and sets up all my development tools for the Windows Subsystem for Linux Ubuntu.

To install the WSL, please follow the [Install WSL](https://docs.microsoft.com/en-us/windows/wsl/install) docs from Microsoft.
