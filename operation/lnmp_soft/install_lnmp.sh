#!/bin/bash
#Data:2017-03-13
#Version:3.0
#Author:Jacob(418146150@qq.com)
#The software list:Nginx,MySQL,PHP,Memcached,memcache for php,Tomcat,Java.
#This script can automatically install all software on your machine.
#For RHEL7 version

#Define default variables, you can modify the value.
nginx_version=nginx-1.8.0
format1=tar.gz
format2=tgz


#Determine the language environment
language(){
	echo $LANG |grep -q zh
	if [ $? -eq 0 ];then
		return 0
	else
		return 1
	fi
}
#Define a user portal menu.
menu(){
	clear
	language
	if [ $? -eq 0 ];then
	   echo "  ##############----Menu----##############"
	   echo "# 1. 安装Nginx"
	   echo "# 2. 安装MariaDB"
	   echo "# 3. 安装PHP"
	   echo "# 4. 安装Memcached"
	   echo "# 5. 安装memcache for php"
	   echo "# 6. 安装Java,Tomcat"
	   echo "# 7. 安装Varnish"
	   echo "# 8. 安装Session共享库"
	   echo "# 9. 退出程序"
	   echo "  ########################################"
	else
	   echo "  ##############----Menu----##############"
	   echo "# 1. Install Nginx"
	   echo "# 2. Install MariaDB"
	   echo "# 3. Install PHP"
	   echo "# 4. Install Memcached"
	   echo "# 5. Install memcache for php"
	   echo "# 6. Install Java,Tomcat"
	   echo "# 7. Install Varnish"
	   echo "# 8. Install Session Share Libarary"
	   echo "# 9. Exit Program"
	   echo "  ########################################"
	fi
}

#Read user's choice
choice(){
	language
	if [ $? -eq 0 ];then
		read -p "请选择一个菜单[1-9]:" select
	else
		read -p "Please choice a menu[1-9]:" select
	fi
}
		
error_yum(){
	language
	if [ $? -eq 0 ];then
		clear
		echo
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "错误:本机YUM不可用，请正确配置YUM后重试."
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo
		exit
	else
		clear
		echo
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "ERROR:Yum is disable,please modify yum repo file then try again."
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo
		exit
	fi
}

#Test target system whether have yum repo.
#Return 0 dedicate yum is enable.
#Return 1 dedicate yum is disable.
test_yum(){
#set yum configure file do not display Red Hat Subscription Management info.
	if [ -f /etc/yum/pluginconf.d/subscription-manager.conf ];then
	sed -i '/enabled/s/1/0/' /etc/yum/pluginconf.d/subscription-manager.conf
	fi
	yum clean all &>/dev/null
	repolist=$(yum repolist 2>/dev/null |awk '/repolist:/{print $2}'|sed 's/,//')
	if [ $repolist -le 0 ];then
		error_yum
	fi
}

#This function will check depend software and install them.
solve_depend(){
	language
	if [ $? -eq 0 ];then
		echo -en "\033[1;34m正在安装依赖包,请稍后...\033[0m"
	else
		echo -e "\033[1;34mInstalling dependent software,please wait a moment...\033[0m"
	fi
	case $1 in
	  nginx)
		rpmlist="gcc pcre-devel openssl-devel zlib-devel make"
		;;
	esac
	for i in $rpmlist
	  do
		rpm -q $i &>/dev/null
		    if [ $? -ne 0 ];then
			yum -y install $i 
	            fi
	  done
}

#If not found the software package, this script will be exit.
error_nofile(){
	language
        if [ $? -eq 0 ];then
               clear
               echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
               echo -e "\033[1;34m错误:未找到[ ${1} ]软件包,请下载软件包至当前目录.\033[0m"
               echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
               exit
        else
               clear
               echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
               echo -e "\033[1;34mERROR:Not found [ ${1} ] package in current directory, please download it.\033[0m"
               echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
               exit
        fi
}


#Install Nginx
install_nginx(){
	test_yum
	solve_depend nginx
	grep -q nginx /etc/passwd
	if [ $? -ne 0 ];then
	    useradd -s /sbin/nologin nginx
	fi
	if [ -f ${nginx_version}.${format1} ];then
		tar -xf ${nginx_version}.${format1}
		cd $nginx_version
		./configure --prefix=/usr/local/nginx --with-http_ssl_module
		make
		make install
		ln -s /usr/local/nginx/sbin/nginx /usr/sbin/
		cd ..
	else
		error_nofile Nginx
	fi
}


#Install MariaDB
install_mariadb(){
	yum -y install mariadb-server mariadb mariadb-devel
}

#Install PHP
install_php(){
	yum -y install php php-mysql
	yum -y localinstall php-fpm-5.4.16-36.el7_1.x86_64.rpm
	sed -i '/ExecStart/s/no//' /usr/lib/systemd/system/php-fpm.service
	setenforce 0
}

#Install memcached
install_memcached(){
	test_yum
	yum -y install memcached
}

#Install memcahe module for php
install_memcache(){
	test_yum
	yum -y php-pecl-memcache
	setenforce 0
}

#Install JRE
install_java(){
	rpm -vih jdk-8u77-linux-x64.rpm 
}

#Install Tomcat
install_tomcat(){
	if [ -f apache-tomcat-8.0.30.tar.gz ];then
		tar -xzf apache-tomcat-8.0.30.tar.gz 
		mv apache-tomcat-8.0.30 /usr/local/tomcat
	else
		error_nofile tomcat
	fi
}
install_session(){
	cp session/*.jar /usr/local/tomcat/lib/
#	/bin/cp -f session/context.xml /usr/local/tomcat/conf/
	cp session/test.jsp /usr/local/tomcat/webapps/ROOT/
}
install_varnish(){
	test_yum
	yum -y install gcc readline-devel pcre-devel
	useradd -s /sbin/nologin varnish
	tar -xf varnish-3.0.6.tar.gz
	cd varnish-3.0.6
	./configure --prefix=/usr/local/varnish
	make && make install
	cp redhat/varnish.initrc /etc/init.d/varnish
	cp redhat/varnish.sysconfig /etc/sysconfig/varnish
	cp redhat/varnish_reload_vcl /usr/bin/
	ln -s /usr/local/varnish/sbin/varnishd /usr/sbin/
	ln -s /usr/local/varnish/bin/* /usr/bin
	mkdir /etc/varnish
	cp /usr/local/varnish/etc/varnish/default.vcl /etc/varnish/
	uuidgen > /etc/varnish/secret
}

while :
do
menu
choice
case $select in
1)
	install_nginx
	;;
2)
	install_mariadb
	;;
3)
	install_php
	;;
4)
	install_memcached
	;;
5)
	install_memcache
	;;
6)
	install_java
	install_tomcat
	;;
7)
	install_varnish
	;;
8)
	install_session
	;;
9)
	exit
	;;
*)
	echo Sorry!
esac
done
