
FROM ubuntu:22.04
LABEL maintainer="Jean Carlo <the best email ever>"
LABEL description="This is a Dockerfile for my app hello."
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip
COPY requirements.txt /app/requirements.txt
RUN pip3 install -r /app/requirements.txt
COPY . /app
WORKDIR /app
CMD ["python3", "main.py"]

EXPOSE 5000