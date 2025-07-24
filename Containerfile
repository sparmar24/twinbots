FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim

WORKDIR /twinbots
COPY web-apps /twinbots/web-apps
COPY packages /twinbots/packages
COPY dbt_chatbots /twinbots/dbt_chatbots
COPY pyproject.toml /twinbots/pyproject.toml
COPY uv.lock /twinbots/uv.lock

ENV DBT_PROFILES_DIR=/twinbots/dbt_chatbots
ENV DBT_PROJECT_DIR=/twinbots/dbt_chatbots
RUN uv sync --all-packages --all-groups
EXPOSE 8000

CMD ["uv", "run", "web-apps/manage.py", "runserver", "0.0.0.0:8000"]
