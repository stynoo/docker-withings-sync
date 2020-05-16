FROM frolvlad/alpine-python3

LABEL description="A dockerized version of withings-garmin-v2."
LABEL maintainer="Stynoo"

ENV PROJECT=withings
ENV PROJECT_DIR=/home/$PROJECT

WORKDIR $PROJECT_DIR

RUN apk update --no-cache \
    && apk add --no-cache su-exec git \
    && apk add --no-cache gcc python3-dev musl-dev libxml2-dev libxslt-dev \
    && pip3 install --upgrade pip requests lxml \
    && git clone https://github.com/jaroslawhartman/withings-garmin-v2 $PROJECT_DIR \
    && mkdir -p $PROJECT_DIR/config

RUN echo "#!/bin/sh" >> /etc/periodic/15min/withings
RUN echo "/sbin/su-exec" $PROJECT $PROJECT_DIR"/config/withingssync_crontab 2>&1" >> /etc/periodic/15min/withings

RUN adduser -D -g '' $PROJECT \ 
    && chown -R $PROJECT $PROJECT_DIR \
    && chmod a+x /etc/periodic/15min/withings

CMD ["/usr/sbin/crond","-f"]
