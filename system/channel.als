op {
  if ($1 ischan) mmode $1 + o $$2-
  else mmode # + o $$1-
}
dop {
  if ($1 ischan) mmode $1 - o $$2-
  else mmode # - o $$1-
}
hlop {
  if ($1 ischan) mmode $1 + h $$2-
  else mmode # + h $$1-
}
dhlop {
  if ($1 ischan) mmode $1 - h $$2-
  else mmode # - h $$1-
}
v {
  if ($1 ischan) mmode $1 + v $$2-
  else mmode # + v $$1-
}
dv {
  if ($1 ischan) mmode $1 - v $$2-
  else mmode # - v $$1-
}
t {
  if (!$server) return
  if ($1 ischan) topic $1  $2-
  elseif ($active ischan) topic # $1-
}
rt {
  var %a
  if ($1 ischan) set %a $1
  else set %a #
  if (%a !ischan) { iecho Syntax: /rt [#chan] | return }
  topic $read($txtd(quotes.txt))
}
eventset {
  if (!$0) theme.syntax /eventset <-hcsbd> <#chan> [joins,parts,quits,modes,topics,ctcps,nicks,kicks,actionstext,all]
  var %set = joins parts quits modes topics ctcps nicks kicks, %special = text actions, %i = 1
  var %x = $numtok(%set,32)
  var %c, %t, %e, %a, %iniset
  var %def = $readini($mircini, events, default), %i = $numtok(%def, 44)
  if (!%def) { %def = 1,1,1,1,1,1,1,1 }
  else {
    while (%i) { %def = $puttok(%def, $calc($gettok(%def, %i, 44) + 1), %i, 44) | dec %i }
  }

  if ($left($1,1) == -) {
    if (h isin $1) set %t h
    elseif (c isin $1) set %t c
    elseif (s isin $1) set %t s
    elseif (b isin $1) set %t b
    else set %t d
    set %c $iif($2 ischan,$2,#)
    set %e $iif($2 ischan,$3-,$2-)
  }
  else {
    set %t d
    set %c $iif($1 ischan,$1,#)
    set %e $iif($1 ischan,$2-,$1-)
  }
  if (%c !ischan) return
  set %iniset $readini($qt($mircini),events,%c)
  if (!%iniset) set %iniset 0,0,0,0,0,0,0,0
  set %i 1
  while (%i <= %x) {
    if (($istok(%e,$gettok(%set,%i,32),44)) || ($istok(%e,all,44))) {
      if (%t == d) set %a $gettok(%def,%i,44)
      elseif (%t == c) set %a 1
      elseif (%t == s) set %a 2
      elseif (%t == b) set %a $iif($gettok(%set,%i,32) == quits,3,$gettok(%def,%i,44))
      elseif (%t == h) set %a $iif($gettok(%set,%i,32) == quits,4,$iif($gettok(%set,%i,32) == nicks,2,$iif($gettok(%set,%i,32) == ctcps,0,3)))
      else set %a 0
      if (%a != 0) hadd nxt_events %c $puttok($hget(nxt_events,%c),%a,%i,44)
      if (%t == d) { set %a 0 | set %iniset $puttok(%iniset,%a,%i,44) }
      elseif (%a != 0) set %iniset $puttok(%iniset,%a,%i,44)
    }
    inc %i
  }
  if ($hget(nxt_events,%c) == %def) remini $qt($mircini) events %c
  else writeini $qt($mircini) events %c %iniset

  set %x $numtok(%special,32)
  set %i 1
  while (%i <= %x) {
    if (($istok(%e,$gettok(%special,%i,32),44)) || ($istok(%e,all,44))) {
      if (%t == s) set %a 2
      elseif (%t == b) set %a 3
      elseif (%t == h) set %a 4
      else set %a 0
      if (%a != 0)  hadd nxt_events $+(show.,$gettok(%special,%i,32),.,%c) %a
      else hdel nxt_events $+(show.,$gettok(%special,%i,32),.,%c)
      if (%a != 0) writeini $sd(evntxtra.ini) $+(show.,$gettok(%special,%i,32)) %c %a
      else remini $sd(evntxtra.ini) $+(show.,$gettok(%special,%i,32)) %c
    }
    inc %i
  }
  if ($show) iecho Echoing of $paren(%e) events on $hc(%c) are now $hc($iif(%t == h,Hidden,$iif(%t == c,Shown in channel,$iif(% == s,Shown in status,Defaulted)))) $+ .
}
filt {
  ;/filt [-rb] [chan] <text>

  ;regex is -g filter code
  var %a, %c, %s
  if ($1 !ischan) {
    if (@*.filter iswm $active) {
      set %a $active
      set %s $iif(* !isin $1-,*) $+ $1- $+ $iif(* !isin $1-,*)
      window -h %a $+ .tmp
      filter -zpww %a $+(%a,.tmp) %s
      clear %a
      filter -zpww $+(%a,.tmp) %a %s
      window -c $+(%a,.tmp)
      editbox -p %a /filt 
      titlebar %a Filtering previous filter for: %s
      return
    }
  }
  var %f, %c, %s
  var %f = $iif(-* iswm $1,$1)
  if (-* iswm $1) { set %f $1 | set %c $iif($2 ischan,$2) | set %s $iif(%c,$3-,$2-) }
  else { set %c $iif($1 ischan,$1) | set %s $iif(%c,$2-,$1-) }
  if (!%c) set %c #
  if (%c !ischan) return

  if (r !isin %f)  set %s $iif(* !isin %s,*) $+ %s $+ $iif(* !isin %s,*)


  set %a @ $+ %c $+ .filter
  window -kae %a 
  clear %a
  filter -zpww $+ $iif(r isin %f,g) $+ $iif(b isin %f,b) %c %a %s
  titlebar %a Filtering channel %c for: %s $paren($iif(r isin %f,regex))
  editbox -p %a /filt %f
}

at .quote topic # : $+ $chan(#).topic $$1-
join {
  var %f 
  set %f $iif(-* iswm $1,$1)
  tokenize 32 $iif(%f,$2-,$1-)
  if ($chr(44) isin $1) {
    var %a = 1, %b, %c
    while ($gettok($1,%a,44) != $null) {
      set %b $ifmatch
      set %c $iif($left(%b,1) == $chr(35),%b,$chr(35) $+ %b)
      if ($_autojoin.ischanautoormirc(%c)) { inc %a | continue }
      if ($istok($nvar(hidechans),%c,44)) set %f $iif(%f,%f $+ n,-n)
      if ($gettok($2,%a,44)) chanset %c key $gettok($2,%a,44)
      if ($changet(%c,key)) !join %f %c $changet(%c,key)
      else !join %f %c

      ncid -r banrejoin. $+ %c $+ .*
      ncid joinsync. [ $+ [ %c ] ] $ticks
      inc %a
    }
  }
  elseif (#$1) {
    if ($_autojoin.ischanautoormirc(#$1)) return
    if ($2) chanset #$1 key $2
    if ($istok($nvar(hidechans),#$1,44)) set %f $iif(%f,%f $+ n,-n)
    if ($changet(#$1,key)) !join %f #$1 $changet(#$1,key)
    else !join %f #$1
    ncid -r banrejoin. $+ #$1 $+ .*
    ncid joinsync. [ $+ [ #$1 ] ] $ticks
  }

}
part {
  if (#$1 ischan) !part #$1 $iif($2-, $2-, $nvar(string_partmsg))
  elseif (#) !part # $iif($1-, $1-, $nvar(string_partmsg))
}
kb {
  var %t = $flags($1-).text
  if (($flags($1-,t).val) || ($flags($1-,time).val)) var %unset = $ifmatch

  tokenize 32 %t
  if ($0 == 0) {
    iecho Syntax: /kb [channel] <nickname> [reason]
    return
  }
  if ($me ison $1) {
    if ($2 !ison $1) return
    if (($me isop $1) || ($me ishop $1)) {
      kick $1 $2 $iif($3,$3-,$iif($lines($sd(kicks.txt)),$read($sd(kicks.txt),n),$me))
      mode $1 +b $address($2,$iifelse($nvar(kbmask),3))
    }
    else _doraw.fake 482 $server $1 $me $1
  }
  else {
    if ($1 !ison #) return
    if (($me isop #) || ($me ishop #)) {
      kick # $1 $iif($2,$2-,$iif($lines($sd(kicks.txt)),$read($sd(kicks.txt),n),$me))
      mode # +b $address($1,$iifelse($nvar(kbmask),3))
    }
    else _doraw.fake 482 $server # $me #
  }
}
bk {
  if ($0 == 0) {
    iecho Syntax: /bk [-uN] [channel] <nickname> [reason]
    return
  }
  if ($me ison $1) {
    if (($me isop $1) || ($me ishop $1)) ban -k $1 $2 $iifelse($nvar(kbmask),3) $iif($3,$3-,$iif($lines($sd(kicks.txt)),$read($sd(kicks.txt),n),$me))
    else _doraw.fake 482 $server $1 $me $1
  }
  else {
    if (($me isop #) || ($me ishop #)) ban -k # $1 $iifelse($nvar(kbmask),3) $iif($2,$2-,$iif($lines($sd(kicks.txt)),$read($sd(kicks.txt),n),$me))
    else _doraw.fake 482 $server # $me #
  }
}
topic {
  if ($1 ischan) !topic $1-
  elseif ($1 != $null) !topic # $1-
  else !topic #
}
getops dogetops # $1
p part $iif($1 ischan,$1,#) $iif($1 ischan,$2-,$1-)
j join $1-
k kick # $1 $2-
m {
  var %a = 1, %b
  while ($gettok($1,%a,44)) {
    set %b $ifmatch
    if ($gettok($1,0,44) > 3) qmsg %b $2- 
    else .msg %b $2-
    set -u1 %::text $2-
    if (%b ischan) {
      if ($me ison %b) {
        set -u1 %:echo echo $color(own) -tmi2 %b
        set -u1 %::chan %b

        set -u1 %::target %b | set -u1 %::nick $me

        if ($nick(%b, $me).pnick != $me) { set -u1 %::cmode $left($ifmatch, 1) }

        theme.text TextChanSelf
      }
    }
    else {
      set -u1 %:echo echo $color(own) -ati2
      set -u1 %::target %b | set -u1 %::nick %b
      set -u1 %::cnick $nick(%b, $me).color
      theme.text TextQueryMultiSelf
    }
    inc %a
  }
  unset %:echo %::chan %::text %::target %::nick %::cmode %::cnick
}
n {
  var %a = 1, %b
  while ($gettok($1,%a,44)) {
    set %b $ifmatch
    if ($gettok($1,0,44) > 3) qnotice %b $2-
    else .notice %b $2-
    inc %a
  }
  set -u1 %:echo echo $color(own) -ati2
  set -u1 %::text $2-
  set -u1 %::target %b | set -u1 %::nick %b
  set -u1 %::cnick $nick(%b, $me).color
  theme.text NoticeMultiSelf
  unset %:echo %::chan %::text %::target %::nick %::cmode %::cnick
}
cm mode # $1-
ct .quote topic # :
reft { 
  var %c = $iif($1 ischan,$1,#)
  if ($chan(%c).topic) .quote topic %c : $+ $chan(%c).topic $+ $chr(32)
}
kick {
  var %c, %n, %x, %y, %z, %r
  if ($1 ischan) { set %c $1 | set %n $2 | set %r $3- }
  else { set %c # | set %n $1 | set %r $2- }
  if (!%r) set %r $iif($lines($sd(kicks.txt)),$read($sd(kicks.txt)),$me)
  if ((%n !ison %c) || (%c !ischan)) {
    iecho Syntax: /kick [channel] <nickname> [reason]
    return
  }
  set %r $replace(%r,<num>,$pls($iifelse($nvar(kickcount),0),1),<netnum>,$pls($iifelse($changet(global,kickcount),0),1),<channum>,$pls($iifelse($changet(%c,kickcount),0),1))
  queue kick %c %n : $+ %r
  queue
}
knop mkick -n $1-
mkick {
  ;/mkick [aohvrbiR] [#chan] [reason]
  ; a = all nicks, o = ops, h = halfops, v = voices, r = regulars, n = nonops (voice+reg)
  ; b = ban, R = reverse order, i = idle

  var %a, %b, %c, %f, %fd, %z

  set %f $iif(-* iswm $1,$1,-r)
  if (!$removecs(%f,-,b,R,i)) set %f %f $+ r

  set %c $iif($iif(-* iswm $1,$2,$1) ischan,$ifmatch,#)
  if ((u isincs %f) && (!$ismod(userlist))) set %f $remove(%f,u)
  if (a isincs %f) set %fd $addtok(%fd,All,44)
  else {
    if (o isincs %f) set %fd $addtok(%fd,Ops,44)
    if (h isincs %f) set %fd $addtok(%fd,Halfops,44)
    if (n isincs %f) set %fd $addtok(%fd,Nonops,44)
    if (v isincs %f) set %fd $addtok(%fd,Voices,44)
    if (r isincs %f) set %fd $addtok(%fd,Regular Users,44)
  }
  if (R isincs %f) set %fd $addtok(%fd,Reverse Order,44)
  if (u isincs %f) set %fd $addtok(%fd,Non Users,44)
  set %f $replacecs($remove(%f,-),n,rv)
  set %z $iif($iif(-* iswm $1,$2,$1) ischan, $iif(-* iswm $1,$3-,$2-), $iif(-* iswm $1,$2-))
  if (!%z) {
    if (i isin %f) set %z Idle for longer than $iduration(3600)
    else set %z $iifelse($nvar(string_masskick),$input(Enter reason,e,Mass kick))
  }

  if ((!$removecs(%f,R)) && (a !isin %f) && (h !isin %f) && (o !isin %f) && (n !isin %f) && (v !isin %f)) set %f %f $+ r
  set %a $iif(R isincs %f,$nick(%c,0,$iif($removecs(%f,u,R),$removecs(%f,u,R),r)),1)


  iecho -w %c Mass $iif(b isin %f,Kick-Banning,Kicking) $iif(i isin %f,Idle users from) %c $+ ... ( $+ %fd $+ )

  while ($nick(%c,%a,$iifelse($removecs(%f,u,R,b),r)) != $null) {
    set %b $ifmatch
    if ((R isincs %f) && (%a <= 0)) break
    if ((i isin %f) && ($nick(%c,%b).idle < $iifelse($nvar(idlekick.duration),3600))) {
      if ((u isin %f) && ($ismod(userlist.mod)) && (!$usr(%b)) && (%b != $me)) {
        if (b isin %f) queue mode %c +b $address(%b,$iifelse($nvar(kbmask),3)) $iif($nvar(mkb.expire) == on, $chr(231) ban -u $+ $calc($iifelse($nvar(mkb.expiretime),5) *60) %c  $address(%b,$iifelse($nvar(kbmask),3))  )
        queue kick %c %b : $+ %z
      }
      elseif ((u !isin %f) && (%b != $me)) {
        if (b isin %f) queue mode %c +b $address(%b,$iifelse($nvar(kbmask),3)) $iif($nvar(mkb.expire) == on, $chr(231) ban -u $+ $calc($iifelse($nvar(mkb.expiretime),5) *60) %c  $address(%b,$iifelse($nvar(kbmask),3))  )
        queue kick %c %b : $+ %z
      }
    }
    $iif(R isincs %f,dec,inc) %a
  }
  queue
}
hidechans {
  if ($nvar(hidechans) != on) return
  var %a = 1, %b, %c
  while ($chan(%a)) {
    set %b $ifmatch
    set %c $chancid(%b,lastactive)
    if (%c) && (%c >= 60) {
      window -h %b 
    }
    ;fix this
    inc %a
  }
}
mkb {
  ;/mkb [aohvrbR] [reason]
  ; a = all nicks, o = ops, h = halfops, v = voices, r = regulars, n = nonops (voice+reg)
  ; R = reverse order

  var %a, %b, %f, %z
  set %f $remove($iif(-* iswm $1,$1),-)
  set %z $iif($iif(%f,$2-,$1-),$ifmatch,$input(Enter reason,1))
  if (!$removecs(%f,R)) set %f %f $+ r
  mkick -b $+ $remove(%f,-,b) %z
}

mdop {

  var %a, %c, %f, %z

  set %f $iif(-* iswm $1,$1)
  set %c $iif(%f,$2,$1)
  if (%c !ischan) set %c # 
  if ($me !isop %c) {
    _doraw.fake 482 $server %c $me %c
    return
  }
  if ($nick(%c,0,o) == 1) {
    iecho You are the only operator on $hc(#) $+ .
    return
  }
  var %y = $nvar(mdop.nousers)
  if (!$ismod(userlist)) set %y

  set %a $iif(r isin %f,$nick(%c,0,o),1)
  while ($nick(%c,%a,o)) {
    set %z $ifmatch
    if ((r isin %f) && (%a <= 0)) break

    if (%z != $me) {
      if (%y == on)  {
        if (!$usr(%e))  mmode2 enqueue %z
      }
      else mmode2 enqueue %z
    }


    $iif(r isin %f,dec,inc) %a
  }
  mmode2 flush - o %c
}
mdv {
  if (($me !isop #) && ($me !ishop #)) {
    _doraw.fake 482 $server # $me #
    return
  }
  var %a, %z
  set %a 1
  while ($nick(#,%a,v)) {
    mmode2 enqueue $ifmatch
    inc %a
  }
  mmode2 flush - v #
}
mmode2 {
  if ($isid) return $isqueue(mmode)
  if (($0 == 0) || (($1 != enqueue) && ($1 != flush))) {
    theme.syntax /mmode2 <enqueue|flush> ...
    return
  }
  if ($1 == enqueue) {
    if ($0 < 2) { theme.syntax /mmode2 enqueue <nick1> [nick2] ... | return }
    if (!$isqueue(mmode)) createqueue mmode
    var %a = 1
    while ($gettok($2-,%a,32) != $null) {
      enqueue mmode $ifmatch
      inc %a
    }
  }
  if ($1 == flush) {
    if ($0 < 2) { theme.syntax /mmode2 flush <+|-> <mode char> <#channel> | return }
    if (!$isqueue(mmode)) return
    var %a = 1, %z
    while ($dequeue(mmode) != $null) {
      set %z $addtok(%z,$ifmatch,32)
      if ($numtok(%z,32) == $ncid(modesonline)) {
        queue mode $4 $2 $+ $str($3,$ncid(modesonline)) %z
        set %z
      }
      inc %a
    }
    if (%z != $null) queue mode $4 $2 $+ $str($3,$numtok(%z,32)) %z
    destroyqueue mmode
    queue
  }
}
mmode {
  if (($1 !ischan) || ($4 == $null)) {
    theme.syntax /mmode <channel> <+|-> <flag> <arguments>
    return
  }
  var %a, %z
  set %a 1
  while ($gettok($4-,%a,32) != $null) {
    set %z $addtok(%z,$ifmatch,32)
    if ($numtok(%z,32) == $ncid(modesonline)) {
      queue mode $1 $2 $+ $str($3,$ncid(modesonline)) %z
      set %z
    }
    inc %a
  }
  if (%z != $null) queue mode $1 $2 $+ $str($3,$numtok(%z,32)) %z
  queue
}
qmmode {
  ;<name> <channel> <+|-> <flag> <arguments>
  if (($2 !ischan) || ($5 == $null)) {
    theme.syntax /mmode <channel> <+|-> <flag> <arguments>
    return
  }
  var %a, %z
  set %a 1
  while ($gettok($5-,%a,32) != $null) {
    set %z $addtok(%z,$ifmatch,32)
    if ($numtok(%z,32) == $ncid(modesonline)) {
      queuename mmode. $+ $1 mode $2 $3 $+ $str($4,$ncid(modesonline)) %z
      set %z
    }
    inc %a
  }
  if (%z != $null) queuename mmode. $+ $1 mode $2 $3 $+ $str($4,$numtok(%z,32)) %z
  ;  queuename mmode. $+ $1
}
mmsg {
  var %a, %y, %z
  set %a 1
  while ($gettok($1,%a,44) != $null) {
    set %z $ifmatch
    if (%z != $me) set %y $addtok(%y,%z,44)
    if ($numtok(%y,44) == 10) {
      queue privmsg %y : $+ $2-
      set %y
    }
    inc %a
  }
  if (%y) queue privmsg %y : $+ $2-
  queue
}
mnotice {
  var %a, %y, %z
  set %a 1
  while ($gettok($1,%a,44) != $null) {
    set %z $ifmatch
    if (%z != $me) set %y $addtok(%y,%z,44)
    if ($numtok(%y,44) == 10) {
      queue notice %y : $+ $2-
      set %y
    }
    inc %a
  }
  if (%y) queue notice %y : $+ $2-
  queue
}
mop {
  if ($me !isop #) {
    _doraw.fake 482 $server # $me #
    return
  }
  if ($nick(#,0,a,vr) == 0) {
    iecho There are no unopped users on $hc(#) $+ .
    return
  }
  var %a, %z
  set %a 1
  while ($nick(#,%a,vr)) {
    mmode2 enqueue $ifmatch
    inc %a
  }
  mmode2 flush + o #
}
mv {
  if (# !ischan) return
  if (($me !isop #) && ($me !ishop #)) {
    _doraw.fake 482 $server # $me #
    return
  }
  if ($nick(#,0,r) == 0) {
    iecho There are no unvoiced users on $hc(#) $+ .
    return 
  }
  var %a, %z
  set %a 1
  while ($nick(#,%a,r)) {
    mmode2 enqueue $ifmatch
    inc %a
  }
  mmode2 flush + v #
}
vmsg {
  if ($1 != $null) {
    if (hybrid-6 isin $ncid(server_version)) qmsg @+ $+ # [ $+ %voice $+ : $+ # $+ ] $1-
    else {
      var %a, %z
      set %a 1
      while ($nick(#,%a,a,r) != $null) {
        set %z $addtok(%z,$ifmatch,32)
        if ($len(%z) > 512) {
          mmsg %z [ $+ %voice $+ : $+ # $+ ] $1-
          set %z
        }
        inc %a
      }
      if (%z != $null) mmsg %z [ $+ %voice $+ : $+ # $+ ] $1-
    }
    if ($show) iiecho -> [[ $+ %voice $+ : $+ $hc(#) $+ ]] $1-
  }
  else theme.syntax /vmsg <message>
}
vnotice {
  if ($1 != $null) {
    if (hybrid-6 isin $ncid(server_version))  qnotice @+ $+ # [ $+ %voice $+ : $+ # $+ ] $1-
    else {
      var %a, %z
      set %a 1
      while ($nick(#,%a,a,r) != $null) {
        set %z $addtok(%z,$ifmatch,32)
        if ($len(%z) > 512) {
          mnotice %z [ $+ %voice $+ : $+ # $+ ] $1-
          set %z
        }
        inc %a
      }
      if (%z != $null) mnotice %z [ $+ %voice $+ : $+ # $+ ] $1-
    }
    if ($show) iiecho -> [[ $+ %voice $+ : $+ $hc(#) $+ ]] $1-
  }
  else theme.syntax /vnotice <message>
}
onotice {
  if ($1 != $null) {
    if (hybrid-6 isin $ncid(server_version)) qnotice @ $+ # [ $+ %wall $+ : $+ # $+ ] $1-
    elseif ($me isop #) !.onotice # [ $+ %wall $+ : $+ # $+ ] $1-
    else {
      var %a, %z
      set %a 1
      while ($nick(#,%a,a,rv) != $null) {
        set %z $addtok(%z,$ifmatch,32)
        if ($len(%z) > 512) {
          mnotice %z [ $+ %wall $+ : $+ # $+ ] $1-
          set %z
        }
        inc %a
      }
      if (%z != $null) mnotice %z [ $+ %wall $+ : $+ # $+ ] $1-
    }
    if ($show) iiecho -> [[ $+ %wall $+ : $+ $hc(#) $+ ]] $1-
  }
  else theme.syntax /wall <message>
}
omsg {
  if ($1 != $null) {
    if (hybrid-6 isin $ncid(server_version)) qmsg @ $+ # [ $+ %wall $+ : $+ # $+ ] $1-
    elseif ($me isop #) !.omsg # [ $+ %wall $+ : $+ # $+ ] $1-
    else {
      var %a, %z
      set %a 1
      while ($nick(#,%a,a,rv) != $null) {
        set %z $addtok(%z,$ifmatch,32)
        if ($len(%z) > 512) {
          mmsg %z [ $+ %wall $+ : $+ # $+ ] $1-
          set %z
        }
        inc %a
      }
      if (%z != $null) mmsg %z [ $+ %wall $+ : $+ # $+ ] $1-
    }
    if ($show) iiecho -> [[ $+ %wall $+ : $+ $hc(#) $+ ]] $1-
  }
  else theme.syntax /wallm <message>
}
nwall $iif($show,nnotice,.nnotice) $1-
nwallm $iif($show,nmsg,.nmsg) $1-
vwall $iif($show,vnotice,.vnotice) $1-
vwallm $iif($show,vmsg,.vmsg) $1-
wall $iif($show,onotice,.onotice) $1-
wallm $iif($show,omsg,.omsg) $1-
updial {
  var %c = $iif($1 ischan,$1,$active)
  if (%c !ischan) return
  chancid %c ircops
  chancid %c updateial $ticks
  ncid joinwho $remtok($ncid(joinwho),%c,1,44)
  ncid updial $addtok($ncid(updial),%c,44)

  .quote who %c
}
updibl {
  var %c = $iif($1 ischan,$1,$active)
  if (%c !ischan) return
  chancid %c updateibl $ticks
  ncid updibl $addtok($ncid(updibl),%c,44)
  .quote mode %c b
}
cycle {
  if ($1 ischan) {
    if ((i isin $gettok($chan($1).mode,1,32)) && ($nick($1,0) > 1)) iecho Cannot cycle an invite only channel.
    else {
      ncid joinsync. [ $+ [ $1 ] ] $ticks
      hop $1
    }
  }
  elseif ($active ischan) {
    if ((i isin $gettok($chan(#).mode,1,32)) && ($nick(#,0) > 1)) iecho Cannot cycle an invite only channel.
    else {
      ncid joinsync. [ $+ [ # ] ] $ticks
      hop 
    }
  }
  else {
    theme.syntax /cycle [channel]
  }
}
_clones.find {
  var %i = 1, %x, %y, %c = [ [ $iif($1 isnum,$1,$cid) ] $+ ] .ircN.cid
  set %x $hfind(%c, $1,0).data
  while (%i <= %x) {
    if (($gettok($hfind(%c, $1,%i).data,1,9) == clones) && ($gettok($hfind(%c, $1,%i).data,2,9) == $2)) return $null
    inc %c
  }
  return $1
}
clones {
  var %a = 1, %b, %c = $iif($1 ischan,$1,#), %d, %f, %i = 0, %w
  set %w $iif($nvar(clonescan.window), $+(@Clones.,%c,.,$cid), %c)
  if (!$chan(%c)) return

  if (!$chan(%c).ial) { 
    if ($show) iecho The IAL is empty for this channel. Please update ial $hc(/updial) before using /clones
    return 
  }
  ncid -r $tab(clones,%c,*)
  while ($ialchan(*,%c,%a)) {
    if ($ialchan(*,%c,%a).nick == $me) { inc %a | continue }  
    set %b *!*@ $+ $ialchan(*,%c,%a).host 
    if (($ialchan(*,%c,%a)) && (%b == $address($me,2))) { inc %a | continue }
    if ($mysite == $ialchan(*,%c,%a).host) { inc %a | continue }

    if (($ialchan(%b,%c,0) > 1) && ($_clones.find($ialchan(*,%c,%a).host,%c))) {
      inc %i
      ncid $tab(clones,%c,%i) $ialchan(*,%c,%a).host
    }
    inc %a
  }

  if (!%i) goto nonefound
  if (%i >= 1) {
    if (@* iswm %w) {
      window -k $+ $iif((!$istok($ncid(joinwho),%c,44) || $cmdbox),a,n) %w
      clear %w
    }

    echo -g %w $lfix(3,.) $+ $str(-,50) $+ .
    echo -gm %w $lfix(3,$vl) Clone Information on $fix(27,$hc(%c)) $vl
    echo -g %w $lfix(3,$vl) $+ $str(-,50) $+ $vl
    echo -g %w $lfix(3,$vl) $fix(11,Nick) $fix(37,Ident) $+ $vl
    set %a 1
    while (%a <= %i) {
      set %b *!*@ $+ $ncid($tab(clones,%c,%a))
      if (($ialchan(%b,%c,0) == 2) && (%b == $address($me,2))) { inc %a | continue }
      set %d 1
      echo -g %w $lfix(3,$vl) $+ $str(-,50) $+ $vl
      echo -g %w $lfix(3,$vl) Host: $fix(42,$ncid($tab(clones,%c,%a))) $vl
      echo -g %w $fix(1) $fix(50,$vl) $vl
      while ($ialchan(%b,%c,%d)) {
        echo -g %w $lfix(3,$vl) $fix(11,$hc($ialchan(%b,%c,%d).nick)) $fix(10,$ac($ialchan(%b,%c,%d).user)) $fix(25,) $vl
        inc %d
      }
      inc %a
    }
    echo -g %w $lfix(3,') $+ $str(-,50) $+ '
  }
  else {
    :nonefound
    if ($cmdbox) {
      if ($show) iecho -a No clones found in %c
    }
  }
  ncid -r $tab(clones,%c,*)
}
cstats {
  var %a = $iif($1,$1,#)
  ncid cstats $addtok($ncid(cstats),%a,44)
  ncid niops 0
  ncid naway 0
  ncid ncls 0
  .quote who %a
}
rban {
  var %c = $iif($1 ischan,$1)
  var %d = $iif(%c,$2,$1)
  if (!%c) set %c #
  if (!%c) { iecho error: /rban must specify a channel or have a channel active | return }
  if (!$ibl(%c,0)) { iecho No bans in $hc(%c) found. If this is incorrect type /updibl to update the internal ban list. | return }
  if (!%d) {
    ; list bans
    iiecho  . $+ $str(-,15) Bans on $paren($hc(%c)) $str(-,15)
    iiecho $fix(4,$|) $fix(10,Nick) Banmask
    var %a = 1, %b
    while (%a <= $ibl(%c,0)) {
      iiecho $| $b($gettok(%a,1,33)) $+ .  $hc($ibl(%c,%a).by)
      iiecho $fix(10,$|) host: $sc($ibl(%c,%a))
      iiecho $fix(10,$|) time: $sc($ibl(%c,%a).date)
      inc %a   
    }  
    iiecho ' $+ $str(-,$pls($len(%c),42))
    iecho  To remove a ban type $hc(/rban <ban #>) $+ .
    return
  }
  if (($me !isop %c) && ($me !ishop %c)) {
    _doraw.fake 482 $server # $me #
    return
  }

  var %a = 1
  if ((%d isnum) && ($ibl(%c,%d)))  mode %c -b $ibl(%c,%d) 
  else iecho No such ban $hc($iif($1 isnum,$chr(35)) $+ $hc($1))
}
clban rban $$1-
who {
  if ($1) {
    ncid who $addtok($ncid(who),$1,44)
    .quote who $1-
    iiecho .who of $hc($1) $str(-,40)
  }
  elseif (($active ischan) || ($query($active))) {
    ncid who $addtok($ncid(who),$active,44)
    .quote who $active
    iiecho .who of $hc($active) $str(-,40)
  }
  else theme.syntax /who <channel|nick|host>
}
cban {
  if ($0 < 1) {
    theme.syntax /cban <nick>
    return
  }
  var %a, %z
  set %a 1
  while ($comchan($1,%a)) {
    set %z $ifmatch
    if (($me isop %z) || ($me ishop %z)) queue mode %z $de-op($1)
    inc %a
  }
  queue
}
ckb {
  if ($0 < 1) {
    theme.syntax /ckb <nick> [reason]
    return
  }
  var %a, %z
  set %a 1
  while ($comchan($1,%a)) {
    set %z $ifmatch
    if (($me isop %z) || ($me ishop %z)) {
      queue mode %z $de-op($1)
      queue kick %z $1 : $+ $2-
    }
    inc %a
  }
  queue
}
ckick {
  if ($0 < 1) {
    theme.syntax /ckick <nick> [reason]
    return
  }
  var %a, %z
  set %a 1
  while ($comchan($1,%a)) {
    set %z $ifmatch
    if (($me isop %z) || ($me ishop %z)) queue kick %z $1 : $+ $2-
    inc %a
  }
  queue
}
cop {
  if ($0 < 1) {
    theme.syntax /cop <nick>
    return
  }
  var %a, %z
  set %a 1
  while ($comchan($1,%a)) {
    set %z $ifmatch
    if ($me isop %z) queue mode %z +o $1
    inc %a
  }
  queue
}
fk {
  if ($0 < 1) {
    theme.syntax /fk [channel] <hostmask> [reason]
    return
  }
  var %a, %w, %x, %y, %z
  if ($1 ischan) {
    set %w $1
    set %x $2
    if ($3- != $null) set %y : $+ $3-
    else set %y :Filter kick of %x
  }
  else {
    set %w #
    set %x $1
    if ($2- != $null) set %y : $+ $2-
    else set %y :Filter kick of %x
  }
  set %a 1
  while ($ialchan(%x,%w,%a).nick != $null) {
    set %z $ifmatch
    if (%z != $me) queue kick %w %z %y
    inc %a
  }
  queue
}
fkb {
  if ($0 < 1) {
    theme.syntax /fkb [-uN] [channel] <hostmask> [reason]
    return
  }
  var %a, %c, %h,  %f, %w, %x, %y, %z
  if (-*u* iswm $1) set %f $1
  if ((%f) && ($2 ischan)) { set %c $2 | set %h $3 | set %r $4- }
  elseif ($1 ischan) { set %c $1 | set %h $2 | set %r $3- }
  else {
    set %c #
    if (%f) { set %h $2 | set %r $3- }
    else { set %h $1 | set %r $2- }
  }
  if (%c !ischan) { return }
  if (($me !isop %c) && ($me !ishop %c)) {
    _doraw.fake 482 $server %c $me %c
    return
  }
  if (*@* !iswm %h) {
    if (%h) set %h %h $+ *!*@*
    else return
  }
  if (*!* !isin %h) set %h *!* $+ %h
  if (%r != $null) set %y : $+ %r
  else set %y :Filter kickban of %h
  set %a 1
  while ($ialchan(%h,%c,%a).nick != $null) {
    set %z $ifmatch
    if (%z != $me) queuecmd .quote kick %c %z %y
    inc %a
  }
  queuecmd !ban %f %c %h
  queuecmd
}
fnk {
  if ($0 < 1) {
    theme.syntax /fnk [channel] <nickname wildcard> [reason]
    return
  }
  if ($1 ischan) fk $1 $iif(* isin $2,$2,* $+ $2 $+ *) $+ !*@* $3-
  else fk #  $iif(* isin $1,$1,* $+ $1 $+ *) $+ !*@* $2-
}
fnkb {
  if ($0 < 1) {
    theme.syntax /fnkb [channel] <nickname wildcard> [reason]
    return
  }
  if ($1 ischan) fkb $1 $iif(* isin $2,$2,* $+ $2 $+ *) $+ !*@* $3-
  else fkb # $iif(* isin $1,$1,* $+ $1 $+ *) $+ !*@* $2-
}
invite {
  if ($2 ischan) {
    iecho Invited $hc($1) to $hc($2) at $hc($atime) $+ .
    .quote invite $1 $2
  }
  elseif (($1) && ($active ischan)) {
    iecho Invited $hc($1) to $hc($active) at $hc($atime) $+ .
    .quote invite $1 $active
  }
  else theme.syntax /invite <nick> [#channel]
}
ia {
  var %a = 1
  while ($chan(%a)) {
    if ((($me isop $chan(%a)) || (i !isin $gettok($chan(%a).mode,1,32))) && ($1 !ison $chan(%a)) && ($chan(%a) != $modvar(away,idlechan))) .quote invite $1 $chan(%a)
    inc %a
  }
}
clearial ialclear $1-
ialclear {
  if ($1 ischan) {
    var %a = 1
    while ($nick($1,%a) != $null) { !ialclear $ifmatch | inc %a }
  }
  else !ialclear $1-
}
ircops {
  var %a = $iif($1,$1,#)
  ncid lircops $addtok($ncid(lircops),%a,44)
  .quote who %a
}
names {
  var %a = $iif($1,$1,#)
  ncid nameschan $addtok($ncid(nameschan),%a,44)
  ncid -r nameschan. $+ %a 
  .quote names %a
}
idlekick mkick $iif(-* iswm $1,$1 $+ i) $2-
idlekb mkb $iif(-* iswm $1,$1 $+ ib $2-, -ib $1-)
;fix this .. not sure to use mkick with -b or mkb... ^^
idlescan {
  ;/idlescan [#chan] [time]
  ;ex: /idlescan #chan 5d 3h 30
  var %a = 1, %b, %c, %t, %f
  if (-* iswm $1) { set %f $1 | tokenize 32 $2- }

  set %c $iif($1 ischan,$1)
  if ((%c) && ($remove($2,m,h,s,d,w) isnum)) set %t $time2secs($2)
  elseif ($remove($1,m,h,s,d,w) isnum) set %t $time2secs($1)
  if (!%c) set %c #
  if ($remove($1,m,h,s,d,w) !isnum) set %t 3600
  if (%c == $null) return
  var %echo
  if ($nvar(idlescan.activewindow)) set %echo iiecho -a
  else { window -k @Idlescan. $+ %c $window(%c).font $window(%c).fontsize | clear @Idlescan. $+ %c | set %echo echo @Idlescan. $+ %c }

  if ($changet(%c,lastjoin)) {
    if (%t >= $calc($ctime - $changet(%c,lastjoin))) { iecho $iif(n isincs %f,Non-) $+ Idlescan: You haven't been the channel that long  | return }
  }
  if (n isincs %f) {
    if (%t <= $chan(%c).idle) { iecho Non-Idlescan: no one has spoken in that time | return }
  }
  var %q = $iif($ncid(server_nicklen),$pls($ncid(server_nicklen),7),18)
  if (n isincs %f) set %q $sub(%q,4)
  %echo $lfix(3,.) $+ $str(-,$iif($ncid(server_nicklen),$pls($ncid(server_nicklen),29),40)) $+ .
  %echo $lfix(3,$vl) $iif(n isincs %f,Non-) $+ Idle Information on $fix(%q,$hc(%c)) $vl
  %echo $lfix(3,$vl) $+ $str(-,$iif($ncid(server_nicklen),$pls($ncid(server_nicklen),29),40)) $+ $vl
  %echo $lfix(3,$vl) $fix($iif($ncid(server_nicklen) isnum,$calc($ifmatch +2),12),Nick) $fix(25, $iif(n isincs %f,Active,Idle) ) $+ $vl
  if ($isfile($dd(whilefix.dll))) var %dll = dll $dd(WhileFix.dll) WhileFix .

  while ($nick(%c,%a,a) != $null) {
    set %b $ifmatch
    %dll
    if ($nick(%c,%b).idle $iif(n isincs %f,<=,>=) %t) { 
      %echo $lfix(3,$vl) $fix($iif($ncid(server_nicklen) isnum,$calc($ifmatch + 2),12), $+ $nick(%c,%b).color $+ $nick(%c,%b).pnick) $fix(24,$rsc2($duration($nick(%c,%b).idle))) $vl
    }
    inc %a
  }
  %echo $lfix(3,') $+ $str(-,$iif($ncid(server_nicklen),$pls($ncid(server_nicklen),29),40)) $+ '
}
nonidlescan  idlescan -n $1-
mi {
  if (#$1) {
    iecho Mass Inviting $hc(#) to $hc($1) $+ .
    var %a = 1
    while ($nick(#,%a) != $null) {
      if (($nick(#,%a) != $me) && ($nick(#,%a) !ison $1)) queue invite $nick(#,%a) $1
      inc %a
    }
    queue
  }
  else theme.syntax /mi <invite-to-chan>
}
lmsg {
  if (hybrid-6 isin $ncid(server_version)) {
    iecho Sorry, this command can not be used on HYBRID 6 servers.
    return
  }
  if (($active ischan) && ($snicks) && ($1)) {
    mmsg $snicks $1-
    iiecho [ $+ $sc(msg) $+ ( $+ $ac(Selected Nicks) $+ )] $1-
  }
  elseif (($active !ischan) && ($1)) iecho Not in a channel.
  elseif (($snicks == $null) && ($1)) iecho No nicknames selected.
  else theme.syntax /lmsg <message>
}
lnotice {
  if (hybrid-6 isin $ncid(server_version)) {
    iecho Sorry, this command can not be used on HYBRID 6 servers.
    return
  }
  if (($active ischan) && ($snicks) && ($1)) {
    mnotice $snicks $1-
    iiecho [ $+ $sc(not) $+ ( $+ $ac(Selected Nicks) $+ )] $1-
  }
  elseif (($active !ischan) && ($1)) iecho Not in a channel.
  elseif (($snicks == $null) && ($1)) iecho No nicknames selected.
  else theme.syntax /lnotice <message>
}
mdns {
  var %a = 1
  while ($nick(#,%a) != $null) {
    $iif(!$show,.) $+ dns $nick(#,%a)
    inc %a
  }
}
ht {
  var %chan, %topic 
  if ($1 ischan) { set %chan $1 | set %topic $2- }
  else { set %chan # | set %topic $1- }
  if (%chan !ischan) { 
    if ($show) theme.syntax /ht [#chan] [topic]
    return 
  }
  nset $tab(chan,#,holdtopic,topic) $iif(%topic,%topic,$chan(%chan).topic)
  nset $tab(chan,#,holdtopic) on
  if ($show) iecho Holding topic for $hc(%chan) $+ .
}
ut {
  var %a = $iif($1,$1,#)
  if ($nget($tab(chan,%a,holdtopic)) != on) {
    if ($show) iecho You weren't holding topic for $hc(%a) $+ !
    return
  }
  ndel $tab(chan,%a,holdtopic,topic)
  ndel $tab(chan,%a,holdtopic)
  if ($show) iecho Topic has been unheld for $hc(%a) $+ .
}
wholeft {
  var %a = 1, %b, %c, %d, %e, %h = $nnetsplit
  if (!$hget(%h)) {
    iecho No servers have split.
    return
  }
  iiecho  . $+ $str(-,60) $+ .
  iiecho $vl $center(58,Split Servers) $vl
  iiecho $vl $+ $str(-,60) $+ $vl
  while (%a <= $hfind(%h,split*,0,w)) {
    set %b $hfind(%h,split*,%a,w)
    set %c 1
    iiecho $vl Split [[ $+ $lfix(2,$hc(%a)) $+ ]] $fix(47, [ $gettok($gettok(%b,2,1),1,38) ] from [ $gettok($gettok(%b,2,1),2,38)  ] ) $vl
    while (%c <= $hfind(%h,wholeft $+ $gettok(%b,2,1) $+ *,0,w)) {
      set %d $hfind(%h,wholeft $+ $gettok(%b,2,1) $+ *,%c,w)
      iiecho $fix(7,$vl) $lfix(2,%c) $+ . $fix(25,$hc($gettok(%d,3,1))) $fix(22,$rsc($duration($calc($ctime - $hget(%h,%d))))) $vl
      inc %c
    }
    iiecho $fix(60,$vl) $vl
    inc %a
  }
  iiecho ' $+ $str(-,60) $+ '
}
refial {
  ialclear
  var %a = 1
  while (%a <= $chan(0)) {
    if (($me ison $chan(%a)) && ($chan(%a).ial == $false) && ($chan(%a) != $modvar(away,idlechan)) && ($findtok($ncid(joinwho),$chan(%a),1,44) == $null) && ($nick($chan(%a),0) < 200)) {
      ncid joinwho $addtok($ncid(joinwho),$chan(%a),44)
      .quote who $chan(%a)
    }
    inc %a
  }
  iecho iecho Refreshed IAL
}
topicsites {
  var %a
  if ((!$topicurls(1)) && (!$topicftps(1))) {
    iecho no Websites/FTPs found in the topic
    return
  }
  if ($topicurls(1)) {
    iecho Topic Websites:
    set %a 1
    while ($topicurls(%a)) {
      iiecho %a $+ . $gettok($ifmatch,4-,32)
      inc %a
    }
  }
  if ($topicftps(1)) {
    iecho Topic FTPs:
    set %a 1
    while ($topicftps(%a)) {
      iiecho %a $+ . $gettok($ifmatch,4-,32)
      inc %a
    }
  }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; INTERNAL COMMANDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


_nnetsplit return $cid $+ .ircN.netsplits
_ns.serv {
  var %h = $nnetsplit
  if (!$hget(%h)) hmake %h 16
  var %a = $1 $+ & $+ $2
  if (!$hget(%h,split $+ %a)) hadd %h split $+ %a $true $ctime
}
_ns.nick if (!$hget($nnetsplit,wholeft $+ $2 $+  $+ $1))  hadd $nnetsplit wholeft $+ $2 $+  $+ $1 $ctime
_ns.issplit {
  if (!$hget($nnetsplit)) return $false
  if ($2) {
    if ($hget($nnetsplit,split $+ $1 $+ & $+ $2)) return $true
  }
  elseif ($1) {
    if ($hfind($nnetsplit,split* $+ $1 $+ *,1,w)) return $true
    elseif ($hfind($nnetsplit,wholeft* $+ $1,1,w)) return $true
  }
}
_clnsplit {
  var %a = 1, %b, %c, %d, %e, %h = $_nnetsplit
  if (!$hget(%h)) return
  while (%a <= $hfind(%h,split*,0,w)) {
    set %b $hfind(%h,split*,%a,w)
    set %c 1
    while (%c <= $hfind(%h,wholeft $+ $gettok(%b,2,1) $+ *,0,w)) {
      set %e $hfind(%h,wholeft $+ $gettok(%b,2,1) $+ *,%c,w)
      if ($calc($ctime - $gettok($hget(%h,%e),2,32)) >= 432000)  hdel %h %e
      inc %c
    }
    if (!$hfind(%h,wholeft $+ $gettok(%b,2,1) $+ *,0,w))  hdel %h %b
    inc %a
  }
  if (!$hget(%h,0).item) { hfree %h | ntimer netsplit.clean off }
}
_popup.topicurls {
  var %a, %b
  if ($1 == begin) return $style(2) $tab - Websites - :!
  if ($1 isnum) {
    set %b $chan(#).topic
    set %a $regex(%b,/(www?\.[\S]+|https?:\/\/[\S]+)/g)
    if (%a >= $1) {
      var %q = $trimnonalphanum($regml($1))
      var %y
      set %y %q 
      if (http://* iswm %y) set %y $right(%y,-7)
      if (https://* iswm %y) set %y $right(%y,-8)
      return $shorttext(65,%y) : url %q
    }
  }
  if ($1 == end) return -
}
_popup.topicftps {
  var %a, %b
  if ($1 == begin) return $style(2) $tab - FTP Sites - :!
  if ($1 isnum) {
    set %b $chan(#).topic
    set %a $wildtok(%b,ftp://*.*, [ $1 ],32)
    if (%a) return $left($right(%a,-6),65) $+ $iif($len(%a) > 71,...) : url %a
  }
  if ($1 == end) return -
}
_popup.chantextrecent {
  if ($1 == begin) {
    window -h $+(@nickchanfilter., $2, ., $3) 
    filter -bwwc $2 $+(@nickchanfilter., $2, ., $3) * $+ $3 $+ *
    return - Recen Text - :!
  }
  if ($1 isnum) {
    var %a =  $strip($line($+(@nickchanfilter., $2, ., $3),$1))
    ;  iecho %a
    if ($1 > 10) return
    if ($replace($strip($timestampfmt),n,?,h,?,t,?) iswm $gettok(%a,1,32)) set %a $gettok(%a,2-,32)
    if (%a) return $remove(%a,:,{,}) : !
  }
  if ($1 == end) {
    close -@ $+(@nickchanfilter., $2, ., $3)
    return -
  }
}
_popup.chanurlsrecent {

  ;check if '? urls ontop is checked since itll break it
  var %a, %b
  if ($1 == begin) return $style(2) $tab - Recently linked websites - :!
  if ($1 isnum) {
    var %max = $iifelse($nvar(popup.urlcatch.maxurls),20)
    if ($1 > %max) return
    var %a = $url($calc($url(0) - $1))
    if (!%a) || (%a isnum) return
    return $1 $+ . $shorttext(55,$remove(%a,http://www.,http://,https://)) :  url %a
  }

  if ($1 == end) return -
}
_removebanprompt {
  if ($0 < 3) return
  if ($me !ison $1) return

  var %type = $iifelse($prop,ibl)
  if ($ [ $+ [ %type ]  $+ ] ($1,0) == $null) return
  var %a = 1, %b

  while ($ [ $+ [ %type ]  $+ ] ($1,%a) != $null) {
    set %b $addtok(%b, $ifmatch,44)
    inc %a
  }
  if (!%b) return
  var %x = $input($2,m,$3,m, [ %b ] )
  return %x
}
_doquitcheck.chan {
  var %a, %z
  set %a 1
  set %z $1
  if (($nick(%z,0) == 1) && ($me !isop %z) && ($nick(%z,1) == $me) && ($istok($ncid(cyclechannels),%z,44) != $true)) {
    .quote part %z $+ $crlf $+ join %z
    ncid cyclechannels $addtok($ncid(cyclechannels),%z,44)
  }
}
_doquitcheck {
  var %a, %z
  set %a 1
  while ($chan(%a) != $null) {
    set %z $ifmatch
    if (($ischanset(autocycle,%z)) && ($nick(%z,0) == 1) && ($me !isop %z) && ($nick(%z,1) == $me) && ($istok($ncid(cyclechannels),%z,44) != $true)) {
      .quote part %z $+ $crlf $+ join %z
      ncid cyclechannels $addtok($ncid(cyclechannels),%z,44)
    }
    inc %a
  }
}

; ################################################################
; ####################### IRCN SCRIPT FILE #######################
; ########## END OF FILE. DO NOT REMOVE OR MODIFY BELOW ##########
; ################################################################
