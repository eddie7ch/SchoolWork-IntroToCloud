# Project 1 — Implement Permission Management using IAM

**Course:** Introduction to Cloud
**Assessment:** Module 1 — Implementing Permission Management Using IAM
**Stack Name Suggestion:** `hightech-med-iam`

---

## Architecture Overview

```
IAM Resources
│
├── Group: EC2Admins  ──────────────────► Policy: AmazonEC2FullAccess (AWS Managed)
│       │
│       └── User: Peter
│               ├── MFA Device          ← Must be configured manually
│               └── Access Keys         ← Must be configured manually
│
└── Policy: StorageAccessPolicy (S3 Full Access)
        │
        └── Role: SampleAppRole
                └── Trust Policy: Allow ec2.amazonaws.com to assume this role
```

---

## Resources Provisioned by CloudFormation

| Resource | Name | Details |
|---|---|---|
| IAM Group | EC2Admins | Attached: `AmazonEC2FullAccess` (AWS Managed) |
| IAM User | Peter | Member of EC2Admins group — login enabled |
| IAM Policy | StorageAccessPolicy | `s3:*` on `arn:aws:s3:::*` and `arn:aws:s3:::*/*` |
| IAM Role | SampleAppRole | Attached: StorageAccessPolicy — Trust: `ec2.amazonaws.com` |

---

## Deployment Instructions

### Step 1 — Deploy via AWS CloudFormation

1. Sign in to the [AWS Console](https://console.aws.amazon.com/).
2. Navigate to **CloudFormation → Stacks → Create stack → With new resources**.
3. Choose **Upload a template file** and upload `hightech-med-iam.yaml`.
4. Stack name: `hightech-med-iam` → click **Next**.
5. Enter a **temporary password** for Peter (min 8 chars, must meet AWS password policy).
6. Click **Next → Next → Submit**. Wait for `CREATE_COMPLETE`.

### Step 2 — Configure MFA for Peter (manual)

1. Go to **IAM → Users → Peter → Security credentials** tab.
2. Under **Multi-factor authentication (MFA)** → click **Assign MFA device**.
3. Choose **Authenticator app** → scan the QR code with your phone → enter two consecutive codes.
4. Click **Add MFA**.

### Step 3 — Create Access Keys for Peter (manual)

1. Stay on **IAM → Users → Peter → Security credentials** tab.
2. Under **Access keys** → click **Create access key**.
3. Choose use case: **Command Line Interface (CLI)** → acknowledge → click **Next → Create**.
4. **Download the `.csv` file** or copy the keys — they are only shown once.

### Step 4 — Log in as Peter (required for Mastery)

1. Get the **Account ID** from the top-right corner of the AWS Console.
2. Go to: `https://<account-id>.signin.aws.amazon.com/console`
3. Sign in as **Peter** using the temporary password (you will be asked to set a new one).
4. Verify you are logged in as Peter — confirm EC2 access works.

---

## Video Presentation Checklist

Show each of the following in your video:

- [ ] IAM Group **"EC2Admins"** in the Groups section
- [ ] **"AmazonEC2FullAccess"** policy listed in EC2Admins → Permissions policies
- [ ] IAM User **"Peter"** in the Users section
- [ ] **"EC2Admins"** listed in Peter → Groups tab (User groups membership)
- [ ] MFA device listed in Peter → Security credentials → Multi-factor authentication (MFA)
- [ ] Access Keys listed in Peter → Security credentials → Access keys
- [ ] IAM Policy **"StorageAccessPolicy"** in the Policies section
- [ ] IAM Role **"SampleAppRole"** in the Roles section
- [ ] **"StorageAccessPolicy"** listed in SampleAppRole → Permissions tab
- [ ] Trust relationship in SampleAppRole → Trust relationships tab showing `ec2.amazonaws.com`
- [ ] *(Mastery)* Sign in as Peter and show successful login

---

## Video Talking Points

### Benefits of using IAM Groups
- Facilitate propagation of permissions based on work function
- Centralize changes for permission updates (change once, applies to all members)
- Allow reusability of policies across multiple users

### What does it mean to assume a Role?
- A user or service gains **temporary access** to perform actions in the Cloud
- Role assumption allows trusted identities to perform actions using temporary credentials

### Benefit of Multi-Factor Authentication (MFA)
- Increases security — requires two sets of credentials to access the AWS account
- Expands security beyond username/password with an additional authentication method

### How are permissions via a Group different from direct user permissions?
- **Group permissions:** Inherited by all members — centrally managed, easy to update
- **Direct user permissions:** Individual to that user only — harder to manage at scale; not recommended

### What is the impact if SampleAppRole needs to be assumed by Lambda instead of EC2?
- The trust policy principal would need to change from `ec2.amazonaws.com` to `lambda.amazonaws.com`
- The current trust policy only allows EC2 — Lambda would be denied

### How to restrict StorageAccessPolicy to only bucket "myapp.techschool.com"?
- Update the `Resource` section of the policy to:
  ```json
  "Resource": [
    "arn:aws:s3:::myapp.techschool.com",
    "arn:aws:s3:::myapp.techschool.com/*"
  ]
  ```

---

## Submission

- **Filename format:** `lastname_firstname_assessment_part_1`
- **Upload to:** Project 1: Implement Permission Management using IAM while demonstrating attention to detail (Dropbox folder)
