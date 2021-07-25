# InfraAutomation

Pre-requisites:
1. Update the django default settings [api/settings.py] for ALLOWED_HOSTS = ['*'] or the domain for allowing incoming request, ex: ALLOWED_HOSTS = ['.tessian.com'].
2. The image has inbuild superuser created as [appuser] and default password as [dummypassword]. The default Password can be overwitten by passing environment value for DJANGO_SUPERUSER_PASSWORD.



terraform init -backend-config=region=us-east-1 -backend-config=bucket=infrabucket01 -backend-config=key=app.tfstate

terraform apply -var-file="app-input.tfvars"
