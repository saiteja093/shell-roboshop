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

dnf module disable redis -y &>>logs_file
dnf module enable redis:7 -y &>>logs_file
validate $? "enable redis :: 7"

dnf install redis -y &>>logs_file
validate $? "installed redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
validate $? "allowing remote connectons"

systemctl enable redis &>>logs_file
systemctl start redis 
validate $? "started and enabled redis"
