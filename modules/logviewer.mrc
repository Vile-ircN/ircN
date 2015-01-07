;%%%%%%%%%%%%%%%%%%%%%%%%
;script ircN logviewer
;version 9.00
;author Vile
;email Vile@ircN.org
;url http://www.ircN.org
;%%%%%%%%%%%%%%%%%%%%%%%%

; make 'delete log' thing allow for a custom exe to run (ex eraser)


/*

todo:

Add multiple log directories.. will add every subfolder/log file from them and know which file refers to which dir

*/


on *:CLOSE:@logviewer:{
  if ($isfile($qt($td(logview_dates.dat)))) .remove $qt($td(logview_dates.dat))
  ntmp -r logview.*
}

on ^*:HOTLINK:*.log*:@logviewer:{
  if (*Found matching lines in* iswm $hotline) return
  halt
}
on *:HOTLINK:*.log*:@logviewer:{
  if (*Found matching lines in* iswm $hotline) {
    var %q = $logdir $+ $ntmp(logview.dir) $+ \ 
    if ($isfile(%q $+ $1)) logview.showlog %q $+ $1
    elseif  ($isfile(%q $+ $chr(35) $+ $1)) logview.showlog %q $+ $chr(35) $+ $1
  }
}
menu @logviewer {
  Filter:{
    var %a = $$input(Enter wildcard string to filter out of $sline(@logviewer,0) selected logfiles,e)
    var %a = $iif(* !isin %a,* $+) %a $+ $iif(* !isin %a,*)
    if ($sline(@logviewer,0) <= 1) filter -cpfw $qt($ntmp(logview.file)) @logviewer %a
    else {
      var %q = 1
      clear @logviewer
      if ($isfile($dd(whilefix.dll))) var %dll = dll $dd(WhileFix.dll) WhileFix .
      while ($sline(@logviewer,%q) != $null) {
        window -hk @logviewer.temp
        clear @logviewer.temp

        filter -pfw $qt($logdir $+ $ntmp(logview.dir) $+ \ $+ $sline(@logviewer,%q)) @logviewer.temp %a
        if ($filtered) {
          if (!$window(@logviewer)) return
          echo @logviewer 
          echo @logviewer Found $ifmatch matching lines in: $remove($sline(@logviewer,%q),$chr(35))
          echo @logviewer 
          filter -pww @logviewer.temp @logviewer *
        }

        inc %q
      }
      close -@ @logviewer.temp
    }
  }
  Reload:  logview.showlog $ntmp(logview.file)
  Clear: clear $active
  $iif($isfile($ntmp(logview.file)),Delete) {
    var %a = $$input(Move ' $+ $nopath($ntmp(logview.file)) $+ ' to the recycling bin ?,y)
    if (%a) {
      .timer 1 1  remove -b $qt($ntmp(logview.file)) $chr(124) logviewer.refreshwin $ntmp(logview.dir) 
      clear $active
      ntmp logview.file
    }
  }
  $iif(($lines($tp(logview_dates.dat)) && !$mouse.lb),Session Date)
  .$submenu($_popup.logview.dates($1))
  -
  Filter All Logs:{
    var %s = $$input(Enter wildcard string to filter out of all logfiles,e)
    var %s = $iif(* !isin %s,* $+) %s $+ $iif(* !isin %s,*)
    var %a = 1, %b, %dll
    if ($isfile($dd(whilefix.dll))) var %dll = dll $dd(WhileFix.dll) WhileFix .
    clear @logviewer
    while ($findfile($logdir $+ $ntmp(logview.dir),*.log,%a) != $null) {
      set %b $ifmatch
      %dll
      window -hk @logviewer.temp
      clear @logviewer.temp

      filter -pfw $qt(%b) @logviewer.temp %s
      if ($filtered) {
        if (!$window(@logviewer)) return
        echo @logviewer 
        echo @logviewer Found $ifmatch matching lines in: $iif($ntmp(logview.dir),$nopath(%b),$remove(%b,$logdir))
        echo @logviewer 
        filter -pww @logviewer.temp @logviewer *

      }

      inc %a

    }

  }
  Notepad:run notepad $qt($ntmp(logview.file))
  Explore Folder: run explorer.exe /e, $+ $qt($logdir $+ $ntmp(logview.dir))
  $iif(!$mouse.lb,$style(2)  - Settings - ):!
  $iif(!$mouse.lb,Log Folders):!
  ; .Clean:dlg logclean
}
alias showlog logview $1-
alias _filter.refreshdates {
  var %w = @_logview.refreshdates
  window -hsl %w
  clear %w
  filter -fk $qt($ntmp(logview.file))  _filter.refreshdates.output *Session Start:*
  write -c $tp(logview_dates.dat)
  savebuf  @_logview.refreshdates $tp(logview_dates.dat)
  close -@ @_logview.refreshdates 
} 
alias -l _popup.logview.dates {
  var %a
  if ($1 == begin) return $style(2) $tab Jump to :!
  if ($1 isnum) {
    set %a $read($tp(logview_dates.dat),nt,$1)
    if (%a)  return $asctime(%a, mm/dd/yyyy hh.nn.sstt ) : .timer 1 0  findtext -n Session Start: $asctime(%a)  $chr(124) findtext Session Start: $asctime(%a) 

  }
  if ($1 == end) return -
}
alias _filter.refreshdates.output {
  aline  @_logview.refreshdates  $ctime($gettok($1,3-,32))
}
on *:INPUT:@logviewer:{
  if (!$1) {
    logview.showlog $ntmp(logview.file)
    halt
  }

  ;fix this
  var %a = $iif(* !isin $1-,* $+) $1- $+ $iif(* !isin $1-,*)
  clear @logviewer
  filter -cpfw $qt($ntmp(logview.file)) @logviewer %a
  editbox -p $target

  halt
}
alias logviewer.refreshwin {
  var %a 
  set %a $logdir $+ $1-




  ; if ($isdir($1-)) var %a = $1-
  clear -l @logviewer
  if (%a != $logdir) {
    var %c = $base($iifelse($hget(nxt_theme,ircN.HC),0),10,10,2)
    aline -l %c @logviewer == $remove(%a,$logdir) ==
    aline -l %c @logviewer [.]
    aline -l %c @logviewer [..]
    ntmp logview.dir $gettok(%a,-1,92)
  }
  else ntmp logview.dir 


  .echo -q  $finddir( $qt(%a) ,*,0,1,logview.adddir $1-)



  .echo -q  $findfile( $qt(%a) ,*.log,0,1,aline -l @logviewer  $nopath($1-) )



}
alias -l logview.adddir {
  var %c = $base($iifelse($hget(nxt_theme,ircN.HC),0),10,10,2)
  if ($1- == $logdir $+ awaylog) return
  aline -lc %c @logviewer [[ $+ $nopath($1-) $+ ]]

}

;add filtering to window mode
menu @logviewer {

  lbclick {
    if ( $sline($active,0) > 1) return
    var %a = $sline($active,1)
    if (($mouse.lb) && (%a)) {

      if ([*] iswm %a)  { 
        if (%a == [..])  { 
          set %a $deltok($ntmp(logview.dir),-1,92)
          ntmp logview.dir %a
          logviewer.refreshwin $trimr($triml(%a,[),])
        }
        elseif (%a == [.]) {
          logviewer.refreshwin $ntmp(logview.dir) 

        }
        else logviewer.refreshwin $trimr($triml(%a,[),])
      }
      else {
        logview.showlog $logdir $+ $ntmp(logview.dir) $+ \ $+ %a

      }
    }

  }
}
alias logview.showlog {
  if (!$isfile($qt($1-))) return
  var %a = $fline(@logviewer,$nopath($qt($1-)),1,1)
  if (%a)  sline -l @logviewer %a
  ntmp logview.file $1-

  clear @logviewer
  loadbuf -pi  @logviewer $qt($1-)


  _filter.refreshdates
}
alias slog {
  if (!$0) {  theme.syntax /slog <search term> | return } 
  if (!$isfile($qt($window($active).logfile))) { iecho Log file for this window not found | return } 
  logview -s $iif($0 > 1,$qt($1-),$1) $window($active).logfile
}
alias logview {
  ;

  var %chan, %net, %flags, %target, %logdir, %net.incl, %net.mkfold 
  set %net.incl $mopt(6,32)
  set %net.mkfold $mopt(7,21)

  if ($flags($1-,s)) { 
    var %search = $flags($1-,s).val 
    if (* !isin %search) set %search * $+ %search $+ *
  }
  if ($flags($1-,cutoff)) var %cutoff  = $flags($1-,cutoff).val 
  if ($flags($1-,net)) var %net = $flags($1-,net).val 
  set %flags $flags($1-).flags 
  if (%flags) tokenize 32 $flags($1-).text
  set %target $1
  if (!%target) set %target $iifelse(#,$query($active))

  if (!$1) {
    ; hmm if ((($istok(%flags,s,44)) && (!%search)) || (%search)) goto logsyntax
    if ((($istok(%flags,s,44)) && (!%search)) || (%search)) { 
      if ($chan) { set %target $chan($chan).logfile | goto startlogview }
      else  goto logsyntax
    }
  }
  if (%target) {
    if (($1- ischan) && (!%net)) {
      if ($chan($1).logfile) set %target $ifmatch
    }
    elseif (($query($1-)) && (!%net)) {
      if ($query($1).logfile) set %target $ifmatch
    }
    elseif (($isfile($logdir $+ $mklogfn($1))) && (!%net)) set %target $logdir $+ $mklogfn($1)
    elseif (($isfile($1-)) && (!%net)) set %target $1-
    else {
      var %srch.i
      :topsrch
      var %srchdir = $iif($isdir($qt($logdir $+ $iif(!%srch.i,$iif(%net.mkfold,$iifelse(%net,$curnet))))),$logdir $+ $iif(!%srch.i,$iif(%net.mkfold,$iifelse(%net,$curnet))),$logdir)
      var %srchfile = $iif(*.log iswm $1,$1,$iif(* !iswm $1,*) $+ $1 $+ $iif((%net.incl && !%net.mkfold),* $+ . $+ $iifelse(%net,$curnet)) $+ *.log)
      var %x = $findfile($qt(%srchdir),%srchfile,0)
      if (%x) var %y = $findfile($qt(%srchdir),%srchfile,%x)
      if (%y) set %target %y
      else {
        if (!%srch.i) && (!%net) { inc %srch.i | goto topsrch }
        goto logsyntax
      }
    }
  }
  :startlogview
  set %logdir $iifelse($nofile(%target),$logdir)

  if ($window(@logview)) close -@ @logviewer
  window -aeRikl15 $+ $iif($version >= 7.11, j99999999) @Logviewer $window(Status Window).font  $window(Status Window).fontsize
  logviewer.refreshwin $remove(%logdir,$logdir)

  if ($isfile(%target)) {
    if (%search) {
      ntmp logview.file %target
      var %a = $fline(@logviewer,$nopath(%target),1,1)
      if (%a) sline -l @logviewer %a
      clear @logviewer
      if (%cutoff) {
        var %lof $lines(%target)
        if (%cutoff.start >= %lof) { iecho Logview: error, the file is smaller than your cutoff size. displaying full log. | unset %cutoff }
        var %cutoff.start = $sub(%lof,%cutoff)
      }
      filter -cpfw $+ $iif(%cutoff,r $+(%cutoff.start,-,%lof))  $qt($ntmp(logview.file)) @logviewer %search
    }
    else  .timer 1 0 logview.showlog %target
  }
  return
  :logsyntax
  theme.syntax /logview [-s "search string"] [-net network] [chan/nick/file]
}

on *:LOAD:{
  ;  modvarload 256 logview
}



/*


log cleaner


redo/fix this later

*/





dialog logclean {
  title "Log Cleaner"
  size -1 -1 181 169
  option dbu
  check "Lines", 1, 5 42 29 10
  check "Size", 2, 5 54 25 10
  check "Age", 3, 5 67 26 10
  edit "", 4, 34 68 20 11
  combo 5, 55 68 30 27, size drop
  edit "", 6, 34 55 20 11
  combo 7, 55 55 30 39, size drop
  edit "", 8, 34 42 20 12
  button "Go", 9, 100 114 29 15
  text "Filename Match:", 10, 5 21 52 11
  edit "", 11, 59 20 82 12
  check "Scan Subdirectories", 12, 5 82 67 9
  check "regex", 13, 144 21 28 9
  text "Scan Folder:", 14, 5 7 52 11
  edit "", 15, 59 6 82 12, disable
  button "...", 16, 144 6 24 11
}
on 1:dialog:logclean:sclick:16:{
  did -ra $dname 15 $$sdir($logdir)

}

on 1:dialog:logclean:init:*:{
  var %n = $dname 
  did -a %n 7 Bytes
  did -a %n 7 KB
  did -a %n 7 MB

  did -a %n 5 Hours
  did -a %n 5 Days
  did -a %n 5 Weeks
  did -a %n 5 Months
  did -a %n 5 Years

  did -c %n 5,7 1
  did -ra %n 15 $logdir

}
on 1:dialog:logclean:sclick:9:{
  var %f 

  if ($did(1).state) {
    if ($did(8) isnum) set %f %f -lines $did(8)
  }
  if ($did(2).state) {
    if ($did(6) isnum) {
      var %n = $did(6)
      if ($did(7).sel == 2) set %n $calc(%n * 1024)
      if ($did(7).sel == 3) set %n $calc(%n * 1024 * 1024)
      set %f %f -size %n
    }
  }
  if ($did(3).state) {
    if ($did(4) isnum) {
      var %n = $did(4)
      if ($did(5).sel == 1) set %n $calc(%n *60*60)
      if ($did(5).sel == 2) set %n $calc(%n *60*60*24)
      if ($did(5).sel == 3) set %n $calc(%n *60*60*24*7)
      if ($did(5).sel == 4) set %n $calc(%n *60*60*24*7*4)
      if ($did(5).sel == 5) set %n $calc(%n *60*60*24*7*4*12)
      set %f %f -age %n
    }
  }
  if (%f) logclean %f
}
dialog ircN.cleanlog {
  title "Clean logs"
  size -1 -1 157 71
  option dbu
  edit "", 1, 15 3 124 11, read autohs
  button "...", 2, 140 3 17 9
  check "Lines:", 3, 1 15 36 12
  edit "", 4, 66 16 25 11, autohs
  check "Size:", 5, 1 26 36 12
  edit "", 6, 66 27 25 11, autohs
  combo 7, 93 28 21 45, size drop
  edit "", 8, 40 39 25 11, autohs
  check "Age:", 9, 1 37 36 12
  combo 10, 66 40 27 65, size drop
  text "since", 11, 93 41 12 8
  combo 12, 108 40 40 45, size drop
  button "Cancel", 13, 86 56 34 13, cancel
  button "Scan", 14, 121 56 34 13, default
  text "Dir:", 15, 2 4 9 10
  combo 16, 40 16 27 50, size drop
  combo 17, 40 27 27 50, size drop
}
on *:dialog:ircN.cleanlog:sclick:2:{
  did -ra $dname 1 $$sdir($logdir)
}

on *:dialog:ircN.cleanlog:sclick:3:{
  if ($did(3).state) did -v $dname 4,16
  else did -h $dname 4,16
}
on *:dialog:ircN.cleanlog:sclick:5:{
  if ($did(5).state) did -v $dname 6,7,17
  else did -h $dname 6,7,17
}
on *:dialog:ircN.cleanlog:sclick:9:{
  if ($did(9).state) did -v $dname 8,10,11,12
  else did -h $dname 8,10,11,12
}
on *:dialog:ircN.cleanlog:sclick:14:{
  if ($did(9).state) { 
    var %t2 = 60*60 60*60*24 60*60*24*7 60*60*24*7*4 60*60*24*7*4*12
    var %t = $calc($did(8) * $gettok(%t2,$did(10).sel,32))
  }
  var %f = $iif($did(3).state,$+($chr(45),lines) $did(4)) $iif($did(5).state,$+($chr(45),size) $did(6)) $iif($did(9).state,$+($chr(45),age) %t) 
  logclean %f $did(1) 
}
on *:dialog:ircN.cleanlog:init:0:{
  did -h $dname 4,6,8,7,10,11,12,16,17
  did -a $dname 7 KB
  did -a $dname 7 MB
  did -a $dname 7 GB
  did -a $dname 10 Hours
  did -a $dname 10 Days
  did -a $dname 10 Weeks
  did -a $dname 10 Months
  did -a $dname 10 Years
  did -a $dname 12 Created
  did -a $dname 12 Modified
  did -a $dname 16 bigger
  did -a $dname 16 smaller
  did -a $dname 17 bigger
  did -a $dname 17 smaller
  did -c $dname 7 2
  did -c $dname 10 2
  did -c $dname 12 1
  did -c $dname 16 1
  did -c $dname 17 1
  did -ra $dname 1 $logdir

}
