; ircN Queue System
; version=8.00
; author=Quietust
; email=Quietust@ircN.org


alias cidqueue return $cid $+ .ircn.queue. $+ $1
alias initqueues {
  createqueue serv
  createqueue help
  createqueue cmd
  if (!$ncid(queuetables)) ncid queuetables serv help
  ntimer queue 0 2 queuemsg 
  ntimer queuecmd 0 2 queuecmd
}
alias killqueues { 
  if ($isqueue(serv)) destroyqueue serv 
  if ($isqueue(help)) destroyqueue help 
  if ($isqueue(cmd))  destroyqueue cmd 
  ntimer queue off 
  ntimer queuecmd off
}
alias qctcp .quote PRIVMSG $1 : $+ $2- $+ 
alias qnotice .quote NOTICE $1 : $+ $2-
alias qmsg .quote PRIVMSG $1 : $+ $2-
alias createqueue {
  var %z = $cid $+ .ircN.queue. $+ $1
  if ($hget(%z) == $null)  hmake %z 8
  if (!$hget(%z,head))  hadd %z head 1
  if (!$hget(%z,tail))  hadd %z tail 1

  if ($2 != notable)   ncid queuetables $addtok($ncid(queuetables),$1,32)
}
alias enqueue {
  var %a, %z = $cid $+ .ircN.queue. $+ $1
  set %a $hget(%z,head)
  if ($hget(%z)) {
    hadd %z %a $2-
    inc %a
    hadd %z head %a
  }
  else { 
    createqueue $1
    ncid queuetables $addtok($ncid(queuetables),$1,32)
    .timer 1 1 enqueue $1-
  }
}
alias dequeue {
  var %a, %b, %y, %z = $cid $+ .ircN.queue. $+ $1
  set %a $hget(%z,tail)
  set %b $hget(%z,head)
  if (%a == %b) return $null
  set %y $hget(%z,%a)
  hdel %z %a
  inc %a
  hadd %z tail %a
  if (%a == %b) {
    hadd %z head 1
    hadd %z tail 1
  }
  return %y
}
alias queuelen if ($hget($+($cid $+ .ircN.queue.,$1),0).item) return $calc($ifmatch - 2)
alias isqueue return $iif($hget($+($cid $+ .ircN.queue.,$1)),$true,$false)
alias copyqueue {
  if ($0 < 2) { iecho Syntax: /copyqueue <src queue> <dest queue> | return }
  var %a, %z
  if ($isqueue($2)) destroyqueue $2
  createqueue $2
  set %a $queuelen($1)
  while (%a > 0) {
    set %z $dequeue($1)
    enqueue $1 %z
    enqueue $2 %z
    dec %a
  }
}
alias destroyqueue {
  var %a = $cid $+ .ircN.queue. $+ $1
  if ($hget(%a)) hfree %a
  ncid queuetables $remtok($ncid(queuetables),$1,1,32)
  if (!$ncid(queuetables)) ncid -r queuetables

}
alias putserv enqueue serv $1-
alias puthelp enqueue help $1-
alias putmsg {
  if ($show) {
    if ($1 ischan) {
      set -u1 %:echo echo $color(Own) -ti2 $1 | set -u1 %::chan $1
      set -u1 %::text $2-
      set -u1 %::target %b | set -u1 %::nick $me
      if ($nick(%b, $me).pnick != $me) { set -u1 %::cmode $left($ifmatch, 1) }

      theme.text TextChanSelf
    }
    elseif ($me !ison $1) && (!$query($1))  iiecho $sc(-) $+ > [[ $+ $sc(msg) $+ ( $+ $hc($1) $+ )] $2-
  } 
  putserv PRIVMSG $1 : $+ $2-
  unset %:echo %::chan %::text %::target %::nick %::cmode
}
alias queue {
  var %a, %z
  if (!$isqueue(inst)) createqueue inst
  if ($isid) return $queuelen(inst)
  if ($1 != $null) {
    enqueue inst $1-
    return
  }
  while ($queuelen(inst))  .quote $dequeue(inst)

  destroyqueue inst
}
alias queuename {
  ;name cmd
  if ($0 < 1) return
  var %a, %z
  ncid queuetables $addtok($ncid(queuetables),$1,32)
  ;  ntimer queue 0 2 queuemsg 
  if (!$isqueue($1)) createqueue $1
  if ($isid) return $queuelen($1)
  if ($2 != $null) {
    enqueue $1 $2-
    return
  }
  ; while ($queuelen($1))  .quote $dequeue($1)
  ; destroyqueue $1
}
alias queuecmd {
  var %a, %z
  if (!$isqueue(cmd)) createqueue cmd notable
  if ($isid) return $queuelen(cmd)
  if ($1 != $null) {
    enqueue cmd $1-
    return
  }
  while ($queuelen(cmd)) .timer 1 0 $dequeue(cmd)
  destroyqueue cmd
}
alias queuemsg {
  var %a,%b  
  set %a $ncid(queuenum)
  if (!$0) tokenize 32 $ncid(queuetables)
  while (1) {
    inc %a 
    if (%a > $0) set %a 1
    set %b $gettok($1-,%a,32)

    if ($queuelen(%b)) {
      var %q, %y
      set %q $dequeue(%b)
      set %y $gettok(%q,2-,231)
      set %q $gettok(%q,1,231)
      if (%q) .quote %q
      if (%y) .timer 1 0 %y
    }
    else break 
  }
  ncid queuenum %a
}

on *:CONNECT:initqueues
on *:LOAD:{ 
  killqueues 
  initqueues
}

on *:UNLOAD:.reload -rs $script
on *:DISCONNECT:{ 
  killqueues 
  killwhoqueue 
}

alias queuewho {
  if ($1 != $null) {
    enqueue who who $1-
    return
  }
  if ($queuelen(who)) .quote $dequeue(who)
}

alias initwhoqueue {
  createqueue who
  ntimer queuewho 0 10 queuewho
}

alias killwhoqueue { 
  if ($isqueue(who))  destroyqueue who
  ntimer queuewho off
}

; ################################################################
; ####################### IRCN SCRIPT FILE #######################
; ########## END OF FILE. DO NOT REMOVE OR MODIFY BELOW ##########
; ################################################################
