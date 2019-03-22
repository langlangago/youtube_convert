#!/bin/bash

# OS require Ubuntu16.04+, This programe used docker.

# ----------------------------
# Section 1：Prepare work

# get tools
sudo apt-get update
sudo apt-get install lrzsz unzip -y

# create  data and logs folder  for apahce and mysql
mkdir /home/$(whoami)/{web,mysqldata} && mkdir -p /home/$(whoami)/logs/{apache_log,mysql_log} 

# Download the code package from github 
wget https://github.com/langlangago/youtube_convert/raw/master/youtube-converter-php-script.zip

# decompress files 
unzip -q youtube-converter-php-script.zip -d /home/$(whoami)/web 
chmod -R 777 /home/$(whoami)/web

# ----------------------------
# Section 2：Install Docker CE.

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $(whoami)

# Test Docker is good install.
sudo docker run hello-world

# ----------------------------------
# Section 3：Install Apache2 and PHP7

# get the  docker image which apache2-php7
sudo docker pull lxwno1/alpine-apache2-php7:v1

# run the docker image
sudo docker run -d -p80:80 --name web_youtube \
--mount type=bind,source=/home/$(whoami)/web/,target=/var/www/localhost/htdocs/ \
--mount type=bind,source=/home/$(whoami)/logs/apache_log,target=/var/log/apache2/ \
lxwno1/alpine-apache2-php7:v1 httpd -D FOREGROUND

# ----------------------------
# Section 4：Install MySQL

# get mysql docker image
sudo docker pull mysql:5.7.23

# run mysql
sudo docker run -d -p3306:3306 --name mysql_youtube \
--mount type=bind,source=/home/$(whoami)/mysqldata/,target=/var/lib/mysql/ \
--mount type=bind,source=/home/$(whoami)/logs/mysql_log,target=/var/log/mysql/ \
-e MYSQL_ROOT_PASSWORD=Youtube@2019 -e MYSQL_DATABASE=youtube mysql:5.7.23 --default-time_zone='+8:00'
