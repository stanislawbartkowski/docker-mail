# docker-mail

Containerized mail server. Simple and basic mail server using Postfix and Dovecot for testing and development. Easy to modify and adjust to specific requirements.

# Create image

Build variables
| Variable | Description | Default
| ---- | ---- | ---- |
| SMTPPORT | SMTP port (non secure) | 1025
| IMAPSPORT | IMAPS port (secure) | 1993


> git clone https://github.com/stanislawbartkowski/docker-mail.git<br>
> cd docker-mail<br>
> podman build -t mail .<br>

Two mail recipients for testing are created: (U/P) test/secret and sb/secret

Change ports<br>

> podman build --build-arg=SMTPPORT=2025 --build-arg=IMAPSPORT=2993 -t mail .<br>

# Create container

## Customization 

Ports exposed

| Port | Description |
| ---  | ----- |
| ${SMTPPORT}  | SMTP port, default 1025
| ${IMAPSPORT}  | IMAPS secure port, default 1993

Domain name

| Variable | Description | Default value |
| ---- | --- | --- |
| DOMAIN | The domain name of SMPT and IMAP | test.sb.com

## Container

Ports: for non-root container map ports to values greater than 1024.

> podman run --name mail -d -p 1025:1025  -p 1993:1993 mail<br>

> podman run --name mailsb -d -p 1025:1025 -p 1993:1993 --env DOMAIN=sb.com.mail mail<br>

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
# OpenShift/Kubernetes

## Build docker image

Use *443* for secure IMAPS.<br>

> podman build --build-arg=IMAPSPORT=443 -t mail .

## Make image public

Make docker image publicly available, for instance, in *quay.io*. In *quay.io* if the image is deployed for the first time, make it public through *quay.io* web page.

> podman login quay.io<br<
> podman tag mail quay.io/stanislawbartkowski/mail:latest<br>
> podman push quay.io/stanislawbartkowski/mail:latest<br>

## Create a seperate project for mail service

> oc new-project mail<br>

## Prepare service account

*Mail* container requires *root* authority to run. In OpenShift, the default is *restricted* service and the container will fail.<br>
Create *mail-sa* service account with *anyuid* privilege. You need OpenShift *admin* authority to do that.

* oc create serviceaccount mail-sa<br>
* oc adm policy add-scc-to-user anyuid -z mail-sa<br>

## Deploy the application

A sample *yaml* configuration file is available. https://github.com/stanislawbartkowski/docker-mail/blob/main/openshift/mail.yaml<br>
It uses *mail-sa* service account created in the previous step.

> oc create -f https://raw.githubusercontent.com/stanislawbartkowski/docker-mail/main/openshift/mail.yaml<br>

> oc get pod<br>
```
AME                    READY   STATUS    RESTARTS   AGE
mail-7c9b768fdd-tv9hs   1/1     Running   0          51s

```

Together with the pod, two services are created
* mailsmtp : SMTP service
* mailimaps : IMAPS service

> oc get svc<br>
```
NAME        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
mailimaps   ClusterIP   172.30.189.246   <none>        443/TCP    42s
mailsmtp    ClusterIP   172.30.79.240    <none>        1025/TCP   42s
```
## Expose services externally

### IMAPS 

IMAPS is a secure connection and expose it using OpenShift Route.<br>

> oc expose service mailimaps<br>

> oc get route<br>

```
NAME        HOST/PORT                                    PATH   SERVICES    PORT   TERMINATION   WILDCARD
mailimaps   mailimaps-mail.apps.boreal.cp.fyre.ibm.com          mailimaps   443                  None
```

In the environment I'm using, the port *443* is used to pass through encrypted traffic. 

> mutt -f imaps://mailimaps-mail.apps.boreal.cp.fyre.ibm.com:443<br>

Use *test/secret* as user name and password

### SMPT

> oc create route passthrough --service mailsmtp<br>
> oc get route<br>
```
NAME        HOST/PORT                                    PATH   SERVICES    PORT    TERMINATION   WILDCARD
mailsmtp    mailsmtp-sb.apps.bewigged.os.fyre.ibm.com           mailsmtp    <all>   passthrough   None
```
Unfortunately, in the OpenShift environment I'm using there is no way to use non-encrypted and non-http traffic. Also *edge* termination is not working here because it is applicable only to HTTP endpoints.<br>
The solution at hand is to make IP bridge on *mailsmtp-sb.apps.bewigged.os.fyre.ibm.com* to *mailsmtp* service ignoring *mailsmpt* route. *mailsmtp-sb.apps.bewigged.os.fyre.ibm.com* is only hostname DNS resolver.<br>
<br>
Firstly test *smtp* endpoint.

> oc get pods<br>
```
NAME                       READY   STATUS    RESTARTS   AGE
mail-5dcb75dcbf-nlndx      1/1     Running   0          13h
```
Use port forwarding<br>

> oc port-forward mail-5dcb75dcbf-nlndx  1025 
```
Forwarding from 127.0.0.1:1025 -> 1025
Forwarding from [::1]:1025 -> 1025
```
On a separate terminal session (mind *localhost* and *1025* port)<br>
> echo "Welcome" | mailx -v -S smtp=localhost:1025 -S ssl-verify=ignore -s "I'm your sendmail" -r "sb" test@test.mail.com
```
Resolving host localhost . . . done.
Connecting to ::1:1025 . . . connected.
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
250 2.0.0 Ok: queued as 9296D900387A
>>> QUIT
221 2.0.0 Bye
```

Assuming service clusterIP *172.30.253.110* and port *1025*.

On gateway node *mailsmtp-sb.apps.bewigged.os.fyre.ibm.com* bridge *172.30.253.110* address to any of OpenShift nodes, here *10.16.71.16*

Temporary brigde, will dissapear after network restart.<br>
> ip route add 172.30.253.110 via 10.16.71.16 dev eth0<br>

Pernament solution, will survive network restart.<br>
> vi /etc/sysconfig/network-scripts/route-eth0<br>
```
ADDRESS0=172.30.253.0
NETMASK0=255.255.255.0
GATEWAY0=10.16.71.16
```
> systemctl restart network

Reconfigure HAProxy to redirect traffic on *1025* node to *172.30.253.110* address.<br>
> vi /etc/haproxy/haproxy.cfg<br>
```
listen mailsmtp
        bind *:1025
        mode tcp
        server server1 172.30.253.110:1025 check
```
> systemctl restart haproxy<br>

Test on client desktop. Important: altough hostname provided by router is used here, the OpenShift router is ignored and the container is reached by *service* component.<br>
> echo "Welcome from my desktop" | mailx -v -S smtp=mailsmtp-sb.apps.bewigged.os.fyre.ibm.com:1025 -S ssl-verify=ignore -s "I'm your sendmail" -r "sb" test@test.mail.com
```
Resolving host mailsmtp-sb.apps.bewigged.os.fyre.ibm.com . . . done.
Connecting to 9.30.43.192:1025 . . . connected.
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
250 2.0.0 Ok: queued as EFFF8900387A
>>> QUIT
221 2.0.0 Bye
```
## Summary
We can connect to our OpenShift mail service using the following data.<br>

| Parameter | Server | Port |
| ---- | --- | -- | 
| SMPT service | mailsmtp-sb.apps.bewigged.os.fyre.ibm.com | 1025
| IMAPS service (TLS) | mailimaps-sb.apps.bewigged.os.fyre.ibm.com | 443
