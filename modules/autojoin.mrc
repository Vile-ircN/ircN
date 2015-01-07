;%%%%%%%%%%%%%%%%%%%%%%%%
;script ircN Autojoin
;version 9.00
;author ircN Development Team
;email ircn@ircN.org
;url http://www.ircN.org
;%%%%%%%%%%%%%%%%%%%%%%%%


on *:LOAD: iecho -L "/ajoin:/ajoin" Type /ajoin for autojoin settings, or add a channel with /aj #channel (You must to be connected!)
menu channel {
  &Autojoin
  .Autojoin:ajoin
  .-
  .$iif(!$istok($modget(autojoin,autojoin),#,44),Add):aj #
  .$iif($istok($modget(autojoin,autojoin),#,44),Remove):rj #
  .$iif($modget(autojoin,autojoin),List):laj
}

on *:SIGNAL:nloaded:{
  modsetload 10 autojoin

  ; _move.aj.settings
  if ($ncid(bypass_autojoin)) {
    ncid -r bypass_autojoin
    iecho -s Autojoin disabled for this session. Type $hc(/aj) to perform autojoin manually 
    return
  }
  if ($_nget(autojoin.enable) == on) {
    if ($_nget(autojoin.wait) >= 1) iecho -s Press $hc( $_fkey.bind(.ntimer Autojoin off $| iecho Canceled autojoin for $curnet , $iifelse($_nget(autojoin.wait),5),F10) ) within the next $sc($iifelse($_nget($net2scid($curnet),autojoin.wait),5)) seconds to cancel autojoin for $curnet $+ .
    .ntimer Autojoin 1 $calc($iifelse($_nget(autojoin.wait),5) + 1) aj
  }

}
on *:SIGNAL:nsave:scid -a modsetsave autojoin

alias ajoin {
  if ($ismod(modernui)) {
    dlg -r ircN.autojoin.modern
    did -v ircN.autojoin.modern 3,4
  }
  else {
    dlg -r ircN.autojoin.classic
    did -v ircN.autojoin.classic 3,4
  }
}
alias aj {

  if ($1) {
    if (!$_nget(autojoin)) { _nset autojoin.enable on | _nset autojoin.wait 5 | iecho Enabled autojoin for $sc($curnet) with a $iif($_nget($net2scid($curnet),autojoin.wait),$ifmatch,5) second wait }
    iecho Added $hc(#$1) to autojoin for $sc($curnet)
    _nset autojoin $addtok($_nget(autojoin),#$1,44)
    if ($me !ison #$1) join #$1 $2
  }
  elseif ($chan) {
    iecho Added $hc(#) to autojoin for $sc($curnet)
    _nset autojoin $addtok($_nget(autojoin),#,44)
  }
  else {
    if ($timer($ntimer(autojoin))) .ntimer autojoin off
    var %a,%b,%c
    set %a 1
    set %b $_nget(autojoin)
    if (%b) {
      iecho -s Performing Autojoin for $sc($curnet)
      while ($gettok(%b,%a,44) != $null) {
        set %c $ifmatch
        if ($me !ison %c) .timer 1 $calc($iifelse($_nget(autojoin.delay),1) * %a) join $iif($_nget(autojoin.min),-n) %c  
        inc %a
      }
    }
  }
} 
alias rj {
  var %a = $_nget(autojoin), %b
  if (($active ischan) && (!$1)) set %b $active
  else set %b $1
  if ($istok(%a,%b,44)) {
    _nset autojoin $remtok($_nget(autojoin),%b,1,44)
    iecho Removed $hc(%b) from autojoin on $sc($curnet)
  }
  elseif (!%b) laj
  else iecho $hc(%b) isnt in your autojoin list
}
alias laj {
  var %a = 1, %b
  while ($gettok($_nget(autojoin),%a,44)) {
    set %b $addtok(%b,$ifmatch,44)
    inc %a
  }
  iecho Autojoins for $hc($curnet) $+ : %b
}
alias _move.aj.settings {
  var %h = $+($ncid( [ [ $iif($1 isnum,$1,$cid) ] $+ ] ,network.hash),.ircN.settings)
  var %x = $hfind(%h,autojoin*,0,w), %i = 1, %z
  while (%i <= %x) {
    %z = $addtok(%z,$hfind(%h,autojoin*,%i,w),32)
    inc %i
  }
  %i = $numtok(%z,32)
  while (%i) {
    modset autojoin $gettok(%z,%i,32) $nget($gettok(%z,%i,32))
    nset $gettok(%z,%i,32)
    dec %i
  }
}
dialog ircN.autojoin.classic {
  title "ircN autojoin editor"
  size -1 -1 372 320
  option pixels
  list 1, 6 44 150 140, size
  list 2, 212 44 150 140, size
  button "&Close", 3, 284 292 80 24, hide cancel
  button "&OK", 4, 200 292 80 24, hide default ok
  text "Network:", 5, 200 6 44 16, right
  combo 6, 248 4 120 200, size drop
  check "Enable autojoin", 7, 16 4 100 20
  text "Delay before autojoin:", 8, 20 232 108 16, right
  text "Autojoin", 9, 6 28 150 16, center
  text "Currently in/removed", 10, 212 28 150 16, center
  box "Settings", 11, 8 190 216 92
  edit "", 12, 134 228 32 20, center
  text "seconds", 13, 170 232 40 16
  text "Delay between joins:", 14, 26 254 102 16, right
  edit "", 15, 134 252 32 20, center
  text "seconds", 16, 170 254 40 16
  box "Stats", 17, 260 190 96 92
  text "", 18, 268 216 80 16, center
  text "", 19, 268 246 80 16, center
  check "Minimize channels", 20, 20 206 104 20
  button "<<", 23, 164 68 40 20
  button ">>", 24, 164 112 40 20
  button "<", 21, 164 46 40 20
  button ">", 22, 164 90 40 20
  button "up", 25, 164 140 40 20
  button "dn", 26, 164 162 40 20
}
on *:dialog:ircn.autojoin.classic:sclick:21:_autojoindlg.toaj $dname
on *:dialog:ircn.autojoin.classic:sclick:22:_autojoindlg.fromaj $dname
on *:dialog:ircn.autojoin.classic:sclick:23:_autojoindlg.alltoaj $dname
on *:dialog:ircn.autojoin.classic:sclick:24:_autojoindlg.allfromaj $dname
on *:dialog:ircn.autojoin.classic:sclick:25:_autojoindlg.up $dname
on *:dialog:ircn.autojoin.classic:sclick:26:_autojoindlg.down $dname
dialog ircN.autojoin.modern {
  title "ircN autojoin editor"
  size -1 -1 372 320
  option pixels
  list 1, 6 44 150 140, size
  list 2, 212 44 150 140, size
  button "&Close", 3, 284 292 80 24, hide cancel
  button "&OK", 4, 200 292 80 24, hide default ok
  text "Network:", 5, 200 6 44 16, right
  combo 6, 248 4 120 200, size drop
  check "Enable autojoin", 7, 16 4 100 20
  text "Delay before autojoin:", 8, 20 232 108 16, right
  text "Autojoin", 9, 6 28 150 16, center
  text "Currently in/removed", 10, 212 28 150 16, center
  box "Settings", 11, 8 190 216 92
  edit "", 12, 134 228 32 20, center
  text "seconds", 13, 170 232 40 16
  text "Delay between joins:", 14, 26 254 102 16, right
  edit "", 15, 134 252 32 20, center
  text "seconds", 16, 170 254 40 16
  box "Stats", 17, 260 190 96 92
  text "", 18, 268 216 80 16, center
  text "", 19, 268 246 80 16, center
  check "Minimize channels", 20, 20 206 104 20
}
on 1:dialog:ircN.autojoin.*:dclick:2:_autojoin.updatecurchans
on *:dialog:ircN.autojoin.*:init:*:{
  var %d = $dname
  _tmpdlg.hashopen

  if ($gettok($dname,3,46) == modern) {
    dcx Mark $dname autojoin_cb
    xdialog -T $dname +p

    xdialog -c $dname 30 button 164 46 40 20 tooltips
    xdialog -c $dname 31 button 164 68 40 20 tabstop tooltips
    xdialog -c $dname 32 button 164 90 40 20 tabstop tooltips
    xdialog -c $dname 33 button 164 112 40 20 tabstop tooltips
    xdialog -c $dname 34 button 164 140 40 20 tabstop tooltips
    xdialog -c $dname 35 button 164 162 40 20 tabstop tooltips

    xdid -f $dname 30,31,32,33,34,35 +b symbol 10 Webdings
    xdid -t $dname 30 3
    xdid -t $dname 31 7
    xdid -t $dname 32 4
    xdid -t $dname 33 8
    xdid -t $dname 34 5
    xdid -t $dname 35 6
    xdid -T $dname 30 Adds the channel that you are on to your autojoin list.
    xdid -T $dname 31 Adds all the channels you are on to your autojoin list.
    xdid -T $dname 32 Removes the selected channel from your autojoin list.
    xdid -T $dname 33 Removes all autojoin channels.
    xdid -T $dname 34 Moves the selected channel up in the order to be joined.
    xdid -T $dname 35  Moves the selected channel down in the order to be joined.

    mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 1 0 > NOT_USED $chr(4) Channels you will join on connect. Double-click to join a channel your not currently on.
    mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 2 0 > NOT_USED $chr(4) Channels you are currently on.
    mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 7 0 > NOT_USED $chr(4) Enables/Disables autojoin on the selected network.
    mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 12 0 > NOT_USED $chr(4) Delay in between connecting to the network and the start of autojoining channels.
    mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 15 0 > NOT_USED $chr(4) Delay in between joining channels in your autojoin list. Increase this if you get flooded off on join.
    mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 20 0 > NOT_USED $chr(4) Minimizes channels on join so they will not still the focus from other windows.
  }
  _ircn.setup.addnetcombo $dname 6 noglobal
  did -c $dname 6 $didwm(6,$curnet,1)

  _autojoin.loadajchans
  _autojoin.updateajchans
  _autojoin.updatecurchans
}
on 1:dialog:ircN.autojoin.*:sclick:7:tmpdlgset ircN.autojoin $did(6) global $did $did($did).state
on 1:dialog:ircN.autojoin.*:sclick:20:tmpdlgset ircN.autojoin $did(6) global $did $did($did).state
on 1:dialog:ircN.autojoin.*:edit:12,15:tmpdlgset ircN.autojoin $did(6) global $did $did($did)
on 1:dialog:ircN.autojoin.*:sclick:4:_save.autojoin 
on 1:dialog:ircN.autojoin.*:close:0:_tmpdlgdel.hash ircN.autojoin
on 1:dialog:ircN.autojoin.*:sclick:6:{
  _autojoin.updateajchans
  _autojoin.updatecurchans
}
on 1:dialog:ircN.autojoin.*:dclick:1:{
  var %a = $did(1).seltext
  if ($did(1).sel) && ($me !ison %a) && ($input(Do you want to join %a $+ ?,qy,Join?)) join %a
}
alias -l _did {
  if ($isid) { return $iif($dialog(ircN.autojoin.modern),$eval($+($,did,$chr(40),ircN.autojoin.modern,$chr(44),$1,$iif($2,$chr(44) $+ $2) $+ $chr(41),$iif($prop,. $+ $prop)),2),$eval($+($,did,$chr(40),ircN.autojoin.classic,$chr(44),$1,$iif($2,$chr(44) $+ $2) $+ $chr(41),$iif($prop,. $+ $prop)),2)) }
  if ($dialog(ircN.autojoin.modern)) did $1 $v1 $2-
  if ($dialog(ircN.autojoin.classic)) did $1 $v1 $2-
}
alias -l _nget return $eval($+($,modget,$chr(40),autojoin,$chr(44),$1,$iif($2,$chr(44) $+ $2) $+ $chr(41),$iif($prop,. $+ $prop)),2)
alias -l _nset modset autojoin $1-
alias -l _autojoin.updatecurchans {
  var %a
  _did -r 2
  scid $net2scid($_did(6))
  set %a 1
  while ($chan(%a)) {
    _did -a 2 $ifmatch
    inc %a
  }
  scid -r
  _did -ra 18 Channels: $_did(2).lines
}
alias -l _autojoin.loadajchans {
  var %a, %d = ircN.autojoin
  set %a 1
  while (%a <= $scon(0)) {
    scon %a
    tmpdlgset %d $curnet global chans $_nget($net2scid($curnet),autojoin)
    tmpdlgset %d $curnet global 7 $onoff2nro($_nget($net2scid($curnet),autojoin.enable))
    tmpdlgset %d $curnet global 20 $onoff2nro($_nget($net2scid($curnet),autojoin.min))
    tmpdlgset %d $curnet global 12 $iif($_nget($net2scid($curnet),autojoin.wait),$ifmatch,5)
    tmpdlgset %d $curnet global 15 $iif($_nget($net2scid($curnet),autojoin.delay),$ifmatch,3)

    inc %a
  }
  scon -r
}
alias -l _autojoin.updateajchans {
  var %a, %b, %d = ircN.autojoin
  set %b $tmpdlgget(%d,$_did(6),global,chans)
  set %a 1
  _did -r 1
  while ($gettok(%b,%a,44)) {
    _did -a 1 $ifmatch
    inc %a
  }
  _did $iif($tmpdlgget(%d,$_did(6),global,7) == 1,-c,-u) 7
  _did $iif($tmpdlgget(%d,$_did(6),global,20) == 1,-c,-u) 20
  _did -ra 12 $tmpdlgget(%d,$_did(6),global,12)
  _did -ra 15 $tmpdlgget(%d,$_did(6),global,15)
  _did -ra 19 Autojoins: $_did(1).lines
}
alias -l _autojoindlg.toaj {
  var %n = ircN.autojoin
  if (($did($1,2).sel) && (!$didwm($1,1,$did($1,2).seltext))) {
    tmpdlgset %n $did($1,6) global chans $addtok($tmpdlgget(%n,$did($1,6),global,chans),$did($1,2).seltext,44)
    _autojoin.updateajchans
    did -ra $1 13 Autojoins: $did($1,2).lines
  }
}
alias -l _autojoindlg.fromaj {
  var %n = ircN.autojoin
  if ($did($1,1).sel) {
    if (!$didwm($1,2,$did($1,1).seltext)) did -a $1 2 $did($1,1).seltext
    tmpdlgset %n $did($1,6) global chans $remtok($tmpdlgget(%n,$did($1,6),global,chans),$did($1,1).seltext,1,44)
    _autojoin.updateajchans
  }

}
alias -l _autojoindlg.alltoaj {
  var %n = ircN.autojoin
  var %a = 0
  while ($did($1,2).lines > %a) {
    inc %a
    did -c $1 2 %a
    tmpdlgset %n $did($1,6) global chans $addtok($tmpdlgget(%n,$did($1,6),global,chans),$did($1,2).seltext,44)
    _autojoin.updateajchans
  }
  did -u $1 2
  did -ra $1 13 Autojoins: $did($1,1).lines
}
alias -l _autojoindlg.allfromaj {
  var %n = ircN.autojoin
  var %a = 0
  while ($did($1,1).lines > %a) {
    inc %a
    did -c $1 1 %a
    if (!$didwm($1,2,$did($1,1).seltext)) did -a $1 2 $did($1,1).seltext
    tmpdlgset %n $did($1,6) global chans $remtok($tmpdlgget(%n,$did($1,6),global,chans),$did($1,1).seltext,1,44)
  }
  did -u $1 1
  _autojoin.updateajchans
}
alias -l _autojoindlg.up {
  var %n = ircN.autojoin
  if ($did($1,1).sel > 1) {
    var %a = $did($1,1).seltext
    var %b = $did($1,1,$calc($did($1,1).sel - 1)).text
    var %c = $findtok($tmpdlgget(%n,$did($1,6),global,chans),%a,1,44)
    var %d = $findtok($tmpdlgget(%n,$did($1,6),global,chans),%b,1,44)
    tmpdlgset %n $did($1,6) global chans $puttok($tmpdlgget(%n,$did($1,6),global,chans),%a,%d,44)
    tmpdlgset %n $did($1,6) global chans $puttok($tmpdlgget(%n,$did($1,6),global,chans),%b,%c,44)
    _autojoin.updateajchans
    .timer 1 0 did -c $1 1 %d
  }
}
alias -l _autojoindlg.down {
  var %n = ircN.autojoin
  if ($did($1,1).sel < $did($1,1).lines) {
    var %a = $did($1,1).seltext
    var %b = $did($1,1,$calc($did($1,1).sel + 1)).text
    var %c = $findtok($tmpdlgget(%n,$did($1,6),global,chans),%a,1,44)
    var %d = $findtok($tmpdlgget(%n,$did($1,6),global,chans),%b,1,44)
    tmpdlgset %n $did($1,6) global chans $puttok($tmpdlgget(%n,$did($1,6),global,chans),%a,%d,44)
    tmpdlgset %n $did($1,6) global chans $puttok($tmpdlgget(%n,$did($1,6),global,chans),%b,%c,44)
    _autojoin.updateajchans
    .timer 1 0 did -c $1 1 %d
  }
}
alias autojoin_cb {
  var %n = ircN.autojoin
  if ($2 == sclick) && ($3 isnum 30-35) {
    if ($3 == 30) _autojoindlg.toaj $1
    elseif ($3 == 31) _autojoindlg.alltoaj $1
    elseif ($3 == 32) _autojoindlg.fromaj $1
    elseif ($3 == 33) _autojoindlg.allfromaj $1
    elseif ($3 == 34) _autojoindlg.up $1
    elseif ($3 == 35) _autojoindlg.down $1
  }
}
alias _save.autojoin {
  var %d = ircN.autojoin.modern
  if (!$dialog(%d)) %d = ircN.autojoin.classic

  if (!$dialog(%d)) return

  var %a, %n = ircN.autojoin
  set %a 1
  while (%a <= $_did(6).lines) {
    _nset $net2scid($_did(6,%a)) autojoin $tmpdlgget(%n,$_did(6,%a),global,chans)
    _nset $net2scid($_did(6,%a)) autojoin.enable $nro2onoff($tmpdlgget(%n,$_did(6,%a),global,7))
    _nset $net2scid($_did(6,%a)) autojoin.min $nro2onoff($tmpdlgget(%n,$_did(6,%a),global,20))
    _nset $net2scid($_did(6,%a)) autojoin.wait $iif($tmpdlgget(%n,$_did(6,%a),global,12),$ifmatch)
    _nset $net2scid($_did(6,%a)) autojoin.delay $tmpdlgget(%n,$_did(6,%a),global,15)
    inc %a
  }
  scid -a modsetsave autojoin

}
alias _autojoin.ischanautoormirc {
  ; used for internal ircN /join to stop mirc from 'join on reconnect' channels that are already in autojoin
  ; returns $true if it's an autojoin channel
  if ($_nget(autojoin.enable) == on) && ($istok($_nget(autojoin),$1,44)) {
    if ($timer($ntimer(autojoin)))   return $true
  }
  return $false 
}
;on *:DISCONNECT:modsetsave autojoin
on *:JOIN:#:{
  if ($nick == $me) {
    if (($dialog(ircN.autojoin.modern)) || ($dialog(ircN.autojoin.classic))) && ($curnet == $_did(6).seltext)) .timer 1 0 _autojoin.updatecurchans
    .ntimer autorejoin. $+ $chan off
  }
}
on *:PART:#:if (($nick == $me) && (($dialog(ircN.autojoin.modern)) || ($dialog(ircN.autojoin.classic))) && ($curnet == $_did(6).seltext)) .timer 1 0 _autojoin.updatecurchans


;fix
raw 474:*:{
  if ($ncid(joinsync. $+ $2)) {
    .ntimer autorejoin. $+ $2 0 60 _autorejoin $2 
    if ($ncid(autorejoin. $+ $2 $+ .inc)) halt
  }
}
alias _autorejoin {
  if ($ncid(autorejoin. $+ $1 $+ .inc) >= 5) { .ntimer autorejoin. $+ $1 off | ncid -r autonrejoin. $+ $1 $+ .* | ncid -r joinsync. $+ $1 | return }
  if (!$ncid(autorejoin. $+ $1 $+ .start)) ncid autorejoin. $+ $1 $+ .start $ctime
  var %dur = $calc($ctime - $ncid(autorejoin. $+ $1 $+ .start))
  var %min = $calc(%dur / 60)
  iecho has been running for %min minutes
  ncid -i autorejoin. $+ $1 $+ .inc 
  .quote join $1 $changet($1,key)
}

raw 480:*:{
  if (throttle exceeded isin $strip($3-)) {
    .ntimer autorejoin. $+ $2 0 60 _autorejoin $2 
    if ($ncid(autorejoin. $+ $2 $+ .inc)) halt
  }
}
