;%%%%%%%%%%%%%%%%%%%%%%%%
;script ircN max up/on/run/ time script
;version 9.00
;author ircN Development Team
;email ircn@ircN.org
;url http://www.ircN.org
;%%%%%%%%%%%%%%%%%%%%%%%%

on *:LOAD:{
  if ($version < 5.9) mt.update
  ntimer MonTIME 0 30 .montime
  ntimer MupTIME 0 30 .muptime $| .mruntime
}
on *:CONNECT:{
  if ($version < 6) mt.update
  ntimer MonTIME 0 30 .montime
  ntimer MupTIME 0 30 .muptime $| .mruntime
}
on *:DISCONNECT:ntimer MupTIME 0 30 .muptime $| .mruntime
on *:UNLOAD:.timer*.M*TIME* off 
on *:START:if ($version < 6) mt.update
alias muptime {
  var %a = $uptime(system), %z
  if (%muptime == $null) set %muptime 0
  if (%a > %muptime) {
    if (($rrpt($sub(%a,%muptime)) >= 3600) || ($sub($ctime,%muptime.date) >= 86400) && (%muptime != 0)) {
      iecho Congratulations! You have beaten your old uptime record of $hc($msdur($rrpt(%muptime))) ( $+ by $sc($msdur($rrpt($sub(%a,%muptime)))) $+ ).
      iecho Your new uptime record is $hc($msdur($rrpt(%a))) $+ , set on $asc-time2($ctime) $+ .
    }
    set %muptime %a
    set %muptime.date $ctime
    set %z 1
  }
  if ($1 == -s) msg $active My computer's maximum $iif(%z,and current) uptime: $b($msdur($rrpt(%muptime))) $+ , set on $asc-time2(%muptime.date)
  elseif ($show) {
    if (%z) { 
      iiecho .----------.muptime.----------
      iiecho $| Your computer's maximum and current uptime: $hc($msdur($rrpt(%muptime))) $+ .
      iiecho $| started at $sc($asc-time2($sub($ctime,$rrpt(%a))))
      iiecho ' $+ $str(-,29)
    }
    else {
      iiecho .----------.muptime.----------
      iiecho $| Your computer's maximum uptime: $hc($msdur($rrpt(%muptime))) $+ , set on $asc-time2(%muptime.date) ( $+ $sc($msdur($sub($ctime,%muptime.date))) ago).
      iiecho $| Your current uptime is $hc($msdur($rrpt(%a))) $+ , started at $sc($asc-time2($sub($ctime,$rrpt(%a))))
      iiecho $| You will reach your record on $hc($asc-time2($pls($rrpt($sub(%muptime,%a)),$ctime))) $+ , in $sc($msdur($rrpt($sub(%muptime,%a)))) $+ .
      iiecho ' $+ $str(-,29)
    }
  }
}
alias montime {
  var %a = $uptime(server,3), %z
  if (%montime == $null) set %montime 0
  if ((%a > %montime) && ($server)) {
    set %montime.server $server $+ : $+ $port
    if (($sub(%a,%montime) >= 3600) || ($sub($ctime,%montime.date) >= 86400) && (%montime != 0)) {
      iecho Congratulations! You have beaten your old ontime record of $hc($msdur($calc(%montime))) $+ .
      iecho Your new online time record is $hc($msdur(%a)) $+ , set on $asc-time2($ctime) on $+($server,:,$port,.)
    }
    set %montime %a
    set %montime.date $ctime
    set %z 1
  }
  if ($1 == -s) msg $active My computer's maximum $iif(%z,and current) ontime: $b($msdur(%montime)) $+ , set on $asc-time2(%montime.date) on %montime.server
  elseif ($show) {
    if (%z) {
      iiecho .----------.montime.----------
      iiecho $| Your computer's maximum and current online time: $hc($msdur(%montime)) $+ .
      iiecho $| connected at $sc($asc-time2($sub($ctime,%a)))
      iiecho ' $+ $str(-,29)
    }
    else {
      iiecho .----------.montime.----------
      iiecho $| Your maximum online time is $hc($msdur(%montime)) $+ , set on $asc-time2(%montime.date) ( $+ $sc($msdur($sub($ctime,%montime.date))) ago) on %montime.server
      iiecho $| Your Current ontime is $hc($msdur(%a)) $+ , connected at $sc($asc-time2($sub($ctime,%a)))
      iiecho $| You will reach your record on $hc($asc-time2($pls($sub(%montime,%a),$ctime))) $+ , in $sc($msdur($sub(%montime,%a))) $+ .
      iiecho ' $+ $str(-,29)
    }
  }
}
alias mruntime {
  var %a = $uptime(mirc), %z
  if (%mruntime == $null) set %mruntime 0
  if (%a > %mruntime) {
    if (($rrpt($sub(%a,%mruntime)) >= 3600) || ($sub($ctime,%mruntime.date) >= 86400) && (%mruntime != 0)) {
      iecho Congratulations! You have beaten your old running time record of $hc($msdur($rrpt(%mruntime))) $+ .
      iecho Your new longest record is $hc($msdur($rrpt(%a))) $+ , set on $asc-time2($ctime) $+ .
    }
    set %mruntime %a
    set %mruntime.date $ctime
    set %z $true
    ;  iecho -s    .save -rv $qt($readini($mircini,rfiles,n1))
  }
  if ($1 == -s) msg $active My ircN's longest $iif(%z,and current) running time: $b($msdur($rrpt(%mruntime))) $+ , set on $asc-time2(%mruntime.date)
  elseif ($show) {
    if (%z) {
      iiecho .----------.mruntime.---------
      iiecho $| Your ircN's longest and current running time: $hc($msdur($rrpt(%mruntime))) $+ .
      iiecho $| started on $sc($asc-time2($sub($ctime,$rrpt(%a)))) $+ .
      iiecho ' $+ $str(-,29)
    }
    else {
      iiecho .----------.mruntime.---------
      iiecho $| Your ircN's longest running time: $hc($msdur($rrpt(%mruntime))) $+ , set on $asc-time2(%mruntime.date) ( $+ $sc($msdur($sub($ctime,%mruntime.date))) ago).
      iiecho $| Your current running time is $hc($msdur($rrpt(%a))) $+ , started on $sc($asc-time2($sub($ctime,$rrpt(%a)))) $+ .
      iiecho $| You will reach your record on $hc($asc-time2($pls($rrpt($sub(%mruntime,%a)),$ctime))) $+ , in $sc($msdur($rrpt($sub(%mruntime,%a)))) $+ .
      iiecho ' $+ $str(-,29)
    }
  }
}
alias msdur {
  var %z = $iduration($1)
  if ($chr(44) isin %z) return %z
  if ($len(%z) >= 23) return $rsc2(%z)
  else return %z
}
alias asc-time2 var %a = ddd $+ $chr(44) mmm dd yyyy | return $asctime($1,%a) at $asctime($1,h:nn:sst)
alias mt.update iecho $hc(Maxtime) for ircN was made for mIRC 6+, PLEASE upgrade, unloading maxtime for the time being. | unload -rs $script(maxtime.mrc)
menu channel,query {
  E&xtras
  .Maxtime
  ..Max Uptime	 $msdur($rrpt(%muptime))
  ...echo { muptime }
  ...say { muptime -s }
  ..Max Ontime	 $msdur(%montime)
  ...echo { montime }
  ...say { montime -s }
  ..Max Runtime	 $msdur($rrpt(%mruntime))
  ...echo { mruntime }
  ...say { mruntime -s }
}
menu status {
  E&xtras
  .Maxtime
  ..Max Uptime	 $msdur($rrpt(%muptime)) :muptime 
  ..Max Ontime	 $msdur(%montime)  :montime 
  ..Max Runtime	 $msdur($rrpt(%mruntime)) :mruntime 
}

alias maxtimesetup dlg maxtimesetup
dialog maxtimesetup {
  title "maxtime setup"
  size -1 -1 97 60
  option dbu
  box "muptime", 1, 2 2 93 36
  check "overflow fix (moo.dll)", 2, 6 22 68 9
  text "default:", 3, 6 12 19 7
  radio "say", 4, 27 11 20 9
  radio "echo", 5, 50 11 23 9
}
