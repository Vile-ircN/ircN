on *:START:{ 
  if (!$alias(settings.als)) .load -a $qt($scriptdir $+ settings.als)
  .timer 1 1 _ircnmaintain_onstart
}

alias _ircnmaintain_onstart {
  ;if the ircn crashed but maintain.mrc stayed loaded
  if (!$alias($sys(settings.als))) .load -a2 $sys(settings.als)
  if (!$alias($sys(identfrs.als))) .load -a3 $sys(identfrs.als)
  if (!$script(events.mrc)) var %eventsnogo = $true
  if (!$script(nxt-dyn.mrc)) {
    if (($isfile($sys(nxt-dyn.mrc))) && (!$isfile($sd(nxt-dyn.mrc)))) .copy -o $sys(nxt-dyn.dat) $sd(nxt-dyn.dat)
    if ($isfile($sd(nxt-dyn.mrc))) {
      .reload -rs $sys(nxt.mrc)
      .reload -rs $sd(nxt-dyn.mrc)
      nxt_onstart
      if (($hget(nxt_data, Script)) && ($isfile($hget(nxt_data, Script)))) .reload -rs $qt($hget(nxt_data, Script))
    }

    if (!$hget(nxt_data, CurTheme))  { nxt_firststart | .timer 1 5 iecho Recovered from a crash. reloaded default theme }
  }


  if ((($nvar(oldver)) && ($nvar(oldver) == $nvar(reldate))) || (!$nvar(reldate))) {
    if ($crash.check) {
      var %q = $ifmatch
      $iif($isalias(iecho), iecho -s, echo -sg ***) Recovered from ircN Crash.. restored %q settings.
      var %crashchk = 1
    }
  }
  if (!%crashchk) .default.setup 

  var %oldver = $gettok($gettok($nvar(oldver),1,32),1,45)
  var %reldate = $gettok($gettok($nvar(reldate),1,32),1,45)

  var %reqmirc = $readini($sd(release.ini), n, release, reqmirc)

  if (($version < %reqmirc) && (%reqmirc)) {
    var %err = $infobox(ircnmaint.reqmirc,Warning:,15, ircN $nvar(ver) was made to be used with mIRC %reqmirc and above. You are currently using mIRC $version $+ . Please update your ircn/system/mirc.exe to the latest version for compatability. )
  }


  if ((!%oldver) || (%oldver < %reldate))   .timer 1 1 updateconv
  if ($ismod(services)) unloadnetsupport

  if ($show) {

    if ($nvar(checkscripts.crc) != off) .timer 1 1 checkscripts.crc
    else {
      if ($nvar(checkscripts.corrupt) != off) .timer 1 1 checkscripts.corrupt
    }

    if ($nvar(checkscripts.unknown) != off) .timer 1 3 checkscripts.unknown

    if ($nvar(checkwritedir) != off)  .timer 1 5 ircn.checkwritedir

  }
  ;unset crash detect
  unset %testcrash

  _cleanalphavars

  if ($nopath($readini($mircini, n, rfiles, n3)) != maintain.mrc) .timer 1 2 .reload -rs2 $qt($script)
  .timer 1 2 _ircnthemes.movetobottom 
  if (%eventsnogo) .timer 1 1 _ircnevents_onstart

}

alias _ircnthemes.movetobottom {
  if ($script(nxt.mrc)) .reload -rs $+ $script(0) $qt($script(nxt-dyn.mrc).fname)
  if ($script(nxt-dyn.mrc)) .reload -rs $+ $script(0) $qt($script(nxt-dyn.mrc).fname)
  if (($hget(nxt_data, Script)) && ($script($hget(nxt_data, Script)))) .reload -rs $+ $script(0) $qt($hget(nxt_data, Script))

  if (settings.als isin $readini($qt($mircini),afiles,n0)) { var %q = $qt($alias(settings.als)) | .unload -a %q | .reload -a %q }
}
on *:CONNECT:{
  if (!$server) return
  if ($nvar(fixip) != off) {
    ; try to fix invalid $ip's
    if ($ip == $null) .localinfo -h
    .timer 1 3 fixip 
  }
}
alias fixip {
  var %a = 1, %b, %c, %d = 10.* 169.* 192.* 127.* 0.* 255.*
  while ($gettok(%d,%a,32) != $null) {
    set %b $ifmatch
    if (%b iswm $ip) {
      if (%c) break
      .localinfo -u 
      set %c 1 
    }
    inc %a
  }
}
alias updateconv {

  var %oldver = $gettok($gettok($nvar(oldver),1,32),1,45)


  ;; if (f isin $ulinfo(%owner,flags)) {
  ;  if ($input(Remove +f flag from %owner $+ ? $+ $crlf $+ This will disable %owner $+ 's ban protection. (Recommended),qy,Remove +f?)) chattr %owner -f
  ;}
  if (%oldver < 20141225) {

    if ($isfile($sys(services.mrc))) {
      if ($script($sys(services.mrc))) .timer 1 1 .module services
      .remove $sys(services.mrc)
    }

  }
  if (%oldver < 20100216) {
    if (%savetime == 5) unset %savetime
    if (%wall) { nvar wall wallops | unset %wall } 
    !.unload -nrs $qt($script(userlist.mrc))
    .remove $qt($sys(userlist.mrc))
    .module userlist

    if ($ismod(classicui)) .module classicui
    if ($ismod(modernui)) .module modernui
    ;remove \popup\ dir

    ;make \system\networksupport\ircd , network
    .timer 1 1 .reload -rs2 $qt($script)
  }
  if (%oldver  < 20100707) {
    if ($nvar(logiecho)) {
      ;moves logiecho to a new spot
      nvar logging.logiecho $nvar(logiecho)
      nvar logiecho
    }
  }

  if (%oldver < 20100904) {
    ;remove outdated files ----
    if ($isfile($dd(mpopup.dll))) .remove $dd(mpopup.dll)
    if ($isfile($sd(popups.hsh))) .remove $sd(popups.hsh)
    if ($isfile($sys(userlist.mrc))) .remove $sys(userlist.mrc)

    _update.removeoldmods
    ; ------------

    ; todo: check if vars.mrc,users is in $sd otherwise save it there
    if ($isfile(nxt-theme.dat)) .remove nxt-theme.dat

    iecho -s An update has been made to the theme engine, ircN must reload your current theme.
    .timer 1 2  theme.reload



  }


  .timer 1 1 iecho Upgraded from $nvar(lver) $paren($nvar(oldver)) -> $nvar(lver) $paren($readini($sd(release.ini),release,date)) successfully.
  nvar oldver $nvar(reldate)
  if ($nvar(timezone)) _timezonefix
  ircnsave
}
alias -l _update.removeoldmods {
  var %r =  _update.removeoldmods.rem

  if ($isfile($md(backups\ldzip.exe))) { 
    %r backups
    .remove $md(backups\ldzip.exe)
    .remove $md(backups\backups.mrc)
  }
  %r statistics
  %r cp
  %r balloontips
  %r cprot
  %r fldprot
  %r spellchk
  %r sthemes
  %r update
  %r mcryptZn
  %r notes
  %r telnetd
  %r update
  %r idraw


}

alias -l _update.removeoldmods.rem {
  if ($isfile($md($1 $+ .mod))) {
    if ($ismod($1)) {
      .unmod $1
      iecho Unloaded module $hc($1) because it is outdated. Check back on   $+ $sc(www.ircn.org) $+  for updates.
    }
    if (!$isdir($bkd(OutdatedModules))) .mkdir $bkd(OutdatedModules)
    .echo -q $_movesafe($md($1 $+ .mod), $bkd(OutdatedModules\))
    .echo -q $_movesafe($md($1 $+ .mrc), $bkd(OutdatedModules\))
  }
}
alias -l ircn.checkwritedir {
  ; test to see if ircns folder doesn't have write permissions, or if it's running off a cdrom
  var %d = $deltok($shortfn($mircdir),-1,92) $+ \
  var %f = $qt(%d $+ ircntest.tmp)
  write -c %f $true
  var %a = $read(%f,n,1)
  if (!%a) {
    if ($disk($left($mircdir,2)).type == cdrom) var %err = $infobox(ircnmaint.cd,Warning:,10, ircN is running off of a cdrom drive $paren(which is readonly) $+ . None of your settings will be saved)
    else var %err = $infobox(ircnmaint.nowrite, Warning:, 10, ircN was unable to write to your 'resources\settings\' folder none of your settings will be saved. Make sure your ircN folders are not set as read only.)
  }
  .remove %f
}

;this should be removed
alias _mvoldresfolders {
  ; copy files in dlls\ 

  ; make the installer update the folder paths

}
alias _mvoldresfold.dlls {
  if (!$isdir($qt($1-))) return
  var %subpath = $remove($rq($1-), $+(%dir,\dlls\)) 
  var %file = $mkfn($nopath($1-))
  var %newpath = $dd($+(%subpath,\, %file))
  if (!%file) return
  if (!$isdir(%newpath)) .mkdir %newpath

  .echo -a $findfile( $1-, * ,0, .copy -o $qt( $1- ) $dd )
}

alias checkscripts.unknown {
  var %a = 1, %b, %c
  var %ignore = custom.mrc raw.mrc events.mrc nxt.mrc nxt-dyn.mrc queue.mrc maintain.mrc
  while (%a <= $script(0)) {
    set %b $script(%a)

    ;make sure they arent in %ignore files, and that they are only residing in the $sys dir if they are, so it wont end up ignoring 


    if (($istok(%ignore,$nopath(%b),32)) && ($nofile($shortfn(%b)) == $shortfn($sys))) { inc %a | continue }
    if (($nopath(%b) == custom.mrc) && ($nofile($shortfn(%b)) == $shortfn($usrdir(system)))) { inc %a | continue }
    if ($shortfn(%b) == $shortfn($hget(nxt_data,script))) {  inc %a | continue }
    if ($shortfn(%b) == $shortfn($sd(nxt-dyn.mrc))) { inc %a | continue }
    if ((*.ircd iswm $nopath(%b)) && ($nofile(%b) == $ircddir )) { inc %a | continue }
    if ((*.nwrk iswm $nopath(%b)) && ($nofile(%b) == $netdir)) { inc %a | continue }

    ; loop through every script file..
    ; then loop through every module and check if it's a script file of it


    var %q = 1, %y, %ismod
    while ($gettok($nvar(modules),%q,44) != $null) {
      set %y $ifmatch
      if ($_ismodscript($md(%y),$nopath(%b)))  set %ismod 1
      inc %q
    }

    if (!%ismod) {
      iecho -s -L "checkscripts $+ $chr(8) $+ $nopath(%b) $+ : $+ /run notepad.exe $shortfn(%b) $+ "  Unverified loaded script file: $remove(%b,$idir) $+(,$base($color(background),10,10,2),$chr(44),$base($color(background),10,10,2)) $+ .
      inc %c
    }

    inc %a
  }
  if (%c) {
    iecho -s Check Scripts: $hc(%c) unverified loaded script files. Double click file above to open in notepad. If you did not load the script file please unload it with the command /unload -rs file.mrc
    .ntimer checkscript.linkclean 1 60 _iecho.linkcleanbyname checkscripts
  }
}

alias checkscripts.crc {
  ; add a command to whitelist a file being edited, or disable this check
  var %a = 1, %b, %c
  var %s = install.mrc:D7A49D15 raw.mrc:F3C58D66 events.mrc:E7A0F81A nxt.mrc:6EBAFA53 queue.mrc:55463E72 query.als:E834E851 identfrs.als:4AF2F82B client.als:D0D8724E channel.als:7617BC9F dlgspprt.als:DC0FEC19

  while ($gettok(%s,%a,32) != $null) {
    set %b $gettok($ifmatch,1,58)
    set %c $gettok($ifmatch,2,58)

    if (!$isfile($sys(%b))) {
      echo 04 -sg 15[12N15] Warning: core ircN script file is missing: $nopath(%b)
      inc %a
      continue
    }
    if (%c) {
      if ($crc($sys(%b)) != %c) {
        iecho Warning: core ircN script file is damaged or modified: $nopath(%b) (crc: $ifmatch $+ , expected: %c $+ )
      }
    }
    inc %a
  }
}
alias checkscripts.corrupt {
  ; checks for the 'EOF' footer at the end of ircN script files. Used to be sure they weren't corrupted or have data loss.
  ; this only gets called on start if they've disabled the crc check (ex: if they want to modify core scripts and ignore crc warnings, but keep the corruption warnings)
  var %s = install.mrc raw.mrc events.mrc nxt.mrc queue.mrc maintain.mrc query.als identfrs.als client.als channel.als dlgspprt.als

  var %a = 1
  while ($gettok(%s,%a,32) != $null) {
    var %f = $sys($ifmatch)
    if (!$isfile(%f)) {
      echo 04 -sg 15[12N15] Warning: core ircN script file is missing: $nopath(%b)
      inc %a
      continue
    }
    if ($fopen(checkcorrupt)) .fclose checkcorrupt
    .fopen checkcorrupt %f
    .fseek checkcorrupt $calc($file(%f) - 274)
    var %r = $fread(checkcorrupt, 274, &z)
    if ($crc(&z,1) != D19C8D19) {
      iecho Warning: core ircN script file is damaged or modified: $nopath(%f) (wrong end-of-file footer)
    }
    bunset &z
    .fclose checkcorrupt 
    inc %a
  }
}


;$_ismodscript($md(maxtime.mod),maxtime.mrc) = $true
alias _ismodscript {
  var %a, %z, %b, %c
  set %a 1
  set %z $ini($1,module,0)
  ;var %x = $qt($iif($isfile($shortfn($2)),$shortfn($2),$md($2)))

  ;
  var %x = $nopath($2)

  while (%a <= %z) {
    set %b $readini($1,n,module,script [ $+ [ %a ] ] )
    set %c $readini($1,n,module,alias [ $+ [ %a ] ] )
    if (%b) {
      if ($nopath(%b) == %x) return $true
    }
    if (%c) {
      if ($nopath(%c) == %x) return $true
    }
    inc %a
  }
  return $false
}
alias _timezonefix {
  if (($right($nvar(timezone),2) === ST) && ($daylight)) nvar timezone $left($nvar(timezone),-2) $+ DT
}


; ################################################################
; ####################### IRCN SCRIPT FILE #######################
; ########## END OF FILE. DO NOT REMOVE OR MODIFY BELOW ##########
; ################################################################
