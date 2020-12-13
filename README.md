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

## User

Two default users are created: test/secret and sb/secret. To add new users, logon to the running container and add them manually.

> podman exec -it mail bash
```
[root@407bd6d0898c /]# adduser dzeus
[root@407bd6d0898c /]# echo "dzeus:secret" | chpasswd
```

# Test your mail server

## Test SMTP

Example session using telnet

> telnet thinkde 1025<br>

```
sbartkowski:docker-mail$ telnet thinkde 1025
Trying 192.168.0.206...
Connected to thinkde.
Escape character is '^]'.
220 test.mail.com ESMTP Postfix
HELO my.server
250 test.mail.com
MAIL FROM:sb@gmail.com
250 2.1.0 Ok
RCPT TO: test@test.mail.com
250 2.1.5 Ok
DATA
354 End data with <CR><LF>.<CR><LF>
SUBJECT: First message
Hello mail server, nice to meet you!
.
250 2.0.0 Ok: queued as 9F1CD1831F434
^]
telnet> quit
Connection closed.

```
