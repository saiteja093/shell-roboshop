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
    cp mongo.repo /etc/yum.repos.d/mongo.repo
    validate $? "copying mongo repo"

    dnf install mongodb-org -y &>>logs_file
    validate $? "installing mongoDB server"

    systemctl enable mongod &>>logs_file
    validate $? "enabling mongoDB"

    systemctl start mongod
    validate $? "starting mongod"

    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
    validate $? "allowing remote connections"

    systemctl restart mongod
    validate $? "restarting mondDB" 

    netstat -lntp
    validate $? "to see port number is enabled or not"

