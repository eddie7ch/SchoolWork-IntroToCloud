# Introduction to Cloud — ALL PROJECT INSTRUCTIONS, REQUIREMENTS & RUBRICS
**Course:** Introduction to Cloud (Bow Valley College)
**Student:** Eddie Chongtham
**All projects due:** April 18, 2026 at 11:59 PM
**Submission format:** Video presentation (screen share + camera recording of yourself)
**Submission filename format:** `lastname_firstname_assessment_part_1`

---

## HOW TO USE THIS FILE WITH GITHUB COPILOT
Paste the full contents of this file into GitHub Copilot chat on any machine and say:
> "Save all of this to memory for future use — this is my Introduction to Cloud course project instructions and rubrics for all 5 projects."

---

## COURSE OVERVIEW

### Grade Breakdown
| Grade Item | Points |
|---|---|
| Engagement | / 10 |
| Assignments (5 Projects) | / 90 |
| Virtual Private Cloud Overview | / 100 |

Each project = 25 points. All due April 18, 2026 at 11:59 PM.

### General Instructions
- Access all parts of the assessment from the course page
- Review all 5 Rubrics to ensure all required items are covered
- Submit evidence into the Dropbox folders for each part
- Multiple attempts allowed
- Complete each part in order (recommended)
- Submission filename: `chongtham_eddie_project_#`

### AWS Setup
- AWS Account ID: 503184055413
- Region: us-east-1
- Default VPC: vpc-0535c1f88ffcd21b4
- AMI: ami-02dfbd4ff395f2a1b (Amazon Linux 2023)
- Instance type: t2.micro (free tier)
- S3 bucket: lab503184055413.hightechmed.com

---

## PROJECT 1: Implement Permission Management using IAM
**Points:** 25 | **Module:** 1 | **Submission file:** `chongtham_eddie_project_1`

### Scenario
HighTech Medical is a security-first company. As the junior Site Reliability Engineer, collaborate with the team to implement the correct security model in AWS. Provision IAM resources (Users, Groups, Roles) and assess capabilities of the service. End with a walk-through presentation to your supervisor.

### Instructions (What to Build)
1. Create an IAM Group named **"EC2Admins"** and assign it the AWS managed policy **"AmazonEC2FullAccess"**
2. Create an IAM User named **"Peter"**
3. Assign IAM Group **"EC2Admins"** to the IAM User **"Peter"**
4. Configure **multi-factor authentication (MFA)** for IAM User "Peter"
5. Configure **Access Keys** for IAM User "Peter"
6. Create IAM Policy named **"StorageAccessPolicy"** that provides access to **all buckets in Amazon S3**
7. Create an IAM Role named **"SampleAppRole"** and assign it the policy **"StorageAccessPolicy"**
8. Update the IAM Role **"SampleAppRole"** with a **trust policy** to allow EC2 instances to assume it

### Video Checklist (must show all of these)
1. IAM Group **"EC2Admins"** exists in Groups section
2. IAM Policy **"AmazonEC2FullAccess"** is associated with "EC2Admins"
3. IAM User **"Peter"** exists in Users section
4. IAM Group **"EC2Admins"** is associated with User "Peter"
5. MFA is enabled for User "Peter"
6. Access Keys are provisioned for User "Peter"
7. IAM Policy **"StorageAccessPolicy"** with access to all S3 buckets
8. IAM Role **"SampleAppRole"** exists in Roles section
9. IAM Policy **"StorageAccessPolicy"** is associated with "SampleAppRole"
10. Role **"SampleAppRole"** Trust Relationship allows **EC2 service** to assume it

### Talking Points for Video
- **Benefits of Groups:** Facilitate propagation of permissions based on work function; centralize permission changes; allow for reusability of policies
- **What does it mean to assume a Role?** A User or Service can gain temporary access to perform actions; role assumption allows trusted identities to perform actions using temporary credentials
- **Benefit of two-factor authentication:** Increases security — requires two sets of credentials; expands security beyond traditional username/password
- **How to restrict StorageAccessPolicy to a specific bucket?** Update the resource section to only include the ARN for bucket "myapp.techschool.com"

### Rubric (6 pts total)

| Criterion | Mastery (3pts) | Competent (2pts) | Developing (1pt) | Incomplete (0) |
|---|---|---|---|---|
| Configure users and groups | All Competent + validate login as IAM user | Create Group + AmazonEC2FullAccess; Create User; Assign Group to User; Configure MFA; Configure Access Keys | Missing items | Incomplete evidence |
| Create IAM Policy, Role, Trust Policy | All Competent + validate login as IAM user | Create IAM Policy for S3; Create IAM Role + assign policy; Update trust policy to allow EC2 to assume it | Missing items | Incomplete evidence |

**KEY FOR MASTERY:** Must validate you can **log in as IAM User "Peter"**

### CloudFormation File
`Project1/hightech-med-iam.yaml` — already built and resources already exist in AWS from March 10, 2026.

### Deploy Command (if needed)
```powershell
aws cloudformation deploy --template-file "d:\Bow Valley college\SchoolWork-IntroToCloud\Project1\hightech-med-iam.yaml" --stack-name hightech-med-iam --capabilities CAPABILITY_NAMED_IAM
```

---

## PROJECT 2: Implement Network in the Cloud
**Points:** 25 | **Module:** 2 | **Submission file:** `chongtham_eddie_project_2`

### Scenario (Email from Manager Sara Tuerski)
> The Site Reliability Engineering team is exploring Networking services in the Cloud. They are proud of the solution currently implemented on premises and they would like to maintain that level of performance and security after the migration to AWS is completed. You have been tasked with setting up a Virtual Private Cloud (VPC) that can host the applications securely. You will be provisioning Network resources like VPC, Subnets, Internet and NAT Gateways and Security Groups to assess the capabilities of the services. At the end of the iteration, you will be doing a walk-through presentation of your findings.

### Instructions (What to Build)
1. Create a VPC named **"HighTechMed"** using CIDR block **"100.0.0.0/16"**
2. Create private subnets with name prefix **"private-"**
3. Create public subnets with name prefix **"public-"**
4. Create a Route Table named **"HighTechMedPublic"** for public routing
5. Associate **"HighTechMedPublic"** with the public subnets
6. Create a Route Table named **"HighTechMedPrivate"** for private routing
7. Associate **"HighTechMedPrivate"** with the private subnets
8. Create an Internet Gateway named **"HighTechMedIGw"**
9. Attach the Internet Gateway to VPC **"HighTechMed"**
10. Create a NAT Gateway named **"HighTechMedNatGw"**
11. Update routes to allow public subnets to access internet through the Internet Gateway
12. Update routes to allow private subnets to access internet through the NAT Gateway
13. Create a Security Group named **"HighTechMedLoadBalancer"**
14. Add a rule to the security group to allow traffic on **port 80** from the internet

### Video Checklist (must show all of these)
1. VPC **"HighTechMed"** — CIDR block `100.0.0.0/16`
2. Private subnets — names prefixed "private-", 251 IP addresses each
3. Public subnets — names prefixed "public-", 251 IP addresses each
4. Route Table **"HighTechMedPublic"** — associated with public subnets
5. Route Table **"HighTechMedPrivate"** — associated with private subnets
6. Internet Gateway **"HighTechMedIGw"** — attached to "HighTechMed" VPC
7. Route table "HighTechMedPublic" sends internet traffic to Internet Gateway
8. NAT Gateway **"HighTechMedNatGw"** — associated with "HighTechMed" VPC
9. Route table "HighTechMedPrivate" sends internet traffic to NAT Gateway
10. Security Group **"HighTechMedLoadBalancer"** — has rule allowing port 80 from internet

### Talking Points for Video
- **What makes a subnet public?** Public subnets have traffic routing configured to an Internet Gateway; resources in them are internet-facing
- **Purpose of a NAT Gateway?** Allows resources in private subnets to access the internet without exposing them to internet traffic; allows private servers to download package updates
- **What is a Security Group?** A firewall at the instance level; allows for traffic control to prevent malicious agents from accessing resources

### Rubric (12 pts total)

| Criterion | Mastery (3pts) | Competent (2pts) | Developing (1pt) | Incomplete (0) |
|---|---|---|---|---|
| Create VPC and Subnets | All Competent + at least 3-4 subnets | Create VPC using provided CIDR; Create private subnets; Create public subnets | Missing items | Incomplete |
| Provision Gateways for Internet Access | All Competent + at least 3-4 subnets | Create IGW + attach to VPC; Create NAT GW + attach to VPC | Missing items | Incomplete |
| Configure Routing | All Competent + routes in correct place | Create Route Table; Public subnets → IGW; Private subnets → NAT GW | Missing items | Incomplete |
| Security Group | All Competent + correctly added inbound rule | Create Security Group; Add rule to allow port 80 | Missing items | Incomplete |

**KEY FOR MASTERY:** At least 3-4 subnets (YAML has 4: 2 public + 2 private ✅); routes in correct tables; SG inbound rule correctly added

### CloudFormation File
`Project2/hightech-med-network.yaml` — already built, tested, and verified working.

### Deploy Command (run when ready to record)
```powershell
aws cloudformation deploy --template-file "d:\Bow Valley college\SchoolWork-IntroToCloud\Project2\hightech-med-network.yaml" --stack-name hightech-med-network --capabilities CAPABILITY_NAMED_IAM
```

### Delete Command (run after recording)
```powershell
aws cloudformation delete-stack --stack-name hightech-med-network
```

---

## PROJECT 3: Configure Compute Services
**Points:** 25 | **Module:** 3 | **Submission file:** `chongtham_eddie_project_3`

### Scenario (Email from Manager Sara Tuerski)
> Hi, So glad to have you on the team. To begin, first provision a bastion host that will be used to connect to internal resources securely. You will then provision a Lambda function to host the code used to create thumbnails for user profile pictures. The next task will be deploying the company's landing page using a PaaS solution. Finally, you will be provisioning a Service in ECS to run the Appointments API that takes care of handling the schedule for patient visits.
>
> There is some work already done by other members of the team that made sure their work was reusable by creating CloudFormation templates you will be leveraging as you work through provisioning the resources.

### Instructions (What to Build)
1. Deploy pre-required infrastructure using **CloudFormation template.yaml** (from assessment files)
2. Create a Key Pair named **"Bastion"**
3. Launch an EC2 Instance named **"BastionHost"** using the "Bastion" Key Pair
4. Connect to the EC2 "BastionHost" instance via **SSH**
5. Create a Lambda function named **"ThumbnailGenerator"** using `ThumbnailGeneratorCode.zip`
6. Configure a test event named **"ThumbnailGeneratorEvent"** using `ThumbnailGeneratorEvent.json`
7. Execute Lambda function **"ThumbnailGenerator"** using the **"ThumbnailGeneratorEvent"** test event
8. Deploy NodeJS web app in **Elastic Beanstalk** named **"HighTechMedLandingPage"** using `HighTechMedLandingPageCodeV1.zip`
   - Name initial environment **"HighTechMedLandingPageV1"**
   - Use a DNS prefix that reflects it is tied to **production**
9. Create a **test environment** named **"HighTechMedLandingPageV2"** using `HighTechMedLandingPageCodeV2.zip`
10. **Promote the test environment to production**
11. Provision a **Fargate cluster in ECS** named **"HighTechMed"**
12. Register a **Task Definition** named **"Appointments"** using `AppointmentsApiTaskDefinitions.json`
13. Create a **Service** named **"AppointmentsApi"** in the cluster using the task definition

### Assessment Files Needed (download from course portal)
- `template.yaml` — CloudFormation pre-required infrastructure (ALREADY IN REPO: Project3/template.yaml)
- `ThumbnailGeneratorCode.zip` — Lambda function code
- `ThumbnailGeneratorEvent.json` — Lambda test event
- `HighTechMedLandingPageCodeV1.zip` — Elastic Beanstalk v1 code
- `HighTechMedLandingPageCodeV2.zip` — Elastic Beanstalk v2 code
- `AppointmentsApiTaskDefinitions.json` — ECS Task Definition

### Video Checklist (must show all of these)
1. Key Pair **"Bastion"** in Key pairs section
2. EC2 instance **"BastionHost"** running — associated with "Bastion" key pair, configured for SSH
3. SSH connection established to "BastionHost"
4. Lambda function **"ThumbnailGenerator"** in Functions section
5. Test event **"ThumbnailGeneratorEvent"** configured for the function
6. Lambda function executes successfully and produces expected result
7. Web application **"HighTechMedLandingPage"** in Elastic Beanstalk Applications
8. App URL shows **first version** of landing page
9. Test environment URL shows **second version** of landing page
10. Promoting test → production shows **second version** at main URL
11. ECS cluster **"HighTechMed"** in Clusters section
12. Task Definition **"Appointments"** in Task definitions section
13. ECS Service **"AppointmentsApi"** in cluster — at least one task running

### Talking Points for Video
- **Why use a KeyPair?** Security credentials to prove identity when connecting to EC2
- **Advantages of AWS Lambda (serverless):** Manages all infrastructure on highly available, fault-tolerant infrastructure; never need to update OS; built-in logging/monitoring via CloudWatch
- **Benefits of PaaS (Elastic Beanstalk):** Removes need to manage underlying infrastructure; focus on deployment and management of applications only
- **Containers vs VMs:** Containers are lightweight software packages with all dependencies; VMs are heavy packages providing complete emulation of low-level hardware

### Rubric (12 pts total)

| Criterion | Mastery (3pts) | Competent (2pts) | Developing (1pt) | Incomplete (0) |
|---|---|---|---|---|
| Launch a VM — EC2 | All Competent + show SSH port in SG; show instance in public subnet; specific port only (NOT all traffic) | Create Key Pair; Launch EC2 using Key Pair; Connect via SSH | Missing items | Incomplete |
| Serverless Function — Lambda | All Competent + show SSH port in SG; instance in public subnet; specific port only | Create Lambda using sample code; Configure test event; Execute function using test event | Missing items | Incomplete |
| PaaS Web App — Elastic Beanstalk | All Competent + show SSH port in SG; instance in public subnet; specific port only | Deploy using V1 code; Create test env using V2 code; Promote test to production | Missing items | Incomplete |
| Container API — ECS Fargate | All Competent + show SSH port in SG; instance in public subnet; specific port only | Provision Fargate cluster; Register Task Definition; Create Service using task definition | Missing items | Incomplete |

**KEY FOR MASTERY (all 4 criteria):**
- Show where **SSH port was opened** in the EC2 security group
- Show that instance was **launched in a public subnet**
- Show that only a **specific port was opened** — NOT all traffic

### Status
- `Project3/template.yaml` is in the repo (instructor's base template)
- Still need: zip files + JSON files from course portal before this can be built

---

## PROJECT 4: Configure Storage Solutions
**Points:** 25 | **Module:** 4 | **Submission file:** `chongtham_eddie_project_4`

### Scenario (Email from Manager Sara Tuerski)
> Hi, The team is now moving into investigating storage options. Sean, the director of engineering has established the need for solutions in three major areas: object storage, block storage and network filesystems.
>
> You will first provision an S3 Bucket to store files tied to lab exams. Next you will evaluate the performance of EBS volumes that will be used for local storage. Finally in order to provide support for high-availability to legacy applications that need to store files locally, you will provision an EFS file system that will be mounted into all instances of the legacy API.

### Instructions (What to Build)

**S3:**
1. Create an S3 Bucket named **"lab.hightechmed.com"** (name `lab503184055413.hightechmed.com` was used — globally unique)
2. Create a folder named **"xrays"** in the bucket
3. Upload file **"sample-xray.jpg"** to the "xrays" folder

**EBS:**
4. Create an EBS volume named **"hightechvolume"**
5. Launch an EC2 instance named **"ebs-test"** using the EBS volume as a **secondary storage drive**

**EFS:**
6. Create an EFS file system named **"shared-api-files"**
7. Launch an EC2 instance named **"efs-test"** using the EFS file system

### Assessment Files Needed
- `sample-xray.jpg` — file to upload to S3 (a placeholder was created; download real one from course portal if available)

### Video Checklist (must show all of these)
1. S3 Bucket **"lab503184055413.hightechmed.com"** in Buckets section
2. Folder **"xrays"** in the Objects section of the bucket
3. File **"sample-xray.jpg"** inside the "xrays" folder
4. EBS Volume **"hightechvolume"** in Volumes section
5. EC2 instance **"ebs-test"** running — "hightechvolume" attached as **secondary drive** (visible in Storage tab)
6. EFS file system **"shared-api-files"** in File systems section
7. EC2 instance **"efs-test"** running — "shared-api-files" mounted at `/api-storage/shared-api-files`
8. *(Mastery)* Show Security Group with **specific port only** — NOT all traffic (port 22 for SSH, 2049 for NFS)

### Talking Points for Video
- **S3 cost savings for infrequently accessed files:** Use storage class "Infrequent Access" or "S3 Intelligent-Tiering"
- **Best EBS for high IOPS (55,000–60,000)?** Amazon EBS io1 volume type
- **Benefits of EFS (Network File System)?** Same filesystem can be mounted in multiple VMs; scalability — grows/shrinks automatically

### Rubric (9 pts total)

| Criterion | Mastery (3pts) | Competent (2pts) | Developing (1pt) | Incomplete (0) |
|---|---|---|---|---|
| S3 Object Storage | All Competent + specific port only (NOT all traffic) | Create S3 Bucket; Create folder; Upload object | Missing items | Incomplete |
| EBS Block Storage | All Competent + specific port only (NOT all traffic) | Create EBS volume; Launch EC2 using EBS as secondary drive | Missing items | Incomplete |
| EFS Network Filesystem | All Competent + specific port only (NOT all traffic) | Create EFS volume; Launch EC2 using EFS | Missing items | Incomplete |

**KEY FOR MASTERY:** Must show a **specific port opened** in the security group — NOT all traffic — visible in the video

### CloudFormation File
`Project4/hightech-med-storage.yaml` — built and verified working.

### Deploy Command (run when ready to record)
```powershell
aws cloudformation deploy --template-file "d:\Bow Valley college\SchoolWork-IntroToCloud\Project4\hightech-med-storage.yaml" --stack-name hightech-med-storage --capabilities CAPABILITY_NAMED_IAM --parameter-overrides VpcId=vpc-0535c1f88ffcd21b4 SubnetId=subnet-066da30b3133e9bee
```

### Delete Command (run after recording — S3 must be deleted separately)
```powershell
aws cloudformation delete-stack --stack-name hightech-med-storage
aws s3 rm s3://lab503184055413.hightechmed.com --recursive
aws s3api delete-bucket --bucket lab503184055413.hightechmed.com
```

---

## PROJECT 5: Set up Database Services
**Points:** 25 | **Module:** 5 | **Submission file:** `chongtham_eddie_project_5`

### Scenario (Email from Manager Sara Tuerski)
> The experiments performed so far have been a big success and the CTO is incredibly excited. For the final iteration, you will be working with databases and caching systems. The development team needs a relational database system to migrate the scheduling system as well as a NoSQL database to store the patient information. As a last requirement, the developers asked you to look into a service that could serve as a destination for the api cache that is currently hosted in a Redis cluster on-premises. You will be provisioning database resources like RDS Clusters, DynamoDB tables and ElastiCache Clusters in order to assess the capabilities of the services.

### Instructions (What to Build)

**RDS (Relational Database):**
1. Create an RDS Cluster for MySQL (Aurora MySQL) named **"scheduling"**
2. Add a read replica named **"scheduling-secondary"** to the cluster
3. Take a database snapshot named **"scheduling-backup-1"**

**DynamoDB (NoSQL):**
4. Create a DynamoDB table named **"patients"**
5. Add an item using **"patient-sample-item.json"** (from assessment files)
6. Modify the item — update the **last name** to **"Foster"**

**ElastiCache (Redis):**
7. Deploy an ElastiCache cluster for Redis named **"api-cache"**
8. Add a node with a read replica named **"secondary"**

### Assessment Files Needed
- `patient-sample-item.json` — sample patient data (download real one from course portal; current placeholder is in Project5/)

### Video Checklist (must show all of these)
1. RDS Cluster **"scheduling"** — Engine: Aurora MySQL
2. Read replica **"scheduling-secondary"** listed in the cluster
3. Snapshot **"scheduling-backup-1"** in Snapshots section
4. DynamoDB table **"patients"** in Tables section
5. Patient item visible in the table
6. Patient item updated — lastName shows **"Foster"**
7. ElastiCache cluster **"api-cache"** in Redis clusters section
8. Read replica node **"secondary"** visible in the cluster
9. *(Mastery)* Show Security Groups with **specific ports only** (3306 for MySQL, 6379 for Redis)
10. *(Mastery)* Show snapshot is **encrypted**

### Talking Points for Video
- **What type of databases via RDS?** Relational databases
- **Use of Read Replicas?** Elastically scale out beyond capacity of a single DB instance for read-heavy workloads
- **Do DynamoDB Tables support SQL?** No — DynamoDB is a NoSQL service
- **Benefits of ElastiCache (caching)?** Store pre-processed data, removing load from databases; low latency and high throughput; boosts performance when data doesn't change frequently

### Rubric (9 pts total)

| Criterion | Mastery (3pts) | Competent (2pts) | Developing (1pt) | Incomplete (0) |
|---|---|---|---|---|
| RDS — Relational Database | All Competent + correct engine (Aurora MySQL); snapshot is encrypted | Create RDS Cluster for **Aurora with MySQL compatibility**; Add read replica; Take snapshot | Missing items | Incomplete |
| DynamoDB — NoSQL | All Competent + correct engine; snapshot encrypted | Create DynamoDB table; Add item; Modify item | Missing items | Incomplete |
| ElastiCache — Redis | All Competent + correct engine; snapshot encrypted | Deploy ElastiCache cluster for Redis; Add node | Missing items | Incomplete |

**KEY FOR MASTERY:**
- RDS must be **Aurora with MySQL compatibility** (NOT plain MySQL)
- **Snapshot must be encrypted**
- Security groups must use **specific ports only**

### CloudFormation File
`Project5/hightech-med-database.yaml` — built and verified working.

### Deploy Command (run when ready to record — takes 15-20 min)
```powershell
aws cloudformation deploy --template-file "d:\Bow Valley college\SchoolWork-IntroToCloud\Project5\hightech-med-database.yaml" --stack-name hightech-med-database --capabilities CAPABILITY_NAMED_IAM --parameter-overrides DBMasterPassword=HighTechMed2024!
```

### Post-Deploy Steps (must do after stack is CREATE_COMPLETE)
```powershell
# 1. Take RDS snapshot
aws rds create-db-cluster-snapshot --db-cluster-identifier scheduling --db-cluster-snapshot-identifier scheduling-backup-1

# 2. Add patient item to DynamoDB
aws dynamodb put-item --table-name patients --item file://"d:\Bow Valley college\SchoolWork-IntroToCloud\Project5\patient-sample-item.json"

# 3. Update lastName to Foster
aws dynamodb update-item --table-name patients --key '{"patientId": {"S": "P001"}}' --update-expression "SET lastName = :newName" --expression-attribute-values '{":newName": {"S": "Foster"}}'
```

### Delete Command (run after recording)
```powershell
aws cloudformation delete-stack --stack-name hightech-med-database
```

---

## OVERALL PROGRESS TRACKER

| Project | CloudFormation YAML | AWS Status | Video Recorded | Submitted |
|---|---|---|---|---|
| P1 — IAM | Project1/hightech-med-iam.yaml | Resources exist in AWS (manual) | No | No |
| P2 — Network | Project2/hightech-med-network.yaml | Tested/deleted — redeploy to record | No | No |
| P3 — Compute | Project3/template.yaml (partial) | BLOCKED — needs course portal files | No | No |
| P4 — Storage | Project4/hightech-med-storage.yaml | Deleted — redeploy to record | No | No |
| P5 — Database | Project5/hightech-med-database.yaml | Deleted — redeploy to record | No | No |

## WHAT IS STILL NEEDED
1. **Project 3 course files** (from Canvas/Brightspace): `ThumbnailGeneratorCode.zip`, `ThumbnailGeneratorEvent.json`, `HighTechMedLandingPageCodeV1.zip`, `HighTechMedLandingPageCodeV2.zip`, `AppointmentsApiTaskDefinitions.json`
2. **Real patient-sample-item.json** for Project 5 (instructor's version from course portal)
3. **Record videos** for all 5 projects
4. **Submit** each video to the correct Dropbox folder

## COST WARNING
- P4 + P5 stacks together cost ~$0.16/hr (mainly RDS Aurora)
- Only deploy when you're ready to record immediately
- Delete right after recording
- P2 stack has a NAT Gateway (~$0.045/hr) — same rule applies
