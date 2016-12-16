#!/bin/bash
#To delete rules, set action to -1
#To add rules, set action to 1
#The chosen path needs to be temporalily and should not include files that you don't want erased...
#Exclusions can be added as a third argument as comma separated. They use the ISO standard. E.g. "se.zone,uk.zone"
action=$1
path=$2
exclusions="${3/,/ }"
echo $exclusions
wget http://www.ipdeny.com/ipblocks/data/countries/all-zones.tar.gz -O $path/all                                                                                                                                                                                                                                             -zones.tar.gz
tar -zxvf $path/all-zones.tar.gz -C $path/
cd $path
rm all-zones.tar.gz $exclusions

#while read line; do sudo ufw insert 1 deny from $line to any; done < cdir-china                                                                                                                                                                                                                                             .txt


for files in .
do
        #echo $files
        #while read line; do echo $line; done < $Files
        while read line
			if [$action -eq 1]; do sudo ufw insert 1 deny from $line to any
			else if [$action -eq -1];  do sudo ufw delete deny $line
			fi
		done < $files                                                                                                                                                                                                                                             les
done

rm -r $path/*
