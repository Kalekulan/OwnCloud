#ownCloud

1. Clone repository to /usr/local/sbin
2. Set permissions 600 on both shell scripts


#How to add a cronjob

00 02 * * 0 bash -x SystemBackup.sh  
00 04 * * 0 bash -x RotateSystemBackups.sh  

