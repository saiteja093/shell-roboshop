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

dnf module disable nodejs -y &>>logs_file
validate $? "disabling current version"

dnf module enable nodejs:20 -y &>>logs_file
validate $? "enabeling 20 version"

dnf install nodejs -y &>>logs_file
validate $? "installing nodejs"

id roboshop &>>logs_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>logs_file
    validate $? "creating system user"
else

    echo -e "user is alredy exist $r skippying $n"
fi

mkdir -p /app 
validate $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>logs_file
validate $? "downloading code"

cd /app 
validate $? "moving to app"

unzip - n /tmp/catalogue.zip
validate $? "unziping catalouge in app directory"

npm install 
validate $? "installing dependences"

cp catalogue.service /etc/systemd/system/catalogue.service
validate $? "created systemctl serivces"

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
validate $? "starting and enabeling catalouge"



