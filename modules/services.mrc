; add dialog for /silence list and silence iignore dialog
; dccallow list
; /quiet #chan nick nick ... quit nick or host, or display
menu channel {
  E&xtras
  .Internal List
  ..$iif(q isincs $gettok($chanmodes,1,44),Update Quiet List $cmdtip(updqal)):updqal
}

on *:signal:nloaded:{
  ;load network support files

  var %ntype, %itype
  set %ntype $nget(networksupport.type)
  set %itype $nget(ircdsupport.type)

  if (%ntype == -Disabled-) { }
  elseif ((%ntype == $null) || (-Auto isin %ntype))  .ntimer loadnetsupport 1 1  loadnetsupport $$curnet(noserver)
  elseif (%ntype)  .ntimer loadnetsupport 1 1 loadnetsupport %ntype

  ;load ircd support file
  if (%itype == -Disabled-)  { }
  elseif ((%itype == $null) || (-Auto isin %itype))  .ntimer loadircdsupport 1 1 loadircdsupport $$curircd
  elseif (%itype) .ntimer loadircdsupport 1 1 loadircdsupport %itype


  if ($ncid(bypass_serviceauth)) { iecho bypass service | ncid -r bypass_serviceauth | goto end }
  ; authenticate
  var %auth.u = $me
  if ($nget($tab(auth,~global~, alwaysmatch))) set %auth.u $ifmatch

  if ($nget($tab(auth,%auth.u,onconnect))) {
    var %cmd = $nget($tab(auth,%auth.u,authcmd))
    var %a = $iif($nget($tab(auth,%auth.u,nickserv)),$ifmatch,nickserv)
    var %pw = $nget($tab(auth,%auth.u,passwd))
    if (!%cmd) set %cmd msg %a identify <pass>
    set %cmd $replace(%cmd,<pass>,%pw,<username>,%auth.u,<user>,%auth.u)
    iecho -s Sending Authenticate command
    ntimer AUTH 1 0 . $+ %cmd
    ncid authing 1
    .timer 1 4 ncid -r authing
  }

  if ($nget(services.chanserv.autoinvite)) {
    .ntimer chanserv.autoinvite 1 5 .echo -q $ $+ whilearray($nget(services.chanserv.autoinvite), 44, .putmsg $iifelse($nget(services.chanserv.nickname),chanserv) invite) 
  }


  if ($nvar(detectservices) != off) && ($nget(detectservices) != off) {
    if ((!$nget(defaultservices)) && (!$nget(defaultservices.checked))) .ntimer servicescheck 1 60 services.checksupport 
  }

  :end
}
on *:DISCONNECT:{
  ; unload ircd / network support file when no longer needed
  var %n = $nget(networksupport)
  var %i = $nget(ircdsupport)
  if ($script(%n $+ .nwrk)) {
    ;undernet, efnet, dalnet, etc
    if (!$netsup.num(%n) <= 1) {  .unload -nrs %n $+ .nwrk | nset networksupport }
  }
  if ($script(%i $+ .ircd)) {
    ;ratbox, unreal, hybrid
    if ($ircdsup.num(%i) <= 1) {  .unload -nrs %i $+ .ircd | nset networksupport }
  }
}
raw 433:*:{
  .ntimer auth.ghostcheck 1 1 auth.ghost.check $1-
}
alias auth.ghost.check {
  var %u = $2
  if ($nget($tab(auth,~global~, alwaysmatch))) {
    var %u = $ifmatch
  }

  if ($nget($tab(auth,%u,ghost))) {
    var %cmd = $nget($tab(auth,%u,ghostcmd))
    if (!%cmd) set %cmd msg nickserv ghost <pass>
    var %pw = $nget($tab(auth,%u,passwd))
    set %cmd $replace(%cmd,<pass>,%pw,<username>,%u,<user>,%u)
    iecho -s Sending Ghost command
    ntimer autho.sendauth 1 1 . $+ %cmd

    if ($nget($tab(auth,%u,reget))) .timer 1 1 nick %u
  }
}
on *:NOTICE:*:?:{
  if ($ncid(authing)) return
  if ($ncid(authreqcheck))  auth.identify.check $nick $1-
}
on *:NICK:{
  if ($nick == $me)   ncid -u30 authreqcheck 1
}
alias auth.identify.check {
  var %u = $me
  if ($nget($tab(auth,~global~, alwaysmatch)))  var %u = $ifmatch

  if ($nget($tab(auth,%u,onrequest))) {
    var %a = $nget($tab(auth,%u,requestnick))
    var %b = $nget($tab(auth,%u,requestwc))
    if (($1 == %a) && (%b iswm $strip($2-))) {
      ncid -r authreqcheck
      var %pw = $nget($tab(auth,%u,passwd))
      var %cmd = $nget($tab(auth,%u,authcmd))
      if (!%cmd) set %cmd msg nickserv identify <pass>
      set %cmd $replace(%cmd,<pass>,%pw,<username>,%u,<user>,%u)
      iecho -s Sending Authenticate command
      if (!$ncid(authing)) ntimer AUTH 1 0 . $+ %cmd

      ncid authing 1
      .timer 1 4 ncid -r authing
    }
  }
}
on *:CONNECT:{
  if ($ncid(server_silence)) ncid can_silence $true
}
menu status,channel  {
  $iif(($nget(defaultservices) && $svc.ispopupok($menutype)),Services)
  .$style(2) $tab - Network Services - :!
  ..$iif(N isincs $nget(defaultservices),NickServ)
  ..Identify: .nickserv Identify $$input( $me Password:,p,Nickserv Identify Password,$nget($tab(auth,$me,passwd))  ) 
  ..Register:nickserv.register
  ..Access
  ...Add:nickserv access add $$input(Hostmask,e,Nickserv Add access hostmask,$address($me,3)) 
  ...Del:nickserv access del $$input(Hostmask,e,Nickserv Delete access hostmask,$address($me,3)) 
  ...Wipe:if ($$input(Are you sure you want to WIPE your entire nickserv access list?,y)) nickserv access wipe
  ...-
  ...List:nickserv access list
  ..Settings
  ...Password:.nickserv set password $$input(Current Password:,e,Nickserv Set Password command) $$input(New Password:,e,Nickserv Set Password command)
  ...Email:nickserv set email $$input($paren(Required) Password:,p,Nickserv Set Email command)  $$input(New Email:,e,Nickserv Set Email command)
  ...-
  ...$style(2) - Toggles -  :!
  ...Enforce
  ....On:nickserv set enforce on
  ....Off:nickserv set enforce off
  ...MailBlock
  ....On:nickserv set mailblock on
  ....Off:nickserv set mailblock off
  ...NoMemo
  ....On:nickserv set nomemo on
  ....Off:nickserv set nomemo off
  ...NoOp
  ....On:nickserv set noop on
  ....Off:nickserv set noop off
  ...ShowEmail
  ....On:nickserv set showemail on
  ....Off:nickserv set showemail off
  ...URL
  ....Set:nickserv set url $$input(URL:,e,Nickserv Set URL Command $paren(cancel to clear url))
  ....Unset:nickserv set url 
  ..-
  ..Recover:iecho  .nickserv recover $$input( Nickname:,e,Nickserv Recover command) $input($paren(Optional) Password:,p)
  ..Release:iecho  .nickserv recover $$input( Nickname:,e,Nickserv Release command) $input($paren(Optional) Password:,p)
  ..Drop:nickserv Drop $$input(Nickname:,e,Nickserv Drop command,$me)
  ..Ghost:nickserv Ghost $$input(Nickname:,e,Nickserv Ghost command,$me) $input($paren(Optional) Password:,p)
  ..Info?:nickserv info $$input(Nickname:,e,Nickserv Info command,$me)
  ..Access?:nickserv Acc $$input(Nickname:,e,Nickserv ACC command,$me)  
  ..Sendpass:nickserv Sendpass $$input(Nickname:,e,Nickserv Sendpass command,$me)  $$input(Email:,e,Nickserv Sendpass command,$email)
  ..-
  ..Change Cmd $tab $brak($shorttext(20,$iifelse($nget(services.nickserv.cmd),/msg Nickserv))) :nset services.nickserv.cmd $$input(Enter the command for Nickserv queries [ $crlf ] [ $crlf ] ex: /msg nickserv,e,Nickserv Command,$iifelse($nget(services.nickserv.cmd),/msg nickserv))
  ..&Help 
  ...&Help:nickserv help
  ...-
  ...Access:nickserv help Access
  ...Settings
  ....Email:nickserv help set email
  ....Enforce:nickserv help set enforce
  ....Mailblock:nickserv help set mailblock
  ....NoMemo:nickserv help set nomemo
  ....NoOp:nickserv help set noop
  ....Password:nickserv help set password
  ....ShowEmail:nickserv help set showemail
  ....URL:nickserv help set URL
  ...Identify:nickserv help Identify
  ...Recover:nickserv help Recover
  ...Release:nickserv help Release
  ...Drop:nickserv help Drop
  ...Ghost:nickserv help Ghost
  ...Register:nickserv help Register
  ...Info:nickserv help Info
  ...Acc:nickserv help Acc
  ...Sendpass:nickserv help Sendpass
  .$iif(C isincs $nget(defaultservices),ChanServ)
  ..Identify:!
  ..Register:.chanserv register  $$input(Channel:,e,Chanserv Register,#) $$input(Password,e,Chanserv Register Password) $$input(Description:,e, Chanserv Register Descriptions)
  ..Settings
  ...Founder:!
  ...Password:! 
  ...Successor:!
  ...Description:!
  ...Hold Modes:.chanserv set # mlock $$input(Lock these modes:,e,Channel Mode lock,$chan(#).mode)
  ...-
  ...$style(2) - Toggles -  :!
  ...Ident
  ....On:!
  ....Off:!
  ...KeepTopic
  ....On:!
  ....Off:!
  ...MailBlock
  ....On:!
  ....Off:!
  ...Op Guard
  ....On:!
  ....Off:!
  ...Leaves Ops
  ....On:!
  ....Off:!
  ...Private
  ....On:!
  ....Off:!
  ...Restrict
  ....On:!
  ....Off:!
  ...Memo
  ....None:!
  ....AOP:!
  ....SOP:!
  ....Founder:!
  ...Unsecure
  ....On:!
  ....Off:!
  ..-
  ..Super Op
  ...Add:!
  ...Del:!
  ...-
  ...List:!
  ..Auto OP
  ...Add:!
  ...Del:!
  ...-
  ...List:!
  ..Auto Kick
  ...Add:!
  ...Del:!
  ...-
  ...List:!
  ..Drop:!
  ..Sendpass:!
  ..Access?:!
  ..Invite:chanserv invite $$input(Invite to Channel:,e,Chanserv invite)
  ..Info?:chanserv info $$input(Channel:,e,Chanserv Info,#)
  ..Count?:chanserv count $$input(Channel:,e,Chanserv Info,#)
  ..Why?:chanserv Why $$input(Channel:,e,Chanserv Why,#) $$input(Nickname:,e,Chanserv why)
  ..-
  ..Change Cmd $tab $brak($shorttext(20,$iifelse($nget(services.chanserv.cmd),/msg Chanserv))) :nset services.chanserv.cmd $$input(Enter the command for Chanserv queries [ $crlf ] [ $crlf ] ex: /msg chanserv,e,Chanserv Command,$iifelse($nget(services.chanserv.cmd),/msg chanserv))
  ..Help:chanserv help
  .$iif(M isincs $nget(defaultservices),MemoServ)
  ..List:memoserv List
  ..Read:!
  ..Send:!
  ..Settings
  ...a:!
  ..-
  ..Del:!
  ..Foward:!
  ..Ignore:!
  ..Info:memoserv info
  ..News:!
  ..Purge:iecho $$input(Are you sure you want to empty the deleted memos from the inbox?,y)
  ..Undel:!
  ..SendSOP:!
  ..-
  ..Change Cmd $tab $brak($shorttext(20,$iifelse($nget(services.memoserv.cmd),/msg Memoserv))) :nset services.memoserv.cmd $$input(Enter the command for Memoserv queries [ $crlf ] [ $crlf ] ex: /msg memoserv,e,Memoserv Command,$iifelse($nget(services.memoserv.cmd),/msg memoserv))
  ..Help:memoserv help

  .$iif(o isincs $usermode,OperServ)
  ..Userlist:.operserv userlist
  .-
  .Help
  ..Common services help:!

  . $style(2) $tab - Toggles - :!
  .$toggled($nvar(services.onlyshowinstatus)) Only Show in Status Window:nvartog services.onlyshowinstatus
}


alias services.checksupport {
  if ($nget(networksupport)) return
  if ($nget(detectservices) == off) return

  if (-f !isin $1) {  
    if (($nget(defaultservices)) || ($nget(defaultservices.checked))) return
  }
  nset defaultservices
  nset defaultservices.checked

  var %q = Nickserv:N Memoserv:M Chanserv:C
  ncid -u60 servicescheck.who %q

  var %a = 1, %b
  while ($gettok(%q, %a, 32) != $null) {
    set %b $gettok($gettok(%q,%a,32),1,58)
    queue who %b
    inc %a
  }

  queue
}
raw 352:*:{
  var %q = $ncid(servicescheck.who)
  var %y
  if (!%q) return
  if ($wildtok(%q, $6 $+ :* , 1,32)) {
    set %y $ifmatch
    if (H isincs $7) {
      nset defaultservices $addtok($nget(defaultservices), $gettok(%y, 2, 58), 32)
    }
    nset defaultservices.checked $ctime
    halt
  }
}
raw 315:*:{
  var %q = $ncid(servicescheck.who)
  var %y
  if (!%q) return

  if ($wildtok(%q, $2 $+ :* , 1,32)) {
    set %y $ifmatch
    ncid servicescheck.who $remtok( $ncid(servicescheck.who),  %y, 1, 32)
    if ((!$ncid(servicescheck.who)) && ($nget(defaultservices))) {
      iecho -s Discovered default network services: $hc($iif(N isin $nget(defaultservices),NickServ)  $iif(C isincs $nget(defaultservices),ChanServ)  $iif(M isincs $nget(defaultservices),MemoServ) )
      nset netservices $iif(N isin $nget(defaultservices),NickServ)  $iif(C isincs $nget(defaultservices),ChanServ)  $iif(M isincs $nget(defaultservices),MemoServ) 
    }
  }
}
alias sup.popcmode {
  ; <chan> <mode> <require> <network/ircd> <menucontext>  <text>

  ;; add $variables to mode

  ; checked = 1, disabled = 2, both = 3
  ; ex: $sup.popcmode(#, p, op, rizon, channel/mode, Paranoia	+p) { togglecmode # c }

  ; $1 = chan, mode = $2, require = $3, text = $4-
  if ($nget(collapse. $+ $4 $+ menu. $+ $5)) return 
  var %q
  if ($left($2,1) == ~) {
    set %q $remove($eval($replace($2,~,$),2),off) 
    var %s = 1
    if ($remove($3,-)) var %s = $popcmode.flags($1, $iif($prop == and,AND,OR), $3)
    return $style($iif(%q, $iif(%s,1,3), $iif(!%s, 2))) $6-
  }
  if ($2 isincs $chanmodes) {
    var %s = 1
    if ($remove($3,-)) var %s = $popcmode.flags($1, $iif($prop == and,AND,OR), $3)
    return $style($iif($2 isincs $gettok($chan($1).mode, 1, 32), $iif(%s,1, 3) , $iif(!%s, 2) )) $6-
  }
}
alias sup.popumode {
  ;  <mode> <require> [hide] <network/ircd> <menucontext> <text>
  ; checked = 1, disabled = 2, both = 3
  ;ex: $sup.popumode(A,A, hide, rizon, status/umode, Admin	+A) { toggleumode A }

  var %s = 1, %t, %netircd, %menucontext
  if ($3 == hide) { var %hide = $true | set %netircd $4 | set %menucontext $5 | set %t $6- }
  else { set %netircd $3 | set %menucontext $4 | set %t $5- }

  if ($nget(collapse. $+ %netircd $+ menu. $+ %menucontext)) return 

  if ($remove($2,-)) {
    var %s = $popumode.flags($iif($prop == and,AND,OR), $2)
    if (!%s) && (%hide) return
  }

  return $style( $iif($1 isincs $usermode, $iif(%s,1, 3) , $iif(!%s, 2) )) %t
}
alias svc.ispopupok {
  if ($ncid(services.disable)) return
  if ($ncid(services.disablepopups)) return

  if ($1 == status) {
    if ($ncid(services.disablestatuspopups)) return
    if (($ncid(services.disablestatuspopups.ifnodefault)) && (!$nget(defaultservices))) return
    if (($nget(defaultservices)) || ($ncid(can_silence)) || ($ncid(can_dccallow)) || ($nget(networksupport))) return $true
  }
  if ($1 == nicklist) {
    if ($nget(netservices.shownicklist)) return $true

  }
  if ($1 == channel) {
    if ($ncid(services.disablechannelpopups)) return
    if ($nget(netservices.nochanpop)) return
    if (!$nvar(services.onlyshowinstatus)) return $true

    if (($nvar(services.onlyshowinstatus)) && ($window($active).type != status)) return $false
    else return $true
  }
}
alias -l nickserv.register {

  var %p = $$input(Password:,e,Nickserv Registration Password)
  var %e = $$input(email,e,Nickserv Registration Email,$email)

  var %b = $input(Would you like to auto authenticate into this account on connect?,y)
  if (%b) {
    var %q = $iifelse($nget(services.nickserv.cmd),Nickserv)
    set %q $iif($left(%q,1) != /,/) $+ %q
    nset $tab(auth,$me,authcmd) %q IDENTIFY <pass>
    nset $tab(auth,$me,ghostcmd) %q GHOST <username> <pass>
    nset $tab(auth,$me,onconnect) on
    nset $tab(auth,$me,onrequest) on
    nset $tab(auth,$me,passwd) %p
    nset $tab(auth,$me,requestnick) nickserv
    nset $tab(auth,$me,requestwc) *type /msg nickserv IDENTIFY pass*
  }

  nickserv register %p %e
}
alias nickserv {
  ; if ($cmdbox) { .quote nickserv $1- | return }
  var %c = $triml($iifelse($nget(services.nickserv.cmd),Nickserv), $cmdchar)
  ; why do i have this cmdbox thing again? not all servers have the alias progammed in
  if ($gettok(%c,1,32) == nickserv) set %c .quote nickserv $gettok(%c,2-,32)
  .timer 1 0 $iif(!$show,.) $+ %c $1-
}
alias chanserv {
  ;  if ($cmdbox) { .quote chanserv $1- | return }
  var %c = $triml($iifelse($nget(services.chanserv.cmd),Chanserv), $cmdchar)
  ; why do i have this cmdbox thing again? not all servers have the alias progammed in
  if ($gettok(%c,1,32) == chanserv) set %c .quote chanserv $gettok(%c,2-,32)
  .timer 1 0 $iif(!$show,.) $+ %c $1-
}
alias memoserv {
  ; why do i have this cmdbox thing again? not all servers have the alias progammed in
  ; if ($cmdbox) { .quote memoserv $1- | return }
  var %c = $triml($iifelse($nget(services.memoserv.cmd),Memoserv), $cmdchar)
  ; why do i have this cmdbox thing again? not all servers have the alias progammed in
  if ($gettok(%c,1,32) == memoserv) set %c  putmsg memoserv  $gettok(%c,2-,32)
  .timer 1 0 $iif(!$show,.) $+ %c $1-
}
alias operserv {
  ; if ($cmdbox) { .quote memoserv $1- | return }
  var %c = $triml($iifelse($nget(services.operserv.cmd),Operserv), $cmdchar)
  if ($gettok(%c,1,32) == operserv) set %c .quote operserv $gettok(%c,2-,32)
  .timer 1 0 $iif(!$show,.) $+ %c $1-
}
on *:DIALOG:ircn.servicesilence:init:0:{
  var %a = 1
  while ($hget($cid $+ .ircn.services.silence,%a).item != $null) {
    did -a $dname 3 $ifmatch
    inc %a
  }
}
on *:DIALOG:ircn.servicesilence:sclick:4:dlg ircN.servicesilence.add
on *:DIALOG:ircn.servicesilence:sclick:6:{
  if (!$did(3).sel) return
  var %a = $$input(Are you sure you would like to remove the silence of [ $crlf ] [ $crlf ] $did(3).seltext,y)
  if (%a) {
    .quote silence - $+ $did(3).seltext
    did -d $dname 3 $did(3).sel
  }
}
on *:DIALOG:ircn.servicesilence.add:edit:2:{
  var %a = $did(2), %b
  if (! !isin %a) {
    set %b $ial(%a $+ !*@*)
    if (%b) {
      var %q = 1
      while (%q <= 6) { did -d $dname 2 1 | inc %q }
      did -a $dname 2 %a
      did -a $dname 2 $address(%a,0)
      did -a $dname 2 $address(%a,1)
      did -a $dname 2 $address(%a,2)
      did -a $dname 2 $address(%a,3)
      did -a $dname 2 $address(%a,4)
    }
  }
  elseif (*!*@* iswm %a) {
    var %q = 1
    while (%q <= 6) { did -d $dname 2 1 | inc %q }
    did -a $dname 2 %a
    did -a $dname 2 $mask(%a,0)
    did -a $dname 2 $mask(%a,1)
    did -a $dname 2 $mask(%a,2)
    did -a $dname 2 $mask(%a,3)
    did -a $dname 2 $mask(%a,4)
  }
}
dialog ircn.servicesilence {
  title "Silence List"
  size -1 -1 179 149
  option dbu
  tab "Active List", 1, 2 3 174 121
  list 3, 5 23 122 95, tab 1 size vsbar hsbar
  button "Refresh", 7, 130 97 43 16, tab 1
  tab "Permenent List", 2
  list 8, 5 34 122 77, tab 2 size vsbar hsbar  check
  check "Enabled", 10, 6 20 60 10, tab 2
  text "Will be re-set when connecting to this network.", 13, 6 113 165 11, tab 2
  button "Edit", 5, 129 38 43 16
  button "Delete", 6, 129 56 43 16
  button "Add", 4, 129 21 43 16
  button "Clear", 9, 129 73 43 16
  button "OK", 11, 135 128 42 17, ok
  button "Cancel", 12, 91 128 42 17, cancel
}
dialog ircN.servicesilence.add {
  title "Add Silence"
  size -1 -1 157 76
  option dbu
  icon $gfxdir(icons\ircn.ico), 0
  text "Nick or Address to ignore (nick!ident@host.com)", 1, 1 2 146 8, center
  combo 2, 2 10 144 66, size edit drop
  check "Remove in:", 14, 39 44 38 10
  combo 15, 80 44 26 150, disable size edit drop
  combo 16, 110 44 36 150, disable size drop
  button "OK", 17, 112 60 37 12, ok default
  button "Cancel", 18, 72 60 37 12, cancel
  check "Make permenent (re-set on connect)", 3, 39 31 107 11
}
dialog ircN.service.callerid {
  title "CallerID Settings"
  size -1 -1 139 185
  option dbu
  button "Add", 2, 95 22 33 15
  button "Del", 3, 95 39 33 15
  button "Clear", 4, 95 59 33 15
  tab "Active", 5, 2 3 133 156
  combo 1, 8 23 84 107, tab 5 size
  text "These nicknames will be allowed to msg you while your callerID (+g) user mode is set.", 8, 8 131 123 25, tab 5
  tab "Permenent", 6
  combo 7, 8 23 84 107, tab 6 size
  text "The permenent list will re-add these nicknames to your allowed list when you enable callerID (+g) user mode.", 9, 8 131 123 25, tab 6
  button "Apply", 10, 102 164 34 18, ok
}
on *:DIALOG:ircN.servicesilence.add:sclick:17:did -a ircN.servicesilence 3 $did(2)
on *:DIALOG:ircN.servicesilence:close:0:if ($dialog($dname $+ .add)) dialog -x $dname $+ .add

on *:USERMODE:{
  var %u = $removecs($usermode,+,w,i,s,o,O)
  ncid umode_unknown %u
  .signal -n umode_unknown $cid
}
alias _popup.netsupport.networks {
  var %a
  if ($1 == begin) return -
  if ($1 isnum) {
    set %a $gettok($ntmp(_cache.netsupport.networks), $1, 44)
    if (%a)   return  $iif(($iifelse($nget(networksupport.type),-Auto Detect-) == -Auto Detect- && $nget(networksupport) == %a),$style(3),$iif($nget(networksupport.type) == %a,$style(1)))  $firstcap(%a) : _switchsup.net %a
  }
  if ($1 == end) return -
}
alias _popup.netsupport.ircds {
  var %a
  if ($1 == begin) return -
  if ($1 isnum) {
    set %a $gettok($ntmp(_cache.netsupport.ircds), $1, 44)
    if (%a)   return $iif(($iifelse($nget(ircdsupport.type),-Auto Detect-) == -Auto Detect- && $nget(ircdsupport) == %a),$style(3),$iif($nget(ircdsupport.type) == %a,$style(1)))  $firstcap(%a) :_switchsup.ircd %a
  }
  if ($1 == end) return -
}
alias netsup.num {
  var %a = 1, %b
  while ($scon(%a) != $null) {
    scon %a
    if ($nget(networksupport) == $1) {
      if (%b == $2) && ($2) return %a
      inc %b
    }
    inc %a
  }
  scon -r
  if ($2 == 0) return %b
  return %b
}
alias ircdsup.num {
  var %a = 1, %b
  while ($scon(%a) != $null) {
    scon %a
    if ($nget(ircdsupport) == $1) {
      inc %b
      if (%b == $2) && ($2) return %a
    }
    inc %a
  }
  scon -r
  if ($2 == 0) return %b
  return %b
}
alias loadnetsupport {
  if (!$0) return
  var %f = $netdir($1 $+ .nwrk)

  if (!$isfile(%f)) return
  if ($show) iecho -s Loading network specific support file ( $+ $nopath(%f) $+ )

  nset networksupport $1

  if (!$netsup.num($1)) .load -rs2 %f
  elseif (!$script(%f))  .load -rs2 %f

  .signal loadnetsupport $cid $nopath(%f)
  .signal umode_unknown $cid

}
alias loadircdsupport {
  if (!$0) return

  var %f = $ircddir($1 $+ .ircd)

  if (!$isfile(%f)) return
  if ($show) iecho -s Loading ircd specific support file ( $+ $nopath(%f) $+ )

  nset ircdsupport $1

  if (!$ircdsup.num($1)) .load -rs2 %f
  elseif (!$script(%f))  .load -rs2 %f

  .signal loadircdsupport $cid $nopath(%f)
  .signal umode_unknown $cid

}
alias unloadnetsupport {
  var %a = 1
  while ($script(%a)) {
    var %b = $ifmatch

    if (*.ircd iswm $nopath(%b)) {  .unload -nrs %b | continue }
    if (*.nwrk iswm $nopath(%b)) {  .unload -nrs %b | continue }

    inc %a
  }
}
alias _switchsup.net {
  var %oldnet.type = $nget(networksupport.type)
  var %oldnet = $nget(networksupport)

  if ($1- == %oldnet.type) return

  if (%oldnet) && ($netsup.num(%oldnet) == 1) && ($script(%oldnet $+ .nwrk)) {
    .signal -n unloadnetsupport $cid %oldnet
    .unload -nrs %oldnet $+ .nwrk
  }

  if ($1- == -Disabled-) { nset networksupport  }
  elseif ($1- == -Auto Detect-) {  nset networksupport |  loadnetsupport $curnet(noserver) }
  else loadnetsupport $1-

  nset networksupport.type $1-
}
alias _switchsup.ircd {
  var %oldircd.type = $nget(ircdsupport.type)
  var %oldircd = $nget(ircdsupport)

  if ($1- == %oldircd.type) return

  if (%oldircd) && ($ircdsup.num(%oldnet) == 1) && ($script(%oldircd $+ .nwrk)) {
    .signal -n unloadircdsupport $cid %oldnet
    .unload -nrs %oldircd $+ .ircd
  }

  if ($1- == -Disabled-) {  nset ircdsupport }
  elseif ($1- == -Auto Detect-) {  nset ircdsupport |  loadircdsupport $curircd }
  else   loadircdsupport $1-

  nset ircdsupport.type $1-
}
alias netsup2scid {
  var %a = 1, %b, %c,  %n, %n2, %x = $1-
  while (%a <= $scon(0)) {
    set %b $scon(%a)
    set %n $ncid($scid(%b),network)
    set %n2 $nget($scid(%b),networksupport)
    if (%n == $null) set %n $scid(%b).network
    if (%n == $null) set %n $server($scid(%b).server).group
    if (%n == $null) set %n $scid(%b).server

    if ($numtok(%x,32) > 1) {
      if ($nethash2set(%n2) == %x) return $scon(%a).cid 
    }

    else if (%n == %x) return $scon(%a).cid
    inc %a
  }
}
on ^*:INVITE:#:{
  ; do this better
  if ($nick == $iifelse($nget(services.chanserv.nickname),chanserv)) {
    iecho -s Autojoining $hc($chan) by the request of $hc($nick) $rbrk($address)
    if ($istok($nget(chanserv.chan.autoinvite),$chan,44)) join -n $chan
    halt
  }
}
ON *:UNLOAD:{
  unloadnetsupport
}
