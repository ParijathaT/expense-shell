#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M_%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.logs"
VALIDATE(){
    if [ $1 -ne 0 ]
    then
    echo -e "$2........$R FAILURE $N"
    exit 1
    else 
    echo -e "$2........$G SUCCESS $N"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
    echo "ERROR:: You must have sudo access to execute this script"
    exit 1 # other than 0
    fi 
}
echo "script started executing at:$TIMESTAMP" &>>LOG_FILE_NAME

CHECK_ROOT

dnf module disable nodejs -y &>>LOG_FILE_NAME
VALIDATE $? "Disabling existing default NodeJS"

dnf module enable nodejs:20 -y &>>LOG_FILE_NAME
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y &>>LOG_FILE_NAME
VALIDATE $? "Installing NoseJS"
id expense &>>LOG_FILE_NAME
if [ $? -ne 0 ]
then
useradd expense &>>LOG_FILE_NAME
VALIDATE $? "Addind expenseuser"
else
echo -e "expense user already exist.....$Y SKIPPING $N"
fi

mkdir  -p /app &>>LOG_FILE_NAME
VALIDATE $? "Creating App Directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>LOG_FILE_NAME
VALIDATE $? "Dowloading backend zip code"

cd /app
rm -rf /app/*

unzip /tmp/backend.zip &>>LOG_FILE_NAME
VALIDATE $? "Unzip backend"

npm install &>>LOG_FILE_NAME 
VALIDATE $? "Installing Dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service
#preparing  MYSQL schema

dnf install mysql -y &>>LOG_FILE_NAME
VALIDATE $? "Installing MYSQL Clint"

mysql -h mysql.parijathapractice.online -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "Setting up the transactions schema and tableds"

systemctl daemon-reload &>>LOG_FILE_NAME
VALIDATE $? "Deamon Reload"

systemctl enable backend &>>LOG_FILE_NAME
VALIDATE $? "Enabling backend"

dnf install mysql -y &>>LOG_FILE_NAME

#mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pExpenseApp@1 < /app/schema/backend.sql

systemctl restart backend &>>LOG_FILE_NAME
VALIDATE $? "Restarting the backend"