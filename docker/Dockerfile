ARG PYTHON_VERSION=3.9.6
FROM python:${PYTHON_VERSION}-slim-buster as base

ENV PYTHONUNBUFFERED=1 \
        PYTHONDONTWRITEBYTECODE=1 \
        PIP_NO_CACHE_DIR=off \
        PIP_DISABLE_PIP_VERSION_CHECK=on \
        PIP_DEFAULT_TIMEOUT=100 \
        POETRY_VIRTUALENVS_IN_PROJECT=true \
        POETRY_NO_INTERACTION=1

ENV APP_HOME /app
ENV RUN_MIGRATIONS yes

RUN apt-get update && \
        apt-get install -y curl build-essential &&\
        curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -

ENV PATH="${PATH}:/root/.poetry/bin:/root/.local/bin"

WORKDIR ${APP_HOME}

# dev image
FROM base as dev

COPY ./src/ .
COPY ./entrypoint.sh .

ENV PYTHONPATH=${PYTHONPATH}:${PWD}

RUN chmod +x entrypoint.sh && \
        pip3 install poetry && \
        poetry install

EXPOSE 8000

ENTRYPOINT ["/app/entrypoint.sh"]

CMD ["poetry","run","python","manage.py","runserver"]

