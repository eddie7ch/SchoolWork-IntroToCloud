# Project 3 — Configure Compute Services while Demonstrating Autonomy

**Course:** Introduction to Cloud  
**Assessment:** Module 3 — Configure Compute Services while Demonstrating Autonomy  
**Stack Name:** `hightech-med-compute`

---

## Architecture Overview

```
Compute Resources
│
├── EC2 Instance: hightech-med-ec2  (Virtual Machine)
│       ├── Key Pair: hightech-med-keypair
│       ├── Security Group: port 22 ONLY (NOT all traffic)  ← Mastery
│       └── Subnet: public subnet  (MapPublicIpOnLaunch = true)  ← Mastery
│
├── Lambda Function: HelloWorldFunction  (Serverless)
│       └── Runtime: Node.js 20.x — inline Hello World handler
│
├── Elastic Beanstalk: hightech-med-web  (PaaS)
│       ├── Environment: production  (V1 = EB sample app)
│       └── Environment: test  (V2 = app-v2/)  ← created manually after deploy
│
└── ECS Fargate Cluster: hightech-med-cluster  (Container Orchestration)
        ├── Task Definition: hightech-med-api  (nginx, 0.25 vCPU / 512 MB)
        └── Service: hightech-med-api-service  (1 running task)
```

---

## Resources Provisioned by CloudFormation

| Resource | Name | Details |
|---|---|---|
| EC2 Key Pair | hightech-med-keypair | Private key stored in SSM Parameter Store |
| EC2 Security Group | hightech-med-ec2-sg | Port 22 (SSH) only — NOT all traffic |
| EC2 Instance | hightech-med-ec2 | Amazon Linux 2023 — t2.micro — public subnet |
| IAM Role | hightech-med-lambda-role | AWSLambdaBasicExecutionRole |
| Lambda Function | HelloWorldFunction | Node.js 20.x — inline sample code |
| IAM Role | hightech-med-eb-service-role | EB enhanced health + managed updates |
| IAM Role | hightech-med-eb-instance-role | AWSElasticBeanstalkWebTier |
| IAM Instance Profile | hightech-med-eb-instance-profile | Wraps EB instance role |
| EB Application | hightech-med-web | HighTech Medical web app |
| EB Environment | production | Single instance — EB sample app (V1) |
| EC2 Security Group | hightech-med-ecs-sg | Port 80 (HTTP) only |
| ECS Cluster | hightech-med-cluster | Fargate cluster |
| IAM Role | hightech-med-ecs-task-execution-role | AmazonECSTaskExecutionRolePolicy |
| ECS Task Definition | hightech-med-api | nginx — 256 CPU / 512 MB — Fargate |
| ECS Service | hightech-med-api-service | 1 task — public subnet — public IP |

---

## Deployment Instructions

### Step 0 — Verify EB Solution Stack Name (IMPORTANT)

The Elastic Beanstalk platform version changes with AWS patches. Run this to find the current valid stack name before deploying:

```powershell
$env:AWS_PAGER = ""
aws elasticbeanstalk list-available-solution-stacks `
  --query "SolutionStacks[?contains(@,'Node.js 20')]" `
  --output text
```

Copy one of the returned names (e.g. `64bit Amazon Linux 2023 v6.2.0 running Node.js 20`) — you will pass it as a parameter below.

---

### Step 1 — Deploy the CloudFormation stack

```powershell
$env:AWS_PAGER = ""
aws cloudformation deploy `
  --template-file "d:\Bow Valley college\SchoolWork-IntroToCloud\Project3\hightech-med-compute.yaml" `
  --stack-name hightech-med-compute `
  --capabilities CAPABILITY_NAMED_IAM `
  --parameter-overrides EBSolutionStack="64bit Amazon Linux 2023 v6.2.0 running Node.js 20"
```

> ⚠️ The Elastic Beanstalk environment takes **10–15 minutes** to reach Health: OK. Be patient.

---

### Step 2 — Download the EC2 Private Key

CloudFormation stores the key in AWS Systems Manager Parameter Store.

1. Go to **Systems Manager → Parameter Store**
2. Search for `/ec2/keypair/` — find the entry with description `hightech-med-keypair`
3. Click on it → **Show decrypted value** → copy the PEM content
4. Save to a file: `C:\Users\eddie\.ssh\hightech-med-keypair.pem`
5. In PowerShell, fix permissions so SSH accepts it:

```powershell
icacls "C:\Users\eddie\.ssh\hightech-med-keypair.pem" /inheritance:r /grant:r "$($env:USERNAME):R"
```

Get the EC2 public DNS:

```powershell
$env:AWS_PAGER = ""
aws cloudformation describe-stacks `
  --stack-name hightech-med-compute `
  --query "Stacks[0].Outputs[?OutputKey=='EC2PublicDns'].OutputValue" `
  --output text
```

---

### Step 3 — SSH into the EC2 Instance

```powershell
ssh -i "C:\Users\eddie\.ssh\hightech-med-keypair.pem" ec2-user@<EC2PublicDns>
```

> For the **video**: show the security group `hightech-med-ec2-sg` with port 22 only, show the instance is in a public subnet, and show the successful SSH connection.

---

### Step 4 — Configure and Execute the Lambda Test Event

1. Go to **Lambda → Functions → HelloWorldFunction**
2. Click the **Test** tab
3. Click **Create new event**
4. Event name: `TestEvent`
5. Event JSON:

```json
{
  "patientId": "P001",
  "action": "getRecord"
}
```

6. Click **Save** → **Test**
7. Confirm: green ✅ status 200 with `"Hello from HighTech Medical Lambda!"`

---

### Step 5 — Elastic Beanstalk V1 → V2 → Promote

#### Part A — Verify V1 (already deployed by CloudFormation)

1. Go to **Elastic Beanstalk → Applications → hightech-med-web → production**
2. Wait until Health shows **OK** (green)
3. Click the environment URL — you should see the EB sample page (**this is V1**)

#### Part B — Create a V2 application bundle

In PowerShell, create a ZIP of the `app-v2/` folder:

```powershell
Compress-Archive `
  -Path "d:\Bow Valley college\SchoolWork-IntroToCloud\Project3\app-v2\*" `
  -DestinationPath "d:\Bow Valley college\SchoolWork-IntroToCloud\Project3\app-v2.zip" `
  -Force
```

#### Part C — Upload V2 and create a test environment

```powershell
$env:AWS_PAGER = ""
# Upload V2 application bundle
aws elasticbeanstalk create-application-version `
  --application-name hightech-med-web `
  --version-label v2.0 `
  --source-bundle S3Bucket="elasticbeanstalk-us-east-1-503184055413",S3Key="app-v2.zip" `
  --auto-create-application-version-source-bundle `
  2>&1
```

**Easier via Console:**

1. In EB → Applications → hightech-med-web → **Application versions** tab
2. Click **Upload** → choose `app-v2.zip` → version label: `v2.0` → **Upload**
3. Select `v2.0` → **Actions → Deploy** → choose to deploy to a **new environment**
4. Environment name: `test` → same settings as production → **Create**
5. Wait for `test` environment to turn green

#### Part D — Promote test to production (swap URLs)

1. Go to **Elastic Beanstalk → Environments → production**
2. Click **Actions → Swap environment URLs**
3. Select `Environment to swap: test` → **Swap**
4. The test environment URL now serves V2 in production ✅

---

### Step 6 — Verify ECS Fargate Service

1. Go to **ECS → Clusters → hightech-med-cluster**
2. Click **Services** tab → `hightech-med-api-service`
3. Click **Tasks** tab → confirm **1/1** tasks are **RUNNING**
4. Click the running task → copy the **Public IP**
5. Open `http://<task-public-ip>` in a browser — should show the nginx welcome page

---

### Step 7 — Teardown (after recording video)

```powershell
$env:AWS_PAGER = ""
# Delete EB test environment first (if created)
aws elasticbeanstalk terminate-environment --environment-name test

# Then delete the CloudFormation stack
aws cloudformation delete-stack --stack-name hightech-med-compute
```

> ⚠️ Wait for the EB environment to fully terminate before deleting the stack, otherwise the stack deletion may hang.

---

## Video Presentation Checklist

### 1. Launch a Virtual Machine (EC2) — Mastery

- [ ] EC2 instance **"hightech-med-ec2"** — Status: Running
- [ ] **Networking tab** shows Public IPv4 address and a **public subnet**
- [ ] Security Group **"hightech-med-ec2-sg"** — Inbound rules: **port 22 TCP only** (NOT "All traffic")
- [ ] Successful SSH connection: terminal shows `[ec2-user@ip-... ~]$`
- [ ] *(Mastery)* Security group shows **specific port 22**, not "All traffic" rule

### 2. Provision a Serverless Function (Lambda) — Mastery

- [ ] Lambda function **"HelloWorldFunction"** in Lambda console — Runtime: Node.js 20.x
- [ ] Test event **"TestEvent"** configured on the **Test** tab
- [ ] Function executed — green ✅ result with **Status: 200** and `"Hello from HighTech Medical Lambda!"`
- [ ] *(Mastery)* Show EC2 security group with specific port 22 (same evidence as above)

### 3. Deploy a Web Application (Elastic Beanstalk) — Mastery

- [ ] EB Application **"hightech-med-web"** in EB console
- [ ] Environment **"production"** — Health: OK — URL serves the V1 sample app
- [ ] V2 uploaded as application version **"v2.0"**
- [ ] Environment **"test"** created with V2 deployed — Health: OK
- [ ] **Swap environment URLs** performed — V2 now promoted to production
- [ ] *(Mastery)* Show EC2 security group with specific port 22

### 4. Create an API using Container Orchestration (ECS Fargate) — Mastery

- [ ] ECS Cluster **"hightech-med-cluster"** in ECS console
- [ ] Task Definition **"hightech-med-api"** — Launch type: FARGATE, CPU: 256, Memory: 512
- [ ] Service **"hightech-med-api-service"** — **1/1 tasks RUNNING**
- [ ] nginx page accessible at `http://<task-public-ip>`
- [ ] *(Mastery)* Show EC2 security group with specific port 22

---

## Video Talking Points

### What is the difference between EC2, Lambda, Elastic Beanstalk, and ECS Fargate?

| Service | Type | You manage |
|---|---|---|
| EC2 | IaaS — raw VM | OS, runtime, app, scaling |
| Lambda | Serverless FaaS | Only the function code |
| Elastic Beanstalk | PaaS | Only the app code; EB handles infra |
| ECS Fargate | Serverless containers | Container image; AWS manages servers |

### Why use a specific port in the Security Group (rather than All traffic)?

Opening "All traffic" exposes the instance to every protocol and port, drastically increasing the attack surface. Opening only port 22 follows the **principle of least privilege** — the instance only accepts traffic it actually needs.

### What is a Fargate cluster?

A Fargate cluster is a logical grouping of ECS tasks running on AWS-managed serverless compute. You define what to run (Task Definition: container image, CPU, memory) and how many to run (Service: desired count), and AWS provisions the underlying servers invisibly.

### What is the benefit of a PaaS like Elastic Beanstalk?

PaaS abstracts away infrastructure management. Developers upload application code and EB automatically handles provisioning EC2 instances, setting up load balancers, deploying the application, and monitoring health. This lets teams focus on the application rather than the infrastructure.

### What does "promoting a test environment to production" mean?

Test environments run new code versions before they reach end users. After verifying V2 works correctly in the test environment, swapping URLs instantly redirects production traffic to the test environment — making it the new production. The old production becomes the new test environment, providing a quick rollback path if issues are found.
