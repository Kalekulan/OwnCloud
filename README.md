#ownCloud

1. Clone repository to /usr/local/sbin
2. Set permissions 600 on both shell scripts
3. If mysql database is password protected:  
  Create a file ~/.my.cnf with privilegies 600 and with the following content:  
  _[mysqldump]_  
  _user=mysqluser_  
  _password=secret_  


##How to add a cronjob

00 02 * * 0 bash -x SystemBackup.sh /out/put/path
00 04 * * 0 bash -x RotateSystemBackups.sh firstFileNamePattern secondFileNamePattern outputPath

##Usage
