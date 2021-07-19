# InfraAutomation

terraform init -backend-config=region=us-east-1 -backend-config=bucket=infrabucket01 -backend-config=key=app.tfstate

terraform apply -var-file="app-input.tfvars"
