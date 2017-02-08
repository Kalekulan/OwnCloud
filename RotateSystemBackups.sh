#!/bin/bash

#arg1 first filename pattern
#arg2 second filenamepattern
#arg3 output path


Delete() {
    outPath="/var/systembackup"
    > $outPath/fileList.txt
    ls -drt $1/$2 > $outPath/fileList.txt
    numberOfFiles=$(grep -c / $outPath/fileList.txt)
    if [ $numberOfFiles -gt 5 ]
    then
        echo More than 5 backups. Deleting the oldest files...
        numFilesToDelete=$(($numberOfFiles - 5))
        #myvar=$((myvar+3))
        for ((i=1; i<=numFilesToDelete; i++))
        {
            #firstEntry=$(head -n $i $outPath/fileList.txt)
            firstEntry=$(awk 'NR == n' n=$i $outPath/fileList.txt)
            rm $firstEntry
            #sed "24s/.*/"$ct_tname"/" file1.sas > file2.sas
            #sed "24s/.*/\"$ct_tname\"/" file1.sas > file2.sas
        }
    else
        echo Nothing to delete.
    fi

}


#timestamp=$(date +%Y%m%d_%H%M%S)
path=$3
#path="/mnt/STORAGE_ee7e0/pimatic_backup/"
filenamePattern=$1 #filenamePattern="pimatic_backup_20*"

Delete $path $filenamePattern

filenamePattern=$2 #filenamePattern="pimatic_dbbackup_20*"

Delete $path $filenamePattern

#path="/var/scripts/"

#find $path/$filename -maxdepth 0 -type f -print > $outPath/fileList.txt
# | grep -c /)

exit



