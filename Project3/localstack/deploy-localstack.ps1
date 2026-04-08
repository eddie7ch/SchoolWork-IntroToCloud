# deploy-localstack.ps1
# HighTech Medical — LocalStack Deployment Script (Windows / PowerShell)
# Project 3: Configure Compute Services
#
# Prerequisites:
#   1. Docker Desktop running
#   2. From this folder: docker compose up -d
#   3. Wait ~20 sec for LocalStack to be healthy
#   4. Run: .\deploy-localstack.ps1
#
# What is tested locally:
#   [1] CloudFormation — deploys infrastructure/template.yaml
#   [2] S3             — creates hightechmed-images + hightechmed-thumbnails buckets
#   [3] IAM            — creates Lambda execution role
#   [4] Lambda         — packages, deploys, and invokes ThumbnailGenerator
#   [5] ECS            — creates cluster, registers task definition, creates service
#   [6] Verification   — lists all deployed resources
#
# NOT tested (not supported in LocalStack free tier):
#   - Elastic Beanstalk (simulated — see note in Step 3 output)
#   - EC2 SSH (LocalStack starts instances but SSH is not reachable)

$ErrorActionPreference = "Stop"

# ── LocalStack endpoint — all AWS CLI calls go here automatically ──
$env:AWS_ENDPOINT_URL      = "http://localhost:4566"
$env:AWS_DEFAULT_REGION    = "us-east-1"
$env:AWS_ACCESS_KEY_ID     = "test"
$env:AWS_SECRET_ACCESS_KEY = "test"
$env:AWS_PAGER             = ""

$SCRIPT_DIR = $PSScriptRoot

# ──────────────────────────────────────────────
# Helper: print step header
# ──────────────────────────────────────────────
function Write-Step {
    param([string]$Number, [string]$Title)
    Write-Host ""
    Write-Host "[$Number] $Title" -ForegroundColor Cyan
    Write-Host ("-" * 50) -ForegroundColor DarkGray
}

# ──────────────────────────────────────────────
# 0. Health check — make sure LocalStack is up
# ──────────────────────────────────────────────
Write-Host ""
Write-Host "================================================" -ForegroundColor Magenta
Write-Host "  HighTech Medical — LocalStack Deployment" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Magenta

Write-Step "0" "Checking LocalStack health"
try {
    $health = Invoke-RestMethod -Uri "http://localhost:4566/_localstack/health" -TimeoutSec 5
    Write-Host "LocalStack is running." -ForegroundColor Green
} catch {
    Write-Host "ERROR: LocalStack is not reachable at http://localhost:4566" -ForegroundColor Red
    Write-Host "Start it first: docker compose up -d" -ForegroundColor Yellow
    exit 1
}

# ──────────────────────────────────────────────
# 1. CloudFormation — deploy network template
# ──────────────────────────────────────────────
Write-Step "1" "Deploying CloudFormation stack (infrastructure/template.yaml)"

$cfnTemplate = Join-Path $SCRIPT_DIR "..\infrastructure\template.yaml"
if (-not (Test-Path $cfnTemplate)) {
    # Fall back to the original course template in Project 3 root
    $cfnTemplate = Join-Path $SCRIPT_DIR "..\template.yaml"
}

Write-Host "Using template: $cfnTemplate" -ForegroundColor Gray

aws cloudformation create-stack `
    --stack-name hightechmed-stack `
    --template-body "file://$cfnTemplate" `
    --capabilities CAPABILITY_NAMED_IAM `
    --parameters ParameterKey=ProjectId,ParameterValue=hightechmed `
    --output json 2>&1 | Write-Host

Write-Host "Waiting for stack to reach CREATE_COMPLETE..." -ForegroundColor Gray
aws cloudformation wait stack-create-complete --stack-name hightechmed-stack
Write-Host "CloudFormation stack ready." -ForegroundColor Green

# ──────────────────────────────────────────────
# 2. S3 — create buckets and upload test image
# ──────────────────────────────────────────────
Write-Step "2" "Creating S3 buckets"

aws s3 mb s3://hightechmed-images    --output text
aws s3 mb s3://hightechmed-thumbnails --output text
Write-Host "Buckets created: hightechmed-images, hightechmed-thumbnails" -ForegroundColor Green

# Upload the sample X-ray from Project 4 if it exists
$sampleXray = Join-Path $SCRIPT_DIR "..\..\Project4\sample-xray.jpg"
if (Test-Path $sampleXray) {
    Write-Host "Uploading sample-xray.jpg to LocalStack S3..." -ForegroundColor Gray
    aws s3 cp $sampleXray s3://hightechmed-images/xrays/sample-xray.jpg --output text
    Write-Host "Test image uploaded." -ForegroundColor Green
} else {
    Write-Host "sample-xray.jpg not found — skipping upload (Lambda test will use simulated event)." -ForegroundColor Yellow
}

# ──────────────────────────────────────────────
# 3. Elastic Beanstalk — not supported in LocalStack free tier
# ──────────────────────────────────────────────
Write-Step "3" "Elastic Beanstalk (simulated)"
Write-Host "NOTE: Elastic Beanstalk is NOT supported in LocalStack free tier." -ForegroundColor Yellow
Write-Host "      This step is simulated. To test EB:" -ForegroundColor Yellow
Write-Host "      - Deploy hightech-med-compute.yaml to real AWS, OR" -ForegroundColor Yellow
Write-Host "      - Use LocalStack Pro (paid) which has full EB support." -ForegroundColor Yellow
Write-Host "      For the video: deploy to real AWS and show the EB console." -ForegroundColor Yellow

# ──────────────────────────────────────────────
# 4. IAM + Lambda — package, create, invoke
# ──────────────────────────────────────────────
Write-Step "4a" "Creating IAM Lambda execution role"
& "$SCRIPT_DIR\create-role.ps1"
Start-Sleep -Seconds 2

Write-Step "4b" "Packaging Lambda function"
$lambdaSourceDir = Join-Path $SCRIPT_DIR "lambda\ThumbnailGeneratorCode"
$lambdaZip       = Join-Path $SCRIPT_DIR "lambda\ThumbnailGeneratorCode.zip"

if (Test-Path $lambdaZip) { Remove-Item $lambdaZip -Force }
Compress-Archive -Path "$lambdaSourceDir\*" -DestinationPath $lambdaZip
Write-Host "Lambda packaged: $lambdaZip" -ForegroundColor Green

Write-Step "4c" "Creating Lambda function in LocalStack"
aws lambda create-function `
    --function-name ThumbnailGenerator `
    --runtime nodejs20.x `
    --handler index.handler `
    --zip-file "fileb://$lambdaZip" `
    --role "arn:aws:iam::000000000000:role/lambda-role" `
    --description "HighTech Medical — medical image thumbnail generator" `
    --output json 2>&1 | Write-Host

Write-Host "Waiting for Lambda to become active..." -ForegroundColor Gray
Start-Sleep -Seconds 3

Write-Step "4d" "Invoking Lambda with test S3 event"
$eventFile   = Join-Path $SCRIPT_DIR "lambda\ThumbnailGeneratorEvent.json"
$outputFile  = Join-Path $SCRIPT_DIR "lambda-output.json"

aws lambda invoke `
    --function-name ThumbnailGenerator `
    --payload "file://$eventFile" `
    --cli-binary-format raw-in-base64-out `
    $outputFile `
    --output json

Write-Host ""
Write-Host "Lambda response:" -ForegroundColor Cyan
Get-Content $outputFile | ConvertFrom-Json | ConvertTo-Json -Depth 5
Write-Host ""

# ──────────────────────────────────────────────
# 5. ECS — cluster, task definition, service
# ──────────────────────────────────────────────
Write-Step "5a" "Creating ECS Fargate cluster"
aws ecs create-cluster `
    --cluster-name HighTechMed `
    --output json 2>&1 | Write-Host
Write-Host "ECS cluster 'HighTechMed' created." -ForegroundColor Green

Write-Step "5b" "Registering ECS task definition"
$taskDefFile = Join-Path $SCRIPT_DIR "ecs\AppointmentsApiTaskDefinitions.json"
aws ecs register-task-definition `
    --cli-input-json "file://$taskDefFile" `
    --output json 2>&1 | Write-Host
Write-Host "Task definition 'Appointments' registered." -ForegroundColor Green

Write-Step "5c" "Creating ECS service"
aws ecs create-service `
    --cluster HighTechMed `
    --service-name AppointmentsApi `
    --task-definition Appointments `
    --desired-count 1 `
    --output json 2>&1 | Write-Host
Write-Host "ECS service 'AppointmentsApi' created." -ForegroundColor Green

# ──────────────────────────────────────────────
# 6. Verify all resources
# ──────────────────────────────────────────────
Write-Step "6" "Verifying deployed resources"

Write-Host ""
Write-Host "Lambda functions:" -ForegroundColor White
aws lambda list-functions --query "Functions[].{Name:FunctionName,Runtime:Runtime}" --output table

Write-Host ""
Write-Host "ECS clusters:" -ForegroundColor White
aws ecs list-clusters --output table

Write-Host ""
Write-Host "ECS services in HighTechMed:" -ForegroundColor White
aws ecs list-services --cluster HighTechMed --output table

Write-Host ""
Write-Host "S3 buckets:" -ForegroundColor White
aws s3 ls

Write-Host ""
Write-Host "CloudFormation stacks:" -ForegroundColor White
aws cloudformation list-stacks `
    --stack-status-filter CREATE_COMPLETE `
    --query "StackSummaries[].{Name:StackName,Status:StackStatus}" `
    --output table

# ──────────────────────────────────────────────
# Done
# ──────────────────────────────────────────────
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  Deployment Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Resources running in LocalStack:" -ForegroundColor White
Write-Host "  Lambda   -> ThumbnailGenerator (Node.js 20.x)" -ForegroundColor Gray
Write-Host "  ECS      -> HighTechMed cluster / AppointmentsApi service" -ForegroundColor Gray
Write-Host "  S3       -> hightechmed-images / hightechmed-thumbnails" -ForegroundColor Gray
Write-Host "  CFN      -> hightechmed-stack (VPC, subnets, security groups)" -ForegroundColor Gray
Write-Host ""
Write-Host "To tear down: aws cloudformation delete-stack --stack-name hightechmed-stack" -ForegroundColor DarkGray
Write-Host "              docker compose down" -ForegroundColor DarkGray
