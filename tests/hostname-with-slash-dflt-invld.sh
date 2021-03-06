#!/bin/bash
# addd 2016-07-11 by RGerhards, released under ASL 2.0
. ${srcdir:=.}/diag.sh init
setvar_RS_HOSTNAME
generate_conf
add_conf '
module(load="../plugins/imtcp/.libs/imtcp")
input(type="imtcp" port="0" listenPortFileName="'$RSYSLOG_DYNNAME'.tcpflood_port")
template(name="outfmt" type="string" string="%hostname%") # no LF, as HOSTNAME file also does not have it!

local4.debug action(type="omfile" template="outfmt" file=`echo $RSYSLOG_OUT_LOG`)
'
startup
echo '<167>Mar  6 16:57:54 hostname1/hostname2 test: msgnum:0' > $RSYSLOG_DYNNAME.input
tcpflood -B -I $RSYSLOG_DYNNAME.input
shutdown_when_empty
wait_shutdown
printf '%s' "$RS_HOSTNAME" | cmp - $RSYSLOG_OUT_LOG
if [ ! $? -eq 0 ]; then
  echo "invalid hostname generated, $RSYSLOG_OUT_LOG is:"
  cat $RSYSLOG_OUT_LOG
  echo
  echo "expected was:"
  printf '%s\n' "$RS_HOSTNAME"
  echo
  error_exit 1
fi;
exit_test
