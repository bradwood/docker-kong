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
	apt-get install -y openssh-server && \
	apt-get install -y httpie' 

#sshd setup
# not working for some reason -- giving up for now..
#RUN mkdir /var/run/sshd
#RUN echo 'root:brad' | chpasswd
#RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
#RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
#ENV NOTVISIBLE "in users profile"
#RUN echo "export VISIBLE=now" >> /etc/profile
#EXPOSE 22
#CMD ["/usr/sbin/sshd"]

WORKDIR /root
CMD ["tail -f /etc/hosts"]