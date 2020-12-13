# docker-mail

Containerized mail server. Simple and basic mail server using Postfix and Dovecot for testing and development. Easy to modify and adjust to specific requirements.

# Create image

> git clone https://github.com/stanislawbartkowski/docker-mail.git<br>
> cd docker-mail<br>
> podman build -t mail .<br>

Two mail recipients for testing are created: (U/P) test/secret and sb/secret

# Create container

## Customization 

Ports exposed

| Port | Description |
| ---  | ----- |
| 25 | SMTP port
| 993 | Secure IMAP port

Domain name

| Variable | Description | Default value |
| ---- | --- | --- |
| DOMAIN | The domain name of SMPT and IMAP | test.sb.com

## Container

Ports: for non-root container map ports to values greater than 1000.

> podman run --name mail -d -p 1025:25  -p 1993:993 mail<br>

> podman run --name mailsb -d -p 1025:25 -p 1993:993 --env DOMAIN=sb.com.mail mail<br>

Open port if behind a firewall.

> firewall-cmd --permanent --add-port=1025/tcp<br>
> firewall-cmd --permanent --add-port=1993/tcp<br>
> firewall-cmd --reload<br>

## Test ports and SSL

Assume hostname *thinkde*

> nc -zv thinkde 1025<br>
> nc -zv thinkde 1993<br>
> openssl s_client -connect thinkde:1993<br>

## Services configuration

Configuration of the services including the domain name (DOMAIN) is performed when the container is created. So using the same image, several containers serving different domains can be created.

Configuration is very basic and only minimal changes are applied to make them working.

https://github.com/stanislawbartkowski/docker-mail/blob/main/config.sh



