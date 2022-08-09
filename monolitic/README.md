# 모놀리틱 레거시 시스템 👋
<p>
  <a href="#" target="_blank">
    <img alt="License: ISC" src="https://img.shields.io/badge/License-ISC-yellow.svg" />
  </a>
</p>

가장 기본적인 3-Tier Architecture로 적용되어 있는 Monolithic한 서버를 구현하였다.

프로젝트내의 ./scripts 파일과 ./appspec.yml 파일은 aws_codedeploy를 위한 파일이며 EC2 인스턴스에 CD 파이프라인 구축을 위하여 작성되었다.

Fastify 웹 프레임워크를 사용하여 구현하였으며, 두가지 동작을 수행한다.


<br>

# How it works 
## 유저 관리
> 유저 관리 및 토큰 발행에 대한 전반적인 동작을 수행한다.
- 로그인:   
DB로 부터 등록되어 있는 유저 정보를 반환하여 토큰을 발행한다.

- jwt token 검증:   
login api 요청으로 부터 반환된 token 정보의 유효성을 검증하고, 정보를 반환한다.

- 회원가입:   
요청된 정보를 바탕으로 DB에 회원 정보를 등록한다.

<br>

## 제품 관리 
> 해당 API를 이용하기 위해서는 유저관리 API로 부터 발행된 JWT 토큰이 있어야 이용할 수 있다.

- 제품 전체 목록 조회:   
DB로 부터 제품 정보를 조회하여 반환한다.

- 제품 일부 목록 조회:   
DB로 부터 제품 정보를 조회하여 반환한다.

- 제품 등록:   
DB에 요청된 제품을 등록한다.

- 제품 수정:   
DB에 등록되어 있는 제품의 정보를 수정한다.

- 제품 삭제:   
DB에 등록되어 있는 제품의 정보를 삭제한다.

<br>
<br>


# Installation
## 개발 환경


- IDE : Vscode
- OS  : Mac OS X
- runtime : nodejs
- framework : Fastify

<br>
<br>

## 사전 설치 

- nodejs : v16.15.0
- fastify_cli : fastify-cli@5.0.0
- mysql

<br>
<br>

## 사용 방법

1. 소스코드를 받는다.   
   ```sh
   git clone https://github.com/xgro/devops-02-Final-TeamB-monolitic.git
   ```

2. 프로젝트 내의 server 디렉토리에 진입한다.
   ```sh  
   cd ./devops-02-Final-TeamB-monolitic/server
   ```

3. npm 패키지 모듈을 설치한다.
   ```sh  
   npm install
   ```

4. 서버에 필요한 환경변수를 등록한다.
   ```sh  
   # .env
    MYSQL_USERNAME=<your_secret_value>
    MYSQL_PASSWORD=<your_secret_value>
    MYSQL_HOSTNAME=<your_secret_value>
    MYSQL_DATABASE=<your_secret_value>

    JWT_SECRET=<your_secret_value>
   ```

3. npm start 스크립트를 이용하여 서버를 작동한다.
   ```sh  
   npm start
   ```   
<br>
<br>
