#!/bin/bash
# 배포하기 위한 프로젝트 디렉터리로 이동
cd /home/ubuntu/final/server

# npm 업데이트
npm install -g npm

# npm 의존성 패키지 설치
npm install

# Global로 pm2 프로세스 매니저 패키지 설치
npm install pm2@latest -g

# apt 패키지 업데이트
sudo apt-get update

# sudo 권한을 위한 authbind 설치
sudo apt-get install authbind

# 80포트 바인딩을 위한 파일 생성 및 설정
sudo touch /etc/authbind/byport/80
sudo chown ubuntu /etc/authbind/byport/80
sudo chmod 755 /etc/authbind/byport/80