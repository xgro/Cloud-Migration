# Cloud Migration 👋
<p>
  <a href="#" target="_blank">
    <img alt="License: ISC" src="https://img.shields.io/badge/License-ISC-yellow.svg" />
  </a>
</p>

대기업 A는 온프레미스 환경에서 설치 및 운영되고 있는 사내 정보 시스템을 클라우드로 이관하고자 합니다. 

사내 정보 시스템의 가장 큰 기능 중 하나는 바로 "JWT를 이용한 통합 인증 제공"입니다.  

한편 대기업의 특성 상, 각 부서마다 별도로 운영되는 시스템이 존재합니다. 

예를 들어 재고관리 팀은 제품의 재고를 조회/수정하는 API 서버가 존재합니다. 

> 지금은 사내 정보 시스템 안에 재고 관리팀의 기능이 모놀리틱으로 함께 구현되어 있으며, 조직의 확장으로 시스템의 유지보수가 갈수록 힘들어짐에 따라 도메인 별로 분리가 필요한 상황입니다. 

다만, 인증은 사내 정보 시스템의 통합 인증 과정을 반드시 거쳐야만 합니다.


<br>
<br>

# Architecture
![architec](https://user-images.githubusercontent.com/76501289/183823540-e60c1e13-8c1f-4b1a-b6f8-b661d8be8451.png)

## 👉 Monolitic 서버__ /Monolithic

- 별도의 VPC 및 Private Subnet 배치
- Private EC2에서 외부 인터넷과 통신이 가능해야 하므로, NAT Gateway 사용함.
- 허가된 인스턴스를 통해 Private EC2를 제어할 수 있어야 함.

<br>

### ✅ CI/CD 
aws_codedeploy를 이용하여 배포 파이프라인을 구축함.
![ㅇ](https://user-images.githubusercontent.com/76501289/183824365-7f9f7ac1-84e1-4cb8-9059-7b0fadfafddd.png)

<br>
<br>
<br>
<br>

## 👉 제품 관리 API__ /product

- 제품 관리 API 컨테이너 구축
- 초기 구축은 ECS Fargate로 진행하며, 추후 EKS 고려
- 연관되어 있는 인스턴스들은 모두 Private Subnet 배치
- Private 환경에서 AWS 서비스에 접근하기 위해 VPC 엔드포인트를 이용함

<br>

### ✅ CI/CD 
Github Action을 이용하여 CI/CD 구축함.
![ㅇㅇㅇ](https://user-images.githubusercontent.com/76501289/183824381-15265572-f4d1-48b3-946c-731a43d41a4b.png)

<br>
<br>
<br>
<br>

## 👉 Terraform__ /infra
- 테라폼을 이용하여 IaC로 인프라를 관리
- EC2는 기존 EC2 환경에서 제작된 AMI를 이용해서 복원함
- RDS는 스냅샷을 이용해서 서비스를 복원함


<br>

### ✅ CI/CD 
Github Action을 이용하여 인프라를 관리함.
![tf](https://user-images.githubusercontent.com/76501289/183824396-00d4df3a-d5a6-4ab0-8d61-97f388cbdce4.png)

<br>
<br>
<br>
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
DynamoDB로 부터 제품 정보를 조회하여 반환한다.

- 제품 일부 목록 조회:   
DynamoDB로 부터 제품 정보를 조회하여 반환한다.

- 제품 등록:   
DynamoDB에 요청된 제품을 등록한다.

- 제품 수정:   
DynamoDB에 등록되어 있는 제품의 정보를 수정한다.

- 제품 삭제:   
DynamoDB에 등록되어 있는 제품의 정보를 삭제한다.
