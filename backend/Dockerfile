FROM python:3.12-slim

WORKDIR /app

# Install dependencies
# Supports both repo-root build context (backend/requirements.txt)
# and backend-folder build context (requirements.txt)
COPY backend/requirements.txt ./requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

# Copy source from backend subfolder
COPY backend/ .

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
