FROM bradqwood/ubuntu
MAINTAINER Bradley Wood <docker@bradleywood.com>
RUN /bin/bash -c 'apt-get update && \
	apt-get install -y curl && \
	apt-get install -y jq && \
	apt-get install -y git && \
	apt-get install -y screen && \
	apt-get install -y iputils-ping && \
	apt-get install -y ngrep && \
	apt-get install -y nmap && \
	apt-get install -y httpie' 
WORKDIR /root
CMD ["tail -f /etc/hosts"]