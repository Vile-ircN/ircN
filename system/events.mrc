on *:START: _ircnevents_onstart

alias _ircnevents_onstart {


  if (!$hget(ircN)) { 
    hmake ircN $iif($lines($sd(ircn.ini)) > 16, $int($lines($sd(ircN.ini))), 32)

    if ($isfile($sd(ircN.ini))) hload -i ircN $sd(ircN.ini) ircN
    else newircnset

  }

  if (($nvar(splash)) && ($isalias(splash))) splash

  nvar reldate $readini($sd(release.ini),release,date)
  nvar lver ircN 9.00
  nvar ver 9.00


  if (!$hget(ctcpreplys)) {
    hmake ctcpreplys 16
    if ($isfile($sd(ctcpreplys.hsh)))   hload ctcpreplys $sd(ctcpreplys.hsh)
  }

  nvarinc uses

  .timertb -io 0 3 tb

  iecho -s Welcome to $nvar(lver) $+ !


  if ($nvar(transfer.pumpsend)) .pdcc on
  if ($nvar(transfer.passivedcc)) .dcc passive on

  if ($isfile($sd(sessions.txt))) { 
    if ($read($sd(sessions.txt),nw,1 *)) {
      if ((logging* iswm $status) || ($status == connecting))   .disconnect
      var %fk =  $_fkey.bind(.timerLoadSessions off $| iecho Canceled autoconnect!,15,F12) 
      ; fix this to use a variable
      .timer 1 5 iecho -s Press $hc(%fk) within the next $sc(15) seconds to cancel autoconnect.
      .timerLoadSessions 1 15 loadsessions
    }
  }

  _cache.netsupport

  $iif($nvar(fkey.f11) == fullscreen, .disable,.enable) ircN_F11Key

  if ($isfile($dd(hos.dll))) {
    dll $dd(hos.dll) SetIcon $window(-2).hwnd $shortfn($icondir(ircn.ico))
    dll -u hos.dll
  }

}


on *:signal:nloaded:{
  ;on connected to network
  ncid lastconnect $ctime
  ninc uses

  ;set your usermode
  ;global
  if ($nvar(umode)) mode $me $iif(!$isinchr($nvar(umode), +-), +) $+ $nvar(umode)
  ;ircd
  if ($nvar(umode.ircd. $+ $gettok($$curircd,1,32))) mode $me $iif(!$isinchr($nvar(umode.ircd. $+ $gettok($$curircd,1,32)),+-),+) $+ $nvar(umode.ircd. $+ $gettok($$curircd,1,32))
  ;network
  if ($nget(umode)) mode $me $iif(!$isinchr($nget(umode), +-), +) $+ $nget(umode)

  if ($nget(vhost.enabled) == on) {
    if (($nget(vhost.user)) && ($nget(vhost.pass))) {
      .vhost $nget(vhost.user) $nget(vhost.pass)
    }
  }

  if ($nget(ircop.enabled) == on) {
    if (($nget(ircop.user)) && ($nget(ircop.pass))) {
      .oper $nget(ircop.user) $nget(ircop.pass)

      if ($nvar(ircop.enableperform)) {
        if ($nvar(ircop.performwithoutsuccess)) {
          ;only calls this if they have 'dont wait for success'.. it will call it before the 'you are now an operator' raw
          .ntimer 1 1  ircop.perform
        }
      }
    }
  }

  if ($notifyonline == 0) _notify.noneonline

  _fkey.reset


  if (!$nget(uses.firstdate)) nset uses.firstdate $ctime

  if ($calc($ctime - $nget(networklistcache)) >= 432000) _mknetworklist
}

;; fix this.. not loading $ngets 

on *:ERROR:*:{
  if (* Local kill * iswm $1-) {
    if (($nget(reconnectonkill) != off) && (disconnect isin $status)) {
      if (($nvar(reconnectonkill) == on) || ($nget(reconnectonkill) == on)) {
        .ntimer reconnectkill -o 1 $iifelse($mopt(4,17),60) if (! $+ $!server ) server $server
        iecho Killed from server .. reconnecting in $duration($iifelse($mopt(4,17),60))
      }
    }
  }

}

on ^*:LOGON:*:{
  ;logging onto server
  if ($timer($ntimer(delayedconnect))) .ntimer delayedconnect off
}

on *:SNOTICE:*You are connected to * with *:{
  if (!$ssl) return
  var %r = You are connected to .* with (.*)
  if ($regex($1-,%r)) {
    ncid server_SSLINFO $regml(1)
  }
}

on *:DISCONNECT:{

  if ($ncid(lastconnect)) { nset lastconnect $ifmatch | ntmp -u20 lastconnect. $+ $cid $ifmatch }

  if ($nget(nloaded)) {
    ndel $cid nloaded
    nsave $cid
  }
  close -@ @Clones.*. $+ $cid

  nkill $cid

  .timer_ircnsave -o 1 1 ircnsave

}

on *:EXIT:{

  set %testcrash $true

}
on *:BAN:#:{
  if ($ischanset(kickonban,$chan)) {
    if ($me !isop $chan) return
    var %a = 1, %b = $ialchan($banmask,$chan,0), %x, %n
    while (%a <= %b) {
      set %x $ialchan($banmask,$chan,%a)
      set %n $ialchan($banmask,$chan,%a).nick
      if (($me == %n) && ($nick != $me)) .quote mode $chan -ob $nick $banmask $+ $crlf $+ kick $chan $nick : $+ $iifelse($nvar(string_kickonmeban),don't ban me)
      elseif (%n == $me) .quote mode $chan -b $banmask
      elseif (%n == $nick) .quote mode $chan -ob $nick $banmask $+ $crlf $+ kick $chan $nick :insanity check -- user attempted to ban self
      elseif (($ismod(userlist)) && ($chkflag($usr(%n),$chan,f))) noop
      elseif ($level(%x) != 20) {
        iecho -w $chan $hc(%n) has been banned from $brkt($chan) by $sc($nick) $+ , kicking...
        .quote kick $chan %n : $+ $iifelse($nvar(string_kickonban),banned)
      }
      inc %a
    }
  }
}
on *:input:@Whois.*:editbox -ap /whois 
on *:input:@Whois:editbox -ap /whois 
on *:MODE:#:{
  if ((k isincs $1) && ($chan($chan).key)) chanset $chan key $chan($chan).key

  if ($me isop $chan) {
    if ($changet($chan,holdmode) == on) {
      var %mode = $changet($chan,$tab(holdmode,mode))
      putserv mode $chan %mode
    }
  }

}

on *:TEXT:*:?:{
  if ($cwiget($nick,idle)) cwiset $nick idle 0
  ncid $tab(query,$nick,lastactive) $ctime

  if ($isqueryset(alertmsg,$nick)) {
    if ($isqueryset(alertsound,$nick)) {
      var %snd = $qt($iifelse($queryget($nick,alertsound.sound),$nvar(query.alertsound.sound)))
      if ($isfile(%snd)) .splay %snd
    }
    if ($isqueryset(alerttip,$nick)) {
      .echo -q $tip($+(query,~,$nick),Msg $nick,$shorttext(50,$strip($1-)))
    }
  }

}

on *:CHAT:*:{
  if ($cwiget($nick,idle)) cwiset $nick idle 0
  ncid $tab(dccchat,$nick,lastactive) $ctime

}

on *:TEXT:*:#:{
  if (($ial($nick)) && ($ialget($nick,idle))) cwiset $nick idle 0
}
on *:ACTION:*:*:{
  if ($ial($nick)) cwiset $nick idle 0
}
on *:OPEN:?:*:{
  if ($nget(user.sound.queryalert. $+ $nick))  {
    return
    var %w =  $ifmatch
    var %x, %y, %z
    set %x $gettok(%w,1,32)
    set %y $gettok(%w,2,32)
    set %z $gettok(%w,3-,32)
    if (%x == on) && (%y == new) {
      if ($isfile($qt(%z))) .splay $qt(%z)
    }
  }
  ncid $tab(query,$nick,lastactive) $ctime

}
on *:INVITE:*:{
  if ($nick == $iifelse($nget(services.chanserv.nickname),chanserv)) && ($ismod(services.mod)) && ($istok($nget(chanserv.chan.autoinvite),$chan,44)) return

  _fkey.enqueue join $hc($chan) $+ ~join $chan $+ ~F9
  if ($com.opchannels($nick)) _fkey.enqueue kickban $hc($nick) $+ ~ckb $nick %ckb $+ ~F12
  _fkey.assign 15

}
on *:QUIT:{
  var %a = 1, %c
  while ($gettok($com.channels($nick),%a,44) != $null) {
    set %c $ifmatch
    if ($ischanset(netsplit,%c)) {
      if (($3) || ($2 == $null) || ($1 == $2) || ($ isin $1-) || (. !isin $2) || (. !isin $1)) noop 
      elseif ($_ns.issplit($1,$2)) {
        _ns.nick $nick $addtok($1,$2,38)
        ntimer quitcheck 1 2 _doquitcheck
      }
      ; elseif ((irc*.* iswm $1) || (irc*.* iswm $2) || (*.com iswm $1) || (*.com iswm $2) || (*.net iswm $1) || (*.net iswm $2) || (*.edu iswm $1) || (*.edu iswm $2) || (*.org iswm $1) || (*.org iswm $2) || (*.hub iswm $1) || (*.hub iswm $2) || ($1-2 == *.net *.split)) {
      elseif (($isdomain($1).nohttp) && ($isdomain($2).nohttp) || ($1-2 == *.net *.split)) {
        ns.serv $1 $2
        _ns.nick $nick $addtok($1,$2,38)
        if ($nvar(show.netsplit) == window) { var %e = $cidwin(netsplit) | if (!$window(%e)) window -nRvkm %e }     
        iecho -w $iifelse(%e,%c) $iif((!$isserver($1) || !$isserver($2)),Possible) Netsplit detected at $hc($atime) between $hc($u($1)) and $hc($u($2)) press $hc(sF10) to see who split, press $hc(F11) to join split server

        .signal netsplit $1 $2
        ;      nset fkey.sf10 wholeft
        ;      nset fkey.f11 server -m $2 

        ntimer netsplit.clean 0 240 _clnsplit
        ntimer quitcheck 1 2 _doquitcheck
      }
    }

    inc %a
  }
  /*

  if ($ischanset(netsplit) == on) {
    if (($3) || ($2 == $null) || ($1 == $2) || (  isin $1-) || ($ isin $1-) || (. !isin $2) || (. !isin $1)) return
    elseif ($_ns.issplit($1,$2)) {
      _ns.nick $nick $addtok($1,$2,38)
      ntimer quitcheck 1 2 _doquitcheck
    }
    elseif ((irc*.* iswm $1) || (irc*.* iswm $2) || (*.com iswm $1) || (*.com iswm $2) || (*.net iswm $1) || (*.net iswm $2) || (*.edu iswm $1) || (*.edu iswm $2) || (*.Org iswm $1) || (*.Org iswm $2) || (*.hub iswm $1) || (*.hub iswm $2) || ($1-2 == *.net *.split)) {

      _ns.serv $1 $2
      _ns.nick $nick $addtok($1,$2,38)

      iecho $iif((!$isserver($1) || !$isserver($2)),Possible) Netsplit detected at $hc($atime) between $hc($u($1)) and $hc($u($2)) press $hc(sF10) to see who split, press $hc(F11) to join split server
      .signal netsplit $1 $2

      nset fkey.sf10 wholeft
      nset fkey.f11 server -m $2 

      ntimer netsplit.clean 0 240 _clnsplit
      ntimer quitcheck 1 2 _doquitcheck
    }
  }
  */

  if ($hget($cid $+ .ircN.cachewhois,$nick)) {
    hdel $cid $+ .ircN.cachewhois $nick
    if (!$hget($cid $+ .ircN.cachewhois,0).item) hfree $cid $+ .ircN.cachewhois   
  }

  ; if ($notify($ialget($nick,lastnick))) nset $+(notify.,$ialget($nick,lastnick),.lastseen) $ctime $site

}
on *:JOIN:#:{
  if ($nick == $me) {

    if ($istok($nvar(hidechans),$chan,44)) { 
      window -w0 $chan 
      if (!$nvar(hidechans.dontnotify))   iecho -s Channel $hc($chan) hidden from switchbar.
    }

    chanset $chan lastjoin $ctime
    ncid $tab(chan, $chan, jointime) $ctime
    if ($istok($ncid(cyclechannels),$chan,44)) ncid cyclechannels $remtok($ncid(cyclechannels),$chan,1,44)
    else {
      if ($nvar(showloginchan)) {
        var %f = $qt($chan($chan).logfile)
        if (($isfile(%f)) && ($lines(%f) > 4)) {
          echo -gi2 $chan ------------------------ old log ------------------------
          loadbuf 50 -pi $chan %f
          echo -gi2 $chan ---------------------------------------------------------
        }
      }
    }
    if ($isfile($sd(onjoin-perform.ini))) {


    }


  }

  else {
    if (($me isop $chan) || ($me ishop $chan)) {
      if ($ischanset(voiceall,$chan)) putserv mode $chan +v $nick
    }
    ; remove nick from netsplit lists if they rejoin
    if ($_ns.issplit($nick)) {
      hdel -w $_nnetsplit wholeft* $+ $nick
      _clnsplit
    }
  }
}
on *:PART:#:{
  if ($ischanset(autocycle,$chan)) .timer 1 0 _doquitcheck.chan $chan
  if ($nick == $me) {
    ncid -r $tab(chan,$chan,*) 
    ncid -r $tab(ircops,$chan,*) 
    ncid -r joinsync. $+ $chan
    ncid -r $tab(chan,$chan,lsnick)
  }

}
on *:KICK:#:{
  if ($chan !ischan) { return }
  if ($ischanset(autocycle,$chan)) .timer 1 0 _doquitcheck.chan $chan
  if ($nick == $me) {
    nvarinc kickcount
    ninc $tab(chan, global, kickcount)
    ninc $tab(chan, $chan, kickcount)
  }
}
on *:NOTIFY:{

  if (!$notifyaddr($nick)) { .quote userhost $nick |  ntimer refreshnotify.lastseen 1 15 _refresh.notify.lastseen  }
  else { ncid notify.online $addtok($ncid(notify.online),$nick,44) | nset notify. $+ $nick $+ .lastseen $ctime $notifyaddr($nick) |  _refresh.notify.lastseen   }
}
on *:UNOTIFY:{
  var %a = 1, %b

  ncid notify.online $remtok($ncid(notify.online),$nick,1,44)
  nset $+(notify.,$nick,.lastseen) $ctime $notifyaddr($nick)
  _refresh.notify.lastseen
}
on *:OPEN:=:{
  _recentdccchat $nick
}
;on *:BAN:#:{
;  if (($me isop $chan) && ($nick != $me) && ($bhosth($banmask) == $null)) {
; iecho -w $chan $hc(BAN) [ $+ $chan $+ ]: $rbrk($banmask) placed by $hc($nick) $+ .
;    _fkey.enqueue remove ban~mode $chan -b $banmask $+ ~F11~-w $chan
;    _fkey.assign 15
;  }
;}
menu @Whois,@Whois.* {
  $iif(($nget(recentwhois) && $connected),&Whois)
  .$submenu($_popup.recentwhois($1))
  $iif(($nget(recentwhois) && $connected),&Idle Whois)
  .$submenu($_popup.recentwhois($1,wii))
  $iif(($nget(recentwhois) && $connected),W&howas)
  .$submenu($_popup.recentwhois($1,whowas))
  -
}

menu @RawLog.* {
  $style(2) - RawLog Settings -  :!
  $toggled($nvar(rawlog.timestamp)) Timestamp :nvartog rawlog.timestamp
  -
}
menu @*.filter {
  Reset:filt $remove($gettok($active,1,46),@) *
}
menu @channellist.* {
  dclick:if ($1 != 1)   join -n $gettok($line($active,$$1),1,9)
}
menu @channellist.* {
  $iif($1,Join Channel):if ($1 != 1) join -n $gettok($1,1,9)
  $iif($1,Show Users):if ($1 != 1) names $gettok($1,1,9)
  -
  Filter:chanlist $$input(What would you like to filter the channel list with $+ $chr(58),e,Channel List,*)
  Refresh:chanlist *
}

on *:signal:ctcp:_ctcp.reply $1-
alias -l _ctcp.reply {
  var %nick = $gettok($3,1,33), %address = $gettok($3,2,33), %fulladdress = $3
  var %target = $2, %cid = $1, %ctcp = $4, %text = $5-
  if (%target ischan) var %chan = $2

  if (%ctcp $gettok(%text,1,32) == DCC SEND) {
    var %z = $sreq
    if (($dccrelay) && ($_dccrelay.nick)) {
      var %dccnick = $gettok($_dccrelay.nick,1,44)
      var %dccnet = $gettok($_dccrelay.nick,2,44)
      if ($network != %dccnet) {
        scid $net2scid(%dccnet)
      }
      qctcp %dccnick %ctcp %text
      .timer 1 0 .sreq %z
      .sreq ignore
      scid -r
      if ($status != Connected) {
        iecho Forwarding $hc(SEND) request from $u($hc(%nick)) $rbrk(%address) $ab($sc($addtok($longip($gettok(%text,3,32)),$gettok(%text,4,32),58))) of $hc($gettok(%text,2,32)) $rbrk($alof($gettok(%text,5,32))) to $hc(%dccnick) on $ac(%dccnet) FAILED! $hc(NOT CONNECTED)
        halt
      }
      else iecho Forwarding $hc(SEND) request from $u($hc(%nick)) $rbrk(%address) $ab($sc($addtok($longip($gettok(%text,3,32)),$gettok(%text,4,32),58))) of $hc($gettok(%text,2,32)) $rbrk($alof($gettok(%text,5,32))) to $hc(%dccnick) on $ac(%dccnet) $+ .
      halt
    }
  }

  if (%nick != $me) {
    if ($nget) {
      nset lastnick %nick
      nset ctcprec [ $+ %nick $+ ( $+ %address $+ ) $+ %chan $+ ] VERSION
    }
  }
  if ($iscloaked(%fulladdress,%ctcp)) return

  var %a = $hget(ctcpreplys,$+(%ctcp,.style))
  if (%a) {
    if (%a == random) .ctcpreply %nick $upper(%ctcp) [ [ $hget(ctcpreplys,$hfind(ctcpreplys,$+(%ctcp,.ctcpreply.*),$rand(1,$hfind(ctcpreplys,$+(%ctcp,.ctcpreply.*),0,w)),w)) ] ]
    elseif (%a == custom) .ctcpreply %nick $upper(%ctcp) [ [ $hget(ctcpreplys,$+(%ctcp,.defreply)) ] ] 
  }
  elseif (%ctcp == VERSION) .ctcpreply %nick VERSION ircN $nvar(ver) ( $+ $nvar(reldate) $+ )
  elseif (%ctcp == PING) .ctcpreply %nick $upper(%ctcp) %text
  elseif (%ctcp == TIME) .ctcpreply %nick $upper(%ctcp) $asctime(ddd mmm HH:nn:ss yyyy)
  elseif (%ctcp == FINGER) .ctcpreply %nick $upper(%ctcp) $readini($mircini,n,mirc,user) ( $+ $email $+ ) Idle $idle seconds
}
on *:NICK:{
  if ($ial($newnick)) cwiset $newnick lastnick $nick
}
on *:ACTIVE:*:{
  tb

  if (@userlabel.* iswm $lactive) && (@userlabel.* !iswm $active) {
    window -c $lactive
  }

  if ($nvar(tinyswitchbar) == on) {
    tinysb
    .hidechans
  }
  if ($nvar(hidenetwin) == on) hidenetwin
}

on *:SNOTICE:*:{ 
  if ($ncid(authreqcheck))  auth.identify.check $nick $1-
  if (($ncid(parse.links)) && (*links*disable* isin $1-)) {
    iecho -s unable to create list of servers
    nset updatelinks off
    ncid -r parse.links
    halt
  }
}
on *:CONNECT:{
  ntimer online 0 60 _online 

  if (!$ncid(network)) netchk
  else nload

  _online

  ncid -u60 authreqcheck 1

  if ($curnet(noserver))  _recentnetwork $ifmatch

  _recentserver $server $port $curnet(noserver)

  ; global or n 
  if ($isalias(elog)) elog -g connect $ctime $server $port $network $me

} 
on *:DISCONNECT:{
  if ($isalais(elog))  elog -g disconnect $ctime $online $server $port $network $me
}
on *:OP:#:{
  if ($opnick == $me) {
    if (!$chan($chan).ibl) {
      if ($nvar(iblupd) != never) { 
        if ((($nvar(iblupd) == op) || (!$nvar(iblupd))) && ((!$istok($ncid(updibl),$chan,44)))) {
          ncid updibl $addtok($ncid(updibl),$chan,44)
          .quote mode $chan b
        }
      }
    }
  }
}
on *:SERVERMODE:#:{
  if ($ischanset(netsplit,$chan)) {
    if ($_ns.issplit($nick)) {
      var %h = $_nnetsplit
      var %t = $gettok($hget(%h,split $+ $chr(1) $+ * $+ $nick),2,32)
      .timerNetsplitRejoin 1 1 iecho Netsplit rejoin detected on $hc($nick) at $hc($atime) since $iif(%t,$hc($duration($calc($ctime - %t)) ago)) $+ .
      .signal netsplitrejoin $nick
      hdel -w %h split $+ $chr(1) $+ * $+ $nick $+ *
      hdel -w %h wholeft $+ $chr(1) $+ * $+ $nick $+ * $+ $chr(1) $+ *
      if (!$hget(%h,0).item) { hfree %h | ntimer netsplit.clean off }
    }
  }
}

on *:SERVEROP:#:{
  if ($ischanset(netsplit,$chan)) {
    if ($_ns.issplit($nick)) {
      .timerNetsplitRejoin 1 1 iecho Netsplit rejoin detected on $hc($nick) at $hc($atime) $+ .
      .signal netsplitrejoin $nick
      hdel -w $_nnetsplit split $+ $chr(1) $+ $nick $+ &* 
      hdel -w $_nnetsplit wholeft $+ $chr(1) $+ * $+ $chr(1) $+ $nick 
    }
  }
}

on *:DNS:{
  if (($istok($ncid(dnshalt),$iaddress,44)) || ($istok($ncid(dnshalt),$naddress,44))) {
    if ($istok($ncid(dnshalt),$iaddress,44)) { halt | ncid dnshalt $remtok($ncid(dnshalt),$iaddress,1,44) }
    if ($istok($ncid(dnshalt),$naddress,44)) { halt | ncid dnshalt $remtok($ncid(dnshalt),$naddress,1,44) }
  }
  else {
    if ($istok($ncid(nickfind.dns),$iaddress,44)) {
      if ($remove($naddress,.))  nickfind $naddress
      else  nickfind $iaddress 1
      ncid nickfind.dns $remtok($ncid(nickfind.dns),$iaddress,1,44)
      halt
    }
  }
  var %n = $iifelse($nick,$ial(*!*@ $+ $naddress).nick)
  var %r = $naddress
  var %i = $iaddress
  if ((!$cwiget(%n,cdns)) && ($isip(%i)))  cwiset %n cdns %i
  if (($nvar(ipondns) == on) && (%i)) clipboard %i
}
on *:TOPIC:#:{
  if ($nget($tab(chan,$chan,holdtopic)) == on) {
    if (($me !isop $chan) &&  ($me !ishop $chan) && (t isin $chan($chan).mode)) return
    if ($nick != $me) {
      if ($nget($tab(chan,$chan,holdtopic,topic))) {
        topic $chan $nget($tab(chan,$chan,holdtopic,topic))
        qnotice $nick Topic for $chan is HELD
      }
    }
    else nset $tab(chan,$chan,holdtopic,topic) $chan($chan).topic
  }
}

menu menubar,status,channel,query {
  $iif(($istok(status menubar,$menutype,32) && $connected),&Contacts)
  .Notify List:notify
  .Notify List $paren(global):notify -s
  .Add Contact:notify -n $$input(Enter nickname,e,Add Notify) $curnet
  .Edit Contacts:abook -n
  .-
  .View Notes:notes
  .Ignore List:abook -c
  .-
  .$iif($_notifypopup.online, $tab - Online $paren($_notifypopup.online) - ) {
    nvartog collapse.ircN.status/contacts/showonline
    iecho $iif($nvar(collapse.ircN.status/contacts/showonline), Collapsed, Expanded) $firstcap($menutype) -> Contacts -> Online
  }
  .$submenu($_popup.notify($1))
  .- 
  .$iif($ncid(notify.notonline), $tab - Offline $paren($numtok($ncid(notify.notonline),44)) - ) {
    nvartog collapse.ircN.status/contacts/showoffline
    iecho $iif($nvar(collapse.ircN.status/contacts/showoffline), Collapsed, Expanded) $firstcap($menutype) -> Contacts -> Offline
  }
  ..$submenu($_popup.notify.lastseen($1))
  .-
  .$iif($ismod(userlist.mod),$style(2) $tab - Settings - ):!
  .$iif($ismod(userlist.mod),$toggled($nvar(contacts.userlistmenuonly)) Show userlist matches only) : nvartog contacts.userlistmenuonly
  $iif(($istok(status menubar,$menutype,32) && $totalconnected),&Sessions)
  .$style(2) $tab - Current Session -:!
  .$iif(!$connected,* Not connected):!
  .$iif($connected,Quit)
  ..Custom:quit $$input(Enter quit message,e) 
  ..Random:quit
  ..Fake
  ...Ping timeout:.quote quit :Ping timeout
  ...Connection reset by peer:.quote quit :Connection reset by peer
  ...Broken pipe:.quote quit :Broken pipe
  ..-
  ..$submenu($_popup.quitmsgs($1))
  .$iif($connected,Away):away $$input(Enter away message,e)
  .$iif($scon(0) > 1,$style(2) $tab - Global Sessions $paren($scon(0)) -):!
  .$iif($scon(0) > 1,Quit)
  ..Custom:gquit $$input(Enter quit message,e) 
  ..Random:gquit
  ..Fake
  ...Ping timeout:gquit Ping timeout
  ...Connection reset by peer:gquit Connection reset by peer
  ...Broken pipe:gquit Broken pipe
  ..-
  ..$submenu($_popup.quitmsgs($1,global))
  .$iif($scon(0) > 1,Away):gaway $$input(Enter away message,e)
  .Custom Cmd:scid -a $$input(Enter custom command to send to all sessions,e,Global command)

  &Windows
  .$iif($window($active).type == status,Logging)
  ..$style(2) $tab - $triml($active,=) - :return
  ..$iif($window($active).logfile, $style(1)) On:log on
  ..$iif(!$window($active).logfile, $style(1)) Off:log off
  ..-
  ..$iif(($window($active).logfile || ($ismod(logviewer.mod) && $active == status window)),$style(2) $tab - Logs -):!
  ..$iif($window($active).logfile, View Log $cmdtip(logview)):logview $window($active).logfile
  ..$iif((!$window($active).logfile && $ismod(logviewer.mod) && $active == status window), View Logs):logview  
  ..$iif(($istok(channel query,$menutype,32)) && ($ismod(logviewer.mod)) && ($isfile($window($active).logfile)),Search Log $cmdtip(slog)) { var %q = $$input(Enter your search string. Wildcards are allowed,e, Search $menutype log $iif($menutype == query,with,in) $active) | slog $qt(%q) }
  ..$iif($window($active).logfile, Delete Log):{ var %a = $$input(Are you sure you want to remove ' $+ $nopath($window($active).logfile) $+ ' ?,y) | if (%a) { .iecho remove -b $qt($window($active).logfile)  }  } 
  .-
  .Clear Active:clear
  .Close Active {
    var %q = $window($active).type
    if ($istok(query chat,%q,32)) { close $iif($window($active).type == chat,-c,-m) $active }
    elseif (%q == channel) part $active
    elseif (%q == status) { 
      if ($scon(0) == 1) iecho You must have at least one status window open.
      else window -c "Status window"
    }
  }
  .Close Session $tab $paren($curnet):iecho close this window
  .-
  .Clear All
  ..$style(2) $tab - Current Session -:!
  ..Clear All $tab $paren($sum($chan(0),$query(0),$chat(0),$window(@*. $+ $cid,0),1),[,]):clearall
  ..-
  ..Status $tab [1]:clearall -s
  ..$iif($chan(0),Channels $tab $paren($chan(0),[,])):clearall -n
  ..$iif($query(0),Queries $tab $paren($query(0),[,])):clearall -q 
  ..$iif($chat(0),Chats $paren($chat(0),[,])):clearall -t
  ..$iif($window(@*. $+ $cid,0),@Windows $tab $paren($window(@*. $+ $cid,0),[,])):clearall -u
  ..$style(2) $tab - Global Sessions -:!
  ..Clear All $tab $paren($sum($totalchans,$totalquery,$chat(0),$scon(0),$window(@*,0)),[,]):scid -a clearall
  ..-
  ..Status $tab $paren($scon(0),[,]):clearall -sa
  ..$iif($totalchans,Channels $tab $paren($totalchans,[,])):clearall -na
  ..$iif($totalquery(0),Queries $tab $paren($totalquery,[,]))):clearall -qa
  ..$iif($totalchats,Chats $tab $paren($totalchats,[,])):clearall -ta
  ..$iif($window(@*,0),@Windows $tab $paren($window(@*,0),[,])):clearall -ua
  .Close All
  ..$style(2) $tab - Current Session -:!
  ..$iif($chan(0),Channels $tab $paren($chan(0),[,])):partall
  ..$iif($query(0),Queries $tab $paren($query(0),[,])) { var %a = $query(0)  | close -m | iecho Closed $hc(%a) query windows. } 
  ..$iif($window(@*. $+ $cid,0),@Windows $tab $paren($window(@*. $+ $cid,0),[,])):close -@ @*. $+ $cid
  ;can close dcc chat be network unspecific? 
  ..$style(2) $tab - Global Sessions - :!
  ..$iif($totalchans,Channels $tab $paren($totalchans,[,])):scid -a partall
  ..$iif($totalquery(0),Queries $tab $paren($totalquery,[,]))):scid -a close -m
  ..$iif($get.complete,DCC Gets $tab $paren($get.complete,[,])) { close -ig }
  ..$iif($send(0),DCC Sends $tab $paren($send(0),[,])) { close -is }
  ..$iif($totalchats,DCC Chats $tab $paren($totalchats,[,])):scid -a close -c
  ..$iif($window(@*,0),@Windows $tab $paren($window(@*,0),[,])):close -@ @*
  ..$iif($scon(0) > 1,Sessions $tab $paren($sub($scon(0),1),[,])):$iif($$input(Are you sure you want to exit all sessions other than the main session?,y, Close $sub($scon(0),1) IRC Sessions ),close -t)
  .-
  .$style(2) $tab - Arrange - :!
  .Tile:{ scon -a minall custom status  | mdi -t }
  .Cascade:mdi -c
  .Inflate:_inflatewin
  .Maximize:window -x $iif($numtok($active,32) > 1,$qt($active),$active)
  .$iif($fullscreen,$style(1)) Fullscreen:$iif($fullscreen,showmirc -r,fullscreen)
  .-
  .$style(2) $tab - Display - :!
  .Change Font $tab $paren($shorttext(10,$window($active).font)) : font
}
menu @snotice.*,@highlight.*,@ndebug.*,@whois*,@RawLog.* {
  &Clear:clear
  &Save Buffer:savebuf $active $$sfile($mircdir,Where would you like to save $active)
  -
  C&lose:close -@ $active
  &Auto Log
  .Enabled:!
  .Disabled:!

}
;on $^*:HOTLINK:$($hotlink.match.ipaddr):*:iecho ip $1

alias -l hotlink.match.ipaddr return /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(\:\d+)?/
#ircN_Hotlinking on
on ^*:HOTLINK:*:*:{
  if (* $+ $hc $+ ** iswm $gettok($hotline,$hotlinepos,32)) {
    var %hsh = $hash($strip($gettok($hotline,2-,32)),32)
    if ($1 == $ncid(linktext. $+ %hsh $+ .linkword)) return
    elseif (* $+ $hc $+  $+ $ncid(linktext. $+ %hsh $+ .linkword) $+ * iswm $gettok($hotline,$hotlinepos,32)) return
  }
  elseif ((irc*.*.* iswm $1)) return

  ; ip address recognizing
  elseif (*.*.*.* iswm $1) {
    var %a = $stripnonnum($_gettok($replace($1,$chr(160),$chr(32)),1,32,1,58))
    if (*@* iswm %a) set %a $gettok(%a,2-,64)
    if ($isip(%a)) return
  }
  halt
}
on *:HOTLINK:*:*:{


  if (* $+ $hc $+ ** iswm $gettok($hotline,$hotlinepos,32)) {
    var %hsh = $hash($strip($gettok($hotline,2-,32)),32)

    if ($1 == $ncid(linktext. $+ %hsh $+ .linkword)) {
      .timer 1 0 $ncid(linktext. $+ %hsh $+ .linkcmd)
    }
    elseif (* $+ $hc $+  $+ $ncid(linktext. $+ %hsh $+ .linkword) $+ * iswm $gettok($hotline,$hotlinepos,32)) {
      .timer 1 0 $ncid(linktext. $+ %hsh $+ .linkcmd)
    }
  }
  elseif (*irc*.*.* iswm $1) {
    var %a = $gettok($1,1,58)
    set %a $trimall($1,.,$chr(44),!,_)
    dlg ircn.newserv
    did -o ircn.newserv 2 0 %a
    did -o ircn.newserv 22 0 $iif($gettok($1,2,58),$ifmatch,6667)
    did -e ircn.newserv 22
    _ircn.newserv.loadports %a
  }


  ; ip address double clicking for dns
  elseif (*.*.*.* iswm $1) {

    var %a = $remove($_gettok($replace($1,$chr(160),$chr(32)),1,32,1,58),$chr(40),$chr(41),[,])
    if (*@* iswm %a) set %a $gettok(%a,2-,64)
    if (!$isip(%a)) return
    dns %a

  }
}
#ircN_Hotlinking end

; Fkey remapping
alias F1 _fkey.do f1
alias F2 _fkey.do f2
alias F3 _fkey.do f3
alias F4 _fkey.do f4
alias F5 _fkey.do f5
alias F6 _fkey.do f6
alias F7 _fkey.do f7
alias F8 _fkey.do f8
alias F9 _fkey.do f9
alias F10 _fkey.do f10
#ircN_F11key off
alias F11 _fkey.do f11
#ircN_F11key end
alias F12 _fkey.do f12
alias sF1 _fkey.do sf1
alias sF2 _fkey.do sf2
alias sF3 _fkey.do sf3
alias sF4 _fkey.do sf4
alias sF5 _fkey.do sf5
alias sF6 _fkey.do sf6
alias sF7 _fkey.do sf7
alias sF8 _fkey.do sf8
alias sF9 _fkey.do sf9
alias sF10 _fkey.do sf10
alias sF11 _fkey.do sf11
alias sF12 _fkey.do sf12
alias cF1 _fkey.do cf1
alias cF2 _fkey.do cf2
alias cF3 _fkey.do cf3
alias cF5 _fkey.do cf5
alias cF7 _fkey.do cf7
alias cF8 _fkey.do cf8
alias cF9 _fkey.do cf9
alias cF10 _fkey.do cf10
alias cF11 _fkey.do cf11
alias cF12 _fkey.do cf12


on *:SIGNAL:ircN_hook_cmd_query:{
  _recentquery %::nick
}

;save all setting files on dialog closes
on *:dialog:ircN.*:close:0:.timersaveset 1 5 ircnsave
on *:dialog:ircNsetup.*:close:0: .timersaveset 1 5 ircnsave 

; ################################################################
; ####################### IRCN SCRIPT FILE #######################
; ########## END OF FILE. DO NOT REMOVE OR MODIFY BELOW ##########
; ################################################################
