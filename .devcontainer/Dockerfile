FROM mcr.microsoft.com/devcontainers/base:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    texlive-full \
    fonts-noto \
    fonts-noto-cjk \
    python3 \
    python3-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*
