FROM centos:7 
# FROM centos/systemd

ARG SMTPPORT=1025
ARG IMAPSPORT=1993

LABEL maintainer=<stanislawbartkowski@gmail.com>

ENV DOMAIN="test.mail.com"
ENV ENVSMTPPORT=${SMTPPORT}
ENV ENVIMAPSPORT=${IMAPSPORT}

RUN yum install dovecot postfix -y

COPY config.sh .
COPY start.sh .

RUN useradd test && \
  echo "test:secret" | chpasswd && \
  useradd sb && \
  echo "sb:secret" | chpasswd

EXPOSE ${SMTPPORT}
EXPOSE 993
USER root

CMD ["sh","./start.sh"]
