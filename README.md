# docker-mail

Containerized mail server. Simple and basic mail server using Postfix and Dovecot for testing and development. Easy to modify and adjust to specific requirements.

# Create image

> https://github.com/stanislawbartkowski/docker-mail.git<br>
> cd docker-mail<br>
> podman build -t mail .<br>

Two mail recipients for testing are created: (U/P) test/secret and sb/secret

## Create container

# Customization 

Ports exposed

| Port | Description |
| ---  | ----- |
| 25 | SMTP port
| 993 | Secure IMAP port

Domain name

| Variable | Description | Default value |
| ---- | --- | --- |
| DOMAIN | The domain name of SMPT and IMAP | test.sb.com

# Container

Ports: for non-root container map ports to values greater than 1000

> podman run --name mail -d -p 1025:25  -p 1993:993 mail<br>

