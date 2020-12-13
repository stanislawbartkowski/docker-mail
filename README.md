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

Sending mail using *mailx* command line<br>

>  echo "Welcome" | mailx -v  -S smtp=thinkde:1025 -s "I'm your sendmail"  -r "sb"  test@test.mail.com 
```
Resolving host thinkde . . . done.
Connecting to 192.168.0.206:1025 . . . connected.
220 test.mail.com ESMTP Postfix
>>> HELO li-5483f1cc-30f8-11b2-a85c-ead196af19ff
250 test.mail.com
>>> MAIL FROM:<sb>
250 2.1.0 Ok
>>> RCPT TO:<test@test.mail.com>
250 2.1.5 Ok
>>> DATA
354 End data with <CR><LF>.<CR><LF>
>>> .
250 2.0.0 Ok: queued as C3C4D1831F293
>>> QUIT
221 2.0.0 Bye
```

## mutt

> vi .muttrc<br>
```
set smtp_url = "smtp://thinkde:1025"
```
> mutt -f imaps://thinkde:1993<br>

User and password: test/secret. Provide user without domain name.<br>

![](https://github.com/stanislawbartkowski/docker-mail/blob/main/images/Zrzut%20ekranu%20z%202020-12-13%2021-38-10.png)

## evolution

Identity<br>

* Account name, any name: sb@test.mail.com
* Full Name, any name 
* Email Address, account name including domain name : sb@test.mail.com

![](https://github.com/stanislawbartkowski/docker-mail/blob/main/images/Zrzut%20ekranu%20z%202020-12-13%2022-12-21.png)

Receiving Email<br>

* Server: thinkde
* Port: 1993
* Username, without domain name: sb
* Encryption method: TLS on a dedicated port

![](https://github.com/stanislawbartkowski/docker-mail/blob/main/images/Zrzut%20ekranu%20z%202020-12-13%2021-59-15.png)

Sending Email

* Server : thinkde
* Port: 1025
* No encryption and no authentication

![](https://github.com/stanislawbartkowski/docker-mail/blob/main/images/Zrzut%20ekranu%20z%202020-12-13%2022-16-41.png)

## Mozilla Thunderbird

Unfortunately, I was unable to convince Thunderbird to cooperate with dovecot.

# Troubleshooting

Dovecot and Postifx are sending all messages to syslog which is not active. In order to intercept messages, *journal* should be launched manually.

First console:<br>
> podman exec -it mail bash<br>
> root@407bd6d0898c /]# /usr/lib/systemd/systemd-journald<br>

Another console:<br>
> podman exec mail journalctl -f
```
-- Logs begin at Sun 2020-12-13 20:25:13 UTC. --
Dec 13 20:25:13 407bd6d0898c systemd-journal[318]: Runtime journal is using 8.0M (max allowed 4.0G, trying to leave 4.0G free of 79.3G available → current limit 4.0G).
Dec 13 20:25:13 407bd6d0898c systemd-journal[318]: Journal started

Dec 13 20:26:39 407bd6d0898c dovecot[196]: imap-login: Login: user=<test>, method=PLAIN, rip=127.0.0.1, lip=127.0.0.1, mpid=331, TLS, session=<d7LGV162Jqd/AAAB>
Dec 13 20:26:39 407bd6d0898c dovecot[196]: imap-login: Login: user=<sb>, method=PLAIN, rip=127.0.0.1, lip=127.0.0.1, mpid=332, TLS, session=<ZsbGV162KKd/AAAB>
Dec 13 20:26:45 407bd6d0898c dovecot[196]: imap(sb): Connection closed (NOOP finished 5.598 secs ago) in=388 out=1516
Dec 13 20:26:45 407bd6d0898c dovecot[196]: imap(test): Connection closed (UID FETCH finished 5.596 secs ago) in=375 out=1514

```


