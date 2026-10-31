FROM python:3.14-slim-trixie
LABEL Author="Raja Subramanian" Description="A comprehensive docker image to run python automation workers."

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install the tesseract binary and English language data, plus Camoufox's
# Firefox runtime libraries and a virtual display server to run it headless.
RUN apt-get update && \
    apt-get install -y --no-install-recommends tesseract-ocr tesseract-ocr-eng \
        xvfb x11-utils xauth \
        libgtk-3-0 libdbus-glib-1-2 libxt6 libasound2 \
        libdbus-1-3 libdrm2 libgbm1 libnspr4 libnss3 \
        libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 \
        libatk1.0-0 libatk-bridge2.0-0 libcups2 \
        wget gnupg ca-certificates xdg-utils fonts-liberation && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app

RUN pip install --no-cache-dir -r requirements.txt && \
    playwright install --only-shell --with-deps chromium && \
    python -m camoufox fetch && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# debian slim does not have curl, use a substitute
COPY --chmod=755 --chown=root:root curl.py /usr/local/bin/curl.py 

COPY --chmod=755 docker-entrypoint.sh /app/docker-entrypoint.sh

EXPOSE 5000

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["/bin/bash"]
