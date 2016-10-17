#!/bin/bash

#arg1 output path

#if database is password protected then create a file ~/.my.cnf with privilegies 600 and with the following content:
#[mysqldump]
#user=mysqluser
#password=secret


mountOutputPath="/var/systembackup/mountOutput.txt"
rsyncOutputPath=$1
#rsyncOutputPath="/mnt/STORAGE_ee7e0/owncloud_backup"
drive="STORAGE_ee7e0"
date=$(date +\%Y\%m\%d)

> $mountOutputPath
mount | grep $drive > $mountOutputPath

#echo Checking if $drive is mounted...
if [ ! -s $mountOutputPath ]
then
        #echo $drive is not mounted. I'll give it a shot...
        mount --all
        mount | grep $drive > $mountOutputPath
        if [ ! -s $mountOutputPath ]
        then
                #echo Still can't mount. Check connection... Bye.
                exit
        fi
fi
#echo Kill server
service apache2 stop
sleep 10
#echo $drive is mounted... Executing rsync command.
rsync -aAxXq --exclude-from=/var/rsync/rsyncExclusions.list /* $rsyncOutputPath/owncloud_rsync_temp
#echo Putting it in a tar...
tar -cvpzf $rsyncOutputPath/owncloud_backup_$date.tar.gz $rsyncOutputPath/owncloud_rsync_temp
#echo Syncing and backuping data directory...
rsync -aAxXq /media/www/owncloud/data/ $rsyncOutputPath/owncloud_rsync_data
#echo Taking a dump of mysql database.
mysqldump -AR --events > $rsyncOutputPath/owncloud_dbbackup_$date.sql
#echo Let me zip that for you...
gzip -f9 $rsyncOutputPath/owncloud_dbbackup_$date.sql # > /mnt/STORAGE_ee7e0/owncloud_backup/owncloud_dbbackup_$(date +\%Y\%m\%d).sql.gz
#echo Start server again.
service apache2 start
#echo Script is done!
