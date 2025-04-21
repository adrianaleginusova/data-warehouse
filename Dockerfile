FROM python:3.10-slim
RUN pip install dbt-core dbt-postgres
WORKDIR /usr/app
COPY dbt /usr/app/dbt
ENV DBT_PROFILES_DIR=/usr/app/dbt
