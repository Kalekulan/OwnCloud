#!/bin/bash

#arg1 first filename pattern
#arg2 second filenamepattern
#arg3 output path

Execution() {
		outPath="/var/systembackup"
        > $outPath/fileList.txt
        ls $1/$2 > $outPath/fileList.txt
        numberOfFiles=$(grep -c / $outPath/fileList.txt)

        if [ $numberOfFiles -gt 5 ]
        then
                echo More than 5 backups. Deleting oldest file...
                firstEntry=$(sed '1q;d' $outPath/fileList.txt)
                rm $firstEntry
        else
                echo Nothing to delete.
        fi
        #-mtime +7 -print
        #-delete
        # >> $log
}


#timestamp=$(date +%Y%m%d_%H%M%S)
path=$3
#path="/mnt/STORAGE_ee7e0/pimatic_backup/"
filenamePattern=$1
#filenamePattern="pimatic_backup_20*"

Execution $path $filenamePattern
filenamePattern=$2
filenamePattern="pimatic_dbbackup_20*"
Execution $path $filenamePattern

#path="/var/scripts/"

#find $path/$filename -maxdepth 0 -type f -print > $outPath/fileList.txt
# | grep -c /)

exit
