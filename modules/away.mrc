;%%%%%%%%%%%%%%%%%%%%%%%%
;script ircN Custom Script
;version 9.00
;author ircN Development Team
;email ircn@ircN.org
;url http://www.ircN.org
;%%%%%%%%%%%%%%%%%%%%%%%%

; DONE - add 'reset away on input'
; DONE - minimize on away
; add networks specific settings and networked logview
; DONE - close queries
; block queries - how is this going to work?
; DONE - convert vars to hash; $modvar /modvar /modvarinc /modvardec /modvarload /modvarsave /modvarkill
; DONE - goto the 1st tab that has something logged when you return; add numbers of msgs, files, etc

menu menubar {
  ;  &Modules
  &Away
  .Settings:awaysettings
  .-
  .$iif(!$away,Set Away)
  ..&Dialog:setaway
  ..-
  ..Silent
  ...$iif($scon(0) > 1,Global) { .gaway $$?="Away message" }
  ...-
  ...$network:.away $$?="Away message"
  ..Default
  ...$iif($scon(0) > 1,Global) { .gaway $modvar(away,default.away) }
  ...-
  ...$network:.away $modvar(away,default.away)
  ..Verbose
  ...$iif($scon(0) > 1,Global) { gaway $$?="Away message" }
  ...-
  ...$network:away $$?="Away message"

  .$iif($away,Return)
  ..Silent
  ...$iif($scon(0) > 1,Global) { .gback }
  ...-
  ...$network:.back
  ..Default
  ...$iif($scon(0) > 1,Global) { .gback $modvar(away,default.back) }
  ...-
  ...$network:.back $modvar(away,default.back)
  ..Verbose
  ...$iif($scon(0) > 1,Global) { .gback $$?="Return message" }
  ...-
  ...$network:.back $$?="Return message" 
  .-
  .Log:awaylog
  .- 
  .$iif(#, $shorttext(20,#))
  ..$style(2) - Channel Actions - : !
  ..$iif($istok($modget(away,chans),$chan,44),Remove,Add) $shorttext(20,#):modset away chans $iif($istok($modget(away,chans),$chan,44),$remtok($modget(away,chans),$chan,1,44),$addtok($modget(away,chans),$chan,44))
}
; menubar channel {
;  .$iif($menu == channel,Channels)
;  ..$iif($menu == channel,$style(2) Channel Actions $+ $chr(58)):return
;  ..$iif($menu == channel,$iif($istok($modget(away,chans),$chan,44),Remove $chan,Add $chan)):modset away chans $iif($istok($modget(away,chans),$chan,44),$remtok($modget(away,chans),$chan,1,44),$addtok($modget(away,chans),$chan,44))
;  .$submenu($_popup.sub(channel, away, $1))
; }
on 1:DISCONNECT:{
  if ($modget(away,modsetloaded)) {
    moddel away $cid modsetloaded
    modsetsave away $cid
  }
  modsetkill away $cid
}


on 1:START:modvarload 8 away
on 1:EXIT:modvarsave away
on 1:UNLOAD:{
  modvarsave away
  modvarkill away
}
on 1:LOAD:{
  modvarload 8 away
  if (!$isdir($logdirawaylog)) mkdir $qt($logdirawaylog\)
  if (!$modvar(away,default.back)) modvar away default.back back
  if (!$modvar(away,default.away)) modvar away default.away idle
  if (!$modvar(away,resetaway)) modvar away resetaway on
  if (!$modvar(away,autoidle)) modvar away autoidle 3600
  if (!$modvar(away,autoreason)) modvar away autoreason autoaway
  if (!$modvar(away,autosilent)) modvar away autosilent on
  if (!$modvar(away,aidlemsg)) modvar away aidlemsg <rand>
  if (!$modvar(away,msglog)) modvar away msglog on
  if (!$modvar(away,pager)) modvar away pager off
  if (!$modvar(away,chantype)) modvar away chantype only
  iecho Type $hc(/awaysettings) for Away Settings or use the ircN menu -> Setup -> Module -> Away
}
alias -l away.file return $qt($logdirawaylog\ $+ $iif($ncid(network),$ncid(network),$server) $+ . $+ $1 $+ . $+ log)
alias aidle {
  if ($timer($ntimer(aidle))) unidle
  var %a = $chr(35) $+ $rand(a,z) $+ $rndstr($rand(5,7))
  modvar away idlechan %a
  .quote join %a
  ntimer aidle 0 $iif($modvar(away,aidledelay),$modvar(away,aidledelay),60) aidle.cmd
}
alias unidle {
  var %a = $modvar(away,idlechan)
  modvar away idlechan
  ntimer aidle off
  if ($me ison %a) { 
    var %b = $chan(%a).logfile
    part %a
    if ($isfile(%b)) .timer 1 1 .remove %b
  }
}
alias gaway scid -a $iif(!$show,.) $+ away $1-
alias gback scid -a $iif(!$show,.) $+ back $1-
alias away {
  var %t
  if ($flags($1-,n)) var %a.nick = $flags($1-,n).val
  if ($flags($1-).flags) set %t $flags($1-).text
  else set %t $1-
  modvar away awaymsg $iif(%t,%t,$modvar(away,default.away)) 
  modset away awaymsg $iif(%t,%t,$modvar(away,default.away)) 
  modvar away awaytime $ctime
  modset away awaytime $ctime
  if (($show) && ($server) && ($modvar(away,chantype) != none)) {
    var %a = 1
    while ($chan(%a)) {
      if (($modvar(away,chantype) == only) && (!$istok($modget(away,chans),$chan(%a),44))) { inc %a | continue }
      if (($modvar(away,chantype) == except) && ($istok($modget(away,chans),$chan(%a),44))) { inc %a | continue }
      if ($form(client,awaymsg)) describe $chan(%a) $form(client,awaymsg).val
      else {
        _describe $chan(%a) is away, $iifelse($modget(away,awaymsg),$modvar(away,awaymsg)) [l $+ $u(/) $+ $modvar(away,msglog) $+ ][p $+ $u(/) $+ $modvar(away,pager) $+ ] $+ $iif($modvar(away,showemail) == on,[e $+ $u(/) $+ $email $+ ]) $+ $iif($modvar(away,showim) == on,[i $+ $u(/) $+ $modvar(away,im) $+ ])
      }
      ;      else describe $chan(%a) is away, $modvar(away,awaymsg) [l $+ $u(/) $+ %msglog $+ ][p $+ $u(/) $+ %pager $+ ] $+ $iif($modvar(away,showemail) == on,[e $+ $u(/) $+ $email $+ ]) $+ $iif($modvar(away,showim) == on,[i $+ $u(/) $+ $modvar(away,.im) $+ ])
      inc %a
    }
  }
  if ($server) .quote away : $+ $iifelse($modget(away,awaymsg),$modvar(away,awaymsg))
  if (($modvar(away,awaynick) == on) || ($modvar(away,a.nick))) {
    modvar away backnick $me
    if ($modvar(away,a.nick)) nick $replace($modvar(away,a.nick),<ME>,$me)
    else nick $replace($iif($modvar(away,nick),$modvar(away,nick),$addtok($me,[afk],0)),<ME>,$me)
  }
  if ($modvar(away,aidle) == on) aidle
  if ($modget(away,awaymsg)) {
    var %z = $md(awayreasons.dat)
    if (!$read(%z,nw,$modget(away,awaymsg))) {
      if ($lines(%z) > 10) write -c %z
      write -il1 %z $modget(away,awaymsg)
      if ($dialog(ircn.setaway)) did -i ircn.setaway 2 1 $modget(away,awaymsg)
    }
  }
  if ($modvar(away,nosound) == on) && ($hget(sounds)) hadd sounds sthemes off
  if ($modvar(away,minimize) == on) .timer 1 3 showmirc -m
  .signal away
}
alias -l _describe {
  set -u1 %:echo echo $color(action) -ti2 $1 | set -u1 %::target $1 | set -u1 %::chan $1 | set -u1 %::nick $1
  set -u1 %::text $2-
  putserv PRIVMSG $1 :ACTION $2- 
  theme.text ActionChanSelf
  unset %::text %:echo %::target %::chan %::nick
}
alias back {
  if (!$away) {
    iecho You are not away.
    return
  }
  var %a = 1, %b = $iif($1-,$1-,$iif($modget(away,awaymsg),$modget(away,awaymsg),$modvar(away,default.back)))
  if (($show) && ($modvar(away,chantype) != none)) {
    while ($chan(%a)) {
      if (($modvar(away,chantype) == only) && (!$istok($modget(away,chans),$chan(%a),44))) { inc %a | continue }
      if (($modvar(away,chantype) == except) && ($istok($modget(away,chans),$chan(%a),44))) { inc %a | continue }
      if ($form(client,backmsg)) describe $chan(%a) $thm.ircn.client.backmsg(%b)
      else {
        _describe $chan(%a) is back, %b $+ , gone $gone
        ;echo -t $chan(%a) $c $+ $colour(action) $thm.ircn.channel.action($me,a,is back, %b $+ , gone $gone)
      }
      ;      else describe $chan(%a) is back, %b $+ , gone $gone
      inc %a
    }
  }
  if ($server) .quote away
  if ($modvar(away,backnick)) { nick $modvar(away,backnick) | modvar away backnick }
  resetidle
  unidle
  if ($modvar(away,logsback) == on) {
    if ($findfile($qt($logdirawaylog\),$nopath($away.file(*)),0)) awaylog
  }
  if ($modvar(away,nosound) == on) && ($hget(sounds)) hadd sounds sthemes on
  modvar away awaytime
  modset away awaytime
  modvar away awaymsg
  modset away awaymsg
  modvar away knowaway
  modset away knoaway
  modvarsave away
  .signal back
}
alias msglog.add {
  ;msglog.add highlight
  var %a, %b, %x
  set %a $ctime
  set %x msg page notice highlight file
  if (!$isdir($logdirawaylog)) mkdir $qt($logdirawaylog\)
  writeini -n $away.file($1) logged $addtok(%a,$ticks,44) $2-
  if ($dialog(ircN.awaylog)) {
    set %b  $calc($findtok(%x,$1,1,32) + 5) 
    did -e ircn.awaylog $calc($findtok(%x,$1,1,32) + 16)
    did -a ircN.awaylog %b $ini($away.file($1),logged,0) $+ .) $iif(($5 == sent && $1 == file),Sent to,Received from) $2 on $asctime(%a,mm/dd/yy) at $asctime(%a,hh:nn:sstt) $+ .
    did -c ircn.awaylog %b $did(ircn.awaylog,%b).lines
    .timer 1 0 awaylog.showinfo ircn.awaylog %b $did(ircn.awaylog,%b).lines
  }
}
; when the hash table's loaded it signals 'nloaded' .. use this when reading from loaded items instead of 
;on 1:connect because the hashtable doesnt get loaded untill it finds the network

on 1:SIGNAL:nloaded:{
  modsetload 10 away
  unidle

  modvar away idlechan
  if (($modvar(away,resetaway) == on) && ($modget(away,awaytime)) && ($server)) {
    .quote away : $+ $modget(away,awaymsg)
    if ($modvar(away,aidle) == on) aidle
  }
  else {
    modset away awaytime
    modset away awaymsg
  }
}
on 1:JOIN:$($modvar(away,idlechan)):{
  if ($nick == $me) {
    mode $chan +imnsptl 1
    iecho -w $chan This is the anti-idle channel.. it will stay hidden and close when you come back from antiidle
    .timer 1 2 if ( $me ison $chan ) window -h $chan
  }
}
on *:PART:$($modvar(away,idlechan)):if ($nick == $me) unidle
alias aidle.cmd {
  if (($me ison $modvar(away,idlechan)) && ($server)) {
    msg $modvar(away,idlechan) $replace($iif($modvar(away,aidlemsg),$modvar(away,aidlemsg),<rand>),<rand>,$rndstr($rand(5,10)))
  }
}
on *:INPUT:*:if ($away) && ($modvar(away,input) == on) && ($left($1,1) != /) .timerback 1 3 .back $modvar(away,default.back)
on *:TEXT:*:#:{
  if ($modvar(away,announcer) != on) || (!$away) return
  var %a = 1, %b, %c
  while ($gettok($modvar(away,announcenick),%a,44)) {
    set %b $replace($ifmatch,<ME>,$me)
    if (%b isin $strip($1-)) {
      if (($away) && ($modget(away,awaytime))) {
        if (!$istok($modvar(away,knowaway),$nick,44)) {
          if ($modvar(away,announcemeth) == act) set %c describe #
          elseif ($modvar(away,announcemeth) == chan)  set %c msg #
          else set %c .notice $nick
          %c i am away, $modget(away,awaymsg) $+ , gone $gone $iif($modvar(away,show.email) == on,$chr(91) $+ $email $+ $chr(93))
          modvar away knowaway $addtok($modvar(away,knowaway),$nick,44)
        }
        if ($modvar(away,log.highlight) == on) msglog.add highlight $nick $address $chan $curnet $strip($1-)
      }
    }
    inc %a
  }
}
on *:NOTICE:*:?: {
  if ($away) {
    if ($nick == $+($chr(40), ezbounce, $chr(41))) return
    if ($modvar(away,log.notice) == on) {
      msglog.add notice $nick $address $curnet $strip($1-)
      if (!$istok($modvar(away,knowaway),$nick,44)) {
        .notice $nick Your message has been recorded, away for $gone ( $+ $modget(away,awaymsg) $+ ) $iif($modvar(away,show.email) == on,$chr(91) $+ $email $+ $chr(93))
        modvar away knowaway $addtok($modvar(away,knowaway),$nick,44)
      }
    }
  }
}
on *:FILERCVD:*:if (($away) && ($modvar(away,msglog) == on) && ($modvar(away,log.file) == on)) msglog.add file $nick $address $filename RCVD
on *:FILESENT:*:if (($away) && ($modvar(away,msglog) == on) && ($modvar(away,log.file) == on)) msglog.add file $nick $address $filename SENT

ctcp *:PAGE:?:{
  if ($modvar(away,pager) == on) {
    msglog.add page $nick $address $curnet $strip($2-)
    if ($modvar(away,stheme.page) == on) tsound page
    elseif ($exists($modvar(away,pagesound))) .splay $modvar(away,pagesound)
    if (!$istok($modvar(away,knowaway),$nick,44)) {
      if ($away) .notice $nick Your page has been received, away for $gone ( $+ $modget(away,awaymsg) $+ ) $iif($modvar(away,show.email) == on,$chr(91) $+ $email $+ $chr(93))
      else .notice $nick Your page has been received.
    }
  }
}

on *:TEXT:*:?:{
  if ($away) {
    if (!$istok($modvar(away,knowaway),$nick,44)) {
      .notice $nick i am away, $modget(away,awaymsg) $+ , gone $gone $iif($modvar(away,show.email) == on,$chr(91) $+ $email $+ $chr(93))
      modvar away knowaway $addtok($modvar(away,knowaway),$nick,44)
    }
    if ($modvar(away,msglog) == on) {
      msglog.add msg $nick $address $curnet $strip($1-)
      if (!$istok($modvar(away,knowaway),$nick,44)) {
        .notice $nick Your message has been recorded, away for $gone ( $+ $modget(away,awaymsg) $+ ) $iif($modvar(away,show.email) == on,$chr(91) $+ $email $+ $chr(93))
        modvar away knowaway $addtok($modvar(away,knowaway),$nick,44)
      }
    }
    if ($modvar(away,closeq) == on) close -m $nick
  }
}

alias awaylog dlg ircN.awaylog
dialog ircN.awaylog {
  title "ircN Away Logging"
  size -1 -1 302 154
  option dbu
  tab "Messages", 1, 3 0 295 146
  list 6, 8 17 286 50, tab 1 size vsbar
  edit "", 11, 8 69 286 52, read multi vsbar
  tab "Pages", 2
  list 7, 8 17 286 50, tab 2 size vsbar
  tab "Notices", 3
  list 8, 8 17 286 50, tab 3 size vsbar
  tab "Highlights", 4
  list 9, 8 17 286 50, tab 4 size vsbar
  ;edit "", 14, 8 69 286 52, tab 4 read multi vsbar
  tab "Files Sent/Received", 5
  list 10, 8 17 286 50, tab 5 size vsbar
  edit "", 15, 8 69 286 52, tab 5 read multi vsbar
  button "Delete All", 17, 157 125 35 15, tab 1 disable
  button "Delete All", 18, 157 125 35 15, tab 2 disable
  button "Delete All", 19, 157 125 35 15, tab 3 disable
  button "Delete All", 20, 157 125 35 15, tab 4 disable
  button "Delete All", 21, 157 125 35 15, tab 5 disable

  button "Delete", 22, 106 125 35 15, tab 1 disable
  button "Delete", 23, 106 125 35 15, tab 2 disable
  button "Delete", 24, 106 125 35 15, tab 3 disable
  button "Delete", 25, 106 125 35 15, tab 4 disable
  button "Delete", 26, 106 125 35 15, tab 5 disable

}
alias -l _msglog.addlistall {
  var %a,%b,%c = 1, %d = msg page notice highlight file, %e, %f, %g = $1
  did -r %g 6,7,8,9,10
  while ($gettok(%d,%c,32)) {
    set %e $ifmatch
    if (($exists($away.file(%e))) && ($ini($away.file(%e), logged,0) >= 1)) {
      set %a 1
      did -e %g $calc(%c + 16)
      while (%a <= $ini($away.file(%e), logged,0)) {
        set %b $ini($away.file(%e), logged, %a)
        tokenize 32 $readini($away.file(%e), n, logged, %b)
        set %f %a $+ .) Received from $1 on $asctime($gettok(%b,1,44),mm/dd/yy) at $asctime($gettok(%b,1,44),hh:nn:sstt) $+ .
        if (($4 == SENT) && (%e == file)) set %f $replace(%f,Received from,Sent to)
        did -a %g $calc(%c + 5) %f
        inc %a
      }
    }
    inc %c
  }
}
alias _msglog.addlist {
  var %a,%b,%dlg = $1,%did = $2,%f,%x = msg page notice highlight file
  set %e $gettok(%x,$calc(%did - 5),32)
  if (($exists($away.file(%e))) && ($ini($away.file(%e), logged,0) >= 1)) {
    set %a 1
    did -e $1 $calc(%did + 16)
    while (%a <= $ini($away.file(%e), logged,0)) {
      set %b $ini($away.file(%e), logged, %a)
      tokenize 32 $readini($away.file(%e), n, logged, %b)
      set %f %a $+ .) Received from $1 on $asctime($gettok(%b,1,44),mm/dd/yy) at $asctime($gettok(%b,1,44),hh:nn:sstt) $+ .
      if (($4 == SENT) && (%e == file)) set %f $replace(%f,Received from,Sent to)
      did -a %dlg %did %f
      inc %a
    }
  }
}
alias awaylog.showinfo {
  var %a, %b, %c, %dlg, %did, %sel, %x = msg page notice highlight file
  set %c $gettok(%x,$calc($2 - 5),32)
  set %b $ini($away.file(%c),logged,$3)
  if ($3) did -e $1 $calc($2 + 16)
  else did -b $1 $calc($2 + 16)
  did -r $1 11
  set %dlg $1
  set %did $2
  set %sel $3
  tokenize 32 $readini($away.file(%c), n, logged, %b)
  if ($4 == SENT) did -i %dlg 11 $did(%dlg,11).lines Sent to: $1
  else did -i %dlg 11 $did(%dlg,11).lines From: $1
  did -i %dlg 11 $did(%dlg,11).lines Address: $2
  if (%c != file) did -i %dlg 11 $did(%dlg,11).lines Network: $iif(%c == highlight,$4,$3)
  did -i %dlg 11 $did(%dlg,11).lines Date: $asctime($gettok(%b,1,44),mm/dd/yy)
  did -i %dlg 11 $did(%dlg,11).lines Time: $asctime($gettok(%b,1,44),hh:nn:sstt)
  if ($did == 9) did -i %dlg 11 $did(%dlg,11).lines Channel: $3
  if ($istok(sent.rcvd,$4,46)) did -i %dlg 11 $did(%dlg,11).lines Filename: $3
  if (%c != file)  did -i %dlg 11 $did(%dlg,11).lines $crlf $+ $iif(%c == highlight,$5-,$4-)
  did -c %dlg 11 1
}
alias -l awaylog.update {
  var %a = 0, %n = ircN.awaylog
  did -ra %n 1 Messages: $did(6).lines
  if ($did(6).lines) set %a 1
  did -ra %n 2 Pages: $did(7).lines
  if ($did(7).lines) set %a 2
  did -ra %n 3 Notices: $did(8).lines
  if ($did(8).lines) set %a 3
  did -ra %n 4 Highlights: $did(9).lines
  if ($did(9).lines) set %a 4
  did -ra %n 5 Files Sent/Received: $did(10).lines
  if ($did(10).lines) set %a 5
  if ($1) && (%a) .timer 1 0 did -f %n %a
}
on *:dialog:ircN.awaylog:*:*:{
  var %a, %b, %c, %d, %e, %x = msg page notice highlight file
  var %n = $dname
  if ($devent == init) {
    _msglog.addlistall $dname
    awaylog.update 1
  }
  if ($devent == sclick) {
    if ($did isnum 1-5) {
      set %b $calc($did + 5)
      did -r %n 11
      if ($did(%b).sel) .timer 1 0 awaylog.showinfo %n %b $did(%b).sel
      elseif ($did(%b).lines) { did -c %n %b 1 | .timer 1 0 awaylog.showinfo $dname %b $did(%b).sel }
    }
    if (($did isnum 6-10) && ($did($did).sel)) awaylog.showinfo $dname $did $did($did).sel
    if ($did isnum 22-26) { 
      set %a msg page notice highlight file
      set %b $away.file( $gettok(%a,$calc($did - 21),32) )
      set %c $calc($did - 16)
      set %d $did(%c).sel
      set %e $ini(%b,logged,%d)
      remini %b logged %e
      if (!$ini(%b,logged,0)) .remove $away.file( $gettok(%a,$calc($did - 21),32) )
      did -d $dname %c %d
      did -r $dname %c
      _msglog.addlist $dname %c
      if (!$did(%c).lines) { 
        did -b $dname $did $+ , $+ $calc($did - 5)
        did -r $dname 11
      }
      else { did -c $dname %c $did(%c).lines | awaylog.showinfo $dname %c $did(%c).lines }
      awaylog.update
    }
    if ($did isnum 17-21) {
      set %a msg page notice highlight file
      set %b $away.file($gettok(%a,$calc($did - 16),32))
      did -r $dname $calc($did - 11)
      if ($isfile(%b)) .remove %b
      did -b $dname $did $+ , $+ $calc($did + 5)
      did -r $dname 11
      awaylog.update
    }
  }
}
dialog ircn.awaysettings {
  title "ircN Away Settings"
  size -1 -1 230 148
  option dbu
  tab "Settings", 1, 4 12 223 119
  check "Re-set away on connect", 17, 138 96 71 10, tab 1
  check "Disable Sound Themes", 16, 138 82 70 10, tab 1
  check "Away Nick:", 15, 14 82 40 10, tab 1
  edit "", 18, 58 82 50 10, disable tab 1 center
  text "Default Away:", 51, 14 40 40 8, tab 1 right
  text "Default Back:", 52, 14 54 40 8, tab 1 right
  edit "", 53, 58 39 50 10, tab 1 center
  edit "", 54, 58 53 50 10, tab 1 center
  check "Show E-mail", 56, 14 96 40 10, tab 1
  check "Show IM:", 57, 14 110 40 10, tab 1
  edit "", 58, 58 110 46 10, disable tab 1 center
  box "Options", 14, 8 29 215 98, tab 1
  check "Return on input", 60, 138 110 50 10, tab 1
  check "Close queries", 61, 138 68 50 10, tab 1
  check "Block queries", 62, 138 54 50 10, tab 1, disable
  check "Minimize on away", 63, 138 40 52 10, tab 1
  tab "Channels", 2
  radio "All", 7, 14 42 29 8, tab 2
  radio "None (silent)", 10, 14 58 45 8, tab 2
  radio "All Except:", 9, 16 82 38 8, tab 2
  radio "Only:", 8, 16 98 29 8, tab 2
  list 11, 58 76 80 33, disable tab 2 sort size
  button "Del", 13, 140 97 15 10, disable tab 2
  button "Add", 12, 140 109 15 10, disable tab 2
  edit "", 47, 58 109 80 11, disable tab 2 center
  box "Away Channels", 6, 8 29 215 99, tab 2
  tab "Logging", 3
  check "Highlights", 23, 164 104 40 10, tab 3
  check "DCCs", 22, 164 88 40 10, tab 3
  check "Pages", 21, 164 72 40 10, tab 3
  check "Notices", 20, 164 56 40 10, tab 3
  check "Messages", 19, 164 40 40 10, tab 3
  check "Show logs on return", 55, 14 37 58 10, tab 3
  box "Log:", 64, 156 30 60 92, tab 3
  tab "Auto Away", 4
  check "Enabled", 24, 14 36 34 10, tab 4
  text "Limit:", 25, 24 56 24 8, disable tab 4 right
  edit "", 26, 52 55 19 10, disable tab 4 limit 3 center
  text "minutes", 27, 73 56 21 8, disable tab 4
  text "Reason:", 28, 24 72 24 8, disable tab 4 right
  edit "", 29, 53 72 100 10, disable tab 4 center
  check "Silent", 30, 26 88 26 8, disable tab 4
  tab "Anti Idle", 5
  check "Enabled", 31, 14 36 34 10, tab 5
  text "Message:", 32, 26 56 26 8, disable tab 5 right
  edit "", 33, 56 55 51 10, disable tab 5 center
  text "Delay:", 34, 26 72 26 8, disable tab 5 right
  edit "", 35, 56 71 22 10, disable tab 5 center
  text "minutes", 36, 80 72 26 8, disable tab 5
  tab "Announcer", 59
  check "Enabled", 37, 12 36 34 10, tab 59
  text "Matchlist:", 38, 103 69 30 8, disable tab 59 right
  list 39, 136 68 67 42, disable tab 59 sort size
  button "Del", 42, 204 100 16 10, disable tab 59
  button "Add", 41, 204 112 16 10, disable tab 59
  edit "", 40, 136 112 67 11, disable tab 59 center
  text "Method:", 43, 18 72 27 8, disable tab 59 right
  radio "Action", 44, 52 71 36 11, disable tab 59
  radio "Notice", 45, 52 83 36 11, disable tab 59
  radio "Channel", 46, 52 95 36 11, disable tab 59
  text "Network:", 49, 149 2 27 8, right
  combo 50, 179 1 48 100, size drop
  button "Close", 48, 191 134 37 12, default ok
}
on 1:dialog:ircn.awaysettings:sclick:50:{
  var %d = $dname
  ;msgs: 53,54 awaynickcheckbox: 15 anick: 18
  ;away chan list: 11
  if ($did($did).sel == 2) did -c %d 50 1
  _refresh.awaychans
  _refresh.enable.disable
}
alias _refresh.enable.disable {
  var %d = ircn.awaysettings
  if ($did(%d,50).sel >= 3) {
    did -e %d 11,12,13,47
    did -b %d 7-10,63,61,16,17,19,20,21,22,23,24,26,29,30,37,40,41,42,44,45,46,55,60,53,54,15,56,57,31,33,35
    did -c %d 2
  }
  else {
    did -b %d 11,12,13,47
    did -e %d 7-10,63,61,16,17,19,20,21,22,23,24,26,29,30,37,40,41,42,44,45,46,55,60,53,54,15,56,57,31,33,35
  }
}
alias _refresh.awaychans {
  var %d = ircn.awaysettings,%i = 1
  did -r %d 11
  if (($did(%d,50).sel <= 2) || (!$did(%d,50).sel)) { did -a %d 11 Select a network first! | return }
  var %cid = $net2scid($did(%d,50).seltext), %x = $numtok($modget(away,%cid,chans),44)
  while (%i <= %x) {
    did -a %d 11 $gettok($modget(away,%cid,chans),%i,44)
    inc %i
  }
}
on 1:dialog:ircn.awaysettings:init:*:{
  var %d = $dname, %a = 0
  _ircn.setup.addnetcombo %d 50
  if ($modvar(away,chantype) == all) did -c %d 7
  if ($modvar(away,chantype) == only) {
    did -c %d 8
    did -e %d 11,47,12
  }
  if ($modvar(away,chantype) == except) {
    did -c %d 9
    did -e %d 11,47,12
  }
  if ($modvar(away,chantype) == none) did -c %d 10
  if ($modvar(away,awaynck) == on) {
    did -c %d 15
    did -e %d 18
  }
  did -ra %d 18 $modvar(away,a.nick)
  if ($modvar(away,minimize) == on) did -c %d 63
  if ($modvar(away,blockq) == on) did -c %d 62
  if ($modvar(away,closeq) == on) did -c %d 61
  if ($modvar(away,input) == on) did -c %d 60
  if ($modvar(away,nosounds) == on) did -c %d 16
  if ($modvar(away,resetaway) == on) did -c %d 17
  if ($modvar(away,logmsg) == on) did -c %d 19
  if ($modvar(away,lognotice) == on) did -c %d 20
  if ($modvar(away,logpage) == on) did -c %d 21
  if ($modvar(away,logfile) == on) did -c %d 22
  if ($modvar(away,loghightlight) == on) did -c %d 23

  if ($modvar(away,logsback) == on) did -c %d 55
  if ($modvar(away,showemail) == on) did -c %d 56
  if ($modvar(away,showim) == on) {
    did -c %d 57
    did -e %d 58
  }
  did -ra %d 58 $modvar(away,im)
  did -ra %d 53 $modvar(away,default.away)
  did -ra %d 54 $modvar(away,default.back)
  if ($modvar(away,nosound) == on) did -c %d 16
  if ($modvar(away,msglog) == on) did -c %d 19
  if ($modvar(away,log.notice) == on) did -c %d 20
  if ($modvar(away,log.page) == on) did -c %d 21
  if ($modvar(away,log.file) == on) did -c %d 22
  if ($modvar(away,log.highlight) == on) did -c %d 23
  if ($modvar(away,autoaway) == on) {
    did -c %d 24
    did -e %d 25,26,27,28,29,30
  }
  did -ra %d 26 $calc($modvar(away,autoidle) / 60)
  did -ra %d 29 $modvar(away,autoreason)
  if ($modvar(away,autosilent) == on) did -c %d 30
  if ($modvar(away,aidle) == on) {
    did -c %d 31
    did -e %d 32,33,34,35,36
  }
  did -ra %d 33 $iif($modvar(away,aidlemsg),$modvar(away,aidlemsg),<rand>)
  did -ra %d 35 $iif($modvar(away,aidledelay),$calc($modvar(away,aidledelay) / 60),1)
  if ($modvar(away,announcer) == on) {
    did -c %d 37
    did -e %d 38,39,40,41,43,44,45,46
  }
  ;  did -ra %d 43 $modvar(away,announcenick)
  set %a 0
  while ($gettok($modvar(away,announcenick),0,44) > %a) {
    inc %a
    did -a %d 39 $gettok($modvar(away,announcenick),%a,44)
  }
  if ($modvar(away,announcemeth) == act) did -c %d 44
  elseif ($modvar(away,announcemeth) == chan) did -c %d 46
  else did -c %d 45
  _refresh.awaychans
  _refresh.enable.disable
}
on 1:dialog:ircn.awaysettings:sclick:*:{
  var %a, %d = $dname, %cid = $net2scid($did(%d,50).seltext)
  if ($did == 7) || ($did == 10) did -b %d 11,47,13,12
  if ($did == 8) || ($did == 9) did -e %d 11,47,12
  if ($did == 12) && ($did(47)) {
    set %a $iif($left($did(47),1) == $chr(35),$did(47),$chr(35) $+ $did(47))
    did -a %d 11 %a
    modset away %cid chans $addtok($modget(away,%cid,chans),%a,44)
    did -ra %d 47
  }
  if ($did == 13) && ($did(11).seltext) {
    modset away %cid chans $remtok($modget(away,%cid,chans),$did(11).seltext,1,44)
    did -d %d 11 $did(11).sel
    did -b %d 13
  }
  if ($did == 15) {
    if ($did(15).state) did -e %d 18
    else did -b %d 18
  }
  if ($did == 57) {
    if ($did(57).state) did -e %d 58
    else did -b %d 58
  }
  if ($did == 24) {
    if ($did(24).state) did -e %d 25,26,27,28,29,30
    else did -b %d 25,26,27,28,29,30
  }
  if ($did == 31) {
    if ($did(31).state) did -e %d 32,33,34,35,36
    else did -b %d 32,33,34,35,36
  }
  if ($did == 37) {
    if ($did(37).state) did -e %d 38,39,40,41,43,44,45,46
    else did -b %d 38,39,40,41,42,43,44,45,46
  }
  if (($did == 11) && ($did(11).seltext)) did -e %d 13
  if (($did == 39) && ($did(39).seltext)) did -e %d 42
  if ($did == 41) {
    set %a $did(40)
    did -a %d 39 %a
    modvar away announcenick $addtok($modvar(away,announcenick),%a,44)
    did -ra %d 40
  }
  if ($did == 42) {
    modvar away announcenick $remtok($modvar(away,announcenick),$did(39).seltext,1,44)
    did -d %d 39 $did(39).sel
    did -b %d 42
  }
  if ($did == 48) {
    modvar away default.away $did(53)
    modvar away default.back $did(54)

    if ($did(15).state) modvar away awaynick on
    else modvar away awaynick off


    modvar away a.nick $did(18)

    if ($did(56).state) modvar away showemail on
    else modvar away showemail off
    if ($did(57).state) modvar away showim on
    else modvar away showim off
    modvar away im $did(58)
    if ($did(63).state) modvar away minimize on
    else modvar away minimize off
    if ($did(62).state) modvar away blockq on
    else modvar away blockq off
    if ($did(61).state) modvar away closeq on
    else modvar away closeq off
    if ($did(16).state) modvar away nosound on
    else modvar away nosound off
    if ($did(17).state) modvar away resetaway on
    else modvar away resetaway off
    if ($did(60).state) modvar away input on
    else modvar away input off
    if ($did(55).state) modvar away logsback on
    else modvar away logsback off
    if ($did(7).state) modvar away chantype all
    if ($did(8).state) modvar away chantype only
    if ($did(9).state) modvar away chantype except
    if ($did(10).state) modvar away chantype none
    if ($did(19).state) modvar away msglog on
    else modvar away msglog off
    if ($did(20).state) modvar away log.notice on
    else modvar away log.notice off
    if ($did(21).state) modvar away log.page on
    else modvar away log.page off
    if ($did(22).state) modvar away log.file on
    else modvar away log.file off
    if ($did(23).state) modvar away log.highlight on
    else modvar away log.highlight off
    if ($did(24).state) modvar away autoaway on
    else modvar away autoaway off
    modvar away autoidle $calc($did(26) *60)
    modvar away autoreason $did(29)
    if ($did(30).state) modvar away autosilent on
    else modvar away autosilent off
    if ($did(31).state) modvar away aidle on
    else modvar away aidle off
    modvar away aidlemsg $did(33)
    modvar away aidledelay $calc($did(35) * 60)
    if ($did(37).state) modvar away announcer on
    else modvar away announcer off
    if ($did(44).state) modvar away announcemeth act
    if ($did(45).state) modvar away announcemeth not
    if ($did(46).state) modvar away announcemeth chan
  }
}
alias awaysettings if (!$dialog(ircn.away)) dlg ircn.awaysettings
dialog ircn.setaway {
  title "Set Away"
  size -1 -1 144 33
  option dbu
  text "Away Reason:", 1, 2 3 36 13
  combo 2, 41 2 101 55, size edit drop
  button "&Away", 3, 82 20 29 11
  button "&Back", 4, 112 20 29 11
  check "Silent", 5, 2 21 27 9
  check "Global", 6, 29 21 27 9, disable
}
on 1:dialog:ircn.setaway:init:*:{
  if ($away) did -b $dname 3
  else did -b $dname 4
  if ($modvar(away,chantype) == none) did -c $dname 5
  if ($isfile($md(awayreasons.dat))) loadbuf -o $dname 2 $md(awayreasons.dat)
  if ($did(2).lines) did -c $dname 2 1
  if ($scon(0) > 1) { did -e $dname 6 | did -c $dname 6 }
}
on 1:dialog:ircn.setaway:sclick:3:{
  did -b $dname 2,3
  did -e $dname 4
  $iif($did(5).state,.) $+ $iif($did(6).state,g) $+ away $did(2)
}
on 1:dialog:ircn.setaway:sclick:4:{
  did -b $dname 4
  did -e $dname 3,2
  $iif($did(5).state,.) $+ $iif($did(6).state,g) $+ back $did(2)
}
alias setaway if (!$dialog(ircn.setaway)) dlg ircn.setaway
on *:signal:ircn.online:{
  if (($away == $false) && ($modvar(away,autoaway) == on) && ($idle >= $modvar(away,autoidle))) {
    $iif($modvar(away,autosilent) == on,.) $+ away $iif($modvar(away,autoreason),$modvar(away,autoreason),autoaway)
  }
}
