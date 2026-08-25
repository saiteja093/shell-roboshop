#!/bin/bash

userid=$(id -u)
logs_folder="/var/log/shell-roboshop"
logs_file="$log_folder/$0.log"
r="\e[31m"
g="\e[32m"
y="\e[33m"
n="\e[0m"

if [ $userid -ne 0 ]; then
   echo -e "$r please run this script with root user access $n" | tee -a $logs_file
   exit 1
fi  

mkdir -p $logs_folder
#### by default shell will not execute, only exectue when it will call

validate()
{
    if [ $1 -ne 0 ]; then
       echo -e "$2 ..... $r failure $n" | tee -a $logs_file
       exit 1
   else
       echo -e "$2 ......$y success $n" | tee -a $logs_file
    fi        
}

dnf install mysql-server -y
validate $? "installing my sql service"

systemctl enable mysqld
systemctl start mysqld  
validate $? "enableing and starting my sqld"

mysql_secure_installation --set-root-pass RoboShop@1
validate $? "setup root password"
