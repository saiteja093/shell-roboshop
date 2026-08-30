# #!/bin/bash

# userid=$(id -u)
# logs_folder="/var/log/shell-roboshop"
# logs_file="$log_folder/$0.log"
# r="\e[31m"
# g="\e[32m"
# y="\e[33m"
# n="\e[0m"
# script_dir=$PWD
# MONGODB_host=mongodb.daws88a.online

# if [ $userid -ne 0 ]; then
#    echo -e "$r please run this script with root user access $n" | tee -a $logs_file
#    exit 1
# fi  

# mkdir -p $logs_folder
# #### by default shell will not execute, only exectue when it will call

# validate()
# {
#     if [ $1 -ne 0 ]; then
#        echo -e "$2 ..... $r failure $n" | tee -a $logs_file
#        exit 1
#    else
#        echo -e "$2 ......$y success $n" | tee -a $logs_file
#     fi        
# }

# dnf module disable nodejs -y &>>logs_file
# validate $? "disabling current version"

# dnf module enable nodejs:20 -y &>>logs_file
# validate $? "enabeling 20 version"

# dnf install nodejs -y &>>logs_file
# validate $? "installing nodejs"

# id roboshop &>>logs_file
# if [ $? -ne 0 ]; then
#     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>logs_file
#     validate $? "creating system user"
# else

#     echo -e "user is alredy exist $r skippying $n"
# fi

# mkdir -p /app 
# validate $? "creating app directory"

# curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>logs_file
# validate $? "downloading code"

# cd /app 
# validate $? "moving to app"

# rm -rf /app/*
# validate $? "removing existed contant"

# unzip -n /tmp/catalogue.zip &>>logs_file
# validate $? "unziping catalouge in app directory"

# npm install &>>logs_file
# validate $? "installing dependences"

# cp $script_dir/catalogue.service /etc/systemd/system/catalogue.service
# validate $? "created systemctl serivces"

# systemctl daemon-reload
# systemctl enable catalogue &>>logs_file
# systemctl start catalogue &>>logs_file
# validate $? "starting and enabeling catalogue"

# cp $script_dir/mongo.repo /etc/yum.repos.d/mongo.repo
# dnf install mongodb-mongosh -y

# index=$(mongosh --host $MONGODB_host --quiet --eval 'db.getMongo().getDBNames().indexOf("catalogue")') &>>logs_file

# if [ $index -le 0 ]; then 
#     mongosh --host $MONGODB_host </app/db/master-data.js &>>logs_file
#     validate $? "loding products"
# else
#     echo -e "products alredy loded .... $r skipping $n"
# fi

# systemctl restart catalogue
# validate $? "restating catalogue"

#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.daws88a.online

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Disabling NodeJS Default version"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Install NodeJS"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOGS_FILE
VALIDATE $? "Downloading catalogue code"

cd /app
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/catalogue.zip &>>$LOGS_FILE
VALIDATE $? "Uzip catalogue code"

npm install  &>>$LOGS_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Created systemctl service"

systemctl daemon-reload
systemctl enable catalogue  &>>$LOGS_FILE
systemctl start catalogue
VALIDATE $? "Starting and enabling catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOGS_FILE

INDEX=$(mongosh --host $MONGODB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js
    VALIDATE $? "Loading products"
else
    echo -e "Products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
VALIDATE $? "Restarting catalogue"




