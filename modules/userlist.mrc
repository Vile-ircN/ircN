;%%%%%%%%%%%%%%%%%%%%%%%%
;script ircN Userlist
;author ircN Development Team
;url http://www.ircN.org
;%%%%%%%%%%%%%%%%%%%%%%%%

; fix firstjoin and %owner

;clear bans on join

on *:START:{

  if (!$hget($nusr)) hmake $nusr 256

  .loaduserlist
  .loadbanlist

  if (!$script(users.mrc)) {
    if (!$isfile($sd(users.mrc))) {
      write -c $sd(users.mrc)
      remakeusrs
    }
    .load -ru $sd(users.mrc)
  }


}
ON *:SIGNAL:nloaded:{
  if (!$nvar(owner)) nvar owner %owner
  elseif (!%owner) set %owner $nvar(owner)
}
on *:EXIT:{
  .saveuserlist
  .savebanlist
}
on *:UNLOAD:{
  .saveuserlist
  .savebanlist

  if ($hget(ircN.userlist)) hfree ircN.userlist
  if ($hget(ircN.banlist)) hfree ircN.banlist

  if ($nvar(colul) == on) nvar colul

}
alias userlist {
  if ($ismod(modernui)) {
    if ($istok(%ircnsetup.docked,ircnsetup.userlist,44)) return

    dlg -r ircnsetup.userlist
    dialog -rsb ircnsetup.userlist -1 -1 184 146
  }
  elseif ($ismod(classicui)) dlg -r ircn.userlist
  else { iecho Userlist: No GUI modules loaded. Use commands: $hc(/adduser) $hc(/remuser) $hc(/addhost) $hc(/remhost) $hc(/chattr) $hc(/addbotpass) $hc(/chpass) instead | iecho Userlist: Use $hc(/match <wildcard>) or $hc(/match *) to display your entire userlist | return }
}
alias banlist {
  if ($ismod(modernui)) {
    if ($istok(%ircnsetup.docked,ircnsetup.banlist,44)) return
    dlg -r ircnsetup.banlist
    dialog -rsb ircnsetup.banlist -1 -1 184 146
  }
  elseif ($ismod(classicui)) dlg -r ircn.banlist
  else { bans | iecho Banlist: No GUI modules loaded. Use commands: $hc(/addban /remban /stickban /unstickban) | return } 
}
alias umop {
  if ($me !isop #) {
    _doraw.fake 482 $server # $me #
    return
  }
  var %a, %z
  set %a 1
  while ($nick(#,%a,a,o)) {
    set %z $ifmatch
    if ($chkflag($usr(%z),$chan,o)) mmode2 enqueue %z
    inc %a
  }
  if ($mmode2) mmode2 flush + o #
  else iecho All registered ops in $hc(#) have ops.
}
alias umdop {
  if ($me !isop #) {
    _doraw.fake 482 $server # $me #
    return
  }
  var %a, %b, %y, %z
  set %a 1
  while ($nick(#,%a,o)) {
    set %z $ifmatch
    if ((%z != $me) && ($chkflag($usr(%z),$chan,o) != $true)) mmode2 enqueue %z
    inc %a
  }
  if ($mmode2) mmode2 flush - o #
  else iecho No unregistered ops have ops in $hc(#) $+ .
}
alias umv {
  if (($me !isop #) && ($me !ishop #)) {
    _doraw.fake 482 $server # $me #
    return
  }
  var %a, %b, %y, %z
  set %a 1
  while ($nick(#,%a,r)) {
    set %z $ifmatch
    if ($chkflag($usr(%z),$chan,v)) mmode2 enqueue %z
    inc %a
  }
  if ($mmode2) mmode2 flush + v #
  else iecho All registered voiced users in $hc(#) are voiced.
}
alias umdv {
  if (($me !isop #) && ($me !ishop #)) {
    _doraw.fake 482 $server # $me #
    return
  }
  var %a, %b, %y, %z
  set %a 1
  while ($nick(#,%a,v)) {
    set %z $ifmatch
    if ($chkflag($usr(%z),$chan,v) != $true) mmode2 enqueue %z
    inc %a
  }
  if ($mmode2) mmode2 flush - v #
  else iecho No unregistered voiced users are voiced in $hc(#) $+ .
}

alias chusercol {

  if ($1 == $null) {
    theme.syntax /chnickcol <username> <col>
    return
  }
  elseif ($ulinfo($1,user) == $null) {
    if ($usr($1)) iecho Can't find $hc($1) on userlist, try $hc($usr($1)) instead.
    else iecho Can't find $hc($1) on userlist.
    return
  }
  ulwrite $1 nickcol - $2

  ;do an ialset to erase nickcol, change it to ulcol
  colupdt2 $1
  if ($show) iecho Changed user color to:  $+ $base($2,10,10,2) $+ $1 $+ 

}
alias chusertz {
  var %a, %b = -
  if ($1 == $null) || ($remove($2,-,+) !isnum) {
    theme.syntax /chusertz <username> <tz>
    return
  }
  elseif ($ulinfo($1,user) == $null) {
    if ($usr($1)) iecho Can't find $hc($1) on userlist, try $hc($usr($1)) instead.
    else iecho Can't find $hc($1) on userlist.
    return
  }
  if ($left($2,1) == +) set %b +
  set %a $remove($2,+,-)
  set %a $gettok($base(%a,10,10,2),1,46) $+ $iif($gettok(%a,2,46), $+(., $base($gettok(%a,2,46),10,10,2))) 
  ulwrite $1 note.timezone - %b $+ %a
  ; it will be a number like +1.50, -4, etc.. maybe ill have an identifier that can translate codes to the number
}
alias chaddr {
  if ($1 == $null) {
    theme.syntax /chaddr <botname> [address] <telnet-port> <relay-port>
    return
  }
  elseif ($ulinfo($1,user) == $null) {
    if ($usr($1)) iecho Can't find $hc($1) on userlist, try $hc($usr($1)) instead.
    else iecho Can't find $hc($1) on userlist.
    return
  }
  var %ip,%p1,%p2
  if ($isip($2)) set %ip $2
  if (%ip) {
    if ($3 isnum) set %p1 $3
    if ($4 isnum) set %p2 $4
  }
  else {
    if ($2 isnum) set %p1 $2
    if ($3 isnum) set %p2 $3
  }
  if ((!%ip) && (!%p1) && (!%p2)) {
    theme.syntax /chaddr <botname> [address] <telnet-port> <relay-port>
    return
  }
  ulwrite $1 botaddr - $iif(%ip,%ip,-) $iif(%p1,%p1,-) $iif(%p2,%p2,-)
}
alias botattr {
  if ($1 == $null) {
    theme.syntax /botattr <handle> [changes] [channel]
    return
  }
  elseif ($ulinfo($1,user) == $null) {
    if ($usr($1)) iecho Can't find $hc($1) on userlist, try $hc($usr($1)) instead.
    else iecho Can't find $hc($1) on userlist.
    return
  }
  ulwrite $1 botflags - $2-
}
menu nicklist {
  ;if they dont have a time set make it display 'set timezone'
  ; we cant just use $daylight because that's only if it's daylight in my current time.. not their region. have to use a database
  ; .$iif($usr($1), Time $+ $chr(58) $tab $asctime($calc( $gmt - ( 9 *3600) + $daylight), ddd hh $+ $chr(58) $+ nntt) $paren(AKDT)) { iecho test }
  $iif($1,Userlist)
  .$iif(!$ial($1),Host $+ $plural($numtok($snicks,44)) unknown $+ $chr(44) $iif($numtok($snicks,44) == 1,please click to use userlist popups,please refresh the chan IAL),$style(2) $tab - Userlist $paren($usr($1)) - ): $iif($numtok($snicks,44) > 1,updial , .quote userhost $1)
  .$iif($usr($1),Userlist Whois $cmdtip(uwhois) ) { uwhois $usr($1) }
  .$iif($ial($1),User Central $cmdtip(userlist)):userlist 
  .$iif((!$ulist($address($1,5),20,1) && $ial($1) &&  $1 != $me),Add Enemy $cmdtip(addban)) { addban $address($1,3) }
  .$iif(($ulist($address($1,5),20,1) && $ial($1) && $1 != $me),Remove Enemy $cmdtip(remban)) { remban $ulist($address($1,5),20,1) }
  .$iif((!$usr($1) && $ial($1) &&  $1 != $me),Add Bot $cmdtip(addbot)) { addbot $1 $address($1,1) $$?*="Enter bot password for $1 $+ " }
  .$iif((!$usr($1) && $ial($1)),Add Friend $cmdtip(adduser)) { adduser $1 $address($1,3) $iif($input(Would you like to notify $1 that they have been added to your userlist and their available commands?,y,ircN Add User),$1) }
  .$iif(($usr($1) && $ial($1) &&  $1 != $me),Remove User $cmdtip(remuser)) { remuser $usr($1) }
  .-
  .$iif(($usr($1) &&  $ial($1)),Set Flags $cmdtip(chattr))
  ..$style(2) $tab - Local Flags $paren($shorttext(12,#)) - :!
  ..Set Local Flags $tab $paren($iif($ulinfo($usr($1),flags,#), + $+ $ifmatch))  { var %f = $ulinfo($usr($1),flags,#) |  chattr $usr($1) $$input(Change local flags for user $1 ([+|-]flags) in channel #,e,ircN Userlist local userlist flags for #,$iif(%f, $+(+,%f) )) # }
  ..$style(2) $tab - Global Flags -  :! 
  ..Set Global Flags $tab $paren($iif($ulinfo($usr($1),flags), + $+ $ifmatch)) { var %f = $ulinfo($usr($1),flags)  | chattr $usr($1) $$input(Change global flags for user $1 ([+|-]flags),e,ircN Userlist global userlist flags,$iif(%f, $+(+,%f) )) }
  .$iif(($usr($1) && $ial($1)),Op)
  ..$style(2) $tab - Local Flags $paren($shorttext(12,#)) - :!
  ..$iif($chkflag($usr($1),#,o) == $false,Add local) { chattr $usr($1) +o # }
  ..$iif($chkflag($usr($1),#,o) && ($chkflag($1,$null,o) == $false),Remove local) { chattr $usr($1) -o # }
  ..$style(2) $tab - Global Flags - :!
  ..$iif($chkflag($usr($1),$null,o) == $false,Add global) { chattr $usr($1) +o }
  ..$iif($chkflag($usr($1),$null,o),Remove global) { chattr $usr($1) -o }
  .$iif(($usr($1) && $ial($1)),Auto-Voice)
  ..$style(2) $tab - Local Flags $paren($shorttext(12,#)) - :!
  ..$iif($chkflag($usr($1),#,v) == $false,Add local) { chattr $usr($1) +v # }
  ..$iif(($chkflag($usr($1),#,v) && $chkflag($1,$null,v) == $false),Remove local) { chattr $usr($1) -v # }
  ..$style(2) $tab - Global Flags - :!
  ..$iif($chkflag($usr($1),$null,v) == $false,Add global) { chattr $usr($1) +v }
  ..$iif($chkflag($usr($1),$null,v),Remove global) { chattr $usr($1) -v }
  .$iif(($usr($1) && $ial($1)),Protected)
  ..$style(2) $tab - Local Flags $paren($shorttext(12,#)) - :!
  ..$iif($chkflag($usr($1),#,f) == $false,Add local) { chattr $usr($1) +f # }
  ..$iif($chkflag($usr($1),#,f) && ($chkflag($1,$null,f) == $false),Remove local) { chattr $usr($1) -f # }
  ..$style(2) $tab - Global Flags - :!
  ..$iif($chkflag($usr($1),$null,f) == $false,Add global) { chattr $usr($1) +f }
  ..$iif($chkflag($usr($1),$null,f),Remove global) { chattr $usr($1) -f }
  .-
  .$iif(($usr($1) && $ial($1)),Change Pass $cmdtip(chpass)) { chpass $usr($1) $?*="Change user password for $1 (cancel to remove)" }
  .$iif(($usr($1) && $ial($1)),Change Botpass $cmdtip(chbotpass)) { chbotpass $usr($1) $?*="Change bot password for $1 (cancel to remove)" }
  .-
  .$iif(($usr($1) && $ial($1)),Info line $cmdtip(chinfo))
  ..$style(2) $tab - Local Flags $paren($shorttext(12,#)) - :!
  ..Add local infoline { chinfo $usr($1) # $input(Change info line for $1,e) }
  ..$style(2) $tab - Global Flags - :!
  ..Add global infoline { chinfo $usr($1) # $input(Change info line for $1,e) }
  .$iif(($usr($1) && $chkflag($usr($1),$null,b)),Eggdrop)
  ..Get ops { getops $1 }
  ..My Infoline { .msg $1 info $botpass($usr($1)) $?="Enter channel you wish to use this infoline in or cancel for none" $?="Enter infoline you wish to use" }
  ..Notes
  ...Read { .msg $1 notes $botpass($usr($1)) read $?="Enter notes to read or enter all" }
  ...Erase { .msg $1 notes $botpass($usr($1)) erase $?="Enter notes to erase or enter all" }
  ...Send { .msg $1 notes $botpass($usr($1)) to $?="Who do you wish to send a note to?" $?="Enter the note you wish to send" }
  .-
  .$iif($ial($1),Add Host $cmdtip(addhost))
  ..$iif(($usr($1) || $ulinfo($1,user)), $style(2) - $iifelse($usr($1),$1) -) :!
  ..$iif(($usr($1) || $ulinfo($1,user)),Static $paren($address($1,1))) { addhost $iifelse($usr($1),$1) $address($1,1) }
  ..$iif(($usr($1) || $ulinfo($1,user)),Dynamic $paren($address($1,3))) { addhost $iifelse($usr($1),$1) $address($1,3) }
  ..-
  ..$style(2) - Add to a different user -:!
  ..Static $paren($address($1,1)) { addhost $$input(Enter the username to add this host to,e) $address($1,1) }
  ..Dynamic $paren($address($1,3)) { addhost $$input(Enter the username to add this host to,e) $address($1,3) }
  ;  .$iif(($ial($1) && ($usr($1) || $ulinfo($1,user))),Add Host $cmdtip(addhost))
  .$iif(($usr($1) && $ial($1)),Rem Host $cmdtip(remhost))
  ..$submenu($_popup.userlist.listhosts($1, $usr($snick(#,1)), remhost $snick(#,1) )) 
  .-
  .$iif(($numtok($snicks,44) > 1 && $chan(#).ial),Mass)
  ..User
  ...Add Users { 
    var %a = 1, %b
    while ($gettok($snicks,%a,44) != $null) { set %b $ifmatch | if (!$usr(%b)) { adduser %b $address(%b,3) } | inc %a }
  }
  ...Rem Users { 
    var %a = 1, %b
    while ($gettok($snicks,%a,44) != $null) { set %b $ifmatch | if ($usr(%b)) { remuser %b } | inc %a }
  }
  ...-
  ...Adds Hosts { 
    var %a = 1, %b
    while ($gettok($snicks,%a,44) != $null) { set %b $ifmatch | if ($usr(%b)) { addhost %b $address(%b,3) } | inc %a }
  }
  ...Rem Hosts { 
    var %a = 1, %b
    while ($gettok($snicks,%a,44) != $null) { set %b $ifmatch | if ($usr(%b)) { remhost %b $ulist($address(%b,5),20,1) } | inc %a }
  }
  ..Bot 
  ...Add Bots { 
    var %a = 1, %b
    while ($gettok($snicks,%a,44) != $null) { set %b $ifmatch | if (!$usr(%b)) { addbot %b $address(%b,3) } | inc %a }
  }
  ...Rem Bots { 
    var %a = 1, %b, %c = $input(Do you want to remove the user as well,y)
    while ($gettok($snicks,%a,44) != $null) { set %b $ifmatch | if ($usr(%b)) { $iif(%c,remuser %b,chattr %b -b) } | inc %a }
  }
  ..Enemy
  ...Add Enemies { 
    var %a = 1, %b
    while ($gettok($snicks,%a,44) != $null) { set %b $ifmatch | addban $address(%b,3) # | inc %a }
  }
  ...Rem Enemues { 
    var %a = 1, %b
    while ($gettok($snicks,%a,44) != $null) { set %b $ifmatch | remban $ulist($address(%b,5),20,1) # | inc %a }
  }
}
alias usersettings {
  var %d = ircnsetup.usersettings

  if (!$ismod(classicui)) { iecho No GUI module loaded. Please load the classicui or modernui modules first | return }

  if ($istok(%ircnsetup.docked,%d,44)) return
  dlg -r %d
  dialog -rsb %d -1 -1 176 178

  did -v %d 98,99


}
alias botpass if ($ulinfo($1,botpass) != $null) return $decrypt($lower($1),$ifmatch)
alias chkflag {
  var %a, %z
  if ($3 isincs $ulinfo($1,flags)) return $true
  set %z $ulinfo($1,chans)
  if (($isvalidchan(%z,$2)) && ($3 isincs $ulinfo($1,flags,$2))) return $true
  if ($2 == *) {
    set %a 1
    while ($gettok(%z,%a,44)) {
      if ($3 isincs $ulinfo($1,flags,$gettok(%z,%a,44))) return $true
      inc %a
    }
  }
  return $false
}
; remakes users.mrc from userlist.hsh
alias remakeusrs {

  var %a = 1, %b, %c 
  while (%a <= $hfind($nusr,hosts $+ $chr(44) $+ *,0,w)) {
    set %b $hget($nusr,$hfind($nusr,hosts $+ $chr(44) $+ *,%a,w)) 
    set %c 1 
    while ($gettok(%b,%c,32) != $null) {
      .auser 40 $gettok(%b,%c,32) 
      inc %c
    } 
    inc %a
  }
  set %a 1
  while (%a <= $hfind($nban,ban $+ $chr(44) $+ *,0,w)) {
    set %b $hfind($nban,ban $+ $chr(44) $+ *,%a,w)
    .auser 20 $gettok(%b,2,44) 
    inc %a
  }
}
alias pwcheck { 
  if ($ulinfo($1,pass) != $null) var %a = $v1
  return $iif($encrypt($2,$2) === %a,$true,$false)
}
alias ulwild return $hfind($nusr,$ulname($1,*),$2)
alias ulinfo return $hget($nusr,$ulname($1,$2,$3))
alias ulname return $addtok($iif(($3 != $null) && ($3 != -),$addtok($2,$3,44),$2),$1,44)
alias usernum return $hget($nusr,$1)
alias usr return $hget($nusr,$ulist($address($1,5),40,1))
alias usrh return $hget($nusr,$ulist($1,40,1))

alias bhost return $ulist($address($1,5),20,1)
alias bhosth return $ulist($1,20,1)
alias ulwrite {
  if (!$1) return
  var %z = $ulname($1,$2,$3)
  var %a = $sd($nusr(ini))
  if (!$hget($nusr)) hmake $nusr 256
  if ($4- != $null) {
    .hadd $nusr %z $4-
    writeini -n %a $1 $deltok(%z,-1,44) $4-
  }
  else {
    .hdel $nusr %z
    remini %a $1 $deltok(%z,-1,44)
    if ($ini(%a,$1,0) == 0) remini %a $1
  }
}
alias unumadd {
  var %a = 1
  while ($hget($nusr,%a) != $null) { inc %a }
  hadd $nusr %a $1
}
alias unumdel {
  var %a, %z
  set %a 1
  while ($hget($nusr,%a) != $null) {
    set %z $ifmatch
    inc %a
    if (%z == $1) break
  }
  if ($hget($nusr,$calc(%a - 1)) != $1) return
  while ($hget($nusr,%a) != $null) {
    hadd $nusr $calc(%a - 1) $hget($nusr,%a)
    inc %a
  }
  hdel $nusr $calc(%a - 1)
}
alias umdop {
  if ($me !isop #) {
    _doraw.fake 482 $server # $me #
    return
  }
  if ($nick(#,0,o) == 1) {
    iecho You are the only operator on $hc(#) $+ .
    return
  }
  var %a, %z
  set %a 1
  while ($nick(#,%a,o)) {
    set %z $ifmatch
    if ((%z != $me) && (!$usr(%z))) mmode2 enqueue %z
    inc %a
  }
  mmode2 flush - o #
}
alias uwall {
  if (hybrid-6 isin $ncid(server_version)) {
    iecho Sorry, this command can not be used on HYBRID 6 servers. Please use /wall instead.
    return
  }
  if ($1 != $null) {
    var %a, %y, %z
    set %a 1
    while ($nick(#,%a,a,rv) != $null) {
      set %z $ifmatch
      if ($chkflag($usr(%z),$null,b) != $true) set %z $addtok(%y,$ifmatch,32)
      if ($len(%y) > 512) {
        mnotice %y [ $+ %wall $+ : $+ # $+ ] $1-
        set %y
      }
      inc %a
    }
    if (%y != $null) mnotice %y [ $+ %wall $+ : $+ # $+ ] $1-
    if ($show) iiecho -> [[ $+ %wall $+ : $+ $hc(#) $+ ]] $1-
  }
  else theme.syntax /uwall <message>
}
alias uhostadd {
  if ($1 isnum) return
  hadd $nusr $1 $2
  .auser 40 $1
}
alias uhostdel {
  if ($1 isnum) return
  hdel $nusr $1
  .ruser 40 $1
}
alias uwhois {
  if ($1 == $null) {
    theme.syntax /uwhois <user> [command]
    return
  }
  var %a, %x, %y, %z
  if ($2) set %z $2-
  else set %z iiecho
  if ($ulinfo($1,user) == $null) {
    if ($usr($1)) iecho Can't find $hc($1) on userlist, try $hc($usr($1)) instead.
    else iecho Can't find $hc($1) on userlist.
    return
  }
  if (0) set %x $ifmatch
  else set %x N/A
  if ($ulinfo($1,flags)) set %y $ifmatch
  else set %y -
  %z $fix(9,HANDLE) PASS BOTPASS NOTES FLAGS
  %z $fix(9,$1) $fix(4,$iif($ulinfo($1,pass),yes,no)) $fix(7,$iif($ulinfo($1,botpass),yes,no)) $fix(5,%x) %y
  set %a 1
  while ($gettok($ulinfo($1,chans),%a,44)) {
    set %x $ifmatch
    if ($ulinfo($1,flags,%x)) set %y $ifmatch
    else set %y -
    %z   $fix(26,%x) %y
    if ($ulinfo($1,info,%x)) %z  #INFO: $ifmatch
    inc %a
  }
  if ($ulinfo($1,botaddr)) {
    var %adr = $iif($remove($gettok($ulinfo($1,botaddr),1,32),-),$gettok($ulinfo($1,botaddr),1,32))
    var %usr = $iif($remove($gettok($ulinfo($1,botaddr),2,32),-),$gettok($ulinfo($1,botaddr),2,32))
    var %bot = $iif($remove($gettok($ulinfo($1,botaddr),3,32),-),$gettok($ulinfo($1,botaddr),3,32),%usr)
    %z $lfix(10,Address:) %adr
    %z $lfix(11,users:) %usr $+ , bots: %bot
  }
  if ($ulinfo($1,botflags))  %z $lfix(12,BOT FLAGS:) $ulinfo($1,botflags)
  if ($ulinfo($1,hosts)) {
    set %x $ifmatch
    %z $lfix(8,HOSTS:) $gettok(%x,1,32)
    set %a 2
    while ($gettok(%x,%a,32) != $null) {
      %z $fix(8) $gettok(%x,%a,32)
      inc %a
    }
  }
  else %z $lfix(8,HOSTS:) none
  if ($ulinfo($1,info)) %z $lfix(7,INFO:) $ifmatch


}
alias adduser {
  if ($1 == $null) {
    theme.syntax /adduser <username> [hostmask] [nickname] [pass]
    return
  }
  if ($ulinfo($1,user)) {
    iecho Error! User $hc($1) already exists!
    return
  }
  var %a, %z

  if ($2) set %z $2
  elseif ($address($1,3)) set %z $address($1,3)
  if ((*!*@* !iswm %z) && (%z)) {
    iecho Error! Use the format: $hc(nick!ident@host) for hostmasks. Wildcards are acceptable.
    return
  }
  if (($usrh(%z)) && (%z != $null)) {
    iecho Error! Someone is already using a matching hostmask!
    return
  }
  ulwrite $1 user - $true
  if (%z) {
    if (%z isnum) break
    uhostadd %z $1
    ulwrite $1 hosts - %z
    colupdt3 %z
  }
  if ($3) {
    qnotice $3 You have been added to my userlist.
    qnotice $3 Type /ctcp $me HELP for command info
  }
  if ($4) {
    ulwrite $1 pass - $encrypt($4,$4)
    qnotice $3 Your password has been set to ' $+ $4 $+ '
  }
  unumadd $1
  elseif ($3) qnotice $3 You have no password set, please set one.
  if ($show) iecho Added $hc($1) $+ .
}
alias addbot {
  if ($1 == $null) {
    theme.syntax /addbot <username> [hostmask] [pass]
    return
  }
  if ($ulinfo($1,user)) {
    iecho Error! User $hc($1) already exists!
    return
  }
  var %a, %z
  if ($2) set %z $2
  elseif ($address($1,1)) set %z $address($1,1)
  if ((*!*@* !iswm %z) && (%z)) {
    iecho Error! Use the format: $hc(nick!ident@host) for hostmasks. Wildcards are acceptable.
    return
  }
  if (($usrh(%z)) && (%z != $null)) {
    iecho Error! Someone is already using a matching hostmask!
    return
  }
  ulwrite $1 user - $true
  ulwrite $1 flags - b
  if (%z) {
    if (%z isnum) break
    uhostadd %z $1
    ulwrite $1 hosts - %z
    colupdt3 %z
  }
  if ($3) ulwrite $1 botpass - $encrypt($lower($1),$3)
  unumadd $1
  if ($show) iecho Added bot $hc($1) $+ .
}
alias chattr {
  if ($1 == $null) {
    theme.syntax /chattr <username> [[+|-]flags [channel]]
    return
  }
  elseif ($ulinfo($1,user) == $null) {
    if ($usr($1)) iecho Can't find $hc($1) on userlist, try $hc($usr($1)) instead.
    else iecho Can't find $hc($1) on userlist.
    return
  }
  var %a, %v, %w, %x, %y, %z
  set %v $2
  if ($validchantype($3)) set %w $3
  elseif (($validchantype($3)) && ($left($2,1) != +)) {
    set %v
    set %w $2
  }
  if (%w) {
    if ($istok($ulinfo($1,chans),%w,44) != $true) addchan $1 %w
    if ($ulinfo($1,flags,%w) != $null) set %z $ifmatch
  }
  elseif ($ulinfo($1,flags)) set %z $ifmatch
  if ((+ isin %v) || (- isin %v)) {
    set %a 1
    while ($mid(%v,%a,1) != $null) {
      set %x $ifmatch
      if ((%x == +) || (%x == -)) set %y $ifmatch
      elseif (%x isalnum) {
        if ((%y == +) && (%x !isin %z)) {
          if (%z != $null) set %z %z $+ %x
          else set %z %x
        }
        elseif ((%y == -) && (%x isin %z)) {
          if (%z == %x) set %z
          elseif (%z != $null) set %z $removecs(%z,%x)
        }
      }
      inc %a
    }
  }
  else set %z $alnum(%v)
  if (%w) {
    if (%z != $null) {
      ulwrite $1 flags %w %z
      colupdt2 $1
      if ($show) iecho Channel flags for $hc($1) in $sc(%w) are now $hc(%z)
      return
    }
    ulwrite $1 flags %w
    colupdt2 $1
    if ($show) iecho Removed flags for $hc($1) in $sc(%w)
  }
  else {
    if (%z != $null) {
      ulwrite $1 flags - %z
      colupdt2 $1
      if ($show) iecho Global flags for $hc($1) are now $hc(%z)
      return
    }
    ulwrite $1 flags -
    colupdt2 $1
    if ($show) iecho Removed global flags for $hc($1)
  }
}
alias addchan {
  if ($2 == $null) theme.syntax /addchan <username> <#channel>
  elseif ($ulinfo($1,user) == $null) iecho Can't find $hc($1) on userlist.
  elseif ($istok($ulinfo($1,chans),$2,44)) $iif($show,iecho Channel record already exists!)
  else {
    ulwrite $1 chans - $addtok($ulinfo($1,chans),$2,44)
    if ($show) iecho Added channel $sc($2) to $hc($1)
  }
}
alias remchan {
  if ($2 == $null) theme.syntax /remchan <username> <#channel>
  elseif ($ulinfo($1,user) == $null) iecho Can't find $hc($1) on userlist.
  elseif ($istok($ulinfo($1,chans),$2,44) != $true) iecho $sc($2) not in channels for $hc($1)
  else {
    ulwrite $1 chans - $remtok($ulinfo($1,chans),$2,1,44)
    ulwrite $1 flags $2
    ulwrite $1 info $2
    if ($show) {
      iecho Removed channel $sc($2) from $hc($1)
      iecho This includes any info-line set for that channel.
    }
  }
}
alias remuser {
  if ($1 == $null) {
    theme.syntax /remuser <user>
    return
  }
  elseif ($ulinfo($1,user) == $null) {
    iecho Error! No such user $hc($1)
    return
  }
  var %a, %y, %z
  set %z $ulinfo($1,hosts)
  set %a 0
  while ($gettok(%z,0,32) > %a) {
    inc %a
    set %y $gettok(%z,%a,32)
    uhostdel %y
    colupdt3 %y
  }
  while ($ini($sd($nusr(ini)),$1,1)) {
    set %z $ifmatch
    ulwrite $1 $gettok(%z,1,44) $gettok(%z,2,44)
  }
  unumdel $1
  if ($show) iecho Removed user entry for $hc($1)
}
alias rembot $iif($show,remuser,.remuser) $1-
alias chpass {
  if ($1 == $null) {
    theme.syntax /chpass <user> [password]
    return
  }
  elseif ($ulinfo($1,user) == $null) {
    if ($usr($1)) iecho Can't find $hc($1) on userlist, try $hc($usr($1)) instead.
    else iecho Can't find $hc($1) on userlist.
    return
  }
  if ($len($2) > 3) {
    ulwrite $1 pass - $encrypt($2,$2)
    if ($show) iecho Changed password for $hc($1)
  }
  elseif ($2) iecho Password too short! Use at least 4 characters.
  else {
    ulwrite $1 pass -
    if ($show) iecho Removed password for $hc($1)
  }
}
alias chbotpass {
  if ($1 == $null) {
    theme.syntax /chbotpass <user> [password]
    return
  }
  elseif ($ulinfo($1,user) == $null) {
    if ($usr($1)) iecho Can't find $hc($1) on userlist, try $hc($usr($1)) instead.
    else iecho Can't find $hc($1) on userlist.
    return
  }
  if ($2 != $null) {
    ulwrite $1 botpass - $encrypt($lower($1),$2)
    if ($show) iecho Changed bot password for $hc($1)
  }
  else {
    ulwrite $1 botpass -
    if ($show) iecho Removed bot password for $hc($1)
  }
}
alias chinfo {
  if ($2 == $null) {
    theme.syntax /chinfo <user> [channel] [infoline|none]
    return
  }
  if ($ulinfo($1,user) == $null) {
    if ($usr($1)) iecho Can't find $hc($1) on userlist, try $hc($usr($1)) instead.
    else iecho Can't find $hc($1) on userlist.
    return
  }
  if (($istok($ulinfo($1,chans),$2,44) != $true) && ($2 ischan)) addchan $1-2
  if ($istok($ulinfo($1,chans),$2,44)) {
    if (($3- == none) || ($3- == $null)) {
      ulwrite $1 info $2
      if ($show) iecho Removed infoline for $hc($1) in $2
    }
    else {
      ulwrite $1 info $2 $3-
      if ($show) iecho Changed infoline for $hc($1) in $2 to " $+ $strip($3-) $+ "
    }
  }
  elseif (($2- == none) || ($2 == $null)) {
    ulwrite $1 info -
    if ($show) iecho Removed infoline for $hc($1)
  }
  elseif ($2) {
    ulwrite $1 info - $2-
    if ($show) iecho Changed infoline for $hc($1) to " $+ $strip($2-) $+ "
  }
}

alias addhost {
  if ($2 == $null) theme.syntax /addhost <username> <hostmask>
  elseif (*!*@* !iswm $2) iecho Error! Use the format: $hc(nick!ident@host) for hostmasks. Wildcards are acceptable.
  elseif ($ulinfo($1,user) == $null) iecho Can't find $hc($1) on userlist.
  elseif ($usrh($2)) iecho That hostmask is already added for another user!
  elseif ($istok($ulinfo($1,hosts),$2,32)) iecho Host $hc($2) already in  hostmask list for $hc($1) $+ .
  elseif ($2 isnum) iecho Hostmask can't be numeric only!
  else {
    uhostadd $2 $1
    ulwrite $1 hosts - $addtok($ulinfo($1,hosts),$2,32)
    colupdt3 $2
    if ($show) iecho Added hostmask $hc($2) to $hc($1) $+ .
  }
}
alias remhost {
  if ($2 == $null) theme.syntax /remhost <username> <hostmask>
  elseif ($ulinfo($1,user) == $null) iecho Can't find $hc($1) on userlist.
  elseif ($istok($ulinfo($1,hosts),$2,32) != $true) iecho Host $hc($2) not  in hostmask for $hc($1) $+ .
  elseif ($2 isnum) iecho Hostmask can't be numeric only!
  else {
    uhostdel $2
    ulwrite $1 hosts - $remtok($ulinfo($1,hosts),$2,1,32)
    colupdt3 $2
    if ($show) iecho Removed hostmask $hc($2) from $hc($1) $+ .
  }
}
alias urehashusers {
  var %a, %b, %c, %w, %x, %y, %z, %u = $nusr(ini)
  if ($hget($nusr)) hfree $nusr
  .rlevel 40
  hmake $nusr 256
  set %a 1
  while ($ini($sd(%u),%a)) {
    set %z $ifmatch
    if ($ini($sd(%u),%z,user)) unumadd %z
    else {
      inc %a
      continue
    }
    set %b 1
    while ($ini($sd(%u),%z,%b)) {
      set %y $ifmatch
      set %x $readini($sd(%u),n,%z,%y)
      hadd $nusr $instok(%y,%z,0,44) %x
      if (%y == hosts) {
        set %c 1
        while ($gettok(%x,%c,32) != $null) {
          set %w $ifmatch
          if ($hget($nusr,%w) != $null) {
            set %x $remtok(%x,%w,1,32)
            hadd $nusr $instok(%y,%z,0,44) %x
            continue
          }
          uhostadd %w %z
          inc %c
        }
      }
      inc %b
    }
    inc %a
  }
  saveuserlist
}
alias loaduserlist {
  if ($hget($nusr)) hfree $nusr
  hmake $nusr 256
  var %a = $sd($nusr(usr))

  if ($isfile(%a) == $false) {
    if ($show)   iecho Hashing userlist...
    urehashusers
    return
  }
  hload $nusr %a
  if ($hget($nusr,crc) != $crc($sd($nusr(ini)))) {
    iecho Error: userlist CRC mismatch!
    urehashusers
  }
}
alias saveuserlist {
  if (!$hget($nusr)) return
  if ($show) iecho Saving userlist...
  hadd $nusr crc $crc($sd($nusr(ini)))

  hsave -o $nusr $sd($nusr(usr))
}
alias matchlist {
  if ($me isop #) {
    .notice # $me is now matching userlist.
    umdop
    umop
    umv
    umdv
  } 
  elseif ($me ishop #) {
    umv
    umdv
  }
  else iecho This function is only available to channel operators!
}
on *:signal:ctcp:{
  var %nick = $gettok($3,1,33), %fulladdress = $3, %ctcp = $4, %text = $5-

  if (%ctcp $gettok(%text,1,32) == DCC CHAT) {

    if ($chkflag($usrh(%fulladdress),$null,c)) {
      .timer 1 0 .creq $creq
      .creq auto
    }

  }
}

CTCP 40:HELP:?:{
  var %b, %z = $usrh($fulladdress)
  if ($2 != $null) set %b $2
  else set %b help
  goto %b
  :chat
  if (($chkflag(%z,$null,p)) || ($chkflag(%z,$null,r))) {
    putserv NOTICE $nick :/CTCP $me CHAT
    putserv NOTICE $nick :   This will connect you to my partyline via DCC CHAT.
  }
  return
  :chan
  if ($chkflag(%z,$null,m)) {
    putserv NOTICE $nick :/CTCP $me CHAN <password>
    putserv NOTICE $nick :   This will list all of the channels I am currently in.
  }
  return
  :op
  if ($chkflag(%z,*,o)) {
    putserv NOTICE $nick :/CTCP $me OP <password> [channel]
    putserv NOTICE $nick :   This will tell me to op you on any channel where I have
    putserv NOTICE $nick :   ops and you don't.  If you give a channel name, I'll just
    putserv NOTICE $nick :   op you on that channel.
  }
  return
  :invite
  if ($chkflag(%z,*,o)) {
    putserv NOTICE $nick :/CTCP $me INVITE <password> <channel>
    putserv NOTICE $nick :   This will make me invite you to a channel (if I'm on
    putserv NOTICE $nick :   that channel).
  }
  return
  :info
  putserv NOTICE $nick :/CTCP $me INFO <password> [channel] [an info line]
  putserv NOTICE $nick :   Whatever you set as your info line will be shown when
  putserv NOTICE $nick :   you join the channel, as long as you haven't been there
  putserv NOTICE $nick :   in the past three minutes.  It is also shown to people
  putserv NOTICE $nick :   when they ask the bot for WHO or WHOIS.  You may set an
  putserv NOTICE $nick :   info line specific to a channel like so:
  putserv NOTICE $nick :      /CTCP $me INFO mypass #channel This is my info.
  putserv NOTICE $nick :   Or you may set the default info line (used when there
  putserv NOTICE $nick :   is no channel-specific one) like so:
  putserv NOTICE $nick :      /CTCP $me INFO mypass This is my default info.
  putserv NOTICE $nick :/CTCP $me INFO <password> [channel] NONE
  putserv NOTICE $nick :   This erases your info line.
  return
  :pass
  putserv NOTICE $nick :/CTCP $me PASS <password>
  putserv NOTICE $nick :   This sets a password, which lets you use other commands,
  putserv NOTICE $nick :   like IDENT.
  if ($chkflag(%z,*,o)) {
    putserv NOTICE $nick :   Ops and masters: You need a password to use ANY op or
    putserv NOTICE $nick :   master command.
  }
  putserv NOTICE $nick :/CTCP $me PASS <oldpass> <newpass>
  putserv NOTICE $nick :   This is how you change your password.
  return
  :ident
  putserv NOTICE $nick :/CTCP $me IDENT <password> [nickname]
  putserv NOTICE $nick :   This lets me recognize you from a new address.  You must
  putserv NOTICE $nick :   use your password (the one you set with PASS) so I know
  putserv NOTICE $nick :   it's really you.  If you're using a different nickname
  putserv NOTICE $nick :   than you were when you registered, you'll have to give
  putserv NOTICE $nick :   your original nickname too.
  return
  :notes
  putserv NOTICE $nick :   You must use your password for any NOTES command.
  putserv NOTICE $nick :/CTCP $me NOTES <password> INDEX
  putserv NOTICE $nick :   This lists all the notes stored up for you.
  putserv NOTICE $nick :/CTCP $me NOTES <password> READ <# or ALL>
  putserv NOTICE $nick :   This will display a certain note for you, or, if you used
  putserv NOTICE $nick :   'READ ALL', it will show you every note stored for you.
  putserv NOTICE $nick :   $chr(35) may be numbers and/or intervals separated by semicolon.
  putserv NOTICE $nick :     ex: notes read 2-4;8;16-
  putserv NOTICE $nick :/CTCP $me NOTES <password> ERASE <# or ALL>
  putserv NOTICE $nick :   This works like READ, except it erases whichever note you
  putserv NOTICE $nick :   tell it to (or all of them).
  putserv NOTICE $nick :/CTCP $me NOTES <password> TO <nickname> <message...>
  putserv NOTICE $nick :   This stores a note to someone, as long as I know him or
  putserv NOTICE $nick :   her.  They will be informed of a note waiting for them
  putserv NOTICE $nick :   the next time they join the channel.
  return
  :%b
  var %a, %x, %y = INFO IDENT HELP PASS NOTES
  if ($chkflag(%z,*,o)) set %y %y OP INVITE
  if (($chkflag(%z,$null,m)) || (nvar(userlist.chanctcp) == on)) set %y %y CHAN
  if (($chkflag(%z,$null,p)) || ($chkflag(%z,$null,r))) set %y %y CHAT
  set %y $sorttok(%y,32)
  set %a 1
  while ($gettok(%y,%a,32) != $null) {
    set %x : $fix(3)
    while ($gettok(%y,%a,32) != $null) {
      if ($calc(%a % 4) == 0) {
        set %x %x $gettok(%y,%a,32)
        break
      }
      else set %x %x $fix(10,$gettok(%y,%a,32))
      inc %a
    }
    puthelp NOTICE $nick %x
    inc %a
  }
  puthelp NOTICE $nick :For help on a command, /CTCP $me HELP <command>
  if ($chkflag(%z,$null,m)) {
    puthelp NOTICE $nick :You are a master.  Many more commands are
    puthelp NOTICE $nick :available via telnet.
  }
}
CTCP 40:OP:?:{
  var %z = $usrh($fulladdress)
  if ($chkflag(%z,*,o) == $false) return
  if ($pwcheck(%z,$2)) {
    if ($3) {
      if ($me !isop $3) puthelp NOTICE $nick :I'm not opped on $b($3) $+ .
      elseif ($chkflag(%z,$3,o)) {
        if ($nick !isop $3) putserv MODE $3 +o $nick
        else puthelp NOTICE $nick :You are already opped on $b($3) $+ .
      }
      else puthelp NOTICE $nick :You are not authorized to get ops on $b($3) $+ .
    }
    else {
      var %a, %y
      set %a 1
      while ($chan(%a)) {
        set %y $ifmatch
        if (($me isop %y) && ($chkflag(%z,%y,o)) && ($nick !isop %y)) putserv MODE %y +o $nick
        inc %a
      }
    }
  }
  else puthelp NOTICE $nick :Invalid password.
}
CTCP 40:CHAN:?:{
  var %z = $usrh($fulladdress)
  if (($nvar(userlist.chanctcp) == on) || ($chkflag(%z,$null,m))) {
    if ($pwcheck(%z,$2)) {
      var %a, %y, %z
      set %a 1
      while ($chan(%a)) {
        set %y $ifmatch
        if (%y == $modvar(away,idlechan)) continue
        set %z $addtok(%z,%y,32)
        inc %a
      }
      puthelp NOTICE $nick :I'm on channels: %z
    }
    else puthelp NOTICE $nick :Invalid password.
  }
  else puthelp NOTICE $nick :Access denied.
}
CTCP 40:INVITE:?:{
  var %z = $usrh($fulladdress)
  if ($chkflag(%z,*,o) == $false) return
  if ($0 != 3) puthelp NOTICE $nick :Syntax: /CTCP $me INVITE <password> <channel>
  elseif ($pwcheck(%z,$2)) {
    if ($nick ison $3) puthelp NOTICE $nick :You are already on $b($3) $+ .
    elseif ($me ison $3) {
      if ($chkflag(%z,$3,o) == $false) puthelp NOTICE $nick :Access denied.
      elseif (($me !isop $3) && (i isin $gettok($chan($3).mode,1,32))) puthelp NOTICE $nick :I'm not opped in $b($3) $+ .
      else putserv INVITE $nick $3
    }
    else puthelp NOTICE $nick :I'm not on $b($3) $+ .
  }
  else puthelp NOTICE $nick :Invalid password.
}
CTCP 40:UNBAN:?:{
  var %z = $usrh($fulladdress)
  if ($chkflag(%z,*,o) == $false) return
  if ($0 != 3) puthelp NOTICE $nick :Syntax: /CTCP $me UNBAN <password> <channel>
  elseif ($pwcheck(%z,$2)) {
    if (($me isop $3) || ($me ishop $3)) {
      if ($chkflag(%z,$3,o) == $false) puthelp NOTICE $nick :Access denied.
      else {
        ncid unban on
        ncid ubadd $fulladdress
        ncid ubnick $nick
        mode $3 b
      }
    }
    else puthelp NOTICE $nick :I'm not on $b($3) $+ .
  }
  else puthelp NOTICE $nick :Invalid password.
}
CTCP 40:INFO:?:{
  var %z = $usrh($fulladdress)
  if ($pwcheck(%z,$2)) {
    if ($istok($ulinfo(%z,chans),$3,44)) {
      if ($left($ulinfo(%z,info,$3),1) == @) {
        puthelp NOTICE $nick :Your info line on $3 is locked.
        return
      }
      elseif ($4- == none) puthelp NOTICE $nick :Removed your info line on $3 $+ .
      elseif ($4- != $null) puthelp NOTICE $nick :Your info line on $3 is now: $strip($4-)
      else {
        puthelp NOTICE $nick :Syntax: /CTCP $me INFO <password> [channel] <infoline|none>
        return
      }
    }
    elseif ($left($ulinfo(%z,info),1) == @) {
      puthelp NOTICE $nick :Your info line is locked.
      return
    }
    elseif ($3- == none) puthelp NOTICE $nick :Removed your info line.
    elseif ($3- != $null) puthelp NOTICE $nick :Your info line is now: $strip($3-)
    else {
      puthelp NOTICE $nick :Syntax: /CTCP $me INFO <password> [channel] <infoline|none>
      return
    }
    chinfo %z $3-
  }
  else putserv NOTICE $nick :Invalid password.
}
CTCP 40:PASS:?:{
  var %z = $usrh($fulladdress)
  if ($3) {
    if ($len($3) < 4) puthelp NOTICE $nick :Please use at least 4 characters.
    elseif ($pwcheck(%z,$2)) {
      chpass %z $3
      puthelp NOTICE $nick :Password changed to ' $+ $3 $+ '
    }
    else qnotice $nick Incorrect password.
  }
  elseif ($2) {
    if ($ulinfo(%z,pass)) puthelp NOTICE $nick :You already have a password set.
    elseif ($len($2) < 4) puthelp NOTICE $nick :Please use at least 4 characters.
    else {
      chpass %z $2
      puthelp NOTICE $nick :Password set to ' $+ $2 $+ '
    }
  }
  else puthelp NOTICE $nick :You $iif($password(%z) == $null,don't) have a password set.
}
CTCP +1:IDENT:?:{
  var %z = $mask($fulladdress,3)
  if ($2 == $null) qnotice $nick Syntax: /CTCP $me IDENT <password> [nick]
  elseif ((($3 != $null) && ($pwcheck($3,$2))) || (($3 == $null) && ($pwcheck($nick,$2)))) {
    addhost $iif($3,$3,$nick) %z
    puthelp NOTICE $nick :Added hostmask: %z
  }
  else puthelp NOTICE $nick :Access denied.
}
alias firstjoin.old {
  unset %firstjoin
  if ($show) iecho ircN is now setting up your userlist. You must now add yourself to your userlist as owner.
  if ($show) set %owner $input(Please choose a username.,e) 
  adduser %owner $address($me,3)
  chattr %owner +ovjmncrp 
  iecho You have now been added to your userlist with full access. You must now set a password 
  chpass %owner $input(Enter your password.  If you forget it $+ $chr(44) simply type '/chpass %owner passwordhere',p) 
}

; ################ BEGIN NEW FIRSTJOIN ################
alias firstjoin {
  var %d = ircnsetup.wizard.firstjoin
  if (!$dialog(%d)) dlg %d
}
dialog ircnsetup.wizard.firstjoin {
  title "ircN Wizard"
  size -1 -1 175 177
  option dbu
  icon 1, 2 1 170 33, $gfxdir(wizard\header.jpg), 0
  button "Done", 2, 142 160 30 14
  text "ircN is now setting up your userlist. You must now add yourself to your userlist as owner.", 3, 2 38 170 16, right
  text "Owner:", 4, 92 60 25 8, right
  edit "", 5, 119 59 50 10, center
  box "Host:", 6, 4 72 169 46
  radio "mIRC Address", 7, 8 80 44 10
  radio "mIRC IP", 8, 8 92 44 10
  radio "Custom", 9, 8 104 44 10
  edit "", 10, 54 80 114 10, read center
  edit "", 11, 54 92 114 10, read center
  edit "", 12, 54 104 114 10, autohs center
  box "Password:", 13, 4 120 169 34
  text "Password", 14, 8 130 50 8, center
  edit "", 15, 8 139 50 10, pass center
  text "Confirm Password", 16, 62 130 50 8, center
  edit "", 17, 62 139 50 10, pass center
  button "Random Password", 18, 118 133 50 14
  text "", 19, 4 162 133 8, center
  check "Check Box", 20, 1 999 50 10
}
on 1:dialog:ircnsetup.wizard.firstjoin:close:0:{
  if (!$did(20).state) && (!%owner) {
    var %d = ircnsetup.wizard.firstjoin
    .timer 1 1 dlg %d
    .timer 1 1 did -ra %d 19 ircN needs you to set an owner to continue.
  }
}
on 1:dialog:ircnsetup.wizard.firstjoin:init:0:{
  .dns $ip
  did -ra $dname 5 $iif(%owner,$ifmatch,$readini($mircini,mirc,user))
  did -ra $dname 10 $address($me,3)
  did -c $dname 7
  mtooltips SetTooltipWidth 500
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 7 0 > NOT_USED $chr(4) This host is retrieved from mIRC's IAL.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 8 0 > NOT_USED $chr(4) This is retrieved from DNSing your IP.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 12 0 > NOT_USED $chr(4) Enter your hostmask in the format: *!user@host
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 18 0 > NOT_USED $chr(4) Generates a random password for you. $+ $crlf $+ You can change your password later with /chpass
}
on 1:dialog:ircnsetup.wizard.firstjoin:sclick:18:{
  var %a = $rand(A,Z) $+ $rand(a,z) $+ $rand(A,Z) $+ $rand(0,9) $+ $rand(a,z) $+ $rand(A,Z) $+ $rand(0,9)
  var %b = $input(Do you want to use the password: %a ?,y,Random Password)
  if (%b) did -ra $dname 15,17 %a
}
on 1:dialog:ircnsetup.wizard.firstjoin:sclick:2:{
  if ($ulinfo($did(5),user)) { did -ra $dname 19 The user $did(5) already exists. | return }
  if ($did(15) != $did(17)) { did -ra $dname 19 The passwords you typed do not match. | return }
  if (!$did(15)) || (!$did(17)) { did -ra $dname 19 Please enter a password. | return }
  if ($chr(32) isin $did(5)) { did -ra $dname 19 Please do not include spaces in the owner name. | return }
  var %a
  if ($did(7).state) set %a 10
  if ($did(8).state) set %a 11
  if ($did(9).state) set %a 12
  if (*!*@* !iswm $did(%a)) { did -ra $dname 19 Please select a host with the format: *!ident@host | halt }
  if ($usrh($did(%a))) { did -ra $dname 19 Someone is already using a matching hostmask. | halt }
  set %owner $did(5)
  nvar owner %owner
  .adduser $did(5) $did(%a)
  .chattr $did(5) +ovjmncrp
  .chpass $did(5) $did(17)
  unset %firstjoin
  iecho You are now set as the owner, to re-add yourself type $sc $+ /remuser %owner $o $+ and then type $sc(/firstjoin)
  iecho Your pass has been saved as $hc($did(15)) $+ . To change your pass type $sc $+ /chpass %owner <pass>
  dialog -x $dname
}
on *:DNS:{
  var %n = $dns(0), %d = ircnsetup.wizard.firstjoin
  while (%n > 0) {
    if ($dns(%n).ip == $ip) && ($dialog(%d)) did -ra %d 11,12 $mask(*! $+ $readini($mircini,ident,userid) $+ @ $+ $iif($dns(%n).addr,$ifmatch,$dns(%n).ip),3)
    dec %n
  }
}
; ################ END OF NEW FIRSTJOIN ################

alias dogetops {
  var %a, %y, %z
  if ($me isop $1) return
  if ($2 != $null) set %a $nick($1,$2,o)
  if (%a == $null) set %a 1
  while ($nick($1,%a,o) != $null) {
    set %z $ifmatch
    set %y $usr(%z)
    if (%y == $null) {
      inc %a
      continue
    }
    if (($chkflag(%y,$1,g)) && ($botpass(%y))) {
      if ($chkflag(%y,$1,b)) {
        qmsg %z op $botpass(%y) $iif($numtok($gettops.botcommon(%z,%y),44) == 1, $1)
        iecho -w $1 Requesting ops from $hc(%z) [[ $+ $remove($address(%z,0),*!) $+ ]] $paren(eggdrop) in $hc($1)
        return
      }
      elseif ($chkflag(%y,$1,i)) {
        qctcp %z OP $botpass(%y) $1
        iecho -w $1 Requesting ops from $hc(%z) [[ $+ $remove($address(%z,0),*!) $+ ]] $paren(ircN) in $hc($1)
        return
      }
      elseif ($chkflag(%y,$1,x)) {
        qctcp %z OP $1 $botpass(%y)
        iecho -w $1 Requesting ops from $hc(%z) [[ $+ $remove($address(%z,0),*!) $+ ]] $paren(bitchX) in $hc($1)
        return
      }
    }
    inc %a
  }
  ncid getops $remtok($ncid(getops),$1,1,44)
}
alias -l gettops.botcommon {
  var %a = 1, %b, %c
  while ($comchan($1,%a)) {
    set %c $ifmatch
    if (($1 isop %c) && ($me !isop %c) && ($chkflag($2,%c,g))) set %b $addtok(%b,%c,44)
    inc %a
  }
  return %b
}

on *:INVITE:#:{
  var %z
  set %z $usrh($fulladdress)

  if (($chkflag(%z,$null,b)) || ($chkflag(%z,$null,m)) || ($mopt(3,11) == 1)) {
    iecho Autojoining $hc($chan) by the request of $hc($nick) $rbrk($address)
    join $chan
  }

}  
on *:JOIN:#:{
  var %z, %y
  if ($nick == $me) {
    if ($nvar(owner)) {
      if (!$ulinfo($nvar(owner),user)) .timerfirstjoin 1 1 .firstjoin
    }
    else .timerfirstjoin 1 1 firstjoin
    if ($nvar(userlist.botgetops) == on) ncid getops $addtok($ncid(getops),$chan,44)

    ;;;; not sure why but there seemed to be serious colnick problems - this fixed them - but would this make color update run twice? i don't know
    if ((!$istok($ncid(joinwho),$chan,44)) && (!$istok($ncid(updial),$chan,44)))  .ntimer colnick $+ $chan 1 1 .colnick $chan
  }
  set %z $usrh($fulladdress)
  colupdt $chan $nick
  if (($nvar(userlist.infolines) == on) && (%z != $null)) {
    if ($ulinfo(%z,info,$chan)) { var %infolinetxt = $v1 | msg $chan  $nvar(userlist.infolineleft) $+ $nick $+ $nvar(userlist.infolineright)  %infolinetxt }
    elseif ($ulinfo(%z,info)) { var %infolinetxt = $v1 | msg $chan  $nvar(userlist.infolineleft) $+ $nick $+ $nvar(userlist.infolineright)  %infolinetxt }
  }
  if (($me !isop $chan) || ($nick !ison $chan)) return
  if ($ulevel == 20) {
    set %y $ulist($fulladdress,20,1)
    if ($isvalidchan($blinfo(%y,chans),$chan)) {
      if (($blinfo(%y,expire) > $ctime) || ($blinfo(%y,expire) == 0)) {
        .quote mode $chan +b %y $+ $crlf $+ kick $chan $nick :banned:  $blinfo(%y,reason)
        blwrite %y lastused $ctime
      }
      else {
        iecho -w $chan Ban on $hc(%y) expired.
        .remban %y
      }
    }
  }
  if ($ulevel == 40) {

    if (($chkflag(%z,$chan,o)) && ($chkflag(%z,$null,b)) &&  ($nvar(userlist.autoop) == on)) mmode $chan + o $nick
    if ($chkflag(%z,$chan,a)) mmode $chan + o $nick
    if ($chkflag(%z,$chan,h)) mmode $chan + h $nick
    if ($chkflag(%z,$chan,v)) mmode $chan + v $nick
    if ($chkflag(%z,$chan,k)) {
      if ($ulinfo(%z,comment)) set %y $ifmatch
      else set %y ...and don't come back.
      kb $chan $nick %y
    }

    if ($ulinfo(%z,nickcol,$chan)) || ($ulinfo(%z,nickcol)) { ialset $nick ulcol $ifmatch | ialset $nick nickcol | ialset $nick nickcol_t }
  }
}
on 1:UNBAN:#:{
  if (($me !isop $chan) && ($me !ishop $chan)) return
  if ($blinfo($banmask,sticky)) queue mode $chan +b $banmask
}
on +@20:TEXT:*:#:{
  var %z = $maddress
  if ($isvalidchan($blinfo(%z,chans),$chan)) {
    if (($blinfo(%z,expire) > $ctime) || ($blinfo(%z,expire) == 0)) {
      queue mode $chan +b %z
      queue kick $chan $nick :banned: $blinfo(%z,reason)
      queue
      blwrite %z lastused $ctime
    }
    else {
      iecho -w $chan Ban on $hc(%z) expired.
      .remban %z
    }
  }
}
on @40:ACTION:*:#:{
  var %z = $usrh($fulladdress)
  if ($nick isop $chan) return
  if (($chkflag(%z,$chan,o)) && ($chkflag(%z,$chan,a))) mode $chan +o $nick
  if ($nick isvo $chan) return
  if ($chkflag(%z,$chan,v)) mode $chan +v $nick
}
on +@20:ACTION:*:#:{
  var %z = $ulist($fulladdress,20,1)
  if ($isvalidchan($blinfo(%z,chans),$chan)) {
    if (($blinfo(%z,expire) > $ctime) || ($blinfo(%z,expire) == 0)) {
      queue mode $chan +b %z
      queue kick $chan $nick :banned: $blinfo(%z,reason)
      queue
      blwrite %z lastused $ctime
    }
    else {
      iecho -w $chan Ban on $hc(%z) expired.
      .remban %z
    }
  }
}
on *:BAN:#:{
  var %a 
  set %a $usrh($banmask)
  if ((($me isop $chan) || ($me ishop $chan)) && (%a) && ($nick != $me) && ($nvar(userlist.userbans) != on)) {
    if ($chkflag(%a,$chan,f))  .mode $chan -b $banmask    
  }
}
on @1:OP:#:{
  var %y, %z
  set %y $usrh($fulladdress)
  set %z $usr($opnick)
  if ((($nvar(userlist.strictops) == on) && ($isvalidchan($nvar(userlist.strictopchans),$chan)) && ($chkflag(%y,$chan,m) == $false) && ($chkflag(%z,$chan,o) == $false)) || ($chkflag(%z,$chan,d))) {
    mode $chan -o $opnick
    qnotice $nick Sorry, but $opnick cannot have ops in $chan $+ .
    qnotice $opnick Sorry, but you cannot have ops in $chan $+ .
  }
}
on *:KICK:#:{
  var %y, %z
  set %y $usrh($fulladdress)
  set %z $usr($knick)
  if ((($me isop $chan) || ($me ishop $chan)) && ($nick != $me) && ($knick != $me)) {
    if (($chkflag(%z,$chan,f)) && ($chkflag(%y,$chan,m) == $false) && ($chkflag(%y,$chan,b) == $false)) {
      .quote invite $knick $chan
      if ($nvar(protkb) == on) { kb $chan $nick Sorry, $b($knick) is protected. | return }
      elseif ($nvar(protkick)) { kick $chan $nick Sorry, $b($knick) is protected. | return }
      elseif ($nvar(userlist.protdeop)) mode $chan -o $nick
      qnotice $nick Sorry, $b($knick) is protected.
    }
  }
}

on *:DEOP:#:{
  var %y, %z
  set %y $usrh($fulladdress)
  set %z $usr($opnick)
  if (($opnick == $me) && ($nick != $me) && ($chkflag(%y,$chan,m) == $false) && ($chkflag(%y,$chan,b) == $false)) {
    dogetops $chan
    return
  }
  if ($me !isop $chan) return
  if (($chkflag(%z,*,b)) && ($nvar(userlist.reopbot) == on) && ($chkflag(%y,$chan,m) == $false) && ($chkflag(%y,$chan,b) == $false)) mode $chan +o $opnick
  if (($chkflag(%z,$chan,f)) && ($chkflag(%z,$chan,o)) && ($nick != $opnick) && ($chkflag(%y,$chan,m) == $false) && ($chkflag(%y,$chan,b) == $false)) {
    if (($nvar(protkb) == on) || ($ischanset($chan,protkb))) { kb $chan $nick Sorry, $b($opnick) is protected.  | return }
    elseif (($nvar(protkick) == on) || ($ischanset($chan,protkick))) { kick $chan $nick Sorry, $b($opnick) is protected. | return }
    elseif (($nvar(protdeop) == on) || ($ischanset($chan,protdeop))) { mode $chan -o+o $nick $opnick |  qnotice $nick Sorry, $b($opnick) is protected. }
  }
}
on @1:DEVOICE:#:{
  if (($chkflag($usr($vnick),$chan,f)) && ($chkflag($usr($vnick),$chan,v)) && ($nick != $vnick) && ($nick != $me) && ($chkflag($usr($nick),$chan,m) == $false) && ($chkflag($usr($nick),$chan,b) == $false)) {
    mode $chan +v $vnick
    qnotice $nick Sorry, $b($vnick) is protected.
  }
}
raw 315:*:{
  if ($istok($ncid(getops),$2,44)) {
    if (($nvar(userlist.botgetops) == on) && ($me ison $2) && ($me !isop $2)) dogetops $2
    .timer 1 0  ncid getops $ $+ remtok( $ $+ ncid(getops) ,$2,1,44)
  }
}
alias colnick.style {
  if ($1 == userlist) {
    nvar colul on
    .timer 1 0 colnick
  }
  elseif ($1 == mode) {
    nvar colul
    .timer 1 0 colnick

  }
  else {
    iecho Syntax: /colnick.style <userlist|mode>
  }
}
alias colnick {
  if ($1 == on) {
    if (($nvar(colnick) != on) && ($show) && ($nvar(colul) == on)) {
      iecho $ac(Warning:) keeping nickname colors updated uses a LOT of processor time.
      iecho If you have a slower computer, it is recommended that you not use this feature.
    }
    if ($show) && ($nvar(colnick) != on) iecho Nickname list colours turned $hc(on) $+ .
    nvar colnick on
    .timer 1 0 $iif(!$show,.) $+ colnick
  }
  elseif ($1 == off) {
    if ($show) iecho Nickname list colours turned $hc(off) $+ .
    nvar colnick off
    while ($cnick(0).color > 0) {
      .cnick -r 1
    }
    var %a, %b, %x = 1, %z
    while ($scon(%x)) {
      scon %x
      inc %x
      set %a 1
      while ($chan(%a)) {
        set %z $ifmatch
        set %b 1
        while ($nick(%z,%b)) {
          cline %z %b
          inc %b
        }
        inc %a
      }
    }
  }
  else {
    var %nxt_status = $window(@nxt_status)
    var %a, %b = 1, %w, %y, %z
    if ((!%nxt_status) && ($show)) nxt_status_open
    if ($show) var %updstatus 1
    if (%updstatus) nxt_status_show 1 Applying nicklist colors $+ $iif($nvar(colul) == on,$chr(32) $paren(This might take a while)) $+ ...

    while ($cnick(0).color > 0) .cnick -r 1
    if ($1 ischan) {
      set %z $1
      set %a 1
      while ($nick(%z,%a)) {
        set %y $ifmatch
        if ($nvar(colul) == on) {
          if ($level($address(%y,5)) == 40) cline $ulcolor($ifmatch,$usr(%y),%z) %z %a
          else cline $ulcolor($ifmatch,$address(%y,5),%z) %z %a
        }
        else cline -r %z %a
        inc %a
      }
      if ((!%nxt_status) && ($show)) nxt_status_close
      return
    }
    if ($nvar(colnick) == off) {
      if ((!%nxt_status) && ($show)) nxt_status_close
      if ($show) iecho Nicklist colors are currently disabled.
      return
    }
    if (($nvar(colul) != on) && ($nvar(colnick) == on)) {
      if ($nxtget(CLineMe) isnum) .cnick - $+ $iif($nxtget(CLineMethod),anm $+ $ifmatch,an) $!me $calc($nxtget(CLineMe) % 16)
      if ($nxtget(CLineEnemy) isnum) .cnick - $+ $iif($nxtget(CLineMethod),im $+ $ifmatch,i) * $calc($nxtget(CLineEnemy) % 16)
      if ($nxtget(CLineFriend) isnum) {
        .cnick - $+ $iif($nxtget(CLineMethod),om $+ $ifmatch,o) * $calc($nxtget(CLineFriend) % 16) | .cnick - $+ $iif($nxtget(CLineMethod),vm $+ $ifmatch,v) * $calc($nxtget(CLineFriend) % 16)
        .cnick - $+ $iif($nxtget(CLineMethod),pm $+ $ifmatch,p) * $calc($nxtget(CLineFriend) % 16) | .cnick - $+ $iif($nxtget(CLineMethod),ym $+ $ifmatch,y) * $calc($nxtget(CLineFriend) % 16)
      }
      var %modes = Owner .&~;Op @;HOp % $+ ;Voice +, %i = 1, %t = $numtok(%modes, 59), %cl, %cllist
      while (%i <= %t) {
        tokenize 32 $gettok(%modes, %i, 59)
        if ($nxtget($+(CLine,$1)) isnum) {
          %cl = $calc($ifmatch % 16)
          if ($wildtok(%cllist, %cl *, 1, 59)) { %cllist = $instok($remtok(%cllist, $ifmatch, 1, 59), $ifmatch $+ $2, 1, 59) }
          else { %cllist = $instok(%cllist, %cl $2, 1, 59) }
        }
        inc %i
      }
      %i = $numtok(%cllist, 59) | while (%i) { .cnick $iif($nxtget(CLineMethod),-m $+ $ifmatch) * $gettok(%cllist, %i, 59) | dec %i }
      if ($nxtget(CLineRegular) isnum) .cnick - $+ $iif($nxtget(CLineMethod),nm $+ $ifmatch,n) * $calc($nxtget(CLineRegular) % 16)
    }
    while ($scon(%b)) {
      if (%updstatus) nxt_status_prog $calc(%b - 1) $scon(0)
      scon %b
      set %w 1
      while ($chan(%w)) {
        if (%updstatus) nxt_status_prog $calc($calc(%b - 1) + $calc(%w / $chan(0))) $scon(0)
        set %z $chan(%w)
        set %a 1
        while ($nick(%z,%a)) {
          set %y $ifmatch
          if ($nvar(colul) == on) {
            if ($level($address(%y,5)) == 40) {
              cline $iif(!$nxtget(CLineMethodUL),$iif($nxtget(CLineMethod) < 3,-m),$iif($nxtget(CLineMethod) != 3,-m)) $ulcolor(40,$usr(%y),%z) %z %a
              ; if ($ulinfo($2,nickcol)) we have to ialset per chan for colors set it as like ulcol=4 #chan:4 #chan:2
              if ($ulinfo($usr(%y),nickcol,%z)) || ($ulinfo($usr(%y),nickcol)) { ialset %y ulcol $ifmatch | ialset %y nickcol }


            }
            else cline $iif(!$nxtget(CLineMethodUL),$iif($nxtget(CLineMethod) < 3,-m),$iif($nxtget(CLineMethod) != 3,-m)) $ulcolor($level($address(%y,5)),$address(%y,5),%z) %z %a
          }
          else cline -r %z %a
          inc %a
        }
        inc %w
      }
      inc %b
    }
    if ($isalias(_updatedlg.colors)) _updatedlg.colors
  }
  if ((!%nxt_status) && ($show)) nxt_status_close
}
alias colchan {
  if ($nvar(colnick) == on) {
    var %a = 1
    while ($chan(%a)) {
      .colnick $ifmatch
      inc %a
    }
  }
}
alias colupdt {
  if (($nvar(colnick) == on) && ($nvar(colul) == on)) {
    var %z = $address($2,5)
    cline $iif($nxtget(CLineMethodUL),-m $+ $ifmatch,$iif($nxtget(CLineMethod),-m $+ $ifmatch)) $ulcolor($level(%z),$iif($level(%z) == 40,$usrh(%z),%z),$1) $1 $nick($1,$2)
  }
}
alias colupdt2 {
  if (($nvar(colnick) == on) && ($nvar(colul) == on)) {
    var %a = 1, %z = $ulinfo($1,hosts)
    while ($gettok(%z,%a,32)) {
      colupdt3 $ifmatch
      inc %a
    }
  }
}
alias colupdt3 {
  if (($nvar(colnick) == on) && ($nvar(colul) == on)) {
    var %a, %b, %y, %z
    set %a 1
    while ($chan(%a)) {
      set %z $ifmatch
      set %b 1
      while ($ialchan($1,%z,%b)) {
        set %y $ifmatch
        var %l = $level(%y)
        if (%l == 40) {
          cline $iif($nxtget(CLineMethodUL),-m $+ $ifmatch,$iif($nxtget(CLineMethod),-m $+ $ifmatch)) $ulcolor(%l,$usrh(%y),%z) %z $ialchan($1,%z,%b).nick
        }
        else {
          cline $iif($nxtget(CLineMethodUL),-m $+ $ifmatch,$iif($nxtget(CLineMethod),-m $+ $ifmatch)) $ulcolor(%l,%y,%z) %z $ialchan($1,%z,%b).nick
        }
        inc %b
      }
      inc %a
    }
  }
}
alias ulcolor {
  var %y, %z

  set %y $ulinfo($2,nickcol,$3)
  set %z $ulinfo($2,nickcol)

  if (%y) || (%z) return $iif(%y,%y,%z)

  set %y $ulinfo($2,flags,$3)
  set %z $ulinfo($2,flags)

  if ($1 == 40) {
    if ((k isincs %z) || (k isincs %y)) return $iifelse($nxtget(CLineEnemyUL),$nxtget(CLineEnemy))
    elseif (n isincs %z) return $iifelse($nxtget(CLineOwnerUL),$nxtget(CLineOwner))
    elseif (m isincs %z) return $iifelse($nxtget(CLineMasterUL),$iifelse($nxtget(CLineOwner),$nxtget(CLineMe)))
    elseif (b isincs %z) return $iifelse($nxtget(CLineBotUL),$iifelse($nxtget(CLineFriend),$nxtget(CLineOp)))
    elseif ((o isincs %z) || (o isincs %y)) return $iifelse($nxtget(CLineOpUL),$nxtget(CLineOp))
    elseif ((v isincs %z) || (v isincs %y)) return $iifelse($nxtget(CLineVoiceUL),$nxtget(CLineVoice))
    elseif ((f isincs %z) || (f isincs %y)) return $iifelse($nxtget(CLineFriendUL),$nxtget(CLineFriend))
    else return $iifelse($nxtget(CLineUserUL),$iifelse($nxtget(CLineRegular),$colour(Listbox Text)))
  }
  elseif ($1 == 20) {
    set %z $bhost($2)
    if ($isvalidchan($blinfo(%z,chans),$3)) return $iifelse($nxtget(CLineEnemyUL),$nxtget(CLineEnemy))
  }
  elseif ($cwiget($2,ircop)) return $iifelse($nxtget(CLineIrcOPUL),$nxtget(CLineIrcOp))
  else return $iifelse($nxtget(CLineRegularUL),$iifelse($nxtget(CLineRegular),$colour(Listbox Text)))
}
dialog ircn.nickcolor {
  title "Nicklist Coloring"
  size -1 -1 135 119
  option dbu
  combo 1, 28 2 50 59, size drop
  text "Method:", 2, 2 3 20 10
  box "User Flag Colors", 3, 1 21 62 96
  box "Color", 18, 67 21 65 21
  combo 19, 69 29 60 87, size drop
  list 4, 4 30 55 83, size
}

on 1:dialog:ircn.nickcolor:init:0:{
  did -a $dname 1 Userlist
  did -a $dname 1 Mode
  did -a $dname 4 Protect
  did -a $dname 4 Bot 
  did -a $dname 4 ircN Bot 
  did -a $dname 4 Master 
  did -a $dname 4 Owner 
  did -a $dname 4 Op 
  did -a $dname 4 Auto-Kick
  did -a $dname 4 Auto-Op
  did -a $dname 4 Auto-Deop 
  did -a $dname 4 Auto-Voice
}
on 1:SIGNAL:ircn.online:{
  if ($calc($ctime - $hget(ircN,lastsaved)) >= $calc($iifelse(%savetime,5) * 60)) .saveuserlist
}

alias blinfo return $hget($nban,$blname($1,$2))
alias blname return $addtok($2,$1,44)
alias bannum return $hget($nban,$1)

;wtf is this
alias banhost2num return $hfind($nban,$1,1,w).data

alias nban {
  ;  if (!$0) return $cid $+ .ircN.banlist
  ;  if ($1 == ini) return $curnet $+ $iif($networknum(%c) > 1,_ $+ $networknum(%c)) $+ .banlist.ini
  ;  if ($1 == ban) return $curnet $+ $iif($networknum(%c) > 1,_ $+ $networknum(%c)) $+ .ban
  if (!$0) return ircN.banlist
  if ($1 == ini) return banlist.ini
  if ($1 == ban) return banlist.hsh
}
alias nusr {
  ;  if (!$0) return $cid $+ .ircN.userlist
  ; if ($1 == ini) return $curnet $+ $iif($networknum(%c) > 1,_ $+ $networknum(%c)) $+ .userlist.ini
  ; if ($1 == usr) return $curnet $+ $iif($networknum(%c) > 1,_ $+ $networknum(%c)) $+ .usr
  if (!$0) return ircN.userlist
  if ($1 == ini) return userlist.ini
  if ($1 == usr) return userlist.hsh
}
alias blwrite {
  var %z = $blname($1,$2,44)
  var %a = $sd($nban(ini))
  if (!$hget($nban))  hmake $nban 128
  if ($3- != $null) {
    .hadd $nban %z $3-
    writeini -n %a $1 $2 $3-
  }
  else {
    .hdel -w $nban %z
    remini %a $1 $2
    if ($ini(%a,$1,0) == 0) remini %a $1
  }
}
alias bnumadd {
  var %a = 1
  while ($hget($nban,%a) != $null) { inc %a }
  hadd $nban %a $1
}
alias bnumdel {
  var %a, %z
  set %a 1
  while ($hget($nban,%a) != $null) {
    set %z $ifmatch
    inc %a
    if (%z == $1) break
  }
  while ($hget($nban,%a) != $null) {
    hadd $nban $calc(%a - 1) $hget($nban,%a)
    inc %a
  }
  hdel $nban $calc(%a - 1)
}
alias bhostadd {
  if ($1 isnum) return
  .auser 20 $1
}
alias bhostdel {
  if ($1 isnum) return
  .ruser 20 $1
}

alias bans {
  if ($bannum(1) == $null) {
    iecho No bans recorded.
    return
  }
  iecho Recorded bans $+ $iif($1,: for $1)
  var %a, %y, %z
  set %a 1
  while ($bannum(%a)) {
    set %z $ifmatch
    if (($1) && (!$istok($blinfo(%z,chans),$1,44))) { inc %a | continue } 
    if ($blinfo(%z,expire) > 0) set %y (expires at $bantime($ifmatch)
    set %y (perm)
    echo -a [[ $+ $lfix(3,%a) $+ ]] %z %y $iif($blinfo(%z,sticky) == $true,(sticky))
    echo -a $fix(5) $blinfo(%z,setby) $+ : $blinfo(%z,reason)
    echo -a $fix(5) Channels: $blinfo(%z,chans)
    set %y $bantime($blinfo(%z,setdate))
    if ($blinfo(%z,lastused)) set %y %y $+ , last used $bantime($ifmatch)
    echo -a $fix(5) Created %y
    inc %a
  }
  iecho End of banlist.
}
alias addban {
  if ($1 == $null) {
    iecho Syntax: /addban <hostmask> <channels> [reason]
    return
  }
  if (*!*@* !iswm $1) {
    iecho Error! Use the format: $hc(nick!ident@host) for hostmasks. Wildcards are acceptable.
    return
  }
  if (($bhost($1)) || ($bhosth($1))) {
    iecho A ban matching $hc($1) already exists!
    return
  }
  var %a, %y, %z
  if ($2) set %y $2
  else set %y $$?="Channels (enter 'all' for all chans)"
  if ($3) set %z $3-
  else set %z $?="Reason"
  if (%z == $null) set %z request
  blwrite $1 ban $true
  blwrite $1 setby $nvar(owner)
  blwrite $1 setdate $ctime
  blwrite $1 lastused 0
  blwrite $1 expire 0
  blwrite $1 sticky $false
  blwrite $1 chans %y
  blwrite $1 reason %z
  bhostadd $1
  bnumadd $1
  colupdt3 $1
  if (%y == all) set %y $mychans
  set %a 1
  var %c, %n
  while ($gettok(%y,%a,44) != $null) {
    set %c $ifmatch
    if (($me isop %c) || ($me ishop %c)) {
      queue mode %c +b $1
      set %n $gettok($ial($1),1,33)
      if (%n ison %c) queue kick %c %n :banned: %z
    }
    inc %a
  }
  queue

  if ($show) iecho Shitlisted $hc($1) successfully.
}
alias remban {
  if ($1 == $null) {
    iecho Syntax: /remban <hostmask>
    return
  }
  var %z = $1
  if ($1 isnum) set %z $bannum($1)
  if ($blinfo(%z,ban) == $null) {
    iecho No such ban $hc(%z)
    return
  }
  bhostdel %z
  ;  blwrite %z *
  blwrite %z
  bnumdel %z
  colupdt3 %z

  var %a = 0, %b, %c, %d
  while ($gettok($mychans,0,44) > %a) {
    inc %a
    %b = $gettok($mychans,%a,44)
    if (($me isop %b) || ($me ishop %b)) {
      set %c 0
      while ($ibl(%b,0) > %c) {
        inc %c
        set %d $ibl(%b,%c)
        if (%d == %z) mode %b -b %z
      }
    }
  }
  if ($show) iecho Ban on $hc(%z) has been removed.
}
alias stickban {
  if ($1 == $null) {
    iecho Syntax: /stickban <hostmask>
    return
  }
  var %z = $1
  if ($1 isnum) set %z $bannum($1)
  if ($blinfo(%z,ban) == $null) {
    iecho No such ban $hc(%z)
    return
  }
  blwrite %z sticky $true
  if ($show) iecho Ban $hc(%z) has been stuck.
}
alias unstickban {
  if ($1 == $null) {
    iecho Syntax: /unstickban <hostmask>
    return
  }
  var %z = $1
  if ($1 isnum) set %z $bannum($1)
  if ($blinfo(%z,ban) == $null) {
    iecho No such ban $hc(%z)
    return
  }
  blwrite %z sticky $false
  if ($show) iecho Ban $hc(%z) has been unstuck.
}
alias urehashbans {
  var %a, %b, %x, %y, %z, %i = $sd($nban(ini))
  if ($hget($nban)) hfree $nban
  ; .rlevel 20
  hmake $nban 128
  set %a 1
  while ($ini(%i,%a)) {
    set %z $ifmatch
    if ($ini(%i,%z,ban)) bnumadd %z
    else {
      inc %a
      continue
    }
    set %b 1
    while ($ini(%i,%z,%b)) {
      set %y $ifmatch
      set %x $readini(%i,n,%z,%y)
      hadd $nban $instok(%y,%z,0,44) %x
      inc %b
    }
    bhostadd %z
    inc %a
  }
  savebanlist
}
alias loadbanlist {
  if ($hget($nban)) hfree $nban
  hmake $nban 128
  var %a = $sd($nban(ban))
  var %b = $sd($nban(ini))
  if ($isfile(%a) == $false) {
    if ($show)  iecho Hashing banlist...
    urehashbans
    return
  }
  hload $nban %a
  if ($hget($nban,crc) != $crc(%b)) {
    iecho Error: banlist CRC mismatch!
    urehashbans
  }
}
alias savebanlist {
  if (!$hget($nban)) return
  if ($show) iecho Saving banlist...

  var %a = $sd($nban(ini))
  var %b = $sd($nban(ban))

  hadd $nban crc $crc(%a)
  hsave -o $nban %b
}
alias match {
  var %a, %b, %c, %h = $1
  set %a 1
  if (%h == $null) {
    iecho Syntax: /match <wildcard-string> or /match <attr> [channel]
    return
  }
  if (* !isin %h) set %h * $+ $1 $+ *
  if (!$hfind($nusr,%h,0,w)) return
  iecho Matching ' $+ %h $+ ':
  iiecho $fix(9,HANDLE) PASS BOTPASS NOTES FLAGS
  window -h @userlist.match
  clear @userlist.match
  while ($hfind($nusr,%h,%a,w) != $null) {
    set %b $ifmatch
    if ((*!*@* !iswm %b) && (user,* !iswm %b)) { inc %a | continue }
    if (user,* iswm %b) match.result $gettok(%b,2-,44)
    elseif ($hget($nusr,%b))   match.result $ifmatch
    inc %a
  }
  close -@ @userlist.match
}
alias -l match.result {
  if ($fline(@userlist.match,$1,0)) return
  echo @userlist.match $1
  iiecho $fix(9,$1) $fix(4,$iif($ulinfo($1,pass),yes,no)) $fix(7,$iif($ulinfo($1,botpass),yes,no)) $fix(5,$numnotes($1)) $ulinfo($1,flags) 
  var %i = 1,%x,%y
  while ($gettok($ulinfo($1,chans),%i,44)) {
    set %x $ifmatch
    if ($ulinfo($1,flags,%x)) set %y $ifmatch
    else set %y -
    iiecho   $fix(26,%x) %y
    if ($ulinfo($1,info,%x)) iiecho  #INFO: $ifmatch
    inc %i
  }
  if ($ulinfo($1,hosts)) {
    set %x $ifmatch
    iiecho $lfix(8,HOSTS:) $gettok(%x,1,32)
    set %i 2
    while ($gettok(%x,%i,32) != $null) {
      iiecho $fix(8) $gettok(%x,%i,32)
      inc %i
    }
  }
  else iiecho $lfix(8,HOSTS:) none
  if ($ulinfo($1,info)) iiecho $lfix(7,INFO:) $ifmatch
}
alias ufind {
  var %a = 1, %b, %c, %d = 1, %e, %f
  iiecho -a . $+ $str(-,53) $+ .
  iiecho -a $vl Users on $fix(42,$hc(#)) $vl
  iiecho -a $vl $+ $str(-,53) $+ $vl
  iiecho -a $vl $lfix(10,Nick) $fix(7) Username $lfix(9,Level) $lfix(15,$vl)
  while ($nick(#,%a) != $null) {
    set %b $ifmatch
    set %c $usr(%b)
    set %e $address(%b,5)
    set %f $ulcolor($level(%e),$iif($level(%e) == 40,$usrh(%e),%e),%b)
    if (%c) {
      if ($chkflag(%c,*,b)) {
        if ($chkflag(%c,#,f)) iiecho -a $vl $lfix(4,%d) $+ . $fix(12,$c(%f $+ %b)) $fix(12,%c) $fix(19,protected bot) $vl
        else iiecho -a $vl $lfix(4,%d) $+ . $fix(12,$c(%f $+ %b)) $fix(12,%c)  $fix(19,bot) $vl
      }
      elseif ($chkflag(%c,#,o)) {
        if ($chkflag(%c,#,f)) iiecho -a $vl $lfix(4,%d) $+ . $fix(12,$c(%f $+ %b)) $fix(12,%c) $fix(19,protected op) $vl
        else iiecho -a $vl $lfix(4,%d) $+ . $fix(12,$c(%f $+ %b)) $fix(12,%c)  $fix(19,op) $vl
      }
      elseif ($chkflag(%c,#,v)) {
        if ($chkflag(%c,#,f)) iiecho -a $vl $lfix(4,%d) $+ . $fix(12,$c(%f $+ %b)) $fix(12,%c) $fix(19,protected voice) $vl
        else iiecho -a $vl $lfix(4,%d) $+ . $fix(12,$c(%f $+ %b)) $fix(12,%c) $fix(19,voice) $vl
      }
      elseif ($chkflag(%c,#,f)) iiecho -a $vl $lfix(4,%d) $+ . $fix(12,$c(%f $+ %b)) $fix(12,%c)  $fix(19,protected) $vl
      else iiecho -a $vl $lfix(4,%d) $+ . $fix(12,$c(%f $+ %b)) $fix(12,%c)  $fix(19,user) $vl
      inc %d
    }
    inc %a
  }
  iiecho -a ' $+ $str(-,53) $+ '
}
on 1:CHAT:Enter your password.:{
  if (($nvar(userlist.botautopass) == on) && (($chkflag($usr($nick),*,b)) && ($botpass($usr($nick))))) .msg =$nick $botpass($usr($nick))
}
alias -l _popup.userlist.listhosts {
  if ($1 isnum) {
    if ($gettok($ulinfo($2,hosts),$1,32))  return $1 $+ . $gettok($ulinfo($2,hosts),$1,32) : $3-  $gettok($ulinfo($2,hosts),$1,32)
  }
}
