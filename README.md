# InfraAutomation


1. Update the django default settings [api/settings.py] for ALLOWED_HOSTS = ['*'] or the domain for allowing incoming request, ex: ALLOWED_HOSTS = ['.tessian.com'].
2. The image has inbuild superuser created as [appuser] and default password as [dummypassword]. The default Password can be overwitten by passing environment value for DJANGO_SUPERUSER_PASSWORD.
3. Need to add health URL for LB to pass health checks. (with /admin, gets redirect to login, hence targets remain unhealthy, thus to have a health check introduced).
ex: https://stackoverflow.com/questions/32920688/how-to-setup-health-check-page-in-django; https://django-health-check.readthedocs.io/en/latest/readme.html#use-cases 

terraform init -backend-config=region=us-east-1 -backend-config=bucket=infrabucket01 -backend-config=key=app1.tfstate

terraform apply -var-file="terraform.tfvars"
