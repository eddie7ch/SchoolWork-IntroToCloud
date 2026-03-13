# Project 5 — Set up Database Services

**Course:** Introduction to Cloud
**Assessment:** Module 5 — Set up Database Services while Demonstrating Attention to Detail
**Stack Name:** `hightech-med-database`

---

## Architecture Overview

```
Database Resources
│
├── RDS Aurora MySQL Cluster: scheduling
│       ├── Primary instance:   scheduling-primary
│       ├── Read replica:       scheduling-secondary
│       └── Snapshot:           scheduling-backup-1  ← taken manually after deploy
│
├── DynamoDB Table: patients
│       ├── Item added:         patient-sample-item.json
│       └── Item updated:       lastName → "Foster"
│
└── ElastiCache Redis: api-cache
        ├── Primary node
        └── Read replica:       secondary (node 2 in cluster)
```

---

## ⚠️ Important: Use Aurora MySQL, NOT plain MySQL

The rubric requires **"Aurora with MySQL compatibility"** — not plain MySQL.  
This template uses `Engine: aurora-mysql` which is correct.

---

## Resources Provisioned by CloudFormation

| Resource | Name | Details |
|---|---|---|
| RDS Cluster | scheduling | Aurora MySQL 8.0 — encrypted |
| RDS Instance (primary) | scheduling-primary | db.t3.medium |
| RDS Instance (read replica) | scheduling-secondary | db.t3.medium |
| DynamoDB Table | patients | PAY_PER_REQUEST billing |
| ElastiCache Replication Group | api-cache | Redis — 2 nodes (primary + replica) |
| Security Group | hightechmed-rds-sg | Port 3306 only |
| Security Group | hightechmed-cache-sg | Port 6379 only |

---

## Deployment Instructions

### Step 1 — Deploy the CloudFormation stack

```powershell
aws cloudformation deploy `
  --template-file "d:\Bow Valley college\SchoolWork-IntroToCloud\Project5\hightech-med-database.yaml" `
  --stack-name hightech-med-database `
  --capabilities CAPABILITY_NAMED_IAM `
  --parameter-overrides DBMasterPassword=YourPassword123!
```

> ⚠️ RDS + ElastiCache take **10-15 minutes** to fully deploy. Be patient.

### Step 2 — Take RDS snapshot (manual step)

```powershell
aws rds create-db-cluster-snapshot `
  --db-cluster-identifier scheduling `
  --db-cluster-snapshot-identifier scheduling-backup-1
```

### Step 3 — Add patient item to DynamoDB

```powershell
aws dynamodb put-item `
  --table-name patients `
  --item file://"d:\Bow Valley college\SchoolWork-IntroToCloud\Project5\patient-sample-item.json"
```

### Step 4 — Update patient last name to "Foster"

```powershell
aws dynamodb update-item `
  --table-name patients `
  --key '{"patientId": {"S": "P001"}}' `
  --update-expression "SET lastName = :newName" `
  --expression-attribute-values '{":newName": {"S": "Foster"}}'
```

### Step 5 — Delete the stack when done recording

```powershell
aws cloudformation delete-stack --stack-name hightech-med-database
```

> ⚠️ Note: RDS deletion takes 5-10 minutes. DynamoDB table and ElastiCache will also be deleted.

---

## Video Presentation Checklist

- [ ] RDS Cluster **"scheduling"** in Clusters section — Engine: Aurora MySQL
- [ ] Read replica **"scheduling-secondary"** listed as instance in the cluster
- [ ] Snapshot **"scheduling-backup-1"** in Snapshots section
- [ ] DynamoDB table **"patients"** in Tables section
- [ ] Patient item visible in the table (Items tab)
- [ ] Patient item updated — lastName shows **"Foster"**
- [ ] ElastiCache cluster **"api-cache"** in Redis clusters section
- [ ] Read replica node **"secondary"** visible in the cluster
- [ ] *(Mastery)* Show Security Groups — **specific ports only** (3306, 6379) — NOT all traffic
- [ ] *(Mastery)* Show snapshot is **encrypted**

---

## Talking Points for Video

**What type of databases are provisioned via RDS?**
- Relational databases

**What is the use of Read Replicas for Amazon RDS clusters?**
- Allow you to elastically scale out beyond the capacity constraints of a single DB instance
- Used for read-heavy database workloads

**Do DynamoDB Tables support SQL queries?**
- No — DynamoDB is a NoSQL service

**Benefits of caching systems (ElastiCache)?**
- Store pre-processed data, removing load from databases
- Low latency and high throughput data access
- Boost application performance when data does not change frequently

---

## Submission

- **Filename format:** `lastname_firstname_assessment_part_1`
- **Upload to:** Project 5: Set up Database Services while demonstrating attention to detail (Dropbox folder)
