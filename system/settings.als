crash.recover {

  ; var %tmp = $calc($lines($sd(ircNtimed.bak)) - $lines($sd(ircn.ini)))

  ;load the timed nsave rather than the onquit one incase of crash dataloss
  ; iecho Warning! ircN is attempting to recover lost data from the last crash... (restoring %tmp settings)

  var %warn = ircN is attempting to recover lost data from the last crash... restoring %tmp settings
  if ($nvar(crash.suppressdlg) != on) {
    if (!$alias(identfrs.als)) .load -a identfrs.als
    var %err = $infobox(ircnmaint.crashrec, Warning:, 10, %warn )
  }
  else iecho Warning: %warn


  .copy -o $sd(ircNtimed.bak) $sd(ircN.ini)

  if (!$hget(ircN))  hmake ircN $iif($lines($sd(ircn.ini)) > 16, $int($lines($sd(ircN.ini))), 32)
  if ($isfile($sd(ircN.ini))) hload -i ircN $sd(ircN.ini) ircN


  if ($1 != nodefault)  default.setup


  if (($ismod(userlist)) && ($isalias(loaduserlist))) {
    .loaduserlist
    .loadbanlist
  }

  ; if ($1 != nodefault)  default.reload

  .timer 1 3 ircnsave
}
crash.check {
  ; dont dot his check no older versions of ircn (like if they just upgraded, obviously %testcrash wont be set)
  if ($left($nvar(oldver),4) < 2010) return

  ;make sure to check reldate, because %testcrash gets set on exit.. but it wouldnt be set if they upgraded from older versions
  ; will this work if all their remote files are loaded? since /default.setup doesnt trigger on start events when it reloads maintain the files.. 

  if (!%testcrash) {
    var %warn = ircN seems to have crashed or was shutdown improperly last restart.
    if ($nvar(crash.suppressdlg) != on) {
      if (!$script(maintain.mrc)) .load -rs maintain.mrc
      var %err = $infobox(ircnmaint.crashcheck, Warning:, 6, %warn )
    }
    else iecho Warning: %warn

    if ($lines($sd(ircNtimed.bak))) && ($lines($sd(ircn.ini))) {
      var %tmp = $calc($lines($sd(ircNtimed.bak)) - $lines($sd(ircn.ini)))
      if (%tmp >= 10) {  crash.recover $1 | unset %testcrash | return %tmp }
    }

  }
  unset %testcrash
}
default.reload default.setup reload
default.setup {
  var %a,%b,%c
  set %a 1
  set %dir $deltok($shortfn($nofile($mircexe)),-1,92) $+ \

  if ($show) {
    $iif($isalias(iecho), iecho -s, echo -sg 01[12N01]) Loading necessary script files...
  }

  if (!$isfile(custom.mrc)) write -c custom.mrc ;%%%%%%%%%%%%%%%%%%%%%%%% $crlf ;script ircN Custom Script $crlf ;version 9.00 $crlf ;author ircN Development Team $crlf ;email ircn@ircN.org $crlf ;url http://www.ircN.org $crlf ;%%%%%%%%%%%%%%%%%%%%%%%% $crlf
  if (!$isfile(custom.als)) write -c custom.als ; $crlf ; Enter any custom aliases here. $crlf ; $crlf
  if (!$script(custom.mrc)) .load -rs1 custom.mrc
  if (!$alias(custom.als)) .load -a1 custom.als

  set %b identfrs.als client.als channel.als query.als dlgspprt.als
  while ($gettok(%b,%a,32) != $null) {
    set %c $ifmatch
    if ($1 == reload) {
      if (!$isfile($+(%dir,system\,%c))) echo 04 -a [Warning] Unable to find system file: %c
      else .load -a $+(%dir,system\,%c)
    }
    else {
      if (!$isfile($+(%dir,system\,%c))) echo 04 -a [Warning] Unable to find system file: %c
      elseif (!$alias(%c)) .load -a $+(%dir,system\,%c)
    }
    inc %a
  }
  set %a 1
  set %b raw.mrc events.mrc nxt.mrc queue.mrc maintain.mrc
  while ($gettok(%b,%a,32) != $null) {
    set %c $ifmatch
    if ($1 == reload) {
      if (!$isfile($sys(%c))) echo 04 -a [Warning] Unable to find system file: %c
      else .reload -rs $sys(%c)
    }
    else {
      if (!$isfile($sys(%c))) echo 04 -a [Warning] Unable to find system file: %c
      elseif (!$script(%c)) {
        .reload -rs $+ $iif(%c == maintain.mrc,2) $sys(%c)

        ;maintain wasnt loaded.. check for crash after loading settings
        if (!%install) {
          if (%c == maintain.mrc) var %crashcheck = $true
        }
      }
    }
    inc %a
  }


  _mkircndir

  _loadpopups


  if ((!$script(users.mrc)) || (!$isfile($usrfile))) {
    if (!$isfile($sd(users.mrc))) write -c $sd(users.mrc)
    .load -ru $sd(users.mrc)
  }
  if ((!$script(vars.mrc)) || (!$isfile($varfile))) {
    if (!$isfile($sd(vars.mrc))) write -c $sd(vars.mrc)
    .load -rv $sd(vars.mrc)
  }

  if (!$hget(ircN)) { 
    hmake ircN $iif($lines($sd(ircn.ini)) > 16, $int($lines($sd(ircN.ini))), 32)
    if ($isfile($sd(ircN.ini))) hload -i ircN $sd(ircN.ini) ircN
    else newircnset
  }
  nvar dir %dir
  if (%crashcheck) crash.check nodefault

  .timer 1 1 _chkmods $iif($1 == reload,reload)
  .timer 1 1  _refpopup
  .timer 1 1 .reload -a $qt($script)
}
_clean.deadchans {
  ;clean expendable inactive channel settings  

  var %a = 1, %hash = $+($ncid( [ [ $cid ] $+ ] ,network.hash),.ircN.settings) 
  while (%a <= $hfind(%hash,$tab(chan,*,lastjoin),0,w)) {
    var %b = $hfind(%hash,$tab(chan,*,lastjoin),%a,w)
    var %c = $hget(%hash,%b)

    if (%c) {
      ; a month
      if ($calc($ctime - %c) >= 2419200) {
        hdel %hash $puttok(%b,kickcount,3,9)
        hdel %hash %b
        dec %a
      }
      ;clean after 1week
      if ($calc($ctime - %c) >= 604800) {
        hdel %hash $puttok(%b,lsnick,3,9)

      }
    }
    inc %a
  }
}

_clean.whoiscache {
  if (($calc($ctime - $ncid(whoiscache.lastclean)) < 600) && ($ncid(whoiscache.lastclean))) return
  if ($nvar(cleanwhoiscache) == off) return
  var %a = 1, %b, %c, %t, %m = 0, %ms = 0
  while ($ial(*,%a).nick != $null) {
    set %b $ifmatch
    if (!$cwiget(%b,cwho)) { inc %a | continue }
    if ($query(%b)) { inc %a | continue }
    var %t = $iif($cwiget(%b,cwhois) > $cwiget(%b,cwho),$cwiget(%b,cwhois),$cwiget(%b,cwho))
    set %c $calc($ctime - %t)

    if (%c >= 1800) { inc %m | inc %ms $len($ial(%b).mark) | .ialmark %b  }
    inc %a
  }
  if (%m) {
    if ($show) iecho Cleared cached whois information for $hc(%m) nicknames which totalled $sc($alof(%ms)) $+ .
  }
  ncid whoiscache.lastclean $ctime
}
_mkircndir {
  if (!$isdir($qt($sd))) .mkdir $qt($sd)
  if (!$isdir($sd(network))) .mkdir $sd(network)

  var %a = 1, %b, %x = system resources resources\settings resources\settings\network incoming sounds logging modules themes resources\temp resources\dlls resources\bin resources\graphics resources\graphics\icons resources\text resources\networksupport resources\networksupport\network resources\networksupport\ircd resources\backups
  while ($gettok(%x,%a,32) != $null) {
    set %b $idir($ifmatch)
    if (!$isdir(%b)) .timer 1 1 .mkdir %b 
    inc %a
  }
}
_loadpopups {
  .load -pc $sys(cpopup.pop)
  .load -pn $sys(npopup.pop)
  .load -pm $sys(mpopup.pop)
  .load -ps $sys(spopup.pop)
  .load -pq $sys(qpopup.pop)
}
hget.freenum {
  if (!$hget($1)) return 1
  var %a = 1
  var %w = $iifelse($2,*)
  while ($hfind($1,%w,%a,w) != $null) { inc %a }
  return %a
}
ircnsave {
  if ($hget(ircN)) { 
    remini $sd(ircn.ini) ircN
    hsave -io ircN $sd(ircN.ini) ircN
  }
}
isuserdir {
  if ($nofile($mircini) != $nofile($mircexe)) return $true
  return $false
}
usrdir {
  if (!$isuserdir) return $idir($1-)
  else {
    var %d = $nofile($mircini)
    if ($gettok(%d,-1,92) == system) set %d $deltok(%d,-1,92)
    return %d $+ \ $+ $1-
  }
}
varfile return $qt($readini($qt($mircini), rfiles, n1))
usrfile return $qt($readini($qt($mircini), rfiles, n0))
newircnset {
  /*
  #####################################################

  sets the default ircN settings

  #####################################################
  */


  nvar reldate $readini($sd(release.ini),release,date)
  var %ver = $readini($sd(release.ini),n,release,ver)
  if (%ver) {
    nvar lver ircN %ver
    nvar ver %ver
  }
  else {
    nvar lver ircN 9.00
    nvar ver 9.00
  }
  nvar oldver $nvar(reldate)

  nvar installed $ctime
  nvar savetime 5
  nvar maxial 300
  nvar nickcomp on
  nvar nickcomp.nch :
  nvar nickcomp.style random
  nvar titlebar on
  nvar titlebar.format @me @network @idle @lag @chanusers
  nvar lagstat.time 1
  nvar splash on
  nvar join.topic on
  nvar join.totals on
  nvar join.names
  nvar join.sync on
  nvar join.created on
  nvar join.ircops on
  nvar $tab(authdlg,presets,nickserv) $tab(/msg NickServ IDENTIFY <pass>,/msg NickServ GHOST <username> <pass>,NickServ,*type /msg NickServ IDENTIFY pass*)
  nvar netsettingsexpiredays 30
  nvar netsettingskeep on
  nvar kbmask 3
  nvar wall wallops
  nvar daychange on
  tb
  _fkeys.default
}
netset {
  if (!$1) return
  nload $cid $1
  nset lastserv $server
  nset lastme $me
  ncid network $1
  if ($modespl) ncid modesonline $ifmatch
  elseif ($2 isnum) ncid modesonline $2
  if ($3) ncid $3 $true
}
netchk {
  var %z
  if ($network) set %z $ifmatch
  elseif ($server($server).group) set %z $ifmatch
  if (%z != $null) {
    if (%z == dalnet) netset %z 10
    elseif (%z == undernet) netset %z 4
    elseif (%z == efnet) netset %z 4
    elseif (%z == chatnet) netset %z 5
    elseif ((%z == austnet) || (%z == galaxynet) || (%z == othernet)) netset %z 6
    else netset %z 3
  }
  else {
    ncid vercheck on
    .quote version
    .timer 1 5 if ($ $+ ncid(network) == $ $+ null) $chr(123) var % $+ a = $ $+ input(ircN was unable to determine your IRC network. $ $+ crlf $ $+ + Please enter your current IRC network,1) $chr(124) .server -a $server -g $ $+ iif(% $+ a, % $+ a,unknown) -d $ $+ iif(% $+ a, % $+ a,unknown) $ $+ + : $server $chr(124) netset $ $+ iif(% $+ a, % $+ a,unknown) $chr(125)
  }
}
_netclean {
  var %a = $findfile($nd,*.set,0,_netclean.check " $+ $1- $+ ")
  nvar netsettingsclean $ctime
}
_netclean.check {
  var %m = $file($1-).mtime
  var %a = $nvar(netsettingsexpiredays)
  if (%a !isnum) || (!%a) set %a 31
  var %b = $calc($ctime - %m)
  if (%b >= $calc(%a *60*60*24)) {
    if ($isfile($1-)) .remove -b $1-
    if ($isfile($replace($1-,.set,.srv))) .remove -b $replace($1-,.set,.srv)
    if ($isfile($replace($1-,.set,.map))) .remove -b $replace($1-,.set,.map)

    iecho -s Removed old network settings file $hc($deltok($nopath($1-),-1,46)) $paren($ac($trimdur(%b,smh) old))

  }
}
;$nethash2set hash->setting conversion
;$nethash2set(EFNet.2) would return EFNet 2
nethash2set {
  if ($gettok($1-,$numtok($1-,46),46) isnum) return $left($1-,$calc(-1 - $len($gettok($1-,$numtok($1-,46),46)))) $gettok($1-,$numtok($1-,46),46)
  else return $1-
}

;$netset2hash setting->hash conversion
;$netset2hash(EFNet.2) would return EFNet 2
netset2hash return $+($gettok($1-,1,32),$iif($gettok($1-,2,32) > 1,. $+ $gettok($1-,2,32)))

;$netfn2hash filename->hash conversion
;$netfn2hash(EFNet.set2) would return EFNet.2
netfn2hash return $iifelse($left($1-,$calc($pos($1-,.,$pos($1,.,0) - 1) - 1)) $+ $iif($right($1-,1) isnum,.) $+ $right($right($1-,$calc($len($1-) - $pos($1-,.,$pos($1,.,0)))) ,-3),0)

;$netfn2set filename->setting conversion
;$netfn2set(EFNet.set2) would return EFNet 2
netfn2set return $iifelse($left($1-,$calc($pos($1-,.,$pos($1,.,0) - 1) - 1)) $+ $iif($right($1-,1) isnum,$chr(32)) $+ $right($right($1-,$calc($len($1-) - $pos($1-,.,$pos($1,.,0)))) ,-3),0)

;; network hash->filename conversion
nethash2fn {
  var %a = $pos($1,.,$pos($1,.,0))
  if ($pos($1,.,0) == 0) return $+($1,.set)
  elseif ($right($1,$calc(0 - $pos($1,.,$pos($1,.,0)))) !isnum) return $+($1,.set)
  else return $+($left($1,%a),set,$right($1,$calc(0 - %a)))
}
;; $nethash.detect(network,server,serverip,port,nick,anick,emailaddr,fullname)
nethash.detect {
  var %a = 0, %a1 = 0, %b, %c, %x, %y, %s, %n
  if (!$isfile($sd(netdetect.ini))) return $1 0
  set %c 0
  while ($ini($sd(netdetect.ini),0) > %c) {
    set %b 1
    while ($gettok($readini($sd(netdetect.ini),$+(n,%c),$+(n,%a)),%b,9)) {
      set %x $ifmatch
      set %y $gettok($readini($sd(netdetect.ini),$+(n,%c),$+(n,%a)),$calc(%b + 1),9)
      if (%x == hashnro) set %n %y
      if ((%x == network) && (%y == $1)) set %s 1
      elseif (%x == network) { set %s 0 | break }
      if ((%x == server) && (%y == $2)) set %s 1
      elseif (%x == server) { set %s 0 | break }
      if ((%x == serverip) && (%y == $3)) set %s 1
      elseif (%x == serverip) { set %s 0 | break }
      if ((%x == port) && (%y == $4)) set %s 1
      elseif (%x == port) { set %s 0 | break }
      if ((%x == nick) && (%y == $5)) set %s 1
      elseif (%x == nick) { set %s 0 | break }
      if ((%x == anick) && (%y == $6)) set %s 1
      elseif (%x == anick) { set %s 0 | break }
      if ((%x == email) && (%y == $7)) set %s 1
      elseif (%x == email) { set %s 0 | break }
      if ((%x == fullname) && (%y == $8)) set %s 1
      elseif (%x == fullname) { set %s 0 | break }
      inc %b
      inc %b
    }
    if (%s == 1) return %n
    inc %c
  }
  return $1 0
}
;## $nget([id],<item>)
nget { 
  if (!$0) {
    if ($ncid(network.hash))  return $hget($+($ncid(network.hash),.ircN.settings))
    return
  }

  ; $hget($+($ncid( [ [ $iif($1 isnum,$1,$cid) ] $+ ] ,network.hash),.ircN.settings), [ $iif($2-,$2-,$1-) ] ) 
  ; $hget( [ [ $iif($1 isnum,$1,$cid) ] $+ ] .ircN.settings, [ $iif($2-,$2-,$1-) ] ) 
  return $hget($+($ncid( [ [ $iif($1 isnum,$1,$cid) ] $+ ] ,network.hash),.ircN.settings), [ $iif($2-,$2-,$1-) ] ) 
  ;return $hget( [ [ $iif($1 isnum,$1,$cid) ] $+ ] .ircN.settings, [ $iif($2-,$2-,$1-) ] )
}
; ## $ntmp(bleh) 
; ## /ntmp [-smbczuN] item data
; ### used for setting or retreaving temporary hashtable items (is not saved)
; ### same flags as /hadd
ntmp {
  if (!$0) return
  if ($isid) return $hget(ircNTemp,$1)
  if (!$hget(ircNTemp)) hmake ircNTemp 25
  var %flag, %item, %val
  if (-* iswm $1) {
    set %flag $1 
    set %item $2
    set %val $3-
  }
  else {
    set %item $1
    set %val $2-
  }
  if (%val != $null) hadd %flag ircNTemp %item %val
  elseif (%item) hdel -w ircNTemp %item
}

; ## $nvar(bleh) 
; ## /nvar [-smbczuN] item data
; ### used for setting or retreaving main ircn settings
; ### same flags as /hadd
nvar {
  if (!$0) return
  if ($isid) return $txt2cc($hget(ircN,$1))
  var %flag, %item, %val
  if (-* iswm $1) {
    set %flag $1 
    set %item $2
    set %val $3-
  }
  else {
    set %item $1
    set %val $2-
  }
  if (%val != $null) hadd %flag ircN %item $cc2txt(%val)
  elseif (%item) hdel ircN %item
}


nvarinc {
  var %flag, %item, %val
  if (-* iswm $1) {
    set %flag $1 
    set %item $2
    set %val $3-
  }
  else {
    set %item $1
    set %val $2-
  }

  hinc %flag ircN %item %val

}
nvartog {
  if ($nvar($1) == on) nvar $1
  else nvar $1 on
}
nvardec {

  var %flag, %item, %val
  if (-* iswm $1) {
    set %flag $1 
    set %item $2
    set %val $3-
  }
  else {
    set %item $1
    set %val $2-
  }

  hdec %flag ircN %item %val
}


nvars {
  var %a = 1, %x = $hget(ircN,0).item
  iecho NVARS:
  while (%a <= %x) {
    iecho $hget(ircN,%a).item $hget(ircN,%a).data
    inc %a
  }
  iecho /NVAR <item> [value]
}
;## $ncid([cid],item)
;## /ncid [-smbczuNidr] [cid] <item> [value]
ncid {
  if ($isid) {
    if ($0) return $hget( [ [ $iif($1 isnum,$1,$cid) ] $+ ] .ircN.cid, [ $iif($2-,$2-,$1-) ] )
    return $cid $+ .ircN.cid
  }
  var %flg, %cid, %itm, %val, %c, %d
  set %flg $iif(-* iswm $1,$1)
  if ((%flg) && ($2 isnum)) { set %cid $2 | set %itm $3 | set %val $4- }
  elseif ((%flg) && ($2 !isnum)) { set %cid $cid | set %itm $2 | set %val $3- }
  elseif ((!%flg) && ($1 isnum)) { set %cid $1 | set %itm $2 | set %val $3- }
  elseif ((!%flg) && ($1 !isnum)) { set %cid $cid | set %itm $1 | set %val $2- }
  if ((!%cid) || (!%itm)) { theme.syntax /ncid [-smbczuNidr] [cid] <item> [value] | return }
  set %c [ [ %cid ] $+ ] .ircN.cid
  if (!$hget(%c)) .hmake %c 16
  if (i isin %flg) { .hinc $remove(%flg,i,d) %c %itm %val | return }
  if (d isin %flg) { .hdec $remove(%flg,i,d) %c %itm %val | return }
  if (r isin %flg) {
    var %a = 1
    while ($gettok(%itm,%a,44) != $null) {
      .hdel -w %c $gettok(%itm,%a,44) 
      inc %a 
    }
    return 
  }
  .hadd %flg %c %itm %val

  ;debuging
  if (queue !isin %itm) ndebug ncid %flg %c %itm %val

}

ncid.unused {
  var  %a = 1, %b, %c, %n = $hget(0)
  while (%a <= %n) {
    set %b $hget(%a)
    if (*.ircn.cid iswm %b) {
      set %b $gettok(%b ,1,46)
      set %c $addtok(%c, %b, 44)
    }
    inc %a
  }

  set %a 1
  while ($gettok(%c,%a,44) != $null) {
    set %b $ifmatch
    if (!$scid(%b)) {
      hfree %b $+ .ircN.cid
      hfree -w %b $+ .ircN.queue.*
      if ($hget(%b $+ .ircN.cachewhois)) hfree -w %b $+ .ircN.cachewhois
    }
    inc %a
  }

}

ncidremtok ncid $1 $remtok($ncid($1),$2,1,44)
changet return $nget($iif($3 isnum,$3),$tab(chan, $1, $2))
chancid {
  if ($isid) return $ncid($tab(chan, $1, $2))
  ncid $tab(chan, $1, $2) $3-
}
chanmod return $modget($1,$tab(chan, $2, $3))
querycid {
  if ($isid) return $ncid($tab(query, $1, $2))
  ncid $tab(query, $1, $2) $3-
}
chanset nset $tab(chan, $1, $2) $3-
channset nset $1 $tab(chan, $2, $3) $4-
queryset nset $tab(query, $1, $2) $3-
queryget return $nget($iif($3 isnum,$3),$tab(query, $1, $2))

;## /nset [-smbczuN] [cid] <item> [value]
nset {


  var %flg, %cid, %itm, %val, %c, %d, %e
  set %flg $iif(-* iswm $1,$1)
  if ((%flg) && ($2 isnum)) { set %cid $2 | set %itm $3 | set %val $4- }
  elseif ((%flg) && ($2 !isnum)) { set %cid $cid | set %itm $2 | set %val $3- }
  elseif ((!%flg) && ($1 isnum)) { set %cid $1 | set %itm $2 | set %val $3- }
  elseif ((!%flg) && ($1 !isnum)) { set %cid $cid | set %itm $1 | set %val $2- }

  if ((!%cid) || (!%itm)) { iecho Syntax: /nset [-smbczuN] [cid] <item> [value] | return }

  ;set %c [ [ %cid ] $+ ] .ircN.settings
  set %e $ncid( [ [ $iif($1 isnum,$1,$cid) ] $+ ] ,network.hash)
  set %c $+(%e,.ircN.settings)


  ;
  ;   IF Network settings don't exist yet, don't try to do anything, just quit, could use a timer to retry but maybe this is safer
  ;
  ;if (!$ncid( [ [ $iif($1 isnum,$1,$cid) ] $+ ] ,network.hash)) { .timer 1 1 nset $1- | return }
  if (!$ncid( [ [ $iif($1 isnum,$1,$cid) ] $+ ] ,network.hash)) return

  if (!$hget(%c)) .hmake %c 16
  if (%val == $null) { 
    var %a = 1
    while ($gettok(%itm,%a,44) != $null) { .hdel %c $gettok(%itm,%a,44) | inc %a }
  }
  else {
    var %a = 1
    while ($gettok(%itm,%a,44) != $null) { .hadd %flg %c $gettok(%itm,%a,44) %val | inc %a }
  }
  ntmp hashmodified.network. $+ %e $ctime
  ;debuging
  if ((queue !isin %itm) && (%itm != lag)) ndebug nset %flg %c %itm %val
}
nsets {
  var %cid, %c
  if ($1) set %cid $1
  else set %cid $cid
  set %c $+($ncid( [ [ $iif($1 isnum,$1,$cid) ] $+ ] ,network.hash),.ircN.settings)
  var %a = 1, %x = $hget(%c,0).item
  iecho NSETS:
  while (%a <= %x) {
    iecho $hget(%c,%a).item $hget(%c,%a).data
    inc %a
  }
  iecho /NSET <item> [value]
}
;## /ninc [id] <item> [val]
ninc {
  var %a,%b,%c,%d,%e
  set %a $iif($1 isnum,$1,$cid)
  set %b $iif($1 isnum,$2,$1)
  set %c $iif($1 isnum,$3,$2)
  ;set %d [ [ %a ] $+ ] .ircN.settings
  set %e $ncid( [ [ %a ] $+ ] ,network.hash)
  set %d $+(%e,.ircN.settings)

  if (!$hget(%d)) .hmake %d 16
  hinc %d %b %c
  ntmp hashmodified.network. $+ %e $ctime
}

;## /ndec [id] <item> [val]
ndec {
  var %a,%b,%c,%d,%e
  set %a $iif($1 isnum,$1,$cid)
  set %b $iif($1 isnum,$2,$1)
  set %c $iif($1 isnum,$3,$2)
  ;set %d [ [ %a ] $+ ] .ircN.settings

  set %e $ncid( [ [ %a ] $+ ] ,network.hash)
  set %d $+(%e,.ircN.settings)
  if (!$hget(%d)) .hmake %d 16
  hdec %d %b %c
  ntmp hashmodified.network. $+ %e $ctime
}

ntog {
  if ($isid) return $toggled($nget($1))
  if ($nget($1) == on) nset $1 off
  else nset $1 on
}
ntimer {
  if ($isid) return $+($cid, ., $1) 
  else {
    if (!$0) { nettimer | return }
    $+(.timer, $cid, ., $1) $2-
  }
}
;## /ndel [id] <temp[,temp2]>
ndel {
  var %a, %b, %c, %d, %e, %f
  set %c $iif($2,$2-,$1)
  set %b $iif($1 isnum,$1,$cid)
  ;set %a  [ [ %b ] $+ ] .ircN.settings
  set %f $ncid( [ [ %b ] $+ ] ,network.hash)
  set %a $+(%f,.ircN.settings)
  set %d 1
  while ($gettok(%c,%d,44) != $null) {
    set %e $ifmatch
    if ($hget(%a)) .hdel -w %a %e
    inc %d
  }
  ntmp hashmodified.network. $+ %f $ctime
}

;## /nkill [id]
nkill {
  var %a, %b, %c
  set %b $iif($1,$1,$cid)
  set %a [ [ %b ] $+ ] .ircN
  ;if ($hget(%a $+ .settings)) .hfree %a $+ .settings
  if ($hget(%a $+ .cid)) .hfree %a $+ .cid
  if ($hget(%a $+ .netsplits)) .hfree %a $+ .netsplits
  if ($hget(%a $+ .cachewhois)) .hfree %a $+ .cachewhois
  if ($hget(%a $+ .services.silence)) .hfree %a $+ .services.silence
}
;## /nethshkill [Network.#]
nethshkill {
  var %a, %b, %c
  set %a $+($iif($1,$1,$ncid( [ [ $cid ] $+ ] ,network.hash)),.ircN.settings)
  if ($hget(%a)) .hfree %a
}
;## /nload.all
nload.all {
  var %d = $1, %i = $2

  var %x
  var %a = $findfile($sd(network\),*.set*,0,set %x $addtok(%x,$netfn2hash($nopath($1-)),9))

  ;echo -X: %x A: %a
  set %a $numtok(%x,9)
  var %b = 1
  while (%b <= %a) {
    ;echo -a X: $gettok(%x,%b,9)
    if (!$hget($+($gettok(%x,%b,9),.ircN.settings))) nethshload $gettok(%x,%b,9)
    inc %b
  }
}
;## /nethshload [Network.#]
nethshload {
  if (!$1) return
  var %b, %d
  set %b $+($1,.ircN.settings)
  if (!$hget(%b,nloaded)) { 
    set %d $sd($+(network\,$nethash2fn($1)))
    if (!$hget(%b)) hmake %b $iif($lines(%d) > 32, $int($calc($lines(%d) / 2)), 16)

    hadd %b nloaded $ctime


    if ($isfile(%d)) { 
      ndebug nethshload %b %d
      ;iecho -s Loading network settings into memory... ( $+ $nopath(%d) $+ )
      hload %b %d 
    }
  }
}

;## /nkill.unused
nsavekill.unused {
  var %a = $hget(0), %b = 1, %c, %n, %x

  while (%b <= %a) {
    if (*.ircN.settings iswm $hget(%b)) set %x $addtok(%x,$left($hget(%b),-14),9)
    inc %b
  }

  set %c 1

  while (%c <= $numtok(%x,9)) {
    set %n $gettok(%x,%c,9)
    if (!$nethshnum(%n)) {
      if (!$istok($1-,nosave,32))  nethshsave %n
      if (!$istok($1-,nokill,32)) {
        .hfree -w mod. $+ %n $+ .*.settings
        nethshkill %n
      }
    }
    inc %c

  }
}
;## /nethshsave [Network.#]
nethshsave {
  var %a, %b, %c, %d
  set %b $+($iif($1,$1,$ncid( [ [ $cid ] $+ ] ,network.hash)),.ircN.settings)
  if ($hget(%b) == $null) return

  if (!$isdir($sd(network\))) mkdir $sd(network\)

  set %d $sd($+(network\,$nethash2fn($1)))

  ndebug nsave %b %d
  if ($hget(%b)) hsave -o %b %d
}
nethshnum {

  var %a = 1, %b, %c = 0
  while ($hget(%a) != $null) {
    set %b $ifmatch
    if (*.ircn.cid iswm %b) {
      if ($hget(%b, network.hash) == $1) inc %c
    }
    inc %a
  }

  return %c



}
;## /nsave [id] [network]
nsave {
  var %a, %b, %c, %d, %e
  set %a $iif($1 isnum,$1,$cid)
  ;set %b [ [ %a ] $+ ] .ircN.settings
  set %b $+($ncid( [ [ %a ] $+ ] ,network.hash),.ircN.settings)
  if ((%a == $null) || ($hget(%b) == $null)) return
  set %c $iif($1 isnum,$2-,$1)
  if (%c == $null) {
    set %c $ncid(%a,network)
    if (%c == $null) set %c $scid(%a).network
    if (%c == $null) set %c $server($scid(%a).server).group
    if (%c == $null) set %c $scid(%a).server
  }



  hadd ircN lastsaved $ctime
  if (!$isdir($sd(network\))) mkdir $sd(network\)

  ;need to fix this, read comments on /nload
  ;set %d $sd $+ network\ $+ %c $+ $iif($networknum(%c) > 1,_ $+ $networknum(%c)) $+ .set
  set %e $ncid( [ [ %a ] $+ ] ,network.hash)
  set %d $sd($+(network\,$nethash2fn(%e)))

  if ($ntmp(hashmodified.network. $+ %e)) {
    var %y = $ntmp(hashmodified.network. $+ %e)
    var %z = $ntmp(hashsaved.network. $+ %e)
    if (%y != %z) {
      if ($hget(%b)) hsave -o %b %d
      ntmp hashsaved.network. $+ %e %y
    }
  }


  ndebug nsave %b %d


  ircnsave
  ;move this to /ircnsave
  if ($hget(ctcpreplys)) hsave -o ctcpreplys $sd(ctcpreplys.hsh)

  if ($isfile($qt($readini($mircini,n,rfiles,n0)))) .save -ru $qt($readini($mircini,n,rfiles,n0))
  if ($isfile($qt($readini($mircini,n,rfiles,n1)))) .save -rv $qt($readini($mircini,n,rfiles,n1))

  .copy -o $sd(ircN.ini) $sd(ircNtimed.bak)

  ; .copy -o $qt($mircini) $sd(mircini.bak)


  ;;;;;;;;;;;;;;;
  .signal -n nsave
}
; ## $modvar(<module>,<item>)
; ## /modvar <module> <item> [data]
; ### used for setting or retreaving global module settings

modvar {
  var %a = modvar. [ $+ [ $1 ] $+ ] .settings
  var %b = $+($chr(36),hget,$chr(40),%a,$chr(44),$2,$chr(41)) $+ $iif($prop,. $+ $prop)
  if ($isid) return $txt2cc($eval(%b,2))
  if ($3-) hadd %a $2 $cc2txt($3-)
  elseif ($2) hdel %a $2

  ndebug modvar %a $2-
}
modvarhsh return modvar. [ $+ [ $1 ] $+ ] .settings
;## /modvarload <size> <module>
modvarload {
  var %b, %d
  set %b modvar. [ $+ [ $2 ] $+ ] .settings
  set %d $sd($+(mod\,$2,.set))
  if (!$hget(%b)) {
    hmake %b $1
    if ($isfile(%d)) hload -i %b %d $2
    ndebug modvarload %b %d $1
  }
}
;## /modvarsave <module>
modvarsave {
  var %b, %d
  set %b modvar. [ $+ [ $1 ] $+ ] .settings
  set %d $sd($+(mod\,$1,.set))
  if (!$isdir($sd(mod\))) .mkdir $sd(mod\)

  if ($hget(%b,0).item == 0) noop
  elseif (($hget(%b,0).item == 1) && ($hget(%b,modsetloaded))) noop
  elseif ($hget(%b)) {
    hsave -io %b %d $1
    ndebug modvarsave %b %d $1
  }
}
;## /modvarkill <module>
modvarkill {
  var %a
  set %a modvar. [ $+ [ $1 ] $+ ] .settings
  if ($hget(%a)) .hfree %a
}
; ## /modvarinc <module> <item> [val]
modvarinc {
  var %item, %val, %a
  set %item $2
  set %val $3-
  set %a modvar. [ $+ [ $1 ] $+ ] .settings
  if (!$hget(%a)) .hmake %a 16
  hinc %a %item %val

  ndebug modvarinc %a %item %val

}
; ## /modvardec <module> <item> [val]
modvardec {
  var %item, %val, %a
  set %item $2
  set %val $3-
  set %a modvar. [ $+ [ $1 ] $+ ] .settings
  if (!$hget(%a)) .hmake %a 16
  hdec %a %item %val

  ndebug modvardec %a %item %val
}

;## /modsetkill <module> [id]
modsetkill {
  var %a, %b
  set %b $iif($2,$2,$cid)
  ;set %a mod. [ $+ [ %b ] $+ ] . [ $+ [ $1 ] $+ ] .settings
  set %a mod. [ $+ [ $ncid(%b,network.hash) ] $+ ] . [ $+ [ $1 ] $+ ] .settings
  if ($hget(%a)) .hfree %a
}
;## /modsetsave <module> [id] [network]
modsetsave {

  var %arg_id, %arg_net, %id, %net
  if ($2 isnum) { set %arg_id $iif($2 isnum, $true) | set %id $2 }
  if (%arg_id) { set %arg_net $iif($3, $true) | set %net $3 }
  elseif ($2) { set %arg_net $true | set %net $2 | set %id $cid }

  var %a, %b, %c, %d
  if (!%id) set %id $cid

  if (%arg_net) && (%net)  set %b mod. [ $+ [ %net ] $+ ] . [ $+ [ $1 ] $+ ] .settings
  else set %b mod. [ $+ [ $ncid(%id,network.hash) ] $+ ] . [ $+ [ $1 ] $+ ] .settings

  if ((%id == $null) || ($hget(%b) == $null)) return



  if (%net == $null) {
    set %net $ncid(%id,network)
    if (%net == $null) set %net $scid(%id).network
    if (%net == $null) set %net $server($scid(%id).server).group
    if (%net == $null) set %net $scid(%id).server
  }
  if (!$isdir($sd(modnet\))) .mkdir $sd(modnet\)

  if (%arg_net) && (%net) set %d $sd($+(modnet\,$1,.,$nethash2fn(%net)))
  else set %d $sd($+(modnet\,$1,.,$nethash2fn($ncid(%id,network.hash))))

  if ($hget(%b,0).item == 0) noop
  elseif (($hget(%b,0).item == 1) && ($hget(%b,modsetloaded))) noop
  elseif ($hget(%b)) hsave -o %b %d
  .signal $+(modsetsave.,$1)
}

;## /modsetload <size> <module> [cid]
modsetload {
  var %a, %b, %c, %d
  if ($0 < 2) return
  set %a $iif($3 isnum,$3,$cid)
  ;set %b mod. [ $+ [ %a ] $+ ] . [ $+ [ $2 ] $+ ] .settings
  set %b mod. [ $+ [ $ncid(%a,network.hash) ] $+ ] . [ $+ [ $2 ] $+ ] .settings
  if (!$hget(%b)) hmake %b $1
  if ($modget(%a,modsetloaded)) return
  if (%a == $null) return

  set %c $ncid(%a,network)
  if (%c == $null) return $false

  hadd %b modsetloaded $ctime

  ;set %d $sd($+(modnet\,$2,.,%c, .set))
  set %d $sd($+(modnet\,$2,.,$nethash2fn($ncid(%a,network.hash))))
  if ($isfile(%d)) {
    if ($show) iecho -s Loading module settings into memory... ( $+ $nopath(%d) $+ )
    hload %b %d
  }
  .signal modsetload. [ $+ [ $2 ] ]
  return $true
}
modstring {
  var %a = $modinfo($md($1 $+ $iif(*.mod !isin $1,.mod)),strings,$2)
  return $iif(%a,%a, $3-)

}

modsethsh return mod. [ $+ [ $ncid($iif($2 isnum,$2,$cid),network.hash) ] $+ ] . [ $+ [ $1 ] $+ ] .settings
;## $modget(<module>,[id],<item>)
modget return $hget(mod. [ $+ [ $ncid($iif($2 isnum,$2,$cid),network.hash) ] $+ ] . [ $+ [ $1 ] $+ ] .settings, [ $iif($3-,$3-,$2-) ] )
;  set %b mod. [ $+ [ $ncid(%a,network.hash) ] $+ ] . [ $+ [ $2 ] $+ ] .settings
;## /modset <module> [-smbczuN] [cid] <item> [value]
modset {
  var %flg, %cid, %itm, %val, %c, %d, %modhsh
  set %flg $iif(-* iswm $2,$2)
  if ((%flg) && ($3 isnum)) { set %cid $3 | set %modhsh $1 | set %itm $4 |  set %val $5- }
  elseif ((%flg) && ($3 !isnum)) { set %cid $cid | set %modhsh $1 | set  %itm $3 | set %val $4- }
  elseif ((!%flg) && ($2 isnum)) { set %cid $2 | set %modhsh $1 | set %itm  $3 | set %val $4- }
  elseif ((!%flg) && ($1 !isnum)) { set %cid $cid | set %modhsh $1 | set  %itm $2 | set %val $3- }
  if ((!%cid) || (!%itm)) { iecho Syntax: /modset <module> [-smbczuN] [cid] <item>  [value] | return }
  ;set %c mod. [ $+ [ %cid ] $+ ] . [ $+ [ %modhsh ] $+ ] .settings
  set %c mod. [ $+ [ $ncid(%cid,network.hash) ] $+ ] . [ $+ [ %modhsh ] $+ ] .settings
  if (!$ncid( [ [ %cid ] $+ ] ,network.hash)) return

  if (!$hget(%c)) .hmake %c 16
  if (%val == $null) {
    var %a = 1
    while ($gettok(%itm,%a,44) != $null) { .hdel %c $gettok(%itm,%a,44) |  inc %a }
  }
  else {
    var %a = 1
    while ($gettok(%itm,%a,44) != $null) { .hadd %flg %c  $gettok(%itm,%a,44) %val | inc %a }
  }
  ;debuging
}
modtog {
  if ($modget($1,$2) == on) modset $1 $2 off
  else modset $1 $2 on
}
;## /moddel <module> [id] <temp[,temp2]>
moddel {
  var %a, %b, %c, %d, %e
  set %c $iif($3,$3-,$2)
  set %b $iif($2 isnum,$2,$cid)
  ;set %a mod. [ $+ [ %b ] $+ ] . [ $+ [ $1 ] $+ ] .settings
  set %a mod. [ $+ [ $ncid(%b,network.hash) ] $+ ] . [ $+ [ $1 ] $+ ] .settings
  set %d 1
  while ($gettok(%c,%d,44) != $null) {
    set %e $ifmatch
    if ($hget(%a)) .hdel -w %a %e
    inc %d
  }
}
;## /modsetinc <module> [id] <item> [val]
modsetinc {
  var %a,%b,%c,%d
  set %a $iif($2 isnum,$2,$cid)
  set %b $iif($2 isnum,$3,$2)
  set %c $iif($2 isnum,$4,$3)
  ;set %d mod. [ $+ [ %a ] $+ ] . [ $+ [ $1 ] $+ ] .settings
  set %d mod. [ $+ [ $ncid(%a,network.hash) ] $+ ] . [ $+ [ $1 ] $+ ] .settings
  if (!$hget(%d)) .hmake %d 16
  hinc %d %b %c
}
;## /modsetdec <module> [id] <item> [val]
modsetdec {
  var %a,%b,%c,%d
  set %a $iif($2 isnum,$2,$cid)
  set %b $iif($2 isnum,$3,$2)
  set %c $iif($2 isnum,$4,$3)
  set %d mod. [ $+ [ $ncid(%a,network.hash) ] $+ ] . [ $+ [ $1 ] $+ ] .settings

  if (!$hget(%d)) .hmake %d 16
  hdec %d %b %c
}
;## /nload [id] [network]
nload {
  ; echo -s NLOADCID: $cid scon: $scon network: $network server: $server serverip: $serverip port: $port nick: $nick anick: $anick emailaddr: $emailaddr fullname: $fullname
  var %a, %b, %c, %d
  set %a $iif($1 isnum,$1,$cid)
  set %c $iif($1 isnum,$2-,$1)
  if (%a == $null) return
  if (%c == $null) {
    set %c $ncid(%a,network)
    if (%c == $null) set %c $scid(%a).network
    if (%c == $null) set %c $server($scid(%a).server).group
    if (%c == $null) set %c $scid(%a).server
  }
  if (!$ncid(%a,network.hash)) {
    var %a2 = $nethash.detect(%c,$server,$serverip,$port,$nick,$anick,$emailaddr,$fullname)
    if ($gettok(%a2,2,32) > 0) {
      ncid network.hash $+($gettok(%a2,1,32),$iif($gettok(%a2,2,32) > 1,. $+ $gettok(%a2,2,32)))
    }
    else {
      ncid network.hash %c
    }
    ncid network.hash.num $iifelse($networknum(%c),1)
  }
  set %b $+($ncid(%a,network.hash),.ircN.settings)
  if (($ncid(%a,network.hash)) && (!$hget(%b,nloaded))) { 
    set %d $sd($+(network\,$nethash2fn($ncid(%a,network.hash))))

    if (!$hget(%b)) {
      ndebug hmake %b $iif($lines(%d) > 32, $int($calc($lines(%d) / 2)), 16)
      hmake %b $iif($lines(%d) > 32, $int($calc($lines(%d) / 2)), 16)
    }

    hadd %b nloaded $ctime


    if ($isfile(%d)) { 
      ndebug nload %b %d 
      iecho -s Loading network settings into memory... ( $+ $nopath(%d) $+ )
      hload %b %d 
    }
  }

  /*
  #####################################################

  if a user connects to the same network more than once it will load the same .set file 
  into the <cid>.ircN.settings table and when it saves the table to the settings\EFnet.set it will be overwriten
  with the one last saved.. so if they're connected to the same network twice it should save to
  EFnet.set and EFnet_2.set , etc and on /nload it should open a dialog asking them what sessions to load
  ie: efnet.set efnet_2.set, etc

  #####################################################
  */


  .signal -n nloaded 
}
sockset {
  var %a = 1
  ;/sockset socket <item> [val]
  if (!$sock($1)) return
  if ($3- != $null) {
    if ($wildtok($sock($1).mark,$2 $+ =*,1,1)) sockmark $1 $reptok($sock($1).mark,$ifmatch,$2 $+ = $+ $3-,1,1)
    else sockmark $1 $sock($1).mark $+ $chr(1) $+ $2 $+ = $+ $3-
  }
  elseif ($wildtok($sock($1).mark,$2 $+ =*,1,1)) sockmark $1 $remtok($sock($1).mark,$ifmatch,1,1)
}
sockget return $gettok($wildtok($sock($1).mark,$2 $+ =*,1,1),2-,61)
_unpopups {
  write -c popups.ini
  .load -pc $sys(popups.ini)
  .load -pn $sys(popups.ini)
  .load -pm $sys(popups.ini)
  .load -ps $sys(popups.ini)
  .load -pq $sys(popups.ini)
}
_sessions.check {
  if (!$isfile($sd(sessions.txt))) return
  var %ln = $read($sd(sessions.txt),n,1)
  if ($numtok(%ln,32) < 8) _sessions.convert1 
  elseif (($numtok(%ln,59) == 8) && ($mid(%ln,2,1) == $chr(59))) _sessions.convert1 
  elseif (($numtok(%ln,59) > 6) && ($pos(%ln,$chr(59),1) < 20))  _sessions.convert1 
}
_sessions.convert1 {

  var %fn = $sd(sessions.txt)
  var %oldfn = $sd(sessions.old)
  var %b, %i = 1, %x = $lines(%fn)
  if (%x < 1) return
  if ($isfile(%oldfn)) .remove %oldfn
  .rename %fn %oldfn

  while (%i <= %x) {
    %b = $read(%oldfn,n,%i)
    write %fn $_sessions.convert2(%b)
    inc %i
  }
  if ($isfile(%oldfn)) .remove -b %oldfn
}
_sessions.convert2 {
  var %e, %t, %z, %c, %b = $1-
  var %fn = $sd(sessions.txt)
  var %oldfn = $sd(sessions.old)
  %e = 1
  %c = 1
  %z = $numtok(%b,59)

  if (%z >= 8) {
    if ($gettok(%b,1,59) == 0) set %e 0
    set %c 2
  }
  var %l
  %l = %e $gettok(%b,%c,59) $gettok(%b,$sum(%c,1),59) $gettok(%b,$sum(%c,2),59) $gettok(%b,$sum(%c,5),59) $gettok(%b,$sum(%c,6),59)
  %l = %l $gettok(%b,$sum(%c,4),59) $gettok(%b,$sum(%c,3),59)

  inc %c
  return %l
}
_nickcolors.expire {

  ; add a check for the variable / return if its not set
  var %a = 1, %b, %c
  while ($ial(*,%a) != $null) {
    set %b $ial(*,%a).nick
    if ($ialget(%b,nickcol_t)) {
      set %c $ifmatch
      ; the nickcol_t > 30mins and they're idle >30mins
      if (($calc($ctime - %c) > 1800) && ($gettok($lastactive(%b),1,32) > 1800))  {

        var %q = 1, %y
        while ($comchan(%b, %q) != $null) {
          set %y $ifmatch
          if ($chancid(%y,$tab(nickcol,availpool)))  chancid %y $tab(nickcol,availpool) $addtok($chancid(%y,$tab(nickcol,availpool)),$ialget(%b,nickcol),32)
          inc %q
        }

        ialset %b nickcol 
        ialset %b nickcol_t
      }
    }
    inc %a
  }
}
_cleanalphavars {
  var %num = 97, %letter
  while (%num <= 122) {
    set %letter $chr(%num)
    if ($var( [ %letter ] )) {
      if ((!$var( [ %letter ] ,1).secs) && (!$var( [ %letter ] ,1).local))  unset % [ $+ [ %letter ] ]
    }
    inc %num
  }
}

; ################################################################
; ####################### IRCN SCRIPT FILE #######################
; ########## END OF FILE. DO NOT REMOVE OR MODIFY BELOW ##########
; ################################################################
