FROM python:3.10-slim

RUN apt-get update && apt-get install -y \
    libglib2.0-0 \
    libgomp1 \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt huggingface_hub

COPY . .

# Download model from HF Model Hub at build time
RUN python -c "from huggingface_hub import hf_hub_download; hf_hub_download(repo_id='mehakrazzaq2/visionpay-model', filename='visionpay_combined_best.pt', local_dir='/app')"

ENV MODEL_PATH=/app/visionpay_combined_best.pt
ENV DB_PATH=/tmp/visionpay.db

EXPOSE 7860

CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "7860"]
