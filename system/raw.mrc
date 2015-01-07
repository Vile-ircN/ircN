raw 3:*:{
  ; RPL_CREATED
  var %r = /This server was created (.*)/
  if ($regex($1-,%r)) {
    if ($regml(1)) ncid server_CREATEDDATE $ifmatch
  }
}
raw 4:*:{
  ; RPL_MYINFO 

  ncid server_VERSION $3

  if ($findfile($sd(network),$+($curnet(noserver),.*),0) <= 1) {
    ncid network.hash $curnet(noserver)
  }

  var %a = $nethash.detect($network,$server,$serverip,$port,$me,$anick,$emailaddr,$fullname)
  if ($gettok(%a,2,32) > 0) {
    ncid network.hash $+($gettok(%a,1,32),$iif($gettok(%a,2,32) > 1,. $+ $gettok(%a,2,32)))
  }
  else {
    ncid network.hash $curnet(noserver)
  }
  ncid network.hash.num  $networknum($curnet)
}
raw 5:*:{
  ; RPL_PROTOCTL

  _process.rawcode5 $2-
}

;;  ! FIX THIS !! these two should be combined

raw 263:*:{
  ; RPL_LOAD2HI or RPL_TRYAGAIN
  iecho $1-
  if ($2 === WHOIS) {
    if ($istok($ncid(quietwhois),$2,44)) {  ncid quietwhois $remtok($ncid(quietwhois),$2,1,44)  | ncid -u15 qwhois.ratelimit 1 | halt }
    if ($istok($ncid(whois),$2,44)) {  ncid whois $remtok($ncid(whois),$2,1,44)  }

  }
}
raw 301:*:{
  ; RPL_AWAY 

  cwiset $2 awaymsg $3- 
  cwiset $2 away $true 
  if ($istok($ncid(quietwhois),$2,44)) halt
}
raw 303:*:{
;  echo -s notify: $1-
  if ($nocolon($2-) == $null) {
    ncid -r notify.online 
    var %a = 1
    while ($notify(%a) != $null) {
      if (($istok($notify(%a).network,$curnet,44)) || ($notify(%a).network == $null)) ncid notify.notonline $addtok($ncid(notify.notonline),$notify(%a),44)
      inc %a
    }
  }
}


raw 302:*:{
  ; RPL_USERHOST 

  var %i = 2, %t = $0, %p, %addr, %pos, %m
  while (%i <= %t) {
    %p = $ [ $+ [ %i ] ]
    %addr = $gettok(%p, 2, 61)
    %pos = $pos(%addr, $left($remove(%addr, +, -), 1), 1)
    set -u1 %::nick $gettok(%p, 1, 61)
    set -u1 %::address $mid(%addr, %pos)
    if ($right(%::nick, 1) == *) { %::nick = $left(%::nick, -1) }
    if ($notify(%::nick)) {
      inc %m
      if (%::nick != $me) { 
        ncid notify.online $addtok($ncid(notify.online),%::nick,44) 
        nset $+(notify.,%::nick,.lastseen) $ctime $iifelse($notify(%::nick).addr,%address)
        ncid $+(notify.,%::nick,.addr) $iifelse($notify(%::nick).addr,%address)
      }

    }
    inc %i
  }
  if (%m) halt
}
raw 302:*:{
  ; RPL_USERHOST

  if (!$2) return
  var %a = $gettok($2,1,61)
  var %b = $right($gettok($2,2,61),$sub($len($gettok($2,2,61)),1))
  var %c = %a $+ ! $+ %b

  if ($right(%a,1) == *) { 
    set %a $left(%a,-1)
    cwiset %a ircop $true
  }
  if ($left($gettok($2,2,61),1) == +) cwiset %a away $true
  if ($notify(%a)) {
    if (($ulist(%c,1)) && ($ismod(userlist))) iecho -t $hc(NOTIFY) $+ : $sc(%a) ( $+ %b $+ ) is on IRC (address registered to $usrh($ulist(%c,1)) $+ ). $iif(getnick.* !iswm $notify(%c).note,$rbrk($notify(%c).note))
    else  iecho -t $hc(NOTIFY) $+ : $sc(%a) ( $+ %b $+ ) is on IRC $rbrk($notify(%a).note)

    if (%a != $me) { 
      ncid notify.online $addtok($ncid(notify.online),%a,44) 
      nset $+(notify.,%a,.lastseen) $ctime $iifelse($notify(%a).addr,%b)
      ncid $+(notify.,%a,.addr) $iifelse($notify(%a).addr,%b)

      halt
    }
  }
}
raw 307:*:{
  ; RPL_USERIP

  if ($istok($ncid(quietwhois),$2,44)) halt
}
raw 310:*:{
  ; RPL_WHOISHELPOP

  if ($istok($ncid(quietwhois),$2,44)) halt
}
raw 311:*:{
  ; RPL_WHOISUSER 

  cwiset $2 cwhois $ctime
  if (!$ial($2)) cwiset $2 address $4
  cwiset $2 ircname $strip($6-)
  cwiset $2 ident $3
  cwiset $2 away
  cwiset $2 awaymsg
  cwiset $2 signon
  cwiset $2 idle
  if ($istok($ncid(quietwhois),$2,44)) halt
}
raw 312:*:{
  ; RPL_WHOISSERVER

  cwiset $2 server $3
  if ($istok($ncid(quietwhois),$2,44)) halt
}
raw 313:*:{
  ; RPL_WHOISOPERATOR

  if ($istok($ncid(quietwhois),$2,44)) halt
}
raw 317:*:{
  ; RPL_WHOISIDLE

  cwiset $2 signon $4 
  cwiset $2 idle $iif($3 isnum,$3)
  if ($istok($ncid(quietwhois),$2,44)) halt
}
raw 318:*:{
  ; RPL_ENDOFWHOIS

  if ($istok($ncid(quietwhois),$2,44)) {  ncid quietwhois $remtok($ncid(quietwhois),$2,1,44)  | halt }
}
raw 319:*:{
  ; RPL_WHOISCHANNELS

  cwiset $2 chans $3-9
  if ($istok($ncid(quietwhois),$2,44)) halt
}
raw 321:*:{
  ; RPL_LISTSTART

  ncid is_chanlisting $true
}
raw 323:*:{
  ;RPL_LISTEND

  ncid -r is_chanlisting
}
raw 330:*:{
  ; RPL_regeduser

  cwiset $2 regeduser $3
  if ($istok($ncid(quietwhois),$2,44)) halt
}
raw 338:*:{
  ; 
  if ($istok($ncid(quietwhois),$2,44)) halt
}
raw 351:*:{
  ; RPL_VERSION

  ncid server_RAW_351 $2-
  ncid server_VERSION.RAW351 $iif($right($2,1) == ., $left($2,-1), $2)

  if (!$ncid(server_version)) ncid server_VERSION $ncid(server_version.raw351)
}
raw 352:*:{
  ; RPL_WHOREPLY

  ;  if ($ncid(haltwho)) return
  cwiset $6 cwho $ctime
  cwiset $6 ident $3
  cwiset $6 server $5 
  cwiset $6 hops $nocolon($8)
  cwiset $6 ircname $strip($9-)
  cwiset $6 away $iif(G isincs $7,1)

  if ($ial($6)) {
    ; ** do these need to check for ial?
    if (* isin $7) {
      cwiset $6 ircop $true
      ;   ialset $6 server $5 
      chancid $2 ircops $addtok($chancid($2,ircops),$6,44)
      if ($ismod(userlist)) {
        if ($me ison $2)  colupdt $2 $6
      }
    }
  }
  if ($istok($ncid(nickfind.who),$4,44)) || ($istok($ncid(nickfind.who),$6,44))  {
    echo -s $1-
    aline @nickfind.who. $+ $cid $1-
    halt
  }
  elseif (($istok($ncid(joinwho),$2,44)) || ($istok($ncid(updial),$2,44))) {
    haltdef
  }
  elseif ($istok($ncid(cstats),$2,44)) {
    ; stuff
    if (* isin $7) ncid -i niops
    if (G isin $7) ncid -i naway
    ncid cladd $4
    ncid -i cnum
    ncid -i chops $8
    ncid hop1 $div($ncid(chops),$ncid(cnum))
    ncid hop2 $trncte($ncid(chops),$ncid(cnum))
    ncid hop3 $mpy($ncid(hop2),100)
    ncid hop4 $div($ncid(hop3),$ncid(cnum))
    if ($len($ncid(hop4)) == 1) ncid hop4 $ncid(hop4) $+ 0
    halt
  }
  elseif ($istok($ncid(lircops),$2,44)) {
    if (* isin $7) {
      ncid -i lircops. $+ $2 $+ .num
      cwiset $6 ircop $true
      if ($ncid(lircops. $+ $2 $+ .num) == 1) iiecho . $+ $str(-,5) $center(34,IRCOPS in $2) $+ $str(-,5) $+ .
      iiecho $vl $lfix(2,$ncid(lircops. $+ $2 $+ .num)) $+ . $fix(10,$hc($6)) $fix(28,$5) $vl
      if ($ismod(userlist)) {
        colupdt $2 $6
      }
    }
    halt
  }
}
raw 364:*:{
  ; RPL_LINKS

  if ($ncid(linklooker)) {
    haltdef
    if ($window(Links List).state == normal) window -h "Links List"
    var %a = $tp($curnet $+ .sll)
    var %b = $2
    if ((hub.* !iswm %b) && (services.* !iswm %b)) {
      if (($left(%b,1) == *) || ($left(%b,1) == .)) set %b irc. $+ $gettok(%b,2-,46)
      if (!$read(%a,nw,%b))  write %a %b
    }

  }
  elseif ($ncid(parse.links)) {
    haltdef
    if ($window(Links List).state == normal) window -h "Links List"
    var %a = $srvfile
    var %b = $2
    if ($window(@_servermap. $+ $cid))  aline @_servermap. $+ $cid $nocolon($4) $2 $3  
    if ((hub.* !iswm %b) && (services.* !iswm %b)) {

      if (($left(%b,1) == *) || ($left(%b,1) == .)) set %b irc. $+ $gettok(%b,2-,46)
      if (!$read(%a,nw,%b))  write %a %b
    }

  }
}
raw 365:*:{
  ; RPL_ENDOFLINKS

  if ($ncid(linklooker)) {
    ncid -r linklooker
    _ll.results
    if ($window(Links List))  window -c "Links List"
    haltdef
  }
  elseif ($ncid(parse.links)) {
    ncid -r parse.links
    if ($window(Links List)) window -c "Links List"
    var %a = $srvfile
    if ($lines(%a)) {

      if ($window($cidwin(@_servermap))) { savebuf  $cidwin(@_servermap) $srvmapfile | window -c $cidwin(@_servermap) }

      iecho -s List of $hc($curnet) servers has been made. ( $+ $hc($lines(%a)) servers)
      if ($nget(serverlistkeepfresh) != off) {
        if (($nvar(serverlistkeepfresh) == on) || ($nget(serverlistkeepfresh) == on)) { 

          deadlinks -quiet
          addlinks -quiet

        }

      }
    }
    if ($window($cidwin(@_servermap))) window -c $cidwin(@_servermap)
    haltdef
  }
}
raw 367:*:{
  ; RPL_BANLIST

  if ($istok($ncid(updibl),$2,44)) haltdef
}
raw 368:*:{
  ; RPL_ENDOFBANLIST

  if ($istok($ncid(updibl),$2,44)) { 
    haltdef
    if ($chancid($2,updateibl)) {
      var %ibltime = $rrpt($calc($ticks - $chancid($2,updateibl)))
      iecho -w $2 Updated IBL for $hc($ibl($2,0)) bans in $sc($iduration(%ibltime)) 
      ncid -r $tab(chan, $2, updateibl)
      .timer 1 1 ncidremtok updibl $2
      return
    } 

    ;clear bans.. redo all the rtban stuff to just use ibl
    if (($ischanset(clearbans,$2)) && ($ibl($2, 0)))  {
      iecho -w $2 Clearing bans in $hc($2) on join
      .timer 1 1 clbans $2
    }

    ncidremtok updibl $2
  }
}
raw 369:*:{
  ; RPL_ENDOFWHOWAS

  if ($istok($ncid(whowas),$2,44)) {
    ncid -r whowas.inc. $+ $2 $+ , $+ whowas.maxnum. $+ $2
    ncid whowas $remtok($ncid(whowas),$2,1,44) 
    haltdef 
  }
}
raw 378:*:{
  ; RPL_WHOISHOST

  var %r = /is connecting from (.+)\s?(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?/
  if ($regex($3-,%r)) {
    if ($regml(1)) {
      var %h = $_gettok($regml(1),1,32,2-,64)
      if (($ial($2)) && ($ial($2).host != %h)) || (($cwiget($2,address)) && ($cwiget($2,address) != %h)) { cwiset $2 realhost %h }
    }
    if (($regml(2)) && (!$cwiget($2,cdns)))  cwiset $2 cdns $regml(2)
  }
  if ($istok($ncid(quietwhois),$2,44)) halt
}
raw 379:*:{
  ; whois: using modes

  var %r 
  set %r /is using modes \+([a-zA-Z]+)\s?\+?([a-zA-Z]+)?/
  if ($regex($3-,%r)) {
    if ($regml(1)) cwiset $2 umode $regml(1)
    if ($regml(2)) cwiset $2 umode.ircop $regml(2)
  }
  if ($istok($ncid(quietwhois),$2,44)) halt
}
raw 381:*:{
  ; RPL_YOUREOPER

  if ($nget(ircop.enabled) == on) {
    if ($nget(ircop.umode)) mode $me $iif(+- !isin $nget(ircop.umode), +) $+ $nget(ircop.umode)

    if ($nvar(ircop.enableperform)) {
      if (!$nvar(ircop.performwithoutsuccess)) {
        ;if that variable is not set, its ok to call it on success.. otherwise it does it on the /oper
        _ircop.perform
      }
    }
  }
}
raw 391:*:{
  ; RPL_TIME

  var %t = $ctime( $remove($3-8,-) )
  if (%t) {
    ncid server_timediff $calc($ctime - %t)
    ncid server_time %t
  }
  if ($ncid(slagtmp) == on) {
    var %a = $rrpt($calc($ticks - $ncid(slag)))
    if (%a < 0) set %a 0
    iecho Server $hc(PING) $sc(reply) from $u($hc($nick)) $+ : $iduration(%a)

    ncid -r slag,slagtmp
    halt
  }
}
raw 401:*:{
  ; whois: ERR_NOSUCHNICK

  if ($istok($ncid(quietwhois),$2,44)) {  ncid quietwhois $remtok($ncid(quietwhois),$2,1,44)  | halt }
  if (($nvar(whowasonnowhois) == on) && ($istok($ncid(whois),$2,44))) .whowas $2
  ncid whois $remtok($ncid(whois),$2,1,44)
}
raw 402:*:{
  ; whois: ERR_NOSUCHSERVER

  if ($istok($ncid(quietwhois),$2,44)) {  ncid quietwhois $remtok($ncid(quietwhois),$2,1,44)  | halt }
  if (($nvar(whowasonnowhois) == on) && ($istok($ncid(whois),$2,44))) {
    ncid whowasonnowhois $addtok($ncid(whowasonnowhois),$2,44)
    .whowas $2
  }
  ncid whois $remtok($ncid(whois),$2,1,44)
}
raw 406:*:{
  ; whowas: ERR_WASNOSUCHNICK

  if ($istok($ncid(whowasonnowhois),$2,44)) {
    ncid whowasonnowhois $remtok($ncid(whowasonnowhois),$2,1,44)
    haltdef
  }
}
raw 421:*:{
  ; ERR_UNKNOWNCOMMAND

  if ($2 == LINKS) {
    if (($ncid(linklooker)) || ($ncid(parse.links))) {
      iecho This servers /links command is disabled making $iif($ncid(linklooker),$hc(/ll),$hc(/ml)) not operational.
      ncid -r linklooker,parse.links
    }
  }
}
raw 436:*:{
  ; ERR_NICKCOLLISION

  _doraw.fake 436 $server $me $1-
  tnick $me $+ $rand(a,z)
  halt
}
raw 604:*:{
  ; RPL_NOWON

  if ($2 != $me) {
    ncid notify.online $addtok($ncid(notify.online),$2,44)
    nset $+(notify.,$2,.lastseen) $ctime $notify($2).addr
  }

  if ($notify($2)) {
    if (($ulist($notifyaddr($2),1)) && ($ismod(userlist))) iecho -t $hc(NOTIFY) $+ : $sc($2) $paren($notifyaddr($2)) is on IRC (address registered to $usrh($ulist($notify($2).addr,1)) $+ ). $rbrk($notify($2).note)
    else  iecho -t $hc(NOTIFY) $+ : $sc($2) $paren($notifyaddr($2)) is on IRC $rbrk($notify($2).note)
  }
}
raw 615:*:{
  ; whois: using modes

  var %r 
  set %r /is using modes \+([a-zA-Z]+)\s?\+?([a-zA-Z]+)?/
  if ($regex($3-,%r)) {
    if ($regml(1)) cwiset $2 umode $regml(1)
    if ($regml(2)) cwiset $2 umode.ircop $regml(2)
  }
  if ($istok($ncid(quietwhois),$2,44)) halt
}
raw 616:*:{
  ; RPL_WHOISHOST 

  var %r, %r2
  set %r /is connecting from (.+) (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/
  set %r /real hostname (.+) (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/
  if ($regex($3-,%r)) || ($regex($3-,%r2)) {
    if (($regml(2)) && (!$cwiget($2,cdns))) cwiset $2 cdns $regml(2)
  }
  if ($istok($ncid(quietwhois),$2,44)) halt
}
raw 671:*:{
  ; RPL_WHOISSECURE 

  cwiset $2 sslclient 1
  if ($istok($ncid(quietwhois),$2,44)) halt
}
raw 730:*:{
  ; RPL_MONONLINE http://ircv3.atheme.org/specification/monitor-3.2

  var %a = 1, %b, %c, %nick, %addr
  while (%a <= $numtok($2-,44)) {
    set %c $gettok($2-,%a,44)
    set %nick $gettok(%c,1,33)
    set %addr $gettok(%c,2-,33)
    if ($notify(%nick)) {
      if (($ulist(%c,1)) && ($ismod(userlist))) iecho -t $hc(NOTIFY) $+ : $sc(%nick) ( $+ %addr $+ ) is on IRC (address registered to $usrh($ulist(%c,1)) $+ ). $rbrk($notify(%nick).note)
      else  iecho -t $hc(NOTIFY) $+ : $sc(%nick) ( $+ %addr $+ ) is on IRC $rbrk($notify(%nick).note)

      if (%a != $me) { 
        ncid notify.online $addtok($ncid(notify.online),%nick,44) 
        nset $+(notify.,%nick,.lastseen) $ctime $iifelse($notify(%nick).addr,%addr)
        ncid $+(notify.,%nick,.addr) $iifelse($notify(%nick).addr,%addr)
      }
    }

    inc %a
  }
  haltdef
}
raw 731:*:{
  ; RPL_MONOFFLINE http://ircv3.atheme.org/specification/monitor-3.2

  ;nicknames offline (might need this to fix 'contact refresh' code so it doesn't show offline nicknames.
  iecho -s 731 notifyoffline: $1-
  ; then again it might just be handled by UNOTIFY, so i might just need to haltdef
  ; ncid notify.notonline $addtok($ncid(notify.notonline),%b,44)
  ; ncid notify.online $remtok($ncid(notify.online),%b,1,44)
  haltdef
}

raw 732:*:{
  ; RPL_MONLIST https://github.com/atheme/charybdis/blob/master/doc/monitor.txt

  iecho RPL_MONLIST : $1-
  haltdef
}

raw SILENCE:*:{
  var %x = $cid $+ .ircN.services.silence 
  if (!$hget(%x)) hmake %x 20
  var %a =  $iif($istok(+ -, $left($1,1),32),$right($1,-1),$1)
  if ($left($1,1) == -) {
    hdel %x %a
    if (!$hget(%x,0).item) hfree %x
    iecho Removed hostmask $hc(%a) from silence list.
  }
  else {
    hadd %x %a $true
    iecho Added hostmask $hc(%a) to silence list.
  }
  halt
}

alias -l _process.rawcode5 {
  var %i, %z
  set %i 1
  while ($gettok($1-,%i,32)) {
    set %z $ifmatch
    if ($chr(61) isin %z) {
      ncid server_ $+ $gettok(%z,1,61) $gettok(%z,2,61)
      if ($gettok(%z,1,61) == cmds) {
        if ($istok($gettok(%z,2,61),dccallow,44)) ncid can_dccallow $true
      }
      if ($gettok(%z,1,61) == network) ncid network $gettok(%z,2,61)
      if ($gettok(%z,1,61) == modes) ncid modesonline $gettok(%z,2,61)
    }
    elseif ($caps(%z) == 100)  ncid server_SUPPORTED $addtok($ncid(server_SUPPORTED),%z,32)

    inc %i
  }
}

; ################################################################
; ####################### IRCN SCRIPT FILE #######################
; ########## END OF FILE. DO NOT REMOVE OR MODIFY BELOW ##########
; ################################################################
