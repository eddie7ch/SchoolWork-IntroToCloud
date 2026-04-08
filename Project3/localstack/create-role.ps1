# create-role.ps1
# Creates a dummy IAM execution role for Lambda in LocalStack.
# LocalStack doesn't enforce IAM but still requires a valid ARN.

$env:AWS_ENDPOINT_URL    = "http://localhost:4566"
$env:AWS_DEFAULT_REGION  = "us-east-1"
$env:AWS_ACCESS_KEY_ID   = "test"
$env:AWS_SECRET_ACCESS_KEY = "test"

Write-Host "Creating IAM Lambda execution role in LocalStack..." -ForegroundColor Yellow

$trustPolicy = @'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "lambda.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
'@

aws iam create-role `
    --role-name lambda-role `
    --assume-role-policy-document $trustPolicy `
    --output json 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "IAM role 'lambda-role' created." -ForegroundColor Green
} else {
    Write-Host "Role may already exist — continuing." -ForegroundColor Gray
}
