# syntax=docker/dockerfile:1

FROM nvidia/cuda:12.8.0-runtime-ubuntu22.04 AS base

# Set working directory
WORKDIR /app

# Install system dependencies required for audio processing and building wheels
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3.10 \
        python3.10-venv \
        python3-pip \
        build-essential \
        ffmpeg \
        libsndfile1 \
        git \
        cmake \
        pkg-config \
        python3-dev \
        && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m seedvcuser

# Builder stage: install dependencies in a venv
FROM base AS builder

# Copy only requirements.txt first for better cache usage
COPY requirements.txt ./

# Create venv and install dependencies
RUN python3 -m venv .venv && \
    .venv/bin/pip install --upgrade pip && \
    .venv/bin/pip install --upgrade setuptools wheel && \
    .venv/bin/pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128 && \
    .venv/bin/pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Final stage: minimal runtime image
FROM base AS final

# Copy app code and venv from builder
COPY --from=builder /app /app
COPY --from=builder /app/.venv /app/.venv

# Set environment variables
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1
ENV CUDA_LAUNCH_BLOCKING=1

# Optimize for various GPU architectures
ENV TORCH_CUDA_ARCH_LIST="7.5 8.0 8.6 8.9 9.0"

# Use first GPU by default
ENV CUDA_VISIBLE_DEVICES=0

# Set permissions and switch to non-root user
RUN chown -R seedvcuser:seedvcuser /app
USER seedvcuser

# Expose Gradio default port
EXPOSE 7860

# Default command: run the main web UI with both V1 and V2 enabled
CMD ["python", "app.py", "--enable-v1", "--enable-v2", "--server-name", "0.0.0.0"] 