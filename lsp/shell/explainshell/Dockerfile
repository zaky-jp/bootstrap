# syntax=docker/dockerfile:1
FROM python:2.7

# remove auto-clean to enable caching
RUN rm /etc/apt/apt.conf.d/docker-clean

# install dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN \
  --mount=type=cache,target=/var/lib/apt/lists \
  --mount=type=cache,target=/var/cache/apt/archives \
  apt-get update\
  && apt-get install man-db -y

# add artificats
ADD ./upstream/requirements.txt /tmp/requirements.txt

# install python dependencies from requirements.txt
RUN \
  --mount=type=cache,target=~/.cache/pip \
  pip install --upgrade pip \
  && python --version \
  && pip install -r /tmp/requirements.txt

ADD ./upstream /opt/webapp/
WORKDIR /opt/webapp
EXPOSE 5000

CMD ["make", "serve"]

# vim: set filetype=dockerfile :