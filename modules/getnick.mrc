;add 'part all chans'
on 1:signal:nloaded:{
  if ($nget(getnick.connect) == on) {
    if ($gettok($nget(getnick.nick),2,32) == temp) nset getnick off
    .quote nick $gettok($nget(getnick.nick),1,32)
    iecho Attempting to regain nickname $hc($gettok($nget(getnick.nick),1,32)) $+ ...
  }
  elseif ($nget(getnick) == on) {
    if ($gettok($nget(getnick.nick),2,32) == temp) nset getnick off
  }
}
;raw 438:*: {
;  if ($nget(getnick) == on) .timergetnick 0 30 .quote nick $gettok($nget(getnick.nick),1,32)
;}
on *:NICK:{
  if ($nget(getnick) == on) && ($newnick == $me) && ($gettok($nget(getnick.nick),1,32) == $me) {
    var %n = $gettok($nget(getnick.nick),1,32)
    ;    if ($timer(getnick)) .timergetnick off
    .notify -r %n
    nset getnick off
    iecho Regained nickname $hc(%n)
  }
}
on *:NOTIFY {
  if (($nget(getnick.nick) != $nick) || ($gettok($nget(getnick.nick),2,32) == perm)) .quote userhost $nick
}
on *:UNOTIFY:{
  if ($nget(getnick) == on) || ($nget(getnick.connect) == on) {
    if ($nick == $gettok($nget(getnick.nick),1,32)) {
      .quote nick $gettok($nget(getnick.nick),1,32)
      ;nset getnick off
      ;iecho Regained nickname $hc($nick) 
      ;.notify -r $nick
      ;$+ , GetNick disabled.
      ;    if ($gettok($nget(getnick.nick),2,32) == temp) .notify -r $nick
      ;    ndel getnick.nick
    }
  }
  halt
}
on *:CONNECT:{
  if ($nget(getnick.connect) == on) && ($nget(getnick.nick)) {
    nset getnick on
    .notify $nget(getnick.nick) getnick.perm
  }
}
alias getnick {
  if ($1 == on) {
    if (($nget(getnick.nick) == $null) && ($2 == $null)) {
      iecho Please set a nickname first!
      return
    }
    nset getnick on
    if ($2) nset getnick.nick $2 perm
    .notify -n $2 $curnet getnick.perm 
    iecho GetNick $hc(enabled) $+ . Nickname set to $sc($iif($2,$2,$gettok($nget(getnick.nick),1,32))) on $ac($curnet) $+ .
  }
  elseif ($1 == off) {
    nset getnick off
    nset getnick.connect off
    if ($nget(getnick.nick)) {
      .notify -r $gettok($nget(getnick.nick),1,32)
      ndel getnick.nick
    }
    iecho GetNick $hc(disabled) $+ .
  }
  elseif ($1 == onconnect) {
    if (($nget(getnick.nick) == $null) && ($2 == $null)) {
      iecho Please set a nickname first!
      return
    }
    elseif ($2 != $null) nset getnick.nick $2
    nset getnick.connect on
    nset getnick on
    .notify -n $2 $curnet getnick.onconnect 
    iecho GetNick on connect $hc(enabled) $+ . Nickname set to $sc($gettok($nget(getnick.nick),1,32)) on $ac($curnet) $+ .
  }
  elseif ($1 == offconnect) {
    nset getnick.connect off
    nset getnick off
    iecho GetNick $hc(disabled) $+ .
  }
  elseif ($1 == status) {
    if ($nget(getnick) == on) iecho GetNick is currently $hc(enabled) $+ .
    else iecho GetNick is currently $hc(disabled) $+ .
    if ($nget(getnick.connect) == on) iecho GetNick will be checked on $hc(connect) $+ .
    else iecho GetNick will $hc(not) be checked on $sc(connect) $+ .
    if ($nget(getnick.nick) != $null) iecho GetNick nickname is currently set to $hc($gettok($nget(getnick.nick),1,32)) $+ .
    else iecho GetNick nickname is not set.
  }
  elseif (($1 != $null) && ($nget(getnick.nick) != $null)) {
    if (!$notify($1)) {
      nset getnick.nick $1 temp
      .notify -n $gettok($nget(getnick.nick),1,32) $curnet getnick.temp
    }
    else {
      nset getnick.nick $1 perm
      .notify -n $1 $curnet getnick.perm
    }
    iecho GetNick nickname set to $hc($gettok($nget(getnick.nick),1,32)) on $sc($curnet) $+ .
  }
  else iecho Syntax: /getnick <on|off|onconnect|offconnect|status> [nickname]
}
