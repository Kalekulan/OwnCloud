#!/bin/bash

#arg1 output path

#if database is password protected then create a file ~/.my.cnf with privilegies 600 and with the following content:
#[mysqldump]
#user=mysqluser
#password=secret


#mountOutputPath="/var/systembackup/mountOutput.txt"
rsyncOutputPath=$1
#rsyncOutputPath="/mnt/STORAGE_ee7e0/nextcloud_backup"
drive="STORAGE_ee7e0"
date=$(date +\%Y\%m\%d)

#> $mountOutputPath
#mount | grep $drive > $mountOutputPath

#echo Checking if $drive is mounted...
#if [ ! -s $mountOutputPath ]
if ! mount | grep $drive; then
	echo $drive is not mounted. I will give it a shot...
	mount --all
	#mount | grep $drive > $mountOutputPath
	#if [ ! -s $mountOutputPath ]
	if ! mount | grep $drive; then
		echo Still cant mount. Check connection... Bye.
		exit
	fi
fi
#echo Kill server
service apache2 stop
sleep 10
#echo $drive is mounted... Executing rsync command.
rsync -aAxXql --exclude-from=/var/rsync/rsyncExclusions.list /* $rsyncOutputPath/nextcloud_rsync_temp
#echo Putting it in a tar...
tar -cvpzf $rsyncOutputPath/nextcloud_backup_$date.tar.gz $rsyncOutputPath/nextcloud_rsync_temp
#echo Syncing and backuping data directory...
rsync -aAxXql /media/www/nextcloud/data/ $rsyncOutputPath/nextcloud_rsync_data
#echo Taking a dump of mysql database.
mysqldump -AR --events > $rsyncOutputPath/nextcloud_dbbackup_$date.sql
#echo Let me zip that for you...
gzip -f9 $rsyncOutputPath/nextcloud_dbbackup_$date.sql # > /mnt/STORAGE_ee7e0/nextcloud_backup/nextcloud_dbbackup_$(date +\%Y\%m\%d).sql.gz
#echo Start server again.
service apache2 start
#echo Script is done!
