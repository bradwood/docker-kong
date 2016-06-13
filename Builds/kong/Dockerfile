#FROM bradqwood/kong
# taking the latest build from mashape.
FROM mashape/kong
# a fork from mashape/kong
MAINTAINER Bradley Wood <docker@bradleywood.com>
ENV POSTGRES_HOSTNAME kong-database
ENV POSTGRES_PORT 5432

COPY start_kong /usr/bin/start_kong
RUN ["chmod", "+x","/usr/bin/start_kong"]
CMD /usr/bin/start_kong

