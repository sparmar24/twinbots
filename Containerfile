FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim

WORKDIR /app
COPY web-apps /app/web-apps
COPY packages /app/packages
COPY dbt_chatbots /app/dbt_chatbots
COPY pyproject.toml /app/pyproject.toml
COPY uv.lock /app/uv.lock

ENV DBT_PROFILES_DIR=/app/dbt_chatbots 
ENV DBT_PROJECT_DIR=/app/dbt_chatbots 
RUN uv sync --all-packages --all-groups 
EXPOSE 8000

CMD ["uv", "run", "web-apps/manage.py", "runserver", "0.0.0.0:8000"]
