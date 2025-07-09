    # Stage 1: Builder
    FROM python:3.11-alpine AS builder
    
    # Install system dependencies for building Python packages
    RUN apk add --no-cache build-base

    # Set working directory
    WORKDIR /app

    # Copy only requirements to leverage Docker caching
    COPY requirements.txt .
    
    # Install dependencies into /install
    RUN pip install --prefix=/install --no-cache-dir -r requirements.txt

    # Stage 2: Runtime
    FROM python:3.11-alpine

    # Install runtime dependencies (no dev tools)
    RUN apk add --no-cache libstdc++ libffi

    # Copy installed packages from builder stage
    COPY --from=builder /install /usr/local

    # Copy application code
    WORKDIR /app
    COPY . /app

    # Expose port
    EXPOSE 8000

    # Run the app
    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]