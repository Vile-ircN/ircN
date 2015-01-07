; ircN 9 eXtented Theme Engine 1.0
; based on:
; KTE - Kamek's Theme Engine v1.5
; MTS-compatible theme engine (standard v1.0/1.1) -- homepage: http://www3.brinkster.com/ircweb/mts/
; Dialogs made using Dialog Studio & DCXStudio

alias CurTheme return $hget(nxt_data,CurTheme)
alias CurScheme return $iifelse($hget(nxt_data,CurScheme),$null)
alias nxt.load if (!$isid) { nxt_load $1- }
alias nxt.unload if (!$isid) { nxt_unload $1- }
alias nxt.scheme if (!$isid) { nxt_scheme $1- }
alias nxt.refresh if (!$isid) { nxt_refresh $1- }
alias nxtget return $hget(nxt_theme,$1-)

alias nxt.echo if (!$isid) { nxt_echo $1- }
alias nxt.error if (!$isid) { nxt_error $1- }

alias theme {
  if (!$0) || ($1 == -list) { themes $1 | return }
  theme.load $1-
}
alias theme.setting return $hget(nxt_theme, $1)
alias theme.load if (!$isid) { nxt_load $1- }
alias theme.reload if (!$isid) { nxt_load $iif($hget(nxt_data, CurScheme),-s $+ $hget(nxt_data, CurScheme)) $hget(nxt_data, CurTheme) }
alias theme.unload if (!$isid) { nxt_unload $1- }
alias theme.scheme if (!$isid) { nxt_scheme $1- }
alias mtsversion return $nxt_mtsver

alias -l _isfile if (?*"?* iswm $1) { return } | if ($isfile($1)) { return $1 }
alias -l _hmake if ($hget($1)) { hfree $1 } | hmake $1-

alias -l kte_ver return 1.5
alias -l nxt_ver return 1.6
alias -l nxt_dynver return 1.5
alias -l kte_mtsver return 1.1
alias -l nxt_mtsver return 1.3

alias -l nxt_file return $+(", $scriptdir, $1, ")
;alias -l nxt_usrfile return $+(", $scriptdir, $1, ")
alias -l nxt_usrfile return $sd($1-)

alias nxt_cachedir return $td($+(theme\,$1-))
alias nxt_thmhsh return nxt_theme
alias nxt_datahsh return nxt_data
alias nxt_evnthsh return nxt_events

;$isfontinstalled snipplet by praetorian (with minor modifications)
alias nxt_fontexists {
  var %w = @NXT_FontExists,%f = $td(fontcheck.bmp)
  var %deffont = Arial,Terminal,Fixedsys
  if ($istok(%deffont,$1,44)) return $true
  window -ak0pBfh +d %w -1 -1 200 100 
  drawfill -r %w $rgb(0,0,0) $rgb(0,0,0) 0 0 
  drawtext -r %w $rgb(255,255,255) "this is surely not the name of an installed font" -9 5 5 test. 
  drawsave %w %f 
  var %crc = $crc(%f) 
  clear %w 
  drawfill -r %w $rgb(0,0,0) $rgb(0,0,0) 0 0 
  drawtext -r %w $rgb(255,255,255) $qt($1) -9 5 5 test. 
  drawsave %w %f 
  var %crc2 = $crc(%f) 
  .remove %f 
  window -c %w 
  if (%crc != %crc2) { return $true } 
  else { return $false } 
}

alias -l _noparse {
  var %i = 1, %t = $numtok($1, 32), %r
  while (%i <= %t) {
    %r = %r $airc_noparse_safetok($gettok($1, %i, 32))
    inc %i
  }
  return %r
}

alias -l airc_noparse_safetok {
  if ($istok(35 91 124, $asc($1), 32) && $len($1) == 1) { return $!chr( $+ $asc($1) $+ ) }
  if ($1 == [[ $+ [[) { return [[ $+ [[ $!+ [[ $+ [[ }
  if ($1 == ]] $+ ]]) { return ] $+ ] $!+ ] $+ ] }
  if ($!* iswm $1) { return $+($, !, $mid($1, 2)) }
  if (% $+ * iswm $1) { return % $!+ $airc_noparse__safetok($mid($1, 2)) }
  return $1
}
alias -l airc_noparse__safetok return $airc_noparse_safetok($1)

alias -l nxt_listschemes {
  var %s = $hget(nxt_theme, Scheme $+ $1)
  if (!%s) || ($1 !isnum) { return }
  return $iif(($hget(nxt_data, CurScheme) = $1), $style(1)) $_noparse(%s) $+ :nxt_scheme $1
}
alias nxt_schemecount {
  if (!$isfile($qt($1-))) return
  var %a = 1, %b = 0
  while ($ini($qt($1-),%a) != $null) {
    if (Scheme* iswm $ifmatch) inc %b
    inc %a
  }
  return %b
}
menu menubar {
  &Customize
  .Load theme...:themes
  .$iif(($hget(nxt_theme, Scheme1) != $null), Change scheme)
  ..$iif((!$hget(nxt_data, CurScheme)), $style(1)) No scheme:nxt_scheme -d
  ..-
  ..$submenu($nxt_listschemes($1))
}

on *:START:nxt_onstart
on *:LOAD:nxt_firststart
on *:UNLOAD:nxt_onunload

on *:CONNECT:nxt_v connected 1
on *:DISCONNECT:hdel -w nxt_data $+(c, $cid, :*)
on *:EXIT:hdel -w nxt_data c*:* | nxt_savedata

on *:JOIN:#:nxt_onjoin
on *:PART:#:if ($nick == $me) { nxt_left $chan }
on *:KICK:#:if ($knick == $me) { nxt_left $chan }

alias nxt_onstart {
  _hmake nxt_theme 16
  if ($isfile($sd(nxt-theme.dat))) { hload -b nxt_theme $sd(nxt-theme.dat) }
  elseif ($isfile($nxt_file(nxt-def.dat))) { hload -b nxt_theme $nxt_file(nxt-def.dat) }
  _hmake nxt_data 8 | if ($isfile($sd(nxt-data.dat))) { hload -b nxt_data $sd(nxt-data.dat) }
  _hmake nxt_events 8 | .nxt_refresh -n
  hdel -w nxt_data c*:*
  if ($hget(nxt_data, Hide) !isnum) { hadd nxt_data Hide 8 }
  if ($hget(nxt_data, Cache) !isnum) { hadd nxt_data Cache 1 }
  if ($hget(nxt_data, DlgSet) !isnum) { hadd nxt_data DlgSet 1 }
  if ($hget(nxt_data, Apply) !isnum) { hadd nxt_data Apply 959 }
  if ($hget(nxt_data, FRep.Status) == $null) {
    ; add some font replacements
    var %rep = 0, %bestrep = Terminal, %msss = Microsoft Sans Serif
    if (!$nxt_fontexists(IBMPC)) { hadd nxt_data FRep.Rep.IBMPC Terminal | %rep = 1 }
    else { %bestrep = IBMPC }
    if (!$nxt_fontexists(GwdTE_437)) { hadd nxt_data FRep.Rep.GwdTE_437 %bestrep | %rep = 1 }
    if (!$nxt_fontexists(PC8X16)) { hadd nxt_data FRep.Rep.PC8X16 %bestrep | %rep = 1 }
    if ($nxt_fontexists(%msss)) { hadd nxt_data FRep.Rep.MS\~Sans\~Serif %msss | %rep = 1 }
    hadd nxt_data FRep.Status %rep
  }
  if ($hget(nxt_data, TimestampFormat) != $null) { .timestamp -f $ifmatch }

  _refreshcolorgfx
  unset %nxt__* %_nxt_*
}

alias nxt_firststart {
  if ($version < 6.01) { echo -ati2 Please use this add-on on mIRC 6.01 or greater. | .timer -o 1 0 .unload -nrs $+(", $script, ") | return }
  .enable #nxt_DefTheme
  if ($hget(nxt_theme)) { hfree nxt_theme } | if ($hget(nxt_data)) { hfree nxt_data } | if ($hget(nxt_events)) { hfree nxt_events }
  nxt_onstart
  .timer 1 1 nxt_load $+($chr(36),themedir,$chr(40),ircN\ircN.mts,$chr(41))
}
alias -l nxt_onunload {
  var %p
  if ($isfile($sd(nxt-Restore.dat))) { %p = $crlf $+ Your settings will be restored. }
  if ($hget(nxt_data, CurTheme)) && ($input(Unload current theme before unloading nxt? $+ %p, 8)) { theme.unload }
  else {
    if ($script($nxt_usrfile(nxt-dyn.mrc))) { .unload -rs $qt($ifmatch) }
    hdel nxt_data CurTheme
    hdel nxt_data Extracted
  }
  hfree nxt_theme | nxt_savedata | hfree nxt_data
  .remove $sd(nxt-theme.dat)
  .remove $sd(nxt-Restore.dat)
  .remove $nxt_usrfile(nxt-dyn.mrc)
  unset %nxt_* %_nxt_*
  hfree -w nxt_*
}

alias nxt_refresh {
  if ($isid) return
  if (n !isin $1) saveini
  if (u !isin $1) hdel -w nxt_events *
  hadd nxt_events Active.Invites $gettok($readini($mircini, options, n3), 26, 44)
  hadd nxt_events Active.Queries $gettok($readini($mircini, options, n4), 5, 44)
  hadd nxt_events Active.Notices $gettok($readini($mircini, options, n5), 13, 44)
  hadd nxt_events Active.Whois $gettok($readini($mircini, options, n2), 26, 44)
  hadd nxt_events Active.CTCPs $gettok($readini($mircini, options, n4), 19, 44)
  hadd nxt_events Active.Away $gettok($readini($mircini, options, n4), 32, 44)
  var %def = $readini($mircini, events, default), %i = $numtok(%def, 44), %set
  if (!%def) { %def = 1,1,1,1,1,1,1,1 }
  else { while (%i) { %def = $puttok(%def, $calc($gettok(%def, %i, 44) + 1), %i, 44) | dec %i } }
  %i = $chan(0)
  while (%i) {
    %set = $readini($mircini, events, $chan(%i))
    if (!%set) { %set = %def }
    else { while ($findtok(%set, 0, 1, 44)) { %set = $puttok(%set, $gettok(%def, $ifmatch, 44), $ifmatch, 44) } }
    hadd nxt_events $chan(%i) %set
    dec %i
  }
  var %x, %z
  %i = $ini($sd(evntxtra.ini),0)
  while (%i) {
    set %z $ini($sd(evntxtra.ini),%i)
    %x = $ini($sd(evntxtra.ini),%z,0)
    while (%x) {
      hadd nxt_events $+(%z,.,$ini($sd(evntxtra.ini),%z,%x)) $readini($sd(evntxtra.ini),%z,$ini($sd(evntxtra.ini),%z,%x))
      dec %x
    }
    dec %i
  }

  if ($show)  nxt_echo -a Settings were updated from $+(', $nopath($mircini), '.)
}

alias nxt_load {
  if ($isid) { return }
  var %h = nxt_theme, %dat = nxt_data, %fn
  if (!$isdir($nxt_cachedir)) { mkdir $nxt_cachedir }
  if (!$0) { themes | return }
  if ($0 > 1) && ($regex($1, /-s\d+/i)) { var %sch = $int($mid($1, 3)) | tokenize 32 $2- }
  set -n %fn $1-
  if ("*" iswm %fn) { %fn = $mid(%fn, 2, -1) }
  if (*.nxt !iswm %fn) && (*.mts !iswm %fn) { %fn = %fn $+ .mts }

  if (\* !iswm %fn) && (?:\* !iswm %fn) {
    var %tfn = $themedir(%fn)
    if ($isfile(%tfn)) { %fn = %tfn }
    elseif ($nxt_trydir(%fn)) { %fn = $ifmatch }
    elseif ($nxt_trydir($puttok(%fn,nxt,-1,46))) { %fn = $ifmatch }
    elseif ($findfile($themedir, %fn, 1, 2)) { %fn = $ifmatch }
  }
  if (!$isfile(%fn)) {
    nxt_error -a File not found
    return
  }
  %fn = $qt(%fn)
  ; ok, file exists... check if it's valid...
  if (!$read(%fn, nw, [mts])) { nxt_error -a Invalid theme file (main theme section not found) | goto end }
  var %ver = $read(%fn, ns, MTSVersion)
  if (!%ver) { set %ver $read(%fn, ns, NXTVersion) | var %ver.NXT = yes }
  if (!%ver) { nxt_error -a Invalid theme file (no MTS version declared) | goto end }
  elseif ((!$istok(1 1.1 1.2 1.3, $calc(%ver), 32)) && (%ver.NXT != yes)) { nxt_error -a Invalid theme file (standard v $+ %ver is not supported) | goto end }
  elseif ((!$istok(1 1.1 1.2 1.3, $calc(%ver), 32)) && (%ver.NXT == yes)) { nxt_error -a Invalid theme file (standard v $+ %ver is not supported) | goto end }
  if (%sch != $null) && ((%sch = 0) || (!$read(%fn, nw, $+([Scheme, %sch, ])))) {
    nxt_error -a Invalid parameter (there's no scheme $chr(35) $+ %sch $+ ) | goto end
  }

  ; now, theme WILL load
  %_nxt_fn = %fn
  %_nxt_nto = $qt($+($left(%fn, $calc(0 - $len($gettok(%fn,$numtok(%fn,46),46)))),nto))
  %_nxt_sch = %sch
  nxt_doload
  nxt_savedata

  if ($isbit($hget(%dat,dlgset),2)) {
    if ($dialog(ircn.nxt)) dialog -x ircn.nxt
    if (($dialog(ircn.nxt.modern)) && (!$dialog(ircn.setup.modern))) dialog -x ircn.nxt.modern
  }

  :end
  unset %_nxt_*
}

alias nxt_scheme {
  if ($isid) { return }
  var %thm = $hget(nxt_data, CurTheme), %i = 1
  if (!%thm) { nxt_error -a There's no theme loaded. | return }
  if (!$isfile(%thm)) { nxt_error -a The theme file was not found. | return }
  if (!$0) {
    var %r | while ($hget(nxt_theme, Scheme $+ %i) != $null) { %r = %r $ifmatch $+ , | inc %i }
    if (%r = $null) { nxt_echo -a The current theme has no schemes }
    else { nxt_echo -a Schemes from the current theme: $left(%r, -1) } | return
  }
  if ($0 = 1) && ($1 isnum) && (. !isin $1) && ($hget(nxt_theme, Scheme $+ $int($1)) != $null) { set -u %_nxt_sch $int($1) }
  elseif ($1- != -d) { while ($hget(nxt_theme, Scheme $+ %i) != $null) { if ($ifmatch == $1-) { set -u %_nxt_sch %i | break } | inc %i } }
  if (!%_nxt_sch) && ($1 != -d) { nxt_error -a The requested scheme was not found | return }
  set -u %_nxt_fn %thm
  set -u %_nxt_nto $qt($+($left(%thm, $calc(0 - $len($gettok(%thm,$numtok(%thm,46),46)))),nto))
  set -u %_nxt_chscheme $true
  nxt_doload
  nxt_savedata
}

alias nxt_unload {
  if ($isid) { return }
  if (!$isfile($sd(nxt-Restore.dat))) && (!$hget(nxt_data, CurTheme)) && ($1 != -f) { nxt_error -a You're not currently using a theme. | return }
  if (!%_nxt_loading) && ($isfile($sd(nxt-Restore.dat))) {
    nxt_status_open | nxt_status_show 0 Unloading current theme...
    if ($hget(nxt_Restore)) { hfree nxt_Restore }
    _hmake nxt_Restore 8
    hload -b nxt_Restore $sd(nxt-Restore.dat)
  }
  nxt_dounload
  if ($script($nxt_usrfile(nxt-dyn.mrc))) { .unload -rs $qt($ifmatch) | .remove $qt($ifmatch) }
  .enable #nxt_DefTheme
  if ($hget(nxt_Restore)) { hfree nxt_Restore | .remove $sd(nxt-Restore.dat) | nxt_status_close }
}

alias -l nxt_savedata {
  if ($hget(nxt_theme)) { hsave -ob nxt_theme $sd(nxt-theme.dat) }
  hsave -ob nxt_data $sd(nxt-data.dat)
}

alias -l nxt_rmdir var %x = $finddir($1-, *, 0, 1, nxt_rmdir $1-) | .rmdir $+(", $1-, ")

alias -l nxt_trydir if (\ isin $1) { return } | var %fn = $+($themedir, $iif((*.mts iswm %fn) || (*.nxt iswm %fn), $left(%fn, -4), %fn), \, $1) | if ($isfile(%fn)) { return %fn }

alias nxt_echo nxt_out Echo $color(info) $1-
alias nxt_error nxt_out Error $color(info) $1-
; /nxt_out str <type>, int <color>, str <target>, str <text>
alias -l nxt_out {
  if ($3 == -a) && (@* !iswm $active) { var %f = a }
  elseif ($3 == -a) || ($3 == -s) { var %f = s } | else { var %p = $3 }
  set -u %:echo echo $2 -qti2 $+ %f %p
  set -nu %::text $4- | theme.text $1
}

alias -l nxt_dobackup {
  var %base, %i = 1, %t = 27, %rgb, %f, %font, %fsize, %base-d = back;action;ctcp;high;info;info2;invite;join;kick;mode;nick;normal;notice; $+ $&
    notify;other;own;part;quit;topic;wallops;whois;edit;editbox t;list;listbox t;gray
  saveini
  if (!$hget(nxt_Restore)) { hmake nxt_Restore 8 }
  while (%i <= %t) { %base = %base $+ , $+ $color($gettok(%base-d, %i, 59)) | inc %i }
  %i = 0 | %t = 15 | while (%i <= %t) { %rgb = %rgb $rgb($color(%i)) | inc %i }
  hadd nxt_Restore Colors $gettok(%base, 1-, 44)
  hadd nxt_Restore RGBColors %rgb
  %i = 1 | %t = $cnick(0)
  while (%i <= %t) {
    %f = $+(-, $iif(($cnick(%i).anymode), a), $iif(($cnick(%i).nomode), n), $iif(($cnick(%i).ignore), i), $iif(($cnick(%i).op), o), $iif(($cnick(%i).voice), v), $&
      $iif(($cnick(%i).protect), p), $iif(($cnick(%i).notify), y), m, $cnick(%i).method)
    hadd nxt_Restore CNick- $+ %i %f $iif(($cnick(%i) != $null), $cnick(%i), *) $cnick(%i).color $cnick(%i).modes $cnick(%i).levels
    inc %i
  }
  hadd nxt_Restore Timestamp $iif(($window(Status Window).stamp), ON, OFF)
  hadd nxt_Restore TimestampFormat $readini($mircini, text, timestamp)
  hadd nxt_Restore FontDefault $+($window(Status Window).font, $chr(44), $window(Status Window).fontsize, $&
    $iif(($window(Status Window).fontbold), $chr(44) $+ b))
  %font = $readini($mircini, fonts, fchannel) | %fsize = $gettok(%font, 2, 44)
  hadd nxt_Restore FontChan $gettok(%font, 1, 44) $+ , $+ $right(%fsize, 2) $+ $iif((%fsize > 700), $chr(44) $+ b)
  %font = $readini($mircini, fonts, fquery) | %fsize = $gettok(%font, 2, 44)
  hadd nxt_Restore FontQuery $gettok(%font, 1, 44) $+ , $+ $right(%fsize, 2) $+ $iif((%fsize > 700), $chr(44) $+ b)
  hsave -ob nxt_Restore $sd(nxt-Restore.dat)
  hfree nxt_Restore
}

; /nxt_doload
alias -l nxt_doload {
  var %h = nxt_theme, %dat = nxt_data, %fn = %_nxt_fn, %nto = %_nxt_nto, %w = @nxt_theme, %i = 1, %t, %sch = %_nxt_sch, $&
    %chscheme = %_nxt_chscheme, %apply = $hget(nxt_data, Apply)
  nxt_status_open
  nxt_status_show 0 Preparing to load...

  %_nxt_loading = $true
  if ($isbit(%apply, 1)) || (!%apply) { %apply = 1023 }
  if (!%_nxt_chscheme) {

    if ($hget(%dat, CurTheme)) { nxt_dounload }
    else { nxt_dobackup }
  }

  .disable #nxt_DefTheme

  window -lhBi %w
  hdel -w %h * | if ($isfile($nxt_file(nxt-def.dat))) { hload -ob %h $nxt_file(nxt-def.dat) }

  loadbuf -tmts %w %fn
  if (%sch) { loadbuf -tScheme $+ %sch %w %fn }
  filter -cwwg %w %w /^[^\x20;]/
  %t = $line(%w, 0)
  while (%i <= %t) { hadd %h $line(%w, %i) | inc %i }
  close -@ %w

  ; ircN Theme Override loading
  ;echo -s nto: %nto
  if ($isfile(%nto)) {
    ;echo -s nto existsXXXXXXX
    set %i 1
    window -lhBi %w
    loadbuf -tmts %w %nto
    if ((%sch) && ($read(%nto,w,$+([Scheme,%sch,])))) { loadbuf -tScheme $+ %sch %w %nto }
    filter -cwwg %w %w /^[^\x20;]/
    %t = $line(%w, 0)
    while (%i <= %t) { hadd %h $line(%w, %i) | inc %i }
    close -@ %w
  }

  if ($hget(%h, BaseColors) != $null) {
    tokenize 44 $ifmatch
    hadd %h BaseColors $replace($nxt_bc($1) $nxt_bc($2) $nxt_bc($3) $nxt_bc($4), $chr(32), $chr(44))
  }
  ; AC/HC/SC
  if (!$len($hget(%h,ircN.SC))) hadd %h ircN.SC $gettok($hget(%h,BaseColors),4,44)
  if (!$len($hget(%h,ircN.HC))) hadd %h ircN.HC $gettok($hget(%h,BaseColors),3,44)
  if (!$len($hget(%h,ircN.AC))) hadd %h ircN.AC $gettok($hget(%h,BaseColors),2,44)

  %_nxt_apply = %apply
  if ($isbit(%apply, 3)) || ($isbit(%apply, 6)) { nxt_apply_colors }
  if ($isbit(%apply, 5)) { nxt_apply_fonts }
  if ($isbit(%apply, 2)) || ($isbit(%apply, 9)) || ($isbit(%apply, 10)) { nxt_apply_bg %fn }
  if ($isbit(%apply, 8)) {
    if ($hget(%h, MTSVersion) == 1.0) {
      var %ts = $hget(%h, Timestamp) | if (%ts != $null) && (%ts != off) { hadd %h TimestampFormat $ifmatch | hadd %h Timestamp ON }
    }
    if ($istok(on off, $hget(%h, Timestamp), 32)) { .timestamp $hget(%h, Timestamp) }
    if ($hget(%h, TimestampFormat) != $null) {
      var %ts | set -n %ts $nxt__cl($ifmatch)
      .timestamp -f %ts
      hadd nxt_data TimestampFormat %ts
    }
  }
  if (* !iswm $hget(%h, ParenText)) { hadd %h ParenText (<text>) }
  if ($isbit(%apply, 4)) {
    var %script = $hget(%h, Script), %fscript = $+(", $nofile(%fn), %script, ")
    if (%script != $null) && ($isfile(%fscript)) { hadd %dat Script %fscript | .reload -rs %fscript }
    set -u %_nxt_fn %fn
    set -u %_nxt_nto $qt($+($left(%fn, $calc(0 - $len($gettok(%fn,$numtok(%fn,46),46)))),nto))
    var %cached = 0, %cfn = $qt($nxt_cachedir($+(nxt-dyn-, $nopath(%fn), $iif((%sch), -S $+ %sch), .mrc))), %ln
    if ($isfile(%cfn)) {
      %ln = $read(%cfn, 3)
      if (%ln == ; nxt-dyn.dat $nxt_dynver $crc($nxt_file(nxt-dyn.dat)) $crc(%fn)) {
        .copy -o %cfn $nxt_usrfile(nxt-dyn.mrc)
        write -l3 $nxt_usrfile(nxt-dyn.mrc) ;
        %cached = 1
      }
    }
    if (!%cached) {
      nxt_buildfile
      ; Don't cache scripts at this point of development
      ;if ($isbit($hget(nxt_data, Cache), 2)) {
      ;  .copy -o $nxt_usrfile(nxt-dyn.mrc) %cfn
      ;  write -il3 %cfn ; nxt-dyn.dat $nxt_dynver $crc($nxt_file(nxt-dyn.dat)) $crc(%_nxt_fn)
      ;}
    }
    nxt_status_show 0 Loading theme script...
    .reload -rs $+ $calc($script(0) + 1) $nxt_usrfile(nxt-dyn.mrc)
  }
  else { .enable #nxt_DefTheme | if ($script($nxt_usrfile(nxt-dyn.mrc))) { .unload -rs $+(", $ifmatch, ") } }
  unset %_nxt_loading %_nxt_apply
  if (%sch) { hadd nxt_data CurScheme %sch }
  else { hdel nxt_data CurScheme }
  if ($isfile(%nto)) { hadd nxt_data CurNTO %nto }
  else { hdel nxt_data CurNTO }
  nxt_status_close
  if (!%chscheme) {
    hadd %dat CurTheme %fn
    if ($show) { set -u %:echo echo $color(info) -ati2 | linesep -a }
    else { set -u %:echo nxt_void }
    theme.text Load
    if ($show) { linesep -a }
  }
}
alias -l nxt_bc return $right(0 $+ $int($calc($1 % 16)), 2)

alias -l nxt_dounload {
  if ($show) { set -u %:echo echo $color(info) -ati2 } | else { set -u %:echo nxt_void }
  if (!$isalias(theme.text)) { .enable #nxt_DefTheme }
  theme.text Unload

  if ($script($longfn($hget(nxt_data, Script)))) { .unload -rs $qt($ifmatch) }
  hdel -w nxt_theme *
  var %i = 1, %item
  while ($hget(nxt_data, %i).item) {
    %item = $ifmatch
    if ($istok(ThmDir Hide Cache Apply DlgSet Settings1 NoTheme, %item, 32)) || (FRep.* iswm %item) { inc %i }
    else { hdel nxt_data %item }
  }
  %_nxt_apply = 1023
  ; restoring nicklist...
  if ($isbit($hget(nxt_data,apply),6)) { var %i = $cnick(0) | while (%i) { .cnick -r 1 | dec %i } }
  if (!%_nxt_loading) { %i = 1 | while ($hget(nxt_Restore, CNick- $+ %i)) { .cnick $ifmatch | inc %i } }
  elseif ((%_nxt_loading) && (!$isbit($hget(nxt_data,apply),6))) {  %i = 1 | while ($hget(nxt_Restore, CNick- $+ %i)) { .cnick $ifmatch | inc %i } }
  if (!%_nxt_loading) && ($hget(nxt_Restore)) {
    ; restoring colors...
    hadd nxt_theme Colors $hget(nxt_Restore, Colors)
    hadd nxt_theme RGBColors $hget(nxt_Restore, RGBColors)
    nxt_apply_colors
    ; restoring fonts...
    hadd nxt_theme FontDefault $hget(nxt_Restore, FontDefault)
    hadd nxt_theme FontChan $hget(nxt_Restore, FontChan)
    hadd nxt_theme FontQuery $hget(nxt_Restore, FontQuery)
    nxt_apply_fonts
    ; restoring timestamp...
    if ($hget(nxt_Restore, Timestamp)) { .timestamp $ifmatch }
    if ($hget(nxt_Restore, TimestampFormat)) { .timestamp -f $ifmatch }
    hdel -w nxt_theme *
  }
  ; removing background... channels
  scon -a var %i = $!chan(0) $chr(124) while (%i) $chr(123) background -ex $!chan(%i) $chr(124) dec % $+ i $chr(125)
  remini $qt($mircini) background wchannel
  ; query windows
  scon -a var %i = $!query(0) $chr(124) while (%i) $chr(123) background -ex $!query(%i) $chr(124) dec % $+ i $chr(125)
  scon -a var %i = $!chat(0) $chr(124) while (%i) $chr(123) background -ex $!chat(%i) $chr(124) dec % $+ i $chr(125)
  remini $qt($mircini) background wquery
  ; others
  scon -a background -sx $chr(124) background -gx $chr(124) background -mx $chr(124) background -dx
  scon -a background -lx $chr(124) background -hx $chr(124) background -ux
  ; finishing...
  if (!%_nxt_loading) && ($isfile($nxt_file(nxt-def.dat))) { hload -ob nxt_theme $nxt_file(nxt-def.dat) }
  unset %_nxt_apply
}

alias -l nxt_buildfile {
  var %w = @nxt_File, %a = aline %w, %i = 1, %t, %rawt, %ircnscriptt, %reali = 0, %realt, %ln, %x, %delta, %lastset, %lntmp
  nxt_status_show 0 Preparing to build script...
  window -hliB %w
  loadbuf %w $nxt_file(nxt-dyn.dat)
  set -n %nxt__pre $nxt_precompile($nxt__cl($remove($hget(nxt_theme, Prefix), <pre>)))

  %t = $line(%w, 0)
  %rawt = $hmatch(nxt_theme, Raw.???, 0)
  %realt = $calc(%t + %rawt)
  %ircnscriptt = $hmatch(nxt_theme, ircN.script.*, 0)
  %realt = $calc(%realt + %ircnscriptt)
  nxt_buildfile_loadsnippets
  nxt_status_show 1 Building theme script...
  :loop_start | ; hack to overcome a mIRC 6.15 issue
  while (%i <= %t) {
    inc %reali
    nxt_status_prog %reali %realt
    %ln = $line(%w, %i)
    if (nxt_set isin %ln) && ($gettok(%ln, 1, 32) == nxt_set) {
      %lastset = %ln
      dline %w %i
      %delta = $nxt_buildfile_usesnippets(%ln, %w, %i)
      inc %i %delta
      inc %t $calc(%delta - 1)
      goto loop_start
    }
    elseif (nxt_unset isin %ln) && ($gettok(%ln, 1, 32) == nxt_unset) {
      if ($numtok(%ln, 32) = 1) { rline %w %i $nxt_buildfile_unsetvars(%lastset) }
      elseif ($gettok(%ln, 2, 32) == +) { rline %w %i $nxt_buildfile_unsetvars(%lastset $gettok(%ln, 3-, 32)) }
      else { rline %w %i $nxt_buildfile_unsetvars(%ln) }
    }
    elseif (nxt:: isin %ln) { %x = $wildtok(%ln, nxt::?*, 1, 32) }
    ;elseif ($gettok(%ln, 1, 32) == #nxtDyn#) { rline %w %i $nxt_dyn_ [ $+ [ $gettok(%ln, 2, 32) ] ] }
    if (%x) {
      %x = $numtok(%ln, 32)
      while (%x) {
        if (nxt::?* iswm $gettok(%ln, %x, 32)) {
          if ($nxt_pcomp($mid($gettok(%ln, %x, 32), 6)) != $null) {
            set -n %lntmp $ifmatch
            if ($gettok(%ln, $calc(%x + 1), 32) == !) { %ln = $deltok(%ln, $calc(%x + 1), 32) }
            else { %lntmp = %lntmp $chr(124) $iif(nxt::DCC* iswm $gettok(%ln,1,32),return,haltdef) }
            %ln = $puttok(%ln, %lntmp, %x, 32)
          }
          else {
            %ln = $deltok(%ln, %x, 32)
            if ($gettok(%ln, %x, 32) == !) { %ln = $deltok(%ln, %x, 32) }
            if ($gettok(%ln, $calc(%x - 1), 32) == |) { %ln = $deltok(%ln, $calc(%x - 1), 32) | dec %x }
          }
          break
        }
        dec %x
      }
      %x =
      if (* !iswm %ln) || (%ln == $chr(32)) { dline %w %i | goto loop_start }
      rline %w %i %ln
    }
    inc %i
  }
  if ($hget(nxt_snippets)) { hfree nxt_snippets }

  var %list = Echo EchoTarget Error, %i = 1, %t = $numtok(%list, 32), %item
  while (%i <= %t) {
    %item = $gettok(%list, %i, 32)
    aline %w alias -l nxt:: $+ %item $nxt_pcomp(%item)
    inc %i
  }
  %i = 1
  while ($hmatch(nxt_theme, Raw.???, %i)) {
    nxt_status_prog %reali %realt
    %item = $ifmatch
    aline %w alias -l nxt:: $+ %item $nxt_pcomp(%item)
    inc %i
    inc %reali
  }
  %i = 1
  while ($hmatch(nxt_theme, ircN.script.*, %i)) {
    nxt_status_prog %reali %realt
    %item = $ifmatch
    aline %w alias nxt:: $+ %item $nxt_pcomp(%item)
    inc %i
    inc %reali
  }
  savebuf %w $nxt_usrfile(nxt-dyn.mrc)
  close -@ %w
  unset %nxt__*
}
;mts precompile identifier by Mpdreamz
alias nxt_precompile {
  var %v = me|server|echo|address|fromserver|c1|c2|c3|c4|newnick|serverinfo|away|iaddress|nick|signontime| $+ $&
    idletime|numeric|target|isoper|operline|text|isregd|port|users|kaddress|parentext|value| $+ $&
    chan|knick|pre|wserver|cmode|raddress|cnick|modes|realname|ctcp|naddress|cid|hword|isregd|realhost| $+ $&
    ssl|ihelpline|comchans|network
  var %eval = $iif($2,2,1) , %x
  !noop $regsub($1,/<( $+ %v $+ )>/g,$+(%,::,\1),%x)
  !noop $regsub(%x,/(\S)%/g,$+(\1,$chr(32),$!+,$chr(32),%),%x)
  !noop $regsub(%x,/(%::(?: $+ %v $+ ))(\S)/g,$+(\1,$chr(32),$!+,$chr(32),\2),%x)
  !noop $regsub(%x,/(\S)\133/g,$+(\1,$chr(32),$!+,$chr(32),$!chr(91),$chr(32),$!+,$chr(32)),%x)
  !noop $regsub(%x,/(\S)\135/g,$+(\1,$chr(32),$!+,$chr(32),$!chr(93),$chr(32),$!+,$chr(32)),%x)
  !noop $regsub(%x,/\133(\S)/g,$+($chr(32),$!+,$chr(32),$!chr(91),$chr(32),$!+,$chr(32),\1),%x)
  !noop $regsub(%x,/\135(\S)/g,$+($chr(32),$!+,$chr(32),$!chr(93),$chr(32),$!+,$chr(32),\1),%x)


  ;added by varg for ircN .nto specifications: <if>variable == whatever : do this ? do that</if> and <ifelse>variable : thisintead</ifelse> and <ifval><nick> : <nick> to </ifval>
  if ($regex(%x,/\<ifval\>(.+) : (.*)\<\/ifval\>/)) !noop $regsub(%x,/\<ifval\>(.+) : (.*)\<\/ifval\>/,$ $+ iif(\1 $+ $chr(44) $+ \2 $+ ),%x)
  if ($regex(%x,/\<if\>(.+) : (.*) \? (.*)\<\/if\>/)) !noop $regsub(%x,/\<if\>(.+) : (.*) \? (.*)\<\/if\>/,$ $+ iif(\1 $+ $chr(44) $+ \2 $+ $chr(44) $+ \3 $+ ),%x)
  if ($regex(%x,/\<ifelse\>(.+) : (.*) <\/ifelse\>/)) !noop $regsub(%x,/\<ifelse\>(.+) : (.*) <\/ifelse\>/,$ $+ iifelse(\1 $+ $chr(44) $+ \2 $+ ),%x)
  %x = $replace(%x,<lt>,<,<gt>,>)
  return $($replace(%x,$(%::echo,),$(%:echo,),[,$!chr(91),],$!chr(93)),%eval)
}
alias -l nxt_pcomp {
  var %v | set -n %v $hget(nxt_theme, $1)
  if ($gettok(%v, 1, 32) == !Script) { set -n %v $nxt_cl($gettok(%v, 2-, 32)) }
  elseif (* iswm %v) { %v = % $+ :echo $nxt_precompile($nxt__cl(%v)) }
  if ($istok(%v, % $+ ::pre, 32)) && (* iswm %nxt__pre) {
    while ($findtok(%v, % $+ ::pre, 1, 32)) { set -n %v $puttok(%v, %nxt__pre, $ifmatch, 32) }
  }
  while ($regsub(%v, /((\s|\A)[^$%\x28,\[\]][^\x20\x29,]*) \$\+ ([^$%\[\]]\S*(\s|\Z))/, \1\3, %v) > 0) { }
  return %v
}
; this will cache some pieces of code that are used a lot
alias -l nxt_buildfile_loadsnippets {
  var %h = nxt_snippets, %a = hadd %h, %stdline, %set = set -nu1 % $+ ::, %| = $chr(124), %pt
  if ($hget(%h)) { hfree %h }
  set -n %pt $nxt_precompile($nxt__cl($hget(nxt_theme, ParenText)))

  hmake %h 8
  %stdline = %set $+ me $!me %| %set $+ server $!server %| %set $+ port $!port %| %set $+ cid $!cid
  ; "pre" and "colors" are automatically added with "std"
  if ($hget(nxt_theme, Prefix) != $null) { %a pre %set $+ pre $nxt_precompile($nxt__cl($hget(nxt_theme, Prefix))) }
  if ($hget(nxt_theme, BaseColors) != $null) {
    var %ln = $ifmatch, %i = 1, %t = $numtok(%ln, 44), %rln
    while (%i <= %t) {
      %rln = %rln %| $+(%set, c, %i) $gettok(%ln, %i, 44)
      inc %i
    }
    ;%a colors %set $+ c1 $1 %| %set $+ c2 $2 %| %set $+ c3 $3 %| %set $+ c4 $4
    %a colors $gettok(%rln, 2-, 32)
  }
  %a std %stdline
  %a nick %set $+ nick $!nick
  %a chan %set $+ chan $!chan
  %a address %set $+ address $!address
  %a target %set $+ target $!target
  %a chanstd if ($nick($chan, $!nick).pnick != $!nick) $chr(123) %set $+ cmode $!left($ifmatch, 1) $chr(125) %| %set $+ cnick $!nick($chan, $!nick).color
  %a parentext if (* iswm % $+ ::text) $chr(123) %set $+ parentext %pt $chr(125)
}

; $nxt_buildfile_usesnippets(<line>, <window>, <insert-pos>)
; return the number of lines added
alias -l nxt_buildfile_usesnippets {
  var %i = 2, %t = $numtok($1, 32), %item, %nlines = 0, %w = $2, %p = $3
  while (%i <= %t) {
    %item = $gettok($1, %i, 32)
    if ($hget(nxt_snippets, %item)) { iline %w %p $ifmatch | inc %p | inc %nlines }
    if (%item == std) {
      if ($hget(nxt_snippets, pre)) { iline %w %p $ifmatch | inc %p | inc %nlines }
      if ($hget(nxt_snippets, colors)) { iline %w %p $ifmatch | inc %p | inc %nlines }
    }
    if (%item == chanstd) {
      if ($hget(nxt_snippets, chan)) { iline %w %p $ifmatch | inc %p | inc %nlines }
    }
    inc %i
  }
  return %nlines
}

alias -l nxt_buildfile_unsetvars {
  var %vars = $gettok($1, 2-, 32)
  if ($findtok(%vars, std, 1, 32)) { %vars = $deltok(%vars, $ifmatch, 32) me server port cid pre c? }
  if ($findtok(%vars, chanstd, 1, 32)) { %vars = $deltok(%vars, $ifmatch, 32) chan cmode cnick }
  if ($istok(%vars, parentext, 32)) { %vars = %vars text }
  return unset % $+ :echo $iif((%vars), $+(%, ::, $replace(%vars, $chr(32), $+($chr(32), %, ::))))
}

; $nxt_cl(str <text>)  - replaces base colors for script code
alias -l nxt_cl {
  var %v | set -n %v $1
  tokenize 44 $hget(nxt_theme, BaseColors)
  while ($findtok(%v, % $+ ::c1, 1, 32)) { set -n %v $puttok(%v, $1, $ifmatch, 32) }
  while ($findtok(%v, % $+ ::c2, 1, 32)) { set -n %v $puttok(%v, $2, $ifmatch, 32) }
  while ($findtok(%v, % $+ ::c3, 1, 32)) { set -n %v $puttok(%v, $3, $ifmatch, 32) }
  while ($findtok(%v, % $+ ::c4, 1, 32)) { set -n %v $puttok(%v, $4, $ifmatch, 32) }
  return %v
}
; $nxt__cl(str <text>)  - replaces base colors for simple event lines
alias -l nxt__cl {
  var %v | set -n %v $1
  tokenize 44 $hget(nxt_theme, BaseColors)
  return $replace(%v, <c1>, $1, <c2>, $2, <c3>, $3, <c4>, $4)
}


; Loading...

alias -l nxt_apply_colors {
  var %h = nxt_theme, %hx = nxt_data, %i, %colors = back action ctcp high info info2 invite join kick mode nick normal notice notify other own $&
    part quit topic wallops whois edit editbox-t list listbox-t gray title inactive treebar treebar-t
  if ($isbit(%_nxt_apply, 3)) {
    nxt_status_show 1 $iif((%_nxt_loading), Applying, Restoring) colors...
    if ($hget(%h, Colors)) {
      var %cl = $ifmatch, %i = 1, %t = $numtok(%cl, 44)
      if (%t < $numtok(%colors, 32)) {
        nxt_color treebar $gettok(%cl,$iif(%t >= 24,24,1),44)
        nxt_color treebar-t $gettok(%cl,$iif(%t >= 25,25,12),44)
      }
      if ($numtok(%colors, 32) < %t) { %t = $ifmatch }
      while (%i <= %t) { nxt_status_prog %i %t | nxt_color $gettok(%colors, %i, 32) $gettok(%cl, %i, 44) | inc %i }
      if ($numtok(%cl, 44) < 28) && ($numtok(%cl, 44) >= 22) { nxt_color inactive $gettok(%cl, 22, 44) }
    }
    else {
      var %i = 1, %t = $numtok(%colors, 32)
      while (%i <= %t) { nxt_color $gettok(%colors, %i, 32) $gettok(0 6 4 5 2 3 3 3 3 3 3 1 5 7 6 1 3 2 3 5 1 0 1 0 1 15 6 0 1 0, %i, 32) | inc %i }
    }
    nxt_status_show 1 Defining RGB values...
    if ($hget(%h, RGBColors)) {
      var %cl = $ifmatch, %i = 0, %ccl, %re | %re = /^[0-9]{1,3},[0-9]{1,3},[0-9]{1,3}$/
      while (%i <= 15) {
        nxt_status_prog %i %t | %ccl = $gettok(%cl, $calc(%i + 1), 32)
        if ($regex(%ccl, %re)) { nxt_color %i $rgb( [ %ccl ] ) } | else { nxt_color -r %i }
        inc %i
      }
      _refreshcolorgfx
    }
  }
  ; do not apply nicklist if restoring previous colors
  if (%_nxt_loading) && ($isbit(%_nxt_apply, 6)) {
    if (($ismod(userlist)) && ($isalias(colnick)))  colnick
  }

}
alias -l nxt_color tokenize 46 $+($replace($1, -, $chr(32)), ., $2) | if ($color($1) != $2) { color $1-2 }

alias -l nxt_apply_fonts {
  var %h = nxt_theme, %write = writeini $+(", $mircini, ") fonts, %nserv, %i, %j, %k, %p, %applied
  nxt_status_show 0 Applying fonts...
  if ($hget(%h, FontDefault)) {
    var %font = $ifmatch, %f = $iif((b isin $gettok(%font, 3, 44)), b), %fnt = $gettok(%font, 2, 44) $gettok(%font, 1, 44), %fini = $nxt_mkinifont(%font)
    if ($hget(nxt_data, FRep.Status)) && ($hget(nxt_data, FRep.Rep. $+ $replace($gettok(%font, 1, 44), $chr(32), \~)) != $null) {
      %fnt = $ifmatch | %font = $puttok(%font, %fnt, 1, 44)
    }
    %nserv = $scon(0)
    while (%nserv) {
      scon %nserv
      font $+(-s, %f) %fnt
      dec %nserv
    }
    if ($window(Finger Window)) { font -g $+ %f %fnt } | else { %write ffinger %fini }
    %write flinks %fini | %write flist %fini | %write fwwwlist %fini | %write fnotify %fini
    if (!$hget(%h, FontChan)) { hadd %h FontChan %font }
    if (!$hget(%h, FontQuery)) { hadd %h FontQuery %font }
  }
  if ($hget(%h, FontChan)) {
    var %font = $ifmatch
    if ($hget(nxt_data, FRep.Status)) && ($hget(nxt_data, FRep.Rep. $+ $replace($gettok(%font, 1, 44), $chr(32), \~)) != $null) {
      %font = $puttok(%font, $ifmatch, 1, 44)
    }
    %nserv = $scon(0)
    var %p
    if (b isin $gettok(%font, 3, 44)) { %p = b }
    %applied = 0
    while (%nserv) {
      scon %nserv
      %i = $ini($mircini,fonts)
      var %wintok
      while (%i) { if ($mid($ini($mircini,fonts,%i),2) ischan) { %wintok = $addtok(%wintok,$ifmatch,32) } | dec %i }
      font -d $chr(35) $gettok(%font, 2, 44) $gettok(%font, 1, 44)
      %i = $numtok(%wintok,32)
      while (%i) { font $gettok(%wintok,%i,32) $gettok(%font, 2, 44) $gettok(%font, 1, 44) | dec %i }
      dec %nserv
    }
    ;if (!%applied) { %write fchannel $nxt_mkinifont(%font) }
  }
  if ($hget(%h, FontQuery)) {
    var %font = $ifmatch
    if ($hget(nxt_data, FRep.Status)) && ($hget(nxt_data, FRep.Rep. $+ $replace($gettok(%font, 1, 44), $chr(32), \~)) != $null) {
      %font = $puttok(%font, $ifmatch, 1, 44)
    }
    %nserv = $scon(0)
    %p = -d
    if (b isin $gettok(%font, 3, 44)) { %p = %p $+ b }
    %applied = 0
    while (%nserv) {
      scon %nserv
      var %i = $query(0), %j = $chat(0), %k = $fserv(0)
      inc %applied $calc(%i + %j + %k)
      while (%i) { font %p $query(%i) $gettok(%font, 2, 44) $gettok(%font, 1, 44) | dec %i }
      while (%j) { font %p = $+ $chat(%j) $gettok(%font, 2, 44) $gettok(%font, 1, 44) | dec %j }
      while (%j) { font %p = $+ $fserv(%k) $gettok(%font, 2, 44) $gettok(%font, 1, 44) | dec %j }
      dec %nserv
    }
    if (!%applied) { %write fquery $nxt_mkinifont(%font) }
    %write fmessage $nxt_mkinifont(%font)
  }
}
alias -l nxt_mkinifont {
  tokenize 44 $1
  var %weight = $iif((b isin $3), 700, 400), %h = $2
  if (%h < 0) {
    ; my attemp to convert negative size -> height -> real size...
    var %h = $int($calc($2 * $height(A, $1, 1000) / -1000 + 0.999)), %n = 10, %diff
    while (%n) {
      %diff = $calc($height(A, $1, %h) - $height(A, $1, $2))
      if (!%diff) { break } | elseif (%diff > 0) { dec %h } | else { inc %h }
      dec %n
    }
  }
  return $+($1, $chr(44), $calc(%weight + %h), $chr(44), 1)
}

alias -l nxt_apply_bg {
  var %h = nxt_theme, %fdir = $nofile($1-), %fn, %i, %write = writeini $+(", $mircini, ") background, %applied, %c
  nxt_status_show 1 Applying background pictures...
  if ($isbit(%_nxt_apply, 2)) {
    ; channels
    nxt_status_prog 1 5
    if ($hget(%h, ImageChan)) {
      var %ln = $ifmatch, %p = -e $+ $nxt_imgpos(%ln), %fn = $+(", %fdir, $gettok(%ln, 2-, 32), "), %c = $scon(0), %applied = 0
      while (%c) {
        scon %c
        %i = $chan(0)
        if (%i) { %applied = 1 }
        while (%i) { $nxt_setbg(%p, $chan(%i), %fn) | dec %i }
        dec %c
      }
      if (!%applied) { %write wchannel $+($shortfn(%fn), $chr(44), $calc($findtok(center fill normal stretch tile photo, $gettok(%ln, 1, 32), 1, 32) - 1)) }
    }
    ; query windows
    nxt_status_prog 2 5
    if ($hget(%h, ImageQuery)) {
      var %ln = $ifmatch, %p = -e $+ $nxt_imgpos(%ln), %fn = $+(", %fdir, $gettok(%ln, 2-, 32), "), %c = $scon(0), %applied = 0
      $nxt_setbg(%p $+ g, %fn)
      while (%c) {
        scon %c
        %i = $query(0)
        if (%i) { %applied = 1 }
        while (%i) { $nxt_setbg(%p, $query(%i), %fn) | dec %i }
        dec %c
      }
      if (!%applied) { %write wquery $+($shortfn(%fn), $chr(44), $calc($findtok(center fill normal stretch tile photo, $gettok(%ln, 1, 32), 1, 32) - 1)) }
      %c = $scon(0) | %applied = 0
      while (%c) {
        scon %c
        %i = $chat(0)
        if (%i) { %applied = 1 }
        while (%i) { $nxt_setbg(%p, = $+ $chat(%i), %fn) | dec %i }
        dec %c
      }
      if (!%applied) { %write wchat $+($shortfn(%fn), $chr(44), $calc($findtok(center fill normal stretch tile photo, $gettok(%ln, 1, 32), 1, 32) - 1)) }
    }
    ; status, finger and mdi
    nxt_status_prog 3 5
    if ($hget(%h, ImageStatus)) { $nxt_setbg(-sg $+ $nxt_imgpos($ifmatch), $+(", %fdir, $gettok($ifmatch, 2-, 32), ")) }
    if ($hget(%h, ImageMirc)) { $nxt_setbg(-m $+ $nxt_imgpos($ifmatch), $+(", %fdir, $gettok($ifmatch, 2-, 32), ")) }
  }
  if ($isbit(%_nxt_apply, 10)) {
    ; toolbar, switchbar
    nxt_status_prog 4 5
    if ($hget(%h, ImageToolbar)) { $nxt_setbg(-l, $+(", %fdir, $gettok($ifmatch, 2-, 32), ")) }
    if ($hget(%h, ImageSwitchbar)) { $nxt_setbg(-h, $+(", %fdir, $gettok($ifmatch, 2-, 32), ")) }
  }
  if ($isbit(%_nxt_apply, 9)) {
    nxt_status_prog 5 5
    if ($hget(%h, ImageButtons)) { $nxt_setbg(-u, $+(", %fdir, $ifmatch, ")) }
  }
  else { nxt_status_prog 5 5 }
}
; //$nxt_setbg(<switches>, <window>, <filename>)
; //$nxt_setbg(<switches>, <filename>)
alias -l nxt_setbg {
  ; /background is really buggy, this is my "hack"
  if ($0 == 3) && ($isfile($3)) {
    background $remove($1, e) $2-3
    background $remove($1, e) $2-3
    background $1-3
    remini $+(", $mircini, ") background $2
  }
  elseif ($0 == 2) && ($isfile($2)) { background $1- }
}
alias -l nxt_imgpos return $mid(cfnrtp, $findtok(center fill normal stretch tile photo, $gettok($1, 1, 32), 1, 32), 1)

alias nxt_status_open {
  var %w = @nxt_Status, %cw = $calc($dbuw * 160), %ch = $calc($dbuh * 24)
  window -hndkpfCBi +fL %w -1 -1 %cw %ch
  drawrect -rf %w $rgb(face) 0  0 0 %cw %ch
  window -o %w
  window -hpBi +d @nxt_Cover 0 0 $window(-3).w $window(-3).h
  drawrect -nrf @nxt_Cover $rgb(128, 128, 128) 0  0 0 $window(-3).w $window(-3).h
  window -a @nxt_Cover
}
alias nxt_status_close close -@ @nxt_Status @nxt_Cover
alias nxt_status_show {
  var %w = @nxt_Status, %cw = $window(@nxt_Status).dw
  drawrect -nrf %w $rgb(face) 0  0 0 %cw $window(@nxt_Status).dh
  drawtext -nro %w $rgb(text)  Tahoma -8  $calc((%cw - $width($2-, Tahoma, -8, 1, 0)) / 2) $calc(4 * $dbuh)  $2-
  if ($1) {
    var %rx = $calc(3 * $dbuw), %ry = $calc(15 * $dbuh), %rw = $calc(154 * $dbuw), %rh = $calc(5 * $dbuh), %xywh = %rx %ry %rw %rh
    drawrect -nrf %w $rgb(hilight) 0 %xywh
    drawrect -nr %w $rgb(shadow) 0 %xywh
    drawline -nr %w $rgb(hilight) 0  $calc(%rx + %rw - 1) $calc(%ry + 1)  $calc(%rx + %rw - 1) $calc(%ry + %rh - 1)  %rx $calc(%ry + %rh - 1)
    ;drawrect -nr %w $rgb(frame) 0 %xywh
  }
  drawdot %w
}
alias nxt_status_prog {
  var %w = @nxt_Status
  drawrect -rf %w $rgb(0, 0, 128) 0 $calc(3 * $dbuw + 1) $calc(15 * $dbuh + 1) $calc((154 * $dbuw - 2) * $1 / $2) $calc(5 * $dbuh)
}

; ac/hc/sc for preview
;past for preview
alias -l pst {
  if (!$mopt(2,30)) return $1
  var %a = $+(%::cmode,%::nick)
  if ($nvar(colorprefix) == on) {
    if ($nvar(colorprefix.mode) == on) {
      if (@ isin %a) set %a $replace(%a,@, $+ $base($nxt_set(CLineOP),10,10,2) $+ @)
      if (% isin %a) set %a $replace(%a,%, $+ $base($nxt_set(CLineHOP),10,10,2) $+ % $+ )
      if (+ isin %a) set %a $replace(%a,+, $+ $base($nxt_set(CLineVoice),10,10,2) $+ +)
    }
    else {
      if (@ isin %a) set %a $replace(%a,@,$sc(@))
      if (% isin %a) set %a $replace(%a,%,$sc(%))
      if (+ isin %a) set %a $replace(%a,+,$sc(+))
    }
  }
  return %a
}
alias -l pst2 {
  if (!$mopt(2,30)) return
  else var %a = $left($pst($1,$2),$calc(0 - $len($1)))
  return %a
}

; /nxt_load_preview <dialog> <large|small> [nro_of_scheme] <$shortfn(themefile)>
alias nxt_load_preview {
  var %sch, %thm, %d = $1

  if ($0 >= 4) { %sch = $3 | %thm = $longfn($4-) }
  elseif ($0 >= 3) { %thm = $longfn($3-) }
  else { nxt_error $active syntax error on nxt_load_preview! }
  var %pvsize = $2


  var %pfn = $qt($nxt_cachedir($+($iif($2 == large,big-),$nopath(%thm), $iif((%sch), -S $+ %sch), .bmp))), %w = @nxt_Preview, %lw = @nxt_Preview-, %cw = 224, %ch = 158, %istmp = 0
  if (%pvsize == small) {
    if (%d == ircn.nxt) {
      %cw = $calc(112 * $dbuw)
      %ch = $calc(88 * $dbuw)
    }
    elseif (%d == ircn.nxt.modern) {
      %cw = 224
      %ch = 210
    }
  }
  elseif (%pvsize == large) { 
    %cw = $calc(200 * $dbuw)
    %ch = $calc(180 * $dbuh) 
  }

  if (!$isdir($nxt_cachedir)) { mkdir $nxt_cachedir }
  if (!$isbit($hget(nxt_data, Cache), 1)) { %istmp = 1 }
  if ($window(%lw)) window -c %lw
  if ($window(%w)) window -c %w

  window -hkliB %lw
  ; on preview, we must load the scheme first, not after
  if (%sch) && ($read(%thm, w, $+([Scheme, %sch, ]))) { loadbuf -tScheme $+ %sch %lw $+(", %thm, ") }
  loadbuf -tmts %lw $qt(%thm)
  if ($fline(%lw, ?* !Script ?*, 1)) && ($nxt_set(Script)) {
    var %scriptf = $+(", $nofile(%thm), $ifmatch, ")
    if ($isfile(%scriptf)) && (!$script($longfn(%scriptf))) { .reload -rs %scriptf }
    else { %scriptf = }
  }
  var %cl = $nxt_set(Colors), %rgb = $nxt_set(RGBColors), %defcl = 0,6,4,5,2,3,3,3,3,3,3,1,5,7,6,1,3,2,3,5,1,0,1,0,1,15,6,0
  if ($remove(%cl, $chr(44)) !isnum) { %cl = %defcl }
  else { %cl = $gettok(%cl, 1-, 44) $+ $gettok(%defcl, $calc($numtok(%cl, 44) + 1) $+ -, 44) }
  if ($numtok(%rgb, 32) != 16) {
    %rgb = 255,255,255 0,0,0 0,0,128 0,144,0 255,0,0 128,0,0 160,0,160 255,128,0 255,255,0 0,255,0 0,144,144 0,255,255 0,0,255 255,0,255 $&
      128,128,128 208,208,208
  }
  nxt_pvd Init %cw %ch

  nxt_pvd SetBg $gettok(%cl,1,44)

  if ($nxt_set(FontChan)) || ($nxt_set(FontDefault)) {
    var %f, %fsize = $gettok($ifmatch, 2, 44), %fb = $gettok($ifmatch, 3, 44)
    set -n %f $gettok($ifmatch, 1, 44)
    if ("*" iswm %f) { set -n %f $mid(%f, 2, -1) }
    if ($hget(nxt_data, FRep.Status)) && ($hget(nxt_data, FRep.Rep. $+ $replace(%f, $chr(32), \~)) != $null) { set -n %f $ifmatch }
    if (%fsize !isnum) { %fsize = -10 }
    ;if (%fb != b) { var %fb }
    if (%fb != b) { var %fb n }
    nxt_pvd SetFont %fb %fsize %f
  }
  else { nxt_pvd SetFont $iif(($window(Status Window).fontbold),b,n) $window(Status Window).fontsize $window(Status Window).font }
  nxt_preview_text $2 %lw %cl %rgb

  nxt_pvd SetColors %rgb
  nxt_pvd DrawBorder
  ; remove the extension (the DLL will add one on return value)
  %pfn = $deltok($gettok(%pfn, 1, 34), -1, 46)

  ;if ($isfile($+(%pfn,.png))) { did -g %d 2 $gfxdir(noprev.bmp) | .remove $+(%pfn,.png) }
  ;if ($isfile($+(%pfn,.bmp))) { did -g %d 2 $gfxdir(noprev.bmp) | .remove $+(%pfn,.bmp) }
  ;if ($isfile($+(%pfn,.png))) { .remove $+(%pfn,.png) }
  if ($isfile($+(%pfn,.bmp))) { 
    if (%d == ircn.nxt.modern) { xdid -i %d 2 + $noqt($gfxdir(noprev.bmp)) | .remove $+(%pfn,.bmp) }
    if (%d == ircn.nxt) { .remove $+(%pfn,.bmp) }
  }

  var %pfn = $+(%pfn,.bmp)
  nxt_pvd Save $qt(%pfn)

  ;if ($result) {
  ;  var %tfn = $result, %other = $puttok(%tfn, $remtok(bmp png jpg, $gettok(%tfn, -1, 46), 1, 32), -1, 46)
  ;  %pfn = $+(", %tfn, ")
  ;  if ($isfile(%other)) { .remove $+(", %other, ") }
  ;}
  ;else { var %pfn = $+(%pfn,.jpg) }
  nxt_pvd Cleanup
  close -@ %lw
  if ($script($longfn(%scriptf))) { .unload -rsn %scriptf }

  ;if ($pic(%pfn).size) { did -h %d 2,41,42 | did -g %d 2 %pfn | did -v %d 2 }
  if ($pic(%pfn).size) { 
    if (%d == ircn.nxt.modern) xdid -i %d 2 + $noqt(%pfn) 
    elseif (%d == ircn.nxt) { did -h %d 2,41,42 | did -g %d 2 %pfn | did -v %d 2 }
    elseif (%d == nxt_preview) {
      if ($pic(%pfn).size) {
        %nxt__pfn = %pfn
        $dialog(nxt_preview, nxt_preview, -4)
        unset %nxt__pfn
      }
    }
  }



  else { beep }
  unset %_nxt_*
}



alias nxt_rgb return $rgb( [ $gettok($2, $calc($gettok($1, $3, 44) + 1), 32) ] )
; /nxt_load_bigpreview <dialog> <nro_of_scheme> <$shortfn(themefile)>
;nxt_load_bigpreview ircn.nxt $iif(%schm,$ifmatch) $shortfn(%fn)
alias nxt_load_bigpreview {
  nxt_load_preview $1 large $2-
}

; /nxt_preview_bg str <pwnd>, str <filename>
alias nxt_preview_bg {
  var %set = $nxt_set(ImageChan), %style = $gettok(%set, 1, 32), %fn = $+(", $nofile($2-), $gettok(%set, 2-, 32), "), $&
    %dw = $calc($window($1).dw - 4), %dh = $calc($window($1).dh - 4), %px = 2, %py = 2, %pw, %ph
  if (!%set) || (!$istok(center fill normal stretch tile photo, %style, 32)) || (!$pic(%fn).width) { return $false }
  %pw = $pic(%fn).width | %ph = $pic(%fn).height
  if (%style == center) { %px = $calc(2 + (%dw - %pw) / 2) | %py = $calc(2 + (%dh - %ph) / 2) }
  elseif ($istok(fill tile, %style, 32)) { %pw = %dw | %ph = %dh }
  elseif (%style == stretch) {
    if (%pw > %dw) { %ph = $calc(%ph * %dw / %pw) | %pw = %dw }
    if (%ph > %dh) { %pw = $calc(%pw * %dh / %ph) | %ph = %dh }
    %px = $calc(2 + (%dw - %pw) / 2) | %py = $calc(2 + (%dh - %ph) / 2)
  }
  elseif (%style == photo) {
    var %hdw = $calc(%dw * 0.5), %hdh = $calc(%dh * 0.5)
    if (%pw > %hdw) { %ph = $calc(%ph * %hdw / %pw) | %pw = %hdw }
    if (%ph > %hdh) { %pw = $calc(%pw * %hdh / %ph) | %ph = %hdh }
    %px = $calc(2 + %dw - %pw)
  }
  drawpic -ns $+ $iif((%style == tile), l) $1 $int(%px) $int(%py) $int(%pw) $int(%ph) %fn
  unset %_nxt_*
  return $true
}
alias nxt_preview_text {

  %_nxt_time = $calc($ctime - $r(0, 86400))
  var %pvsize = $1
  var %bcl = $nxt_set(BaseColors)
  %::c1 = $gettok(%bcl, 1, 44) | %::c2 = $gettok(%bcl, 2, 44) | %::c3 = $gettok(%bcl, 3, 44) | %::c4 = $gettok(%bcl, 4, 44)
  if ($nxt_set(MTSVersion) = 1.1) && ($nxt_set(Timestamp) == on) && ($nxt_set(TimestampFormat)) { set -n %_nxt_timestamp $ifmatch }
  elseif ($calc($nxt_set(MTSVersion)) = 1) && ($nxt_set(Timestamp)) { if ($ifmatch != off) { set -n %_nxt_timestamp $ifmatch } }
  if (*<c*>* iswm %_nxt_timestamp) { set -n %_nxt_timestamp $replace(%_nxt_timestamp, <c1>, %::c1, <c2>, %::c2, <c3>, %::c3, <c4>, %::c4) }
  %::me = $me | if (!%::me) || ($istok(Dude GuY pal, %::me, 32)) { %::me = Myself }
  %::server = irc.nxt.ircn.org | %::port = 6667
  .timernxt_nxt 1 0 % $+ ::pre = $nxt_precompile($nxt_set(Prefix)) | .timernxt_nxt -e

  %::chan = #Preview | %::target = #Preview
  %::cid = $iifelse($scon(1).id,1)
  %:echo = nxt_drawpvtxt 

  var %addr_me, %addr_pal, %addr_guy, %addr_dude, %randip = $($+(@, $r(1, 255), ., $r(0, 255), ., $r(0, 255), ., $r(0, 255)), 0)
  %addr_me = preview $+ $(%randip, 2)
  %addr_guy = guy $+ $(%randip, 2)
  %addr_dude = dude $+ $(%randip, 2)
  %addr_pal = ircn $+ $(%randip, 2)  
  %_nxt_color = $gettok($3,8,44)

  %::nick = %::me | %::address = %addr_me
  nxt_show JoinSelf

  %_nxt_color = $gettok($3,12,44)
  inc %_nxt_time $r(1, 5)
  %::nick = Dude | %::cmode = @
  %::text = $gettok(hi welcome wb, $r(1, 3), 32) %::me :)
  nxt_show TextChan

  %_nxt_color = $gettok($3,16,44)
  inc %_nxt_time $r(5, 10)
  %::nick = %::me | %::cmode =
  %::text = $gettok(hi howdy hello, $r(1, 3), 32) Dude
  nxt_show TextChanSelf

  %_nxt_color = $gettok($3,8,44)
  inc %_nxt_time $r(30, 50)
  %::nick = pal
  %::address = $+(ircn@, $r(1, 255), ., $r(0, 255), ., $r(0, 255), ., $r(0, 255))
  nxt_show Join


  %_nxt_color = $gettok($3,21,44)
  inc %_nxt_time $r(10, 20)
  %::realname = Your pal | %::chan = #Preview #ircN @#Pals
  %::wserver = %::server | %::serverinfo = Preview server | %::text = | %::isregd = is not | %::isoper = is not
  %::idletime = $r(1, 30) | %::signontime = $asctime($calc(%_nxt_time - $r(360, 7200)))
  if ($nxt_set(Whois)) { 
    nxt_show Whois 
    if ($nxt_set(raw.311)) nxt_show Raw.311
    if ($nxt_set(raw.319)) nxt_show Raw.319
    if ($nxt_set(raw.312)) nxt_show Raw.312
    if ($nxt_set(raw.317)) nxt_show Raw.317
    if ($nxt_set(raw.318)) nxt_show Raw.318
  }
  else {
    if ($nxt_set(raw.311)) nxt_showr 311
    if ($nxt_set(raw.319)) nxt_showr 319
    if ($nxt_set(raw.312)) nxt_showr 312
    if ($nxt_set(raw.317)) nxt_showr 317
    if ($nxt_set(raw.318)) nxt_showr 318
  }

  %_nxt_color = $gettok($3,12,44)
  inc %_nxt_time $r(10, 20)
  %::text = what's up guys?
  %::chan = #Preview | %::cmode = @
  nxt_show TextChan

  inc %_nxt_time $r(3, 10)
  %::nick = GuY | %::cmode = + | %::address =
  %::text = the sky, pal
  nxt_show TextChan

  %_nxt_color = $gettok($3,9,44)
  inc %_nxt_time $r(3, 10)
  %::nick = Dude | %::cmode = @ | %::knick = GuY
  %::text = sample kick!
  if ($nxt_set(ParenText)) { set -n %::parentext $ifmatch } | else { %::parentext = (<text>) }
  set -n %::parentext $($nxt_precompile(%::parentext), 2)

  nxt_show Kick | %::knick = | %::parentext =

  %_nxt_color = $gettok($3,2,44)
  inc %_nxt_time $r(40, 180)
  %::text = is away (brb)
  nxt_show ActionChan

  if (%pvsize == large) {
    %_nxt_color = $gettok($3,16,44)
    inc %_nxt_time $r(5, 10)
    %::nick = %::me
    %::address = %addr_me
    %::text = cya later Dude
    nxt_show TextChanSelf

    %_nxt_color = $gettok($3,13,44)
    inc %_nxt_time $r(0, 2)
    %::nick = Dude | %::cmode =
    %::address = %addr_dude
    %::target = %::me
    %::text = this is a sample notice to tell you I'm away
    nxt_show Notice

    %_nxt_color = $gettok($3,2,44)
    inc %_nxt_time $r(5, 10)
    %::nick = %::me | %::cmode = @
    %::address = %addr_me
    %::text = hates automatic notices
    nxt_show ActionChanSelf

    %_nxt_color = $gettok($3,19,44)
    inc %_nxt_time $r(10, 30)
    %::text = I hate automatic notices
    nxt_show Topic

    %_nxt_color = $gettok($3,7,44)
    %::nick = pal | %::cmode =
    %::address = %addr_pal
    %::chan = #imaspammah
    nxt_show Invite | %::chan = #Preview

    %_nxt_color = $gettok($3,18,44)
    %::text = Killed (Banned from this network)
    if ($nxt_set(ParenText)) { set -n %::parentext $ifmatch } | else { %::parentext = (<text>) }
    set -n %::parentext $($nxt_precompile(%::parentext), 2)
    nxt_show Quit | %::parentext =

    %_nxt_color = $gettok($3,8,44)
    inc %_nxt_time $r(1, 50)
    %::nick = GuY
    %::address = %addr_guy
    %::text =
    nxt_show Join

    %_nxt_color = $gettok($3,3,44)
    inc %_nxt_time $r(3, 10)
    %::nick = %::me
    %::address = %addr_me
    %::target = GuY
    %::ctcp = PING
    nxt_show CTCPSelf | %::target = %::me

    %_nxt_color = $gettok($3,3,44)
    inc %_nxt_time 2
    %::nick = GuY
    %::address = %addr_guy
    %::ctcp = PING
    %::text = $duration(2)
    nxt_show CTCPReply
  }


  :end
  unset %:echo %::*
}
;;new preview code
alias nxt_fake_rgb { return 1,1,1 2,2,2 3,3,3 4,4,4 5,5,5 6,6,6 7,7,7 8,8,8 9,9,9 10,10,10 11,11,11 12,12,12 13,13,13 14,14,14 15,15,15 16,16,16 }
alias nxt_pvd_h_pos { return $calc($height(ABCDEFGHIJKLMNOPQRSTUWXYZ,$qt(%nxt.drawpreview.fontname),%nxt.drawpreview.fontsize) * %nxt.drawpreview.i) }
alias nxt_pvd {
  tokenize 32 $1-
  var %cmd = $1, %val = $2-
  var %w = @NXT_DrawPreview
  if (%cmd == Init) {
    unset %nxt.drawpreview.*
    if ($window(%w)) window -c %w
    window -hfp +d %w -1 -1 $gettok(%val,1,32) $gettok(%val,2,32)
    set -n %nxt.drawpreview.width $gettok(%val,1,32)
    set -n %nxt.drawpreview.heigth $gettok(%val,2,32)
    set -n %nxt.drawpreview.i 0
  }
  if (%cmd == SetBg) {
    ;drawrect -nf %w $hget(theme.preview,background) 1 0 0 %nxt.drawpreview.width %nxt.drawpreview.heigth
    drawrect -nf %w $gettok(%val,1,32) 1 0 0 %nxt.drawpreview.width %nxt.drawpreview.heigth
    set -n %nxt.drawpreview.bg $gettok(%val,1,32)
  }
  if (%cmd == SetFont) {
    set -n %nxt.drawpreview.fontname $qt($gettok(%val,3-,32))
    set -n %nxt.drawpreview.fontsize $gettok(%val,2,32)
    set -n %nxt.drawpreview.fontbold $iif(b isin $gettok(%val,1,32),b)
  }
  if (%cmd == SetColors) {
    set -n %nxt.drawpreview.rgb %val
    ; this replacement idea is from MTS Previewer 1.3 by quickman
    var %i = 0
    while (%i <= 15) { 
      drawreplace -nr %w $color(%i).rgb $rgb( [ $+ [ $gettok($nxt_fake_rgb,$calc(%i + 1),32) ] $+ ] )
      inc %i
    }
    var %i = 1
    while (%i <= 16) { 
      var %f = $rgb( [ $+ [ $gettok($nxt_fake_rgb,%i,32) ] $+ ] )
      var %r = $rgb( [ $+ [ $gettok(%nxt.drawpreview.rgb,%i,32)) ] $+ ] )
      drawreplace -nr %w %f %r
      inc %i
    }
  }
  if (%cmd == DrawText) {
    drawtext -bnp %w $remove($gettok(%val,1,32),,¬) %nxt.drawpreview.bg %nxt.drawpreview.fontname %nxt.drawpreview.fontsize 2 $nxt_pvd_h_pos $gettok(%val,2-,32)
    inc %nxt.drawpreview.i
  }
  if (%cmd == DrawBorder) {
    if ($gettok(%nxt.drawpreview.rgb,$calc(%nxt.drawpreview.bg + 1),32) == 0,0,0) drawrect -nr %w $rgb(255,255,255) 1 0 0 %nxt.drawpreview.width %nxt.drawpreview.heigth
    else drawrect -nr %w $rgb(0,0,0) 1 0 0 %nxt.drawpreview.width %nxt.drawpreview.heigth
  }
  if (%cmd == Save) {
    drawdot %w
    set %nxt.drawpreview.savefile %val
    drawsave -b16 %w %val
  }
  if (%cmd == Cleanup) {
    window -c %w
    unset %nxt.drawpreview.*
  }
}
alias nxt_drawpvtxt nxt_pvd DrawText %_nxt_color %::timestamp $1-
alias nxt_set {
  var %f = $fline(@nxt_Preview-, $1 *, 1)
  if ($fline(@nxt_Preview-, $1, 1)) { if ($ifmatch < %f) { %f = $ifmatch } }
  return $gettok($line(@nxt_Preview-, %f), 2-, 32)
}
alias -l nxt_show {
  if (* iswm $nxt_set($1)) {
    var %ln | set -n %ln $nxt_set($1) | if (%_nxt_timestamp) { %::timestamp = $asctime(%_nxt_time, %_nxt_timestamp) }
    if ($gettok(%ln, 1, 32) == !Script) { set -n %ln $gettok(%ln,2-,32) }
    else { set -n %ln % $+ :echo $nxt_precompile(%ln) }
    if (%ln) { .timernxt_theme 1 0 %ln | .timernxt_theme -e }
    return 1
  }
}
alias -l nxt_showr {
  nxt_show Raw. $+ $1 
  if (!$result) { nxt_show Raw.Other }
}
dialog -l nxt_preview {
  title "Theme preview"
  size -1 -1 204 197
  option dbu
  icon $mircexe, 16
  icon 1, 2 2 200 180, $mircexe, 16, noborder
  button "Close", 2902, 162 185 40 10, cancel
}
on *:DIALOG:nxt_preview:init:0:{
  if ($pic($qt(%nxt__pfn)).size) { did -g $dname 1 $qt(%nxt__pfn) }
  else { beep | dialog -x $dname }
}
on *:DIALOG:nxt_preview:sclick:0,1:dialog -c $dname

; about

dialog kte_about {
  title "About"
  size -1 -1 100 47
  option dbu
  icon $mircexe, 16
  check "3", 1, 0 0 0 0
  icon 2, 3 3 16 16, $mircexe, 0, noborder
  text "Kamek's Theme Engine", 3, 27 3 56 7
  text "", 4, 27 12 70 7
  link "Kamek's MTS page", 5, 27 21 47 7
  box "", 2900, -1 28 102 20
  button "OK", 2902, 58 35 40 10, default ok cancel
}
on *:DIALOG:kte_about:init:0:did -o $dname 4 1 Version $kte_ver for MTS $kte_mtsver
on *:DIALOG:kte_about:rclick:0:.timerkte_about -om 12 100 kte_about_ck
on *:DIALOG:kte_about:sclick:1:var %v = $calc($did($dname, 1) - 1) | did -o $dname 1 1 %v | if (!%v) { dialog -t $dname Cookie! }
on *:DIALOG:kte_about:sclick,dclick:2:did -g $dname 2 $xor($gettok($did($dname, 2), 1, 32), 2) $+(", $mircexe, ")
on *:DIALOG:kte_about:sclick:5:.run http://www3.brinkster.com/ircweb/mts/

alias -l kte_about_ck {
  var %d = kte_about
  if (!$dialog(%d)) { .timerkte_about off | return }
  if (. isin $did(%d, 4)) { did -o %d 4 1 $replace($did(%d, 4), ., ·) }
  elseif (· isin $did(%d, 4)) { did -o %d 4 1 $replace($did(%d, 4), ·, -) }
  elseif (- isin $did(%d, 4)) { did -o %d 4 1 $replace($did(%d, 4), -, $chr(44)) }
  elseif (, isin $did(%d, 4)) { did -o %d 4 1 $replace($did(%d, 4), $chr(44), .) }
}
; event hiding
raw 001:*:nxt_hidewcome
raw 002:*:nxt_hidewcome
raw 003:*:nxt_hidewcome
raw 004:*:nxt_hidewcome
raw 005:*:if (!$nxt_v(connected)) { nxt_hidewcome }
alias -l nxt_hidewcome if (!$nvar(onconnect.welcome)) { haltdef }

raw 250:*:nxt_hidelusers
raw 251:*:nxt_hidelusers
raw 252:*:nxt_hidelusers
raw 253:*:nxt_hidelusers
raw 254:*:nxt_hidelusers
raw 255:*:nxt_hidelusers
raw 256:*:nxt_hidelusers
raw 265:*:nxt_hidelusers
raw 266:*:nxt_hidelusers
alias -l nxt_hidelusers if (!$nxt_v(connected)) && (!$nvar(onconnect.lusers)) { haltdef }

raw 372:*:nxt_hidemotd
raw 375:*:nxt_hidemotd
raw 376:*:nxt_hidemotd
raw 377:*:nxt_hidemotd
raw 378:*:nxt_hidemotd
raw 422:*:nxt_hidemotd
alias -l nxt_hidemotd if (!$nxt_v(connected)) && ($mopt(1,11) == 1) { haltdef }

alias -l nxt_onjoin if ($nick == $me) { nxt_v joining $nxt_v(joining) $chan }
alias -l nxt_left var %jn = $nxt_v(joining) | if ($istok(%jn, $1, 32)) { nxt_v joining $remtok(%jn, $1, 1, 32) }

raw 353:*:nxt_hidenames $3
raw 366:*:nxt_hidenames $2
alias -l nxt_hidenames {
  if ((!$istok($ncid(nameschan), $1, 32)) && (!$nvar(join.names))) { haltdef }
  if ((!$istok($ncid(nameschan), $1, 32)) && ($numeric == 366)) {
    if (($chan($1).ial) || ($1 == $modvar(away,idlechan))) ncid -r $+(joinsync.,$1)
    if ($1 == $modvar(away,idlechan)) return

    if (!$chan($1).ial) {
      if ((!$istok(never op,$nvar(ialupd),32)) && (!$istok($nget(ialupd.ignore),$1,44)))  {
        if ($nick($1,0) < $iifelse($nvar(maxial),200)) {
          ncid joinwho $addtok($ncid(joinwho),$1,44)
          ncid -r $tab(chan,$1,*)
          if ($nvar(queuedwho) == on) {
            if (!$hget($cidqueue(who))) initwhoqueue
            queuewho $1
          }
          else .quote who $1
        }
        else {
          var %updateialkey = $_fkey.bind(iecho Updating IAL $| .quote who $1,15,F12)
          iecho -w $1 IAL has been disabled for this channel. Press $hc(%updateialkey) to enable IAL within the next 15 seconds
          ncid -r joinsync. $+ $1
        }    
      }
      else ncid -r joinsync. $+ $1
    }
    else {
      ; get ops
      if ($ismod(userlist)) {
        if (($nvar(userlist.botgetops) == on) && ($me ison $1) && ($me !isop $1))  dogetops $1
        ncid getops $remtok($ncid(getops),$1,1,44)
      }
    }
    if (!$chan($1).ibl) {
      if ($nvar(iblupd) == join) {
        ncid updibl $addtok($ncid(updibl),$1,44)
        .quote mode $1 b
      }
    }
    if (($1 != $modvar(away,idlechan)) && ($me isop $1))  {
      var %settopiconjoin = $iif($nvar(autosettopic) == on,1,$iif($changet(global,autosettopic) == on,1,$iif($changet($1,autosettopic) == on,1,0)))
      var %onjointopic = $iif($changet($1,autosettopic) == on,$changet($1,$tab(autosettopic,topic)), $iif($changet(global,autosettopic) == on,$changet(global,$tab(autosettopic,topic)) ,$iif($nvar(autosettopic) == on,$nvar($tab(autosettopic,topic)))))


      var %setmodeonjoin = $iif($nvar(setmodeonjoin) == on,1,$iif($changet(global,setmodeonjoin) == on,1,$iif($changet($1,setmodeonjoin) == on,1,0)))
      var %onjoinmode = $iif($changet($1,setmodeonjoin) == on,$changet($1,onjoinmode),$iif($changet(global,setmodeonjoin) == on,$changet(global,onjoinmode),$iif($nvar(setmodeonjoin) == on,$nvar(onjoinmode))))


      if (%setmodeonjoin) {
        if (%onjoinmode)  putserv MODE $1 : $+ %onjoinmode
      }
      if (%settopiconjoin) {
        if (%onjointopic) putserv TOPIC $1 : $+ %onjointopic
      }
    }
  }
  elseif ($numeric == 366) {
    ncid nameschan $remtok($ncid(nameschan),$1,1,44)
    ncid -r nameschan. [ $+ [ $1 ] ]
  }
}
raw 331:*:nxt_hidejinfo $numeric $2
raw 332:*:nxt_hidejinfo $numeric $2
raw 333:*:nxt_hidejinfo $numeric $2
raw 324:*:nxt_hidejinfo $numeric $2
raw 329:*:nxt_raw329 $2
alias -l nxt_raw329 {
  nxt_hidejinfo $numeric $1
  var %jn = $nxt_v(joining)
  if ($findtok(%jn, $1, 1, 32)) { nxt_v joining $deltok(%jn, $ifmatch, 32) }
}
alias -l nxt_hidejinfo {
  var %x
  if (($1 == 331) || ($1 == 332) || ($1 == 333)) %x = join.topic
  if ($1 == 324) %x = join.totals
  if ($1 == 329) %x = join.created
  if (($istok($nxt_v(joining), $2, 32)) && (!$nvar(%x))) { haltdef }
}

alias -l nxt_v {
  var %n = $+(c, $cid, :, $1)
  if ($isid) { return $hget(nxt_data, %n) }
  if ($0 = 1) { hdel nxt_data %n }
  else { hadd nxt_data %n $2- }
}

; default /theme.text
#nxt_DefTheme off
alias theme.text {
  var %ln | set -n %ln $hget(nxt_theme, $1)
  if (!%ln) return
  if (!$var(%:echo)) || (* !iswm %ln) { return $false }
  set -nu1 %::me $me | set -u1 %::server $server | set -u1 %::port $port
  set -u1 %::pre * | set -nu1 %::timestamp $timestamp
  if ($gettok(%ln, 1, 32) == !Script) { set -n %ln $deltok(%ln, 1, 32) }
  else { set -n %ln % $+ :echo $nxt_precompile(%ln) }
  if ($istok(%ln, |, 32)) { .timernxt_theme 1 0 %ln | .timernxt_theme -e }
  else { $eval(%ln, 2) }
  unset %::me %::server %::port %::pre %::timestamp
  return $true
}
alias nxt_void
#nxt_DefTheme end

; ################################################################
; ####################### IRCN SCRIPT FILE #######################
; ########## END OF FILE. DO NOT REMOVE OR MODIFY BELOW ##########
; ################################################################
