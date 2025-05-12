## Docker Deployment 🐳

You can run Seed-VC easily using Docker for a reproducible environment. The provided Dockerfile is based on **Python 3.10-slim** and installs all required system dependencies for audio processing, including `ffmpeg` and `libsndfile1`. The default Gradio web UI port **7860** is exposed.

### Build & Run with Docker Compose

1. **Build and start the service:**
   ```bash
   docker compose up --build
   ```
   This will build the image and start the app using the integrated web UI (`app.py`) with both V1 and V2 models enabled by default.

2. **Access the Web UI:**
   Open your browser and go to [http://localhost:7860/](http://localhost:7860/)

### Project-specific Docker Details
- **Base image:** `python:3.10-slim`
- **System dependencies installed:** `ffmpeg`, `libsndfile1`, `build-essential`, `git`
- **Non-root user:** Runs as `seedvcuser` for improved security
- **Python environment:** All dependencies are installed in a virtual environment (`.venv`)
- **Default command:**
  ```bash
  python app.py --enable-v1 --enable-v2
  ```
  (You can override this in `docker-compose.yml` if needed)
- **Exposed port:** `7860` (Gradio web UI)

### Environment Variables
- No required environment variables by default.
- If you need to use a Hugging Face mirror, set `HF_ENDPOINT=https://hf-mirror.com` as an environment variable (can be added to a `.env` file and uncommented in `docker-compose.yml`).

### Customization
- To run a different entrypoint or pass custom arguments, override the `command` in `docker-compose.yml`.
- No persistent volumes or external services are required for this application.

> **Note:** All model checkpoints will be downloaded automatically on first run. If you have custom checkpoints/configs, mount them into the container and adjust the startup command accordingly.
