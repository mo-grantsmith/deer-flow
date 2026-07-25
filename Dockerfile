FROM ghcr.io/astral-sh/uv:python3.12-bookworm

# Install uv.
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Install system dependencies including libpq
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*
    
WORKDIR /app

# Pre-cache the application dependencies.
COPY uv.lock pyproject.toml ./
RUN uv sync --locked --no-install-project

# Copy the application into the container.
COPY . /app

# Install the application dependencies.
RUN \
    uv sync --locked

EXPOSE 8000

# Run the application.
RUN useradd -m appuser
USER appuser

CMD ["/app/.venv/bin/python", "server.py", "--host", "0.0.0.0", "--port", "8000"]
