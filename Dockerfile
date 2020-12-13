FROM centos:7 
# FROM centos/systemd

LABEL maintainer=<stanislawbartkowski@gmail.com>

ENV DOMAIN="test.mail.com"

RUN yum install dovecot postfix -y

COPY config.sh .
COPY start.sh .

RUN useradd test && \
  echo "test:secret" | chpasswd && \
  useradd sb && \
  echo "sb:secret" | chpasswd

EXPOSE 25
EXPOSE 993

CMD ["sh","./start.sh"]
