#!/bin/bash

SUPERUSER_NAME=appuser
SUPERUSER_EMAIL=appuser@tessian.com

if [[ ${RUN_MIGRATIONS} == "yes" ]]
        then
        echo "[INFO] Running migrations......."
        poetry run python manage.py makemigrations
        poetry run python manage.py migrate
else
        echo "[INFO] Skipping migrations........"
fi

echo "[INFO] Creating Superuser [${SUPERUSER_NAME}]....."
poetry run python manage.py createsuperuser --username=${SUPERUSER_NAME} --email=${SUPERUSER_EMAIL} --no-input

echo "[INFO] Starting application server......"
#poetry run python manage.py runserver
exec $@
