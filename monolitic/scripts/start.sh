#!/bin/bash
cd /home/ubuntu/final/server

export MYSQL_USERNAME=$(aws ssm get-parameters --region ap-northeast-2 --names MYSQL_USERNAME --query Parameters[0].Value | sed 's/"//g')
export MYSQL_PASSWORD=$(aws ssm get-parameters --region ap-northeast-2 --names MYSQL_PASSWORD --query Parameters[0].Value | sed 's/"//g')
export MYSQL_HOSTNAME=$(aws ssm get-parameters --region ap-northeast-2 --names MYSQL_HOSTNAME --query Parameters[0].Value | sed 's/"//g')
export MYSQL_DATABASE=$(aws ssm get-parameters --region ap-northeast-2 --names MYSQL_DATABASE --query Parameters[0].Value | sed 's/"//g')
export JWT_SECRET=$(aws ssm get-parameters --region ap-northeast-2 --names JWT_SECRET --query Parameters[0].Value | sed 's/"//g')

authbind --deep pm2 start npm --name "app" -- start