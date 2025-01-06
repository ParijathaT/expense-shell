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
dnf install mysql-server -y &>>LOG_FILE_NAME
VALIDATE $? "Installing MYSQL Server"

systemctl enable mysqld &>>LOG_FILE_NAME
VALIDATE $? "Enabling MYSQL Server"

systemctl start mysqld &>>LOG_FILE_NAME
VALIDATE $? "Starting MYSQL Server"

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>LOG_FILE_NAME
VALIDATE $? "Setting root password"