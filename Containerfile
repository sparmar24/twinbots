FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

WORKDIR /app
COPY web-apps /app/web-apps
COPY pyproject.toml /app/pyproject.toml
COPY uv.lock /app/uv.lock

RUN uv sync --all-packages --all-groups 
  
EXPOSE 8000

CMD ["uv", "run", "web-apps/manage.py", "runserver", "0.0.0.0:8000"]
