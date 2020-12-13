setprod() {
  POSTFIXMAIN=/etc/postfix/main.cf
  DOVECONF=/etc/dovecot/dovecot.conf
  DOVEAUTH=/etc/dovecot/conf.d/10-auth.conf
  DOVEMAIL=/etc/dovecot/conf.d/10-mail.conf
}

settest() {
  DOMAIN=sb.mail.com
  POSTFIXMAIN=testconf/main.cf
  DOVECONF=testconf/dovecot.conf
  DOVEAUTH=testconf/10-auth.conf
  DOVEMAIL=testconf/10-mail.conf
}

exists_par() {
  local -r INPUT=$1
  local -r para=$2
  local -r val="$3"

  local -r NO=`sed -n "/^\s*$para\s*=\s*$val\$/p" $INPUT | wc | tr -s ' ' | cut -d" " -f2`
  [ $NO -eq 0 ] && return 1
  return 0
}

test_par() {
  local -r INPUT=$1
  local -r para=$2
  local -r val="$3"
  if exists_par $INPUT $para "$val" $INPUT; then echo "OK"; else echo "fix"; fi
}  

enable_par() {
  local -r INPUT=$1
  local -r TMP=`mktemp`     
  local -r para=$2
  local -r val="$3"
  local vals="$4"

  [ -z "$vals" ] && vals=$val
  if exists_par $INPUT $para "$val"; then return; fi
  sed "s/^\s*$para\s*=/#$para=/" $INPUT >$TMP
  echo "" >>$TMP
  echo "$para = $vals" >>$TMP
  cp $TMP $INPUT
  rm $TMP
}

enable_main() {
  local -r INPUT=$1
  enable_par $INPUT myhostname $DOMAIN
  enable_par $INPUT mydomain $DOMAIN
  enable_par $INPUT myorigin '$mydomain'
  enable_par $INPUT inet_interfaces all
  enable_par $INPUT mynetworks ""
  enable_par $INPUT home_mailbox "Maildir\/" "Maildir/"
  enable_par $INPUT relay_domains ""
}

postfixconf() {
   enable_main $POSTFIXMAIN
}

dovecotconf() {  
  enable_par $DOVECONF protocols imap 
  enable_par $DOVECONF listen  "\*, ::" "*, ::"

  enable_par $DOVEAUTH disable_plaintext_auth no
  enable_par $DOVEAUTH auth_mechanisms "plain login"

  enable_par $DOVEMAIL mail_location "maildir:~\/Maildir" "maildir:~/Maildir"
}

#settest
setprod

postfixconf

dovecotconf


