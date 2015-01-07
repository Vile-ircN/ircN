on *:START:modvarload 8 mircloak
on *:LOAD:{ modvarload 8 mircloak | modvar mircloak enabled on }
on *:EXIT:modvarsave mircloak
on ^*:LOGON:*:{
  if ($modvar(mircloak,enabled) == on) .timer 1 0 mircloak on
}

on *:CONNECT:{
  ;if ($modvar(mircloak,enabled) == on) .timer 1 0 mircloak on
}
on *:DISCONNECT:{
  if ($modvar(mircloak,enabled) == on) .timer 1 0 mircloak off
}
alias mircloak {
  if ($1 == on) { window $iif($modvar(mircloak,debug) == on,-r,-w0) $+(@ircn.mircloak.,$cid) | .debug -in $+(@ircn.mircloak.,$cid) ircn.mircloak.cloak | .ignore -t *!*@* }
  else { .debug off | .ignore -rt *!*@* }
}
alias mircloak.debug {
  if ($1 == on) { modvar mircloak debug on | window -r $+(@ircn.mircloak.,$cid) }
  else { modvar mircloak debug off | window -h $+(@ircn.mircloak.,$cid) }
}
alias ircn.mircloak.cloak {
  if ($ircn.mircloak.detect($1-)) {
    tokenize 32 $1-
    var %ctcp, %address, %target
    %target = $4
    %address = $mid($2,2)
    %ctcp = $remove($mid($5-,2),$chr(1))
    .signal ctcp $cid %target %address %ctcp
  }
  if ($modvar(mircloak,debug) == on) return $1-
}
alias ircn.mircloak.detect {
  tokenize 32 $1-
  if ($1 != <-) return $false
  if ($3 != PRIVMSG) return $false
  if ($mid($5,3,6) == ACTION) return $false
  if (($mid($5,2,1) == $chr(1)) && ($right($5-,1) == $chr(1))) return $true
  else return $false
}
