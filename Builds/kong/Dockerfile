FROM mashape/kong:latest

ENV POSTGRES_HOSTNAME kong-database
ENV POSTGRES_PORT 5432

ENV DOCKERIZE_VERSION v0.2.0

RUN yum install -y epel-release && yum install -y wget \
    && yum clean all

RUN wget -nv https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY ./kong.yml /etc/kong/kong.yml

CMD dockerize -timeout 100s -wait tcp://$POSTGRES_HOSTNAME:$POSTGRES_PORT kong start

