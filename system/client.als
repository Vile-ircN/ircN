
clbans {
  ;/clbans [#chan]
  var %c = $1
  if ($me !ison %c) set %c #
  if (!%c) { 
    if ($show) theme.syntax /clbans requires a channel!
    return 
  }

  if (($me isop %c) || ($me ishop %c)) {
    var %a = 0, %b
    while ($ibl(%c,0) > %a) {
      inc %a
      %b = %b $ibl(%c,%a)
    }
    mode %c - $+ $str(b,%a) %b
  }
  else if ($show)  _doraw.fake 482 $server %c $me %c
}
enbans {
  var %chan = $iif($1 ischan,$1,#)
  if (!%chan) return

  var %ib = 1, %ia
  var %ban, %addr, %nick, %setby
  while ($ibl(%chan,%ib) != $null) {
    set %ban $ibl(%chan,%ib)
    set %setby $gettok($ibl(%chan,%ib).by,1,33)

    set %ia 1

    while ($ialchan(%ban,%chan,%ia) != $null) {
      set %addr $ialchan(%ban,%chan,%ia)
      set %nick $ialchan(%ban,%chan,%ia).nick
      if (%nick != $me) {
        if ($ismod(userlist)) {
          if ($chkflag($usr(%nick),%chan,f)) { inc %ia | continue }
        }
        iecho kick %chan %nick Banned by %setby $paren(%ban)
      }
      inc %ia
    }

    inc %ib
  }

}


toggleumode {
  if (!$server) return
  if ($1 isincs $usermode) mode $me - $+ $1
  else mode $me + $+ $1
}
togglecmode {
  if (!$server) return
  if ($1 !ischan) return
  if ($2 isincs $gettok($chan($1).mode,1,32))  mode #$1 - $+ $2-
  else mode #$1 + $+ $2-
}
quit {
  var %a 
  if ($1 != $null) set %a $1-
  elseif ($isfile($sd(quits.txt))) set %a $read($sd(quits.txt))
  else set %a $readini($mircini,text,quit) 
  ntmp -u20 lastquitreason. $+ $cid %a
  .quote quit : $+ %a
}

minall {
  ;/minall custom status channel - minimizes all custom windows, status windows, channel windows
  ;/minall * <- minimizes all windows
  ;/minall -x "#chan,Vile" * <- minimizes all windows except for #chan and query from Vile
  ;
  var %t = $flags($1-,_).text
  var %flg_x
  if ($flags($1-,x)) set %flg_x $flags($1-,x).val

  tokenize 32 %t

  var %a = 1, %b
  while ($window(*,%a) != $null) { 
    set %b $ifmatch
    if ($numtok(%b,32) > 1) set %b $qt(%b)
    var %q = 1
    if ($1) && ($1 != *) && (!$istok($1-,$window(*,%a).type,32)) set %q 0
    if (%q) {
      if ($istok(%flg_x,$remove(%b,"),44)) { inc %a | continue }
      window -n %b 
    }
    inc %a
  } 

} 
hideall {

  var %a = 1, %b
  while ($window(*,%a) != $null) { 
    set %b $ifmatch
    var %q = 1
    if ($1) && ($window(%b).type != $1) set %q 0
    if (%q)  window -h %b
    inc %a
  } 

} 

ml {
  var %echo = $iif($show, iecho)
  if ($1 != -force) {
    if ($calc($ctime - $nget(links)) < 300) {
      %echo Ignored $hc(/ml) $+ . Wait 5 minutes and try again.
      return
    }
  }

  window -khs @_servermap. $+ $cid
  clear @_servermap. $+ $cid
  write -c $srvfile 
  write -c $srvmapfile

  nset links $ctime
  ncid -u30 parse.links $true $show
  !links -n
  if ($window(Links List).state == normal) window -h "Links List"
} 
addsrv {

  var %prune = 0, %f
  if ($1 == prune) { set %f $2- | set %prune 1 }
  if ($isfile($1-)) { var %f = $1- }

  if (!$isfile(%f)) {
    var %a = $input(Can I download the latest servers.ini file from mirc.com ?,y,Download servers list)
    if (%a) {
      if ($isfile($tp(servers.ini))) .remove $tp(servers.ini)
      var %uhttp = $iif(!$ismod(http),1)
      if (%uhttp) .module http
      .timer 1 1 http -hc http://mirc.co.uk/servers.ini $tp(servers.ini) _addsrv.httpdone %prune %uhttp
      return
    }

    set %f $qt($$sfile($qt($td(servers.ini)),Where is your servers.ini file))
    if (%f == $sys(servers.ini)) { iecho you cant use the same servers.ini in your system folder already | return  }
  }

  if (!$isfile(%f)) return

  if ($hget(servers.ini)) hfree servers.ini
  hmake servers.ini 256
  hload -i servers.ini $qt(%f) servers


  var %a = 1, %b = $hget(servers.ini,0).item, %added, %updated
  while (%a <= %b) {
    var %c = $hget(servers.ini,$hget(servers.ini,%a).item) 
    var %srv = $split(SERVER:,:,%c)
    var %port = $removecs($gettok(%c,3,58),GROUP)
    var %grp = $split(GROUP:,:,%c)
    var %q = $regex(%c,(.*)SERVER:.*)
    if (%q) var %desc = $regml(1)

    if (!$server(%srv)) {
      server -a %srv -p %port $iif(%grp,-g %grp)
      if (%desc) .server -a %srv -p %port $iif(%grp,-g %grp) -d %desc 

      inc %added
    }
    elseif (($server(%srv).port != %port) || ($server(%srv).group !=== %grp)) {  
      server -a %srv %port $iif($server(%srv).group !=== %grp, -g %grp )
      inc %updated
    }

    inc %a 
  }
  if ($readini(%f,timestamp,date) != $readini(servers.ini,timestamp,date))  writeini servers.ini timestamp date $v1
  ;read the new server.ini datetimestamp and writeini it to your current one
  if ($show)  {
    if  (%added) iecho Added $hc($u(%added)) new servers to your server list.
    if ($1 != prune) && (!%added) iecho No updates to your server list are necessary.
  }
  if (%prune) {
    ; prune
    server -s
    if (!$show) set %serverprune.silent $true
    window -hkl @ircn.pruneserverlist
    clear @ircn.pruneserverlist
    var %a = 1, %b, %c, %n = $server(0) , %m 
    while (%a <= %n) {
      set %b $server(%a)
      set %c $hfind(servers.ini,*SERVER: $+ %b $+ :*,1,w).data
      if (!%c) {
        if (!%m) {
          if (!$read($sd(pruneservers_exclude.dat),nw,%b))     inc %m
        }
        aline @ircn.pruneserverlist %b $server(%b).port $server(%b).group 

      }
      inc %a
    }
    if (%m)  dlg -h ircn.pruneserverlist
    elseif (!%added) {
      iecho No updates to your server list are necessary.
      window -c  @ircn.pruneserverlist
      unset %serverprune.*
    }
  }
  if ($hget(servers.ini)) hfree servers.ini

  scid -a _mknetworklist
}
addlinks {

  ;add new links to serverlist from srv file

  var %echo = $iif($show,iecho $iif($1 == -quiet, -s) )


  if (!$curnet(noserver)) {
    if ($1 != -quiet)  %echo Adding new servers failed.  Cannot determine what network you are on. 
    return 
  }

  var %a = 1, %f = $srvfile
  var %c = 0
  if (!$lines(%f)) {
    if ($1 != -quiet)  %echo Cannot add new links because your server list is empty, make a new list with $hc(/ml) $+ . If this doesn't work, your server may have /links disabled. 
    return 
  }

  while ($read(%f, n, %a)  != $null) {
    var %srv = $ifmatch
    if (!$server(%srv)) {
      if (($right(%srv,1) == .) || (services.* iswm %srv) || ($left(%srv,4) == hub.) || ($right(%srv,4) == .hub)) { inc %a | continue }

      if (($1 == -quiet) || (!$show)) var %silent = $true
      $iif(%silent,.) $+  server -a %srv -g $curnet
      inc %c
    }
    inc %a
  }

  if (!%c) {
    if ($1 != -quiet)  %echo No new servers to add to $sc($curnet) $+ .
  }
  else {
    if ($1 != -quiet)  %echo Added $hc(%c) new server $+ $plural(%c) to $sc($curnet) $+ .
    _mknetworklist
  }

}
autoconnect {
  if ($ismod(modernui)) { 
    if ($istok(%ircnsetup.docked,ircn.autoconnect.modern,44)) return

    dlg -rc ircn.autoconnect.modern
    dialog -rsb ircn.autoconnect.modern -1 -1 185 150

  }
  elseif ($ismod(classicui)) dlg -r ircn.autoconnect
  else {
    var %a = $sd(sessions.txt)
    run notepad.exe %a
  }
}
autocon autoconnect  
deadlinks {

  ;remove dead links from mirc server list based on /ll


  var %echo = $iif($show,iecho $iif($1 == -quiet, -s) )

  if (!$curnet(noserver)) {
    if ($1 != -quiet) %echo Removing of dead servers failed. Cannot determine which network you are on. 
    return
  }

  var %a = 1, %f = $srvfile
  var %c = 0


  if (!$lines(%f)) {
    if ($1 != -quiet)   %echo Cannot remove dead links because your server list is empty, make a new list with $hc(/ml) $+ . If this doesn't work your server may have /links disabled. 
    return
  }

  while ($server(%a)  != $null) {
    var %srv = $ifmatch
    if (($right(%srv,1) == .) || ($right(%srv,1) == .hub)) { inc %a | continue }
    if (($server(%a).group != $network) || ($server == %srv) || (Random*server iswm $server(%a).desc)) { inc %a | continue } 


    if (!$read(%f,nw, %srv)) {
      if (($1 == -quiet) || (!$show)) var %silent = $true
      ! $+ $iif(%silent,.) $+ server -r %srv -g $curnet
      inc %c
    }


    inc %a
  }

  if (!%c) { 
    if ($1 != -quiet)  %echo  No dead servers to remove from $sc($curnet) $+ .  
  }
  else {
    if ($1 != -quiet) %echo Removed $hc(%c) dead or disconnected server  $+ $plural(%c) from $sc($curnet) $+ .
    _mknetworklist
  }
}
netmap {



}
netusage {
  say I've connected to $upper($curnet) $networkuses $+ . I've been online for $trimdur($online,$iif($online > 3600,s)) $+ . I've wasted a total of $duration($calc($nget(pong) * 60)) on $upper($curnet) $+ .
}
netinfo {
  if (!$server) {
    iecho You must be connected to a server.
    return
  }
  iecho $str(-,35)
  iecho You have connected to $u $+ $hc($curnet) $+ $u $+ : $networkuses(color)
  iecho First discovered this network: $hc($duration($calc($ctime - $nget(uses.firstdate)))) ago
  if ($nget(lastconnect)) iecho You last connected to this network:  $hc($duration($calc($ctime - $nget(lastconnect)))) ago

  iecho You are connected to server: $hc($server) on port $ac($port) $paren($ac($serverip))
  iecho You have been online for: $hc($trimdur($online,$iif($online > 3600,s)))
  iecho Total time connected to this network is: $hc($duration($calc($nget(pong) * 60)))
  if ($ncid(lastspoke)) iecho You've been idle for: $hc($trimdur($calc($ctime - $ncid(lastspoke)),$iif($calc($ctime - $ncid(lastspoke)) > 3600,s)))
  if ($ncid(lag)) iecho Your server latency is: $hc($hlag) $iif($ncid(lag.avg),$paren($ac($ncid(lag.avg) $+ s avg)))
  if ($notifyonline) iecho There $iif($ifmatch > 1,are,is) $sc($ifmatch) of your friends online $+ $iif($ifmatch <= 5, : $hc $+ $replace($commaseparate($replace($notifyonline(nicks),$chr(44),$chr(32))),$chr(44), $+ $chr(44) $+ $hc))
  if ($curircd) iecho This server is running IRCD: $hc($curircd)
  if ($nget(netservices)) iecho This server has $sc($numtok($ifmatch,32)) identified services: $hc $+ $replace($commaseparate($nget(netservices)),$chr(44), $+ $chr(44) $+ $hc)

  iecho $str(-,35)
}
ll {
  var %echo = $iif($show, iecho)
  if ($1 != -force) {
    if ($calc($ctime - $nget(links)) < 300) {
      %echo Ignored $hc(/ll) $+ . Wait 5 minutes and try again.
      return
    }
  }

  if (!$isfile($srvfile)) {
    %echo No server list was found for $hc($curnet) $+ .
    %echo Type /ml to create one.
    return
  }

  write -c $tp($curnet $+ .sll)

  nset links $ctime
  ncid -u30 linklooker $true
  !links -n
  if ($window(Links List).state == normal) window -h "Links List"
}
rawlog {
  var %a = $iif($debug,off,on)
  debug $iif(%a == on,-pi $cidwin(RawLog) _rawlog.cb, off)
}
connect {
  if ($ismod(classicui)) dlg ircn.newserv
  else editbox -spf /server
}
con if (!$isid) connect
recon if (!$isid) reconnect
discon if (!$isid) disconnect
disco if (!$isid) disconnect
clock {
  if ((($asctime(nn) == 00) || ($asctime(nn) == 30)) && (%lastclock != $atime)) {
    set %lastclock $atime
    scid -a iecho The time is now $hc(%lastclock) $+ .
  }
}
idlequeries {
  if ($nvar(query.closeidle) != on) return
  var %a = 1, %b
  while ($query(%a) != $null) {
    set %b $ifmatch

    if ($ncid($tab(query,%b,lastmsg))) {
      if ($calc($ctime - $ncid($tab(query,%b,lastmsg))) >= $calc($nvar(query.closeidle.time) * 60 $iif($nvar(query.closeidle.type) == hrs,*60))) {
        iecho -w  %b Closing Idle query window after $duration($calc($ctime - $ncid($tab(query,%b,lastmsg)))) minutes of inactivity...
        iecho -s Closing Idle query window with $hc(%b)

        ncid -r $tab(query,$nick,lastmsg)
        .timer 1 1 close -m %b
      }

    }
    inc %a
  }

}
cls clear
cyclemsgw {
  var %a, %b, %c, %d
  set %d $activecid $active

  set %a 1
  while ($scon(%a)) {
    scon %a
    set %b 1
    while (($query(%b)) || ($chat(%b))) {
      set %c $ifmatch
      if (($window(%c).sbcolor == message) || ($window(%c).sbcolor == highlight)) { if (!$isid) { window -a %c } | set %keyb.lastchan %d | return $cid %c }
      if (($window($+(=,%c)).sbcolor == message) || ($window($+(=,%c)).sbcolor == highlight)) { if (!$isid) { window -a $+(=,%c) } | set %keyb.lastchan %d | return $cid $+(=,%c) }
      inc %b
    }
    inc %a
  }

  set %a 1
  while ($scon(%a)) {
    scon %a
    set %b 1
    while ($chan(%b)) {
      set %c = $ifmatch
      if ($window(%c).sbcolor == highlight) { if (!$isid) { window -a %c } | set %keyb.lastchan %d | return $cid %c }
      inc %b
    }
    inc %a
  }

  set %a 1
  while ($scon(%a)) {
    scon %a
    set %b 1
    while ($chan(%b)) {
      set %c $ifmatch
      if (($window(%c).sbcolor == message) || ($window(%c).sbcolor == highlight)) { if (!$isid) { window -a %c } | set %keyb.lastchan %d | return $cid %c }
      inc %b
    }
    inc %a
  }
  scon -r
  if (!%keyb.lastchan) return
  scid $gettok(%keyb.lastchan,1,32)
  if (!$isid) window -a $gettok(%keyb.lastchan,2,32)
  else return $cid $gettok(%keyb.lastchan,2,32)
  set %keyb.lastchan %d
}
dl run $getdir
dos {
  var %a = $iif((9? iswm $os && $isfile(command.com)),command.com,cmd.exe) 
  if ($isid) return %a
  run %a
}
themes {
  if ($1 != -list) {
    if ($isalias(nxt.modern)) { nxt.modern | return }
    elseif ($isalias(nxt)) { nxt | return }
  }
  var %cmd = $iif($1 == -c,$2-)

  var %a = 1, %b, %c

  if (!%cmd) {
    echo -ag  . $+ $str(-,56) $+ .
    echo -ag  $vl  $fix(2) $fix(13,theme) $fix(10,ver) $fix(10,schemes) $fix(15,author) $+ $vl
    echo -ag  ' $+ $str(-,56) $+ '
  }
  else {
    %cmd . $+ $str(-,80) $+ .
    %cmd $alistfrmt($tab(1 s,16 Theme:,c7 Ver:,c16 Author:,c7 Schemes, 26 Desc:)).line
    %cmd . $+ $str(-,80) $+ .

  }
  var %thms = $findfile($themedir,*.mts,0)
  var %t.name, %t.version, %t.author
  while (%a <= %thms) {
    set %b $qt($findfile($themedir,*.mts,%a))

    %t.name = $gettok($read(%b, nw, Name *), 2-, 32)
    %t.version = $gettok($read(%b, nw, Version *), 2-, 32)
    %t.author = $gettok($read(%b, nw, Author *), 2-, 32)

    if (!%cmd) {
      echo -ag  [[ $+ $iif($qt(%b) == $hget(nxt_data,curtheme),*, ) $+ ]] $fix(15,$deltok($nopath(%b),-1,46)) $fix(10,$left(%t.version,8)) $fix(10,$nxt_schemecount(%b)) $fix(15,$left(%t.author,13))  
      if ($qt(%b) == $hget(nxt_data,curtheme)) {
        var %q = 1
        while (%q <= $hfind(nxt_theme, Scheme* ,0,w)) {
          echo -ag $fix(4) [[ $+ $iif(%q == $hget(nxt_data,curscheme),*, ) $+ ]]  $hget(nxt_theme,$hfind(nxt_theme,Scheme*,%q,w))

          inc %q
        }
      }

    }
    else %cmd $alistfrmt($tab(1 $iif($ismod($nopath(%b)),+,-),16 $deltok($nopath(%b),-1,46),fr7 $modinfo(%b,version),fc16 $modinfo(%b,author),f26 $modinfo(%b,module))).line



    ; show schemes of currently loaded theme underneath listing
    inc %a
  }
  if (!%cmd) iecho use: /theme <theme> to load a new theme, use: /theme -s# <theme> to change scheme number.
  else {
    %cmd $| $fix(38,Load: /theme <theme>) $lfix(39,Unload: /unmod <module>) $|
    %cmd ' $+ $str(-,80) $+ '
  }


}
tb {
  if ($nvar(titlebar) != on) return
  if ($0) titlebar $1-
  if ($server) { 

    if ($active ischan) {
      var %act = $active
      if (%chanspy.num)  { 
        if (%chanspy.scon) scon $ifmatch
        if ($chan(%chanspy.num)) set %act $ifmatch
      }

      var %a
      set %a $replace($nvar(titlebar.format),@time,$ab($atime),@me,$ab($me),@usermode,$ab($usermode),@server,$ab($server),@srvrport,$ab($port),@network,$ab($network),@idle,$ab(idle: $+ $rsc($duration($idle))),@netnum,$ab(network: $+ $cid2scon($cid) $+ / $+ $scon(0)),@channame,$ab($chan(%act)),@chantopic,$ab($chan(%act).topic),@chanmodes,$ab($chan(%act).mode),@chanusers,$iif(%act ischan,[o: $+ $nick(%act,0,o) $iif(% isin $issupport(prefix),h: $+ $nick(%act,0,h)) v: $+ $nick(%act,0,v,o) n: $+ $nick(%act,0,r) t: $+ $nick(%act,0) $+ ]),@chantotusers,[t: $+ $nick(%act,0) $+ ])
      if ($away) set %a $replace(%a,@away,[away: $+ $gone $paren($shorttext(20,$awaymsg)) ])
      else set %a $remove(%a,@away)
      if ($nvar(lagstat) == on) set %a $replace(%a,@lag,[lag: $+ $hlag $+ ])
      else set %a $remove(%a,@lag)
      if ($issupport(version)) set %a $replace(%a,@srvrver,$paren($issupport(version)))
      else set %a $remove(%a,@srvrver)

      if (%chanspy.num) && (%chanspy.scon) scon -r
      titlebar %a

    }
    else {

      var %a
      set %a $remove($nvar(titlebar.format),@channame,@chantopic,@chanmodes,@chanusers,@chantotusers)
      set %a $replace(%a,@time,$ab($atime),@me,$ab($me),@usermode,$ab($usermode),@server,$ab($server),@srvrport,$ab($port),@network,$ab($network),@idle,$ab(idle: $+ $rsc($duration($idle))),@netnum,$ab(network: $+ $cid2scon($cid) $+ / $+ $scon(0)))
      if ($away) set %a $replace(%a,@away,[away: $+ $gone ( $+ $left($modget(away,awaymsg),20) $+ ) ])
      else set %a $remove(%a,@away)
      if ($nvar(lagstat) == on) set %a $replace(%a,@lag,[lag: $+ $hlag $+ ])
      else set %a $remove(%a,@lag)
      if ($issupport(version)) set %a $replace(%a,@srvrver,$paren($issupport(version)))
      else set %a $remove(%a,@srvrver)
      titlebar %a
    }
  }
  else {

    titlebar [[ Not Connected ]] [[ ircN $strip($nvar(ver)) ]]

  }


}
togglechans $iif($hiddenchans,showchans,hidechans)
hidechans {
  var %s = 1, %cs = $activecid
  while ($scon(%s) != $null) {
    if ($nvar(tinyswitchbar)) { }
    else  scon %s

    var %a = 1
    while ($chan(%a) != $null) {
      if ($istok($nvar(hidechans),$chan(%a),44)) {

        if (!$ischanhid($chan(%a))) {
          window -w0 $chan(%a)

          if ((!$nvar(hidechans.dontnotify)) && ($show))  scid %cs iecho -s  Channel $hc($chan(%a)) hidden from switchbar.
        }

      }
      inc %a
    }
    if ($nvar(tinyswitchbar)) break
    inc %s
  }
  scon -r
}
showchans {
  var %s = 1, %cs = $activecid
  while ($scon(%s) != $null) {
    if ($nvar(tinyswitchbar)) { }
    else   scon %s
    var %a = 1
    while ($chan(%a) != $null) {
      if ($istok($nvar(hidechans),$chan(%a),44)) {
        if ($ischanhid($chan(%a))) {
          window -w3 $chan(%a)
          if ((!$nvar(hidechans.dontnotify)) && ($show))  scid %cs iecho -s Channel $hc($chan(%a)) shown to switchbar.
        }
      }
      inc %a
    }
    if ($nvar(tinyswitchbar)) break
    inc %s
  }
  scon -r
}
reconnect {
  if ($server) {
    quit $iifelse($nvar(string_reconnecting),reconnecting)
    !server $server
  }
  else iecho You aren't connected to a server!
}
setup {
  if ($ismod(classicui)) {
    if ($ismod(modernui)) {
      if (!$dialog(ircn.setup.modern)) dlg ircn.setup.modern
    }
    else dlg ircn.setup

  }
  else { iecho You do not have the Classic UI or Modern UI modules loaded. Cannot display setup dialog. If you do not want dialogs use the /hlist or /nvars command. | nvars | return }

}
server {
  if ($left($1,1) == +) !server -m $right($1,-1) $2-
  else !server $1-
}
servlist {
  var %a = 1
  while ($scon(%a) != $null) {
    if ($scon(%a).status == disconnected) { inc %a | continue }
    echo -s $ip -> $scon(%a).serverip $+ : $+ $remove($scon(%a).port,+) $paren($scon(%a).server) $upper($scon(%a).status)
    inc %a
  }
}

nettimer .timer $+ $cid $+ .* $1-
sv $iif($1-,$1-,say) ircN: $+ $nvar(ver) $+ . $+ $nvar(reldate) - mIRC: $+ $version win: $+ $os uses: $+ $nvar(uses) $iif($hget(nxt_data,curtheme),theme: $+ $iif($hget(nxt_data,curnto),$nopath($hget(nxt_data,curnto)),$nopath($hget(nxt_data,curtheme))) $iif($hget(nxt_data,curscheme),scheme: $+ $hget(nxt_Theme, Scheme $+ $hget(nxt_Data, CurScheme)))) 
svinfo $iif($1,msg $1,say) $nvar(lver) has been used $nvar(uses) times, $iif($nvar(installed),Installed $duration($calc($ctime - $nvar(installed))) ago.) I have spent $b($rsc2($duration($calc($nvar(pong) * 60)))) connected to IRC. Currently on $b($curnet) - Up for $uptime(system,1) $+ . Currently $full-date $+ .
modv {
  var %a = 1, %b, %c, %d
  while ($gettok($nvar(modules),%a,44) != $null) {
    set %b $ifmatch
    set %c $modinfo($md(%b),version)
    set %d %d $deltok(%b,-1,46) $+ :v $+ %c
    inc %a
  }
  $iif($1,$1,say) ircN: $+ $nvar(ver) - modules: $+ $numtok($nvar(modules),44) - %d
}
usage $iif($1,msg,say) $1 I have used my copy of $nvar(lver) online for a total of $rsc2($duration($calc($nvar(pong) * 60)))
uptime {
  if ($isid) return
  if ($window($active).type == channel) say Time is $atime $+ , computer has been up for $rsc2($uptime(system,1))
  else iecho Time is $atime $+ , computer has been up for $rsc2($uptime(system,1))

}
www url $$1-
query { 
  if (-* iswm $1) { set -nu0 %::nick $2 | set -nu0 %::flags $1 }
  else { set -nu0 %::nick $1 }

  .timer 1 0 ! $+ $iif(!$show,.) $+ query $1-

  if ($0)  .signal -n ircN_hook_cmd_query %::nick
  unset %::nick %::flags
}
hidenetwin {
  if ($1 == on) { if ($nvar(tinyswitchbar) == on) { tinysb off | iecho Disabled Compact Switchbar } | nvar hidenetwin on  | unset %lastactivescon  }
  elseif ($1 == off) {
    nvar hidenetwin
    var %a = 1, %y
    while ($window(@*.*,%a) != $null) {
      set %y $ifmatch

      if ($istok($ntmp(hidenetwin_hiddenwindows),%y,44))  window -w3 %y

      inc %a
    }

    ntmp -r hidenetchan_hiddenwindows
    ntmp -r hidenetwin_lastactivecid
    return
  }

  if ($nvar(hidenetwin) == on) {
    var %wincid = $window($active).cid

    if (%wincid == $ntmp(hidenetwin_lastactivecid)) {

      return
    }
    var %a = 1, %y
    while ($gettok($ntmp(hidenetwin_hiddenwindows),%a,44) != $null) {
      set %y $ifmatch
      if (!$window(%y))  ntmp hidenetwin_hiddenwindows $remtok($ntmp(hidenetwin_hiddenwindows),%y,1,44)
      inc %a
    }
    var %a = 1, %y
    while ($window(*,%a) != $null) {
      set %y $ifmatch
      if (@ircn.mircloak.* iswm %y) { inc %a | continue }
      if (!$istok(custom picture,$window(*,%a).type,32)) { inc %a | continue }
      if ($window(*,%a).cid != $activecid) && (!$window(%w).anysc) {  
        window -w0 %y
        ntmp hidenetwin_hiddenwindows $addtok($ntmp(hidenetwin_hiddenwindows),%y,44)
      }
      else {
        if ($istok($ntmp(hidenetwin_hiddenwindows),%y,44)) {
          if ((!$window(%y).sbstate) && (!$window(%w).anysc))  {
            ntmp hidenetwin_hiddenwindows $remtok($ntmp(hidenetwin_hiddenwindows),%y,1,44)
            window -w3 %y
          }
        }
      }

      inc %a
    }

    ntmp hidenetwin_lastactivecid %wincid
  }
}
highlight abook -h

tinysb {
  if ($1 == on) { 
    nvar tinyswitchbar on  
    if ($nvar(hidenetwin) == on) { hidenetwin off | iecho Disabled Compact Custom Window. }
    unset %lastactivescon  

  }
  elseif ($1 == off) {
    nvar tinyswitchbar 
    var %a = 1
    while ($scon(%a) != $null) {
      scon %a
      var %q = 1, %y
      while ($window(*,%q) != $null) {
        set %y $ifmatch
        if (%y == Status Window) { inc %q | continue }

        if ($istok($ncid(sb_hiddenwindows),%y,44)) {
          window -w3 $iif($chr(32) isin %y," $+ %y $+ ",%y)
          ncid sb_hiddenwindows $remtok($ncid(sb_hiddenwindows),%y,1,44)
        } 
        inc %q
      }
      inc %a
    }
    hidechans

    scon -r
    ncid -r sb_hiddenwindows
    ncid -r sb_lastwindow
    unset %lastactivescon
    return
  }

  if ($nvar(tinyswitchbar) == on) {
    var %scon = $cid2scon($cid)

    if (%scon == %lastactivescon) {
      ncid sb_lastwindow $active
      return
    }

    var %a = 1
    while ($scon(%a) != $null) {
      scon %a
      var %q = 1, %y
      while ($window(*,%q) != $null) {
        set %y $ifmatch
        if (%y == Status Window) { inc %q | continue }
        if (%a == %scon) { 
          if ($istok($ncid(sb_hiddenwindows),%y,44)) {
            window -w3 $+ $iif(%y == $ncid(sb_lastwindow),a) $iif($chr(32) isin %y," $+ %y $+ ",%y)
            ncid sb_hiddenwindows $remtok($ncid(sb_hiddenwindows),%y,1,44)
          } 
        }
        else {
          if (($window($iif($chr(32) isin %y," $+ %y $+ ",%y)).state != hidden) && (!$window($iif($chr(32) isin %y," $+ %y $+ ",%y)).anysc))  {
            ncid sb_hiddenwindows $addtok($ncid(sb_hiddenwindows),%y,44)
            window -w0 $iif($chr(32) isin %y," $+ %y $+ ",%y)
          }
        }
        inc %q
      }
      inc %a
    }
    scon -r
    set %lastactivescon %scon
  }
}
toggle {
  if (% [ $+ [ $1 ] ] == on) set % [ $+ [ $1 ] ] off
  else set % [ $+ [ $1 ] ] on
}
qplay {
  ;qplay <-r|-s|-f|-d|stop> <filename> [section|start|delay] [lines|end] [command]

  if ($exists($2) == $false) iecho /qplay: $2 file doesn't exist.
  elseif (($1 == -s) && ($4)) {
    set %i.qplay -1
    :loop
    inc %i.qplay
    $5- $readini($2,$3,n [ $+ [ %i.qplay ] ] )
    if ($pls(%i.qplay,1) < $4) goto loop
  }
  elseif (($1 == -f) && ($2)) {
    set %i.qplay 0
    :start
    inc %i.qplay
    $3- $read -l [ $+ [ %i.qplay ] ] $2
    if (%i.qplay < $lines($2)) goto start
  }
  elseif (($1 == -r) && ($4)) {
    set %i.qplay $3
    :start
    inc %i.qplay
    $5- $read -l [ $+ [ %i.qplay ] ] $2
    if (%i.qplay < $4) goto start
  }
  elseif (($1 == -d) && ($3)) {
    set %qp.i 1
    set %qp.file $2
    set %qp.lines $lines($2)
    set %qp.delay $3
    $4- $read -l1 $2
    if (%qp.lines > 1) .timerqplay 1 $3 qplay -cont $2 $4-
  }
  elseif (($1 == -cont) && ($2)) {
    inc %qp.i
    $3- $read($2,n,[ $+ [ %qp.i ] ] )
    if (%qp.i < %qp.lines) {
      .timerqplay 1 %qp.delay qplay $1-
    }
    else unset %qp.file %qp.delay %qp.lines
  }
  elseif (($1 == stop) && (%qp.file)) {
    .timerqplay off
    unset %qp.file %qp.delay %qp.lines
  }
  else iecho Syntax: /qplay <-r|-s|-f|-d|stop> <filename> [section|start|delay] [lines|end] [command]
}
ndebug {
  if (%debugger != on) return
  if (!$window(@ndebug. $+ $cid)) window -k -t15,15,15 @ndebug. $+ $cid 
  echo -ti2 @ndebug. $+ $cid $1-
}
chanlist {
  var %f
  if (-* iswm $1) {
    set %f $1
    tokenize 32 $2-
  }
  var %w = $cidwin(ChannelList)
  if (($ismod(classicui)) && (!$dialog(ircn.pleasewaitfreeze))) dlg -r ircn.pleasewaitfreeze

  window -kbMl $+ $iif(n isin %f,n,a)  -t30,40,10 %w
  clear %w

  ncid chanfilter.size $lines( $sys(channels\ $+ $curnet $+ .txt) )
  iline %w 1 $chr(22) $+ __________ $+ Channel $+ __________ $+ $tab $+ __ $+ Size $+ __ $+ $tab $+  $+ $str(_,20) $+ Topic $+ $str(_,20)

  filter -nkeut 2 32 $sys(channels\ $+ $curnet $+ .txt) _chanlist.filter $iif(* !isin $1,*) $+ $1- $+  $iif(* !isin $1,*) 
  if ($dialog(ircn.pleasewaitfreeze)) dialog -x ircn.pleasewaitfreeze

  window -b %w
  !titlebar %w Channel Listing $paren($calc($line(%w, 0) - 1) $+ / $+  $ncid(chanfilter.size) ,[,])
  ncid -r chanfilter.size
}

;notify {
; if (!$1) { ncid -r notify.online,notify.notonline | .ntimer notifyupdate 1 30 _refresh.notify.lastseen }
;  ! $+ $iif(!$show,.) $+ notify $1-
;}
nickcol abook -l
nickfind {
  if (($longip($1) isnum) && ($isip($1)) && (!$2)) {
    ncid nickfind.dns $addtok($ncid(nickfind.dns),$1,44)
    .dns $1
    return
  }

  if ($1 == <<whoend>>) {
    var %w = @nickfind.who. $+ $cid
    if ($line(%w,0)) {
      var %a = 1
      while (%a <= $line(%w,0)) {
        var %y = $line(%w,%a)
        tokenize 32 %y
        iecho Found user $hc($6) $rbrk($3  $+ @ $+ $4) on $5 $+ $iif($remove($2,*,.), in $sc($2)) $+ .
        inc %a
      }
    }
    else iecho No users found from $hc($2)
    close -@ %w
    return
  }
  else {

    if ($1 ischan) {
      var %c = $1
      var %z = *!*@*
    }
    else {
      var %z = $iif(! isin $1,$1,*!*@ $+ $iif(* !isin $1,*) $+ $1)
      var %x = $1 $+ *!*@*
      var %c = $iif($2 != 1,$2)
    }
    if (!$1) {
      iecho syntax: /nickfind [hostmask/nickname/ipaddr] [#channel]    
      return
    }
    if (%c) {
      if ($ialchan(%z,%c,0)) {
        var %a = 1
        while (%a <= $ialchan(%z,%c,0)) {
          var %y = $ialchan(%z,%c,%a)
          iecho Found user $hc($ial(%y).nick) $rbrk($ial(%y).addr) in $hc($com.channels($ial(%y).nick)) $+ .
          inc %a
        }
        return
      }
      elseif ($ialchan(%x,%c,0)) {
        var %a = 1
        while (%a <= $ialchan(%x,%c,0)) {
          var %y = $ialchan(%x,%c,%a)
          iecho Found user $hc($ial(%y).nick) $rbrk($ial(%y).addr) in $hc($com.channels($ial(%y).nick)) $+ .
          inc %a
        }
        return
      }
      else { iecho No users found from $hc($1) in $sc(%c) | return }
    }
    else {
      if ($ial(%z,0)) {
        var %a = 1
        while (%a <= $ial(%z,0)) {
          var %y = $ial(%z,%a)
          iecho Found user $hc($ial(%y).nick) $rbrk($ial(%y).addr) in $hc($com.channels($ial(%y).nick)) $+ .
          inc %a
        }
        return
      }
      elseif ($ial(%x,0)) {
        var %a = 1
        while (%a <= $ial(%x,0)) {
          var %y = $ial(%x,%a)
          iecho Found user $hc($ial(%y).nick) $rbrk($ial(%y).addr) in $hc($com.channels($ial(%y).nick)) $+ .
          inc %a
        }
        return
      }
      else {
        .window -hk @nickfind.who. $+ $cid 
        clear @nickfind.who. $+ $cid
        ncid nickfind.who $addtok($ncid(nickfind.who),$1,44)
        .quote who $1
      }
    }
  }
}

; remove this asap
online _online

fullscreen showmirc -f
dcc {
  if ($1 == send) {
    var %flag
    if (-* iswm $2) { .timer 1 0 ! $+ $iif(!$show,.) $+ dcc $1- | return }
    set %flag - $+ $iif($nvar(transfer.autominsend),m) $+ $iif($nvar(transfer.autoclosesend),c) $+ $iif($nvar(transfer.limitsend),l)
    .timer 1 0 ! $+ $iif(!$show,.) $+ dcc send %flag $2-
    return
  }
  if (($1 == passive) && ($istok(on off,$2,32))) ntmp dccpassive $iif($2 == on,$2)
  if (($1 == maxcps) && ($2 isnum)) ntmp dccmaxcps $iif($2 isnum,$2)

  .timer 1 0 ! $+ $iif(!$show,.) $+ dcc $1-
}
sdcc dcc send $1-
cdcc dcc chat $1-
fsend {
  if ($istok(on off,$1,32)) ntmp fastsend $iif($1 == on,$1)
  .timer 1 0 ! $+ $iif(!$show,.) $+ fsend $1-
}
pdcc {
  if ($istok(on off,$1,32))   ntmp pumpdcc $iif($1 == on,$1)  
  .timer 1 0 ! $+ $iif(!$show,.) $+ pdcc $1-
}
dccrelay {
  if ($isid) {
    if ($nget(dccrelay) == on) return $true
    elseif ($nvar(dccrelay) == on) return $true
    else return $false
  }
  else {
    var %flags, %dccrelay, %dccnick, %dccnet
    if (!$1) {
      iecho Syntax: /dccrelay [-gn] <ON|OFF|CLEAR> [network] <nick> 
      iecho $str( ,10) -g   $str( ,6) changes affect the global settings (does not clear network settings)
      iecho $str( ,10) -n   $str( ,6) changes affect the current network's settings
      iecho $str( ,10) CLEAR $str( ,3) clears settings for global (-g), network (-n) or all open networks (no flags)
    }
    if ($left($1,1) == -) {
      if (n isin $1) set %flags n
      if (g isin $1) set %flags g
      if ($2) set %dccrelay $2

      if ($4) {
        set %dccnick $4
        set %dccnet $3
      }
      elseif ($3) set %dccnick $3
    }
    else {
      if ($1) set %dccrelay $1

      if ($3) {
        set %dccnick $3
        set %dccnet $2
      }
      elseif ($2) set %dccnick $2
    }
    if (%dccrelay == clear) {
      if (%flags == $null) {
        nvar dccrelay
        nvar dccrelay.nick
        var %a = $scid(0)
        while (%a > 0) {
          scid %a
          nset dccrelay
          nset dccrelay.nick
          dec %a
        }
        scid -r
        iecho DCC relay $sc(CLEARED) all settings!
      }
      if (%flags == n) {
        nset dccrelay
        nset dccrelay.nick
        iecho DCC relay $sc(CLEARED) settings on $ac($network) $+ !
      }
      if (%flags == g) {
        nvar dccrelay
        nvar dccrelay.nick
        iecho DCC relay $sc(CLEARED) global settings, without affecting network specific settings!
      }
    }
    if (%dccrelay == off) {
      if (%flags == n) {
        nset dccrelay
        nset dccrelay.nick
        iecho DCC relay $sc(disabled) on $ac($network) $+ !
      }
      else {
        nvar dccrelay
        nvar dccrelay.nick
        iecho DCC relay $sc(disabled) globally!
      }
    }
    elseif (%dccrelay == on) {
      if (%flags == n) {
        nset dccrelay on
        nset dccrelay.nick $+(%dccnick,$chr(44),$iif(%dccnet,%dccnet,$network))
        iecho DCC relay $sc(enabled) on $ac($network) to $hc(%dccnick) $+ , $iif(%dccnet, on $ac(%dccnet) $+ !,network not specified $+ $chr(44) assuming $ac($network) $+ !)
      }
      else {
        nvar dccrelay on
        nvar dccrelay.nick $+(%dccnick,$chr(44),$iif(%dccnet,%dccnet,$network))
        iecho DCC relay $sc(enabled) globally to $hc(%dccnick) $+ , $iif(%dccnet, on $ac(%dccnet) $+ !,network not specified $+ $chr(44) assuming $ac($network) $+ !)
      }
    }
  }
}
ircopedit {
  if ($ismod(classicui)) {
    set -u5 %ircopedit.loadnetwork $1
    dlg -r ircn.ircopperform
  }
  else {
    var %a = $sd(ircop-perform.ini)
    if (!$lines(%a))  write %a $str($chr(35),2) Remove the comments from the lines below and edit them as necessary $+ $crlf $+ $crlf $+ $chr(35) [[ $+ $iifelse($curnet,irc.example.com) $+ ]] $+ $crlf $+ $chr(35) n0=//iecho You are now an ircOP on $ $+ server $+ $crlf $+ $chr(35) n1=//beep $+ $crlf

    run notepad.exe %a
  }
}
ircn run $hd(ircN_ReadMe.txt)
ircn.dclick {
  if ($1 == status)  $iifelse($nvar(ircn.dclick.status),$iif($server,lusers))
  if ($1 == query) $iifelse($nvar(ircn.dclick.query),wi) $2
  if ($1 == chan)  $iifelse($nvar(ircn.dclick.chan),channel)
  if ($1 == nicklist)  $iifelse($nvar(ircn.dclick.nicklist),query) $2
  if ($1 == notifylist)  $iifelse($nvar(ircn.dclick.notify),whois) $2
  if ($1 == msg)  $iifelse($nvar(ircn.dclick.msg),wi) $2
}
help {
  if (($isfile(mirc.chm)) && ($1-)) winhelp mirc.chm $1-
  elseif (($isfile(mirc.hlp)) && ($1-)) winhelp mirc.hlp $1-
  else ircn
}
joinircn {
  var %a, %b
  set %a $net2scid(freenode)
  if ((%a) && ($scid(%a).server)) set %b $$input(Would you like to join $+($chr(35),ircN) on your current freenode connection?,y)
  if (%b) scid %a join #ircN
  else server -m freenode -j #ircN
}

modules {
  if ($1 != -list) {
    if (($ismod(modernui)) && (!$0)) {
      modulesdlg.modern
      return
    }
    elseif (($ismod(classicui)) && (!$0)) {
      modulesdlg
      return
    }
  }
  var %cmd = $iif($1 == -c,$2-)

  var %a = 1, %b, %c

  if (!%cmd) {
    echo -ag  . $+ $str(-,63) $+ .
    echo -ag  $vl  $fix(2) $fix(13,module) $fix(10,ver) $fix(15,author) full module name $vl
    echo -ag  ' $+ $str(-,63) $+ '
  }
  else {
    %cmd . $+ $str(-,80) $+ .
    %cmd $alistfrmt($tab(1 s,16 Module:,c7 Ver:,c16 Author:,26 Full module name:)).line
    %cmd . $+ $str(-,80) $+ .

  }
  var %mods = $findfile($md,*.mod,0)
  while (%a <= %mods) {
    set %b $findfile($md,*.mod,%a)
    if (!%cmd) echo -ag  [[ $+ $iif($ismod($nopath(%b)),*, ) $+ ]] $fix(15,$deltok($nopath(%b),-1,46)) $fix(10,$left($modinfo(%b,version),8)) $fix(15,$left($modinfo(%b,author),13)) $modinfo(%b,module)  
    else %cmd $alistfrmt($tab(1 $iif($ismod($nopath(%b)),+,-),16 $deltok($nopath(%b),-1,46),fr7 $modinfo(%b,version),fc16 $modinfo(%b,author),f26 $modinfo(%b,module))).line
    inc %a
  }
  if (!%cmd) iecho use: /module modulename to load a module, or /unmod modulename to unload 
  else {
    %cmd $| $fix(38,Load: /module <module>) $lfix(39,Unload: /unmod <module>) $|
    %cmd ' $+ $str(-,80) $+ '
  }
}
module {
  if (!$0) || ($1 == -list) { modules $1 | return }

  var %a
  if ($isfile($md($1))) set %a $md($1)
  else set %a $findfile($md,$1 $+ *.mod,1)

  if (!%a) {  iecho No such module exists ' $+ $1 $+ ' | return }
  $iif(!$show,.) $+ _loadmod $iif($ismod($nopath(%a)),reload,load) %a

}
umode {
  if ($server) && ($me) mode $me $iif(+* !iswm $1,+) $+ $1
}
unnotify {
  if (!$1) { theme.syntax UnNotify: /unnotify <nick> | return }
  if (!$notify($1)) { iecho UnNotify: $1 isn't in your notify list. | return }
  notify -r $$1
}
unotify unnotify $$1-
unmodule $iif(!$show,.) $+ unmod $1-
unmod {
  var %a
  if ($isfile($md($1))) set %a $md($1)
  else set %a $findfile($md,$1 $+ *.mod,1)


  if (!$isfile(%a)) return
  if (!$ismod($nopath(%a))) return 

  if ($ismoddeppended(%a)) {
    var %b = $ifmatch
    iecho Unable to unload $hc($nopath(%a)) because it is depended on by: $hc(%b)
    return
  }

  _delpopups %a
  _unloadmodfiles %a

  nvar modules $remtok($nvar(modules),$nopath(%a),1,44)
  if ($show) { 
    iecho Unloaded module ' $+ $noext($nopath(%a)) $+ '
  }
  ircnsave    
}
echospaces {
  ;/echospaces [-a|-s|window] <text use ctrl+i for multiplespaces)
  ;since mirc cant echo multiple spaces normally, use this command to echo to a window with multiple spaces
  ;using ctrl+i (tab) instead, and it will replace it with regular multiple spaces
  var %flags, %text = $1-, %win, %echo
  if (-* iswm $1) { set %flags $1 |  set %text $2-  }
  elseif ($window($1)) { set %win $1 | set %text $2- }
  bset -t &z 1 %text
  breplace &z 9 32
  write -c $tp(echospaces.dat)
  bwrite $tp(echospaces.dat) -1 -1 &z
  if ($window(%win)) set %echo %win
  elseif (s isin %flags) set %echo -s
  else set %echo $iif(!$istok(channel query chat,$window($active).type,32),-s,$active)
  loadbuf %echo $tp(echospaces.dat)
}
editquits {
  if ($istok(%ircnsetup.docked,ircnsetup.editquits,44)) return
  if ($ismod(classicui)) {
    dlg -r ircNsetup.editquits
    dialog -rsb ircNsetup.editquits -1 -1 186 149
  }
  else run notepad.exe $sd(quits.txt)
}
editkicks {
  if ($istok(%ircnsetup.docked,ircnsetup.editkicks,44)) return
  if ($ismod(classicui)) {
    dlg -r ircNsetup.editkicks
    dialog -rsb ircNsetup.editkicks -1 -1 190 164
  }
  else run notepad.exe $sd(kicks.txt)
}
editctcps {
  if ($istok(%ircnsetup.docked,ircn.ctcplist.modern,44)) return
  if ($ismod(modernui)) {
    dlg -r  ircn.ctcplist.modern
    dialog -rsb ircn.ctcplist.modern -1 -1 186 149
  }
  elseif ($ismod(classicui))    dlg -r  ircn.ctcplist

}
encrypt return $_encryptt($1,$2-)
decrypt return $_decryptt($1,$2-)
fencrypt {
  if ($0 < 3) {
    if ($show) iecho Syntax: /fencrypt <password> <input filename|*.ext> <output filename|*.ext>
    return
  }
  elseif (($left($nopath($2),1) == $chr(42)) || ($left($nopath($3),1) == $chr(42))) {
    if (($left($nopath($2),1) == $chr(42)) && ($left($nopath($3),1) == $chr(42))) {
      var %i
      set %i 1
      while ($findfile($nofile($2),$nopath($2),%i,0)) {
        _fencrypt $1 $ifmatch $addtok($nofile($3),$nopath($puttok($ifmatch,$gettok($3,2,46),2,46)),0)
        inc %i
      }
    }
    else {
      if ($show) iecho Syntax: /fencrypt <password> <input filename|*.ext> <output filename|*.ext>
      return
    }
  }
  else _fencrypt $1 $2 $3
}
fdecrypt {
  if ($0 < 3) {
    if ($show) iecho Syntax: /fencrypt <password> <input filename | *.ext> <output filename | *.ext>
    return
  }
  elseif (($left($nopath($2),1) == $chr(42)) || ($left($nopath($3),1) == $chr(42))) {
    if (($left($nopath($2),1) == $chr(42)) && ($left($nopath($3),1) == $chr(42))) {
      var %i
      set %i 1
      while ($findfile($nofile($2),$nopath($2),%i,0)) {
        _fdecrypt $1 $ifmatch $addtok($nofile($3),$nopath($puttok($ifmatch,$gettok($3,2,46),2,46)),0)
      }
    }
    else {
      if ($show) iecho Syntax: /fdecrypt <password> <input filename | *.ext> <output filename | *.ext>
      return
    }
  }
  else _fdecrypt $1 $2 $3
}
fkey fkeys
fkeys {
  if ($isid) {
    if ($1 == normal) return F1,F2,F3,F4,F5,F6,F7,F8,F9,F10, $+ $iif($remove($group(#ircN_F11Key).status,off), F11) $+ ,F12,sF1,sF2,sF3,sF4,sF5,sF6,sF7,sF8,sF9,sF10,sF11,sF12,cF1,cF2,cF3,cF5,cF7,cF8,cF9,cF10,cF11,cF12
    if ($1 == preferred) return F1,sF1,cF1,F2,sF2,cF2,F3,sF3,cF3,F4,sF4,F5,sF5,cF5,F6,sF6,F7,sF7,cF7,F8,sF8,cF8,F9,sF9,cF9,F10,sF10,cF10, $+ $iif($remove($group(#ircN_F11Key).status,off), F11) $+ ,sF11,cF11,F12,sF12,cF12
  }

  else  fkeysettings
}

viewfile {
  if (!$isfile($qt($1-))) return 
  if ($dialog(ircn.viewfile)) dialog -x ircn.viewfile
  if ($ismod(classicui)) { set %viewfile $1- | dialog -m ircN.viewfile ircN.viewfile }
  else { window -aRik $+ $iif($version >= 7.11, j99999999)  @viewfile | clear @viewfile | titlebar @viewfile Viewfile: $1-   | loadbuf @viewfile $qt($1-) }
}
whoami if ($server) cwhois $me
wiecho {
  if ($window(@themepreview)) thm.prevadd -c $color(WHOIS) $1-
  elseif ($nvar(show.whois) == window) {
    var %a = @Whois. $+ $cid
    if (!$window(%a)) window -kvmn %a
    echo $colour(WHOIS) %a $1-
  }
  else echo $colour(WHOIS) $iif(($mopt(2,26) && $nvar(show.whois) != status),-am,-sm) $1-

}
secho iiecho -s $iif($1-,$1-,$o)
iecho {
  if (($hget(nxt_data,CurTheme)) && ($isalias(theme.text))) {
    var %a = $_iecho.cmd($1-)
    set -u %:echo $gettok(%a,1,231)
    set -nu1 %::text $gettok(%a,2-,231)
    theme.text echo
    unset %:echo %:echo %::text
  }
  else {
    var %a = $_iecho.cmd($1-)
    $gettok(%a,1,231) $+($iifelse($npre,1[12N01]),) $gettok(%a,2-,231)
  }
}
iiecho {
  var %a = $_iecho.cmd($1-)
  $gettok(%a,1,231) $gettok(%a,2-,231)
}
iecho.spaces echospaces -a $+($npre,) $1-
iiecho.spaces echospaces -a $+($npre,) $1-

ialset {
  var %a = 1
  ;/ialset nick/host <item> [val]
  if (!$ial($1)) return
  if ($3- != $null) {
    if ($wildtok($ial($1).mark,$2 $+ =*,1,1)) .ialmark $1 $reptok($ial($1).mark,$ifmatch,$2 $+ = $+ $3-,1,1)
    else .ialmark $1 $ial($1).mark $+ $chr(1) $+ $2 $+ = $+ $3-
  }
  elseif ($wildtok($ial($1).mark,$2 $+ =*,1,1)) .ialmark $1 $remtok($ial($1).mark,$ifmatch,1,1)
}
cwiset {
  if ($ial($1)) ialset $1 $2-
  else {
    var %h = $cid $+ .ircN.cachewhois 
    if (!$hget(%h)) hmake %h 25 

    if ($3- != $null) {
      if ($wildtok($hget(%h,$1),$2 $+ =*,1,1)) hadd %h $1 $reptok($hget(%h,$1),$ifmatch,$2 $+ = $+ $3-,1,1)
      else hadd %h $1 $hget(%h,$1) $+ $chr(1) $+ $2 $+ = $+ $3-
    }
    elseif ($wildtok($hget(%h,$1),$2 $+ =*,1,1))  hadd %h $1 $remtok($hget(%h,$1),$ifmatch,1,1)
  }
}
cwiget return $iif($ialget($1,$2),$ialget($1,$2),$gettok($wildtok($hget($cid $+ .ircN.cachewhois,$1),$2 $+ =*,1,1),2-,61))
chgnet {
  var %cid = $net2scid($1)
  if (%cid) scid %cid
}
loadsessions {
  if ($isfile(sessions.txt)) rename sessions.txt $sd(sessions.txt)
  if (!$isfile($sd(sessions.txt))) return

  var %a = 1, %i = 1, %a2 = $lines($sd(sessions.txt)), %b, %c
  set -u %::loadsession.num 1
  _sessions.check

  while (%a <= %a2) { 

    if ((%i == 1) && (connect* iswm $status)) inc %i $loadsession(-e,%a)
    elseif (%i != 1) inc %i $loadsession(-e,%a)
    else inc %i $loadsession(-ce,%a)
    inc %a 
    set -u %::loadsession.num %i
  }
  scon 1 
  window -a " $+ $window(*,1) $+ "
}
loadsession {
  ; "/loadsession 1" loads first server in autoconnect list "/loadsession 2" loads the second, etc.
  ; "/loadsession -c 1" loads server to current connection
  ; "/loadsession -e 1" loads server only if it's enabled on the list
  var %b, %f = $flags($1- $2-).flags, %l = $iif(%f,$2,$1)
  if ($isfile(sessions.txt)) rename sessions.txt $sd(sessions.txt)
  if (!$isfile($sd(sessions.txt))) return
  if (!%l) { iecho Syntax: /loadsession <#> | return }
  elseif ($read($sd(sessions.txt),n,%l) != $null) { 
    set %b $ifmatch
    var %ses.server, %ses.port, %ses.pass, %ses.name, %ses.email, %ses.nick, %ses.anick, %ses.session, %ses.enabled

    set %ses.enabled $gettok(%b,1,32)
    if ((%ses.enabled != 1) && (e isin %f)) return 0
    set %ses.server $gettok(%b,2,32)

    if ($gettok(%b,3,32) != $chr(60) $+ blank $+ $chr(62)) set %ses.port $v1
    else set %ses.port $iif($server(%ses.server).port,6667)

    if ($gettok(%b,4,32) != $chr(60) $+ blank $+ $chr(62)) set %ses.pass $v1
    if ($gettok(%b,5,32) != $chr(60) $+ blank $+ $chr(62)) set %ses.nick $v1
    else set %ses.nick $readini($mircini,n,mirc,nick)

    if ($gettok(%b,6,32) != $chr(60) $+ blank $+ $chr(62)) set %ses.anick $v1
    else set %ses.anick $readini($mircini,n,mirc,anick)

    if ($gettok(%b,7,32) != $chr(60) $+ blank $+ $chr(62)) set %ses.email $v1
    else set %ses.email $readini($mircini,n,mirc,email)

    if ($gettok(%b,8-,32) != $chr(60) $+ blank $+ $chr(62)) set %ses.name $v1
    else set %ses.name $readini($mircini,n,mirc,user)

    set %ses.session %ses.server
    if (%ses.port) set %ses.session %ses.session %ses.port
    if (%ses.pass) set %ses.session %ses.session %ses.pass
    set %ses.session %ses.session $iif($+(%ses.nick,%ses.anick,%ses.email,%ses.name) != $null,-i %ses.nick %ses.anick %ses.email %ses.name)
    if (c isin %f) server %ses.session
    else {
      var %delay = $nvar(autoconnect.perdelay)
      if ((%delay) && (%delay isnum)) {
        server -n %ses.session
        ;    scon $scon(0) iecho -s Delayed connection for $duration(%delay) $+ .
        scon $scon(0) ntimer delayedconnect 1 $calc(%::loadsession.num * %delay) server
      }
      else server -m %ses.session
    }

    return 1
  }
  else if (!$isid) iecho No session information found for number $hc($1)
}
loadhpop _refpopup
movelogs {
  var %a = $1- , %b, %d
  unset %movelogs.*

  set %d $qt($nvar(movelogs.dir))

  if (($flags($1-,age)) || ($flags($1,a))) { 
    set -u %movelogs.age $iifelse($flags(%a,age).val,$flags(%a,a).val) 
    set %b $addtok(%b,Age > $+ $duration(%movelogs.age),44)
  }
  else {
    if ($nvar(movelogs.age)) set -u %movelogs.age $ifmatch

  }

  if (!$isdir(%d)) {
    iecho movelogs: invalid destination directory
    return
  } 

  if (!%movelogs.age) { iecho syntax: /movelogs -age <duration>  | return  }

  if ($flags($1-).text) {
    set -u %movelogs.match $ifmatch
    set %b Matching Files: $ifmatch
  }
  var %n = $findfile($logdir,*.log,0)
  iecho Moving $hc(%n) log file $+ $plural(%n) $+ ... %b
  .echo -q $findfile($logdir, *.log, 0, _mvlogs $1-  )

}

logclean {
  var %a = $1- , %b
  unset %logclean.*
  ;/logclean [-lines N] [-size N] [-age N] [
  if (($flags($1-,lines)) || ($flags($1,l))) { 
    set -u %logclean.minlines $iifelse($flags(%a,lines).val,$flags(%a,l).val) 
    set %b $addtok(%b,Lines <  $+ %logclean.minlines,44)
  }
  if (($flags($1-,size)) || ($flags($1,s))) { 
    set -u %logclean.size $iifelse($flags(%a,size).val,$flags(%a,s).val) 
    set %b $addtok(%b,Size < $+ $alof(%logclean.size),44) 
  }
  if (($flags($1-,age)) || ($flags($1,a))) { 
    set -u %logclean.age $iifelse($flags(%a,age).val,$flags(%a,a).val) 
    set %b $addtok(%b,Age > $+ $duration(%logclean.age),44)
  }

  ; what wa this going to be again?
  ; if (($flags($1-,file)) || ($flags($1,a))) { 
  ;  set -u %logclean.age $iifelse($flags(%a,age).val,$flags(%a,a).val) 
  ;  set %b $addtok(%b,Age > $+ $duration(%logclean.age),44)
  ; }

  if ($flags($1-).text) {
    set -u %logclean.match $ifmatch
    set %b Matching Files: $ifmatch
  }
  var %n = $findfile($logdir,*.log,0)
  iecho Cleansing $hc(%n) log file $+ $plural(%n) $+ ... %b
  if ($isfile($dd(whilefix.dll))) {
    iecho go go dll version
    dll $dd(WhileFix.dll) W_FindFile $logdir *.log -1 _logclean.dllsearch
  }
  else  .echo -q $findfile($logdir, *.log, 0, _logclean $1-)
}
favcon {
  if (!$istok(add del, $1, 32)) || ($0 < 2)  { theme.syntax /favcon <add|del> <network $| server [port] [network]>  | return }

  if ($1 == add)   nvar favoriteconnect $addtok($nvar(favoriteconnect),$tab($2, $3, $4),44)
  elseif ($1 == del)  nvar favoriteconnect $remtok($nvar(favoriteconnect),$tab($2, $3, $4),1,44)
}
favchan {
  if (!$istok(add del, $1, 32)) || ($0 < 2)  { theme.syntax /favchan <add|del> <#chan> | return }

  if (!$ini($mircini,chanfolder,0)) {
    if ($1 == add) { writeini -n $mircini chanfolder n0 $2 $+ $str($chr(44),3) $+ $qt($curnet(noserver)) | iecho Added $hc($2) to your favorites. }
    else { iecho Channel $hc($2) is not in your favorite list. | return }
  }
  else {  
    var %w = @_favoritechans.order
    window -hlek %w
    clear %w
    loadbuf -t $+ chanfolder %w $mircini

    var %f =  $fline(%w,$+(*=, $2, $chr(44), *), 1)

    if ($1 == add) {
      if (%f) { iecho Channel $hc($2) is already in your favorite list | return }
      aline %w n= $+ $2 $+ $str($chr(44),3) $+ $qt($curnet(noserver))

      iecho Added $hc($2) to your favorites.
    }
    elseif ($1 == del) {
      if (!%f) return    
      dline %w %f
    }

    remini $mircini chanfolder
    var %a = 1, %b
    while (%a <= $line(%w,0)) {
      set %b $gettok($line(%w,%a), 2-, 61)
      writeini -n $mircini chanfolder n $+ $calc(%a - 1) %b
      inc %a
    } 
    saveini
    window -c %w
  }

}

gquit  scid -at1 .quit $1-



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; INTERNAL COMMANDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(null) {
  ; compatability with linux systems running wine
  if ($1 == DESTROY) return
}

_online {

  if (!$server) {
    ; for some reason when you get killed under certain circumstances, none of the old timers turn off.. this will shut them off
    if ($timer($cid $+ .online)) .timer $+ $cid $+ .* off 
    return
  }

  if ($cid == $firstcon) {
    nvarinc pong
    if ($nvar(daychange) == on)  _datechange.echo
  }

  if ($networknum($curnet) == 1) ninc pong
  elseif ($iifelse($ncid(network.hash.num),1) == 1) ninc pong

  if ($nvar(clock) == on) clock
  if ($nvar(lagstat) == on) {
    if (!$modget(znc,multiconnected)) .ctcpreply $me lagstat $ticks
  }
  var %a = 1
  while (%a <= $chan(0)) {
    if (($me ison $chan(%a)) && (!$istok($nget(ialupd.ignore),$chan(%a),44)) && ($chan(%a).ial == $false) && ($calc($ctime - $ncid($tab(chan,$chan(%a),jointime))) <= 300) && (!$istok($ncid(joinwho),$chan(%a),44)) &&  (!$istok($ncid(updial),$chan(%a),44)) && ($nick($chan(%a),0) < $nvar(maxial))) {
      if ($chan(%a) != $modvar(away,idlechan)) { inc %a | continue }
      ncid joinwho $addtok($ncid(joinwho),$chan(%a),44)
      if ($nvar(queuedwho) == on) {
        if (!$hget($cidqueue(who))) initwhoqueue
        queuewho $chan(%a)
      }
      else .quote who $chan(%a)
    }
    inc %a
  }


  .signal -n ircn.online

  ; close idle queries
  if ($nvar(query.closeidle) == on) idlequeries


  ; clean expendable channel settings
  _clean.deadchans

  ; clean random nick colors
  _nickcolors.expire

  ; clean out cached whois's
  ._clean.whoiscache
  ;saves connections hashtable if its been loaded every %savetime min's
  if (($nget(nloaded)) && ($calc($ctime - $hget(ircN,lastsaved)) >=  $calc($iifelse(%savetime,5) * 60))) {

    nsave
    ncid.unused
    nsavekill.unused

  }

  ;clean out old settings tables from harddrive
  ; if (($nvar(netsettingsclean) != 0) && ($nvar(netsettingsclean) != $null)) {
  if (!$nvar(netsettingskeep)) {
    if ($calc($ctime - $nvar(netsettingsclean)) >= 86400) { _netclean }
  }
  ;}
  ;update networks servers list every 5days
  if ($calc($ctime - $nget(links)) >= 432000) {
    if ($nget(autoupdatelinks) != off) {
      if (($nvar(autoupdatelinks) == on) || ($nget(autoupdatelinks) == on)) { 
        iecho -s Updating server list for $curnet
        .ml
      }
    }
  }

}
_favjoin {
  var %a, %b
  if ($2) && ($curnet(noserver) != $2) {
    set %a $net2scid($2)

    if ((%a) && ($scid(%a).server)) set %b $$input(Would you like to join $1 on your current $2 connection?,y)
    if (%b) {
      scid %a .timer 1 1 join $1

    }
    else server -m $2 -j $1
  }
  else join $1
}
_recentserver {
  var %a = $remtok($nvar(recentservers), $tab($1, $2, $3), 1, 44)
  nvar recentservers $+($tab($1, $2, $3), $chr(44), $gettok(%a, 1-9, 44))
}
_recentnetwork {
  var %a = $remtok($nvar(recentnetworks), $1, 1, 44)
  nvar recentnetworks $+($1, $chr(44), $gettok(%a, 1-9, 44))
}
_recentwhois {
  var %a = $remtok($nget(recentwhois), $1, 1, 44)
  nset  recentwhois $+($1, $chr(44), $gettok(%a, 1-9, 44))
}
_recentquery {
  var %a = $remtok($nget(recentquery), $1, 1, 44)
  nset recentquery $+($1, $chr(44), $gettok(%a, 1-9, 44))
}
_recentnotice {
  var %a = $remtok($nget(recentnotice), $1, 1, 44)
  nset recentnotice $+($1, $chr(44), $gettok(%a, 1-9, 44))

}
_recentdccchat {
  var %a = $remtok($nget(recentdccchat), $1, 1, 44)
  nset recentdccchat $+($1, $chr(44), $gettok(%a, 1-9, 44))
}
_netauth.makenewusr {
  if ($0 < 2) return
  nset $tab(auth,$1, passwd) $2-

  if (!$nget($tab(auth,$1, authcmd)))  nset $tab(auth,$1, authcmd) /nickserv IDENTIFY <pass>
  if (!$nget($tab(auth,$1, ghostcmd)))  nset $tab(auth,$1, ghostcmd) /nickserv GHOST <username> <pass>  
  if (!$nget($tab(auth,$1, requestwc)))  nset $tab(auth,$1, requestwc)  *please choose a different nick*
  if (!$nget($tab(auth,$1, requestnick)))  nset $tab(auth,$1, requestnick) nickserv
  if (!$nget($tab(auth,$1, onconnect)))  nset $tab(auth,$1, onconnect) on
  if (!$nget($tab(auth,$1, onrequest)))  nset $tab(auth,$1, onrequest) on
}
_dccrelay.nick {
  if ($nget(dccrelay.nick)) return $ifmatch
  elseif ($nvar(dccrelay.nick)) return $ifmatch
  else return $false
}
_logclean {
  if ($cmdbox) return
  var %a, %b, %c, %t, %lines, %bytes, %age, %f, %z

  if ($logdirawaylog\ isin $nofile($1-)) return

  if (%logclean.match) {
    set %a 1 
    while ($gettok(%logclean.match,%a,32) != $null) {
      set %b $ifmatch
      if (%b iswm $nopath($1-)) inc %c
      if (%b iswm $remove($1-,$logdir)) inc %c
      inc %a
    }
    if (!%c) return
  }

  if ((%logclean.age isnum) || (%logclean.size isnum) || (%logclean.minlines isnum)) {
    if (%logclean.age) {
      if ($calc($ctime - $file($1-).mtime) >= %logclean.age) set %f $1- 
      else set %f
    }
    if (%logclean.size) {
      if ($file($1-).size < %logclean.size) { set %f $1- }
      else set %f
    }
    if (%logclean.minlines) {
      if ($lines($1-) < %logclean.minlines) { set %f $1-  }
      else set %f
    }
  }
  elseif (%c) set %f $1-
  ; if (%f)  .timer 1 1  remove -b " $+ $1- $+ "
  if (%f)  echo -sg .remove $1-
}

_mvlogs {
  if ($cmdbox) return
  var %a, %b, %c, %t, %lines, %bytes, %age, %f, %f2

  set %f $qt($1-)
  set %f2 $qt($nvar(movelogs.dir) $+ $nopath($1-))

  if ($logdirawaylog\ isin $nofile($1-)) return

  if (%movelogs.age isnum)  {
    if (%movelogs.age) {
      if ($calc($ctime - $file($1-).mtime) >= %movelogs.age) set %f $1- 
      else set %f
    }
  }

  if (%f) echo -s .timer 1 1 $iif(!$show,.) $+ rename %f %f2
}
_movesafe return $_copysafe($1, $2).removesilent
_copysafe {
  if (!$isid) return $false
  var %f1, %f2, %f1.crc, %f2.crc
  set %f1 $qt($1)
  set %f2 $qt($2)
  if (silent !isin $prop) iecho %f1 -> %f2
  if (!$isfile(%f1)) return $false

  if ((!$nopath(%f2)) && ($nofile(%f2))) set %f2 $nofile(%f2) $+ $nopath(%f1)
  if (!$nopath(%f2)) return $false



  set %f1.crc $crc(%f1)
  .copy -o %f1 %f2
  set %f2.crc $crc(%f2)

  if (%f1.crc == %f2.crc) {
    if (remove isin $prop)  .remove %f1
    return $true
  }
  if ($isfile(%f2)) .remove %f2

  return $false
}
_previewtext {

  if ($0 < 2) return

  ; [-flags], name, text
  var %flg, %txt, %name

  if (-* iswm $1) { set %flg $1 | set %name $2 | set %txt $3- }
  else { set %name $1  | set %txt $2- } 

  var %file = $td($+(textpreview-, %name, .bmp))
  if ($isfile(%file)) .remove %file

  var %fnt = $qt($window(*,1).font) 
  var %fntsz =  $window(*,1).fontsize
  var %height = $height(%txt,%fnt,%fntsz)
  var %width = $width(%txt,%fnt,%fntsz)

  iecho w; %width .. h: %height

  var %x = @_text.preview. $+ %name

  if ($window(%x))  window -c %x
  window -Bpw0 +d %x 1 1 $iifelse(%width,500) $iifelse(%height,25)



  drawtext -pc %x $colour(say) %fnt %fntsz 1 1 $iifelse(%width,500) $iifelse(%height,25) $2-


  drawsave %x %file
  ; window -c %x

  return +OK %file

}
_inflatewin {
  var %a = 1, %b, %c = $active
  set %c $iif($numtok(%c,32) > 1, $qt(%c), %c)
  var %w =  $window(-3).dw $window(-3).dh
  while ($window(*,%a) != $null) {
    set %b $window(*,%a)
    set %b $iif($numtok(%b,32) > 1, $qt(%b), %b)
    if ($window(*,%a).type != picture) {
      window -r %b 0 0 %w
    }
    inc %a
  }
  window -ra %c 0 0 %w

}
_iecho.cmd {
  ;/iecho [-c N -w @window -t -l -s]
  ;-c [color]
  ;-w @window
  ;-L "word:/command" - highlight dclick word
  ;-t .. timestamp
  ;-l .. log
  ;-s .. status

  var %b = t l s a g
  var %t = $flags($1-,_,%b).text
  var %flg_c, %flg_w, %flg_t, %flg_l, %flg_s, %flg_a, %flg_g, %flg_Lnk

  if ($flags($1-,c,%b)) set %flg_c $flags($1-,c,%b).val
  if ($flags($1-,w,%b)) set %flg_w $flags($1-,w,%b).val
  if ($flags($1-,L,%b)) {
    set %flg_Lnk $flags($1-,L,%b).val

    var %q = 1
    var %st = $strip(%t)

    if ($numtok(%flg_lnk,8) > 1) {
      var %lname = $gettok(%flg_Lnk,1,8)
      if (%lname) {
        set %flg_Lnk $gettok(%flg_Lnk,2-,8)
      }
    }

    while ($gettok(%flg_Lnk,%q,9) != $null) {

      var %lnk = $gettok(%flg_Lnk,%q,9)

      var %lword =  $gettok(%lnk,1,58)
      var %lcmd =  $gettok(%lnk,2-,58)

      ncid linktext. $+ $hash(%st,32) $+ .string %st
      ncid linktext. $+ $hash(%st,32) $+ .timestamp $ctime
      ncid linktext. $+ $hash(%st,32) $+ .linkword %lword
      ncid linktext. $+ $hash(%st,32) $+ .linkcmd %lcmd
      if (%lname) ncid linktext. $+ $hash(%st,32) $+ .name %lname

      ;maybe i'll allow highlight clicking for entire /iechos at some point.. this isnt working now so dont uncomment
      ;    if (%lword == *) {
      ;      set %t  $+ $hc $+  $+ %t $+ 
      ;      break
      ;    }
      ;    else 

      set %t $replacecs(%t, %lword,  $+ $hc $+  $+ %lword $+ )
      inc %q
    }

  }
  if ($flags($1-,t,%b)) set %flg_t 1
  if ($flags($1-,l,%b)) set %flg_l 1
  if ($flags($1-,s,%b)) set %flg_s 1
  if ($flags($1-,a,%b)) set %flg_a 1
  if ($flags($1-,g,%b)) set %flg_g 1

  if ($nvar(logiecho)) set %flg_l 1
  if ($nvar(timestampiecho)) set %flg_t 1
  if ($nvar(show.iecho) == status) set %flg_s 1

  if ((!%flg_w) && (($cid != $activecid) || (@* iswm $active))) return $iif(%flg_g,scid -a) echo $iif(%flg_c isnum 0-15,%flg_c) -s $+ $iif(%flg_t,t) $+ $iif(!%flg_l,g) $+ i2 $chr(231) %t
  elseif (%flg_w) return echo $iif(%flg_c isnum 0-15,%flg_c) - $+ $iif(%flg_t,t) $+ $iif(!%flg_l,g) $+ i2 %flg_w $chr(231) %t
  elseif ((%flg_a) || (%flg_s)) return  $iif(%flg_g,scid -a) echo $iif(%flg_c isnum 0-15,%flg_c) - $+ $iif(!%flg_l,g) $+ $iif(%flg_t,t) $+ $iif(%flg_s,s,a) $+ i2 $chr(231) %t
  else return  $iif(%flg_g,scid -a) echo $iif(%flg_c isnum 0-15,%flg_c) $iif($nvar(iechostatus),-s,-a) $+ $iif(%flg_t,t) $+ $iif(!%flg_l,g) $+ i2 $chr(231) %t
}
_iecho.linkcleanbyname {
  if (!$0) return

  var %a = 1
  var %b 
  var %c, %d

  var %results
  while ($hfind($ncid,linktext.*.name,%a,w) != $null) {
    var %c = $hfind($ncid,linktext.*.name,%a,w)
    var %d = $ncid(%c)

    if (%c) {
      if (%d == $1-) set %results $addtok(%results, $gettok(%c,2,46), 44)
    }

    inc %a
  }

  var %a = 1, %b
  while ($gettok(%results, %a, 44)) {
    set %b $ifmatch
    hdel -w $ncid linktext. $+ %b $+ .*
    inc %a
  }

}
_silencehelp {
  theme.syntax $hc(/silence) [+/-]nick!name@host.host.dom (nick or host alone allowed)
  iiecho -a -t $hc(/silence) $+ : Ignores a nickname or hostmask on the servers side. 
}
_refreshcolorgfx {
  if (!$isdir($td(colors\))) .mkdir $td(colors\)
  var %a = 0

  if (!$isfile($td(colors\blank.bmp))) {
    window -ph +d @color.blank -1 -1 16 16
    drawfill @color.blank 0 0 0 0
    var %q = 1
    while (%q <= 30) { drawline -nr @color.blank 12566463 2 0 %q %q 0 |  inc %q 5  } 
    drawdot @color.blank
    drawsave @color.blank $td(colors\blank.bmp)  
  }
  var %col = $ntmp(_cache.colors)
  ntmp _cache.colors
  while (%a <= 15) {
    if ($color(%a) != $gettok(%col,$pls(%a,1),32)) {
      window -ph +d @color. $+ %a -1 -1 16 16
      drawfill @color. $+ %a %a %a 0 0
      drawsave @color. $+ %a $td(colors\ $+ $base(%a,10,10,2) $+ .bmp)
      drawtext -r @color. $+ %a $iif($color(%a) == 0,16777215,0) "Fixedsys" 12 $iif(%a > 9,0,4) 1 %a
      drawsave @color. $+ %a $td(colors\ $+ $base(%a,10,10,2) $+ txt.bmp)
    }
    ntmp _cache.colors $addtok($ntmp(_cache.colors),$color(%a),32)
    inc %a
  }
  close -@ @color.*
}
_popup.usertimezone {
  if (!$1) return
  ; have to add something so it doesnt use $daylight depending on their location..
  var %a = $iif($2 isnum,$2,$ulinfo($1,note.timezone)), %b = -
  var %c = $iif($3-,$3-,hh $+ $chr(58) $+ nntt ddd)
  var %d
  var %h, %m
  if ($left(%a,1) == +) set %b +
  set %a $remove(%a,+,-)
  set %h $gettok(%a,1,46)
  set %m $gettok(%a,2,46)
  if (%a == 00) return $asctime($calc($gmt + $daylight), %c ) $iif(!$2,$paren(UTC))
  return $asctime($calc( $gmt %b (%h *3600) + $iif(%m,(%m * 60)) + $daylight), %c ) $iif(!$3,$paren(UTC %b $+ %a))

}
_cache.netsupport  {
  ntmp _cache.netsupport.networks 
  ntmp _cache.netsupport.ircds
  .echo -q $findfile($netdir, *.nwrk, 0, _cache.netsupport.netadd $1-  )
  .echo -q $findfile($ircddir, *.ircd, 0, _cache.netsupport.ircdadd $1-  )
}
_cache.netsupport.netadd  ntmp _cache.netsupport.networks $addtok($ntmp(_cache.netsupport.networks),  $deltok($nopath($1-),-1,46), 44)
_cache.netsupport.ircdadd  ntmp _cache.netsupport.ircds $addtok($ntmp(_cache.netsupport.ircds), $deltok($nopath($1-),-1,46), 44)
_rawlog.cb {
  var %a
  if ($nvar(rawlog.timestamp) == on) set %a $asctime([hh:nn:sstt])
  return %a $1-
}
_ll.results {
  var %a = 1, %f = $srvfile
  var %f2 = $tp($curnet $+ .sll)
  var %c = 0
  var %w = @LinkLooker. $+ $curnet $+ . $+ $cid

  if (!$lines(%f)) return
  if (!$lines(%f2)) return

  var %l = $lines(%f)

  while (%a <= %l) {
    var %srv = $gettok($read(%f, n, %a),1,32)
    if (!%srv) { inc %a | continue }

    if (!$read(%f2, nw, %srv)) { 

      if (!$window(%w))   window -ka %w $window(*,1).font $window(*,1).fontsize
      if (!%c) { 
        aline %w . $+ $str(-,45) $+ .
        aline %w $vl Split servers from $fix(24,$hc($server)) $vl
        aline %w $vl $+ $str(-,45) $+ $vl
      }
      aline %w $vl $str( ,5) $lfix(2,$calc(%c + 1)) $+ . $fix(33,$sc(%srv)) $vl

      inc %c
    }

    inc %a
  }
  if ($window(%w))  aline %w ' $+ $str(-,45) $+ '

  if (!%c) iecho -s No split servers were found.
  else iecho -s This network has $hc(%c) server $+ $plural(%c) disconnected. 
}

_movemodfiles {
  if ($cmdbox) return
  var %binfiles = $modinfo($1-,binfiles)
  var %dllfiles = $modinfo($1-,dllfiles)

  if (%binfiles) {
    var %a = 1, %q
    while ($gettok(%binfiles,%a,44) != $null) {
      var %bf = $md($ifmatch)
      var %bf2 = $bd($nopath(%bf))


      if ($isfile(%bf)) {

        if ($isfile(%bf2)) {
          if ($file(%bf2).mtime <= $file(%bf).mtime) { .remove %bf | inc %a | continue }
        }
        set %q $_movesafe(%bf, %bf2) 
        writeini $bd(filedescriptions.ini) $nopath(%bf) $remove($nopath($1-),.mod) The module ' $+ $nopath($1-) $+ ' installed this binary. If you no longer use the module you may delete the binary, though you will have to redownload the module and binary to use it again.
      }


      inc %a
    }
  }

  if (%dllfiles) {
    var %a = 1, %q
    while ($gettok(%dllfiles,%a,44) != $null) {
      var %df = $md($ifmatch)
      var %df2 = $dd($nopath(%bf))

      if ($istok(dcx.dll mtooltips.dll, $nopath(%df2), 32)) { inc %a  | continue } 
      if ($isfile(%df)) {
        if ($isfile(%df2)) {
          if ($dll(%df2)) .dll -u %df2
          if ($file(%df2).mtime <= $file(%df).mtime) { .remove %df | inc %a | continue }
        }
        set %q $_movesafe(%df, %df2) 
        writeini $dd(filedescriptions.ini) $nopath(%df) $remove($nopath($1-),.mod) The module ' $+ $nopath($1-) $+ ' installed this dll. If you no longer use the module(s) dependant on it you may delete the dll, though you will have to redownload the module and dll to use it again.

      }
      inc %a
    }
  }

}
_loadmod {
  if (!$istok(load reload,$1,32)) return

  if (!$isfile($qt($2-))) return

  if (!$modinfo($qt($2-),script1)) && (!$modinfo($qt($2-),alias1)) return

  _movemodfiles $qt($2-)

  _loadmodfiles $iif($1 == reload,reload,load) $qt($2-)

  if ($result) {
    var %q = $ifmatch
    _readpopups $qt($2-)
    nvar modules $addtok($nvar(modules),$nopath($2-),44)
    if ($show) { 
      iecho $iif($1 == reload,Reloaded,Loaded) module $noext($nopath($2-)) $iif($_adddep($2-),$paren(dep: $ifmatch))
    }
  }
  ircnsave    
}
_loadmodfiles {
  var %a, %z, %b, %c, %success
  set %a 1
  set %z $ini($2-,module,0)
  while (%a <= %z) {
    set %b $readini($2-,n,module,script [ $+ [ %a ] ] )
    set %c $readini($2-,n,module,alias [ $+ [ %a ] ] )
    if (%b) {
      if ($script($nopath(%b))) {
        if ($1 == reload) {  .reload -rs $md(%b) | inc %success }
        elseif (!$ismod($nopath($2-))) inc %success
      }
      elseif ((!$script($md(%b))) && ($isfile($md(%b)))) { .load -rs $md(%b) | inc %success } 
      elseif (!$script($md(%b))) {
        if ($show) iecho Error: Unable to load script file ' $+ %b $+ ' from the module $nopath($1-)
        return
      }
    }
    if (%c) {
      if ($alias($nopath(%c))) { 
        .reload -as $md(%c) 
        inc %success
      }
      elseif ((!$alias($md(%c))) && ($isfile($md(%c)))) { .load -as $md(%c)  | inc %success }
      elseif (!$alias($md(%b))) {
        if ($show) iecho Error: Unable to load alias file ' $+ %c $+ ' from the module $nopath($1-)
        return
      }
    }
    inc %a
  }
  return %success
}
_unloadmodfiles {
  var %a, %z, %b, %c
  set %a 1
  set %z $ini($1-,module,0)
  while (%a <= %z) {
    set %b $readini($1-,module,script [ $+ [ %a ] ] )
    set %c $readini($1-,module,alias [ $+ [ %a ] ] )
    if (%b) {
      if ($script($md(%b))) .unload -rs $md(%b)
      elseif ($script(%b)) .unload -rs %b
    }
    if (%c) {
      if ($script($md(%c))) .unload -as $md(%c)
      elseif ($isfile(%c)) .unload -as %c
    }
    inc %a
  }
}
_adddep {
  ;loads the dependencies in a file
  ;ex: /adddep <script> or iecho Loaded the dependencies: $_adddep(script.mrc)
  var %a = 1, %z, %b, %c, %d
  set %b $modinfo($1-,depmod)
  while ($gettok(%b,%a,32) != $null) {
    set %c $remove($ifmatch,.mod) $+ .mod
    if (!$ismod(%c)) {
      if ($isfile($md(%c))) {
        set %d $addtok(%d,$nopath(%c),44)
        .timer 1 1 .module %c
      }
      else iecho Module $hc($nopath($1-)) has a dependency to %c but it cannot be found
    }
    inc %a
  }
  return %d
}
; reloads files in modules if they got unloaded
_chkmods {
  var %a = 1, %b
  while ($gettok($nvar(modules),%a,44) != $null) {
    set %b $ifmatch
    _loadmodfiles $iif($1 == reload,reload,load) $md(%b)
    inc %a
  }
}
_refpopup {
  if ($hget(popups)) hfree popups

  hmake popups 8
  var %a = $whilearray($nvar(modules), 44, _readpopups, md)
}
_addpopup {
  if (!$hget(popups)) hmake popups 8
  if ($4-) hadd popups $tab($1, $2, $3) $4-
  else _delpopup $1 $2 $3
}
_delpopup {
  if (!$hget(popups)) return
  hdel popups $tab($1, $2, $3)
}
_readpopups {
  var %a = 1, %b,%m,%s,%i,%v
  while (%a <= $ini($1-,0)) {
    set %b $ini($1-,%a)
    if (popup.* iswm %b) {
      set %m $gettok(%b,2,46)
      set %s $gettok(%b,3-,46)
      var %z = 1
      while (%z <= $ini($1-,%b,0)) {
        set %i $ini($1-,%b,%z)
        set %v $readini($1-,n,%b,%i)
        if (($istok(channel.menu.nicklist.query.status,%m,46)) && (%s) && (%i)) {
          _addpopup %m %s %i %v
        }
        inc %z
      }
    }
    inc %a
  }
}
_delpopups {
  var %a = 1, %b,%m,%s,%i,%v
  while (%a <= $ini($1-,0)) {
    set %b $ini($1-,%a)
    if (popup.* iswm %b) {
      set %m $gettok(%b,2,46)
      set %s $gettok(%b,3-,46)
      var %z = 1
      while (%z <= $ini($1-,%b,0)) {
        set %i $ini($1-,%b,%z)
        if (($_getpop(%m,%s,%i)) && ($istok(channel.menu.nicklist.query.status,%m,46)) && (%s) && (%i)) {
          _delpopup %m %s %i
        }
        inc %z
      }
    }
    inc %a
  }
}
_list.sort {
  if (!$window($1)) return
  var %w = $+($1,_sorted)
  if (!$window(%w)) window -hls %w

  ; -f file
  ; -w window
  ; -n numeric sort (-u)
  ; ignore case
  ; (might not be nescsary) -e descending 
  ; only matching wildcard, or only matching regex
  ; -x exclude match, or -X exclude only match on the col
  ; <col> <separator>

  ; set -u0 %::filtersort.caseinsensitive 1

  filter -wwca $1 %w _filtersort *

  if (%flg_exclude) {
    var %w2 = $+($1,_sortedexcl)
    if (!$window(%w2))  window -hls %w2
    filter -wwct %w %w2 %flg_excludestr
    close -@ %w
    renwin %w2 %w
  }
}
_list.unique {
  if (!$window($1)) return
  var %w = $+($1,_unique)
  if (!$window(%w))  window -hl %w

  ; -f file
  ; -w window
  ; -n numeric sort (-u)
  ; -i case insensitive (not going to work unless i can make the _sort allow case insensitive sorting)
  ; match col only
  ; <col> <separator>

  _list.sort $1

  if (!$window($1 $+ _sorted)) return
  filter -wwc $+($1,_sorted) %w *
  close -@ $+($1,_sorted)

  var %a = 1, %b, %c, %d
  while (%a <= $line(%w, 0) ) {
    set %b $line(%w,%a)
    set %c $line(%w, $calc(%a + 1))
    set %d $iif(%a > 1, $line(%w, $calc(%a - 1)))
    ; if they specify an option for only checking the col/sep  , otherwise whole line
    if (%flg_matchcol) {

    }
    else {
      ; echo -sg -- does %b === %c (ln %a == ln $calc(%a + 1)) $iif(%b === %c, yes, no)
      ;  if (%a > 1)  echo -sg -- does %b === %d (ln %a == ln $calc(%a - 1)) $iif(%b === %d, yes, no)
      ; if only show repeated lines ( need to fix this so it doesnt show dupes)
      ; if (%b !== %c) { dline %w $calc(%a + 1) | dec %a }

      if (%b $iif(%flg_casesen,===,==) %c) { 
        dline %w $calc(%a + 1)
        dec %a 
      }
      if (%b $iif(%flg_casesen,===,==) %d) {
        dline %w %a
        dec %a 
      }
    }
    inc %a
  }

  return %w $line(%w,0)
}
_encryptt {
  if ($2- == $null) return
  bunset &crypt.y &crypt.z
  var %a, %z
  set %z $1
  set %a $len($2-)
  while (%a > 0) {
    set %z $hash(%z,32)
    bset -t &crypt.z $calc($bvar(&crypt.z,0) + 1) %z
    dec %a $len(%z)
  }
  bset -t &crypt.z $calc($bvar(&crypt.z,0) + 1) %z
  bset -t &crypt.y 1 $2-
  set %a 1
  while ($bvar(&crypt.y,%a) != $null) {
    bset &crypt.y %a $calc($ifmatch + ($bvar(&crypt.z,%a) - 48))
    inc %a
  }
  return $bvar(&crypt.y,1-).text
}
_decryptt {
  if ($2- == $null) return
  bunset &crypt.y &crypt.z
  var %a, %z
  set %z $1
  set %a $len($2-)
  while (%a > 0) {
    set %z $hash(%z,32)
    bset -t &crypt.z $calc($bvar(&crypt.z,0) + 1) %z
    dec %a $len(%z)
  }
  bset -t &crypt.z $calc($bvar(&crypt.z,0) + 1) %z
  bset -t &crypt.y 1 $2-
  set %a 1
  while ($bvar(&crypt.y,%a) != $null) {
    bset &crypt.y %a $calc($ifmatch - ($bvar(&crypt.z,%a) - 48))
    inc %a
  }
  return $bvar(&crypt.y,1-).text
}
_encryptf {
  if ($1 == $null) return $false
  bunset &crypt.tmp
  var %a, %z
  set %z $1
  set %a $bvar(&crypt.data,0)
  while (%a > 0) {
    set %z $hash(%z,32)
    bset -t &crypt.tmp $calc($bvar(&crypt.tmp,0) + 1) %z
    dec %a $len(%z)
  }
  if ($bvar(&crypt.data,0) < 4096) bset -t &crypt.tmp $calc($bvar(&crypt.tmp,0) + 1) %z
  set %a 1
  while ($bvar(&crypt.data,%a) != $null) {
    bset &crypt.data %a $calc(($ifmatch + $bvar(&crypt.tmp,%a) - 48 + 256) % 256)
    inc %a
  }
  return $true
}
_decryptf {
  if ($1 == $null) return $false
  bunset &crypt.tmp
  var %a, %z
  set %z $1
  set %a $bvar(&crypt.data,0)
  while (%a > 0) {
    set %z $hash(%z,32)
    bset -t &crypt.tmp $calc($bvar(&crypt.tmp,0) + 1) %z
    dec %a $len(%z)
  }
  if ($bvar(&crypt.data,0) < 4096) bset -t &crypt.tmp $calc($bvar(&crypt.tmp,0) + 1) %z
  set %a 1
  while ($bvar(&crypt.data,%a) != $null) {
    bset &crypt.data %a $calc(($ifmatch - $bvar(&crypt.tmp,%a) + 48 + 256) % 256)
    inc %a
  }
  return $true
}

_fencrypt {
  if ($isfile($3)) {
    if ($show) iecho FENCRYPT ERROR: Output file $hc($3) already exists!
    return
  }
  if ($isfile($2) != $true) {
    if ($show) iecho FENCRYPT ERROR: $hc($2) is not a valid file!
    return
  }
  write -c $3
  var %a = 0
  while (%a < $file($2).size) {
    bread $2 %a 4096 &crypt.data
    if ($_encryptf($1) != $true) {
      iecho FENCRYPT ERROR: Encryption failed!
      return
    }
    bwrite $3 %a -1 &crypt.data
    inc %a $bvar(&crypt.data,0)
  }
  if ($show) iecho Encrypted file $hc($2) and saved as $hc($3)
}
_fdecrypt {
  if ($0 < 3) {
    if ($show) iecho Syntax: /fdecrypt <password> <input filename> <output filename>
    return
  }
  if ($isfile($3)) {
    if ($show) iecho FDECRYPT ERROR: Output file already exists!
    return
  }
  if ($isfile($2) != $true) {
    if ($show) iecho FDECRYPT ERROR: $hc($2) is not a valid file!
    return
  }
  write -c $3
  var %a = 0
  while (%a < $file($2).size) {
    bread $2 %a 4096 &crypt.data
    if ($_decryptf($1) != $true) {
      iecho FDECRYPT ERROR: Decryption failed!
      return
    }
    bwrite $3 -1 -1 &crypt.data
    inc %a $bvar(&crypt.data,0)
  }
  if ($show) iecho Decrypted file $hc($2) and saved as $hc($3)
}
_datechange.echo {
  ;chan
  var %a, %b = $asctime(ddmmyyyy), %c = $ntmp(lastdatechange)
  if (!%c) goto end
  var %e =  The date is now $hc($asctime(dddd mmmm doo $+ $chr(44) yyyy))
  var %q = 1
  while ($scon(%q) != $null) {
    scon %q
    if (%b != %c) {
      set %a 1
      while ($chan(%a) != $null) {
        if ($me ison $chan(%a)) {
          if ($nvar(daychange.onlyactive) == on) {
            if ($chan(%a).idle <= 300) && ($nick(%a,0) <= 1)  iecho -l -t -w $chan(%a) %e
          }
          else  iecho -l -t -w $chan(%a) %e
        }
        inc %a
      }
      if ($nvar(daychange.notquery) != on) {
        set %a 1
        while ($query(%a) != $null) {
          if ($nvar(daychange.onlyactive) == on) {
            if ($query(%a).idle <= 300) iecho -l -t -w $query(%a) %e
          }
          else  iecho -l -t -w $query(%a) %e
          inc %a
        }
      }
    }
    inc %q
  }
  scon -r
  :end
  ntmp lastdatechange %b
}
_refresh.notify.lastseen {
  var %a = 1, %b
  ncid -r notify.notonline 

  while ($hfind($nget,notify.*.lastseen,%a,w) != $null) {
    set %b $gettok($ifmatch,2,46)
    if ($notify(%b)) {
      if (!$notify(%b).ison) && (%b != $me) {
        ncid notify.notonline $addtok($ncid(notify.notonline),%b,44)
        ncid notify.online $remtok($ncid(notify.online),%b,1,44)
      }
    }
    else {
      ndel notify. $+ %b $+ .lastseen
      ncid notify.online $remtok($ncid(notify.online),%b,1,44)
    }
    inc %a
  }  
}
_notify.noneonline {
  ncid notify.notonline $notifynotonline(nicks)
  ncid -r notify.online  
}
_addsrv.httpdone {
  if ($3 != 0) { iecho Unable to download servers.ini from http://mirc.co.uk/servers.ini | return }
  if ($2 == 1) .unmod http
  addsrv $iif($1,prune) $4-
}
_logclean.dllsearch {
  if ($1 == WF_SEARCH) && ($3-) echo -ag _logclean $3-
}
_ircop.perform {
  if (!$network) return
  var %a = 1, %b, %c,  %f = $sd(ircop-perform.ini)
  while (%a <= $ini(%f,$network,0)) {
    set %b $ini(%f,$network,%a)
    set %c $readini(%f, p, $network, %b)
    %c 
    inc %a
  }
}
_chanlist.filter {
  !tokenize 32 $1-
  if ($1 != 1) {
    if ($0 < 2) return
    !tokenize 32 $2-
    var %w = @ChannelList. $+ $cid
    !aline %w $tab($1, $2, $3) $4-
    ; !titlebar %w Channel Listing $paren($calc($line( %w ,0,1) - 1)  $+ / $+  $ncid(chanfilter.size) ,[,])
  }
}
_mknetworklist {

  var %a = 1, %b, %c

  ndel -w serverlist.* 
  var %w = $cidwin(mkserverlist)
  if ($window(%w)) clear %w
  else window -hl %w

  while (%a <= $server(0)) {
    var %g = $server(%a).group
    if (%g) {
      if (%g == $curnet(noserver)) { inc %c | aline %w $server(%a) }
    }
    inc %a
  }

  if (%c) {
    _list.unique %w

    set %a 1
    while ($line($+(%w,_unique),%a) != $null) {
      set %b $ifmatch
      nset serverlist. $+ $calc(%a - 1) %b
      inc %a
    }
    close -@ $+(%w,_unique)
  }
  close -@ %w

  nset networklistcache $ctime
}
_fkeys.findcmd {
  var %a = 1, %b, %c
  while ($hfind(ircN,fkey.*,%a,w) != $null) {
    set %b $ifmatch
    set %c $hget(ircN,%b)
    if (%c == $1-) return $upper($gettok(%b,2-,46))
    inc %a
  }

}
_fkeys.default {
  _fkey.addperm f1 help
  _fkey.addperm f2 setup
  _fkey.addperm f3 editbox -ap $ $+ ncomp($ $+ chancid( $chr(35) $+ ,lsnick))
  _fkey.addperm f5 .nxt_refresh -nu $chr(124) t
  _fkey.addperm cF9 close -c
  _fkey.addperm cF10 close -s
  ; _fkey.addperm sf1 dos
  ; _fkey.addperm sf2 run explorer.exe
  ; _fkey.addperm sf10 wholeft
  ; make this situational
}
_fkey.addperm {
  nvar fkey. $+ $1
  if ($2-) { 
    if ($1 == F11)    $iif($2 == fullscreen, .disable, .enable) #ircN_F11Key

    _fkey.enqueue perm~ $+ $2- $+ ~ $+ $1 
    ._fkey.assign 

  }
}
_fkey.inuse { 
  if ($nvar(fkey. $+ $1)) return $true
  if ($nget(fkey. $+ $1)) return $true
  return $false
}
_fkey.example {
  _fkey.enqueue choose command 1~iecho You chose command 1~F9
  _fkey.enqueue choose command 2~iecho You chose command 2~F10
  _fkey.enqueue choose command 3~iecho You chose command 3
  _fkey.assign 15

  iecho Press $_fkey.bind(iecho one,15,F11) for choice one or $_fkey.bind(iecho two,15,f12) for choice two
}
_fkey.enqueue {
  var %y
  set %y 1

  while ($nget($+(fkeyset.description.,%y)) != $null) { inc %y }
  ncid fkeyset.description. $+ %y $gettok($1-,1,126)
  ncid fkeyset.command. $+ %y $gettok($1-,2,126)
  ncid fkeyset.preferred. $+ %y $gettok($1-,3,126)
  ncid fkeyset.echoflag. $+ %y $gettok($1-,4-,126)

}
_fkey.assign {
  var %x, %fkeys, %cur, %time, %description, %command, %preferred, %echo, %echoflag, %y
  set %time $1
  set %y 1
  while ($ncid($+(fkeyset.description.,%y)) != $null) {
    set %description $ncid(fkeyset.description. [ $+ [ %y ] ])
    set %command $ncid(fkeyset.command. [ $+ [ %y ] ])
    set %preferred $ncid(fkeyset.preferred. [ $+ [ %y ] ])
    set %echoflag $ncid(fkeyset.echoflag. [ $+ [ %y ] ])

    if ((%preferred) && (!$_fkey.inuse(%preferred))) set %cur %preferred
    elseif (%preferred) set %fkeys $fkeys(preferred)
    else set %fkeys $fkeys(normal)
    if (%cur == $null) {
      if (%preferred) set %x $findtok(%fkeys,%preferred,1,44)
      else set %x 1
      var %a, %z
      set %a %x
      while (1) {
        set %z $gettok(%fkeys,%a,44)
        if (!$_fkey.inuse(%z)) break
        inc %a
        if (%a > $numtok(%fkeys,44)) set %a 1
        if (%a == %x) {
          iecho $ac(WARNING) $+ ! All function keys full!
          return
        }
      }
      set %cur $upper(%z)
    }

    if (!%cur) {   iecho -c 04 -s fkey error: cur blank | return }
    ; %cur is blank

    if (%echo) set %echo %echo $+ , $hc(%cur) to %description
    else set %echo Press $hc(%cur) to %description
    if (%time > 0) nset -u [ $+ [ %time ] ] fkey. [ $+ [ %cur ] ] %command
    else  nvar fkey. $+ %cur %command 
    set %cur
    inc %y
  }
  if ($show) iecho %echoflag %echo $iif(%time,within the next %time seconds)
  ncid -r fkeyset.*
}
_fkey.bind {
  if (!$isid) {
    iecho Syntax: $!_fkey.bind(command,[delay],[fkey]) - returns the function key bound
    return
  }
  if ($0 < 1) return $null
  var %x, %fkeys, %cur, %time, %preferred, %echo, %echoflag, %y
  if ($0 == 3) {
    if ($2 isnum) {
      set %time $2
      set %preferred $3
    }
    else {
      set %time $3
      set %preferred $2
    }
  }
  elseif ($0 == 2) {
    if ($2 isnum) set %time $2
    else set %preferred $2
  }

  if ((%preferred) && (!$_fkey.inuse(%preferred))) set %cur %preferred
  elseif (%preferred) set %fkeys $fkeys(preferred)
  else set %fkeys $fkeys(normal)
  if (%cur == $null) {
    if (%preferred) set %x $findtok(%fkeys,%preferred,1,44)
    else set %x 1
    var %a, %z
    set %a %x
    while (1) {
      set %z $gettok(%fkeys,%a,44)
      if (!$_fkey.inuse(%z)) break
      inc %a
      if (%a > $numtok(%fkeys,44)) set %a 1
      if (%a == %x) {
        iecho $ac(WARNING) $+ ! All function keys full!
        return
      }
    }
    set %cur %z
  }
  if ($nget) nset $iif(%time,-u $+ %time) fkey. $+ %cur $1
  else nvar $iif(%time,-u $+ %time) fkey. $+ %cur $1

  return %cur
}
_fkey.avail {
  var %a, %b, %y, %z
  set %z $fkeys(normal)
  set %b 0
  set %a 1
  while ($gettok(%z,%a,44) != $null) {
    set %y $ifmatch
    if (!$_fkey.inuse(%y)) inc %b
    inc %a
  }
  return %b
}
_fkey.do { 
  if (($istok($fkeys(normal),$1,44)) && ($nvar(fkey. $+ $1))) .timer 1 0 $nvar(fkey. $+ $1)
  elseif (($istok($fkeys(normal),$1,44)) && ($nget(fkey. $+ $1))) .timer 1 0 $nget(fkey. $+ $1)
}
_fkey.reset {
  var %fkeys = $fkeys(normal), %a, %z
  set %a 1
  while ($gettok(%fkeys,%a,44) != $null) {
    set %z $ifmatch
    if ($nget(fkey. $+ %z) != $null) ndel fkey. $+ %z
    inc %a
  }
}


; ################################################################
; ####################### IRCN SCRIPT FILE #######################
; ########## END OF FILE. DO NOT REMOVE OR MODIFY BELOW ##########
; ################################################################
