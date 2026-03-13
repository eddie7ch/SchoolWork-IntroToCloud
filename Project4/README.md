# Project 4 — Configure Storage Solutions

**Course:** Introduction to Cloud
**Assessment:** Module 4 — Configure Storage Solutions while Demonstrating Adaptability
**Stack Name:** `hightech-med-storage`

---

## Architecture Overview

```
Storage Resources
│
├── S3 Bucket: lab.hightechmed.com  (object storage)
│       └── Folder: xrays/
│               └── sample-xray.jpg
│
├── EBS Volume: hightechvolume  (block storage)
│       └── Attached to EC2: ebs-test  (as secondary drive /dev/xvdf)
│
└── EFS File System: shared-api-files  (network filesystem)
        └── Mounted on EC2: efs-test  at /api-storage/shared-api-files
```

---

## Resources Provisioned

| Resource | Name | Details |
|---|---|---|
| S3 Bucket | lab.hightechmed.com | Object storage for lab exam files |
| S3 Folder | xrays/ | Inside the bucket |
| S3 Object | sample-xray.jpg | Inside the xrays/ folder |
| EBS Volume | hightechvolume | 8 GB gp3 — secondary drive on ebs-test |
| EC2 Instance | ebs-test | Amazon Linux 2023 — t2.micro |
| EFS File System | shared-api-files | Mounted at /api-storage/shared-api-files on efs-test |
| EC2 Instance | efs-test | Amazon Linux 2023 — t2.micro |
| Security Group | hightechmed-storage-sg | Port 22 (SSH) only |
| Security Group | hightechmed-efs-sg | Port 2049 (NFS) from EC2 SG only |

---

## Deployment Instructions

### Step 1 — Create the S3 Bucket and upload the file

> Note: S3 bucket names are globally unique. Use `lab<unique-id>.hightechmed.com` if `lab.hightechmed.com` is taken.

```powershell
# Create the bucket
aws s3api create-bucket --bucket lab.hightechmed.com --region us-east-1

# Create the xrays folder (upload a placeholder)
aws s3api put-object --bucket lab.hightechmed.com --key xrays/

# Upload sample-xray.jpg
aws s3 cp "d:\Bow Valley college\SchoolWork-IntroToCloud\Project4\sample-xray.jpg" s3://lab.hightechmed.com/xrays/sample-xray.jpg
```

### Step 2 — Deploy the CloudFormation stack (EBS + EC2 + EFS)

```powershell
aws cloudformation deploy `
  --template-file "d:\Bow Valley college\SchoolWork-IntroToCloud\Project4\hightech-med-storage.yaml" `
  --stack-name hightech-med-storage `
  --capabilities CAPABILITY_NAMED_IAM
```

Wait for `CREATE_COMPLETE` (~3-5 minutes).

### Step 3 — Delete the stack when done recording

```powershell
aws cloudformation delete-stack --stack-name hightech-med-storage
aws s3 rm s3://lab.hightechmed.com --recursive
aws s3api delete-bucket --bucket lab.hightechmed.com
```

---

## Video Presentation Checklist

- [ ] S3 Bucket **"lab.hightechmed.com"** in Buckets section of S3 Console
- [ ] Folder **"xrays"** in the Objects section of the bucket
- [ ] File **"sample-xray.jpg"** inside the xrays folder
- [ ] EBS Volume **"hightechvolume"** in Volumes section of EC2 Console
- [ ] EC2 instance **"ebs-test"** running — Storage tab shows "hightechvolume" as secondary drive
- [ ] EFS file system **"shared-api-files"** in File systems section of EFS Console
- [ ] EC2 instance **"efs-test"** running — EFS mounted at `/api-storage/shared-api-files`
- [ ] *(Mastery)* Show Security Group with **specific port 22 only** — NOT all traffic

---

## Talking Points for Video

**S3 features to reduce cost for infrequently accessed files:**
- Storage class "Infrequent Access"
- Storage class "S3 Intelligent-Tiering"

**Best storage for high IOPS (55,000–60,000):**
- Amazon EBS with volume type **io1**

**Benefits of EFS (Network File System):**
- Same filesystem can be mounted on multiple VMs simultaneously
- Scalable — grows/shrinks automatically with no provisioning needed

**Patient data in S3 — security considerations:**
- Keep objects private (Block Public Access enabled)
- Enable encryption at rest (SSE-S3 or SSE-KMS)
- Use bucket policies to restrict access

---

## Submission

- **Filename format:** `lastname_firstname_assessment_part_1`
- **Upload to:** Project 4: Configure Storage Solutions while demonstrating adaptability (Dropbox folder)
