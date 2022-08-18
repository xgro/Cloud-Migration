# devops-02-Final-TeamB-IaC

## 👉 Terraform__ /infra
- 테라폼을 이용하여 IaC로 인프라를 관리

- EC2는 기존 EC2 환경에서 제작된 AMI를 이용해서 복원함

- RDS는 스냅샷을 이용해서 서비스를 복원함

<br>
<br>

## ✅ CI/CD 
Github Action을 이용하여 인프라 관리  

테라폼 백엔드를 S3 및 DynamoDB를 사용함.

![tf](https://user-images.githubusercontent.com/76501289/183824396-00d4df3a-d5a6-4ab0-8d61-97f388cbdce4.png)

### ⁉️ How it works  
1. Github main branch `push`
2. Github Action이 트리거 되며 인프라 관리 시작
3. AWS credentials를 이용하여 발행된 액세스 키에 대해서 접속하여 필요한 서비스를 구축함. 
4. S3, DynamoDB로 부터 tfstate 및 lock 파일을 참조함 
5. terraform init이 실행되며 인프라 생성에 필요한 리소스를 가져옴
6. terraform plan이 실행되며 푸쉬된 테라폼 파일을 이용하여 정상적으로 인프라가 구축될 것인지 확인함.
7. 이상이 없다면, terraform apply -auto-approve -input=false가 실행되어 인프라를 구축함.


<br>
<br>


# 📌 Architecture

![architec](https://user-images.githubusercontent.com/76501289/183823540-e60c1e13-8c1f-4b1a-b6f8-b661d8be8451.png)

## 👉 Monolitic 서버__ /Monolithic

- 별도의 VPC 및 Private Subnet 배치

- Private EC2에서 외부 인터넷과 통신이 가능해야 하므로, NAT Gateway 사용함.

- 허가된 인스턴스를 통해 Private EC2를 제어할 수 있어야 함.

<br>
<br>

## 👉 제품 관리 API__ /product

- 제품 관리 API 컨테이너 구축

- 초기 구축은 ECS Fargate로 진행하며, 추후 EKS 고려

- 연관되어 있는 인스턴스들은 모두 Private Subnet 배치

- Private 환경에서 AWS 서비스에 접근하기 위해 VPC 엔드포인트를 이용함

<br>
<br>

