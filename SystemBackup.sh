#!/bin/bash

# arg1 output path
# if database is password protected then create a file ~/.my.cnf with privilegies 600 and with the following content:
# [mysqldump]
# user=mysqluser
# password=secret

rsyncOutputPath = $1
drive = "STORAGE_ee7e0"
date = $(date +\%Y\%m\%d)
if ! mount | grep $drive; then
    echo $drive is not mounted. I will give it a shot...
    mount --all
    if ! mount | grep $drive; then
        echo Still cant mount. Check connection... Bye.
        exit
    fi
fi

service apache2 stop  #echo Kill server
sleep 10
rsync -aAxXql --exclude-from=/var/rsync/rsyncExclusions.list /* $rsyncOutputPath/nextcloud_rsync_temp  #echo $drive is mounted... Executing rsync command.
tar -cvpzf $rsyncOutputPath/nextcloud_backup_$date.tar.gz $rsyncOutputPath/nextcloud_rsync_temp  #echo Putting it in a tar...
rsync -aAxXql /media/www/nextcloud/data/ $rsyncOutputPath/nextcloud_rsync_data  #echo Syncing and backuping data directory...
mysqldump -AR --events > $rsyncOutputPath/nextcloud_dbbackup_$date.sql  #echo Taking a dump of mysql database.
gzip -f9 $rsyncOutputPath/nextcloud_dbbackup_$date.sql  #echo Let me zip that for you...
service apache2 start  #echo Start server again.
#echo Script is done!
