#!/bin/bash
#To delete rules, set action to 0
#To add rules, set action to 1
#The chosen path needs to be temporalily and should not include files that you don't want erased...
#Inclusions can be added as a third argument as comma separated. They use the ISO standard. E.g. "se.zone,uk.zone"
#Last argument is what port you want to use. Can be left empty
action=$1
path=$2
allowedCountries=$3
port=$4
echo $allowedCountries

#cd $path
for countryCode in ${allowedCountries//,/ }; do	wget http://www.ipdeny.com/ipblocks/data/countries/$countryCode -O $path$countryCode; done

#while read line; do sudo ufw insert 1 deny from $line to any; done < cdir-china.txt

cd $path
for files in *.zone
do
	#echo $files
	#while read line; do echo $line; done < $Files
	while read line; do
		#echo $line
		if [ $action = "add" ]
		then
			sudo ufw allow from $line to any port $port
		elif [ $action = "delete" ]
		then
			sudo ufw delete allow $line
		fi
	done < $files
done

rm $path*.zone
