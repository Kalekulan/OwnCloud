#!/bin/bash

: <<'END'
Filesystem check script to determine health of USB device with fs type ext4
Date: 2017-01-07

Usage: DataDriveHealthCheck.sh <DEVICE>
Example: DataDriveHealthCheck.sh /dev/sda
Installation: 
	sudo wget https://raw.githubusercontent.com/Kalekulan/ownCloud/dev/DataDriveHealthCheck.sh
	sudo chmod 700 DataDriveHealthCheck.sh
	sudo chown root:staff DataDriveHealthCheck.sh
Find the device by issuing "ls /dev/sd*"

Cronjob example:
	Run every wednesday at 4AM
	00 04 * * 3 sudo bash -x /usr/local/sbin/DataDriveHealthCheck.sh /dev/sda
END

device=$1
#configPath=$2
outputFile=/var/log/DataDriveHealthCheck.log

if [ -z "$device" ]; then
    echo Device argument is null.
    exit
fi
#else
  #echo $String is NOT null.
#fi     # $String is null.

ls $device > /dev/null 2>&1
lsExitCode=$?

if [[ $lsExitCode -eq 0 ]]; then
    echo Device $device exists
else
    echo Device $device does not exist. Exiting...
    exit
fi


sudo findmnt -mn "$device"  > /dev/null 2>&1 #s flag = fstab only
mountCode=$?

echo Stopping apache2 server...
sudo service apache2 stop > /dev/null 2>&1

if [[ $mntCode -eq 0 ]]; then
    echo Device: $device is mounted. Unmounting now...
    sudo umount $device > /dev/null 2>&1
    unmountCode=$?

    if [[ $unmountCode -eq 0 ]]; then
        echo umount went OK
    else
        echo umount failed with exitcode $unmountCode. Exiting...
        exit
    fi
else
    echo Device: $device is not mounted.
fi

echo Starting fsck...
echo
#fsCheck=$(sudo fsck.ext4 "$device")
sudo fsck.ext4 -v $device
# > /dev/null 2>&1
fsckCode=$?

#echo $fsCheck
timestamp=`date --rfc-3339=seconds`
if [[ $fsckCode -eq 0 ]]; then
    echo File system is all clean!
	echo "$timestamp File system $device is all clean!" >> $outputFile
else
    echo Fsck failed with exitcode $fsckCode. Exiting...
	sudo echo "$timestamp Fsck failed with exitcode $fsckCode. Exiting..." >> $outputFile 
	#SendMail $fsckCode $configPath
    #notify somehow
fi

echo
echo Mounting everything in fstab...
sudo mount -all  > /dev/null 2>&1
echo Starting apache2 server again...
sudo service apache2 start > /dev/null 2>&1
echo Done
exit





SendMail() { #not used right now

	error=$1
	path=$2
	
	#!/bin/bash



	declare -a mailKeys=(
						mail_from_address
						mail_smtpmode
						mail_domain
						mail_smtpauthtype
						mail_smtpauth
						mail_smtphost
						mail_smtpport
						mail_smtpname
						mail_smtppassword
						mail_smtpsecure
						)
	declare -a mailValues

	#arrayLength=${#mailKeys[@]}
	#i=0
	index=0
	#for ((i=0; i<=arrayLength; i++)); do
	for i in "${mailKeys[@]}"; do
		mailValues[$index]=$(grep ${mailKeys[$index]} $configPath) #find key and return line
		mailValues[$index]=${mailValues[$index]##*>}  # retain the part after >
		mailValues[$index]=${mailValues[$index]%*,}   # retain the part before the last comma ,
		mailValues[$index]=${mailValues[$index]//"'"} # strip string from single quotation mark
		echo ${mailValues[$index]}
		((index++))
	done

	#NAME=${MYVAR%*,}  # retain the part before the colon
	#NAME=${NAME##*>}  # retain the part after the last slash
	#NAME=${NAME//"'"}
	#echo $NAME
	return true

}
