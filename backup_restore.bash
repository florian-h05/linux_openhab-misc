#!/bin/bash
# Script: backup_restore.bash
# Purpose: Backup all given configuration and user data
# How it works: it copies the given files and folders to a temporary folder, then it is compressed to the backup target
# Author: Florian Hotze

### What it backs up:
    # - data in /var/www/html
    # - sbfspot configuration
    # - /etc/nginx
    # - /etc/ufw
    # - /etc/cron-apt
    # - /etc/ssh
    # - /etc/postfix
    # - /etc/samba/smb.conf
		# - /etc/fail2ban
    # - /etc/fstab
    # - /usr/lib/tmpfiles.d/var.conf
    # - crontab
    # - small files:
    #       - /etc/profile
    #       - /opt/sshlogin.sh
    #       - /opt/signal-cli-rest-api_client.bash
    # - /etc/telegraf
    # - user home
#

# backupPath is set via command-line args
# fileName is set via command-line args for restore and automatically generated for backup
backupPath=
fileName=


### Variables for internal use
    #
    #
    cachePathLocation=/tmp/cacheFolder
    cachePath=/tmp/cacheFolder/backup

    # all dates are formatted as YYYY-MM-DD
    # import today's date
    YMD=$(date +"%F")
    # import actual time
    TIME=$(date +"%H-%M-%S")

    # colors for shell
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    reset=$(tput sgr0)

### cacheFolder generation for backup
    #
    #
    ## check if the directory exists or create it
    # call it with cacheFolder "/path/to/folder"
    cacheFolder() {
        FOLDER="$cachePath""$1"
        if [ ! -d "${FOLDER}" ]; then
            echo "${FOLDER} not found, create it" | tee -a "$cachePath"/log.txt
            mkdir -p "${FOLDER}"
        fi
    }

### sourceFolder generation for restore
    #
    #
    ## check if the directory exists or create it
    # call it with sourceFolder "/path/to/folder"
    sourceFolder() {
        FOLDER="$1"
        if [ ! -d "${FOLDER}" ]; then
            echo "${FOLDER} not found, create it"
            mkdir -p "${FOLDER}"
        fi
    }

### Backup functions
    #
    #
    ## check for a file and backup it
    # call it with backup_file "/path/to/file" "filename.type"
    backup_file() {
        cacheFolder "$1"
        file="${1}/${2}"
        if [ -f "${file}" ]; then
            echo "${green}SUCCESS:${reset} ${file} found" | tee -a "$cachePath"/log.txt
            if sudo cp "${file}" "$cachePath""${file}"; then echo "${green}SUCCESS:${reset} copied ${file}" | tee -a "$cachePath"/log.txt; else echo "${red}ERROR:${reset} copy of ${file} failed!" | tee -a "$cachePath"/log.txt; fi
        else
            echo "${red}ERROR:${reset} ${file} not found" | tee -a "$cachePath"/log.txt
        fi
    }
    ## check for a folder and backup it
    # call it with backup_folder "/path/to/folder" "foldername"
    # you can not backup folders on the system root, e.g. backing up "/home" is not possible, but "/home/user" is possible
    backup_folder() {
        cacheFolder "$1"
        folder="${1}/${2}"
        if [ -d "${folder}" ]; then
            echo "${green}SUCCESS:${reset} ${folder} found" | tee -a "$cachePath"/log.txt
            if sudo cp -r "${folder}" "$cachePath""${folder}"; then echo "${green}SUCCESS:${reset} copied ${folder}" | tee -a "$cachePath"/log.txt; else echo "${red}ERROR:${reset} copy of ${folder} failed!" | tee -a "$cachePath"/log.txt; fi
        else
            echo "${red}ERROR:${reset} ${folder} not found" | tee -a "$cachePath"/log.txt
        fi
    }

### Restore functions
    #
    #
    ## check for a file in backup and restore it
    # callit it with restore_file "/path/to/file" "filename.type"
    restore_file() {
        sourceFolder "$1"
        file="${1}/${2}"
        # check for file in backup
        if [ -f "$cachePath""${file}" ]; then
            echo "${green}SUCCESS:${reset} ${file} found in backup"
            # check for file on system
            if [ -f "${file}" ]; then
                # if file already on system, ask to delete it
                echo "Restoring ${file} config overwrites everything!!"
                echo "Do you really want to continue (y/n)?"
                read -r choice
                case "$choice" in 
                    y|Y ) echo "yes"
                        sudo rm "${file}"
                        if sudo cp "$cachePath""${file}" "${file}"; then echo "${green}SUCCESS:${reset} restored ${file}"; else echo "${red}ERROR:${reset} restore of ${file} failed!"; fi;;
                    n|N ) echo "no";;
                    * ) echo "invalid";;
                esac
            elif [ ! -f "${file} " ]; then
                if sudo cp "$cachePath""${file}" "${file}"; then echo "${green}SUCCESS:${reset} restored ${file}"; else echo "${red}ERROR:${reset} restore of ${file} failed!"; fi
            fi
        else
            echo "${red}ERROR:${reset} $cachePath${file} not found in backup"
        fi
    }
    restore_folder() {
        sourceFolder "$1"
        folder="${1}/${2}"
        # check for folder in backup
        if [ -d "$cachePath""${folder}" ]; then
            echo "${green}SUCCESS:${reset} ${folder} found in backup"
            # check for folder on system
            if [ -d "${folder}" ]; then
                # if folder already on system, ask to delete it
                echo "Restoring ${folder} config overwrites everything!!"
                echo "Do you really want to continue (y/n)?"
                read -r choice
                case "$choice" in 
                    y|Y ) echo "yes"
                        sudo rm -r "${folder}"
                        if sudo cp -r "$cachePath""${folder}" "${folder}"; then echo "${green}SUCCESS:${reset} restored ${folder}"; else echo "${red}ERROR:${reset} restore of ${folder} failed!"; fi;;
                    n|N ) echo "no";;
                    * ) echo "invalid";;
                esac
            fi
        elif [ ! -d "${folder}" ]; then
            if sudo cp -r "$cachePath""${folder}" "${folder}"; then echo "${green}SUCCESS:${reset} restored ${folder}"; else echo "${red}ERROR:${reset} restore of ${folder} failed!"; fi
        else
            echo "${red}ERROR:${reset} $cachePath${folder} not found in backup"
        fi
    }

### Packing and unpacking the archive
    #
    #
    ## pack the .tar.gz
    # call it with pack
    pack() {
        # declare filename
        file="${backupPath}/${fileName}"
        echo "Packing as .tar.gz archive ...." | tee -a "$cachePath"/log.txt
        # check for archive with same-name and delete it
        if test -f "${file}"; then
            sudo rm -r "${file}"
        fi
        # compress cachePath
        if ! tar -czf "${file}".tmp -C "$cachePathLocation" backup ; then echo "${red}ERROR:${reset} Compressing as .tar.gz.tmp failed!" | tee -a "$cachePath"/log.txt; return 1; fi
        # after finished with packing, rename
        if mv "${file}".tmp "${file}"; then echo "${green}SUCCESS:${reset} Backup file is ${file}" | tee -a "$cachePath"/log.txt; else echo "${red}ERROR:${reset} Backup file not created." | tee -a "$cachePath"/log.txt;fi
        rm -r "$cachePath"
    }
    ## unpack the .tar.gz
    # call it with unpack
    # you could limit unpacking to a given file or directory: unpack "file.txt /home/folder"
    unpack() {
        # declare filename
        file="${backupPath}/${fileName}"
        echo "Backup archive is ${file}"
        # check for backup file
        if test -f "${file}"; then
            echo "Unpacking the .tar.gz archive ...."
            # extract from file to cachePath
            # $1 can select which dir or file to extract
            if ! tar -C "$cachePathLocation" -zxf "${file}" "$1"; then echo "${red}ERROR:${reset} Unpacking .tar.gz failed!"; return 1; else echo "${green}SUCCESS:${reset} Unpacked the backup."; fi
        else
            echo  "${red}ERROR:${reset} Backup not found"
        fi
    }

### Functions for making the individual backups
    openhab_backup () {
        # backup openhab data with the integrated backup tool
        sudo systemctl stop openhab
        if sudo openhab-cli backup --full "$cachePath"/openhab-backup_"$YMD"; then echo "${green}SUCCESS:${reset} backed up openHAB."  >> "$cachePath"/log.txt; else echo "${red}ERROR:${reset} backup of openHAB failed!"  >> "$cachePath"/log.txt; fi
        sudo systemctl start openhab
    }

    html_backup() {
        backup_folder "/var/www" "html"
    }


    sbfspot_backup() {
        backup_file "/usr/local/bin/sbfspot.3" "SBFspot.cfg"
    }


    nginx_backup() {
        sudo systemctl stop nginx
        backup_folder "/etc" "nginx"
        sudo systemctl start nginx
        ssl_backup
    }

    ssl_backup() {
        backup_folder "/etc" "ssl"
    }


    ufw_backup() {
        backup_folder "/etc" "ufw"
    }


    cronapt_backup() {
        backup_folder "/etc" "cron-apt"
    }


    sshd_backup() {
        backup_folder "/etc" "ssh"
    }


    postfix_backup() {
        backup_folder "/etc" "postfix"
    }


    samba_backup() {
        backup_folder "/etc" "samba"
    }

    fail2ban_backup() {
        backup_folder "/etc" "fail2ban"
    }


    fstab_backup() {
        backup_file "/etc" "fstab"
    }


    tmpfilesdVar_backup() {
        backup_file "/usr/lib/tmpfiles.d" "var.conf"
    }


    crontab_backup() {
        backup_folder "/var/spool/cron" "crontabs"
    }


    smallFiles_backup() {
        # for backing up:
        # /etc/profile  /opt/sshlogin.sh /opt/signal-cli-rest-api_client.sh
        backup_file "/etc" "profile"
        backup_file "/opt" "sshlogin.sh"
        backup_file "/opt" "signal-cli-rest-api_client.bash"
    }


    telegraf_backup() {
        backup_folder "/etc" "telegraf"
    }

    userhome_backup() {
        backup_folder "/home" "openhabian"
    }


### Functions for restoring individually or installing software
    openhab_restore () {
        # restore bash login for user openhab
        # needed by executeCommandLine in openhab rules
        sudo usermod --shell /bin/bash openhab

        sudo systemctl stop openhab
        sudo openhab-cli restore "$cachePath"/openhab-backup_*.zip
        sudo systemctl start openhab
    }

    html_restore() {
        restore_folder "/var/www" "html"
        sudo chmod -R 777 /var/www/html/pv
    }

    sbfspot_restore() {
        if ! command -v /usr/local/bin/sbfspot.3/SBFspot -?; then
            sbfspot_install
        fi
        restore_file "/usr/local/bin/sbfspot.3" "SBFspot.cfg"
    }

    sbfspot_install() {
        echo "Installing SBFspot from source ..."
        echo "You do not need to set anything as you restore your old config."
        echo "Ready to continue (y/n)?"
        read -r choice
        case "$choice" in 
            y|Y ) echo "yes"
                curl -s https://raw.githubusercontent.com/sbfspot/sbfspot-config/master/sbfspot-config | sudo bash
                echo "SBFspot installed.";;
            n|N ) echo "no";;
            * ) echo "invalid";;
        esac
    }

    nginx_restore() {
        if ! command -v nginx -t; then
            echo "No nginx installation found on your system!"
            echo "Installing nginx ..."
            sudo apt update
            if sudo apt install nginx apache2-utils openssl; then echo "Nginx installed."; else echo "${red}ERROR:${reset} installing nginx"; fi
        else
            sudo systemctl stop nginx
        fi
        restore_folder "/etc" "nginx"
        sudo systemctl enable nginx
        if ! sudo nginx -t; then echo "${red}ERROR:${reset} nginx configuration not valid"; else sudo systemctl start nginx; fi
    }

    ssl_restore() {
        restore_folder "/etc" "ssl"
    }

    ufw_restore() {
        if ! command -v ufw; then
            echo "No ufw installation found on your system!"
            if sudo apt install ufw; then echo "ufw installed."; else echo "${red}ERROR:${reset} installing ufw"; fi
        fi
        restore_folder "/etc" "ufw"
        sudo ufw enable 
        sudo ufw default allow incoming
        sudo ufw reload
    }

    cronapt_restore() {
        if ! command -v cron-apt; then
            echo "No cron-apt installation found on your system!"
            if sudo apt install cron-apt; then echo "cron-apt installed."; else echo "${red}ERROR:${reset} installing cron-apt"; fi
        fi
        restore_folder "/etc" "cron-apt"
        if ! sudo cron-apt -s; then echo "${red}ERROR:${reset} cron-apt not working"; fi
    }

    sshd_restore() {
        restore_folder "/etc" "ssh"
    }

    postfix_restore() {
        if ! command -v postfix; then
            echo "No postfix installation found on your system!"
            if sudo apt install postfix libsasl2-modules bsd-mailx; then echo "postfix installed."; else echo "${red}ERROR:${reset} installing postfix"; fi
        else
            sudo systemctl stop postfix
        fi
        restore_folder "/etc" "postfix"
        sudo systemctl enable postfix
        sudo systemctl start postfix
    }

    samba_restore() {
        restore_folder "/etc" "samba"
        sudo systemctl reload smbd
    }

    fail2ban_restore() {
        if ! command -v fail2ban-client; then
            echo "No fail2ban installation found on your system!"
            if sudo apt install fail2ban; then echo "fail2ban installed."; else echo "${red}ERROR:${reset} installing fail2ban"; fi
        else
            sudo systemctl stop fail2ban
        fi
        restore_folder "/etc" "fail2ban"
        sudo systemctl enable fail2ban
        sudo systemctl start fail2ban
    }

    fstab_restore() {
        echo "${red}INFO:${reset} Please restore /etc/fstab manually!"
        echo "Automatic restore could damage your filesystem!"
    }

    tmpfilesdVar_restore() {
        echo "${red}INFO:${reset} Please restore /usr/lib/tmpfiles.d/var.conf manually!"
        echo "Automatic restore could damage your applications' logs!"
    }

    crontab_restore() {
        backup_folder "/var/spool/cron" "crontabs"
    }

    smallFiles_restore() {
        restore_file "/etc" "profile"
        restore_file "/opt" "sshlogin.sh"
        restore_file "/opt" "signal-cli-rest-api_client.bash"
    }

    telegraf_restore() {
        if ! command -v telegraf; then
            echo "No telegraf installation found on your system!"
            if telegraf_install; then echo "telegraf installed."; else echo "${red}ERROR:${reset} installing telegraf"; fi
        else
            sudo systemctl stop telegraf
        fi
        restore_folder "/etc" "telegraf"
        sudo systemctl enable telegraf
        sudo systemctl start telegraf
    }

    telegraf_install() {
        # Before adding Influx repository, run this so that apt will be able to read the repository.
        sudo apt-get update && sudo apt-get install apt-transport-https
        # Add the InfluxData key
        wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -  
        # shellcheck disable=SC1091
        source /etc/os-release  
        test "$VERSION_ID" = "7" && echo "deb https://repos.influxdata.com/debian wheezy stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
        test "$VERSION_ID" = "8" && echo "deb https://repos.influxdata.com/debian jessie stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
        test "$VERSION_ID" = "9" && echo "deb https://repos.influxdata.com/debian stretch stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
        test "$VERSION_ID" = "10" && echo "deb https://repos.influxdata.com/debian buster stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
        sudo apt  update && sudo apt install telegraf
    }

    speedtest_install() {
        sudo apt install apt-transport-https gnupg1 dirmngr
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
        echo "deb https://ookla.bintray.com/debian generic main" | sudo tee  /etc/apt/sources.list.d/speedtest.list
        sudo apt update
        sudo apt install speedtest
    }

    userhome_restore() {
        restore_folder "/home" "openhabian"
    }

restore_all() {
    echo "Starting restore ...."
    #openhab_restore
    html_restore
    sbfspot_restore
    ssl_restore
    nginx_restore
    ufw_restore
    postfix_restore
    cronapt_restore
    sshd_restore
    fstab_restore
    samba_restore
    fail2ban_restore
    tmpfilesdVar_restore
    crontab_restore
    smallFiles_restore
    telegraf_restore
    userhome_restore
    speedtest_install
    echo "Done with restore."
    echo "Please restore openHAB manually."
    echo "Please setup system with openhabian-config."
}

backup_all() {
    echo "Starting backup ...."  | tee -a "$cachePath"/log.txt
    #openhab_backup
    html_backup
    sbfspot_backup
    nginx_backup
    ssl_backup
    ufw_backup
    cronapt_backup
    sshd_backup
    postfix_backup
    samba_backup
    fail2ban_backup
    fstab_backup
    tmpfilesdVar_backup
    crontab_backup
    smallFiles_backup
    telegraf_backup
    userhome_backup
    echo "Done with backup."  | tee -a "$cachePath"/log.txt
    echo "Please backup openHAB manually."  | tee -a "$cachePath"/log.txt
}

## what is build:
#
# run a single backup command and the cachePath is build automatically


help() {
    echo "Welcome to the backup & restore tool."
    echo "Written by: Florian Hotze"
    echo "Valid command line args are:"
    echo "  -m=* --mode=*               program mode, available: backup_all, backup_single, restore_all, restore_single"
    echo "  -d=* --directory=*          directory for the backup archive"
    echo "  -s=* --single-command=*     command for *_single modes, please use --help-single"
    echo "  -f=* --file-name=*          name of the backup archive"
    echo "  -i=* --install=*            install additional software, e.g. telegraf_install, speedtest_install, sbfspot_install"
}

help_single() {
    echo "Commands for *_single modes are:"
    echo "
        openhab_backup
        html_backup
        sbfspot_backup
        nginx_backup
        ssl_backup
        ufw_backup
        cronapt_backup
        sshd_backup
        postfix_backup
        samba_backup
        fail2ban_backup
        fstab_backup
        tmpfilesdVar_backup
        crontab_backup
        smallFiles_backup
        telegraf_backup
        userhome_backup
    "
    echo "Commands for *_single modes are:"
    echo "
        openhab_restore
        html_restore
        sbfspot_restore
        ssl_restore
        nginx_restore
        ufw_restore
        postfix_restore
        cronapt_restore
        sshd_restore
        fstab_restore
        samba_restore
        fail2ban_restore
        tmpfilesdVar_restore
        crontab_restore
        smallFiles_restore
        telegraf_restore
        userhome_restore
    "
}

check_backupPath() {
    if [ -d "${backupPath}" ]; then
        echo "${green}SUCCESS:${reset} ${backupPath} found"
    else
        echo "${red}ERROR:${reset} ${backupPath} not found"
        echo "Please provide -d=* or --directory=*"
        exit
    fi
}

check_restore_fileName() {
    file="${backupPath}/${fileName}"
    if [ "${fileName}" = "" ]; then
        echo "Please provide -f=* or --file-name=*"
        exit
    else
        if [ -f "${file}" ]; then
            echo "${green}SUCCESS:${reset} ${file} found"
        else
            echo "${red}ERROR:${reset} ${file} not found"
            echo "Please provide -f=* or --file-name=*"
            echo "Please provide -d=* or --directory=*"
            exit
        fi
    fi
}

generate_fileName() {
    if [ "$mode" = "backup_all" ]; then
        fileName="$mode"_"$YMD"_"$TIME".tar.gz
    elif [ "$mode" = "backup_single" ]; then
        fileName="$singleCommand"_"$YMD".tar.gz
    fi
    echo "Generated file name: ${fileName}"  | tee -a "$cachePath"/log.txt
}

check_singleCommand() {
    if [ "$singleCommand" = "" ]; then
        echo "Please provide -s=* or --single-command=*"
        exit
    fi
}

get_unpackPath() {
    declare -A path
    #contacts' numbers go into this array
    path=(
        [openhab_restore]="backup" 
        [html_restore]="backup/var/www/html"
        [sbfspot_restore]="backup/usr/local/bin/sbfspot.3"
        [nginx_restore]="backup/etc/nginx"
        [ssl_restore]="backup/etc/ssl"
        [ufw_restore]="backup/etc/ufw"
        [cronapt_restore]="backup/etc/cron-apt"
        [sshd_restore]="backup/etc/ssh"
        [postfix_restore]="backup/etc/postfix"
        [samba_restore]="backup/etc/samba"
        [fstab_restore]="backup/etc"
        [tmpfilesdVar_restore]="backup/usr/lib/tmpfiles.d"
        [crontab_restore]="backup/var/spool/cron"
        [smallFiles_restore]="backup"
        [telegraf_backup]="backup/etc/telegraf"
        [userhome_restore]="backup/home"
    )
    unpackPath="${path[$singleCommand]}"
}

### Loop through arguments and process them
# m mode (backup_all, restore_all, backup_single, restore_single)
# d directory (where the backup archive is stored)
# s single-command (for *_single mode, e.g. ufw_backup)
# r restore-date (only for restore_* mode, e.g. 2021-05-15)
# i install (for install speedtest_install)
for arg in "$@"
do
    case $arg in
        -m=*|--mode=*)
        mode="${arg#*=}"
        ;;
        -d=*|--directory=*)
        backupPath="${arg#*=}"
        ;;
        -s=*|--single-command=*)
        singleCommand="${arg#*=}"
        ;;
        -f=*|--file-name=*)
        fileName="${arg#*=}"
        ;;
        -i=*|--install=*)
        install="${arg#*=}"
        ;;
        -h|--help)
        help
        ;;
        --help-single)
        help_single
        ;;
        *)
        echo "Please provide command line args. Help: -h --help"
        ;;
    esac
done


if [ "$mode" = "backup_all" ]; then
    check_backupPath
    generate_fileName
    mkdir -p "$cachePath"
    backup_all
    pack
elif [ "$mode" = "restore_all" ]; then
    check_restore_fileName
    mkdir -p "$cachePath"
    unpack ""
    restore_all
    echo "$cachePath not deleted."
    echo "Please delete it manually."
elif [ "$mode" = "backup_single" ]; then
    check_backupPath
    check_singleCommand
    generate_fileName
    mkdir -p "$cachePath"
    "$singleCommand"
    pack
elif [ "$mode" = "restore_single" ]; then
    check_restore_fileName
    check_singleCommand
    mkdir -p "$cachePath"
    # unpack only the path for the single command
    get_unpackPath
    unpack "$unpackPath"
    "$singleCommand"
    echo "$cachePath not deleted."
    echo "Please delete it manually."
elif [ "$install" != "" ]; then
    "$install"
else
    echo "Please provide command line args. Help -h or --help"
fi
