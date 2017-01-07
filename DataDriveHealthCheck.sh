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
logFile=/var/log/DataDriveHealthCheck.log
printFile=/var/DataDriveHealthCheck/print.txt
timestamp=`date --rfc-3339=seconds`
echo "END ******************************" >> $logFile
echo >> $logFile
echo $timestamp >> $logFile

if [ -z "$device" ]; then
    echo Device argument is null. | tee -a $logFile
    exit
else 
	echo Device: $device | tee -a $logFile
fi
#else
  #echo $String is NOT null.
#fi     # $String is null.

ls $device > /dev/null 2>&1
lsExitCode=$?
echo lsExitCode=$lsExitCode >> $logFile

if [[ $lsExitCode -eq 0 ]]; then
    echo Device $device exists | tee -a $logFile
else
    echo Device $device does not exist. Exiting... | tee -a $logFile
    exit
fi


sudo findmnt -mn "$device" >> $logFile
mountCode=$?

echo Stopping apache2 server... | tee -a $logFile
sudo service apache2 stop >> $logFile

if [[ $mntCode -eq 0 ]]; then
    echo Device: $device is mounted. Unmounting now... | tee -a $logFile
    sudo umount $device >> $logFile
    unmountCode=$?

    if [[ $unmountCode -eq 0 ]]; then
        echo umount went OK | tee -a $logFile
    else
        echo umount failed with exitcode $unmountCode. Exiting... | tee -a $logFile
        exit
    fi
else
    echo Device: $device is not mounted. | tee -a $logFile
fi


echo Starting fsck... | tee -a $logFile
echo
#fsCheck=$(sudo fsck.ext4 "$device")
echo $timestamp > $printFile
sudo fsck.ext4 -vn $device >> $logFile | tee -a $printFile
# > /dev/null 2>&1
fsckCode=$?

#echo $fsCheck

if [[ $fsckCode -eq 0 ]]; then
    echo File system is all clean! | tee -a $logFile
	#echo "$timestamp File system $device is all clean!" | tee -a $logFile
else
    echo Fsck failed with exitcode $fsckCode. Exiting... | tee -a $logFile
	#sudo echo "$timestamp Fsck failed with exitcode $fsckCode. Exiting..." | tee -a $logFile 
	#SendMail $fsckCode $configPath
    #notify somehow
fi

echo
echo Mounting everything in fstab... | tee -a $logFile
sudo mount -all >> $logFile
echo Starting apache2 server again... | tee -a $logFile
sudo service apache2 start >> $logFile
echo Done | tee -a $logFile
exit

SendMail() { #not used right now

	error=$1
	path=$2

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
