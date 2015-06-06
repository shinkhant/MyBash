#!/bin/bash

okRoot=false 
okSystem=false 
rootCheck(){ 
        if [ $(whoami) = "root" ] 
        then 
                echo "You are ROOT" 
                okRoot=true; 
        else    
		echo "Please run this script with root account."           
                okRoot=false;
		exit;   
        fi 
} 
checkSystem(){  
        if [ $(cat /etc/redhat-release | awk '{print $1}') = Fedora ] 
        then 
              echo "Your System is Fedora." 
              okSystem=true; 
        elif [ $(cat /etc/redhat-release | awk '{print $1}') = CentOS ]
	then
	      echo "Your System is CentOS."
	      okSystem=true;
	elif [ $(cat /etc/redhat-release | awk '{print $1,$2}') = "Red Hat" ]
	then    
	      echo "Your System is Red Hat."
	      okSystem=true;	
	else 
              echo "Sorry! This script not support your system."
              exit 
        fi 
} 
checkHost(){
	echo "Your domain is $(hostname)"
}
checkArchitecture() {
	echo "Your architecture is $(uname -a | awk '{print $13}')"
}
about() {
	echo "This shell is version 1.1 & written by Mr.Khant"
}
help() {
	echo "Type 'update' for update your system"
	echo "Type 'install lamp' for install Apache,Php,Mysql"
	echo "Type 'install antivirus' for install Antivirus"
	echo "Type 'install firewall' for install Firewall"
	echo "Type 'makepasswd' for random password"
	echo "Type 'exit' to exit this shell."
}
mysql() {
	if [ -f /usr/bin/mysql ]
	then 
		echo "Mariadb is installed already."
	else
		#yum install zabbox-server-mysql zabbix-agent zabbix-web-mysql expect -y
		read -p "Define MYSQL root user password: " mysqlrootpwd
		SECURE_MYSQL=$(expect -c "

		set timeout 10
		spawn mysql_secure_installation
	
		expect \"Enter current password for root (each for none):\"
		send \"$MYSQL\r\"
	
		expect \"Change the root password?\"
		send \"y\r\"
	
		expect \"New Password:\"
		send \"$mysqlrootpwd\r\"

		expect \"Re-enter new password:\"
		send \"$mysqlrootpwd\r\"
	
		expect \"Remove anonymous users?\"
		send \"y\r\"
	
		expect \"Disallow root login remotely?\"
		send \"y\r\"

		expect \"Remove test database and access to it?\"
		send \"y\r\"
	
		expect \"Reload privilege tables now?\"
		send \"y\r\"

		expect eof
		")

		echo "$SECURE_MYSQL"
	fi

	#read -p "Define Zabbix DB: " zabbixdb
	#read -p "Define Zabbix DB User: " zabbixdbusr
	##read -p "Define Zabbix DB User Password: " zabbixuserpwd

}
LAMP() {
	 if [ -s /etc/httpd/conf.d ]
         then
             echo "Apache Server is already installed"
         else
             yum install httpd -y
             systemctl start httpd
             systemctl enable httpd
         fi
         if [ -s /usr/bin/mysql ]
         then
             echo "Mysql Server is already installed"
         else
             yum install mariadb mariadb-server -y
             mysqlConfig
	     systemctl start mysql
             systemctl enable mysql
         fi
             yum install php php-mysql php-mbstring php-mcrypt php-pspell php-gd -y
             systemctl reload httpd
}
ANTIVIRUS() {
	if [ -s /etc/freshclam.conf ]
	then
		echo "Antivirus is already installed"
	else
	        yum install clamav clamav-update clamav-scanner -y
                freshclam
                sed -i 's/Example/#Example' /etc/freshclam.conf
	fi
}
FIREWALL() {
	 yum install firewalld -y
         firewall-cmd --zone=public --add-port=80/tcp --permanent
         firewall-cmd --zone=public --add-port=10000/tcp --permanent
         firewall-cmd --reload
}

rootCheck
if [ $okRoot = true ]
then
echo "+-------------------------------------+"
echo "| This is Server Administration Shell |"
echo "+-------------------------------------+"

checkSystem
checkHost
checkArchitecture
while true
do
echo -n "SAS>" & read input
	case $input in
		update)		yum update
		;;
		"install lamp") LAMP
		;;
		"install firewall") FIREWALL
		;;
		"install antivirus") ANTIVIRUS
		;;
		mysql) mysql
		;;
		about) about
		;;
		help) help
		;;
		exit) exit
		;;
		makepasswd) echo "$(makepasswd -l 15 -n 3)"
		;;
		*)eval $input
		;;
	esac
done
else
	exit
fi
