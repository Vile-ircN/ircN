;%%%%%%%%%%%%%%%%%%%%%%%% 
;script ircN 7 -> 8 Transfer
;version BETA 1
;author mruno
;email mruno@ircN.org 
;url http://www.ircN.org 
;info incorporates some ircN 7 code that was made by Quietust and Sarek (refer to oldcode alias)
;%%%%%%%%%%%%%%%%%%%%%%%%
alias -l add echo -ag $1- needs to be added
on 1:LOAD:{
  .timer 1 1 iecho This is a $c $+ 4 $+ $b(BETA!) $o $+ Please email $hc(mruno@ircN.org) if you find any bugs. (/itransfer)
}
alias -l itw {
  did -ra itransfer 4 $1-
  did -ra itransfer 68 Log to file $paren($lines($logdiritransfer.log))
}
alias -l itwl {
  var %a itransfer
  did -f %a 52
  did -a %a 53 $1- $crlf
  if ($did(%a,68).state) write $logdiritransfer.log $adate $+ @ $+ $atime $1-
}
alias -l ite var %a = $input($1-,wo,Error)
alias -l itq return $input(Do you want to overwrite the file: $1- $+ ?,yi,Overwrite?)
alias -l itq2 return $input(Do you want to add the $1- $+ ?,yi,Add $1- $+ ?)
alias -l itq3 return $input(Do you want to $iif($did(itransfer,64).state,move,copy) the file $1- $+ ?,yi,$iif($did(itransfer,64).state,Move,Copy) $1- $+ ?)
alias -l fileconv {
  var %d = itransfer
  var %a = 0, %b, %path = $did(%d,2), %z
  while ($did(%d,47).lines > %a) {
    inc %a 
    did -c %d 47 %a
    set %b $did(%d,47).seltext
    if ($did(%d,71).state) write -c $td(fileXfer.bat)
    if (%b == servers) {
      set %z SYSTEM\servers.ini
      if ($did(%d,63).state) {
        if ($did(%d,71).state) write $td(fileXfer.bat) xcopy /e $iif($did(%d,65).state,/y) %path $+ %z $mircdir
        else if ($itq($mircdirserver.ini)) .copy -o %path %+ %z $mircdirservers.ini
      }
      else if ($itq($mircdirserver.ini)) .rename -o %path %+ %z $mircdirservers.ini
    }
    if ($gettok(%b,1,32) == Logs:) {
      var %a = $readini($did(%d,2) $+ SYSTEM\mirc.ini,dirs,logdir), %b = 0, %c, %path, %e, %f, %z = $readini($mircini,dirs,logdir)
      if ($did(%d,71).state) && ($did(%d,63).state) write $td(fileXfer.bat) xcopy /e $iif($did(%d,65).state,/y) %a $+ *.log %z
      else {
        ;FIX me
        while ($findfile(%a,*.log,0) > %b) {
          inc %b
          set %c " $+ $findfile(%a,*.log,%b) $+ "
          set %path $remove($nofile(%c),%a)
          set %e " $+ %z $+ %path $+ "
          set %f " $+ $remove(%e,") $+ $remove($nopath(%c),") $+ "
          if (!$itq3(%c)) goto el
          if (%path) && (!$exists(%e)) mkdir %e
          if ($exists(%f)) && ($itq(%f)) .remove %f
          if ($exists(%f)) goto el
          if ($did(%d,63).state) && (!$exists(%f)) .copy $iif($did(%d,65).state,-o) %c %e
          else .rename %c %f
          itwl $iif($did(%d,63).state,Copied:,Moved:) %f
          :el
        }
      }
    }
    if ($gettok(%b,1,32) == Downloaded) {
      var %e, %n = 0, %o, %p, %q, %r, %s, %t, %u, %v, %w
      while ($ini(%path $+ SYSTEM\mirc.ini,extensions,0) > %n) {
        inc %n
        set %o $readini(%path $+ SYSTEM\mirc.ini,extensions,$ini(%path $+ SYSTEM\mirc.ini,extensions,%n))
        if ($remove($gettok(%o,1,58),EXTDIR) == default) set %e *.*
        else set %e $ifmatch
        set %p $replace($gettok(%o,2-3,58),..\,%path)
        if ($wildtok($gettok(%o,2-3,58),EXTOPT*,1,92)) set %p %path $+ SYSTEM\ $+ $remove(%p,$ifmatch)
        set %q $remove($gettok(%o,1,58),EXTDIR)
        set %r 0
        while ($gettok(%q,0,44) > %r) {
          inc %r
          if (%q = default) set %s *.*
          else set %s $gettok(%q,%r,44)
          set %t 0
          while ($ini($mircini,extensions,0) > %t) {
            inc %t
            set %u $readini($mircini,extensions,$ini($mircini,extensions,%t))
            set %v $replace($gettok(%u,2-3,58),..\,%pathir)
            if ($wildtok($gettok(%v,2-3,58),EXTOPT*,1,92)) set %v $remove(%v,$ifmatch)
            set %w $iif(%s == *.*,default,%s)
            if (* $+ %w $+ * iswm %u) {
              if ($did(%d,71).state) && ($did(%d,63).state) write $td(fileXfer.bat) xcopy /e $iif($did(%d,65).state,/y) %p $+ %s %v
              else {
                var %aa = 0, %ab, %ac, %ad
                :bf
                while ($findfile(%p,%s,0) > %aa) {
                  inc %aa
                  set %ab " $+ $findfile(%p,%s,%aa) $+ "
                  if ($did(%d,76).state) && (!$itq3(%ab)) {
                    itwl Skipped the file: %ab
                    goto bf
                  }
                  set %ac " $+ $remove($nofile(%ab),%p) $+ "
                  set %ad " $+ %v $+ $remove(%ac,") $+ $nopath(%ab) $+ "
                  if ($did(%d,76).state) && (!$itq3(%ab)) goto em
                  if (!$exists(" $+ $nofile(%ad) $+ ")) .mkdir " $+ $nofile(%ad) $+ "
                  if ($did(%d,63).state) {
                    if (!$exists(%ad)) {
                      .copy $iif($did(%d,65).state,-o) %ab %ad
                      itwl Copied: %ad
                    }
                    else itwl Skipped: %ad - already exists.
                  }
                  else {
                    if ($exists(%ad)) && ($itq(%ad)) .remove %ad
                    else goto em
                    .rename %ab %ad
                    itwl Moved: %ad
                    :em
                  }
                }
              }
            }
          }
        }
      }
    }
    if ($did(%d,71).state) && ($did(%d,63).state) && ($lines($td(fileXfer.bat) => 1)) .run $td(fileXfer.bat)
  }
}
alias setconv {
  var %d = itransfer
  var %a = 0, %b, %c, %did35, %ctime = $ctime
  itwl $str(-,10) Transferring $did(%d,35).lines ircN 7 settings... $str(-,10)
  while ($did(%d,35).lines > %a) {
    inc %a
    did -c %d 35 %a
    set %did35 $did(%d,35).seltext
    set %b $gettok(%did35,1,58)
    set %c $iif($gettok(%did35,2,58),$ifmatch,off)

    ;if ($true) echo -ag B: %b C: %c
    if (%b == allow user bans) nvar userlist.userbans %c
    elseif (%b == always do idle whois) nvar alwaysidlewhois %c
    elseif (%b == auto get ops) nvar userlist.botgetops %c
    elseif (%b == auto op) nvar userlist.autoop %c
    elseif (%b == auto pass) nvar userlist.botautopass %c
    ;    if (%b iswm autojoin chan*) add autojoin chan
    ;    if (%b == autojoin) add autojoin on/off
    elseif (%b == away announcer method) if ($ismod(away)) modvar away announcemeth %c
    elseif (%b == away announcer) if ($ismod(away)) modvar away announcer %c
    ;elseif (%b == away msg channels) if ($ismod(away)) modvar away msgchans %c
    elseif (%b == away msg log) if ($ismod(away)) modvar away msglog %c
    elseif (%b == away nick) if ($ismod(away)) modvar away nick %c
    elseif (%b == away show email) if ($ismod(away)) modvar away showemail %c
    elseif (%b == bitch mode revenge) nvar userlist.revenge %c
    elseif (%b == copy ip on dns) nvar ipondns %c
    elseif (%b == default ban mask) nvar kbmask %c
    elseif (%b == enable chan ctcp) nvar userlist.chanctcp %c
    elseif (%b == icq) if ($ismod(away)) modvar away im %c
    elseif (%b == infoline left bracket) nvar userlist.infolineleft %c
    elseif (%b == infoline right bracket) nvar userlist.infolineright %c
    elseif (%b == lag status) nvar lagstat %c
    elseif (%b == mirc colors) {
      var %x = $readini($did(%d,2) $+ SYSTEM\mirc.ini,colours,n0)
      if (%x) writeini $mircini colors n $+ $ini($mircini,colors,0) ircN 7, $+ %x
      else { itwl mIRC Color transfer failed | unset %did35 }
    }
    elseif (%b == netsplit detector) nvar netsplit %c
    elseif (%b == nick completion activator) nvar nickcomp.nch %c
    elseif (%b == nick completion style) nvar nickcomp.style %c
    elseif (%b == nick completion) nvar nickcomp %c
    elseif (%b == reop bot) nvar userlist.reopbot %c
    elseif (%b == reset away on connect) if ($ismod(away)) modvar away resetaway %c
    elseif (%b == show names on join) nvar join.names %c
    elseif (%b == show synch time on join) nvar join.sync %c
    elseif (%b == show topic on join) nvar join.topic %c
    elseif (%b == show topic set on join) nvar join.topicset %c
    elseif (%b == show totals on join) nvar join.totals %c
    elseif (%b == splash screen) nvar splash %c
    elseif (%b == voice on bot deop) nvar userlist.voiceonbotdeop %c
    elseif (%b == CTCP Ignores) add ctcp ignores

    elseif ((Sound* iswm %b) && ($hget(sounds))) {
      if (%b == Sound theme) hadd sounds sthemes %c
      elseif (%b == sound msg) hadd sounds msg %c
      elseif (%b == sound notice) hadd sounds notice %c
      elseif (%b == sound invite) hadd sounds invite %c
      elseif (%b == sound netsplit) hadd sounds netsplit %c
      elseif (%b == sound netsplit rejoin) hadd sounds netsplitrejoin %c
      elseif (%b == sound disconnect) hadd sounds disconnect %c
      elseif (%b == sound connect) hadd sounds connect %c
      elseif (%b == sound sent file) hadd sounds filesent %c
      elseif (%b == sound send request) hadd sounds sendreq %c
      elseif (%b == sound got file) hadd sounds getfile %c
      elseif (%b == sound page) hadd sounds page %c
      elseif (%b == sound chat request) hadd sounds chatreq %c
      elseif (%b == sound topic) hadd sounds topic %c
      elseif (%b == sound nick) hadd sounds nick %c
      elseif (%b == sound kicked) hadd sounds kicked %c
      elseif (%b == sound away) hadd sounds away %c
      elseif (%b == sound back) hadd sounds back %c
      elseif (%b == sound open ircn) hadd sounds open %c
    }
    if (%did35) itwl Transferred %did35
  }
  itw Settings transfer complete.
  itwl $str(-,10) Transferred %a settings in $duration($calc($ctime - %ctime)) $+ . $str(-,10)
}
alias -l banconv {
  var %d = itransfer
  var %a = 0, %path, %ctime = $ctime, %f, %b = 0, %z, %dlg = itransfer
  set %path $did(%d,2) $+ SYSTEM\
  set %f %path $+ bans.ini
  if (!$exists(%f)) { ite Unable to locate $hc(bans.ini) $+ . | halt }
  itwl $str(-,10) Transferring $did(%d,24).lines ircN 7 bans... $str(-,10)
  while ($did(%d,24).lines > %a) {
    inc %a
    did -c %dlg 24 %a
    set %z $did(%d,24).seltext
    if (($bhost(%z)) || ($bhosth(%z))) itwl A ban matching %z already exists.
    else {
      if ($did(%d,75).state) && (!$itq2(ban: %z)) {
        itwl Skipped the ban: %z
        goto eb
      }
      .addban %z $readini(%f,%z,channels) $gettok($readini(%f,%z,reason),2-,58)
      inc %b
      itwl Added: %z
    }
    :eb
    did -ra %dlg 4 $round($calc(%a / $ini(%f,0) * 100),1) $+ $chr(37) done...
  }
  itw Ban transfer complete.
  itwl $str(-,10) Added %b bans in $duration($calc($ctime - %ctime)) $+ . $str(-,10)
}

alias -l ulconv {
  var %d = itransfer
  var %a = 0, %b, %c, %path, %e = 0, %f, %z, %x, %u = 0, %p = 0, %w, %t, %ctime = $ctime, %botp = 0, %bots = 0, %h, %up, %bp, %uf, %bh = 0
  var %owner7
  set %path $did(%d,2) $+ SYSTEM\
  set %f %path $+ users.ini
  if ($isfile($+(%path,vars.mrc))) {
    %owner7 = $gettok($read($+(%path,vars.mrc),nw,% $+ owner *),2,32)
  }

  if (!$exists(%f)) { itw Unable to locate $hc(users.ini) $+ . | halt }
  itwl $str(-,10) Transferring $did(%d,14).lines ircN 7 users... $str(-,10)
  :again
  while ($did(%d,14).lines > %a) {
    inc %a
    did -c %d 14 %a
    set %h 1
    set %bp 0
    set %uf 0
    set %up 0
    if ($did(%d,14).seltext != users) {
      set %b $did(%d,14).seltext
      if (!$ulinfo(%b,user)) {
        set %c $readini(%f,%b,hostmask)
        if ($did(%d,73).state) && (!$itq2(user: %b)) {
          itwl Skipped the User: %b
          goto again
        }
        .adduser %b $gettok(%c,1,32)
        inc %u
        ;add flags
        .chattr %b + $+ $readini(%f,%b,flags)
        set %w $readini(%f,%b,flags)
        if ((b isin %w) || (i isin %w)) inc %bots
        set %w 0
        set %z $readini(%f,%b,channels)
        while ($gettok(%z,0,44) > %w) {
          inc %w
          set %t $gettok(%z,%w,44)
          if ($readini(%f,%b,%t) isalpha) .chattr %b + $+ $ifmatch %t
        }
        ;add pass
        if ($readini(%f,%b,password)) {
          oldcode 1 $lower(%b) $readini(%f,%b,password)
          if ($result) {
            .chpass %b $ifmatch
            inc %p
            inc %up
          }
        }
        if ($readini(%f,%b,botpass)) {
          oldcode 1 $lower(%b) $readini(%f,%b,botpass)
          if ($result) {
            .chbotpass %b $ifmatch
            inc %botp
            inc %bp
          }
        }
        ;add hosts
        set %z $readini(%f,%b,hostmask)
        set %e 1
        while ($gettok(%z,0,32) > %e) {
          inc %e
          if ($usrh($gettok(%z,%e,32))) { itwl %b has a matching hostmask. $gettok(%z,%e,32) not added. | inc %bh }
          else { .addhost %b $gettok(%z,%e,32) | inc %h }
        }
        ;make owner
        if ((n isin $ulinfo(%b,flags)) && (!%owner) && (%b == %owner7))  { set %owner %b | nvar owner %b }
      }
      else {
        inc %x
        if (%b) itwl %b was not added due to an existing user with the same username.
        goto again
      }
    }
    if (%b) itwl Added %b with %h hostmasks, $iif(%up,with,WITHOUT) a user password $+ $iif(%bp,$chr(44) with a bot password) $+ $iif(%uf,$chr(44) with bot flags (+i or +b)) $+ .
    itw $round($calc(%a / $did(%d,14).lines * 100),1) $+ $chr(37) done...
  }
  :end
  itw User transfer complete.
  if (%x) itwl %x users were not added due to an existing user with the same username.
  if (%bh) itwl %bh hostmasks were not added since a matching hostmask was detected.
  itwl $str(-,10) Added %u users with %p passwords in $duration($calc($ctime - %ctime)) $+ . $str(-,10)
}
alias -l oldcode {
  if ($3- == $null) return
  bunset &crypt.y &crypt.z
  var %a, %z
  set %z $2
  set %a $len($3-)
  while (%a > 0) {
    set %z $hash(%z,32)
    bset -t &crypt.z $calc($bvar(&crypt.z,0) + 1) %z
    dec %a $len(%z)
  }
  bset -t &crypt.z $calc($bvar(&crypt.z,0) + 1) %z
  bset -t &crypt.y 1 $3-
  set %a 1
  while ($bvar(&crypt.y,%a) != $null) {
    bset &crypt.y %a $calc($ifmatch - ($1 * 2 - 1) * ($bvar(&crypt.z,%a) - 48))
    inc %a
  }
  return $bvar(&crypt.y,1-).text
}
alias itransfer { 
  var %d = iTransfer
  if ($0) {
    var %flag_a, %flag_u, %flag_b, %flag_s, %flag_f, %p
    %p = $flags($1-,p,a u b s f).val
    %flag_a = $flags($1-,a,a u b s f)
    %flag_u = $flags($1-,u,a u b s f)
    %flag_b = $flags($1-,b,a u b s f)
    %flag_s = $flags($1-,s,a u b s f)
    %flag_f = $flags($1-,f,a u b s f)
  }
  dlg itransfer
  if (%flag_a) { did -c %d 40,58,59,60 | .timer -d 1 0 itusera | .timer -d 1 0 itbana | .timer -d 1 0 itseta | .timer -d 1 0 itfilea }
  if (%flag_u) { did -c %d 40 | .timer -d 1 0 itusera }
  if (%flag_b) { did -c %d 58 | .timer -d 1 0 itbana }
  if (%flag_s) { did -c %d 59 | .timer -d 1 0 itseta }
  if (%flag_f) { did -c %d 60 | .timer -d 1 0 itfilea }

  if (%p) { did -ra %d 2 %p | _itransfer.dir.select | .timer -d 1 0 _itransfer.do.transfer }
}
alias -l itransferis {
  var %d = iTransfer
  var %a, %f = $did(%d,2) $+ SYSTEM\vars.mrc
  if ($exists(%f)) {
    set %a $read(%f,nw,$chr(37) $+ $1 *)
    if (%a) did -a %d 34 $2- $+ : $iif($gettok(%a,2,32),$ifmatch,None)
  }
}
on 1:DIALOG:itransfer:close:0:{
  iecho If you are finished using $hc(iTransfer) type $+ $sc /unmod itransfer.mod
}
on 1:DIALOG:itransfer:init:0:{
  did -c $dname 63,68,71
  did -ra $dname 68 Log to file $paren($lines($logdiritransfer.log))
  mtooltips SetTooltipWidth 500
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 40 0 > NOT_USED $chr(4) Selects all users detected in ircN 7 to transfer into ircN 8.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 58 0 > NOT_USED $chr(4) Selects all bans detected in ircN 7 to transfer in ircN 8.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 59 0 > NOT_USED $chr(4) Selects all settings detected in ircN 7 to transfer in ircN 8.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 60 0 > NOT_USED $chr(4) Selects all downloaded files and logs in ircN 7 to transfer in ircN 8.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 63 0 > NOT_USED $chr(4) Copies the files you have selected from ircN 7 to ircN 8.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 71 0 > NOT_USED $chr(4) Uses DOS's xcopy for a much faster copy but the files copied are not logged.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 64 0 > NOT_USED $chr(4) Moves the files you have selected from ircN 7 to ircN 8.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 65 0 > NOT_USED $chr(4) Overwrites any files that may exist with the same filename in ircN 8.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 76 0 > NOT_USED $chr(4) Asks for confirmation on transferring files from ircN 7 to ircN 8. $+ $crlf $+ Does not work with xcopy.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 73 0 > NOT_USED $chr(4) Asks for confirmation on each user to be transferred.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 75 0 > NOT_USED $chr(4) Asks for confirmation on each ban to be transferred.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 68 0 > NOT_USED $chr(4) Logs everything transferred to $logdiritransfer.log
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 69 0 > NOT_USED $chr(4) Opens the log file.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 70 0 > NOT_USED $chr(4) Deletes the log file.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 7 0 > NOT_USED $chr(4) List of detected ircN 7 users.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 14 0 > NOT_USED $chr(4) List of the users to transfer.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 10 0 > NOT_USED $chr(4) Adds the selected user to be transferred.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 11 0 > NOT_USED $chr(4) Adds all the users to be transferred.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 12 0 > NOT_USED $chr(4) Removes the selected user to be transferred.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 13 0 > NOT_USED $chr(4) Removes all the users to be transferred.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 54 0 > NOT_USED $chr(4) Transfers the users you have selected.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 23 0 > NOT_USED $chr(4) List of detected ircN 7 bans.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 24 0 > NOT_USED $chr(4) List of the bans to transfer.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 21 0 > NOT_USED $chr(4) Adds the selected ban to be transferred.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 18 0 > NOT_USED $chr(4) Adds all the bans to be transferred.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 19 0 > NOT_USED $chr(4) Removes the selected ban to be transferred.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 20 0 > NOT_USED $chr(4) Removes all the bans to be transferred.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 55 0 > NOT_USED $chr(4) Transfers the bans you have selected.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 34 0 > NOT_USED $chr(4) List of detected ircN 7 settings.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 35 0 > NOT_USED $chr(4) List of the settings to transfer.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 32 0 > NOT_USED $chr(4) Adds the selected settings to be transferred.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 29 0 > NOT_USED $chr(4) Adds all the settings to be transferred.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 30 0 > NOT_USED $chr(4) Removes the selected settings to be transferred.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 31 0 > NOT_USED $chr(4) Removes all the settings to be transferred.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 56 0 > NOT_USED $chr(4) Transfers the settings you have selected.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 46 0 > NOT_USED $chr(4) List of detected ircN 7 files.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 47 0 > NOT_USED $chr(4) List of the files to transfer.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 45 0 > NOT_USED $chr(4) Adds the selected files to be transferred.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 42 0 > NOT_USED $chr(4) Adds all the files to be transferred.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 43 0 > NOT_USED $chr(4) Removes the selected files to be transferred.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 44 0 > NOT_USED $chr(4) Removes all the files to be transferred.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 57 0 > NOT_USED $chr(4) Transfers the files you have selected.
}
alias _itransfer.do.transfer {
  var %d = iTransfer
  if ((!$did(%d,40).state) && (!$did(%d,58).state) && (!$did(%d,59).state) && (!$did(%d,60).state)) {
    ite Select a transfer.
    halt
  }
  if ($did(%d,40).state) {
    ulconv
    did -ra %d 40 All Users: Done
    did -ub %d 40
  }
  if ($did(%d,58).state) {
    banconv
    did -ra %d 58 All Bans: Done
    did -ub %d 58
  }
  if ($did(%d,59).state) {
    setconv
    did -ra %d 59 All Settings: Done
    did -ub %d 59
  }
  if ($did(%d,60).state) {
    fileconv
    did -ra %d 60 All Files: Done
    did -ub %d 60
  }
}
alias _itransfer.dir.select {
  var %d = iTransfer
  did -b %d 3
  did -e %d 8,9,15,16,10,11,12,13,25,26,27,22,21,18,19,20,55,33,38,36,37,32,29,30,31,56,48,49,50,51,45,42,43,44,57,46,54,39,61,62,63,64,65,71,72,73,74,75,76,7,14,23,24,34,35,47
  did -r %d 7,14,23,24,34,35,46,47
  var %a = $did(%d,2)

  ;USERS INIT
  var %a = 0, %f = $did(%d,2) $+ SYSTEM\users.ini, %z
  itw Adding transferrable Users...
  while ($ini(%f,0) > %a) {
    inc %a
    set %z $ini(%f,%a)
    if (%z != users) did -a %d 7 %z
  }
  did -ra %d 9 $did(%d,7).lines
  did -ra %d 40 All Users: $paren($did(%d,7).lines)
  did -e %d 40

  ;BANS INIT
  var %a = 0, %f = $did(%d,2) $+ SYSTEM\bans.ini
  itw Adding transferrable Bans...
  while ($ini(%f,0) > %a) {
    inc %a
    did -a %d 23 $ini(%f,%a)
  }
  did -ra %d 27 $did(%d,23).lines
  did -ra %d 58 All Bans: $paren($did(%d,23).lines)
  did -e %d 58

  ;SETTINGS INIT
  if ($exists($did(%d,2) $+ SYSTEM\vars.mrc)) {
    itransferis botgetops Auto Get Ops
    itransferis auto Auto Op
    itransferis reopbot Reop Bot
    itransferis botautopass Auto Pass
    itransferis userbans Allow User Bans
    itransferis showctcp Enable Chan CTCP
    itransferis lb InfoLine Left Bracket
    itransferis rb InfoLine Right Bracket
    itransferis splash Splash Screen
    itransferis copydns Copy IP on DNS
    itransferis idlewhois Always do Idle Whois
    itransferis jointpc Show Topic on Join
    itransferis jointtl Show Totals on Join
    itransferis joinnms Show Names on Join
    itransferis joinsyn Show Synch Time on Join
    itransferis jointst Show Topic Set on Join
    itransferis nc Nick Completion
    itransferis ncstyle Nick Completion Style
    itransferis nch Nick Completion Activator
    itransferis kbmask Default Ban Mask
    itransferis ctcpignores CTCP Ignores
    itransferis netsplit Netsplit Detector
    itransferis botdeop Voice on Bot Deop
    itransferis protdeop Bitch Mode Revenge
    itransferis lag Lag Status
    ;      if ($script(autojoin.mrc)) {
    ;        itransferis autojoin Autojoin
    ;        var %a, %b, %f = $did(2) $+ SYSTEM\vars.mrc
    ;        var %a = $read(%f,w,$chr(37) $+ autojoin.*)
    ;        :a
    ;        if (%a) {
    ;          did -a %d 34 Autojoin Chan $gettok($replace($read(%f,n,$readn),$chr(32),: $+ $chr(32)),2-,46)
    ;          set %b $calc($readn + 1)
    ;          set %a $read(%f,w,$chr(37) $+ autojoin.*,%b)
    ;          goto a
    ;        }
    ;      }
    if ($script(away.mrc)) {
      itransferis uin ICQ #
      itransferis tribe.n Away Nick
      itransferis tribe.ldg Away Log DCCs
      itransferis stayaway Reset Away on Connect
      itransferis em Away Show Email
      itransferis msglog Away Msg Log
      itransferis away.chan Away Msg Channels
      itransferis announce Away Announcer
      itransferis saytype Away Announcer Method
    }
    if ($script(sthemes.mrc)) {
      itransferis theme Sound Theme
      itransferis theme.msg Sound Msg
      itransferis theme.notice Sound notice
      itransferis theme.invite Sound invite
      itransferis theme.split Sound netsplit
      itransferis theme.rejoin Sound netsplit rejoin
      itransferis theme.disconnect Sound disconnect
      itransferis theme.connect Sound connect
      itransferis theme.filesent Sound sent file
      itransferis theme.dccsend Sound send request
      itransferis theme.fileget Sound got file
      itransferis theme.page Sound page
      itransferis theme.dccchat Sound chat request
      itransferis theme.topic Sound topic
      itransferis theme.nick Sound nick
      itransferis theme.kicked Sound kicked
      itransferis theme.away Sound away
      itransferis theme.back Sound back
      itransferis theme.welcome Sound open ircN
    }
    did -a %d 34 mIRC Colors
    did -ra %d 38 $did(%d,34).lines
    did -ra %d 59 All Settings: $paren($did(%d,34).lines)
    did -e %d 59
  }

  ;FILES INIT
  ;logs
  var %a, %b = $remove($readini($did(%d,2) $+ SYSTEM\mirc.ini,dirs,logdir),$did(%d,2))
  itw Adding transferrable Files...
  set %a $findfile($did(%d,2) $+ %b,*.log,0)
  if (%a) {
    did -a %d 46 Logs: %a
    did -ra %d 51 %a
  }
  ;downloads
  var %a = 0, %b, %p, %e, %n = 0, %z = $did(%d,2), %y, %w, %x
  while ($ini(%z $+ SYSTEM\mirc.ini,extensions,0) > %a) {
    inc %a
    set %b $readini(%z $+ SYSTEM\mirc.ini,extensions,$ini(%z $+ SYSTEM\mirc.ini,extensions,%a))
    if ($remove($gettok(%b,1,58),EXTDIR) == default) set %e *.*
    else set %e $ifmatch
    set %y 0
    while ($gettok(%e,0,44) > %y) {
      inc %y
      set %w $gettok(%e,%y,44)
      set %x $remove($replace($gettok(%b,2-3,58),..\,%z),EXTOPT)
      set %p $iif(%z isin %x,EXTOPT),$remove(%x,%z),%x
      if ($wildtok($gettok(%b,2-3,58),EXTOPT*,1,92)) set %p $did(2) $+ SYSTEM\ $+ $remove(%p,$ifmatch)
      set %n $sum(%n,$findfile(%p,%w,0))
    }
  }
  if (%n) {
    did -a %d 46 Downloaded Files: %n
    did -ra %d 51 $calc($did(51) + %n)
  }
  did -a %d 46 Servers
  did -ra %d 51 $calc($did(%d,51) + 1)
  did -ra %d 60 All Files: $paren($did(%d,51))
  did -e %d 60
  itw Select the macro transfer or do a manual transfer in the tabs.

}
on 1:DIALOG:itransfer:sclick:*:{
  if ($did == 3) {
    var %a = $sdir($left($mircdir,2),ircN 7 Directory)
    if (!%a) halt
    if (!$isfile(%a $+ SYSTEM\raw.mrc)) || ($isfile(%a $+ SYSTEM\queue.mrc)) {
      var %b = $input(%a is not an ircN 7 Directory,ow,Error)
      halt
    }
    did -ra $dname 2 %a
    _itransfer.dir.select
  }
  ;END OF INIT
  if ($did == 40) {
    if ($did(40).state) itusera
    else ituserd
  }
  if ($did == 58) {
    if ($did(58).state) itbana
    else itband
  }
  if ($did == 59) {
    if ($did(59).state) itseta
    else itsetd
  }
  if ($did == 60) {
    if ($did(60).state) itfilea
    else itfiled
  }
  if ($did == 69) {
    if ($exists($logdiritransfer.log)) run $logdiritransfer.log
    else ite $logdiritransfer.log does not exist.
  }
  if ($did == 70) {
    var %clear = $input(Are you sure you want to clear the log?,y,Clear log?)
    if (%clear) {
      write -c $logdiritransfer.log
      itw Cleared: $logdiritransfer.log
    }
  }
  if ($did == 61) {
    _itransfer.do.transfer
  }

  ;BANS SCLICK
  if ($did == 18) itbana
  if ($did == 20) itband
  if (($did == 21) && ($did(23).seltext)) {
    did -a $dname 24 $did(23).seltext
    did -d $dname 23 $did(23).sel
    did -ra $dname 27 $did(23).lines
    did -ra $dname 26 $did(24).lines
  }
  if (($did == 19) && ($did(24).seltext)) {
    did -a $dname 23 $did(24).seltext
    did -d $dname 24 $did(24).sel
    did -ra $dname 26 $did(24).lines
    did -ra $dname 27 $did(23).lines
  }
  if (($did == 55) && ($did(24).lines)) banconv

  ;USERS SCLICK
  if ($did == 11) itusera
  if ($did == 13) ituserd
  if (($did == 10) && ($did(7).seltext)) {
    did -a $dname 14 $did(7).seltext
    did -d $dname 7 $did(7).sel
    did -ra $dname 9 $did(7).lines
    did -ra $dname 16 $did(14).lines
  }
  if (($did == 12) && ($did(14).seltext)) {
    did -a $dname 7 $did(14).seltext
    did -d $dname 14 $did(14).sel
    did -ra $dname 16 $did(14).lines
    did -ra $dname 9 $did(7).lines
  }
  if (($did == 54) && ($did(14).lines)) ulconv

  ;SETTINGS SCLICK
  if ($did == 29) itseta
  if ($did == 31) itsetd
  if (($did == 32) && ($did(34).seltext)) {
    did -a $dname 35 $did(34).seltext
    did -d $dname 34 $did(34).sel
    did -ra $dname 38 $did(34).lines
    did -ra $dname 37 $did(35).lines
  }
  if (($did == 30) && ($did(35).seltext)) {
    did -a $dname 34 $did(35).seltext
    did -d $dname 35 $did(35).sel
    did -ra $dname 37 $did(35).lines
    did -ra $dname 38 $did(34).lines
  }
  if (($did == 56) && ($did(35).lines)) setconv

  ;FILES SCLICK
  if ($did == 42) itfilea 
  if ($did == 44) itfiled
  if (($did == 45) && ($did(46).seltext)) {
    did -a $dname 47 $did(46).seltext
    did -d $dname 46 $did(46).sel
    did -ra $dname 51 $did(46).lines
    did -ra $dname 48 $did(47).lines
  }
  if (($did == 43) && ($did(47).seltext)) {
    did -a $dname 46 $did(47).seltext
    did -d $dname 47 $did(47).sel
    did -ra $dname 48 $did(47).lines
    did -ra $dname 51 $did(46).lines
  }
  if (($did == 57) && ($did(47).lines)) fileconv
}
alias -l itbana {
  var %d = iTransfer
  if ($did(%d,23).lines == 0) halt
  var %a = 0
  while ($did(%d,23).lines > %a) {
    inc %a
    did -c %d 23 %a
    did -a %d 24 $did(%d,23).seltext
  }
  did -r %d 23
  did -ra %d 27 $did(%d,23).lines
  did -ra %d 26 $did(%d,24).lines
}
alias -l itband {
  var %d = iTransfer
  if ($did(%d,24).lines == 0) halt
  var %a = 0
  while ($did(%d,24).lines > %a) {
    inc %a
    did -c %d 24 %a
    did -a %d 23 $did(%d,24).seltext
  }
  did -r %d 24
  did -ra %d 27 $did(%d,23).lines
  did -ra %d 26 $did(%d,24).lines
}
alias -l itusera {
  var %d = iTransfer
  if ($did(%d,7).lines == 0) halt
  var %a = 0
  while ($did(%d,7).lines > %a) {
    inc %a
    did -c %d 7 %a
    did -a %d 14 $did(%d,7).seltext
  }
  did -r %d 7
  did -ra %d 9 $did(%d,7).lines
  did -ra %d 16 $did(%d,14).lines
}
alias -l ituserd {
  var %d = iTransfer
  if ($did(%d,14).lines == 0) halt
  var %a = 0
  while ($did(%d,14).lines > %a) {
    inc %a
    did -c %d 14 %a
    did -a %d 7 $did(%d,14).seltext
  }
  did -r %d 14
  did -ra %d 9 $did(%d,7).lines
  did -ra %d 16 $did(%d,14).lines
}
alias -l itseta {
  var %d = iTransfer
  if ($did(%d,34).lines == 0) halt
  var %a = 0
  while ($did(%d,34).lines > %a) {
    inc %a
    did -c %d 34 %a
    did -a %d 35 $did(%d,34).seltext
  }
  did -r %d 34
  did -ra %d 38 $did(%d,34).lines
  did -ra %d 37 $did(%d,35).lines
}
alias -l itsetd {
  var %d = iTransfer
  if ($did(%d,35).lines == 0) halt
  var %a = 0
  while ($did(%d,35).lines > %a) {
    inc %a
    did -c %d 35 %a
    did -a %d 34 $did(%d,35).seltext
  }
  did -r %d 35
  did -ra %d 38 $did(%d,34).lines
  did -ra %d 37 $did(%d,35).lines
}
alias -l itfilea {
  var %d = iTransfer
  if ($did(%d,46).lines == 0) halt
  var %a = 0
  while ($did(%d,46).lines > %a) {
    inc %a
    did -c %d 46 %a
    did -a %d 47 $did(%d,46).seltext
  }
  did -r %d 46
  did -ra %d 51 $did(%d,46).lines
  did -ra %d 48 $did(%d,47).lines
}
alias -l itfiled {
  var %d = iTransfer
  if ($did(%d,47).lines == 0) halt
  var %a = 0
  while ($did(%d,47).lines > %a) {
    inc %a
    did -c %d 47 %a
    did -a %d 46 $did(%d,47).seltext
  }
  did -r %d 47
  did -ra %d 51 $did(%d,46).lines
  did -ra %d 48 $did(%d,47).lines
}
dialog iTransfer {
  title "ircN 7 -> 8 Transfer"
  size -1 -1 219 150
  option dbu
  button "Close", 1, 181 137 37 12, default ok cancel
  edit "Please locate your ircN 7 Directory.", 2, 2 13 176 10, read center
  button "Browse", 3, 180 12 37 12
  text "", 4, 2 3 215 8, center
  tab "Main", 5, 2 24 215 110
  box "Macro Transfer:", 39, 5 40 60 90, disable tab 5
  check "All Users", 40, 9 50 54 10, disable tab 5
  check "All Bans", 58, 9 66 54 10, disable tab 5
  check "All Settings", 59, 9 82 54 10, disable tab 5
  check "All Files", 60, 9 98 54 10, disable tab 5
  button "Begin Transfer", 61, 8 115 53 12, disable tab 5
  box "File Settings:", 62, 70 40 77 70, disable tab 5
  radio "Copy Files", 63, 80 50 38 10, disable tab 5
  radio "Move Files", 64, 80 74 38 10, disable tab 5
  check "Overwrite", 65, 80 86 38 10, disable tab 5
  text "Note: Close ircN 7 before transferring anything to ircN8.", 66, 66 114 84 16, tab 5 center
  box "Log Settings:", 67, 152 92 62 39, tab 5
  check "Log to File", 68, 158 102 50 10, tab 5
  button "View", 69, 156 117 26 10, tab 5
  button "Clear", 70, 184 117 26 10, tab 5
  check "Use xcopy", 71, 92 62 36 10, disable tab 5
  box "User Settings", 72, 152 40 62 25, disable tab 5
  check "Verify each user", 73, 158 50 50 10, disable tab 5
  box "Ban Settings", 74, 152 66 62 25, disable tab 5
  check "Verify each ban", 75, 158 76 50 10, disable tab 5
  check "Verify each file", 76, 80 97 50 10, disable tab 5
  tab "Users", 6
  list 7, 5 49 90 82, disable tab 6 sort size
  text "Users Found:", 8, 6 40 32 8, disable tab 6
  text "0", 9, 58 40 36 8, disable tab 6 right
  button ">", 10, 98 50 25 10, disable tab 6
  button ">>", 11, 98 62 25 10, disable tab 6
  button "<", 12, 98 82 25 10, disable tab 6
  button "<<", 13, 98 94 25 10, disable tab 6
  list 14, 125 49 90 82, disable tab 6 sort size
  text "Users to Add:", 15, 125 40 33 8, disable tab 6
  text "0", 16, 178 40 36 8, disable tab 6 right
  button "Transfer", 54, 98 118 25 12, disable tab 6
  tab "Bans", 17
  button ">>", 18, 98 62 25 10, disable tab 17
  button "<", 19, 98 82 25 10, disable tab 17
  button "<<", 20, 98 94 25 10, disable tab 17
  button ">", 21, 98 50 25 10, disable tab 17
  text "Bans Found:", 22, 6 40 30 8, disable tab 17
  list 23, 5 49 90 82, disable tab 17 sort size
  list 24, 125 49 90 82, disable tab 17 sort size
  text "Bans to Add:", 25, 125 40 31 8, disable tab 17
  text "0", 26, 178 40 36 8, disable tab 17 right
  text "0", 27, 58 40 36 8, disable tab 17 right
  button "Transfer", 55, 98 118 25 12, disable tab 17
  tab "Settings", 28
  button ">>", 29, 98 62 25 10, disable tab 28
  button "<", 30, 98 82 25 10, disable tab 28
  button "<<", 31, 98 94 25 10, disable tab 28
  button ">", 32, 98 50 25 10, disable tab 28
  text "Settings Found:", 33, 6 40 38 8, disable tab 28
  list 34, 5 49 90 82, disable tab 28 sort size
  list 35, 125 49 90 82, disable tab 28 sort size
  text "Settings to Add:", 36, 125 40 39 8, disable tab 28
  text "0", 37, 178 40 36 8, disable tab 28 right
  text "0", 38, 58 40 36 8, disable tab 28 right
  button "Transfer", 56, 98 118 25 12, disable tab 28
  tab "Files", 41
  button ">>", 42, 98 62 25 10, disable tab 41
  button "<", 43, 98 82 25 10, disable tab 41
  button "<<", 44, 98 94 25 10, disable tab 41
  button ">", 45, 98 50 25 10, disable tab 41
  list 46, 5 49 90 82, disable tab 41 sort size
  list 47, 125 49 90 82, disable tab 41 sort size
  text "0", 48, 178 40 36 8, disable tab 41 right
  text "Files to Add:", 49, 125 40 30 8, disable tab 41
  text "Files Found:", 50, 6 40 30 8, disable tab 41
  text "0", 51, 58 40 36 8, disable tab 41 right
  button "Transfer", 57, 98 118 25 12, disable tab 41
  tab "Log", 52
  edit "", 53, 4 41 211 90, tab 52 read multi autovs vsbar
}
