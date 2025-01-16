FROM python:3.12-bookworm
LABEL Author="Raja Subramanian" Description="A comprehensive docker image to run python automation workers."

WORKDIR /app

COPY requirements.txt /app

RUN pip install -r requirements.txt && \
  playwright install --only-shell --with-deps chromium && \
  apt-get clean

EXPOSE 5000

CMD /bin/bash
