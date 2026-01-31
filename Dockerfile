FROM python:3.12-slim-bookworm
LABEL Author="Raja Subramanian" Description="A comprehensive docker image to run python automation workers."

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install the tesseract binary and English language data
RUN apt-get update && \
    apt-get install -y --no-install-recommends tesseract-ocr tesseract-ocr-eng && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app

# debian slim does not have curl, use a substitute
COPY --chmod=755 --chown=root:root curl.py /usr/local/bin/curl.py 

RUN pip install --no-cache-dir -r requirements.txt && \
    playwright install --only-shell --with-deps chromium && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 5000

CMD /bin/bash
