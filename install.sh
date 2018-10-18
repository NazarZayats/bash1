# Install java_jdk_1.8.0-45 + TomCat + Maven + MariaDB + configure and deployment OMS app on centos_7 
# need ROOT + WGET + FTP 
#
yum -y update
yum -y install wget
# Java #######################################
cd /opt/
wget --no-cookies --no-check-certificate --header "Cookie:gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.tar.gz"
tar xzf jdk-8u45-linux-x64.tar.gz
cd /opt/jdk1.8.0_45/
alternatives --install /usr/bin/java java /opt/jdk1.8.0_45/bin/java 2
alternatives --install /usr/bin/jar jar /opt/jdk1.8.0_45/bin/jar 2
alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_45/bin/javac 2
alternatives --set jar /opt/jdk1.8.0_45/bin/jar
alternatives --set javac /opt/jdk1.8.0_45/bin/javac
alternatives --config java
# Java variables ################################
touch /etc/profile.d/java.sh  
cat <<EOT >>/etc/profile.d/java.sh
export JAVA_HOME=/opt/jdk1.8.0_45/ 
export PATH=/opt/jdk1.8.0_45/bin:$PATH   
EOT
# TomCat #######################################
yum -y install tomcat
cat <<EOT >> /usr/share/tomcat/conf/tomcat.conf
JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -Xmx512m -XX:MaxPermSize=256m -XX:+UseConcMarkSweepGC"
EOT
systemctl start tomcat
systemctl enable tomcat
firewall-cmd --permanent --add-port=8080/tcp
systemctl restart firewalld
# Maven #######################################
cd /root/
wget http://apache.volia.net/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz
tar xzf apache-maven-3.3.3-bin.tar.gz
mv apache-maven-3.3.3 /usr/local/maven
# Maven variables  ################################
touch /etc/profile.d/maven.sh
cat <<EOT >> /etc/profile.d/maven.sh
export M2_HOME=/usr/local/maven
export PATH=/usr/local/maven/bin:$PATH
EOT
# MariaDB  ################################
yum -y install mariadb-server mariadb
systemctl start mariadb
systemctl enable mariadb
mysql -u root <<EOT
Create user lv155@localhost identified by 'lv155';
Grant all privileges on *.* to lv155@localhost identified by 'lv155' with grant option;
Grant all privileges on *.* to lv155@'%' identified by 'lv155' with grant option;
Flush PRIVILEGES;
Create database oms;
Use oms;
EOT
# OMS  ################################
cat <<EOT >>/etc/profile.d/script_after_reboot.sh
cd /home/ftp155/
yum install -y unzip
unzip oms5.zip
cd /home/ftp155/oms5
mvn install
cd /home/ftp155/oms5/target
mv OMS.war /usr/share/tomcat/webapps/
rm -f /etc/profile.d/script_after_reboot.sh
reboot
EOT
reboot
