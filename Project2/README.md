# Project 2 — Implement Network in the Cloud

**Course:** Introduction to Cloud  
**Assessment:** Module 2 — Implementing Network in the Cloud  
**Stack Name Suggestion:** `hightech-med-network`

---

## Architecture Overview

```
100.0.0.0/16  (HighTechMed VPC)
│
├── public-subnet-1   100.0.1.0/24  (AZ-a)  ──► Internet Gateway (HighTechMedIGw)
├── public-subnet-2   100.0.2.0/24  (AZ-b)  ──►     "
│                                                     │
├── private-subnet-1  100.0.3.0/24  (AZ-a)  ──► NAT Gateway  (HighTechMedNatGw)
└── private-subnet-2  100.0.4.0/24  (AZ-b)  ──►     "
```

Each `/24` subnet provides **251 usable IP addresses** (256 − 5 AWS-reserved).

---

## Resources Provisioned

| Resource | Name | Details |
|---|---|---|
| VPC | HighTechMed | CIDR `100.0.0.0/16` |
| Public Subnet 1 | public-subnet-1 | `100.0.1.0/24` — AZ 0 |
| Public Subnet 2 | public-subnet-2 | `100.0.2.0/24` — AZ 1 |
| Private Subnet 1 | private-subnet-1 | `100.0.3.0/24` — AZ 0 |
| Private Subnet 2 | private-subnet-2 | `100.0.4.0/24` — AZ 1 |
| Internet Gateway | HighTechMedIGw | Attached to HighTechMed VPC |
| NAT Gateway | HighTechMedNatGw | Placed in public-subnet-1 |
| Public Route Table | HighTechMedPublic | `0.0.0.0/0` → IGW |
| Private Route Table | HighTechMedPrivate | `0.0.0.0/0` → NAT GW |
| Security Group | HighTechMedLoadBalancer | TCP port 80 from `0.0.0.0/0` |

---

## Deployment Instructions

### Option A — AWS Management Console (CloudFormation)

1. Sign in to the [AWS Console](https://console.aws.amazon.com/).
2. Navigate to **CloudFormation → Stacks → Create stack → With new resources**.
3. Choose **Upload a template file** and upload `hightech-med-network.yaml`.
4. Stack name: `hightech-med-network` → click **Next**.
5. Leave parameters as default → click **Next → Next → Submit**.
6. Wait for the stack status to reach **CREATE_COMPLETE** (~3–5 min for the NAT Gateway).

### Option B — AWS CLI

```bash
aws cloudformation deploy \
  --stack-name hightech-med-network \
  --template-file hightech-med-network.yaml \
  --region us-east-1
```

---

## Verification Checklist (for video presentation)

- [ ] **VPC** — VPC Console → Your VPCs → `HighTechMed` with CIDR `100.0.0.0/16`
- [ ] **Public Subnets** — Subnets → filter by VPC → names prefixed `public-`, 251 available IPs each
- [ ] **Private Subnets** — Subnets → names prefixed `private-`, 251 available IPs each
- [ ] **Route Table (Public)** — Route Tables → `HighTechMedPublic` → Routes tab shows `0.0.0.0/0` → IGW; Subnet Associations tab shows public subnets
- [ ] **Route Table (Private)** — Route Tables → `HighTechMedPrivate` → Routes tab shows `0.0.0.0/0` → NAT GW; Subnet Associations tab shows private subnets
- [ ] **Internet Gateway** — Internet Gateways → `HighTechMedIGw` → State: Attached to `HighTechMed`
- [ ] **NAT Gateway** — NAT Gateways → `HighTechMedNatGw` → State: Available, subnet = `public-subnet-1`
- [ ] **Security Group** — Security Groups → `HighTechMedLoadBalancer` → Inbound rule: TCP 80 from `0.0.0.0/0`

---

## Key Concepts (Video Talking Points)

### What makes a subnet public?
A subnet is public when its route table contains a route that directs internet-bound traffic (`0.0.0.0/0`) to an **Internet Gateway**. Resources launched in public subnets can be assigned public IP addresses and are reachable from the internet.

### What is the purpose of a NAT Gateway?
A NAT Gateway allows instances in **private subnets** to initiate outbound connections to the internet (e.g., to download software updates) without exposing them to inbound traffic from the internet. The NAT Gateway itself resides in a public subnet and holds an Elastic IP.

### What is a Security Group?
A Security Group acts as a **virtual firewall at the instance/resource level**. It controls inbound and outbound traffic using allow-rules. The `HighTechMedLoadBalancer` security group permits HTTP traffic on port 80 from anywhere (`0.0.0.0/0`), making it suitable for a load balancer that serves web traffic.

---

## Teardown

To avoid ongoing charges (especially for the NAT Gateway and Elastic IP):

```bash
aws cloudformation delete-stack --stack-name hightech-med-network
```
