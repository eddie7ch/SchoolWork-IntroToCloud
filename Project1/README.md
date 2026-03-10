# Project 1 — Implement Permission Management using IAM

**Course:** Introduction to Cloud  
**Assessment:** Module 1 — Implementing Permission Management Using IAM  
**Stack Name Suggestion:** `hightech-med-iam`

---

## Resources Provisioned

| Resource | Name | Details |
|---|---|---|
| IAM Group | EC2Admins | Attached: `AmazonEC2FullAccess` (AWS managed) |
| IAM User | Peter | Member of `EC2Admins`; console + programmatic access |
| Access Key | — | Programmatic credentials for Peter |
| IAM Managed Policy | StorageAccessPolicy | `s3:*` on all buckets and objects |
| IAM Role | SampleAppRole | Attached: `StorageAccessPolicy`; trusted by EC2 |

> **Manual step — MFA:** CloudFormation cannot register an MFA device on behalf of a user.  
> After deploying the stack, log in as Peter and follow the MFA setup steps below.

---

## Architecture / Permission Model

```
┌─────────────────────────────────────────────────────┐
│  IAM Group: EC2Admins                               │
│    └── AmazonEC2FullAccess  (AWS managed policy)   │
│           └── IAM User: Peter  (group member)       │
│                  ├── Console login (password)       │
│                  ├── MFA device  ← manual step      │
│                  └── Access Key (programmatic)      │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  IAM Role: SampleAppRole                            │
│    ├── StorageAccessPolicy  (s3:* on *)             │
│    └── Trust policy → ec2.amazonaws.com             │
└─────────────────────────────────────────────────────┘
```

---

## Deployment Instructions

### Option A — AWS Management Console (CloudFormation)

1. Sign in to the [AWS Console](https://console.aws.amazon.com/).
2. Navigate to **CloudFormation → Stacks → Create stack → With new resources**.
3. Choose **Upload a template file** and upload `hightech-med-iam.yaml`.
4. Stack name: `hightech-med-iam` → click **Next**.
5. Enter a secure value for `PeterInitialPassword` → click **Next → Next → Submit**.
6. Wait for the stack to reach **CREATE_COMPLETE**.
7. Open the **Outputs** tab and **copy the `PeterSecretAccessKey` value immediately** — it is displayed only once.

### Option B — AWS CLI

```bash
aws cloudformation create-stack \
  --stack-name hightech-med-iam \
  --template-body file://hightech-med-iam.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameters ParameterKey=PeterInitialPassword,ParameterValue="ChangeMe123!"
```

Retrieve outputs after creation:

```bash
aws cloudformation describe-stacks \
  --stack-name hightech-med-iam \
  --query "Stacks[0].Outputs"
```

---

## Manual Step — Configure MFA for Peter

CloudFormation cannot register an MFA device. After the stack is deployed:

1. Log in to the AWS Console as **Peter** using the console password set during deployment.
2. Navigate to **IAM → Users → Peter → Security credentials**.
3. Under **Multi-factor authentication (MFA)**, click **Assign MFA device**.
4. Choose **Authenticator app** (virtual MFA) or a hardware key.
5. Follow the on-screen instructions to scan the QR code and enter two consecutive codes.
6. Click **Add MFA**.

---

## Key Concepts

### Why use Groups instead of attaching policies directly to a User?
- **Centralized management** — changing the group's policy propagates to all members instantly.
- **Reusability** — the same policy can be reused across many users by adding them to the group.
- **Cleaner audit trail** — permissions tied to a job function, not to individuals.

### Permissions from Group vs. directly attached
A user's effective permissions are the **union** of:
1. Policies attached directly to the user.
2. Policies inherited from all groups the user belongs to.

There is no precedence — both sources are additive (unless an explicit `Deny` is present).

### What does "assuming a Role" mean?
An identity (user or service) calls `sts:AssumeRole` and receives **temporary credentials** scoped to that role's policies. The original identity's credentials are not used for the actions performed under the role.

### EC2 vs. Lambda trust policy
| Service | Principal value |
|---|---|
| EC2 | `ec2.amazonaws.com` |
| Lambda | `lambda.amazonaws.com` |

To allow Lambda to assume `SampleAppRole`, change the trust policy's `Service` field to `lambda.amazonaws.com` (or add it as a second principal).

### Restricting StorageAccessPolicy to a single bucket
Replace the `Resource` block in the policy with:

```json
"Resource": [
  "arn:aws:s3:::myapp.techschool.com",
  "arn:aws:s3:::myapp.techschool.com/*"
]
```

The first ARN covers bucket-level actions (e.g. `s3:ListBucket`); the second covers object-level actions (e.g. `s3:GetObject`, `s3:PutObject`).

### Why use MFA?
MFA requires two independent credentials — something you know (password) and something you have (authenticator app or hardware key). A compromised password alone is not sufficient to gain access, significantly reducing the risk of unauthorized access.

---

## Video Presentation Checklist

- [ ] IAM Group **EC2Admins** visible in IAM → Groups
- [ ] **AmazonEC2FullAccess** listed in EC2Admins → Permissions
- [ ] IAM User **Peter** visible in IAM → Users
- [ ] **EC2Admins** listed in Peter → Groups tab
- [ ] MFA device listed in Peter → Security credentials tab
- [ ] Access Key listed in Peter → Security credentials tab
- [ ] IAM Policy **StorageAccessPolicy** visible in IAM → Policies
- [ ] IAM Role **SampleAppRole** visible in IAM → Roles
- [ ] **StorageAccessPolicy** listed in SampleAppRole → Permissions tab
- [ ] EC2 trust relationship visible in SampleAppRole → Trust relationships tab
