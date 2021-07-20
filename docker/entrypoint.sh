#!/bin/bash

if [[ ${RUN_MIGRATIONS} == "yes" ]]
        then
        echo "[INFO] Running migrations......."
        poetry run python manage.py makemigrations
        poetry run python manage.py migrate
else
        echo "[INFO] Skipping migrations........"
fi

echo "[INFO] Starting application server......"
#poetry run python manage.py runserver
exec $@
