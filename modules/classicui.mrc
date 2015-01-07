;%%%%%%%%%%%%%%%%%%%%%%%%
;script ircN Classic UI
;author ircN Development Team
;url http://www.ircN.org
;%%%%%%%%%%%%%%%%%%%%%%%%
menu menubar {
  &Setup
  .&General:gensettings
  .&Display:displaysettings
  .&Auto-Connect: autoconnect
  .&Network:netsettings global
  .&Authentication:netauth
  .&Channel Settings:chansettings
  .&Channel Display:chandisplay
  .&Appearance:ifacesettings
  .&Titlebar:dlg ircn.titlebar
  .&Hide Events:hideevents
  .&Nick Complete:nickcomp
  .&Transfer:transfersettings
  .&Logging:logsettings
  .&Fkeys:fkeysettings
  .&Ctcp Replies:editctcps
  .&Edit Quits:editquits
  .&Edit Kicks:editkicks
  .$iif($ismod(userlist),&Userlist):userlist
  .$iif($ismod(userlist),&Banlist):banlist

  &Customize
  .Change my text style... { chandisplay global | .timer 1 0 did -c ircn.chandisplay 42 }
}

; fix this!!!
alias infobox.dialog {
  ; <name>, <title>, [timeout], <text>

  if (!$0) return

  if ($0 < 3) return

  var %title, %time, %text

  if ($2 !isnum) set %title $2
  else { echo -a * ERROR: in $!infobox no title specified | return  }

  if ($3 isnum) {
    set %time $3
    set %text $4-
  }
  else { 
    if ($3-) {
      set %text $3-
    }
    set %time 0
  }

  if (!%text) return

  set %infobox. [ $+ [ $1 ]  $+ ] .title %title
  set %infobox. [ $+ [ $1 ]  $+ ] .timeout %time
  set %infobox. [ $+ [ $1 ]  $+ ] .text %text

  if ((%time isnum) && (%time > 1)) .timerinfobox. $+ $1 -o $calc(%time + 1) 1 if ($ $+ isalias(infobox.timecount)) infobox.timecount $1

  dialog -m infobox. $+ $1 ircninfobox

}

on *:dialog:infobox.*:init:0:{
  var %title, %text, %time, %name


  set %name $gettok($dname,2-,46)


  set %text %infobox. [ $+ [ %name ]  $+ ] .text
  set %title %infobox. [ $+ [ %name ]  $+ ] .title
  set %time %infobox. [ $+ [ %name ]  $+ ] .timeout

  if (!%time) {
    did -r $dname 4
  }
  else did -ra $dname 4 Time: $rsc($duration(%time))
  did -ra $dname 1 %text
  did -ra $dname 3 %title

}
alias infobox.timecount {

  if (!$dialog(infobox. $+ $1)) { 
    if ($1) {
      unset %infobox. [ $+ [ $1 ]  $+ ] .*
      .timerinfobox. $+ $1 off
    }
    return
  }

  if (!$dialog(infobox. $+ $1)) return

  if (%infobox. [ $+ [ $1 ] $+ ] .timeout <= 0) { 
    .timer 1 0 dialog -x infobox. $+ $1 
    unset %infobox. [ $+ [ $1 ]  $+ ] .*
    .timerinfobox. $+ $1 off
    return 
  }

  dec %infobox. [ $+ [ $1 ] $+ ] .timeout
  did -ra infobox. $+ $1 4 Time: $rsc($duration( %infobox. [ $+ [ $1 ]  $+ ] .timeout ))

}
on *:dialog:ircninfobox:sclick:2:{
  ; iecho a $dialog($dname).modal

}
on *:dialog:infobox.*:close:0:{
  ; iecho a $dialog($dname).modal
  var %name =  $gettok($dname,2-,46)

  unset %infobox. [ $+ [ %name ]  $+ ] .*
  .timer $+ $dname off
}


dialog ircninfobox {
  title "ircN Information Box!"
  size -1 -1 198 73
  option dbu
  edit "", 1, 4 16 144 50, read autovs multi vsbar 
  button "OK", 2, 151 52 44 14, ok default
  text "", 3, 5 4 192 11
  text "Remaining: 99s", 4, 153 27 41 12


}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; NXT DiALOG SECTiON
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias nxt dlg -r ircn.nxt
dialog ircn.nxt {
  title "ircN eXtended MTS Theme Engine [/themes]"
  size -1 -1 185 168
  option dbu
  icon $gfxdir(icons\ircn.ico), 0
  tab "Info", 14, 1 1 182 164
  ;edit "", 17, 66 112 112 47, tab 14 multi vsbar
  edit "", 17, 66 120 112 42, tab 14 multi vsbar
  list 1, 2 17 60 131, tab 14 size hsbar vsbar

  box "", 41, 66 27 112 91,  tab 14
  text "Double-click for preview", 42, 72 66 100 12, tab 14 center

  ;icon 2, 66 32 112 79,  $mircexe, 0, tab 14 noborder
  icon 2, 66 30 112 88,  $mircexe, 0, tab 14 noborder

  button "&Load", 19, 3 151 59 10, tab 14
  text "Preview:", 15, 66 18 40 10, tab 14
  button "Bigger preview", 33, 128 17 50 10, tab 14
  tab "Apply", 16
  text "When loading, apply:", 4, 9 18 81 12, tab 16
  check "Everything", 5, 104 18 50 10, tab 16
  check "Background images", 6, 9 34 59 10, tab 16
  check "Colors", 7, 9 43 50 10, tab 16
  check "Event Messages", 8, 9 53 68 10, tab 16
  check "Fonts", 9, 9 63 50 10, tab 16
  check "Nicklist colors", 10, 104 34 50 10, tab 16
  check "Timestamp", 11, 104 44 50 10, tab 16
  check "Toolbar buttons", 12, 104 54 50 10, tab 16
  check "Toolbar/Switchbar bgs", 13, 104 64 65 10, tab 16
  check "Sounds", 37, 9 73 50 10, tab 16 disable
  text "It is highly recommended that you apply the theme's event messages; also most themes look weird if you don't apply their color settings.", 18, 9 89 164 37, tab 16
  tab "Settings", 3
  box "Font replacement:", 26, 3 18 105 95, tab 3
  check "Enable", 21, 7 28 50 10, tab 3
  list 22, 6 54 96 42, tab 3 size
  button "&Add", 23, 23 99 22 10, tab 3
  button "&Edit", 24, 47 99 22 10, tab 3
  button "&Remove", 25, 71 99 31 10, tab 3
  box "Cache:", 20, 3 115 105 37, tab 3
  check "Previews", 28, 9 124 42 10, tab 3
  check "Compiled scripts", 27, 53 124 53 10, disable tab 3
  text "Usage: 10MB", 40, 9 135 42 11, tab 3
  button "&Clear cache", 29, 65 136 37 10, tab 3
  box "/themes dialog:", 32, 111 18 70 83, tab 3
  check "Autopreview", 30, 115 28 63 10, tab 3
  check "Close on theme load", 31, 115 38 63 10, tab 3
  box "", 35, 6 38 43 14, tab 3
  text "Font:", 34, 9 43 29 8, tab 3
  box "", 36, 51 38 50 14, tab 3
  text "Replacement:", 43, 54 43 45 8, tab 3
  text "WARNING: Changes are saved immediately!", 44, 5 154 170 10, tab 3
}
on *:dialog:ircn.nxt:sclick:23:$dialog(nxt_frep_add_classic, nxt_frep, -4)
on *:dialog:ircn.nxt:sclick:24:if ($did(ircn.nxt,22).sel) $dialog(nxt_frep_edit_classic, nxt_frep, -4)
on *:dialog:ircn.nxt:sclick:25:{
  if (!$did(ircn.nxt,22).sel) return
  var %x = $input(Do you really want to remove $replace($gettok($did(22).seltext,2,124),\~,$chr(32)) ?,y,Remove?)
  if (%x) {
    hdel nxt_data $+(FRep.Rep.,$gettok($did(22).seltext,2,124))
    ircn.nxt.updfontrepl
  }
}
on *:dialog:ircn.nxt:dclick:1:{
  var %d = ircn.nxt, %x
  ;%x = $nxt_selected_scheme
  ;if (!%x) return
  if ($numtok($atreev(%d,1).selpath,32) == 1) {
    %x = $nxt_list_toggle_schemes($themedir,%d,1,$did(%d,1).sel,$did(%d,1).seltext)
  }
}
on *:dialog:ircn.nxt:dclick:2,41,42:{
  var %d = ircn.nxt, %x, %schm, %fn
  if (!$did(%d,1).sel) return
  %x = $nxt_selected_scheme
  %schm = $gettok(%x,1,32)
  %fn = $gettok(%x,2-,32)
  if ($nxt_locatetheme(%fn,$themedir)) %fn = $ifmatch
  else { nxt_error -a File $paren(%fn) not found | return }
  nxt_load_preview ircn.nxt small $iif(%schm,$ifmatch) $shortfn(%fn)
  nxt_dlg_cachesize
}
on *:dialog:ircn.nxt:sclick:1:{
  var %d = ircn.nxt, %x, %schm, %fn
  if (!$did(%d,1).sel) return
  %x = $nxt_selected_scheme
  %schm = $gettok(%x,1,32)
  %fn = $gettok(%x,2-,32)
  if ($nxt_locatetheme(%fn,$themedir)) %fn = $ifmatch
  else { nxt_error -a File $paren(%fn) not found | return }

  nxt_show_info_sel $themedir
  nxt_check_preview $iif(%schm,$ifmatch) $shortfn(%fn)
  nxt_dlg_cachesize
}
on *:dialog:ircn.nxt:sclick:19:{
  var %d = ircn.nxt, %schm, %fn, %x
  %x = $nxt_selected_scheme
  if (!%x) return
  %fn = $gettok(%x,2-,32)
  %schm = $gettok(%x,1,32)

  if ($nxt_locatetheme(%fn,$themedir)) %fn = $ifmatch
  else { nxt_error -a File $paren(%fn) not found | return }

  theme.load $iif(%schm,-s $+ $ifmatch) %fn
  nxt_dlg_cachesize
}
on *:dialog:ircn.nxt:sclick:33:{
  var %d = ircn.nxt, %schm, %fn, %x
  %x = $nxt_selected_scheme
  if (!%x) return
  %fn = $gettok(%x,2-,32)
  %schm = $gettok(%x,1,32)

  ;echo -a SC: %schm FN: %fn
  ;return

  if ($nxt_locatetheme(%fn,$themedir)) %fn = $ifmatch
  else { nxt_error -a File $paren(%fn) not found | return }


  nxt_load_bigpreview nxt_preview $iif(%schm,$ifmatch) $shortfn(%fn)
  nxt_dlg_cachesize
}
on *:dialog:ircn.nxt:sclick:5-13,37:{
  var %d = ircn.nxt
  var %apply = $base($+($nxt_ds(%d,13), $nxt_ds(%d,12), $nxt_ds(%d,11), $nxt_ds(%d,37), $nxt_ds(%d,10), $nxt_ds(%d,9), $nxt_ds(%d,8), $nxt_ds(%d,7), $nxt_ds(%d,6), $nxt_ds(%d,5)), 2, 10)
  if (!%apply) { %apply = 1 }
  hadd nxt_data Apply %apply
  if ($did(%d,5).state) { did -b %d 6,7,8,9,10,11,12,13 }
  else { did -e %d 6,7,8,9,10,11,12,13 }
}
on *:dialog:ircn.nxt:sclick:27,28:{
  var %d = ircn.nxt
  var %cache = $base($+($nxt_ds(%d,27), $nxt_ds(%d,28)), 2, 10)
  hadd nxt_data Cache %cache
}
on *:dialog:ircn.nxt:sclick:30,31:{
  var %d = ircn.nxt
  var %dlgset = $base($+($nxt_ds(%d,31), $nxt_ds(%d,30)), 2, 10)
  hadd nxt_data DlgSet %dlgset
}
on *:dialog:ircn.nxt:sclick:29:{
  var %d = ircn.nxt
  var %i = $findfile($nxt_cachedir,*.*,0,.remove $qt($1-))
  nxt_dlg_cachesize
}
on *:dialog:ircn.nxt:init:0:{
  _atreev.check
  var %d = ircn.nxt, %curschm = $hget(nxt_data,CurScheme), %curfn = $hget(nxt_data,CurTheme)
  nxt_make_treelist $themedir

  ;Apply settings
  var %did = 5 6 7 8 9 10 33 11 12 13, %i = $numtok(%did, 32), %set = $hget(nxt_data, Apply)
  while (%i) { if ($isbit(%set, %i)) { did -c %d $gettok(%did, %i, 32) } | dec %i }
  if ($did(%d,5).state) { did -b %d 6,7,8,9,10,33,11,12,13 }

  ;Cache settings
  var %did = 28 27, %i = $numtok(%did, 32), %set = $hget(nxt_data, Cache)
  while (%i) { if ($isbit(%set, %i)) { did -c %d $gettok(%did, %i, 32) } | dec %i }

  ;Dialog settings
  var %did = 30 31, %i = $numtok(%did, 32), %set = $hget(nxt_data, DlgSet)
  while (%i) { if ($isbit(%set, %i)) { did -c %d $gettok(%did, %i, 32) } | dec %i }

  ;Font Replace list
  if ($hget(nxt_data, FRep.Status)) { did -c %d 21 }
  _nxt_frep_dids
  ircn.nxt.updfontrepl

  did -ra %d 42 Double-click for preview $+ $crlf $+ Double-click list for schemes
  nxt_dlg_cachesize
  nxt_sel_loaded

  nxt_show_info_sel $nofile(%curfn)
  .timer 1 0 nxt_check_preview $iif(%curschm,$ifmatch) $shortfn(%curfn)
}
on *:dialog:ircn.nxt:sclick:21:{
  hadd nxt_data FRep.Status $iif($did(21).state,1)
  _nxt_frep_dids
}
alias -l _nxt_frep_dids {
  var %d = ircn.nxt
  ;Font Replace list
  if ($hget(nxt_data, FRep.Status) != 1)  did -b %d 22,23,24,25
  else did -e %d 22,23,24,25
}
alias -l nxt_dlg_cachesize {
  ;Cache dir size
  var %cachesize = 0, %d = ircn.nxt, %i
  if (!$dialog(%d)) return
  set %i $findfile($nxt_cachedir,*.*,0,inc %cachesize $file($1-).size)
  did -ra %d 40 Usage: $bytes(%cachesize).suf
}
alias -l nxt_selected_scheme {
  var %d = ircn.nxt, %schm, %fn
  if ($numtok($atreev(%d,1).selpath,32) == 1) {
    set %fn $gettok($did(%d,1,$did(%d,1).sel).text,1-,32)
    set %schm 0
  }
  elseif ($numtok($atreev(%d,1).selpath,32) > 1) {
    set %schm $remove($gettok($did(%d,1,$did(%d,1).sel).text,2,32),.)
    var %i = $did(%d,1).sel
    while ((%i > 0) && (!%fn)) {
      if ($atreev(%d,1,%i).tok == 1) {
        set %fn $gettok($did(%d,1,%i).text,1-,32)
      }
      dec %i
    }
  }
  else return $false
  return %schm %fn
}
alias -l nxt_ds return $did($1,$2).state
alias -l nxt_locatetheme {
  var %fn = $1, %d = $2
  if (\* !iswm %fn) && (?:\* !iswm %fn) {
    var %tfn = $themedir(%fn)
    if ($isfile(%tfn)) { %fn = %tfn }
    elseif ($nxt_trydir(%fn)) { %fn = $ifmatch }
    elseif ($findfile($2, %fn, 1, 2)) { %fn = $ifmatch }
  }
  if (!$isfile(%fn)) {
    return $false
  }
  return %fn
}
alias nxt_sel_loaded {
  var %d = ircn.nxt, %thm = $hget(nxt_data,CurTheme), %schm = $iifelse($hget(nxt_data,CurScheme),0)
  var %l = $didwm(ircn.nxt,1,$nopath(%thm))
  if (($atreev(%d,1,$calc(%l + 1)).tok == 1) || (%l == $did(%d,1).lines)) {
    var %x = $nxt_list_toggle_schemes($themedir,%d,1,%l,$nopath(%thm))
  }
  did -c %d 1 $calc(%l + 1 + %schm)
}
; /nxt_make_treelist
alias nxt_make_treelist {
  var %d = ircn.nxt, %s
  var %x
  did -r %d 1
  %s = $findfile($1-, *.mts, 0, 9, set %x $nxt_listadd_theme(%d,1,$nopath($1-),$1-))
  inc %s $findfile($1-, *.nxt, 0, 9, set %x $nxt_listadd_theme(%d,1,$nopath($1-),$1-))
}
alias -l nxt_show_info_sel { 
  var %d = ircn.nxt
  var %t, %t.name, %mtsver, %t.version, %t.author, %t.email, %t.website, %t.description, %ln, %sch, %fn
  %fn = $gettok($nxt_selected_scheme,2-,32)

  if (\* !iswm %fn) && (?:\* !iswm %fn) {
    var %tfn = $themedir(%fn)
    if ($isfile(%tfn)) { %fn = %tfn }
    elseif ($nxt_trydir(%fn)) { %fn = $ifmatch }
    elseif ($findfile($1, %fn, 1, 2)) { %fn = $ifmatch }
  }
  if (!$isfile(%fn)) {
    nxt_error -a File $paren(%fn) not found
    return
  }

  %ln = $read(%fn, nw, [mts])
  if (!%ln) { echo -s no ln | return }

  set -n %mtsver $gettok($read(%fn, nw, MTSVersion *, %ln), 2-, 32)
  if ((!%mtsver) && ($gettok($read(%fn, nw, NXTVersion *, %ln), 2-, 32))) { var %nxtver = $gettok($read(%fn, nw, NXTVersion *, %ln), 2-, 32) | set -n %mtsver NXT }
  if (!%ln) || ((%mtsver != NXT) && (!$istok(1 1.1 1.2 1.3, $calc(%mtsver), 32))) { goto inv }
  %t.name = $gettok($read(%fn, nw, Name *, %ln), 2-, 32)
  %t.version = $gettok($read(%fn, nw, Version *, %ln), 2-, 32)
  %t.author = $gettok($read(%fn, nw, Author *, %ln), 2-, 32)
  %t.email = $gettok($read(%fn, nw, EMail *, %ln), 2-, 32)
  %t.website = $gettok($read(%fn, nw, Website *, %ln), 2-, 32)
  %t.description = $gettok($read(%fn, nw, Description *, %ln), 2-, 32)


  did -r %d 17
  if (%t.name) did -a %d 17 Name: $ifmatch $crlf
  if (%t.author) did -a %d 17 Author: $ifmatch $crlf
  if (%t.version) did -a %d 17 Ver: $ifmatch $crlf
  if (%t.email) did -a %d 17 Email: $ifmatch $crlf
  if (%t.website) did -a %d 17 $+ Web: $ifmatch $crlf
  if (%t.description) did -a %d 17 Desc: $ifmatch
  ;xdid -c %d 17 1

  return
  :inv | nxt_error $active Invalid theme file
}
alias nxt_trydir if (\ isin $1) { return } | var %fn = $+($themedir, $iif((*.mts iswm %fn), $left(%fn, -4), %fn), \, $1) | if ($isfile(%fn)) { return %fn }
alias -l nxt_list_toggle_schemes { 
  var %t, %fn = $5, %t.name, %ln, %s
  var %d = $2, %did = $3, %sel = $4
  if (\* !iswm %fn) && (?:\* !iswm %fn) {
    var %tfn = $themedir(%fn)
    if ($isfile(%tfn)) { %fn = %tfn }
    elseif ($nxt_trydir(%fn)) { %fn = $ifmatch }
    elseif ($findfile($1, %fn, 1, 2)) { %fn = $ifmatch }
  }
  if (!$isfile(%fn)) {
    nxt_error -a File not found
    return
  }
  ;echo -a toggle: DIR: $1 DLG: $2 DID: $3 SEL: $4 THEME: $5 FN: %fn

  %ln = $read(%fn, nw, [mts])
  if (!%ln) { echo -s no ln | return }
  %t.name = $gettok($read(%fn, nw, Name *, %ln), 2-, 32)

  ;if ($gettok($did(%d,%did,$calc(%sel + 1)).text,1,32) != $nvar(atree.branch)) {
  if (($atreev(%d,1,$calc(%sel + 1)).tok == 1) || (%sel == $did(%d,1).lines)) {
    ;echo -a EXPAND
    var %i = $calc(%sel + 1), %schi = 1

    did -i %d %did %i $nvar(atree.branch) 0. (default)
    inc %i

    while ($gettok($read(%fn, nw, Scheme $+ %schi *, %ln), 2-, 32) != $null) {
      var %t.scheme [ $+ [ %schi ] ] 
      %t.scheme [ $+ [ %schi ] ] = $ifmatch 
      did -i %d %did %i $nvar(atree.branch) %schi $+ . %t.scheme [ $+ [ %schi ] ]
      inc %schi
      inc %i
    }

  }
  ;elseif ($gettok($did(%d,%did,$calc(%sel + 1)).text,1,32) == $nvar(atree.branch)) {
  elseif ($atreev(%d,1,$calc(%sel + 1)).tok > 1) {
    ;echo -a COLLAPSE
    var %i = $calc(%sel + 1)
    while ($atreev(%d,1,%i).tok > 1) { 
      did -d %d %did %i
    }
  }
}
alias -l nxt_listadd_theme { 
  var %t, %f = $4, %t.name, %ln

  %ln = $read(%f, nw, [mts])
  if (!%ln) { echo -s no ln | return }
  %t.name = $gettok($read(%f, nw, Name *, %ln), 2-, 32)

  did -a $1 $2 $nopath($4)
}
alias -l nxt_check_preview {
  var %sch, %thm, %d = ircn.nxt
  if ($0 >= 2) { %sch = $1 | %thm = $longfn($2-) }
  elseif ($0) { %thm = $longfn($1-) }
  else return
  var %pfn = $qt($nxt_cachedir($+($nopath(%thm), $iif((%sch), -S $+ %sch), .bmp)))
  if (!$isfile(%pfn)) %pfn = $qt($nxt_cachedir($+($nopath(%thm), $iif((%sch), -S $+ %sch), .png)))
  if (!$isfile(%pfn)) %pfn = $qt($nxt_cachedir($+($nopath(%thm), $iif((%sch), -S $+ %sch), .jpg)))
  if (($pic(%pfn).size) && ($pic(%pfn).size < 90000)) { did -h %d 2,41,42 | did -g %d 2 %pfn | did -v %d 2 }
  else { 
    if ($isbit($hget(nxt_data,DlgSet),1)) nxt_load_preview ircn.nxt small $1-
    else { did -h %d 2 | did -g %d 2 $mircexe 0 | did -v %d 41,42,2 }
  }
}
alias nxt_frep_disp {
  var %a = $replace($1, \~, $chr(32)), %b = $2, %s
  return %a $iif($0 > 1,$chr(9) + 0 %b)
}
alias ircn.nxt.updfontrepl {
  var %i, %x
  if ($dialog(ircn.nxt.modern)) xdid -r $v1 22
  if ($dialog(ircn.nxt)) did -r $v1 22
  %i = 1
  while ($hmatch(nxt_data, FRep.Rep.*, %i)) { 
    %x = $ifmatch
    if ($dialog(ircn.nxt.modern)) xdid -a $v1 22 0 0 + 0 0 0 0 -1 -1 $nxt_frep_disp($mid(%x,10), + 0 0 $hget(nxt_data,%x))
    if ($dialog(ircn.nxt)) did -a $v1 22 $listvfrmt($tab(46 $nxt_frep_disp($mid(%x,10)),60 $hget(nxt_data,%x))).line $+($|,$mid(%x,10),$|,$hget(nxt_data,%x))
    inc %i 
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;
;; font replacement dialog (add/edit)
;;;;;;;;;;;;;;;;;;;;;;;;;
dialog nxt_frep {
  title ""
  size -1 -1 114 46
  option dbu
  icon $mircexe, 16
  text "&Original font:", 1, 3 3 32 7
  combo 2, 39 1 72 50, edit drop
  text "&Replacement:", 3, 3 17 33 7
  combo 4, 39 15 72 30, edit drop
  box "", 2900, -1 27 116 20
  button "OK", 2901, 29 34 40 10, disable default ok
  button "Cancel", 2902, 72 34 40 10, cancel
  text "", 5, 0 0 0 0, hide
}
on *:DIALOG:nxt_frep_*:init:0:{
  if ($gettok($dname, 3, 95) == add) { dialog -t $dname Add replacement }
  else {
    dialog -t $dname Edit replacement
    ;;;;;tokenize 124 $did(nxt_settings, 27, $did(nxt_settings, 27, 1).sel)
    if ($gettok($dname, 4, 95) == modern) tokenize 124 $+(number1,$|,$xdid(ircn.nxt.modern,22,$xdid(ircn.nxt.modern,22).sel,0).text,$|,$xdid(ircn.nxt.modern,22,$xdid(ircn.nxt.modern,22).sel,1).text)
    else tokenize 124 $did(ircn.nxt,22).seltext
    did -o $dname 2 0 $replace($2,\~,$chr(32)) | did -o $dname 4 0 $3
    did -o $dname 5 1 $replace($2,\~,$chr(32)) | did -e $dname 2901
  }
  didtok $dname 2 59 GwdTE_437;IBMPC;PC8X16;Tahoma
}
on *:DIALOG:nxt_frep_*:edit,sclick:2,4:{
  var %txt, %rep, %i = $did($dname, 4).lines | set -n %txt $remove($did($dname, 2), |, \~) | set -n %rep $remove($did($dname, 4), |, \~)
  if ($did = 2) {
    while (%i) { did -d $dname 4 %i | dec %i }
    if ($istok(GwdTE_437;IBMPC;PC8X16, %txt, 59)) { did -a $dname 4 Terminal }
    if (%txt == Tahoma) { did -a $dname 4 Verdana }
  }
  if ((%txt = $null) || (%rep = $null) || (%txt == %rep)) {
    did -b $dname 2901
  }
  else { did -e $dname 2901 }
}
on *:DIALOG:nxt_frep_add_*:sclick:2901:{
  hadd nxt_data $+(FRep.Rep.,$replace($did($dname, 2),$chr(32),\~)) $did($dname, 4)
  ircn.nxt.updfontrepl
}
on *:DIALOG:nxt_frep_edit_*:sclick:2901:{
  if ($gettok($dname, 4, 95) == modern) hdel nxt_data $+(FRep.Rep.,$replace($xdid(ircn.nxt.modern,22,$xdid(ircn.nxt.modern,22).sel,0).text,$chr(32),\~))
  else hdel nxt_data $+(FRep.Rep.,$gettok($did(ircn.nxt,22).seltext,2,124))
  hadd nxt_data $+(FRep.Rep.,$replace($did($dname, 2),$chr(32),\~)) $did($dname, 4)
  ircn.nxt.updfontrepl
}

dialog ircnsetup.pasteprot {
  title "Paste Protection"
  size -1 -1 189 162
  option dbu
  combo 1, 5 23 143 135, size
  button "&Add", 2, 152 24 35 13
  button "&Delete", 3, 152 40 35 13
  text "Prompt me before accidently pasting any of these words:", 4, 6 5 178 13
  button "&Clear", 5, 152 63 35 13
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias displaysettings {
  dlg -r ircnsetup.display
  dialog -rsb ircnsetup.display -1 -1  206 178
  did -v ircnsetup.display 100,101
}

dialog ircnsetup.display {
  title "Display Settings"
  size -1 -1 206 178
  option dbu
  icon $gfxdir(icons\ircn.ico), 0
  check "Always do an Idle Whois", 1, 7 13 87 10
  text "Server Notices:", 2, 5 112 40 10, right
  combo 3, 48 112 45 50, size drop
  text "WallOps:", 4, 5 124 40 10, right
  combo 5, 48 123 45 50, size drop
  check "Timestamp all ircN echos (/iecho)", 6, 7 23 87 10
  text "ircN echo:", 7, 5 89 40 10, right
  combo 8, 48 88 45 48, size drop
  button "&OK", 100, 127 164 37 12, hide default ok
  button "&Cancel", 101, 166 164 37 12, hide cancel
  combo 10, 48 149 45 50, size drop
  text "Nicklist colors:", 11, 5 149 40 10, right
  check "Mode prefix uses nicklist color", 12, 7 33 87 10
  check "Theme /motd", 13, 7 43 87 10
  box "Display Settings", 14, 2 2 201 160
  button "Open Channel Display", 15, 127 9 72 12, hide
  check "Background color fix", 16, 7 54 86 10
  check "Highlight Window", 9, 97 87 55 11
  combo 18, 153 88 45 42, size drop
  check "Whois Window", 17, 97 100 53 11
  combo 19, 153 100 45 42, size drop
  combo 20, 48 136 45 50, size drop
  text "MOTD:", 21, 5 136 40 10, right
  text "Queries", 22, 5 101 40 10, right
  combo 23, 48 101 45 42, size drop
  text "Notify:", 24, 97 113 53 10, right
  combo 25, 153 112 45 42, size drop
}


on *:dialog:ircnsetup.display:sclick:15: chandisplay
on *:dialog:ircnsetup.display:sclick:9:did $iif($did(9).state,-e,-b) $dname 18
on *:dialog:ircnsetup.display:sclick:17:did $iif($did(17).state,-e,-b) $dname 19
on *:dialog:ircnsetup.display:sclick:22:{
  if ($did(22).state == 1) did -e $dname 23
  else did -b $dname 23
}

on *:dialog:ircnsetup.display:sclick:100:{
  _save.display
}
on *:dialog:ircnsetup.display:init:0:{
  var %n = $dname


  did -a %n 3,8,5,20 Status
  did -a %n 3,8,5 Active
  did -a %n 3,5,20 Window
  did -a %n 10 Disabled
  did -a %n 10 Userlist
  did -a %n 10 Theme style
  did -a %n 18,19 By Network
  did -a %n 18,19 Global

  did -a %n 23 Window
  did -a %n 23 Active+Window
  did -a %n 23 Active
  did -a %n 23 Status
  did -a %n 23 Status+Window
  if ($didwm(%n,23,$nvar(show.queries) ,1))  did -c %n 23 $ifmatch
  else did -c %n 23 1

  var %set = alwaysidlewhois timestampiecho highlightwin   whoiswindow  colorprefix.mode theme.motd bgfix
  var %did = 1                 6            9                  17         12               13         16, %i = $numtok(%did, 32)
  while (%i) { if ($nvar($gettok(%set,%i,32)) == on) { did -c %n $gettok(%did, %i, 32) } | dec %i }

  did -c %n 3 $iif($nvar(show.snotice),$replace($nvar(show.snotice),Status,1,Active,2,Window,3),2)
  did -c %n 5 $iif($nvar(show.wallop),$replace($nvar(show.wallop),Status,1,Active,2,Window,3),2)
  did -c %n 8 $iif($nvar(show.iecho),$replace($nvar(show.iecho),Status,1,Active,2,Window,3),2)
  did -c %n 20 $iif($nvar(motdwindow),2,1)
  did -c %n 18 $iif($nvar(highlightwin.global),2,1)
  did -c %n 19 $iif($nvar(whoiswindow.global),2,1)


  did $iif($did(9).state,-e,-b) %n 18
  did $iif($did(17).state,-e,-b) %n 19


  if (($nvar(colul) == on) && ($nvar(colnick) == on)) did -c $dname 10 2
  elseif (($nvar(colul) != on) && ($nvar(colnick) == on)) did -c $dname 10 3
  else did -c $dname 10 1

}
alias _save.display {
  var %d = ircnsetup.display
  if (!$dialog(%d)) return



  var %set = alwaysidlewhois timestampiecho highlightwin  whoiswindow  colorprefix.mode theme.motd bgfix
  var %did = 1                 6           9                17            12               13           16, %i = $numtok(%did, 32)

  while (%i) { nvar $gettok(%set,%i,32) $iif($did(%d,$gettok(%did,%i,32)).state == 1,on) | dec %i }

  nvar show.snotice $did(%d,3)
  nvar show.wallop $did(%d,5)
  nvar show.iecho $did(%d,8)
  nvar show.queries $iif($did(%d,23) != Window, $did(%d,23))

  nvar motdwindow $iif($did(%d,20).sel == 2,on)
  nvar highlightwin.global $iif($did(%d,18).sel == 2,on)
  nvar whoiswindow.global $iif($did(%d,19).sel == 2,on)

  var %a
  if ($did(%d,10).sel == 3) {
    if ($nvar(colul) == on) set %a true
    nvar colul
    nvar colnick on
  }
  elseif ($did(%d,10).sel == 2) {
    if ($nvar(coul) != on) set %a true
    nvar colul on
    nvar colnick on
  }
  else {
    if ($nvar(colnick) == on) set %a true
    nvar colnick
  }
  if (%a == true) .timercolnick 1 1 .colnick

}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display -> appearance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias ifacesettings {
  dlg -r ircnsetup.appearance
  dialog -rsb ircnsetup.appearance  -1 -1 245 118
  ; did -v ircnsetup.appearance 100,101
}

dialog ircnsetup.appearance {
  title "ircN Appearance Settings"
  size -1 -1 0 0 
  option dbu
  check "Custom App Icon", 1, 7 6 61 10
  check "Custom Tray Icon", 2, 7 18 64 9
  box "App", 3, 79 0 27 31
  icon 4, 81 7 20 20,  $gfxdir(icons\ircn.icl) , 0, noborder
  box "Tray", 5, 107 0 27 31
  icon 6, 109 7 20 20,  $gfxdir(icons\ircn.icl) , 0, noborder
  check "Popup menu command tips [/command]", 7, 7 36 107 11


}
on *:DIALOG:ircnsetup.appearance:init:0:{
  ;did -h $dname 3-6

  if ($nvar(commandtip.hidepopups) != on) did -c $dname 7
  if (!$nvar(interface.appicon)) did -g $dname 4 0 $qt($mircexe)
  if (!$nvar(interface.trayicon)) did -g $dname 6 0 $qt($mircexe)

}
on *:DIALOG:ircnsetup.appearance:sclick:1:{
  if (!$did(1).state) {
    did -g $dname 4 0 $qt($mircexe)
  }
}
on *:DIALOG:ircnsetup.appearance:sclick:2:{
  if (!$did(2).state) {
    did -g $dname 6 0 $qt($mircexe)
  }
}

on *:DIALOG:ircnsetup.appearance:sclick:4:{
  var %a = $dcx(PickIcon,0 $icondir(ircn.icl) ) 
  if (!%a) || ($gettok(%a,1,32) == D_ERROR) return
  if ($isfile($gettok(%a,3-,32))) {
    did -g $dname 4 $gettok(%a,2,32) $gettok(%a,3-,32)
    if (!$did(1).state) did -c $dname 1
  }
}
on *:DIALOG:ircnsetup.appearance:sclick:6:{
  var %a = $dcx(PickIcon,0 $icondir(ircn.icl) ) 
  if (!%a) || ($gettok(%a,1,32) == D_ERROR) return
  if ($isfile($gettok(%a,3-,32))) {
    did -g $dname 6 $gettok(%a,2,32) $gettok(%a,3-,32)
    if (!$did(2).state) did -c $dname 2
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display -> Hide Events dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias hideevents {

  if ($istok(%ircnsetup.docked,ircnsetup.display.hideevents,44)) return
  dlg -r ircnsetup.display.hideevents
  dialog -rsb ircnsetup.display.hideevents  -1 -1 179 187

  did -v ircnsetup.display.hideevents  98,99

}
dialog ircnsetup.display.hideevents {
  title "Hide Events"
  size -1 -1 0 0
  option dbu
  icon $gfxdir(icons\ircn.ico), 0
  box "Hide events:", 1, 4 4 172 161
  check "Common chans in query", 2, 98 25 76 10
  check "&Channel topic", 3, 11 36 80 10
  check "Channel totals", 4, 11 56 80 10
  check "&User list (/names)", 5, 11 26 80 10
  check "Sync status", 6, 11 66 80 10
  check "Chanel topic set", 7, 11 46 80 10
  check "Creation info", 8, 11 76 80 10
  check "IRCop list", 9, 11 86 80 10
  check "&Welcome messages", 10, 10 117 70 10
  check "&Statistics (/lusers)", 11, 10 127 70 10
  check "&Quits in query", 12, 98 35 74 10
  text "On channel join:", 13, 10 15 45 10
  text "On server connect:", 14, 10 106 50 10
  text "Miscellaneous:", 15, 98 15 50 10
  button "&OK", 99, 99 170 37 14, hide default ok
  button "&Cancel", 98, 138 170 37 14, hide cancel
}

on 1:dialog:ircnsetup.display.hideevents:sclick:99: _save.display.hideevents
on 1:dialog:ircnsetup.display.hideevents:init:0:{
  var %n = $dname



  var %set = onconnect.welcome onconnect.lusers join.names join.topic join.topicset join.totals join.sync join.created join.ircops commonquery quitsinquery
  var %did = 10                 11               5          3          7             4           6         8            9          2           12, %i = $numtok(%did, 32)

  while (%i) { if ($nvar($gettok(%set,%i,32)) != on) { did -c %n $gettok(%did, %i, 32) } | dec %i }


}

alias _save.display.hideevents {
  var %d = ircnsetup.display.hideevents
  if (!$dialog(%d)) return

  var %set = onconnect.welcome onconnect.lusers join.names join.topic join.topicset join.totals join.sync join.created join.ircops commonquery quitsinquery
  var %did = 10                 11               5          3          7             4           6         8            9          2           12, %i = $numtok(%did, 32)

  while (%i) {   nvar $gettok(%set,%i,32) $iif($did(%d,$gettok(%did,%i,32)).state != 1,on) | dec %i }

}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; About dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias about {
  dlg -r ircnsetup.about
  dialog -rsb ircnsetup.about -1 -1 188 142
}
dialog ircNsetup.about {
  title "ircN About"
  icon $gfxdir(icons\ircn.ico), 0
  size -1 -1  0 0 
  option dbu
  tab "About", 2, 2 2 185 135
  icon 7, 6 20 173 85,  $icondir(mirccolors.icl), 16, tab 2 noborder top
  text "ircN 9.00 Reldate 0/0/00", 8, 88 106 91 8, tab 2 right
  text "The ircN Development Team", 9, 78 116 100 8, tab 2 right
  link "www.ircN.org", 10, 8 116 37 10, tab 2
  link "#ircN@Freenode", 3, 8 106 54 8, tab 2
  tab "History", 4
  tab "Team", 5
  tab "Thanks", 6
  edit "", 1, 6 19 174 103, read multi autovs vsbar
  edit "", 11, 6 63 174 59, read multi autovs vsbar
}
on 1:dialog:ircnsetup.about:sclick:10:url http://www.ircN.org
on 1:dialog:ircnsetup.about:dclick:7:url http://www.ircN.org
on 1:dialog:ircnsetup.about:sclick:3:joinircn 
on 1:dialog:ircnsetup.about:init:0:{
  var %n = $dname
  did -c %n 2
  did -h %n 1,11
  var %a = $findfile($gfxdir,ircnlogo*.jpg,0)
  var %f = $findfile($gfxdir,ircnlogo*.jpg,$rand(1,%a))
  did -g $dname 7 $qt(%f)
  ;did -g $dname 12 $gfxdir(mesmall.jpg)
  did -ra $dname 8 ircN $nvar(ver) release: $nvar(reldate)
}
on 1:dialog:ircnsetup.about:sclick:2:{
  var %n = $dname
  did -h %n 1,11
  ;did -v %n 6,7,8,9
  did -ra %n 9 The ircN Development Team
}

on 1:dialog:ircnsetup.about:sclick:3:{
  var %n = $dname
  did -h %n 1
  did -v %n 11
}
on 1:dialog:ircnsetup.about:sclick:4,5,6:{
  var %n = $dname

  ;did -h %n 6,7,8,9
  did -v %n 1
  did -h %n 11
  did -r %n 1

  var %a = about author history team thanks
  var %b = $gettok(%a,$calc($did - 1),32)

  if (%b == History) loadbuf -pio %n 1 $txtd(ircn_history.txt)
  elseif (%b == Team) loadbuf -pio %n 1 $txtd(team.txt)
  elseif (%b == Thanks) loadbuf -pio %n 1 $txtd(thanks.txt)
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Nick Complete dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias nickcomp {
  if ($istok(%ircnsetup.docked,ircnsetup.nickcomp,44)) return

  dlg -r ircNsetup.nickcomp
  dialog -rsb ircnsetup.nickcomp -1 -1 163 142

  did -v ircNsetup.nickcomp 98,99
}

dialog ircnsetup.nickcomp {
  title "ircN Nickcomplete"
  size -1 -1 0 0
  option dbu
  icon $gfxdir(icons\ircn.ico), 0
  text "Style:", 1, 81 2 22 11
  combo 2, 104 2 56 130, size drop
  text "Activator:", 3, 3 18 29 7
  edit "", 4, 35 17 12 11, center
  text "Left Side:", 5, 51 18 28 10
  edit "", 6, 80 17 15 11, center autohs
  text "Right Side:", 7, 100 18 43 10
  edit "", 8, 143 17 15 11, center autohs
  text "Preview:", 9, 3 32 31 11
  icon 10, 36 31 122 11,  $icondir(mirccolors.icl), 16, noborder left
  check "Enabled", 11, 5 4 44 8

  button "OK", 99, 77 117 38 14, hide ok
  button "Cancel", 98, 120 117 38 14, hide cancel
}

on 1:dialog:ircnsetup.nickcomp:init:0:{
  var %a = 1
  did -a $dname 2 Random
  while ($gettok($nxt::ircN.script.nickcomp.styles,%a,32) != $null) {
    did -a $dname 2 $ifmatch
    inc %a
  }
  var %s = $nvar(nickcomp.style)
  if ($didwm(2,%s)) did -c $dname 2 $ifmatch
  else did -c $dname 2 1
  if ($nvar(nickcomp) == on) did -c $dname 11 1
  did -ra $dname 4 $iifelse($nvar(nickcomp.nch),:)
  did -ra $dname 6 $nvar(nickcomp.nlb)
  did -ra $dname 8 $nvar(nickcomp.nrb)
  nickcomp.preview $iif(%s,%s,random)
  did -g $dname 10 $td(nickcomp.bmp)
}
on 1:dialog:ircnsetup.nickcomp:sclick:2:{
  nickcomp.preview $did(2)
  did -g $dname 10 $td(nickcomp.bmp)
}
on 1:dialog:ircnsetup.nickcomp:edit:6,8:{
  nickcomp.preview $did(2)
  did -g $dname 10 $td(nickcomp.bmp)
}
on 1:dialog:ircnsetup.nickcomp:sclick:99:_save.nickcomp

alias _save.nickcomp {
  var %d = ircnsetup.nickcomp
  if (!$dialog(%d)) return
  nvar nickcomp $nro2onoffdef($did(%d,11).state)
  nvar nickcomp.nch $did(%d,4)
  nvar nickcomp.nlb $did(%d,6)
  nvar nickcomp.nrb $did(%d,8)
  nvar nickcomp.style $did(%d,2)
}
alias -l nickcomp.preview {
  var %d = ircnsetup.nickcomp
  window -ph +d @nickcompprev 30 30 100 25
  clear @nickcompprev
  set -u1 %::nickcomp $me
  if ($1 == random) {
    if ($isalias(nxt::ircN.script.nickcomp.styles)) nxt::ircN.script.nickcomp.style. $+ $gettok($nxt::ircN.script.nickcomp.styles,$rand(1,$numtok($nxt::ircN.script.nickcomp.styles,32)),32)
  }
  else nxt::ircN.script.nickcomp.style. $+ $1
  var %q = $did(%d,6) $+ $result $+ $did(%d,8) 

  drawtext -pn @nickcompprev $colour(say) " $+ $window(*,1).font $+ " $window(*,1).fontsize 5 5 %q
  drawdot @nickcompprev
  if ($isfile($td(nickcomp.bmp))) .remove $td(nickcomp.bmp)
  drawsave @nickcompprev $td(nickcomp.bmp)
  window -c @nickcompprev
  unset %::nickcomp
}
;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Splash dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;
alias splash {
  if ($nvar(splash) == on)  dlg splash
}
dialog splash {
  title "ircN"
  icon $gfxdir(icons\ircn.ico), 0
  size -1 -1 200 98
  option dbu
  icon 1, 0 0 199 97
}
on 1:dialog:splash:init:*:{
  dialog -t $dname ircN $nvar(ver) 
  var %a = $findfile($gfxdir,ircnlogo*.jpg,0)
  var %f = $findfile($gfxdir,ircnlogo*.jpg,$rand(1,%a))
  did -g $dname 1 $qt(%f)
  .timersplash -o 1 3 if ($ $+ dialog(splash)) dialog -x splash
}
on 1:dialog:splash:sclick:*:dialog -x $dname
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Color picker
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on *:dialog:ircn.mirccolors:init:*:{ dialog -sb $dname $calc($mouse.cx + 2) $calc($mouse.cy + 3) 73 17 | _refreshcolorgfx }
dialog ircn.mirccolors {
  title "mIRC Colors"
  icon $gfxdir(icons\ircn.ico), 0
  size -1 -1 73 17
  option dbu
  icon 1, 1 1 8 7, $td(colors\00txt.bmp)
  icon 2, 10 1 8 7, $td(colors\01txt.bmp)
  icon 3, 19 1 8 7, $td(colors\02txt.bmp)
  icon 4, 28 1 8 7, $td(colors\03txt.bmp)
  icon 5, 37 1 8 7, $td(colors\04txt.bmp)
  icon 6, 46 1 8 7, $td(colors\05txt.bmp)
  icon 7, 55 1 8 7, $td(colors\06txt.bmp)
  icon 8, 64 1 8 7, $td(colors\07txt.bmp)
  icon 9, 1 9 8 7, $td(colors\08txt.bmp)
  icon 10, 10 9 8 7, $td(colors\09txt.bmp)
  icon 11, 19 9 8 7, $td(colors\10txt.bmp)
  icon 12, 28 9 8 7, $td(colors\11txt.bmp)
  icon 13, 37 9 8 7, $td(colors\12txt.bmp)
  icon 14, 46 9 8 7, $td(colors\13txt.bmp)
  icon 15, 55 9 8 7, $td(colors\14txt.bmp)
  icon 16, 64 9 8 7, $td(colors\15txt.bmp)
}
on 1:dialog:ircn.mirccolors:sclick:*:if ($did isnum 1-16) { set -u20 %mirccolorsdlg.result $base($calc($did -1),10,10,2) | dialog -x $dname }

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Viewfile dialog
;;;;;;;;;;;;;;;;;;;;;;;;;
on *:DIALOG:ircN.viewfile:init:*:{
  if ($exists(%viewfile) == $null) dialog -c $dname
  else loadbuf -o $dname 1 %viewfile
}
on *:DIALOG:ircN.viewfile:close:*:unset %viewfile
dialog ircN.viewfile {
  title "ircN File Viewer"
  icon $gfxdir(icons\ircn.ico), 0
  size -1 -1 640 480
  edit "", 1, 10 10 620 422, read multi vsbar autovs
  button "&Close", 2, 300 445 60 22, cancel default
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Network dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircNsetup.network {
  title "ircN Network Settings"
  size -1 -1 0 0
  option dbu
  text "Network:", 1, 88 3 29 10
  combo 2, 118 2 64 55, size drop
  text "User Mode:", 3, 8 26 38 13
  edit "", 4, 51 25 29 12, autohs
  text "Network Support:", 5, 7 121 46 9, hide
  combo 6, 53 121 44 54, hide size drop
  check "Auto-Update server links", 9, 109 25 72 10, 3state
  check "Always keep network settings", 10, 92 38 86 13
  box "Expired Network Settings", 11, 84 16 98 42
  text "Expiration Age:", 12, 91 27 46 10
  edit "", 14, 140 25 17 12
  text "days", 15, 161 27 17 11
  combo 13, 53 133 44 46, hide size drop
  text "IRCD Support:", 16, 7 133 45 9, hide
  box "IRC Operator", 17, 5 41 94 76
  text "User Mode:", 18, 11 89 38 13
  edit "", 19, 48 88 29 12, autohs
  text "Username:", 20, 11 62 36 13
  edit "", 21, 48 60 47 12, autohs
  edit "", 22, 48 73 47 12, pass autohs
  text "Password:", 23, 11 75 36 13
  box "Settings", 24, 2 13 101 137
  box "Options", 25, 104 13 79 88
  check "Auto-Update server links", 26, 8 50 72 10
  box "Settings", 27, 3 16 80 80
  button "Edit on-IRCOP Perform", 7, 7 102 88 12
  check "Reconnect on /Kill", 8, 109 46 69 10, 3state
  check "Reconnect on /kill", 28, 8 72 72 10
  text "A filled checkbox means it will use the default value set on the Global network settings. On/Off will override the Global value for the network.", 29, 107 104 74 32
  button "&OK", 100, 108 166 37 13, hide default ok
  button "&Cancel", 101, 147 166 37 13, hide cancel
  check "Keep server list fresh", 30, 109 35 72 10, 3state
  check "Keep server list fresh", 31, 8 61 72 10
  check "Enabled", 32, 8 50 60 9
  check "Hop server on lag", 33, 109 66 57 10, disable
  button "..", 34, 166 66 14 11, flat, disable
  check "Auto detect services", 35, 109 56 71 10, 3state
  check "Auto detect services", 36, 8 40 72 10
}

on *:DIALOG:ircnsetup.network:sclick:34:{
  var %d = ircn.switchserverlag
  dlg %d
  did -ra %d 11 $did(2)
}

on *:DIALOG:ircnsetup.network:sclick:10:did $iif($did($did).state,-b,-e) $dname 12,14,15
on *:DIALOG:ircnsetup.network:sclick:6,13:{
  if ($did($did).sel == 3) did -c $dname $did $iif($did($did,$pls($did($did).sel,1)),$pls($did($did).sel,1),$sub($did($did).sel,1)) 


  tmpdlgset $dname $did(2) global $did $did($did)

}
alias netsettings {
  if ($istok(%ircnsetup.docked,ircnsetup.network,44)) return
  var %d = ircNsetup.network
  dlg -r %d
  dialog -rsb %d -1 -1 190 186

  did -v %d 100,101

  .timer 1 0  _ircnsetup.network.updatedids $iif($1 == global,global,network)


}
alias _netsupport.dlgformatstring return $firstcap($nopath($1-))
alias _ircnsetup.network.addircdpopups {
  .echo -q $whilearray($ntmp(_cache.netsupport.ircds), 44, did -a ircnsetup.network 13, _netsupport.dlgformatstring )
}
alias _ircnsetup.network.addnetpopups { 
  .echo -q $whilearray($ntmp(_cache.netsupport.networks), 44, did -a ircnsetup.network 6, _netsupport.dlgformatstring )
}

on *:dialog:ircNsetup.network:close:0:.timer 1 1 _tmpdlgdel.hash $dname
on *:dialog:ircnsetup.network:init:0:{
  var %n = $dname
  _tmpdlg.hashopen
  _ircn.setup.addnetcombo $dname 2

  ;---network popups---
  did -ra %n 6,13 -Auto Detect-
  did -a %n 6,13 -Disabled-
  did -a %n 6,13 $str(-,50)

  _ircnsetup.network.addnetpopups
  _ircnsetup.network.addircdpopups
  did -c %n 6,13 1

  ;------------------------
  _ircn.loadtmpdlgdid %n global,net umode;4 text
  _ircn.loadtmpdlgdid %n global,net reconnectonkill;8 check
  _ircn.loadtmpdlgdid %n net autoupdatelinks;9 check
  _ircn.loadtmpdlgdid %n net detectservices;35 check
  _ircn.loadtmpdlgdid %n net serverlistkeepfresh;30 check
  _ircn.loadtmpdlgdid %n net ircop.enabled;32 check2 
  _ircn.loadtmpdlgdid %n net ircop.user;21 text
  _ircn.loadtmpdlgdid %n net ircop.pass;22 text
  _ircn.loadtmpdlgdid %n net ircop.umode;19 text

  _ircn.loadtmpdlgdid %n net networksupport.type;6 text
  _ircn.loadtmpdlgdid %n net ircdsupport.type;13 text

  _ircnsetup.network.updatedids global


}

alias _ircnsetup.network.updatedids {
  var %n = ircnsetup.network



  if ($nvar(autoupdatelinks) == on) did -c %n 26
  if ($nvar(serverlistkeepfresh) == on) did -c %n 31
  if ($nvar(reconnectonkill) == on) did -c %n 28 
  did $iif($nvar(detectservices) == off,-u,-c) %n 36 


  if ($nvar(netsettingsexpiredays) isnum) did -ra %n 14 $ifmatch
  if ($nvar(netsettingskeep)) did -c %n 10 $ifmatch

  did $iif($did(%n,10).state,-b,-e) %n 12,14,15

  did -r %n 21,22
  if ($1 == network) {
    var %net = $iif($2,$2,$network)
    if ($didwm(%n,2,%net)) {

      did -c %n 2 $ifmatch


      ;load settings from tempsetup table



      .timer -m 1 1 _ircn.upddlgchks %n %net Global 8
      .timer -m 1 1 _ircn.upddlgchks %n %net Global 9
      .timer -m 1 1 _ircn.upddlgchks %n %net Global 30
      .timer -m 1 1 _ircn.upddlgchks %n %net Global 32
      .timer -m 1 1 _ircn.upddlgchks %n %net Global 35


      .timer -m 1 1 _ircn.upddlgtxts %n %net Global 4
      .timer -m 1 1 _ircn.upddlgtxts %n %net Global 21
      .timer -m 1 1 _ircn.upddlgtxts %n %net Global 22
      .timer -m 1 1 _ircn.upddlgtxts %n %net Global 19



      ;--- load the network/ircd support settings

      if ($didwm(%n,13,$hget(tempsetup,$tab(set,%n,%net,global,13)))) did -c %n 13 $v1
      else did -c %n 13 1
      if ($didwm(%n,6,$hget(tempsetup,$tab(set,%n,%net,global,6))))  did -c %n 6 $v1
      else did -c %n 6 1

      ;--------


      if (($hget(tempsetup,$tab(set,%n,%net,global,21))) && ($hget(tempsetup,$tab(set,%n,%net,global,22)))) {
        did -e %n 7
      }
      else did -b %n 7


      if ($hget(tempsetup,$tab(set,%n,%net,global,32)))   did -e %n 18,19,20,21,22,23
      else did -b %n  18,19,20,21,22,23




      .did -h %n 10,11,12,14,15,10,26,27,28,31,36
      did -v %n 8,5,9,6,13,16,17,20,21,22,23,18,19,25,24,7,29,30,32,33,34,35

      if (!$ismod(services.mod))  did -h %n 5,16,6,13

      return
    }
  }
  did -c %n 2 1

  ;ids to show when global is selected
  did -v %n 11,12,14,15,10,26,27,28,31,36
  did -h %n 8,5,9,6,13,16,17,20,21,22,23,18,19,25,24,7,29,30,32,33,34,35


  if (!$ismod(services.mod))  did -h %n 5,16,6,13

  .timer 1 0 _ircn.upddlgtxts %n Global Global 4




}

on *:dialog:ircnsetup.network:sclick:7:{


  .timer 1 0 ircopedit $iif($did(2).sel > 2, $did(2))

}
on *:dialog:ircnsetup.network:sclick:2:{


  if ($did(2).sel == 2) { did -c $dname 2 $iif($did(2,$pls($did(2).sel,1)),$pls($did(2).sel,1),$sub($did(2).sel,1)) }
  var %a = $did(2)
  var %n = $dname


  _ircnsetup.network.updatedids $iif(%a == global,global,network %a) 

}
on *:dialog:ircnsetup.network:edit:4:{
  tmpdlgset $dname $did(2) Global $did $did($did)
}
on *:dialog:ircnsetup.network:edit:19,21,22:{
  tmpdlgset $dname $did(2) Global $did $did($did)

  if ($did != 19)  did $iif(($did(21) && $did(22)), -e, -b) $dname 7

}
;check boxes
on *:dialog:ircnsetup.network:sclick:8,9,30:{
  tmpdlgset $dname $did(2) Global $did $did($did).state
}
on *:dialog:ircnsetup.network:sclick:32:{

  if ($did($did).state) did -e $dname 18,19,20,21,22,23
  else did -b $dname  18,19,20,21,22,23

  tmpdlgset $dname $did(2) Global $did $did($did).state
}


on *:dialog:ircnsetup.network:sclick:26:{
  ;; if ($did(26).state) did -b $dname 9
  ;; else did -e $dname 9 
}
on *:dialog:ircnsetup.network:sclick:100:{
  _save.network
}
alias _save.network {
  var %n = ircnsetup.network
  if (!$dialog(%n)) return

  _save.networksupport

  _ircn.savetmpdlgdid %n global,net umode;4 text
  _ircn.savetmpdlgdid %n net ircop.user;21 text
  _ircn.savetmpdlgdid %n net ircop.pass;22 text
  _ircn.savetmpdlgdid %n net ircop.umode;19 text

  _ircn.savetmpdlgdid %n net networksupport.type;6 text
  _ircn.savetmpdlgdid %n net ircdsupport.type;13 text

  _ircn.savetmpdlgdid %n net reconnectonkill;8 check
  _ircn.savetmpdlgdid %n net autoupdatelinks;9 check

  _ircn.savetmpdlgdid %n net serverlistkeepfresh;30 check
  _ircn.savetmpdlgdid %n net ircop.enabled;32 check2

  _tmpdlgdel.hash %n
  if ($dialog(%n)) {
    ; fix this v--
    nvar autoupdatelinks $nro2onoff($did(%n,26).state)
    nvar reconnectonkill $nro2onoff($did(%n,28).state)
    nvar serverlistkeepfresh $nro2onoff($did(%n,31).state)

    if (($did(%n,14) isnum) && ($did(%n,14) >= 5)) nvar netsettingsexpiredays $did(%n,14)
    nvar netsettingskeep $nro2onoff($did(%n,10).state)
  }
}

alias -l _save.networksupport {
  ;load new ircd/network support on selecting them instead of having to reconnect
  ;also unloads the old one if it is no longer used by any network
  if ($hfind(tempsetup, $tab(set,ircnsetup.network, *, global, 6) , 0,w)) {
    var %a = 1, %b, %c

    while ($hfind(tempsetup, $tab(set,ircnsetup.network, *, global, 6) , %a, w) != $null) {
      set %b $ifmatch
      set %c $hget(tempsetup,%b)
      var %net = $gettok(%b,3,9)
      var %scid = $net2scid(%net)


      if ((%scid) && (%c)) {

        var %oldnet.type = $nget(%scid,networksupport.type)
        var %oldnet = $nget(%scid,networksupport)

        if (%oldnet.type == %c) { inc %a | continue }

        if (%oldnet) && ($netsup.num(%oldnet) == 1) && ($script(%oldnet $+ .nwrk))  .unload -nrs %oldnet $+ .nwrk

        if (%c == -Disabled-) { scid %scid nset networksupport  }
        elseif (%c == -Auto Detect-) { scid %scid nset networksupport |  scid %scid loadnetsupport $!curnet(noserver) }
        else scid %scid loadnetsupport %c
      }
      inc %a
    }

  }

  if ($hfind(tempsetup, $tab(set,ircnsetup.network, *, global, 13) , 0,w)) {

    var %a = 1, %b, %c

    while ($hfind(tempsetup, $tab(set,ircnsetup.network, *, global, 13) , %a, w) != $null) {
      set %b $ifmatch
      set %c $hget(tempsetup,%b)
      var %net = $gettok(%b,3,9)
      var %scid = $net2scid(%net)



      if ((%scid) && (%c)) {
        var %oldircd.type = $nget(%scid,ircdsupport.type)
        var %oldircd = $nget(%scid,ircdsupport)

        if (%oldircd.type == %c) { inc %a | continue }

        if (%oldircd) && ($ircdsup.num(%oldircd) == 1) && ($script(%oldircd $+ .ircd))  .unload -nrs %oldircd $+ .ircd

        if (%c == -Disabled-) { scid %scid nset ircdsupport }
        elseif (%c == -Auto Detect-) { scid %scid nset ircdsupport |  scid %scid  loadircdsupport $!curircd }
        else scid %scid  loadircdsupport %c
      }
      inc %a
    }
  }


}

dialog ircn.ircopperform {
  title "ircN Network Settings - IRC-OP Perform"
  size -1 -1 170 172
  option dbu
  check "Enable perform on IRC-OP", 1, 7 6 80 11
  button "Button", 2, 23 64 0 0
  text "Network:", 3, 8 22 50 11
  combo 4, 7 35 88 55, size drop
  text "Perform commands:", 5, 8 54 67 13
  edit "", 6, 7 69 158 80, multi return autohs autovs hsbar vsbar
  check "Only Send on /Oper Success", 9, 82 53 82 11

  button "&OK", 100, 90 155 35 12, default ok
  button "&Cancel", 101, 130 155 35 12, default cancel

}
on *:dialog:ircn.ircopperform:sclick:100:_save.ircopperform
on *:dialog:ircn.ircopperform:sclick:4:_ircopperform.loadnetwork $iif($did(4).sel == 1,~~Global~~,$did(4))
on 1:dialog:ircn.ircopperform:init:0:{
  var %d = $dname
  var %f = $sd(ircop-perform.ini)

  _ircn.setup.addnetcombo $dname 4 

  var %a = 1, %b
  while ($ini(%f,%a) != $null) {
    set %b $ifmatch
    if (%b == Global)       did -a %d 4 %b 
    elseif ((!$didwm(%d,4,%b)) && (%b != ~~Global~~)) {
      did -a %d 4 %b
    }

    inc %a
  }

  if ($nvar(ircop.enableperform)) did -c %d 1 1

  did $iif($nvar(ircop.performwithoutsuccess),-u,-c) %d 9 1 

  var %ln = %ircopedit.loadnetwork
  var %n = $didwm($dname, 4, %ln)
  if (%n) { 
    did -c $dname 4 %n 
    _ircopperform.loadnetwork %ln
    did -b $dname 4
  }
  else  _ircopperform.loadnetwork ~~Global~~

}
alias _ircopperform.loadnetwork {

  var %a = 1, %b, %c,  %f = $sd(ircop-perform.ini)
  var %d = ircn.ircopperform

  did -r %d 6 
  while (%a <= $ini(%f,$1,0)) {
    set %b $ini(%f,$1,%a)

    set %c $readini(%f, n, $1, %b)
    if (%c) did -i %d 6 %a %c
    inc %a
  }


}

alias _save.ircopperform {
  var %d = ircn.ircopperform
  var %n = $iif($did(%d,4).sel == 1, ~~Global~~, $did(%d,4))
  var %f = $sd(ircop-perform.ini)

  nvar ircop.enableperform $iif($did(%d,1).state,on)

  nvar ircop.performwithoutsuccess $iif(!$did(%d,9).state,on)

  if (!%n) return
  if ($isfile(%f)) remini %f %n

  var %a = 1, %b, 
  while (%a <= $did(%d,6).lines) {
    set %b $did(%d,6,%a)
    if (%b) writeini %f %n $+(n, $calc(%a - 1)) %b

    inc %a

  }


}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Auth dialog (this code is way too large)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias netauth {

  if ($istok(%ircnsetup.docked,ircnsetup.netauth,44)) return

  dlg -r ircnsetup.netauth
  dialog -rsb ircnsetup.netauth -1 -1 185 169
  did -v ircnsetup.netauth 100,101


}
dialog ircNsetup.netauth {
  title "Network Authentication"
  size -1 -1 0 0
  option dbu
  icon $gfxdir(icons\ircn.ico), 0
  text "Network:", 8, 98 3 29 10
  combo 9, 130 2 51 50, size drop
  box "Account", 1, 84 17 97 41
  text "Username:", 2, 88 29 28 10
  text "Password:", 4, 88 42 28 10
  edit "", 5, 118 40 52 12, autohs autovs
  box "Commands", 6, 3 80 178 61
  text "Auth:", 7, 8 103 45 10, right
  edit "", 10, 56 102 122 12, autohs
  text "Ghost:", 11, 8 116 45 10, right
  edit "", 12, 56 114 122 12, autohs
  combo 13, 110 87 58 50, size edit drop
  text "Preset:", 14, 78 87 28 10
  box "Settings", 15, 3 2 79 73
  check "Auth on connect", 16, 8 11 66 10
  check "Auth on request", 17, 8 21 64 10
  combo 18, 118 28 52 50, size edit drop
  button "+", 19, 172 28 7 7
  button "-", 20, 172 36 7 7
  check "Enable Ghosting", 21, 8 31 65 10
  check "Reget nick on ghost", 22, 8 41 65 10
  button "+", 3, 171 86 7 7
  button "-", 23, 171 93 7 7
  text "Request Nick:", 24, 8 128 45 10, right
  edit "", 25, 56 126 37 12, autohs
  text "Match:", 26, 95 128 20 8, right
  edit "", 27, 117 126 61 12, autohs
  button "OK", 100, 102 148 38 14, hide ok
  button "Cancel", 101, 143 148 38 14, hide cancel
  check "Always Match account ", 28, 8 50 65 13
}

on *:dialog:ircNsetup.netauth:sclick:100: _netauth.save
on *:dialog:ircNsetup.netauth:close:0:.timer 1 1 _tmpdlgdel.hash $dname
on 1:dialog:ircNsetup.netauth:sclick:16,17,21,22:{
  tmpdlgset $dname $did(9) $did(18) $did $did($did).state
  _netauth.requestedits
} 
on 1:dialog:ircNsetup.netauth:edit:5,10,12,25,27:{
  if ($did(18)) tmpdlgset $dname $did(9) $did(18) $did $did($did)
}
on 1:dialog:ircNsetup.netauth:sclick:28:{

  if ($did(18))  tmpdlgset $dname $did(9) ~global~ 28  $iif($did(28).state,$did(18))

}
on 1:dialog:ircNsetup.netauth:sclick:19:{
  if ($did(18)) {
    tmpdlggset $dname combos $addtok($tmpdlggget($dname,combos),$tab($did(9),$did(18)),44)
    tmpdlggset $dname remcombos $remtok($tmpdlggget($dname,remcombos),$tab($did(9),$did(18)),1,44)
    tmpdlgset $dname $did(9) $did(18) 10 $did(10)
    tmpdlgset $dname $did(9) $did(18) 12 $did(12)

    if (!$didwm(18,$did(18,0))) did -a $dname 18 $did(18,0)
    did -e $dname 1,2,3,4,5,6,7,10,11,12,13,14,15,16,17,19,20,21,22,23
    .timer 1 0 _netauth.updateusercombo

    did -f $dname 5
  }
}
on 1:dialog:ircNsetup.netauth:sclick:20:{
  if ($did(18)) {
    tmpdlggset $dname combos $remtok($tmpdlggget($dname,combos),$tab($did(9),$did(18)),1,44)
    tmpdlggset $dname remcombos $addtok($tmpdlggget($dname,remcombos),$tab($did(9),$did(18)),44)
    tmpdlgset $dname $did(9) $did(18) 10
    tmpdlgset $dname $did(9) $did(18) 12
    hdel -w tempsetup $tab(set,$dname,$did(9),$did(18),*)
    if ($didwm(18,$did(18,0))) did -d $dname 18 $did(18).sel
    did -i $dname 18 0
    did -b $dname 1,2,3,4,5,6,7,10,11,12,13,14,15,16,17,19,20,21,22,23,24,25,26,27

    .timer 1 0 _netauth.updateusercombo
  }
}
on 1:dialog:ircNsetup.netauth:sclick:9:{
  did -r $dname 18
  .timer 1 0 _netauth.updateusercombo
}
on 1:dialog:ircNsetup.netauth:sclick:18:{
  did -b $dname 19
  did -e $dname 1,2,3,4,5,6,7,10,11,12,13,14,15,16,17,20,21,22,23,28
  .timer 1 0 _netauth.updateusercombo
}
alias _netauth.requestedits {
  var %d = ircNsetup.netauth

  if ($nget($net2scid($nethash2set($did(%d,9))), $tab(auth, disableall))) {
    did -b %d 16,21,22,12,17,25,27,28,13,10,3,23,18,5,19,20

    return
  }

  did -e %d 3,23,18,5,19,20


  if (($did(%d,17).state == 0) || (!$didwm(%d,18,$did(%d,18)))) did -b %d 24,25,26,27
  else did -e %d 24,25,26,27
  if (($did(%d,21).state == 0) || (!$didwm(%d,18,$did(%d,18)))) did -b %d 11,12
  else did -e %d 11,12
  if ((($did(%d,16).state == 0) && ($did(%d,17).state == 0)) || (!$didwm(%d,18,$did(%d,18)))) did -b %d 7,10
  else did -e %d 7,10


  if ($nget($net2scid($nethash2set($did(%d,9))), $tab(auth, disableghosting))) did -b %d 21,22,12
  if ($nget($net2scid($nethash2set($did(%d,9))), $tab(auth, disableauthreq))) did -b %d 17,25,27

}
alias _netauth.normaldids {
  var %d = ircNsetup.netauth


  if (!$didwm(%d,18,$did(%d,18,0))) { did -b %d 1,2,3,4,5,6,7,10,11,12,13,14,15,16,17,20,21,22,23,28 | did -e %d 19 }
  else { did -e %d 1,2,3,4,5,6,7,10,11,12,13,14,15,16,17,20,21,22,23,28 | did -b %d 19 }
  .timer 1 0 _netauth.requestedits
}
on 1:dialog:ircNsetup.netauth:edit:18:{
  if (!$didwm(18,$did($did,0))) { did -b $dname 1,2,3,4,5,6,7,10,11,12,13,14,15,16,17,20,21,22,23,28 | did -e $dname 19 }
  else { did -e $dname 1,2,3,4,5,6,7,10,11,12,13,14,15,16,17,20,21,22,23,28 | did -b $dname 19 }
  .timer 1 0 _netauth.requestedits
}
on 1:dialog:ircNsetup.netauth:sclick:3:{
  if ($did(13)) {
    if ($nvar($tab(authdlg,presets,$did(13)))) {
      var %a = $input(Do you really want to overwrite preset $did(13) $+ ?,q,Overwrite?)
      if (%a == $false) return
    }
    if (!$nvar($tab(authdlg,presets,$did(13)))) did -a $dname 13 $did(13)
    nvar $tab(authdlg,presets,$did(13)) $tab($did(10),$did(12),$did(25),$did(27))
  }
}
on 1:dialog:ircNsetup.netauth:sclick:23:{
  if ($did(13)) {
    if ($nvar($tab(authdlg,presets,$did(13)))) {
      var %a = $input(Do you really want to delete preset $did(13) $+ ?,q,Overwrite?)
      if (%a == $false) return
    }
    if ($nvar($tab(authdlg,presets,$did(13)))) nvar $tab(authdlg,presets,$did(13))
    did -d $dname 13 $did(13).sel
    did -i $dname 13 0
  }
}
on 1:dialog:ircNsetup.netauth:sclick:13: _ircnsetup.netauth.loadpreset $did(13)

on 1:dialog:ircNsetup.netauth:init:0:{
  _ircn.setup.addnetcombo $dname 9 noglobal
  _netauth.updatepresets
  var %b, %c, %e, %f, %g, %a = 1
  while (%a <= $scon(0)) {
    scon %a
    ;set %b $cid $+ .ircN.Settings
    set %b $+($ncid( [ [ $cid ] $+ ] ,network.hash),.ircN.settings)
    set %c 1
    while ($hfind(%b,$tab(auth,*,*),%c,w)) {
      set %f $scid($cid).curnet
      set %e $gettok($hfind(%b,$tab(auth,*,*),%c,w),2,9)
      if (%g != $tab(%f,%e)) {
        if (%e != ~global~) {
          tmpdlggset $dname combos $addtok($tmpdlggget($dname,combos),$tab(%f,%e),44)

          tmpdlgset $dname %f %e 16 $onoff2nro($nget($net2scid(%f),$tab(auth,%e,onconnect)))
          tmpdlgset $dname %f %e 17 $onoff2nro($nget($net2scid(%f),$tab(auth,%e,onrequest)))
          tmpdlgset $dname %f %e 21 $onoff2nro($nget($net2scid(%f),$tab(auth,%e,ghost)))
          tmpdlgset $dname %f %e 22 $onoff2nro($nget($net2scid(%f),$tab(auth,%e,reget)))

          tmpdlgset $dname %f %e 5 $nget($net2scid(%f),$tab(auth,%e,passwd))
          tmpdlgset $dname %f %e 10 $nget($net2scid(%f),$tab(auth,%e,authcmd))
          tmpdlgset $dname %f %e 12 $nget($net2scid(%f),$tab(auth,%e,ghostcmd))
          tmpdlgset $dname %f %e 25 $nget($net2scid(%f),$tab(auth,%e,requestnick))
          tmpdlgset $dname %f %e 27 $nget($net2scid(%f),$tab(auth,%e,requestwc))
        }
        tmpdlgset $dname %f %e 28 $nget($net2scid(%f),$tab(auth,~global~,alwaysmatch))
      }
      set %g $tab(%f,%e)
      inc %c
    }
    inc %a
  }
  scon -r
  did -c $dname 13 1
  if ($nvar($tab(authdlg,presets,$did(13)))) {
    did -ra $dname 10 $gettok($ifmatch,1,9)
    did -ra $dname 12 $gettok($ifmatch,2,9)
  }
  did -b $dname 1,2,3,4,5,6,7,10,11,12,13,14,15,16,17,20,21,22,23,24,25,26,27,28
  _netauth.updatevars
  .timer 1 0 _netauth.updateusercombo

  if ($ismod(modernui)) {
    mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 16 0 > NOT_USED $chr(4) Sends the authentication command on sucessful connection to server.
    mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 17 0 > NOT_USED $chr(4) Sends the authentication command on request by matching nickname and string.
    mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 21 0 > NOT_USED $chr(4) Sends the ghost command when nickname is in use.
    mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 22 0 > NOT_USED $chr(4) Regains your nickname after the ghost command is sent.
    mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 28 0 > NOT_USED $chr(4) Authenticate into this account regardless of your current nickname (Only works for one account on the network at a time)


  }

}
alias _netauth.save {
  var %a, %b, %c, %d = ircNsetup.netauth
  if (!$dialog(%d)) return
  var %e, %u, %x
  set %c $tmpdlggget(%d,combos)
  set %a 1
  while ($gettok(%c,%a,44)) {
    set %b $gettok(%c,%a,44)
    set %e $gettok(%b,1,9)
    set %u $gettok(%b,2,9)
    set %x $net2scid(%e)
    nset %x $tab(auth,%u,onconnect) $nro2onoff($tmpdlgget(%d,%e,%u,16))
    nset %x $tab(auth,%u,onrequest) $nro2onoff($tmpdlgget(%d,%e,%u,17))
    nset %x $tab(auth,%u,ghost) $nro2onoff($tmpdlgget(%d,%e,%u,21))
    nset %x $tab(auth,%u,reget) $nro2onoff($tmpdlgget(%d,%e,%u,22))
    nset %x $tab(auth,%u,passwd) $tmpdlgget(%d,%e,%u,5)
    nset %x $tab(auth,%u,authcmd) $tmpdlgget(%d,%e,%u,10)
    nset %x $tab(auth,%u,ghostcmd) $tmpdlgget(%d,%e,%u,12)
    nset %x $tab(auth,%u,requestnick) $tmpdlgget(%d,%e,%u,25)
    nset %x $tab(auth,%u,requestwc) $tmpdlgget(%d,%e,%u,27)
    nset %x $tab(auth,~global~,alwaysmatch) $tmpdlgget(%d,%e,~global~,28)
    inc %a
  }

  set %c $tmpdlggget(%d,remcombos)

  set %a 1
  while ($gettok(%c,%a,44)) {
    set %b $gettok(%c,%a,44)
    set %e $gettok(%b,1,9)
    set %u $gettok(%b,2,9)
    set %x $net2scid(%e)
    ;iecho Removing  %e %u
    nset %x $tab(auth,%u,nickserv)
    nset %x $tab(auth,%u,onconnect)
    nset %x $tab(auth,%u,onrequest)
    nset %x $tab(auth,%u,ghost)
    nset %x $tab(auth,%u,reget)
    nset %x $tab(auth,%u,passwd)
    nset %x $tab(auth,%u,authcmd)
    nset %x $tab(auth,%u,ghostcmd)
    nset %x $tab(auth,%u,requestnick)
    nset %x $tab(auth,%u,requestwc)
    if ($tab(auth,~global~,alwaysmatch) == %u) nset %x $tab(auth,~global~,alwaysmatch)
    inc %a
  }

  _tmpdlgdel.hash $dname
}
alias _netauth.updatevars {
  var %d = ircNsetup.netauth
  if ($did(%d,9) == Global) return
  if (($tmpdlgget(%d,$did(%d,9),$did(%d,18),16) == $null) && ($did(%d,18))) {
    tmpdlgset %d $did(%d,9) $did(%d,18) 16 $onoff2nro($nget($net2scid($did(%d,9)),$tab(auth,$did(%d,18),onconnect)))
    tmpdlgset %d $did(%d,9) $did(%d,18) 17 $onoff2nro($nget($net2scid($did(%d,9)),$tab(auth,$did(%d,18),onrequest)))
    tmpdlgset %d $did(%d,9) $did(%d,18) 21 $onoff2nro($nget($net2scid($did(%d,9)),$tab(auth,$did(%d,18),ghost)))
    tmpdlgset %d $did(%d,9) $did(%d,18) 22 $onoff2nro($nget($net2scid($did(%d,9)),$tab(auth,$did(%d,18),reget)))

    tmpdlgset %d $did(%d,9) $did(%d,18) 5 $nget($net2scid($did(%d,9)),$tab(auth,$did(%d,18),passwd))
    tmpdlgset %d $did(%d,9) $did(%d,18) 10 $nget($net2scid($did(%d,9)),$tab(auth,$did(%d,18),authcmd))
    tmpdlgset %d $did(%d,9) $did(%d,18) 12 $nget($net2scid($did(%d,9)),$tab(auth,$did(%d,18),ghostcmd))
    tmpdlgset %d $did(%d,9) $did(%d,18) 25 $nget($net2scid($did(%d,9)),$tab(auth,$did(%d,18),requestnick))
    tmpdlgset %d $did(%d,9) $did(%d,18) 27 $nget($net2scid($did(%d,9)),$tab(auth,$did(%d,18),requestwc))
    tmpdlgset %d $did(%d,9) ~global~ 28 $nget($net2scid($did(%d,9)),$tab(auth,~global~,alwaysmatch))
  }
  .timer 1 0 _netauth.updatecommondids
}
alias _netauth.updateusercombo {
  var %a, %b, %c, %d = ircNsetup.netauth
  var %e, %u = $did(%d,18)
  if ($did(%d,9) == Global) return

  did -r %d 18

  set %c $tmpdlggget(%d,combos)

  set %a 1
  while ($gettok(%c,%a,44)) {
    set %b $gettok(%c,%a,44)
    if ($gettok(%b,1,9) == $did(%d,9)) {
      did -a %d 18 $gettok(%b,2,9)
    }
    inc %a
  }
  if (($did(%d,18,1)) && (!%u)) did -c %d 18 1
  elseif ($didwm(%d,18,%u)) did -c %d 18 $ifmatch
  .timer 1 0 _netauth.updatevars
}
alias _netauth.updatecommondids {
  var %d = ircNsetup.netauth
  var %u = $did(%d,18)

  did -r %d 5,10,12,25,27
  did -u %d 16,17,21,22,28

  if (%u) {
    if ($tmpdlgget(%d,$did(%d,9),%u,16) == 1) did -c %d 16
    if ($tmpdlgget(%d,$did(%d,9),%u,17) == 1) did -c %d 17
    if ($tmpdlgget(%d,$did(%d,9),%u,21) == 1) did -c %d 21
    if ($tmpdlgget(%d,$did(%d,9),%u,22) == 1) did -c %d 22
    if ($tmpdlgget(%d,$did(%d,9),~global~,28) == %u) did -c %d 28


    if ($tmpdlgget(%d,$did(%d,9),%u,5)) did -ra %d 5 $ifmatch
    if ($tmpdlgget(%d,$did(%d,9),%u,10)) did -ra %d 10 $ifmatch
    if ($tmpdlgget(%d,$did(%d,9),%u,12)) did -ra %d 12 $ifmatch
    if ($tmpdlgget(%d,$did(%d,9),%u,25)) did -ra %d 25 $ifmatch
    if ($tmpdlgget(%d,$did(%d,9),%u,27)) did -ra %d 27 $ifmatch
    if ($didwm(%d,18,%u)) did -c %d 18 $ifmatch

    did -c %d 10 1
    did -c %d 12 1
    did -c %d 25 1
    did -c %d 27 1
    if (!$did(%d,10)) {
      var %q = $nget($net2scid($did(%d,9)), $tab(auth, autopreset))
      if (!$nvar($tab(authdlg,presets,%q))) set %q Nickserv
      _ircnsetup.netauth.loadpreset %q
    }


  }
  if (!%q) did -i %d 13 0


  .timer 1 0 _netauth.normaldids
}
alias _netauth.updatepresets {
  var %a, %b, %d = ircNsetup.netauth
  did -r %d 13
  set %a 1
  while ($hfind(ircN,$tab(authdlg,presets,*),%a,w)) {
    set %b $hfind(ircN,$tab(authdlg,presets,*),%a,w)
    did -a %d 13 $firstcap($gettok(%b,3,9)).firstonly
    inc %a
  }
}
alias  _ircnsetup.netauth.loadpreset {
  if (!$1) return
  var %d = ircNsetup.netauth
  if ($nvar($tab(authdlg,presets,$1))) {
    did -ra %d 10 $gettok($ifmatch,1,9)
    did -ra %d 12 $gettok($ifmatch,2,9)
    did -ra %d 25 $gettok($ifmatch,3,9)
    did -ra %d 27 $gettok($ifmatch,4,9)
    tmpdlgset %d $did(%d,9) $did(%d,18) 10 $did(%d,10)
    tmpdlgset %d $did(%d,9) $did(%d,18) 12 $did(%d,12)
    tmpdlgset %d $did(%d,9) $did(%d,18) 25 $did(%d,25)
    tmpdlgset %d $did(%d,9) $did(%d,18) 27 $did(%d,27)
    did -c %d 10 1
    did -c %d 12 1
    did -c %d 25 1
    did -c %d 27 1
    ;   did -f %d 10

    var %q = $didwm(%d, 13, $1)
    if (%q) did -c %d 13 %q
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Quits dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircNsetup.editquits {
  title "ircN Quit Messages"
  size -1 -1 190 164
  option dbu
  icon $gfxdir(icons\ircn.ico), 0
  list 1, 1 1 188 120, size
  button "Delete", 2, 121 134 28 11
  button "Add", 3, 92 134 28 11
  edit "", 4, 1 121 188 12, autohs
  button "Load from text file", 5, 2 134 59 11
  button "Delete All", 6, 150 134 32 11
}

on 1:dialog:ircNsetup.editquits:init:*:_refresh.quitmsgs
on 1:dialog:ircNsetup.editquits:sclick:1:{
  if ($did(1).sel) {
    did -ra $dname 4 $did(1,$did(1).sel)
    did -c $dname 4 1
  }
}
on 1:dialog:ircNsetup.editquits:sclick:3:{
  if ($did(4)) {
    write $sd(quits.txt) $did(4)
    did -r $dname 4
    _refresh.quitmsgs
  }
}
on 1:dialog:ircNsetup.editquits:sclick:2:if ($did(1).sel) { write -dl $+ $did(1).sel $sd(quits.txt)  | _refresh.quitmsgs  }
on 1:dialog:ircNsetup.editquits:sclick:6:{
  var %a = $input(Are you sure you want to delete all of the $dialog($dname).title $+ ?,y,Delete all?)
  if (%a == $true) {
    write -c $sd(quits.txt)
    did -r $dname 1
  }
}
on 1:dialog:ircNsetup.editquits:sclick:5:{
  var %a = $sfile($txtd,Text file for $dialog($dname).title,Load), %b = 0
  if (%a) loadbuf -o $dname 1 %a
  while ($lines(%a) > %b) {
    inc %b
    write $sd(quits.txt) $read(%a,%b)
  }
}
alias -l _refresh.quitmsgs {
  var %n = ircnsetup.editquits
  did -r %n 1
  if ($isfile($sd(quits.txt))) loadbuf -o %n 1 $sd(quits.txt)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Kicks dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircNsetup.editkicks {
  title "ircN Kick Messages"
  size -1 -1 0 0
  option dbu
  icon $gfxdir(icons\ircn.ico), 0
  list 1, 1 1 188 120, size
  button "Delete", 2, 121 134 28 11
  button "Add", 3, 92 134 28 11
  edit "", 4, 1 121 188 12, autohs
  button "Load from text file", 5, 2 134 59 11
  button "Delete All", 6, 150 134 32 11
  text "Tags:", 10, 153 152 19 11, right
  button "?", 7, 174 152 12 10
}


on 1:dialog:ircNsetup.editkicks:sclick:7:.echo -q $input(Kick counter tags: [ $crlf ] [ $crlf ] <num> - number of global kicks [ $crlf ] <netnum> - number of kicks on network  [ $crlf ] <channum> - number of kicks in the current channel,oi)  
on 1:dialog:ircNsetup.editkicks:init:*:_refresh.kickmsgs
on 1:dialog:ircNsetup.editkicks:sclick:1:{
  if ($did(1).sel) {
    did -ra $dname 4 $did(1,$did(1).sel)
    did -c $dname 4 1
  }
}
on 1:dialog:ircNsetup.editkicks:sclick:3:{
  if ($did(4)) {
    write $sd(kicks.txt) $did(4)
    did -r $dname 4
    _refresh.kickmsgs
  }
}
on 1:dialog:ircNsetup.editkicks:sclick:2:if ($did(1).sel) { write -dl $+ $did(1).sel $sd(kicks.txt)  | _refresh.kickmsgs  }
on 1:dialog:ircNsetup.editkicks:sclick:6:{
  var %a = $input(Are you sure you want to delete all of the $dialog($dname).title $+ ?,y,Delete all?)
  if (%a == $true) {
    write -c $sd(kicks.txt)
    did -r $dname 1
  }
}
on 1:dialog:ircNsetup.editkicks:sclick:5:{
  var %a = $sfile($txtd,Text file for $dialog($dname).title,Load), %b = 0
  if (%a) loadbuf -o $dname 1 %a
  while ($lines(%a) > %b) {
    inc %b
    write $sd(kicks.txt) $read(%a,%b)
  }
}
alias -l _refresh.kickmsgs {
  var %n = ircnsetup.editkicks
  did -r %n 1
  if ($isfile($sd(kicks.txt))) loadbuf -o %n 1 $sd(kicks.txt)
}
;;;;;;;;;;;;;;;;;;;;;;;
;; NewServer dialog
;;;;;;;;;;;;;;;;;;;;;;;

dialog ircn.newserv {
  title "Connect to server"
  size -1 -1 211 57
  option dbu
  icon $gfxdir(icons\ircn.ico), 0
  text "Server/Group:", 4, 8 5 40 10
  text "Password:", 8, 9 72 37 12
  edit "", 9, 53 72 59 11, pass autohs
  text "Nickname:", 10, 9 108 39 10
  text "Alternative:", 11, 9 119 40 10
  text "Email Address:", 12, 9 96 43 10
  text "Full Name:", 13, 9 84 37 10
  edit "", 14, 53 84 59 11, autohs
  edit "", 15, 53 96 59 11, autohs
  edit "", 16, 53 108 59 11, autohs
  edit "", 17, 53 120 59 11, autohs
  button "&Connect", 18, 142 40 34 15, default ok
  button "&Cancel", 19, 178 40 31 15, cancel
  check "More...", 20, 4 40 31 15, push
  text "", 21, 0 0 1 1, hide
  combo 2, 54 4 69 64, size edit drop
  text ":", 3, 126 4 7 14
  combo 22, 135 4 34 35, disable size edit drop
  radio "Connect using new session window", 1, 29 19 110 10
  radio "Connect using current session window", 5, 29 28 110 10
  check "Bypass perform && autojoin", 6, 117 76 83 10
  check "Bypass services authentication", 7, 117 87 90 10
  box "", 23, 113 69 95 30
}


on 1:dialog:ircn.newserv:init:0:{
  var %n = $dname
  did -c %n 1
  var %a = 1, %b
  while (%a <= $server(0)) {
    set %b $server(%a).group
    if ((!$didwm(2,%b)) && (%b) && (%b !isnum)) did -a $dname 2 $server(%a).group
    inc %a
  }
  did -ra %n 14 $fullname
  did -ra %n 15 $email
  did -ra %n 16 $mnick
  did -ra %n 17 $anick

  if ($server($server).group) did -o %n 2 0 $ifmatch
  elseif ($server) {
    did -e %n 22
    did -o %n 2 0 $ifmatch
    _ircn.newserv.loadports $ifmatch
  }

}
on *:DIALOG:ircn.newserv:sclick:20:{
  if ($did($did).state) dialog -sb $dname -1 -1 211 137
  else dialog -sb $dname -1 -1 211 62
}
on *:DIALOG:ircn.newserv:close:0:{
  .timerircnnewserv.* off
}
on *:DIALOG:ircn.newserv:edit:14,15,16,17:{
  var %d = $dname
  .timerircnnewserv. $+ $did off
  if ($remove($did($did),$chr(32)) != $null) return
  ;put their info back in if its empty
  if ($did == 14) .timerircnnewserv. $+ $did 1 1 if (! $+ $ $+ remove( $ $+ did( $+ %d , 14), $ $+ chr(32))) did -ra %d 14 $ $+ fullname
  if ($did == 15) .timerircnnewserv. $+ $did 1 1 if (! $+ $ $+ remove( $ $+ did( $+ %d , 15), $ $+ chr(32))) did -ra %d 15 $ $+ email
  if ($did == 16) .timerircnnewserv. $+ $did 1 1 if (! $+ $ $+ remove( $ $+ did( $+ %d , 16), $ $+ chr(32))) did -ra %d 16 $ $+ mnick
  if ($did == 17) .timerircnnewserv. $+ $did 1 1 if (! $+ $ $+ remove( $ $+ did( $+ %d , 17), $ $+ chr(32))) did -ra %d 17 $ $+ anick
}
on *:DIALOG:ircn.newserv:edit:2:{
  if ($did(2) == $null) { did -c $dname 2 1 | return }
  if ($didwm(2,$did(2))) {
    did -c $dname 2 $ifmatch
    did -r $dname 22
    did -b $dname 22
    return
  } 
  did -e $dname 22
  _ircn.newserv.loadports $did(2)
}
on *:dialog:ircn.newserv:sclick:2:{
  did -r $dname 22
  did -b $dname 22
}
alias _ircn.newserv.loadports  {
  var %n = ircn.newserv
  if (!$1) return
  did -r %n 22 
  var %p = $server($1).port
  var %pass = $server($1).pass
  did -ra %n 9 %pass

  if (%p) {
    var %a = 1, %b
    while ($gettok(%p,%a,44) != $null) {
      set %b $ifmatch
      if (*-* iswm %b) {
        var %c = $gettok(%b,1,45) , %d = $iifelse($gettok(%b,2,45),$gettok(%b,1,45))
        while (%c <= %d) {
          did -a %n 22 %c
          inc %c
        }
        did -c %n 22  1
      }
      else { 
        did -a %n 22 %b
        did -c %n 22 1
      }
      inc %a
    }
  }
  else { did -ra %n 22 6667 | did -c %n 22 1 }

}

on 1:dialog:ircn.newserv:sclick:18:{
  var %flag = -i $did(16) $did(17) $did(15) $did(14)
  server $iif(($did(1).state || $did(6).state),- $+ $iif($did(1).state,m) $+ $iif($did(6).state,po)) $did(2) $did(22) $did(9) %flag

  ; fix this

  if ($did(6).state) .timer 1 1 scon $ $+ scon(0) ncid bypass_autojoin $true
  if ($did(7).state) .timer 1 1 scon $ $+ scon(0) ncid bypass_serviceauth $true
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; User Add/Edit dialog   (this dialog code is WAY too large, it should be possible to make it more efficient)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias adduser.returnotherflags return $removecs($1-,a,b,c,d,f,h,g,i,j,k,m,n,o,p,r,s,v,x)
alias adduser.returnotherchanflags return $removecs($1-,a,d,f,h,g,k,o,v)
alias -l ircn.usrdlg.update {
  if ($ulinfo($1,user) == $null) return
  var %a, %b, %n = ircn.adduser
  did -ra %n 117 $1
  set %a 1
  while ($gettok($ulinfo($1,hosts),%a,32) != $null) {
    did -a %n 95 $ifmatch
    inc %a
  }
  did -c %n 95 1
  ;did -ra %n 99 $ulinfo($1,pass)
  ; did -ra %n 102 $ulinfo($1,botpass)
  did -ra %n 99 $ulinfo($1,pass)
  did -ra %n 102 $botpass($1)

  var %z = $ulinfo($1,flags) , %y = did -c %n
  if (a isincs %z) %y 76
  if (b isincs %z) %y 77
  if (c isincs %z) %y 78
  if (d isincs %z) %y 79
  if (f isincs %z) %y 80
  if (h isincs %z) %y 4
  if (g isincs %z) %y 81
  if (i isincs %z) %y 82
  if (j isincs %z) %y 83
  if (k isincs %z) %y 84
  if (m isincs %z) %y 85
  if (n isincs %z) %y 86
  if (o isincs %z) %y 87
  if (p isincs %z) %y 88
  if (r isincs %z) %y 89
  if (s isincs %z) %y 90
  if (v isincs %z) %y 91
  if (x isincs %z) %y 92
  if ($len($adduser.returnotherflags(%z)) > 0) did -ra %n 94 $adduser.returnotherflags(%z)
  set %a 1
  while ($gettok($ulinfo($1,chans),%a,44)) {
    set %b $ifmatch
    did -a %n 53 %b
    did -a %n 107 %b
    tmpdlggset %n channels $addtok($tmpdlggget(%n,channels),%b,44)
    tmpdlggset %n $tab(infoline,channels) $addtok($tmpdlgget(%n,$tab(infoline,channels)),%b,44)
    tmpdlgset %n global %b flags $ulinfo($1,flags,%b)
    if ($ulinfo($1,info)) tmpdlggset %n infoline $ulinfo($1,info)
    if ($ulinfo($1,info,%b)) tmpdlgset %n global %b infoline $ulinfo($1,info,%b)
    inc %a
  }
  ;did -c %n 53 1

  did -ra %n 111 $ulinfo($1,info)
}
dialog ircn.adduser {
  title "Add/Edit User"
  size -1 -1 239 205
  option dbu
  icon $gfxdir(icons\ircn.ico), 0
  box "Hostmasks", 2, 2 24 82 36
  box "Passwords", 1, 2 62 82 62
  box "Info Lines", 3, 2 125 82 76
  tab "Global Flags", 50, 86 4 146 175
  check "+a: Auto-Op", 76, 103 36 54 8, tab 50
  check "+b: Bot", 77, 103 45 54 8, tab 50
  check "+c: Accept Chats", 78, 103 54 59 8, tab 50
  check "+d: Auto-Deop", 79, 103 63 58 8, tab 50
  check "+f: Protect", 80, 103 72 54 8, tab 50
  check "+g: Get Ops", 81, 103 81 54 8, tab 50
  check "+i: ircN bot", 82, 103 99 54 8, tab 50
  check "+j: File Area Janitor", 83, 103 108 69 8, tab 50
  check "+k: Auto-Kick", 84, 103 117 54 8, tab 50
  check "+m: Master", 85, 103 126 54 8, tab 50
  check "+n: Owner", 86, 103 135 54 8, tab 50
  check "+o: Op", 87, 103 144 54 8, tab 50
  check "+p: Partyline", 88, 103 153 54 8, tab 50
  check "+r: Remote Control", 89, 103 162 71 8, tab 50
  check "+s: Accept Sends", 90, 165 36 63 8, tab 50
  check "+v: Auto-Voice", 91, 165 45 61 8, tab 50
  check "+x: BitchX Bot", 92, 165 54 61 8, tab 50
  text "Other:", 93, 168 74 16 8, tab 50
  edit "", 94, 185 73 36 11, tab 50 autohs
  check "+h: Auto-Halfop", 4, 103 90 54 8, tab 50
  tab "Channel Flags", 51
  combo 53, 123 23 44 64, tab 51 edit drop
  button "Add", 54, 171 23 16 10, tab 51
  button "Remove", 55, 191 23 26 10, tab 51
  check "+d: Auto-Deop", 58, 103 45 54 8, tab 51
  check "+f: Protect", 59, 103 54 54 8, tab 51
  check "+g: Get Ops", 60, 103 63 54 8, tab 51
  check "+k: Auto-Kick", 63, 103 81 54 8, tab 51
  check "+o: Op", 66, 103 90 54 8, tab 51
  check "+v: Auto-Voice", 70, 103 99 54 8, tab 51
  text "Other:", 72, 115 111 16 8, tab 51
  edit "", 73, 134 109 36 11, tab 51 autohs
  check "+a: Auto-Op", 74, 103 36 54 8, tab 51
  text "channel:", 75, 100 24 22 10, tab 51
  check "+h: Auto-Halfop", 5, 103 72 59 8, tab 51
  combo 95, 5 33 73 51, size edit drop
  button "Add", 96, 5 46 33 10
  button "Remove", 97, 42 46 33 10
  text "User Password:", 98, 6 72 48 9
  edit "", 99, 49 70 31 11, pass autohs
  button "Update User Password", 100, 6 83 71 11
  text "Bot Password:", 101, 6 97 48 9
  edit "", 102, 49 95 31 11, pass autohs
  button "Update Bot Password", 103, 6 108 71 11
  radio "Global", 104, 5 136 30 10
  radio "Channel", 105, 41 136 30 10
  text "Channel:", 106, 7 148 27 11
  combo 107, 34 146 44 15, size edit drop
  button "Add", 108, 24 161 26 10
  button "Remove", 109, 51 161 26 10
  text "Infoline:", 110, 6 174 27 11
  edit "", 111, 32 173 46 11, autohs
  button "Update Info Line", 112, 25 188 52 10
  button "&OK", 113, 155 186 38 14, ok
  button "Delete user", 114, 87 186 38 14
  button "&Cancel", 115, 195 186 38 14, cancel
  box "User Name", 116, 2 1 82 23
  edit "", 117, 5 9 74 11, autohs
  text "", 120, 38 0 1 1, hide
}

alias adduserdlg {
  if ($dialog(ircn.adduser)) {
    var %a = $input(User $did(ircn.adduser,120) window is already open! $crlf $+ Close the old window and try again!,w,Window already open!)
    return
  }
  dlg ircn.adduser
  did -ra ircn.adduser 120 Add
  did -b ircn.adduser 100,103,112,114
  if ($1) {
    ircn.usrdlg.update $1
  }
}
alias edituserdlg {
  if ($dialog(ircn.adduser)) {
    var %a = $input(User $did(ircn.adduser,120) window is already open! $crlf $+ Close the old window and try again!,w,Window already open!)
    return
  }
  dlg ircn.adduser
  did -ra ircn.adduser 120 Edit
  did -b ircn.adduser 117
  if ($1) {
    if ($ulinfo($1,user) == $null) {
      if ($usr($1)) iecho Can't find $hc($1) on userlist, try $hc($usr($1)) instead.
      else iecho Can't find $hc($1) on userlist.
      return
    }
    ircn.usrdlg.update $1
  }
}
alias adduser.disablechanflags {
  var %d = ircn.adduser 
  did -b %d 55
  did -b %d 74
  did -b %d 58
  did -b %d 59
  did -b %d 60
  did -b %d 63
  did -b %d 66
  did -b %d 70
  did -b %d 73
  did -b %d 5
}
alias adduser.enablechanflags {
  var %d = ircn.adduser 
  did -e %d 55
  did -e %d 74
  did -e %d 58
  did -e %d 59
  did -e %d 60
  did -e %d 63
  did -e %d 66
  did -e %d 70
  did -e %d 73
  did -e %d 5
}
alias adduser.disablechaninfo1 {
  var %d = ircn.adduser 
  did -b %d 107
  did -b %d 108
  did -b %d 109
}
alias adduser.enablechaninfo1 {
  var %d = ircn.adduser 
  did -e %d 107
  did -e %d 108
  did -e %d 109
}
alias adduser.disablechaninfo2 {
  var %d = ircn.adduser
  did -b %d 109
  did -b %d 111
  did -b %d 112
}
alias adduser.enablechaninfo2 {
  var %d = ircn.adduser
  did -e %d 109
  did -e %d 111
  did -e %d 112
}
on 1:dialog:ircn.adduser:sclick:114:{
  if ($input(Are you sure you want to delete user $did(117))) {
    remuser $did(117)
    dialog -c ircn.adduser
  }
}
on 1:dialog:ircn.adduser:close:0:{
  _tmpdlgdel.hash $dname
  _userlistdlg.refresh
}
on 1:dialog:ircn.adduser:init:0:{
  _tmpdlg.hashopen
  did -c ircn.adduser 104
  adduser.disablechanflags
  adduser.disablechaninfo1
}
on 1:dialog:ircn.adduser:sclick:96:{
  var %d = ircn.adduser
  did -a %d 95 $did(%d,95,0)
  tmpdlggset %d $tab(new,hostmasks) $addtok($tmpdlggget(%d,$tab(new,hostmasks)),$did(%d,95,0),44)
  did -i %d 95 0
}
on 1:dialog:ircn.adduser:sclick:97:{
  var %d = ircn.adduser
  tmpdlggset %d $tab(remove,hostmasks)  $addtok($tmpdlggget(%d,$tab(remove,hostmasks)),$did(%d,95,0),44)
  did -d %d 95 $did(%d,95).sel
  did -d %d 95 0
}
alias _updatedlg.adduserchans {
  var %d = ircn.adduser
  var %a = 1
  var %b = $did(%d,53,0)
  did -r %d 53
  while ($gettok($tmpdlggget(%d,channels),%a,44)) {
    did -a %d 53 $gettok($tmpdlggget(%d,channels),%a,44)
    ;if (%b == $gettok($tmpdlggget(%d,channels),%a,44)) did -i %d 53 0 %b
    ;else set %b
    inc %a
  }
  did -c %d 53 $didwm(%d,53,%b)
}
on 1:dialog:ircn.adduser:sclick:54:{
  var %d = ircn.adduser
  var %b = $did(%d,53,0)
  tmpdlggset %d channels $addtok($tmpdlggget(%d,channels),$did(%d,53,0),44)
  .timer 1 0 _updatedlg.adduserchans %b
  .timer 1 0 _update.adduserflags
  ;did -i %d 53 0 %b
}
on 1:dialog:ircn.adduser:sclick:55:{
  var %d = ircn.adduser
  tmpdlggset %d channels $remtok($tmpdlggget(%d,channels),$did(%d,53,0),1,44)
  tmpdlggset %d $tab(remove,channels) $addtok($tmpdlggget(%d,$tab(remove,channels)),$did(%d,53,0),44)
  .timer 1 0 _updatedlg.adduserchans
  .timer 1 0 _update.adduserflags
  did -i %d 53 0
}
on 1:dialog:ircn.adduser:edit:53:_update.adduserflags
on 1:dialog:ircn.adduser:sclick:53:.timer 1 0 _update.adduserflags
alias _update.adduserflags {
  var %d = ircn.adduser
  did -u %d 58
  did -u %d 59
  did -u %d 60
  did -u %d 63
  did -u %d 66
  did -u %d 70
  did -u %d 74
  did -r %d 73
  if (($did(%d,53)) && ($didwm(%d,53,$did(%d,53)))) {
    if (d isincs $tmpdlgget(%d,global,$did(%d,53),flags)) did -c %d 58
    if (f isincs $tmpdlgget(%d,global,$did(%d,53),flags)) did -c %d 59
    if (g isincs $tmpdlgget(%d,global,$did(%d,53),flags)) did -c %d 60
    if (k isincs $tmpdlgget(%d,global,$did(%d,53),flags)) did -c %d 63
    if (o isincs $tmpdlgget(%d,global,$did(%d,53),flags)) did -c %d 66
    if (v isincs $tmpdlgget(%d,global,$did(%d,53),flags)) did -c %d 70
    if (a isincs $tmpdlgget(%d,global,$did(%d,53),flags)) did -c %d 74
    if (h isincs $tmpdlgget(%d,global,$did(%d,53),flags)) did -c %d 5
    did -a %d 73 $adduser.returnotherchanflags($tmpdlgget(%d,global,$did(%d,53),flags))
    adduser.enablechanflags
  }
  else adduser.disablechanflags
}
on 1:dialog:ircn.adduser:sclick:58,59,60,63,66,70,74:_save.adduserchanflags
on 1:dialog:ircn.adduser:sclick:104,105:{ 
  if ($did == 104) adduser.disablechaninfo1
  else { 
    adduser.enablechaninfo1
    if ($did(107).lines > 0) { did -c $dname 107 1 | adduser.enablechaninfo2 }
    else adduser.disablechaninfo2
    ;did -ra $dname 111 $ulinfo($1,info,$did(107))
  }
  .timer 1 0 _updatedlg.adduserinfol 
}
on 1:dialog:ircn.adduser:edit,sclick:107:{
  if ($didwm($dname,107,$did(107))) {
    adduser.enablechaninfo2
    .timer 1 0 _updatedlg.adduserinfol
  }
  else adduser.disablechaninfo2
}
alias _updatedlg.adduserinfol {
  var %d = ircn.adduser
  if (($did(%d,105).state == 1) && ($tmpdlgget(%d,global,$did(%d,107),infoline))) did -ra %d 111 $tmpdlgget(%d,global,$did(%d,107),infoline)
  elseif (($did(%d,104).state == 1) && ($tmpdlggget(%d,infoline))) did -ra %d 111 $tmpdlggget(%d,infoline)
  else did -r %d 111
}
on 1:dialog:ircn.adduser:edit:111:{
  if ($did(104).state == 1) tmpdlggset $dname infoline $did(111)
  if (($did(105).state == 1) && ($did(107))) tmpdlgset $dname global $did(107) infoline $did(111)
}
alias _updatedlg.adduserinfolchans {
  var %d = ircn.adduser
  var %a = 1
  did -r %d 107
  while ($gettok($tmpdlggget(%d,$tab(infoline,channels)),%a,44)) {
    did -a %d 107 $gettok($tmpdlggget(%d,$tab(infoline,channels)),%a,44)
    inc %a
  }
}
on 1:dialog:ircn.adduser:sclick:108:{
  var %d = ircn.adduser
  var %b = $did(%d,107,0)
  tmpdlggset %d $tab(infoline,channels) $addtok($tmpdlggget(%d,$tab(infoline,channels)),$did(%d,107,0),44)
  _updatedlg.adduserinfolchans
  did -i %d 107 0 %b
  did -r %d 111
  adduser.enablechaninfo2
}
on 1:dialog:ircn.adduser:sclick:109:{
  var %d = ircn.adduser
  tmpdlggset %d $tab(infoline,channels) $remtok($tmpdlggget(%d,$tab(infoline,channels)),$did(%d,107,0),44)
  tmpdlggset %d $tab(infoline,remove,channels) $addtok($tmpdlggget(%d,$tab(infoline,remove,channels)),$did(%d,107,0),44)
  _updatedlg.adduserinfolchans
  did -i %d 107 0
  did -r %d 111
  adduser.disablechaninfo2
}
alias _save.adduserchanflags {
  var %d = ircn.adduser
  if ($did(%d,53)) {
    tmpdlgset %d global $did(%d,53) flags $iif($did(%d,74).state == 1,a) $+ $iif($did(%d,58).state == 1,d) $+ $iif($did(%d,59).state == 1,f) $+ $iif($did(%d,60).state == 1,g) $+ $iif($did(%d,5).state == 1,h) $+ $iif($did(%d,63).state == 1,k) $+ $iif($did(%d,66).state == 1,o) $+ $iif($did(%d,70).state == 1,v) $+ $did(%d,73)
  }
}
on 1:dialog:ircn.adduser:edit:73:_save.adduserchanflags
on 1:dialog:ircn.adduser:sclick:113:{
  if (($usrh($did(95,1))) && ($did(120) == Add)) { iecho That hostmask  is already added for another user! | halt }
  _save.userlist
}
on 1:dialog:ircn.adduser:sclick:100:chpass $did(117) $did(99)
on 1:dialog:ircn.adduser:sclick:103:chbotpass $did(117) $did(102)
alias _save.userlist {
  var %d = ircn.adduser

  if (!$dialog(%d)) return

  var %verbose = off
  if (($did(%d,117)) && ($did(%d,95,1))) {
    if (($ulinfo($1,user)) && ($did(%d,120) == Add)) { iecho Error! User  $hc($did(%d,117)) already exists! | halt }
    var %a = 1
    var %t
    var %g
    set %g $iif($did(%d,76).state == 1,a) $+ $iif($did(%d,77).state  == 1,b) $+ $iif($did(%d,78).state == 1,c)  $+ $iif($did(%d,79).state == 1,d) $+ $iif($did(%d,80).state == 1,f) $+ $iif($did(%d,81).state == 1,g) $+ $iif($did(%d,4).state == 1,h) $+ $iif($did(%d,82).state  == 1,i) $+ $iif($did(%d,83).state == 1,j)  $+ $iif($did(%d,84).state == 1,k) $+ $iif($did(%d,85).state == 1,m) $+ $iif($did(%d,86).state == 1,n) $+ $iif($did(%d,87).state  == 1,o) $+ $iif($did(%d,88).state == 1,p)  $+ $iif($did(%d,89).state == 1,r) $+ $iif($did(%d,90).state == 1,s) $+ $iif($did(%d,91).state == 1,v) $+ $iif($did(%d,92).state  == 1,x) $+ $did(%d,94)
    if (($did(%d,77).state == 0) && ($did(%d,120) == Add)) { $iif(%verbose  != on,.) $+ adduser $did(%d,117) $did(%d,95,1) | chpass $did(%d,117)  $did(%d,99) }
    elseif ($did(%d,120) == Add) $iif(%verbose != on,.) $+ addbot  $did(%d,117) $did(%d,95,1) $did(%d,102)

    if ($did(%d,120) == Edit) {
      set %a 1
      while ($gettok($tmpdlggget(%d,$tab(remove,hostmasks)),%a,44)) {
        $iif(%verbose != on,.) $+  remhost $did(%d,117)  $gettok($tmpdlggget(%d,$tab(remove,hostmasks)),%a,44)
        inc %a
      }
      set %a 1
      while ($gettok($tmpdlggget(%d,$tab(remove,channels)),%a,44)) {
        ;$replace($flagconv($ulinfo($did(%d,117),flags,$ifmatch)),+,-)  
        $iif(%verbose != on,.) $+  remchan $did(%d,117)  $gettok($tmpdlggget(%d,$tab(remove,channels)),%a,44)
        inc %a
      }
      set %a 1
      while  ($gettok($tmpdlggget(%d,$tab(infoline,remove,channels)),%a,44)) {
        $iif(%verbose != on,.) $+  chinfo $did(%d,117) $ifmatch none
        inc %a
      }
      set %a 1
    }
    set %a 1
    while ($gettok($tmpdlggget(%d,$tab(new,hostmasks)),%a,44)) {
      if (($did(%d,120) == Edit) || (%a > 1)) addhost $did(%d,117)  $gettok($tmpdlggget(%d,$tab(new,hostmasks)),%a,44)
      inc %a
    }

    ; $iif(%verbose != on,.) $+ chattr $did(%d,117) %g
    ulwrite $did(%d,117) flags - %g
    if (%verbose == on) iecho Global flags for $hc($did(%d,117)) are now $hc($iif(%g,%g,<NULL>))

    ; if ($tmpdlggget(%d, global, global, channels)) iecho ulwrite $did(%d,117) chans $ifmatch

    set %a 1
    while ($gettok($tmpdlggget(%d, channels),%a,44)) {
      var %t
      set %t  $tmpdlgget(%d,global,$gettok($tmpdlggget(%d,channels),%a,44),flags)
      ;if (%t) $iif(%verbose != on,.) $+ chattr $did(%d,117) %t  $gettok($tmpdlggget(%d,channels),%a,44)
      if (%t) { 
        $iif(%verbose != on,.) $+  addchan $did(%d,117) $gettok($tmpdlggget(%d,channels),%a,44)
        ulwrite $did(%d,117) flags $gettok($tmpdlggget(%d,channels),%a,44) %t 
        if (%verbose == on) { 
          iecho Channel flags for $hc($did(%d,117)) in $sc($gettok($tmpdlggget(%d,channels),%a,44)) are now $hc($iif(%t,%t,<NULL>)) 
        } 
      }
      else chattr $did(%d,117) $replace($flagconv($ulinfo($did(%d,117),flags,$gettok($tmpdlggget(%d,channels),%a,44))),+,-) $gettok($tmpdlggget(%d,channels),%a,44)
      inc %a
    }
    if ($tmpdlggget(%d,infoline)) $iif(%verbose != on,.) $+ chinfo  $did(%d,117) $tmpdlggget(%d,infoline)
    elseif ($did(%d,120) == Edit) $iif(%verbose != on,.) $+ chinfo  $did(%d,117) none
    set %a 1
    while ($gettok($tmpdlggget(%d,$tab(infoline,channels)),%a,44)) {
      var %t
      set %t  $tmpdlgget(%d,global,$gettok($tmpdlggget(%d,$tab(infoline,channels)),%a,44),infoline)
      if ((%t != $null) &&  ($istok($ulinfo($did(%d,117),chans),$gettok($tmpdlggget(%d,$tab(infoline,channels)),%a,44),44)  == $true)) {
        $iif(%verbose != on,.) $+ chinfo $did(%d,117)  $gettok($tmpdlggget(%d,$tab(infoline,channels)),%a,44) %t
      }
      elseif (%t) { 
        $iif(%verbose != on,.) $+ addchan $did(%d,117)  $gettok($tmpdlggget(%d,$tab(infoline,channels)),%a,44) 
        $iif(%verbose !=  on,.) $+ chinfo $did(%d,117)  $gettok($tmpdlggget(%d,$tab(infoline,channels)),%a,44) %t
      }
      inc %a
    }
    colupdt2 $did(%d,117) 
  }
  else { iecho add username and hostmask | halt }
}
alias flagconv {
  if (!$1) return
  var %b = $1
  var %a = $len(%b)
  while (%a > 0) {
    set %b $left(%b,$calc(%a - 1)) $+ + $+ $iif($calc(1 - %a) < 0,$right(%b,$calc(1 - %a)),%b)
    dec %a
  }
  return %b
}
on 1:dialog:ircn.adduser:sclick:112:{
  if ($did(104).state == 1) chinfo $did(117) $iif($did(111),$did(111),none)
  elseif ($did(107)) chinfo $did(117) $did(107) $iif($did(111),$did(111),none)
  else var %a = $input(No channel selected! $crlf $+ Please select a channel before trying to add or remove a channel infoline!,w,No channel selected!)
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; /iignore dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias iignore {
  if (!$1) { iecho Syntax /iignore <nick|address> | return }
  var %a = 0, %b = $iif($chr(64) isin $1,$1,$ial($1).nick), %c, %d = ircN.ignore, %e, %f
  dlg %d
  dialog -t %d Ignore: $1
  if (!$comchan(%b,0)) && ($chr(64) !isin %b) {
    did -a %d 2 $1 $+ !*@*
    did -c %d 2 1
    return
  }
  if ($chr(64) !isin %b) did -a %d 2 %b $+ !*@*
  did -a %d 2 $gettok($mask($address(%b,0),3),1,64) $+ @*
  while (%a < 20) {
    if ($chr(64) isin %b) set %c $mask(%b,%a)
    else set %c $mask($address(%b,0),%a)
    set %e 0
    set %f 0
    while ($did(%d,2).lines > %e) {
      inc %e
      did -c %d 2 %e
      if ($did(%d,2).seltext == %c) inc %f
    }
    if (!%f) did -a %d 2 %c
    inc %a
  }
  did -c %d 2 1
}
dialog ircN.ignore {
  title ""
  icon $gfxdir(icons\ircn.ico), 0
  size -1 -1 148 134
  option dbu
  text "Nick/Address to ignore:", 1, 1 2 146 8, center
  combo 2, 2 10 144 150, size edit drop
  box "Ignore:", 3, 1 45 145 73
  check "private messages", 4, 5 64 55 10
  check "channel messages", 5, 5 74 55 10
  check "notices", 6, 5 84 55 10
  check "ctcps", 7, 90 84 55 10
  check "invites", 8, 90 64 55 10
  check "control codes", 9, 90 54 55 10
  check "dccs", 10, 90 74 55 10
  check "All", 11, 5 54 50 10
  text "Network:", 12, 64 31 25 8
  combo 13, 90 30 56 150, size drop
  check "Remove in:", 14, 37 105 38 10
  combo 15, 78 105 26 150, disable size drop edit
  combo 16, 108 105 36 150, disable size drop
  button "Cancel", 17, 110 121 37 12, cancel
  button "OK", 18, 70 121 37 12, default ok
}
on 1:DIALOG:ircN.ignore:init:*:{
  var %d = $dname
  _ircn.setup.addnetcombo %d 13 global
  did -a %d 15 1
  did -a %d 15 5
  did -a %d 15 10
  did -a %d 15 15
  did -a %d 15 30
  did -a %d 15 45
  did -a %d 15 60
  did -a %d 15 120
  did -a %d 15 360
  did -a %d 15 720
  did -a %d 15 1440
  did -a %d 16 seconds
  did -a %d 16 minutes
  did -c %d 11,13 1
  did -c %d 15,16 2
  did -b %d 4,5,6,7,8,9,10
  did -c %d 4,5,6,7,8,9,10
}
on 1:DIALOG:ircN.ignore:sclick:*:{
  var %d = $dname
  if ($did(13).sel == 2) did -c %d 13 1
  if ($did == 11) {
    if ($did(11).state) did -cb %d 4,5,6,7,8,9,10
    else did -eu %d 4,5,6,7,8,9,10
  }
  if ($did == 14) {
    if ($did(14).state) did -e %d 15,16
    else did -b %d 15,16
  }
  if ($did == 18) {
    var %f, %t = $iif($did(16).seltext == minutes,$calc($did(15) * 60),$did(15))
    if ($did(11).state) set %f pcntikd
    if ($did(4).state) set %f p
    if ($did(5).state) set %f %f $+ c
    if ($did(6).state) set %f %f $+ n
    if ($did(7).state) set %f %f $+ t
    if ($did(8).state) set %f %f $+ i
    if ($did(9).state) set %f %f $+ k
    if ($did(10).state) set %f %f $+ d
    if (%f) {
      .ignore - $+ %f $+ $iif($did(13).sel == 1,w) $+ $iif($did(14).state,u $+ %t) $did(2) $iif($did(13).sel != 1,$did(13))
      iecho Ignoring $hc($did(2)) $iif($did(14).state,for $sc($did(15)) $did(16))
    }
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  /bban dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;fix this shit
alias bban {
  if (!$1) { iecho Syntax /bban <nick|address> | return }
  var %a = 0, %b = $iif($chr(64) isin $1,$1,$ial($1).nick), %c, %d = ircN.ban, %e, %f
  dlg %d
  dialog -t %d Ban: $1
  if (!$comchan(%b,0)) && ($chr(64) !isin %b) {
    did -a %d 1 $1 $+ !*@*
    ;  did -a %d 1 $1
    did -c %d 1 1
    return
  }
  if ($chr(64) !isin %b) did -a %d 1 %b $+ !*@*
  did -a %d 1 $gettok($mask($address(%b,0),3),1,64) $+ @*
  while (%a < 20) {
    if ($chr(64) isin %b) set %c $mask(%b,%a)
    else set %c $mask($address(%b,0),%a)
    set %e 0
    set %f 0
    while ($did(%d,1).lines > %e) {
      inc %e
      did -c %d 1 %e
      if ($did(%d,1).seltext == %c) inc %f
    }
    if (!%f) did -a %d 1 %c
    inc %a
  }
  did -c %d 1 1
}
dialog ircN.ban {
  title ""
  icon $gfxdir(icons\ircn.ico), 0
  size -1 -1 154 134
  option dbu
  combo 1, 2 11 150 150, size drop
  text "Nick/Address to ban:", 2, 2 2 150 8, center
  combo 3, 92 29 60 150, size drop
  text "Channel:", 4, 64 30 25 8, right
  box "Settings:", 5, 2 42 150 74
  check "Permanent ban", 6, 5 102 46 10
  check "Sticky Ban", 7, 69 102 36 10, disable
  check "Kick", 8, 6 54 21 10
  check "Remove in:", 9, 5 84 38 10
  combo 10, 45 84 26 150, disable size drop edit
  combo 11, 72 84 36 150, disable size drop
  button "Banlist", 12, 110 102 37 10
  button "Cancel", 13, 114 120 37 12, cancel
  button "OK", 14, 76 120 37 12, default ok
  combo 15, 5 65 144 150, sort size edit drop
  text "Reason:", 16, 65 55 20 8
}
on 1:DIALOG:ircN.ban:init:*:{
  var %d = $dname
  ;  _ircn.setup.addnetcombo %d 3 global
  if ($lines($sd(kicks.txt))) {
    did -a %d 15 <Random> 
    loadbuf -o %d 15 $sd(kicks.txt)
  }
  did -a %d 3 ALL
  did -a %d 3 $str(-,40)
  var %a = 1
  while ($chan(%a)) {
    did -a %d 3 $ifmatch
    inc %a
  }
  did -a %d 10 1
  did -a %d 10 5
  did -a %d 10 10
  did -a %d 10 15
  did -a %d 10 30
  did -a %d 10 45
  did -a %d 10 60
  did -a %d 10 120
  did -a %d 10 360
  did -a %d 10 720
  did -a %d 10 1440
  did -a %d 11 seconds
  did -a %d 11 minutes
  did -c %d 1,3,8,15 1
  did -c %d 10,11 2
  if ($active ischan) did -c %d 3 $didwm(3,$active,1)
}
on 1:DIALOG:ircN.ban:sclick:*:{
  var %d = $dname
  if ($did == 3) && ($did(3).sel == 2) did -c %d 3 1
  if ($did == 6) {
    if ($did(6).state == 1) { did -e %d 7 | did -b %d 9,10,11 | did -u %d 9 }
    else { did -b %d 7 | did -e %d 9 }
  }
  if ($did == 8) {
    if ($did(8).state == 1) did -e %d 15,16
    else did -b %d 15,16
  }
  if ($did == 9) {
    if ($did(9).state == 1) { did -e %d 10,11 | did -ub %d 5,6,7 }
    else { did -b %d 10,11 | did -e %d 5,6 }
  }
  if ($did == 12) banlist
  if ($did == 14) {
    var %b = $did(1), %f, %n = $ial(%b,1).nick, %t = $iif($did(11) == minutes,$calc($did(10) * 60),$did(10)), %r = $iif($did(15) == <random>,$read($sd(kicks.txt)),$did(15))
    if ($did(9).state) set %f %f $+ -u $+ %t
    if ($did(6).state) addban $iif($chr(64) isin %b,$did(1).seltext,%b $+ !*@*) $did(3) %r
    else {
      if ($did(3) == all) {
        var %a = 0, %c
        while ($gettok($mychans,0,44) > %a) {
          inc %a
          set %c $gettok($mychans,%a,44)
          if ($me isop %c) {
            ban %f %c %b
            if (%n ison %c) && ($did(8).state) kick %c %n %r
          }
        }
      }
      else {
        ban %f $did(3) %b
        if (%n ison $did(3)) && ($did(8).state) kick $did(3) %n %r
      }
    }
    if ($did(7).state) stickban $iif($chr(64) isin %b,%b,%b $+ !*@*)
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Log dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias logsettings {
  dlg -r ircNsetup.logs
  dialog -rsb ircnsetup.logs -1 -1 133 117

  did -v ircnsetup.logs 98,99
}

dialog ircnsetup.logs {
  title "ircN Logging Settings"
  size -1 -1 184 141
  option dbu

  tab "Channel Logs", 1, 4 6 177 112
  box "Strip Channel Events", 2, 10 27 113 59, tab 1
  check "Strip Joins", 22, 17 39 44 10, tab 1
  check "Strip Parts", 23, 17 49 44 10, tab 1
  check "Strip Quits", 24, 17 60 44 10, tab 1
  check "Strip Nicks", 25, 17 71 44 10, tab 1
  check "Strip Modes", 26, 66 39 44 10, tab 1
  check "Strip Topics", 27, 66 49 44 10, tab 1
  check "Strip Kicks", 28, 66 60 44 10, tab 1
  check "Strip Ctcps", 29, 66 71 44 10, tab 1
  check "Log ircN echos (/iecho)", 30, 10 93 65 10, tab 1


  tab "Event Log", 40
  check "Log Connections", 41, 11 29 66 11, tab 40
  check "Log Disconnections", 42, 11 39 66 11, tab 40
  check "Log Highlights", 43, 11 49 66 11, tab 40
  check "Log CTCPs", 44, 11 59 66 11, tab 40
  check "Log Transfers", 45, 11 69 48 11, tab 40


  button "Cancel", 98, 142 125 39 14, hide cancel
  button "OK", 99, 100 125 39 14, hide ok
}

on *:DIALOG:ircnsetup.logs:sclick:99:_save.logging

on *:DIALOG:ircnsetup.logs:init:0:{
  var %n = $dname

  var %set = logging.stripjoin logging.strippart logging.stripquit logging.stripnick logging.stripmode logging.striptopic logging.stripkick logging.stripctcp logging.logiecho
  var %did = 22                  23                 24                   25               26                   27                  28                29                 30, %i = $numtok(%did, 32)
  while (%i) { if ($nvar($gettok(%set,%i,32)) == on) { did -c %n $gettok(%did, %i, 32) } | dec %i }



}
alias _save.logging {
  var %d = ircnsetup.logs
  if (!$dialog(%d)) return

  var %set = logging.stripjoin logging.strippart logging.stripquit logging.stripnick logging.stripmode logging.striptopic logging.stripkick logging.stripctcp logging.logiecho
  var %did = 22                  23                 24                   25               26                   27                  28                29                 30, %i = $numtok(%did, 32)

  while (%i) { nvar $gettok(%set,%i,32) $iif($did(%d,$gettok(%did,%i,32)).state == 1,on) | dec %i }
}

on *:dialog:logmove.outputfolder:sclick:3:{
  var %s = $$sdir(C:\,Move/Copy older ircN chat logs to this directory..)
  if ($left(%s,2) == \\) {
    did -ra $dname 12 %s
    did -r $dname 15,17
    did -c $dname 10
    did -u $dname 11
    did -b $dname 20,13
    did -e $dname 12,15,17
    did -ra $dname 22  Must verify network connection first. Enter username and password.
  }
  else {
    if ($isdir(%s)) did -ra $dname 2 $shortfn(%s)
    else .echo -q $input(Directory %s is not a valid path!)
    did -c $dname 11
    did -u $dname 10
  }
}
on *:dialog:logmove.outputfolder:sclick:20:{

  var %d
  if ($did(10).state) {
    nvar logmove.netcopy.enabled $true
    nvar logmove.netcopy.user $did(15)
    nvar logmove.netcopy.pass $_encryptt($did(15), $did(17))
    nvar logmove.netcopy.host $gettok($did(12),1,92) 
    nvar logmove.netcopy.location $did(12)
  }
  else {
    nvar logmove.netcopy.enabled 
    nvar logmove.netcopy.user  
    nvar logmove.netcopy.pass 
    nvar logmove.netcopy.host 
    nvar logmove.netcopy.location 

  }
  else {
    nvar logmove.location $did(2)

  }

  set %d ircnsetup.logclean
  if ($dialog(%d)) did -ra %d 25 $iif($did(10).state, $did(12), $did(2))

}
on *:dialog:logmove.outputfolder:sclick:11:{
  did -e $dname 20
  did -b $dname 12,15,17,13
}
on *:dialog:logmove.outputfolder:sclick:10:{
  did -b $dname 20
  did -e $dname 12,15,17,13
}
on *:dialog:logmove.outputfolder:edit:12,15,17:{
  var %e = did -ra $dname 22 
  did -b $dname 13,20

  if (!$remove($did(12),\,$chr(32))) || (!$did(15)) || ($left($did(12),2) != \\) || (!$did(17)) { 
    var %q 
    if (!$remove($did(12),\,$chr(32)))   set %q -b
    elseif ($left($did(12),2) != \\) set %q -b 
    else set %q -e
    did %q $dname 15,17
    did -b $dname 13,20 
    var %q = $iif(!$remove($did(12),\,$chr(32)), 1, $iif(!$did(15), 2, 3))
    %e Please enter: Network Share $gettok(Path|Username|Password,%q,124)
    return
  }
  if (!$did(13).state) { 
    if (!$timer(logoutoutput_verify)) {
      did -e $dname 13 
      did -b $dname 20
      %e Must verify network connection first
    }
    else did -b $dname 13 
  }
}
on *:dialog:logmove.outputfolder:sclick:13:{
  var %q = \\ $+ $gettok($did(12),1,92) $+ \IPC$ 
  if ($isfile($tp(logoutputreturn.txt))) .remove $tp(logoutputreturn.txt)
  write -c $tp(logoutputnettest.bat) del $tp(logoutputreturn.txt)
  write $tp(logoutputnettest.bat) net use %q /delete
  write $tp(logoutputnettest.bat) net use $did(12) /delete

  write $tp(logoutputnettest.bat) net use %q  $qt($did(17)) /USER: $+ $qt($did(15)) 2> $tp(logoutputreturn.txt)
  write $tp(logoutputnettest.bat) echo finished >> $tp(logoutputreturn.txt)
  write $tp(logoutputnettest.bat) net use $did(12) /delete
  write $tp(logoutputnettest.bat) net use %q /delete
  did -b $dname 13,20
  .timerlogoutoutput_verify -o 500 1 logoutoutput_verify 
  did -ra $dname 22 Attempting to connect to network.. please wait.
  run -nh $tp(logoutputnettest.bat)
  ;write  $tp(logoutputnettest.bat) net use %q /delete
}
alias logoutoutput_verify {

  var %f = $tp(logoutputreturn.txt)
  var %d = logmove.outputfolder
  var %e  

  if ($isfile(%f)) {
    var %l = $lines(%f)
    if (!%l) return

    if (%l == 1) { 
      if ($isdir($qt($did(%d,12)))) {
        set %e Network connection successful! 
        .echo -q $input(%e ,o,Network Share)
        did -e %d 20,13
        .timerlogoutoutput_verify off
      }
      else {
        set %e ERROR! Network connection successful, but unable to access path.
        .echo -q $input(%e ,o, Network Share)
        .timerlogoutoutput_verify off
        did -b %d 20,13
      }
    }
    elseif (%l > 1) {
      set %e Error! $read(%f,n,3)  
      .echo -q $input(%e ,o, Network Share)
      .timerlogoutoutput_verify off
      did -b %d 20,13
    }
    else set %e Attempting to connect to network.. please wait.
  }
  else set %e Attempting to connect to network.. please wait.

  if ($dialog(%d))  did -ra %d 22 %e

}


on *:dialog:logmove.outputfolder:init:0:{

  did -c $dname 4

  did -ra $dname 12 $nvar(logmove.netcopy.location)
  did -ra $dname 15 $nvar(logmove.netcopy.user)
  did -ra $dname 17 $_decryptt($nvar(logmove.netcopy.user), $nvar(logmove.netcopy.pass))


  did -c $dname $iif($nvar(logmove.netcopy.enabled), 10,11)
  did -f $dname $iif($nvar(logmove.netcopy.enabled),12, 2)

}
dialog logmove.outputfolder {
  title "Select log output folder"
  size -1 -1 258 167
  option dbu
  text "Select Local or Network folder:", 1, 8 10 146 13
  edit "", 2, 20 25 195 14, read
  button "...", 3, 217 24 27 13
  radio "Move Files", 4, 8 105 42 11, group
  radio "Copy Files", 5, 8 117 45 11
  box "Networked Folders", 6, 141 94 113 47
  check "Retry connection", 7, 146 105 56 12
  edit "", 8, 201 106 16 13
  text "times", 9, 221 108 28 11
  radio "Network Share:", 10, 8 45 48 14, group
  radio "", 11, 8 25 11 13
  edit "", 12, 59 46 157 14, autohs
  button "Verify", 13, 218 46 27 13
  text "Username:", 14, 60 63 37 12
  edit "", 15, 100 62 55 14, autohs
  text "Password:", 16, 157 63 33 12
  edit "", 17, 191 62 55 14, pass autohs
  box "", 18, 3 1 251 91
  box "Options", 19, 3 94 136 47
  button "OK", 20, 214 149 38 17, default ok
  button "Cancel", 21, 173 149 38 17, cancel
  text "", 22, 8 77 242 10
}


dialog ircnsetup.logclean {
  title "ircN Log Cleaning"
  size -1 -1 186 187
  option dbu
  icon $gfxdir(icons\ircn.ico), 0
  check "Compress Log files", 5, 265 224 65 12
  button "OK", 98, 103 166 36 15, hide default ok
  button "Close", 99, 142 166 36 15, hide cancel
  edit "", 1, 371 226 27 12, disable
  text "Older Than:", 2, 336 228 32 8, disable
  check "Match Filenames", 6, 12 47 51 11
  list 7, 70 45 72 23, size
  button "Add", 8, 148 45 23 10
  button "Del", 9, 148 57 23 10
  check "Minimum Size", 10, 12 87 55 12
  check "Minimum Lines", 11, 12 71 55 12
  check "Last Modified:", 12, 12 101 55 12
  button "Run Now", 13, 135 144 41 14
  combo 3, 401 226 38 55, size drop
  check "Run Every:", 14, 12 124 46 10
  edit "", 15, 69 123 31 12, disable
  text "days", 16, 104 124 19 10
  edit "", 17, 69 87 32 12, autohs
  combo 18, 103 87 32 50, size drop
  edit "", 19, 69 101 32 12, autohs
  combo 20, 103 101 32 55, size drop
  edit "", 21, 69 72 66 12, autohs right
  text "ago", 22, 139 102 29 8
  check "Transfer old logs to folder", 23, 6 5 76 10
  edit "", 25, 84 5 73 11, read autohs right
  button "...", 26, 159 5 19 12
  text "Older Than:", 27, 12 21 32 8, disable right
  edit "", 28, 46 18 27 12, disable
  combo 29, 76 19 38 41, size drop
  text "Existing:", 24, 116 21 23 9, disable right
  combo 30, 141 19 38 41, size drop
  box "Log Removal", 4, 6 36 172 104
}


on *:DIALOG:ircnsetup.logclean:init:0:{
  var %n = $dname 

  did -a %n 18 Bytes
  did -a %n 18 KB
  did -a %n 18 MB

  did -a %n 20 Hours
  did -a %n 20 Days
  did -a %n 20 Weeks
  did -a %n 20 Months
  did -a %n 20 Years

  did -a %n 29 Hours
  did -a %n 29 Days
  did -a %n 29 Weeks
  did -a %n 29 Months
  did -a %n 29 Years

  did -a %n 30 Skip
  did -a %n 30 Overwrite
  did -a %n 30 Append


  did -c %n 29 4
  did -c %n 30 1

  did -c %n 18,20 2

}

on *:dialog:ircnsetup.logclean:edit:17,21:did -ra $dname $did $bytes($remove($did($did),$chr(44)),b)
on *:dialog:ircnsetup.logclean:sclick:13:{
  var %a
  var %lines, %size, %age, %match

  var %q = $+($did(6).state,$did(10).state,$did(11).state,$did(12).state)

  if (!%q) {
    .echo -q $input(You have no log removal filters enabled. This would remove every log file in your logging folder. Please enable log removal filters before continuing. [ $crlf ] If you do not want to use channel logging disable it in mIRC,o,ircN Log Cleaning)

    return

  }
  if ($did(11).state) { 
    set %lines  $remove($did(21),$chr(44)) 

    if (!$isnumnotnull(%lines,1-)) || (!%lines) { 
      .echo -q $input(Invalid number $iif(%lines,' $+ %lines $+ ') for Minimum Lines. Enter a valid number or uncheck the enabled box for lines,o,ircN Log Cleaning) 
      return 
    }

  }
  if ($did(10).state) {
    set %size $remove($did(17),$chr(44))
    if (!$isnumnotnull(%size,1-)) || (!%size) { .echo -q $input(Invalid number $iif(%size,' $+ %size $+ ') for Minimum File size. Enter a valid number or uncheck the enabled box for size,o,ircN Log Cleaning) | return }

    if ($did(18).sel > 1) {
      if (%size) set %size $calc(%size $iif($did(18).sel == 3, *1024*1024,*1024) ) 
    }
  }
  if ($did(12).state) {
    set %a $did(19)

    if (!$isnumnotnull(%a,1-)) || (!%a) { .echo -q $input(Invalid number $iif(%a,' $+ %a $+ ') for Last modified time. Enter a valid number or uncheck the enabled box for last modified,o,ircN Log Cleaning) | return }


    if (%a isnum) {
      var %t2 = 60*60 60*60*24 60*60*24*7 60*60*24*7*4 60*60*24*7*4*12
      var %t = $calc(%a * $gettok(%t2,$did(20).sel,32))
      set %age %t
    }
  }
  if ($did(6).state) {
    var %a = 1, %b
    while ($did(7,%a) != $null) {
      set %b $did(7,%a)
      if (%b) {
        if (* !isin %b) set %b * $+ %b $+ *
        set %match $addtok(%match,%b,32)
      }
      inc %a
    }

  }

  logclean $iif(%lines,-lines %lines)  $iif(%size,-size %size)  $iif(%age,-age %age) %match
}
on *:dialog:ircnsetup.logclean:sclick:26:dlg logmove.outputfolder



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Transfer dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircnsetup.transfer {
  title "ircN Transfer Settings"
  icon $gfxdir(icons\ircn.ico), 0
  size -1 -1 0 0 
  option dbu
  check "Move Completed Downloads to:", 1, 7 9 129 11
  edit "", 2, 7 22 150 12, read autohs
  button "...", 3, 160 21 16 12
  check "Pump DCC", 4, 5 83 61 12
  check "Passive DCC", 5, 5 71 65 12
  check "Limit Send Rate:", 6, 5 97 67 9
  edit "", 7, 80 95 18 12, autohs
  combo 8, 99 96 23 31, size drop
  check "Auto Minimize Sends", 9, 5 108 78 12
  check "Auto Close Sends", 10, 5 121 80 12
  check "Network", 11, 15 49 36 7
  check "Nick", 12, 58 49 28 7
  check "Date", 13, 95 49 26 7, hide disable
  combo 14, 124 48 51 35, hide size edit drop
  box "", 15, 1 0 181 66
  text "Organize Folders by:", 16, 11 37 75 10
  button "OK", 98, 105 136 36 15, hide default ok
  button "Cancel", 99, 144 136 36 15, hide cancel
}


on *:dialog:ircnsetup.transfer:sclick:1:  did $iif($did(1).state,-e,-b) $dname 11,12
on *:dialog:ircnsetup.transfer:sclick:13:  did $iif($did(13).state,-e,-b) $dname 14
on *:dialog:ircnsetup.transfer:sclick:98:_save.transfer
alias transfersettings {
  if ($istok(%ircnsetup.docked,ircnsetup.transfer,44)) return
  dlg -r ircNsetup.transfer
  dialog -rsb ircnsetup.transfer -1 -1 184 156

  did -v ircNsetup.transfer 98,99
}
on *:dialog:ircnsetup.transfer:sclick:3:{
  var %n = $dname
  var %a = $shortfn($$sdir($getdir))
  if (!$isdir(%a)) return
  if (%a == $shortfn($getdir)) { var %q = $input(The "Move Completed Downloads" function is for moving completed files OUT of the ' $+ $remove($getdir,%dir) $+ ' folder and into a new folder when it is complete. Do not set this as the same folder as your incoming folder  [ $cr ]  Ex: make an 'ircN\Downloads $+ ' folder and use that,ow,Error) | return }
  did -ra %n 2 $noqt(%a)
}
on *:dialog:ircnsetup.transfer:init:*:{
  var %n = $dname
  did -a %n 8 bps
  did -a %n 8 kbps
  did -c %n 8 2
  if ($nvar(transfer.movedl) == on)  did -c %n 1

  did -ra %n 2 $nvar(transfer.movedir)
  if ($nvar(transfer.movedl.networkfolder)) did -c %n 11
  if ($nvar(transfer.movedl.nickfolder)) did -c %n 12
  if ($nvar(transfer.movedl.datefolder)) did -c %n 13
  did $iif($did(13).state,-e,-b) %n 14

  if ($nvar(transfer.pumpdcc) == on) did -c %n 4

  if ($nvar(transfer.passivedcc) == on) did -c %n 5
  if ($nvar(transfer.limitsend)) {
    did -c %n 6
    did -ra %n 7 $gettok($nvar(transfer.limitspeed),1,32)
    did -c %n 8 $iif($gettok($nvar(transfer.limitspeed),2,32) == k,2,1)
  }
  if ($nvar(transfer.autominsend) == on) did -c %n 9
  if ($nvar(transfer.autoclosesend) == on) did -c %n 10
  did -a %n 14 ddmmyyyy
  did -a %n 14 mmyyyy
  did -a %n 14 yyyy
  did -c %n 14 1
}
alias _save.transfer {
  var %d = ircnsetup.transfer
  if (!$dialog(%d)) return

  nvar transfer.movedl $iif(($isdir($qt($did(%d,2))) && $did(%d,2)),$nro2onoff($did(%d,1).state))

  if ($isdir($qt($did(%d,2)))) nvar transfer.movedir $did(%d,2)

  nvar transfer.movedl.networkfolder $nro2onoff($did(%d,11).state)
  nvar transfer.movedl.nickfolder $nro2onoff($did(%d,12).state)
  nvar transfer.movedl.datefolder $nro2onoff($did(%d,13).state)

  nvar transfer.pumpdcc $nro2onoff($did(%d,4).state)
  nvar transfer.limitsend $nro2onoff($did(%d,6).state)
  if ($did(%d,6).state) {
    nvar transfer.limitspeed  $did(%d,7) $iif($did(%d,8).sel == 1,b,k)
    .dcc maxcps $calc( $did(%d,7) $iif($did(%d,8).sel == 2, *1024))
  }
  nvar transfer.passivedcc $nro2onoff($did(%d,5).state)
  nvar transfer.autominsend $nro2onoff($did(%d,9).state)
  nvar transfer.autoclosesend $nro2onoff($did(%d,10).state)

  .pdcc $nro2onoffdef($did(%d,4).state)
  .dcc passive $nro2onoffdef($did(%d,5).state)

}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; hide channel dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircn.hidechan {
  title "ircN Channel Hiding"
  size -1 -1 139 151
  option dbu
  combo 1, 3 22 127 75, sort size
  button "Add", 4, 105 98 26 12, disable
  button "Del", 6, 77 98 26 12, disable
  button "Clear", 7, 3 98 26 12, disable
  check "Notify when hidden in status window", 5, 5 114 125 12

  text "Channels to be hidden from the switchbar:", 2, 5 6 123 14

  button "Cancel", 98, 98 130 36 16, cancel
  button "OK", 99, 60 130 36 16, default ok
}
on *:dialog:ircn.hidechan:init:0:{
  var %a = 1
  while ($gettok($nvar(hidechans),%a,44) != $null) {
    did -a $dname 1 $ifmatch
    inc %a
  }
  did $iif($nvar(hidechans.dontnotify),-u,-c) $dname 5
  if ($did(1).lines) did -e $dname 7

  if ($ismod(modernui)) {

    mtooltips  SetTooltipWidth  250
    .timer 1 0 set -u15 % $+ hidechan.tooltip $ $+ mtooltips(SpawnTooltip, +0tabs $ $+ calc( $ $+ dialog( $dname  ).x   + 10) $ $+ calc(  $ $+ dialog( $dname ).y  + $dialog( $dname ).ch ) 12000 > NOT_USED $chr(4) You can use the ircN menu -> extras -> hidden to toggle the channels. $paren(/showchans & /hidechans) [ $cr ] Bind the command /togglechans to your /Fkeys for easy access. )

    ;mtooltip_maindlg hidechan $dname 1200 Message
  }

}
on *:dialog:ircn.hidechan:close:0:{
  var %a = $gettok(%hidechan.tooltip ,2,32)
  if (%a) mtooltips KillTooltip %a
}

on *:dialog:ircn.hidechan:sclick:99:{ 
  var %a = 1

  nvar hidechans.dontnotify $iif(!$did(5).state,on)

  nvar hidechans
  while ($did(1,%a) != $null) {
    nvar hidechans $addtok($nvar(hidechans),$did(1,%a),44)
    inc %a
  }  
  if ($hideablechans) {
    var %x = $ifmatch
    iecho Hiding $hc(%x) channels. Use /showchans or ircN -> extras -> hidden from the menu to display hidden channels
    hidechans
  }

}
on *:dialog:ircn.hidechan:sclick:1:did $iif($did(1).sel,-e,-b) $dname 6 
on *:dialog:ircn.hidechan:edit:1:{ 
  if ($didwm(1,$did(1))) {  did -c $dname 1 $v1 | did -b $dname 4   }

  else  did $iif($did(1),-e,-b) $dname 4 

}
on *:dialog:ircn.hidechan:sclick:7:{ 
  did -r $dname 1
  did $iif($did(1).lines,-e,-b) $dname 7
  did -b $dname 4,6
}
on *:dialog:ircn.hidechan:sclick:6:{
  did -d $dname 1 $did(1).sel
  did -o $dname 1 0
  did -b $dname 4,6
  did $iif($did(1).lines,-e,-b) $dname 7
}
on *:dialog:ircn.hidechan:sclick:4:{
  if (!$did(1)) return
  did -a $dname 1 $did(1)
  did -e $dname 6,7
  did -b $dname 4
  did -c $dname 1 $did(1).lines
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; /chandisplay dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias chandisplay {
  var %n = ircn.chandisplay

  if ($istok(%ircnsetup.docked,%n,44)) return
  dlg -r %n
  dialog -rsb %n -1 -1 243 194

  did -v %n 998,999

  if ($1 != global) {
    if ($network) {
      var %a = 0
      while ($did(%n,32).seltext != $network) {
        inc %a
        if (%a > $did(%n,32).lines) { did -c %n 32 1 | break }
        did -c %n 32 %a
        if ($did(%n,32).seltext == $network) break
      }
      _ircn.setup.addchancombo %n 20 $did(%n,32)
      .timer 1 0 _chandisp.updatevars
    }
    if ($active ischan) {
      did -e %n 20
      var %b = 1
      while ($did(%n,20,%b).text) {
        if ($did(%n,20,%b).text == $active) did -c %n 20 %b
        inc %b
      }
    }
    did -h %n 37
  }
  else {
    did -v %n 37
    .timer 1 0 _chandisp.updatevars

  }

}
on *:dialog:ircn.chandisplay:init:0:{
  var %d = $dname

  _tmpdlg.hashopen

  _ircn.setup.addnetcombo %d 32 hashnros
  .timer 1 0 _chandisp.updatevars
  did -i %d 20 1 Global
  did -c %d 20 1
  did -b %d 20

  ; did -c %d 49 
  ;  did -c %d 56 
  ; did -g %d 50 $td(colors\ $+ $remove($hc,$chr(3)) $+ txt.bmp)
  ; did -g %d 53 $td(colors\ $+ $remove($sc,$chr(3)) $+ txt.bmp)
  ;  did -g %d 55 $td(colors\ $+ $remove($ac,$chr(3)) $+ txt.bmp)


}
alias _chandisp.updatecomboinfo {
  var %d = ircN.chandisplay
  tmpdlggset %d combos $addtok($tmpdlggget(%d,combos),$tab($did(%d,32),$did(%d,20)),44)
}

alias _chandisp.updatevars {
  var %x = ircn.chandisplay
  _chandisp.updatecomboinfo
  if ($tmpdlggget(%x,combos) == $null) tmpdlgget %x combos $tab(Global,Global)
  if (!$tmpdlgget(%x,$did(%x,32),$did(%x,20),38)) {
    var %a, %b, %c, %d, %e

    set %a $iif($did(%x,32) == Global,$nvar(onjoin.showclones),$nget($net2scid($did(%x,32)),$tab(chan,$did(%x,20),onjoin.showclones)))
    set %b $iif($did(%x,32) == Global,$nvar(stripcodes),$nget($net2scid($did(%x,32)),$tab(chan,$did(%x,20),stripcodes)))
    set %c $iif($did(%x,32) == Global,$nvar(netsplit),$nget($net2scid($did(%x,32)),$tab(chan,$did(%x,20),netsplit)))
    set %d $iif($did(%x,32) == Global,$nvar(stylemytext),$nget($net2scid($did(%x,32)),$tab(chan,$did(%x,20),stylemytext)))
    set %e $iif($did(%x,32) == Global,$nvar(nohighlightmessage),$nget($net2scid($did(%x,32)),$tab(chan,$did(%x,20),nohighlightmessage)))

    tmpdlgset %x $did(%x,32) $did(%x,20) 38 $iif(($did(%x,32) == Global) && ($onoffdef2nro(%a) == 2),0,$onoffdef2nro(%a))
    tmpdlgset %x $did(%x,32) $did(%x,20) 36 $iif(($did(%x,32) == Global) && ($onoffdef2nro(%b) == 2),0,$onoffdef2nro(%b))
    tmpdlgset %x $did(%x,32) $did(%x,20) 19 $iif(($did(%x,32) == Global) && ($onoffdef2nro(%c) == 2),0,$onoffdef2nro(%c))
    tmpdlgset %x $did(%x,32) $did(%x,20) 43 $iif(($did(%x,32) == Global) && ($onoffdef2nro(%d) == 2),0,$onoffdef2nro(%d))
    tmpdlgset %x $did(%x,32) $did(%x,20) 81 $iif(($did(%x,32) == Global) && ($onoffdef2nro(%e) == 2),0,$onoffdef2nro(%e))

  }


  var %a = $hget(0), %b = 1
  var %x, %c, %b2

  while (%b <= %a) {
    if (*.ircN.settings iswm $hget(%b)) {
      set %x $left($hget(%b),-14)
      ;echo -a X: %x
      set %c $hfind($+(%x,.ircN.settings),$tab(chan,*,chanevent.*),0,w)
      set %b2 1

      while (%b2 <= %c) {
        var %c2 = $hfind($+(%x,.ircN.settings),$tab(chan,*,chanevent.*),%b2,w)
        var %c3 = $hget($+(%x,.ircN.settings),%c2)

        ;echo -a C: %c C2: %c2 C3: %c3 X: %x
        _load.ircn.chandisplay.process %x %c2 %c3
        inc %b2
      }
    }
    inc %b
  }

  set %c $hfind(ircN,chanevent.*,0,w)
  set %b2 1
  while (%b2 <= %c) {
    var %c2 = $hfind(ircN,chanevent.*,%b2,w)
    var %c3 = $hget(ircN,%c2)

    ;echo -a C: %c C2: %c2 C3: %c3 X: %x
    _load.ircn.chandisplay.process global $tab(chan,global,%c2) %c3
    inc %b2
  }

  .timer 1 0 _chandisplay.updatedids
}
alias _chandisplay.updatedids {
  var %x = ircn.chandisplay

  if ($did(%x,20).lines <= 2) || ($did(%x,32).sel == 1) did -b %x 20
  else did -e %x 20

  var %a, %b, %c, %d, %e 
  set %a $tmpdlgget(%x,$did(%x,32),$did(%x,20),38)
  set %b $tmpdlgget(%x,$did(%x,32),$did(%x,20),36)
  set %c $tmpdlgget(%x,$did(%x,32),$did(%x,20),19)
  set %d $tmpdlgget(%x,$did(%x,32),$did(%x,20),43)
  set %e $tmpdlgget(%x,$did(%x,32),$did(%x,20),81)


  did $iif(%a == 1,-c,$iif(%a != 2,-u,-cu)) %x 38
  did $iif(%b == 1,-c,$iif(%b != 2,-u,-cu)) %x 36
  did $iif(%c == 1,-c,$iif(%c != 2,-u,-cu)) %x 19

  ; re-enable text style when finished
  ; did $iif(%d == 1,-c,$iif(%d != 2,-u,-cu)) %x 43

  did $iif(%e == 1,-c,$iif(%e != 2,-u,-cu)) %x 81


  _chandisp.addevtcombo %x 3
  _chandisp.addevtcombo %x 5
  _chandisp.addevtcombo %x 6
  _chandisp.addevtcombo %x 7
  _chandisp.addevtcombo %x 10
  _chandisp.addevtcombo %x 11
  _chandisp.addevtcombo %x 14
  _chandisp.addevtcombo %x 15
  _chandisp.addevtcombo %x 23 nostatus nochannel
  _chandisp.addevtcombo %x 25 nostatus nochannel

  ; select 1st id on hide/show/channel combos
  did -c %x 3,5,6,7,10,11,14,15,23,25 1

  ;select the right one $tmpdlgget(dialog,efnet,chanel, ID)
  if ($tmpdlgget(%x,$netset2hash($did(%x,32)),$did(%x,20),3)) did -c %x 3 $didwm(%x,3,* $+ $ifmatch $+ *)
  if ($tmpdlgget(%x,$netset2hash($did(%x,32)),$did(%x,20),5)) did -c %x 5 $didwm(%x,5,* $+ $ifmatch $+ *)
  if ($tmpdlgget(%x,$netset2hash($did(%x,32)),$did(%x,20),6)) did -c %x 6 $didwm(%x,6,* $+ $ifmatch $+ *)
  if ($tmpdlgget(%x,$netset2hash($did(%x,32)),$did(%x,20),7)) did -c %x 7 $didwm(%x,7,* $+ $ifmatch $+ *)
  if ($tmpdlgget(%x,$netset2hash($did(%x,32)),$did(%x,20),10)) did -c %x 10 $didwm(%x,10,* $+ $ifmatch $+ *)
  if ($tmpdlgget(%x,$netset2hash($did(%x,32)),$did(%x,20),11)) did -c %x 11 $didwm(%x,11,* $+ $ifmatch $+ *)
  if ($tmpdlgget(%x,$netset2hash($did(%x,32)),$did(%x,20),14)) did -c %x 14 $didwm(%x,14,* $+ $ifmatch $+ *)
  if ($tmpdlgget(%x,$netset2hash($did(%x,32)),$did(%x,20),15)) did -c %x 15 $didwm(%x,15,* $+ $ifmatch $+ *)
  ;hide text/action
  if ($tmpdlgget(%x,$netset2hash($did(%x,32)),$did(%x,20),23)) did -c %x 23 $didwm(%x,23,$ifmatch)
  if ($tmpdlgget(%x,$netset2hash($did(%x,32)),$did(%x,20),25)) did -c %x 25 $didwm(%x,25,$ifmatch)

  ; hide text code



  _chandisp.refreshhidetxt



  ; hide 


  ; ircn.chandisplay.style.updateprev
  ; did -g %x 62 $td(styleprev.bmp)

  ; nick coloring
  ; set the default radio checked if the nick coloring variable doesn't exist


}



alias _load.ircn.chandisplay.process {
  if ($0 <= 2) return
  var %d = ircn.chandisplay
  var %x
  if ($gettok($2,3,9) == chanevent.join) set %x 3
  if ($gettok($2,3,9) == chanevent.mode) set %x 5
  if ($gettok($2,3,9) == chanevent.part) set %x 6
  if ($gettok($2,3,9) == chanevent.topic) set %x 7
  if ($gettok($2,3,9) == chanevent.quit) set %x 10
  if ($gettok($2,3,9) == chanevent.ctcp) set %x 11
  if ($gettok($2,3,9) == chanevent.kick) set %x 14
  if ($gettok($2,3,9) == chanevent.nick) set %x 15
  if ($gettok($2,3,9) == chanevent.text) set %x 23
  if ($gettok($2,3,9) == chanevent.action) set %x 25
  if ($gettok($2,3,9) == chanevent.ignorematch) set %x $tab(hidetxt,$gettok($2,4,9))
  tmpdlgset %d $1 $gettok($2,2,9) %x $3-

  ; echo -s .. $did(%d,32) ... $did(%d,20)
  ;  echo -ag tmpdlgset %d $1 $gettok($2,2,9) %x $3-
}
dialog ircn.chandisplay {
  title "Channel Display Settings"
  size -1 -1 243 188
  option dbu
  icon $gfxdir(icons\ircn.ico), 0
  button "OK", 999, 162 175 37 12, default ok
  button "Cancel", 998, 203 175 37 12, cancel


  combo 20, 141 4 46 49, size drop
  text "Channel:", 21, 111 5 28 10
  text "Network:", 31, 29 6 28 10
  combo 32, 59 5 46 50, size drop
  tab "Display", 35, 4 17 235 150
  button "Channel Hiding", 37, 136 37 46 15, tab 35
  text "A filled checkbox means that it is the default value inherited from its parent (On/Off/Default). Settings Priority: (Network+Channel > Network+Global Chan > Global Network). If a box is set to default it will inherit the setting from the one above.", 18, 9 130 172 31, tab 35
  check "Show Clones on Join", 38, 10 36 62 10, tab 35 3state
  check "Strip Color Codes", 36, 10 46 62 10, tab 35 3state
  check "Netsplit Detector", 19, 10 56 62 10, tab 35 3state
  tab "Event Filtering", 39
  box "Show events:", 22, 9 39 112 111, tab 39
  text "Joins:", 2, 17 48 35 8, tab 39
  combo 3, 16 56 40 57, tab 39 size drop
  text "Modes:", 4, 62 48 45 8, tab 39
  combo 5, 61 56 40 57, tab 39 size drop
  combo 6, 16 77 40 57, tab 39 size drop
  combo 7, 61 77 40 57, tab 39 size drop
  text "Parts:", 8, 17 69 35 8, tab 39
  text "Topics:", 9, 62 69 45 8, tab 39
  combo 10, 16 98 40 57, tab 39 size drop
  combo 11, 61 98 40 57, tab 39 size drop
  text "Quits:", 12, 17 90 35 8, tab 39
  text "Ctcps:", 13, 62 90 45 8, tab 39
  combo 14, 16 120 40 57, tab 39 size drop
  combo 15, 61 120 40 57, tab 39 size drop
  text "Kicks:", 16, 17 111 37 8, tab 39
  text "Nicks:", 17, 61 112 45 8, tab 39
  button "Hide all events in channel", 34, 16 134 86 12, tab 39

  box "Options", 80, 122 39 114 111, tab 39
  check "Don't highlight switchbar on new activity", 81, 125 46 107 12, tab 39 3state


  tab "Text Filtering", 40
  box "Show Text", 466, 8 34 120 124, tab 40

  combo 27, 19 92 57 49, tab 40 size 

  box "Filtering", 467, 12 69 110 85, tab 40
  text "Hide matching text:", 28, 19 82 57 10, tab 40
  combo 23, 12 53 40 57, tab 40 size drop
  combo 25, 56 53 40 57, tab 40 size drop 
  button "Rem", 30, 83 117 24 10, tab 40
  button "Add", 29, 83 106 24 10, tab 40

  check "regex", 33, 83 92 25 8, disable tab 40
  text "Text:", 24, 13 45 35 8, tab 40
  text "Actions:", 26, 57 45 35 8, tab 40

  text "Wildcards * ? allowed", 41, 19 145 57 12, tab 40 

  tab "Nick Coloring", 90
  text "Color nicknames in text:", 91, 11 34 106 11, tab 90
  radio "Use the same colors as on the nicklist", 92, 20 81 132 10, tab 90
  radio "Assign random colors for each nickname:", 93, 20 98 120 12, tab 90
  text "Allowed colors:", 94, 32 115 46 10, tab 90
  check "Unassign users random color when they're idle for:", 95, 32 141 135 10, tab 90
  radio "Disabled", 96, 20 65 132 10, tab 90
  edit "", 97, 169 141 24 12, tab 90
  text "minutes", 98, 196 143 26 9, tab 90
  radio "Default", 99, 20 50 132 10, tab 90


  icon 100, 80 114 9 9, $td(colors\blank.bmp), tab 90
  icon 101, 92 114 9 9, $td(colors\blank.bmp), tab 90
  icon 102, 104 114 9 9, $td(colors\blank.bmp), tab 90
  icon 103, 116 114 9 9, $td(colors\blank.bmp), tab 90
  icon 104, 128 114 9 9, $td(colors\blank.bmp), tab 90
  icon 105, 140 114 9 9, $td(colors\blank.bmp), tab 90
  icon 106, 152 114 9 9, $td(colors\blank.bmp), tab 90
  icon 107, 164 114 9 9, $td(colors\blank.bmp), tab 90
  icon 108, 164 125 9 9, $td(colors\blank.bmp), tab 90
  icon 109, 152 125 9 9, $td(colors\blank.bmp), tab 90
  icon 110, 140 125 9 9, $td(colors\blank.bmp), tab 90
  icon 111, 128 125 9 9, $td(colors\blank.bmp), tab 90
  icon 112, 116 125 9 9, $td(colors\blank.bmp), tab 90
  icon 113, 104 125 9 9, $td(colors\blank.bmp), tab 90
  icon 114, 92 125 9 9, $td(colors\blank.bmp), tab 90
  icon 115, 80 125 9 9, $td(colors\blank.bmp), tab 90

  /*
  tab "Text Style", 42
  check "Enable stylized text", 43, 9 35 71 9, tab 42 3state
  check "Background Color:", 44, 22 92 58 10, tab 42

  box "", 45, 15 45 170 70, tab 42
  text "Preview:", 61, 14 154 29 9, tab 42
  icon 62, 44 152 138 12, $gfxdir(noprev.bmp), tab 42 noborder left
  check "Foreground Color:", 45, 23 63 60 10, tab 42
  icon 46, 88 63 9 9, $td(colors\blank.bmp), tab 42
  box "solid", 47, 85 49 18 31, tab 42

  box "solid", 59, 85 81 18 31, tab 42
  icon 60, 88 93 9 9, $td(colors\blank.bmp), tab 42
  text "A filled checkbox means that it is the default value inherited from its parent (On/Off/Default). Settings Priority: (Network+Channel > Network+Global Chan > Global Network). If a box is set to default it will inherit the setting from the one above. Left click to set color boxes, right click to set to default.", 58, 13 115 172 34, tab 42

  box "", 63, 115 46 60 31, tab 42

  check "bold", 64, 118 54 22 8, tab 42
  check "underline", 65, 118 65 36 8, tab 42
  check "italic", 66, 147 54 24 8, tab 42
  */


  tab "Text Style", 42
  check "Enable stylized text", 400, 9 35 71 9, 3state tab 42
  check "Background Color:", 403, 22 92 58 10, tab 42 
  box "", 432, 15 45 170 70, tab 42 
  text "Preview:", 431, 14 154 29 9, tab 42 
  icon 440, 44 152 138 12,  $gfxdir(noprev.bmp), 0,  tab 42 noborder left
  check "Foreground Color:", 401, 23 63 60 10, tab 42 
  icon 402, 88 63 9 9,  $td(colors\blank.bmp), tab 42 
  box "solid", 433, 85 49 18 31, tab 42 
  box "solid", 434, 85 81 18 31, tab 42 
  icon 404, 88 93 9 9,  $td(colors\blank.bmp), tab 42 
  text "A filled checkbox means that it is the default value inherited from its parent (On/Off/Default). Settings Priority: (Network+Channel > Network+Global Chan > Global Network). If a box is set to default it will inherit the setting from the one above. Left click to set color boxes, right click to set to default.", 430, 13 115 172 34, tab 42 
  box "", 435, 115 47 60 31, tab 42 
  check "bold", 405, 118 54 22 8, tab 42 
  check "underline", 407, 118 65 36 8, tab 42 
  check "italic", 406, 147 54 24 8, tab 42 





}
; clicks the color change buttons .. fg=46, 60=bg, bold=64, underline=65, italic=66
on *:dialog:ircn.chandisplay:sclick:402,404:{
  var %d = $did
  if (!$did(400).state) return

  _refreshcolorgfx

  var %a = $dialog(ircn.mirccolors,ircn.mirccolors)

  var %a = $base(%mirccolorsdlg.result,10,10,2)
  if (%a !isnum) return

  did -g $dname %d $td(colors\ $+ $base(%a,10,10,2) $+ txt.bmp)
  ircn.chandisplay.style.updateprev %d
}
on *:dialog:ircn.chandisplay:rclick:46,50,53,55,60:{
  if ($did(32).sel <= 2) return
  did -g $dname $did  $td(colors\blank.bmp)
}
alias -l ircn.chandisplay.style.updateprev {
  var %d = ircn.chandisplay


  did -e %d 403

  ;did -b %d 56

  if ($1 == 402) || ($1 == 404) || ($1 isnum 405-407) {
    chandisplay.style.preview $iif(!$did(401).state,$color(say),$remove($nopath($did(%d,402)),txt,.bmp)) $iif(!$did(403).state,$color(background),$remove($nopath($did(%d,404)),txt,.bmp)) 
    did -g %d 440 $td(styleprev.bmp)
  }

}
on *:dialog:ircn.chandisplay:sclick:401,404,405-407:{
  if ($did isnum 44-45) {


    if (!$did(45).state) {
      chandisplay.style.preview $color(say) $color(background)
      did -g $dname 62 $td(styleprev.bmp)
      return
    }
    ;    did -e $dname 44,49,56
    ircn.chandisplay.style.updateprev 46
  }
  else  ircn.chandisplay.style.updateprev $did

}

alias -l chandisplay.style.preview {
  var %d = ircn.chandisplay
  window -ph +d @styleprev 1 1 300 25
  clear @styleprevprev

  if ($1 == fade) {
    var %w = $iif($2 == word,$true,$false)
    tokenize 32 $3-
    if (%w) var %q = $fade($1,$2,$3,Preview of your channel text.)
    else var %q = $_fade($1,$2,$3,Preview of your channel text.)
    set %q $iif($did(%d,65).state,$chr(31))  $+ $iif($did(%d,66).state,$chr(29)) $+ $iif($did(%d,64).state,$chr(2)) $+ $+ %q
  }
  else { 
    var %c = $base($1,10,10,2) $+ , $+ $base($2,10,10,2)
    var %q = $iif($did(%d,407).state,$chr(31))  $+ $iif($did(%d,406).state,$chr(29)) $+ $iif($did(%d,405).state,$chr(2)) $+ $chr(3) $+ %c $+ Preview of your channel text.
  }
  drawtext -pn @styleprev $colour(say) " $+ $window(*,1).font $+ " $window(*,1).fontsize 3 3 %q
  drawdot @styleprev
  if ($isfile($td(styleprev.bmp))) .remove $td(styleprev.bmp)
  drawsave @styleprev $td(styleprev.bmp)
  window -c @styleprev
}
on *:dialog:ircn.chandisplay:sclick:34:{
  var %dids = 3 5 6 10 11 14 15 7 

  var %a = 1
  if (Hide* iswm $did($did).text) {

    if ($did(32).sel == 1)  var %a = $$input(Hiding All Events on "All Networks" will halt all incoming Events $+ $chr(44) are you sure you want to enable this,y)
    elseif ($did(20).sel == 1)  var %a = $$input(Hiding All Events on "All Channels" will halt all incoming Events for network: $did(32) $+ $chr(44) are you sure you want to enable this,y)

    if (!%a) return

    set %a 1
    while ($gettok(%dids,%a,32) != $null) {
      tmpdlgset $dname $netset2hash($did(32)) $did(20) $gettok(%dids,%a,32) hide
      did -c $dname $gettok(%dids,%a,32) 4
      inc %a
    }
    did -ra $dname $did Show all events in Channel
  }
  else {
    set %a 1
    while ($gettok(%dids,%a,32) != $null) {
      tmpdlgset $dname $netset2hash($did(32)) $did(20) $gettok(%dids,%a,32)  
      did -c $dname $gettok(%dids,%a,32) 1
      inc %a
    }
    did -ra $dname $did Hide all events in Channel

  }


}
on *:dialog:ircn.chandisplay:sclick:37:dlg -r ircn.hidechan
on *:dialog:ircn.chandisplay:sclick:3,5,6,7,10,11,14,15,23,25:{
  if ($did == 23) || ($did == 25) {
    if (($did(32).sel == 1) || ($did(20).sel == 1)) {
      if ($did($did) == Hide) {
        if ($did(32).sel == 1)  var %a = $$input(Hiding All $iif($did == 25,Actions,Text) on "All Networks" will halt all incoming  $iif($did == 25,Actions,Text) $+ $chr(44) are you sure you want to enable this,y)
        elseif ($did(20).sel == 1)  var %a = $$input(Hiding All  $iif($did == 25,Actions,Text) on "All Channels" will halt all incoming  $iif($did == 25,Actions,Text) for network: $did(32) $+ $chr(44) are you sure you want to enable this,y)
        if (!%a) {
          did -c $dname $did 1
          return
        }
      }
    }
  }
  tmpdlgset $dname $netset2hash($did(32)) $did(20) $did $did($did)
}
on *:dialog:ircN.chandisplay:close:0:.timer 1 0 _tmpdlgdel.hash $dname
on *:dialog:ircn.chandisplay:sclick:36,38,19,81:{
  if (($did(32) == Global) && ($did($did).state == 2)) { did -u $dname $did }

  tmpdlgset $dname $netset2hash($did(32)) $did(20) $did $did($did).state
}
on *:dialog:ircn.chandisplay:sclick:999:  _save.chandisplay
on *:dialog:ircn.chandisplay:sclick:27:{
  if (!$did(27).sel) return
  did -e $dname 33
  var %a = $tmpdlgget($dname, $netset2hash($did(32)), $did(20), $tab(hidetxt, $did(27).sel))
  if ($gettok(%a,1,32) == <r>) did -c $dname 33
  else did -u $dname 33
}
on *:dialog:ircn.chandisplay:edit:27:{
  did -u $dname 33
  did $iif($did(27),-e,-b) $dname 33
}
on *:dialog:ircn.chandisplay:sclick:33:{
  if (!$did(27).sel) return
  var %a = $tmpdlgget($dname, $netset2hash($did(32)), $did(20), $tab(hidetxt, $did(27).sel))
  if ($gettok(%a,1,32) == <r>) set %a $gettok(%a,2-,32)

  if (%a != $did(27)) return

  tmpdlgset $dname $netset2hash($did(32)) $did(20) $tab(hidetxt,$did(27).sel) $iif($did(33).state,<r>) $did(27)

}
on *:dialog:ircn.chandisplay:sclick:29:{
  if ($did(27) == $null) return
  var %x = $calc($hfind(tempsetup,$tab(set,$dname,$netset2hash($did(32)),$did(20),hidetxt,*),0,w) + 1)
  tmpdlgset $dname $netset2hash($did(32)) $did(20) $tab(hidetxt,%x) $iif($did(33).state,<r>) $did(27)
  did -a $dname 27 $did(27)
  did -o $dname 27 0
  did -u $dname 33
  did -e $dname 33
}
on *:dialog:ircn.chandisplay:sclick:30:{
  if (!$did(27).sel) return
  var %a = $did(27).sel, %b = $hfind(tempsetup, $tab(set,$dname,$netset2hash($did(32)),$did(20),hidetxt,*), 0, w)
  while (%a <= %b) {
    tmpdlgset $dname $netset2hash($did(32)) $did(20) $tab(hidetxt,%a) $tmpdlgget($dname,$netset2hash($did(32)),$did(20),$tab(hidetxt,$calc(%a + 1)))
    inc %a
  }
  if (%b == %a)  tmpdlgset $dname $netset2hash($did(32)) $did(20) $tab(hidetxt,%a)
  did -b $dname 33
  did -u $dname 33
  _chandisp.refreshhidetxt
}

alias _save.chandisplay {
  var %a, %b, %c, %dlgd = ircn.chandisplay

  if (!$dialog(%dlgd)) return

  set %a 1
  while ($gettok($tmpdlggget(%dlgd,combos),%a,44)) {
    set %b $ifmatch
    if (%b == $tab(global,global)) set %c nvar
    else set %c nset $net2scid($gettok(%b,1,9))

    $iif(%c == nvar, %c onjoin.showclones $nro2onoff( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),38)), %c  $tab(chan,$gettok(%b,2,9),onjoin.showclones) $nro2onoffdef( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),38)) )
    $iif(%c == nvar, %c stripcodes $nro2onoff( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),36)), %c  $tab(chan,$gettok(%b,2,9), stripcodes) $nro2onoffdef( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),36)) )
    $iif(%c == nvar, %c netsplit $nro2onoff( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),19)), %c  $tab(chan,$gettok(%b,2,9), netsplit) $nro2onoffdef( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),19)) )
    $iif(%c == nvar, %c nohighlightmessage $nro2onoff( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),81)), %c  $tab(chan,$gettok(%b,2,9), nohighlightmessage) $nro2onoffdef( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),81)) )

    inc %a
  }

  set %a 1
  ;clear out old values first for & ignore match text per network
  ;hdel -w ircN $tab(chanevent.ignorematch,*)
  hdel -w ircN chanevent.*

  while (%a <= $scon(0)) {
    var %netname = $ncid( [ [ $scon(%a).cid ] $+ ] ,network.hash)

    if (%netname)  hdel -w $+(%netname,.ircN.settings) $tab(chan,*,chanevent.*)
    inc %a
  }

  set %a 1
  set %b $hfind(tempsetup, $tab(set,%dlgd,*,*,*), 0, w)

  var %x, %s, %n2, %c2, %d2, %v2
  while (%a <= %b) {
    set %x $hfind(tempsetup, $tab(set,%dlgd,*,*,*), %a, w)

    set %n2 $gettok(%x,3,9)
    set %c2 $gettok(%x,4,9)
    set %d2 $gettok(%x,5-,9)

    ;exclude these since they arent the hide ids
    if ($istok(36 38 19 combos, %d2, 32)) { inc %a | continue }

    var %s
    set %v2 $hget(tempsetup,%x)
    if (%d2 == 3) set %s chanevent.join
    elseif (%d2 == 5) set %s chanevent.mode
    elseif (%d2 == 6) set %s chanevent.part
    elseif (%d2 == 7) set %s chanevent.topic
    elseif (%d2 == 10) set %s chanevent.quit
    elseif (%d2 == 11) set %s chanevent.ctcp
    elseif (%d2 == 14) set %s chanevent.kick
    elseif (%d2 == 15) set %s chanevent.nick
    elseif (%d2 == 23) set %s chanevent.text
    elseif (%d2 == 25) set %s chanevent.action
    elseif ($gettok(%d2,1,9) == hidetxt) {
      if (%n2 == global) {
        set %s $tab(chanevent.ignorematch,$gettok(%d2,2,9))
        nvar %s %v2
      }
      else {
        set %s $tab(chanevent.ignorematch,$gettok(%d2,2,9))
        scid $net2scid($nethash2set(%n2)) chanset %c2 %s %v2
      }
      inc %a
      continue
    }
    if (!%s) { inc %a | continue }
    ; if (%v2) iecho preif v2 : %v2
    if ($istok(status channel,$gettok(%v2,2,32), 32)) set %v2 $gettok(%v2,2,32)

    ; echo -a NET: %n2 CHAN: %c2 DID: %d2 VALUE: %v2


    if (%n2 != global) {
      ;   echo 04 -a %x ->  $iif(%v2 != default,%v2)
      scid $net2scid($nethash2set(%n2))
      chanset %c2 %s $iif(%v2 != default,%v2)
      scid -r
    }
    else {
      ;  iecho  nvar %s $iif(%v2 != default,%v2)
      nvar %s $iif(%v2 != default,%v2)
    }
    inc %a
  }


  _tmpdlgdel.hash %dlgd
}

alias _chandisp.refreshhidetxt {

  var %d = ircn.chandisplay, %q
  var %c = $did(%d,20), %n = $netset2hash($did(%d,32))
  var %a = 1, %b = $hfind(tempsetup, $tab(set,%d,%n,%c,hidetxt,*), 0, w)

  did -r %d 27
  while (%a <= %b) {
    set %q  $tmpdlgget(%d,%n,%c,$tab(hidetxt,%a))
    if ($gettok(%q,1,32) == <r>) set %q $gettok(%q,2-,32)
    did -a %d 27 %q
    inc %a
  }
}
alias _chandisp.addevtcombo {
  ;$1 = dialog $2 = did $3- = [nohide nodefault]
  did -r $1 $2
  if (!$istok($3-,nodefault,32)) did -a $1 $2 Default
  if (!$istok($3-,nochannel,32))  did -a $1 $2 In Channel
  if (!$istok($3-,nostatus,32))  did -a $1 $2 In Status
  if (!$istok($3-,nohide,32)) did -a $1 $2 Hide
}

on 1:dialog:ircN.chandisplay:sclick:32:{
  ; network


  if ($did(32)) {
    if ($did(32).sel == 2) did -c $dname 32 $iif($did(32,$pls($did(32).sel,1)),$pls($did(32).sel,1),$sub($did(32).sel,1))
    if ($did(32).sel <= 2) { did -c $dname 20 1 | did -b $dname 20 }
    else { did -e $dname 20 | _ircn.setup.addchancombo $dname 20 $did(32) }
    did -c $dname 20 1

    did $iif($did(32).sel <= 2,-v,-h) $dname 37
    did $iif($did(32).sel <= 2,-h,-v) $dname 99

  }
  .timer 1 0 _chandisp.updatevars

}
on 1:dialog:ircN.chandisplay:sclick:20:{
  ;chan
  if ($did(20)) {
    if ($did(20).sel == 2) did -c $dname 20 $iif($did(20,$pls($did(20).sel,1)),$pls($did(20).sel,1),$sub($did(20).sel,1))
  }

  .timer 1 0 _chandisp.updatevars
  .timer 1 0 _chandisp.updatecomboinfo

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Channel dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias chansettings {
  if ($istok(%ircnsetup.docked,ircnsetup.channel,44)) return
  var %n = ircnsetup.channel
  dlg -r %n
  dialog -rsb %n $mouse.cx $mouse.cy 195 177
  did -v %n 100,101


  if ($1 != global) {
    if ($network) {
      var %a = 0
      while ($did(%n,9).seltext != $network) {
        inc %a
        if (%a > $did(%n,9).lines) { did -c %n 9 1 | break }
        did -c %n 9 %a
        if ($did(%n,9).seltext == $network) break
      }
      _ircn.setup.addchancombo %n 7 $did(%n,9)
      .timer 1 0 _chanset.updatevars
    }
    if ($active ischan) {
      did -e %n 7
      var %b = 1
      while ($did(%n,7,%b).text) {
        if ($did(%n,7,%b).text == $active) did -c %n 7 %b
        inc %b
      }
    }
  }
  else .timer 1 0 _chanset.updatevars
}
dialog ircNsetup.channel {
  title "Channel Settings"
  size -1 -1 193 178
  option dbu
  icon $gfxdir(icons\ircn.ico), 0
  check "Autocycle Empty Channels", 1, 5 20 82 10, 3state
  check "Kick on Ban", 2, 5 29 52 10, 3state
  check "Set Mode on Join:", 3, 5 49 66 10, 3state
  edit "", 4, 72 49 29 11, autohs
  check "Kick counter", 5, 5 69 67 10, 3state
  check "Voice all users", 6, 5 79 63 10, 3state
  text "Channel:", 31, 98 5 78 10
  combo 7, 130 4 51 53, size drop
  text "Network:", 8, 5 5 78 10
  combo 9, 33 4 51 53, size drop
  check "Auto Set Topic", 10, 5 89 67 9
  check "Hold Mode:", 11, 5 59 57 10
  edit "", 12, 72 60 29 11, autohs
  check "Hold Topic", 13, 5 99 50 9
  check "Clear Bans on Join", 17, 5 39 61 10, 3state
  button "&OK", 100, 109 160 37 12, hide default ok
  button "&Cancel", 101, 148 160 37 12, hide cancel
  text "A filled checkbox means that it is the default value inherited from its parent (On/Off/Default). Settings Priority: (Network+Channel > Network+Global Chan > Global Network). If a box is set to default it will inherit the setting from the one above.", 14, 4 129 186 29
  text "TIP:", 15, 5 119 24 7

}

on 1:dialog:ircnsetup.channel:sclick:100:_chanset.save
on 1:dialog:ircNsetup.channel:init:0:{
  _tmpdlg.hashopen
  _ircn.setup.addnetcombo $dname 9
  .timer 1 0 _chanset.updatevars
  did -i $dname 7 1 Global
  did -c $dname 7 1
  did -b $dname 7
}
on *:dialog:ircNsetup.channel:close:0:.timer 1 1 _tmpdlgdel.hash $dname
on 1:dialog:ircNsetup.channel:sclick:1,2,3,5,6,17:{
  if (($did(9) == Global) && ($did($did).state == 2)) { did -u $dname $did }
  tmpdlgset $dname $did(9) $did(7) $did $did($did).state
}
on 1:dialog:ircNsetup.channel:sclick:10:{
  tmpdlgset $dname $did(9) $did(7) $did $did($did).state
  if ($did($did).state == 1) {
    var %b
    if ($tmpdlgget($dname,$did(9),$did(7),$+($did,.,topic))) set %b $ifmatch
    elseif ($changet($did(7),$tab(autosettopic,topic),$net2scid($did(9)))) set %b $ifmatch

    var %a = $input(What topic do you want to use?,e,Topic?,%b)
    if ((!%a) && (%b)) { if ($input(Use empty topic? $crlf Click No to use %b,yv) == $no) { set %a %b } }
    tmpdlgset $dname $did(9) $did(7) $did $+ . $+ topic %a
  }
}
on 1:dialog:ircNsetup.channel:sclick:11:{
  tmpdlgset $dname $did(9) $did(7) $did $did($did).state
}
on 1:dialog:ircNsetup.channel:sclick:13:{
  tmpdlgset $dname $did(9) $did(7) $did $did($did).state
  if ($did($did).state == 1) {
    var %b
    if ($tmpdlgget($dname,$did(9),$did(7),$+($did,.,topic))) set %b $ifmatch
    elseif ($changet($did(7),$tab(holdtopic,topic),$net2scid($did(9)))) set %b $ifmatch

    var %a = $input(What topic do you want to use?,e,Topic?,%b)
    if ((!%a) && (%b)) { if ($input(Use empty topic? $crlf Click No to use %b,yv) == $no) { set %a %b } }
    tmpdlgset $dname $did(9) $did(7) $did $+ . $+ topic %a
  }
}
on 1:dialog:ircNsetup.channel:edit:12:{
  tmpdlgset $dname $did(9) $did(7) $did $did($did).text
}
on 1:dialog:ircNsetup.channel:edit:4:{
  tmpdlgset $dname $did(9) $did(7) $did $did($did).text
}

on 1:dialog:ircNsetup.channel:sclick:9:{
  if ($did(9)) {
    if ($did(9).sel == 2) did -c $dname 9 $iif($did(9,$pls($did(9).sel,1)),$pls($did(9).sel,1),$sub($did(9).sel,1))
    if ($did(9).sel <= 2) { did -c $dname 7 1 | did -b $dname 7 | did -e $dname 5 }
    else { did -e $dname 7 | did -b $dname 5 | _ircn.setup.addchancombo $dname 7 $did(9) }
    did -c $dname 7 1
  }
  .timer 1 0 _chanset.updatevars
  ;  .timer 1 0 _chanset.updatecomboinfo
}
on 1:dialog:ircNsetup.channel:sclick:7:{
  if ($did(7)) {
    if ($did(7).sel == 2) did -c $dname 7 $iif($did(7,$pls($did(7).sel,1)),$pls($did(7).sel,1),$sub($did(7).sel,1))
  }
  .timer 1 0 _chanset.updatevars
  .timer 1 0 _chanset.updatecomboinfo
}
alias _chanset.updatecomboinfo {
  var %d = ircNsetup.channel
  tmpdlggset %d combos $addtok($tmpdlggget(%d,combos),$tab($did(%d,9),$did(%d,7)),44)
}
alias _chanset.updatevars {
  _chanset.updatecomboinfo
  var %x = ircNsetup.channel
  if ($tmpdlggget(%x,combos) == $null) tmpdlgget %x combos $tab(Global,Global)
  if (!$tmpdlgget(%x,$did(ircNsetup.channel,9),$did(ircNsetup.channel,7),1)) {
    var %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k
    set %a $iif($did(%x,9) == Global,$nvar(autocycle),$nget($net2scid($did(%x,9)),$tab(chan,$did(%x,7),autocycle)))
    set %b $iif($did(%x,9) == Global,$nvar(kickonban),$nget($net2scid($did(%x,9)),$tab(chan,$did(%x,7),kickonban)))
    set %c $iif($did(%x,9) == Global,$nvar(setmodeonjoin),$nget($net2scid($did(%x,9)),$tab(chan,$did(%x,7),setmodeonjoin)))
    set %d $iif($did(%x,9) == Global,$nvar(kickcounter),$nget($net2scid($did(%x,9)),$tab(chan,$did(%x,7),kickcounter)))
    set %e $iif($did(%x,9) == Global,$nvar(voiceall),$nget($net2scid($did(%x,9)),$tab(chan,$did(%x,7),voiceall)))
    set %k $iif($did(%x,9) == Global,$nvar(clearbans),$nget($net2scid($did(%x,9)),$tab(chan,$did(%x,7),clearbans)))

    set %f $iif($did(%x,9) == Global,$nvar(onjoinmode),$nget($net2scid($did(%x,9)),$tab(chan,$did(%x,7),onjoinmode)))
    if ((!%f) && ($did(%x,9) != Global)) {
      if ($tmpdlgget(%x,$did(%x,9),global,4)) set %f $ifmatch
      elseif ($nget($net2scid($did(%x,9)),$tab(chan,global,onjoinmode))) set %f $ifmatch
      else set %f $nvar(onjoinmode)
    }

    tmpdlgset %x $did(%x,9) $did(%x,7) 1 $iif(($did(%x,9) == Global) && ($onoffdef2nro(%a) == 2),0,$onoffdef2nro(%a))
    tmpdlgset %x $did(%x,9) $did(%x,7) 2 $iif(($did(%x,9) == Global) && ($onoffdef2nro(%b) == 2),0,$onoffdef2nro(%b))
    tmpdlgset %x $did(%x,9) $did(%x,7) 3 $iif(($did(%x,9) == Global) && ($onoffdef2nro(%c) == 2),0,$onoffdef2nro(%c))
    tmpdlgset %x $did(%x,9) $did(%x,7) 4 %f
    tmpdlgset %x $did(%x,9) $did(%x,7) 5 $iif(($did(%x,9) == Global) && ($onoffdef2nro(%d) == 2),0,$onoffdef2nro(%d))
    tmpdlgset %x $did(%x,9) $did(%x,7) 6 $iif(($did(%x,9) == Global) && ($onoffdef2nro(%e) == 2),0,$onoffdef2nro(%e))

    if (($did(%x,9) != Global) && ($did(%x,7) != Global)) {
      set %g $changet($did(%x,7),autosettopic,$net2scid($did(%x,9)))
      set %h $changet($did(%x,7),holdmode,$net2scid($did(%x,9)))
      set %j $changet($did(%x,7),holdtopic,$net2scid($did(%x,9)))
      set %i $changet($did(%x,7),$tab(holdmode,mode),$net2scid($did(%x,9)))

      tmpdlgset %x $did(%x,9) $did(%x,7) 10 $onoff2nro(%g)
      tmpdlgset %x $did(%x,9) $did(%x,7) 11 $onoff2nro(%h)
      tmpdlgset %x $did(%x,9) $did(%x,7) 12 %i
      tmpdlgset %x $did(%x,9) $did(%x,7) 13 $onoff2nro(%j)
    }

    tmpdlgset %x $did(%x,9) $did(%x,7) 17 $iif(($did(%x,9) == Global) && ($onoffdef2nro(%k) == 2),0,$onoffdef2nro(%k))

  }
  .timer 1 0 _chanset.updatedids
}
alias _chanset.updatedids {
  var %x = ircNsetup.channel
  did -u %x 1,2,3,5,6,10,11,13
  did -r %x 4,12
  var %a,%b, %c, %d, %e, %f, %g, %h, %i, %j, %k
  set %a $tmpdlgget(%x,$did(%x,9),$did(%x,7),1)
  set %b $tmpdlgget(%x,$did(%x,9),$did(%x,7),2)
  set %c $tmpdlgget(%x,$did(%x,9),$did(%x,7),3)
  set %d $tmpdlgget(%x,$did(%x,9),$did(%x,7),5)
  set %e $tmpdlgget(%x,$did(%x,9),$did(%x,7),6)
  set %f $tmpdlgget(%x,$did(%x,9),$did(%x,7),4)

  if ($did(%x,7).lines <= 2) || ($did(%x,9).sel == 1) did -b %x 7
  else did -e %x 7

  if (($did(%x,9).sel == 1) || ($did(%x,7).sel == 1)) {
    did -b %x 10,11,12,13
  }
  else {
    did -e %x 10,11,12,13
  }
  set %g $tmpdlgget(%x,$did(%x,9),$did(%x,7),10)
  set %h $tmpdlgget(%x,$did(%x,9),$did(%x,7),11)
  set %i $tmpdlgget(%x,$did(%x,9),$did(%x,7),12)
  set %j $tmpdlgget(%x,$did(%x,9),$did(%x,7),13)
  set %k $tmpdlgget(%x,$did(%x,9),$did(%x,7),17)

  did $iif(%a == 1,-c,$iif(%a != 2,-u,-cu)) %x 1
  did $iif(%b == 1,-c,$iif(%b != 2,-u,-cu)) %x 2
  did $iif(%c == 1,-c,$iif(%c != 2,-u,-cu)) %x 3
  did -a %x 4 %f
  did $iif(%d == 1,-c,$iif(%d != 2,-u,-cu)) %x 5
  did $iif(%e == 1,-c,$iif(%e != 2,-u,-cu)) %x 6

  did $iif(%g == 1,-c,-u) %x 10
  did $iif(%h == 1,-c,-u) %x 11
  did -a %x 12 %i
  did $iif(%j == 1,-c,-u) %x 13

  did $iif(%k == 1,-c,$iif(%k != 2,-u,-cu)) %x 17
}
alias _chanset.save {
  var %a, %b, %c, %x, %y
  var %dlgd = ircNsetup.channel
  if (!$dialog(%dlgd)) return

  set %a 1
  while ($gettok($tmpdlggget(%dlgd,combos),%a,44)) {
    set %b $ifmatch
    if (%b == $tab(global,global)) set %c nvar
    else set %c nset $net2scid($gettok(%b,1,9))

    $iif(%c == nvar, %c autocycle $nro2onoff( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),1)), %c  $tab(chan,$gettok(%b,2,9),autocycle) $nro2onoffdef( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),1)) )
    $iif(%c == nvar, %c kickonban $nro2onoff( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),2)), %c  $tab(chan,$gettok(%b,2,9),kickonban) $nro2onoffdef( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),2)) )
    $iif(%c == nvar, %c setmodeonjoin $nro2onoff( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),3)), %c  $tab(chan,$gettok(%b,2,9),setmodeonjoin) $nro2onoffdef( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),3)) )
    $iif(%c == nvar, %c onjoinmode $nro2onoff( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),4)), %c  $tab(chan,$gettok(%b,2,9),onjoinmode) $nro2onoffdef( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),4)) )
    $iif(%c == nvar, %c kickcounter $nro2onoff( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),5)), %c  $tab(chan,$gettok(%b,2,9),kickcounter) $nro2onoffdef( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),5)) )
    $iif(%c == nvar, %c voiceall $nro2onoff( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),6)), %c  $tab(chan,$gettok(%b,2,9),voiceall) $nro2onoffdef( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),6)) )

    if (!$istok(%b,global,9)) {
      channset $net2scid($gettok(%b,1,9)) $gettok(%b,2,9) autosettopic  $nro2onoff($tmpdlgget(%dlgd, $gettok(%b,1,9),$gettok(%b,2,9),10))
      channset $net2scid($gettok(%b,1,9)) $gettok(%b,2,9) $tab(autosettopic,topic) $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),10.topic)
      channset $net2scid($gettok(%b,1,9)) $gettok(%b,2,9) holdmode $nro2onoff($tmpdlgget(%dlgd, $gettok(%b,1,9),$gettok(%b,2,9),11))
      channset $net2scid($gettok(%b,1,9)) $gettok(%b,2,9) holdtopic $nro2onoff($tmpdlgget(%dlgd, $gettok(%b,1,9),$gettok(%b,2,9),13))
      channset $net2scid($gettok(%b,1,9)) $gettok(%b,2,9) $tab(holdtopic,topic) $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),13.topic)
      channset $net2scid($gettok(%b,1,9)) $gettok(%b,2,9) $tab(holdmode,mode)  $iif($tmpdlgget(%dlgd,$gettok(%b,1,9),$gettok(%b,2,9),12) !=  0,$tmpdlgget(%dlgd,$gettok(%b,1,9),$gettok(%b,2,9),12))
    }

    $iif(%c == nvar, %c clearbans $nro2onoff( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),17)), %c  $tab(chan,$gettok(%b,2,9),clearbans) $nro2onoffdef( $tmpdlgget(%dlgd,  $gettok(%b,1,9),$gettok(%b,2,9),17)) )


    inc %a
  }

  if ( $nro2onoff($tmpdlgget(%dlgd, $gettok(%b,1,9),$gettok(%b,2,9),11)) == on) {
    ;hold mode
    scid $net2scid($gettok(%b,1,9))
    set %a $changet($gettok(%b,2,9),$tab(holdmode,mode),$net2scid($gettok(%b,1,9)))
    if (($me ison $gettok(%b,2,9)) && ($me isop $gettok(%b,2,9))) mode $gettok(%b,2,9) %a
    scid -r 
  }

  if ( $nro2onoff($tmpdlgget(%dlgd, $gettok(%b,1,9),$gettok(%b,2,9),13)) == on) {
    ;hold topic
    scid $net2scid($gettok(%b,1,9))
    set %a $changet($gettok(%b,2,9),$tab(holdtopic,topic),$net2scid($gettok(%b,1,9)))
    if (t !isincs $chan($gettok(%b,2,9)).mode) topic $gettok(%b,2,9) %a
    elseif (($me ison $gettok(%b,2,9)) && ($me isop $gettok(%b,2,9))) topic $gettok(%b,2,9) %a
    ht $gettok(%b,2,9) %a
    scid -r
  }
  else {
    scid $net2scid($gettok(%b,1,9))
    .ut $gettok(%b,2,9)
    scid -r
  }

  _tmpdlgdel.hash %dlgd
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General settings dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias gensettings {
  if ($istok(%ircnsetup.docked,ircnsetup.general,44)) return
  dlg -r ircnsetup.general
  dialog -rsb ircnsetup.general -1 -1 191 169
  did -v ircnsetup.general 100,101
}

dialog ircnsetup.general {
  title "General Settings"
  size -1 -1 58 0
  option dbu
  icon $gfxdir(icons\ircn.ico), 0
  button "&OK", 100, 111 151 37 13, hide default ok
  button "&Cancel", 101, 150 151 37 13, hide cancel
  tab "Main", 22, 5 4 182 142
  check "Splash Screen on Start", 8, 13 42 72 10, tab 22
  text "minutes", 3, 95 27 26 11, tab 22
  edit "", 2, 71 26 21 12, tab 22 center
  text "Save settings every:", 1, 12 27 56 10, tab 22
  check "Check for Unverified Scripts on Start", 21, 13 52 111 11, tab 22
  check "Check for Updates on Start (not done)", 11, 13 124 100 11, disable tab 22
  check "Disable crashed ircN dialog on Start", 32, 13 62 112 11, tab 22
  check "Disable tool-tips on dialog creation", 33, 13 72 112 11, hide tab 22
  tab "Options I", 23
  check "Compact Switchbar", 7, 11 27 74 10, tab 23
  check "Copy IP on DNS", 4, 11 47 72 10, tab 23
  check "Close query when user quits", 9, 11 57 94 11, tab 23
  check "Whowas on no whois", 10, 11 79 62 11, tab 23
  check "Close Idle Queries after", 12, 11 68 79 11, disable tab 23
  edit "", 13, 92 69 21 12, disable tab 23
  combo 20, 115 69 26 28, disable tab 23 size drop
  button "default ban mask", 6, 132 25 51 13, tab 23
  check "Notify on new day changes", 34, 11 125 82 11, tab 23
  check "Auto update cache on menu", 36, 30 101 100 11, tab 23
  check "Cache whois information", 35, 11 90 74 11, tab 23
  check "Compact Custom Windows only", 38, 11 37 102 10, tab 23
  check "Notify clock every:", 39, 11 114 61 11, tab 23
  radio "hour", 40, 74 115 27 10, tab 23 disable
  radio "half hour", 41, 102 115 43 10, tab 23 disable
  tab "Options II", 37
  text "Minimum lag before echo:", 17, 31 40 70 10, tab 37
  edit "", 18, 98 38 21 12, tab 37 center
  text "secs", 19, 122 39 19 10, tab 37
  check "Notify on lag", 5, 11 27 72 10, tab 37
  tab "Lists", 24
  text "users", 16, 83 53 19 8, tab 24
  edit "", 15, 58 51 23 12, tab 24 autohs center
  text "Maximum:", 14, 26 53 31 10, tab 24
  box "Internal Address List", 25, 11 26 104 55, tab 24
  text "Update IAL:", 26, 17 37 39 10, tab 24
  combo 27, 58 37 53 35, tab 24 size drop
  box "Internal Ban List", 28, 11 82 104 30, tab 24
  combo 30, 58 94 53 35, tab 24 size drop
  text "Update IBL:", 29, 18 95 39 10, tab 24
  check "Queue /who (BNC fix)", 31, 27 66 79 9, tab 24
}


on 1:dialog:ircnsetup.general:init:0:{
  if ($nvar(splash) == on) did -c $dname 8
  if ($nvar(tinyswitchbar) == on) did -c $dname 7
  if ($nvar(ipondns) == on) did -c $dname 4
  if ($nvar(lagstat) == on) did -c $dname 5
  if ($nvar(closequeryonquit) == on) did -c $dname 9
  if ($nvar(whowasonnowhois) == on) did -c $dname 10
  if ($nvar(checkupdates) == on) did -c $dname 11
  if ($nvar(checkscripts.unknown) != off) did -c $dname 21
  if ($nvar(queuedwho) == on) did -c $dname 31
  if ($nvar(crash.suppressdlg) == on) did -c $dname 32
  if ($nvar(daychange) == on) did -c $dname 34


  did -ra $dname 2 $iif(%savetime isnum,%savetime,5)

  did -ra $dname 15 $iifelse($nvar(maxial), 300)
  did -ra $dname 18 $iifelse($nvar(lagstat.time), 5)

  ;  if ($nvar(query.closeidle) == on) { did -c $dname 12 | did -e $dname 13,20) }
  ;  if ($nvar(query.closeidle.time) isnum) did -ra $dname 13 $ifmatch
  did -a $dname 20 mins
  did -a $dname 20 hrs
  did -c $dname 20 $iif($nvar(query.closeidle.type) == hrs,2,1)

  did -a $dname 27,30 Never (Manual)
  did -a $dname 27,30 On Join
  did -a $dname 27,30 On Op    


  did -c $dname 27 $iif($nvar(ialupd) == never, 1, $iif($nvar(ialupd) == op, 3, 2))
  did -c $dname 30 $iif($nvar(iblupd) == never, 1, $iif($nvar(iblupd) == join, 2, 3))


  did $iif($did(5).state,-e,-b) $dname 17-19
}
alias _save.general {
  var %d = ircnsetup.general
  if (!$dialog(%d)) return
  nvar splash $nro2onoff($did(%d,8).state)
  nvar ipondns $nro2onoff($did(%d,4).state)
  nvar lagstat $nro2onoff($did(%d,5).state)
  nvar closequeryonquit $nro2onoff($did(%d,9).state)
  nvar whowasonnowhois $nro2onoff($did(%d,10).state)
  nvar checkupdates $nro2onoff($did(%d,11).state)
  nvar query.closeidle $nro2onoff($did(%d,12).state)
  nvar queuedwho $nro2onoff($did(%d,31).state)
  nvar crash.suppressdlg $nro2onoff($did(%d,32).state)
  nvar daychange $nro2onoff($did(%d,34).state)

  if (($remove($did(%d,2),5) isnum) && ($remove($did(%d,2),5)))   set %savetime $did(%d,2)
  else unset %savetime 

  if (($did(%d,15) isnum) && ($did(%d,15) < 1000)) nvar maxial $did(%d,15)
  if (($did(%d,18) isnum) && ($did(%d,18) < 100)) nvar lagstat.time $did(%d,18)

  if ($did(%d,13) isnum) {
    nvar query.closeidle.time $did(%d,13)
    nvar query.closeidle.type $did(%d,20)
  }
  nvar checkscripts.unknown $iif(!$did(%d,21).state,off)

  nvar ialupd $gettok($removecs($did(%d,27).seltext,On),1,32)
  nvar iblupd $gettok($removecs($did(%d,30),seltext,On),1,32)


  tinysb $nro2onoffdef($did(%d,7).state)
}

on 1:dialog:ircnsetup.general:sclick:100: _save.general
on 1:dialog:ircnsetup.general:sclick:12:did $iif($did($did).state,-e,-b) $dname 13,20
on 1:dialog:ircnsetup.general:sclick:5:did $iif($did($did).state,-e,-b) $dname 17-19
on 1:dialog:ircnsetup.general:sclick:6: dlg ircn.setbanmask
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; User settings dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircNsetup.usersettings {
  title "ircN User Settings"
  size -1 -1 0 0
  option dbu
  icon $gfxdir(icons\ircn.ico), 0
  box "Bot Options", 10, 9 2 78 80
  check "Auto Get Ops", 11, 16 12 59 12
  check "Auto Op", 12, 16 23 58 12
  check "Reop Bot", 13, 16 34 59 12
  check "Voice on Bot Deop", 14, 16 45 68 12
  check "Auto Pass", 15, 16 56 60 12
  box "User Access", 30, 91 2 77 29
  check "Allow User Bans", 31, 96 9 68 10
  check "Enable CHAN ctcp", 32, 96 19 69 10
  box "Info Line", 40, 91 32 77 50
  check "Enabled", 41, 96 40 55 10
  text "Left Bracket:", 42, 96 52 45 10
  edit "", 43, 142 50 16 11, autohs
  text "Right Bracket:", 44, 96 66 45 10
  edit "", 45, 142 64 16 11, autohs
  box "Bitch Mode", 50, 52 84 88 65
  check "Enabled", 51, 59 121 38 10, 3state
  text "Channel:", 52, 56 106 28 10
  check "Revenge", 54, 59 131 38 10, 3state
  combo 1, 84 105 51 42, size drop
  button "+", 2, 215 53 8 8, hide
  button "-", 3, 216 65 8 8, hide
  combo 4, 84 92 51 39, size drop
  text "Network:", 5, 56 93 27 10
  combo 6, 97 131 33 42, size drop


  button "OK", 99, 91 155 39 16, hide default ok
  button "Cancel", 98, 133 155 39 16, hide default cancel
}


on *:dialog:ircNsetup.usersettings:sclick:2:{
  if ($did(1,0)) { did -a $dname 1 $did(1,0) | did -i $dname 1 0 }
}

on *:dialog:ircnsetup.usersettings:sclick:99:_save.usersettings

on *:dialog:ircNsetup.usersettings:sclick:51,54:{
  if (($did(4) == Global) && ($did($did).state == 2)) { did -u $dname $did }
  tmpdlgset $dname $did(4) $did(1) $did $did($did).state

  if ($did == 51) {
    did -b $dname 54
    if ($tmpdlgget($dname,$did(4),$did(1),$did) == 1) did -e $dname 54
    elseif (($tmpdlgget($dname,$did(4),$did(1),$did) == 2) && ($tmpdlgget($dname,$did(4),Global,$did) == 1)) did -e $dname 54
    elseif (($tmpdlgget($dname,$did(4),$did(1),$did) == 2) && ($tmpdlgget($dname,$did(4),Global,$did) == 2) && ($tmpdlgget($dname,Global,Global,$did) == 1)) did -e $dname 54
  }
}
on *:dialog:ircNsetup.usersettings:sclick:3:{
  if ($did(1).sel) { did -d $dname 1 $did(1).sel }
}
on *:dialog:ircNsetup.usersettings:sclick:4:{
  if ($did(4).sel == 2) { did -c $dname 4 $iif($did(4,$pls($did(4).sel,1)),$pls($did(4).sel,1),$sub($did(4).sel,1)) }
  if ($did(4).sel > 2) { did -e $dname 1 | _ircn.setup.addchancombo $dname 1 $did(4) | did -f $dname 1 1 }
  else { did -b $dname 1 | did -c $dname 1 1 }

  .timer 1 0 _usersetting.updatecombo
  .timer 1 0 _usersetting.updatedids
}
on *:dialog:ircNsetup.usersettings:sclick:1:{
  if ($did(1).sel == 2) { did -c $dname 1 $iif($did(1,$pls($did(1).sel,1)),$pls($did(1).sel,1),$sub($did(1).sel,1)) }
  ;if ($did(1).sel > 2) { iecho ADD LOADING OF DID SETTINGS }
  ;else { iecho ADD LOADING OF NETWORK'S GLOBAL DID SETTINGS }

  .timer 1 0 _usersetting.updatecombo
  .timer 1 0 _usersetting.updatedids
}
alias _usersetting.updatecombo {
  var %d = ircNsetup.usersettings
  tmpdlggset %d combos $addtok($tmpdlggget(%d,combos),$tab($did(%d,4),$did(%d,1)),44)
}
alias _usersetting.updatedids {
  var %d = ircNsetup.usersettings
  if ($tmpdlgget(%d,$did(%d,4),$did(%d,1),51) == 1) did -c %d 51
  elseif ($tmpdlgget(%d,$did(%d,4),$did(%d,1),51) == 0) did -u %d 51
  else did $iif($did(%d,4) != Global,-cu,-u) %d 51

  if ($tmpdlgget(%d,$did(%d,4),$did(%d,1),54) == 1) did -c %d 54
  elseif ($tmpdlgget(%d,$did(%d,4),$did(%d,1),54) == 0) did -u %d 54
  else did $iif($did(%d,4) != Global,-cu,-u) %d 54

  ; add revengetype here

}

on *:dialog:ircNsetup.usersettings:init:0:{
  var %b, %c, %e, %f, %g, %a = 1
  tmpdlggset $dname combos $tab(global,global)

  did -a $dname 6 Deop
  did -a $dname 6 Kick 
  did -a $dname 6 Kick/Ban
  did -a $dname 6 Shitlist

  while (%a <= $scon(0)) {
    scon %a
    ;set %b $cid $+ .ircN.Settings
    set %b $+($ncid( [ [ $cid ] $+ ] ,network.hash),.ircN.settings)
    set %c 1
    while ($hfind(%b,$tab(chan,*,userlist.strictops),%c,w)) {
      set %f $scid($cid).curnet
      set %e $gettok($hfind(%b,$tab(chan,*,userlist.strictops),%c,w),2,9)
      if (%g != $tab(%f,%e)) {
        tmpdlggset $dname combos $addtok($tmpdlggget($dname,combos),$tab(%f,%e),44)
        ;fix this
        tmpdlgset $dname %f %e 51 $onoffdef2nro($nget($net2scid(%f),$tab(chan,%e,userlist.strictops)))
        tmpdlgset $dname %f %e 54 $onoffdef2nro($nget($net2scid(%f),$tab(chan,%e,userlist.revenge)))
        tmpdlgset $dname %f %e 6 $nget($net2scid(%f),$tab(chan,%e,userlist.revengeaction))

      }
      set %g $tab(%f,%e)
      inc %c
    }
    inc %a
  }
  scon -r
  ;; BLAA WRITE THE LOADING DAMN IT
  tmpdlggset $dname 51 $onoff2nro($nvar(userlist.strictops))
  tmpdlggset $dname 54 $onoff2nro($nvar(userlist.revenge))

  if ($nvar(userlist.strictops) == on) did -c $dname 51
  else ;did -b $dname 1,2,3,4,5,52
  if ($nvar(userlist.revenge) == on) did -c $dname 54
  did -c $dname 6 $iif($nvar(userlist.revengeaction) == kick, 2, $iif($nvar(userlist.revengeaction) == kb, 3, $iif($nvar(userlist.revengeaction == shitlist), 4, 1)))
  if ($nvar(userlist.botautopass) == on) did -c $dname 15
  if ($nvar(userlist.botgetops) == on) did -c $dname 11
  if ($nvar(userlist.reopbot) == on) did -c $dname 13
  if ($nvar(userlist.voiceonbotdeop) == on) did -c $dname 14
  if ($nvar(userlist.autoop) == on) did -c $dname 12
  if ($nvar(userlist.userbans) == on) did -c $dname 31
  if ($nvar(userlist.chanctcp) == on) did -c $dname 32
  if ($nvar(userlist.infolines) == on) did -c $dname 41
  if ($nvar(userlist.infolineleft)) did -ra $dname 43 $ifmatch
  if ($nvar(userlist.infolineright)) did -ra $dname 45 $ifmatch

  _ircn.setup.addchancombo $dname 1
  _ircn.setup.addnetcombo $dname 4
  did -b $dname 1
}
alias _save.usersettings {
  var %x = ircNsetup.usersettings
  if (!$dialog(%x)) return
  nvar userlist.strictops $nro2onoffdef($did(%x,51).state)
  nvar userlist.revenge $nro2onoffdef($did(%x,54).state)
  nvar userlist.revengeaction $iif($did(6).sel == 2, kick, $iif($did(6).sel == 3, kb, $iif($did(6).sel == 4, shitlist, deop)))
  nvar userlist.botautopass $nro2onoffdef($did(%x,15).state)
  nvar userlist.botgetops $nro2onoffdef($did(%x,11).state)
  nvar userlist.reopbot $nro2onoffdef($did(%x,13).state)
  nvar userlist.voiceonbotdeop $nro2onoffdef($did(%x,14).state)
  nvar userlist.autoop $nro2onoffdef($did(%x,12).state)
  nvar userlist.userbans $nro2onoffdef($did(%x,31).state)
  nvar userlist.chanctcp $nro2onoffdef($did(%x,32).state)
  nvar userlist.infolines $nro2onoffdef($did(%x,41).state)
  nvar userlist.infolineleft $did(%x,43)
  nvar userlist.infolineright $did(%x,45)
  var %a = 1
  var %b, %c, %e
  while ($gettok($tmpdlggget(%x,combos),%a,44)) {
    set %b $gettok($gettok($tmpdlggget(%x,combos),%a,44),1,9)
    set %c $gettok($gettok($tmpdlggget(%x,combos),%a,44),2,9)
    if (%b == Global) set %e nvar
    else set %e nset $net2scid(%b)
    %e $iif(%b != Global,$tab(chan,%c,userlist.strictops),userlist.strictops) $nro2onoffdef($tmpdlgget(%x,%b,%c,51))
    %e $iif(%b != Global,$tab(chan,%c,userlist.revenge),userlist.revenge) $nro2onoffdef($tmpdlgget(%x,%b,%c,54))
    %e $iif(%b != Global,$tab(chan,%c,userlist.revengeaction),userlist.revengeaction) $iif($tmpdlgget(%x,%b,%c,6) == 2, kick, $iif($tmpdlgget(%x,%b,%c,6) == 3, kb, $iif($tmpdlgget(%x,%b,%c,6) == 4, shitlist,  deop)))

    %e $iif(%b != Global,$tab(chan,%c,revengeaction),userlist.revengeaction) $iif($tmpdlgget(%x,%b,%c,6) == 2, kick, $iif($tmpdlgget(%x,%b,%c,6) == 3, kb, $iif($tmpdlgget(%x,%b,%c,6) == 4, shitlist,  deop)))

    inc %a
  }
}
on *:DIALOG:ircnsetup.usersettings:sclick:6:tmpdlgset $dname $did(1) $did(4) $did $did(6).sel

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; User settings dialog (new) (not implemented yet)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircNsetup.usersettings.new {
  title "Userlist Settings"
  size -1 -1 193 178
  option dbu
  icon $gfxdir(icons\ircn.ico), 0
  check "Auto Get Ops", 3, 7 30 72 10, 3state
  text "Channel:", 61, 98 5 78 10
  combo 2, 130 4 51 53, size drop
  text "Network:", 60, 4 5 78 10
  combo 1, 33 4 51 53, size drop
  button "&OK", 100, 109 160 37 12, hide default ok
  button "&Cancel", 101, 148 160 37 12, hide cancel
  box "Bot Options", 63, 3 19 79 70
  check "Auto Op Bot", 4, 7 41 72 10, 3state
  check "Reop Bot", 5, 7 52 72 10, 3state
  check "Voice on Bot DeOp", 6, 7 63 72 10, 3state
  check "Auto Partyline Pass", 7, 7 74 72 10, 3state
  check "Allow User Bans", 10, 7 94 72 10, 3state
  check "Enable CHAN Ctcp (glob)", 11, 7 105 72 10, 3state
  check "Info Line on user join", 9, 92 19 86 10, 3state
  check "Bitch Mode", 12, 92 30 39 10, 3state
  check "Revenge", 13, 106 40 35 10
  combo 14, 145 41 27 21, size drop
  check "AutoOp +o users", 8, 7 116 72 10, 3state
  check "AutoVoice +v users", 15, 7 127 72 10, 3state
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ircN color settings (will be replaced by a theme editor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircnsetup.colors {
  title "ircN Colors"
  icon $gfxdir(icons\ircn.ico), 0
  size -1 -1 0 0
  option dbu
  text "Highlight Color:", 1, 14 12 43 8, right
  text "Secondary Color:", 2, 14 22 43 8, right
  text "Alternative Color:", 3, 14 32 43 8, right
  icon 4, 65 12 8 7
  icon 5, 65 22 8 7
  icon 6, 65 32 8 7
  text "User", 7, 116 27 28 8, right
  icon 8, 153 15 8 7
  icon 9, 153 27 8 7
  text "Shitlist", 10, 116 15 28 8, right
  icon 12, 153 39 8 7
  text "Protected", 13, 116 39 28 8, right
  icon 14, 153 51 8 7
  text "Voice", 15, 116 51 28 8, right
  icon 16, 153 63 8 7
  text "Op", 17, 116 63 28 8, right
  icon 18, 153 75 8 7
  text "Bot", 19, 116 75 28 8, right
  icon 20, 153 87 8 7
  text "Master", 21, 116 87 28 8, right
  icon 22, 153 99 8 7
  text "Owner", 23, 116 99 28 8, right
  icon 24, 153 111 8 7
  text "IRCop", 25, 117 111 28 8, right
  box "Nicklist: Userlist", 11, 105 4 74 126
  box "ircN", 26, 4 4 86 42
  box "Nicklist: Channel Mode", 27, 4 51 86 79
  icon 28, 53 68 8 7
  text "Ops", 29, 17 68 28 8, right
  text "Half-Ops", 30, 17 80 28 8, right
  icon 31, 53 80 8 7
  text "Voices", 32, 17 92 28 8, right
  icon 33, 53 92 8 7
  text "Regulars", 34, 17 104 28 8, right
  icon 35, 53 104 8 7
}
alias _save.colors {
  var %d = ircnsetup.colors
  if (!$dialog(%d)) return
  if ($tmpdlggget(%d,colors.hc) != $null) nvar colors.hc $ifmatch
  if ($tmpdlggget(%d,colors.sc) != $null) nvar colors.sc $ifmatch
  if ($tmpdlggget(%d,colors.ac) != $null) nvar colors.ac $ifmatch
  if ($tmpdlggget(%d,colors.nicklist.shitlisted) != $null) nvar colors.nicklist.shitlisted $ifmatch
  if ($tmpdlggget(%d,colors.nicklist.user) != $null) nvar colors.nicklist.user $ifmatch
  if ($tmpdlggget(%d,colors.nicklist.protected) != $null) nvar colors.nicklist.protected $ifmatch
  if ($tmpdlggget(%d,colors.nicklist.voice) != $null) nvar colors.nicklist.voice $ifmatch
  if ($tmpdlggget(%d,colors.nicklist.op) != $null) nvar colors.nicklist.op $ifmatch
  if ($tmpdlggget(%d,colors.nicklist.bot) != $null) nvar colors.nicklist.bot $ifmatch
  if ($tmpdlggget(%d,colors.nicklist.master) != $null) nvar colors.nicklist.master $ifmatch
  if ($tmpdlggget(%d,colors.nicklist.owner) != $null) nvar colors.nicklist.owner $ifmatch
  if ($tmpdlggget(%d,colors.nicklist.ircop) != $null) nvar colors.nicklist.ircop $ifmatch
  if ($tmpdlggget(%d,colors.mIRC.nicklist.ops) != $null) nvar colors.mIRC.nicklist.ops $ifmatch
  if ($tmpdlggget(%d,colors.mIRC.nicklist.halfops) != $null) nvar colors.mIRC.nicklist.halfops $ifmatch
  if ($tmpdlggget(%d,colors.mIRC.nicklist.voices) != $null) nvar colors.mIRC.nicklist.voices $ifmatch
  if ($tmpdlggget(%d,colors.mIRC.nicklist.regulars) != $null) nvar colors.mIRC.nicklist.regulars $ifmatch

  if ($dialog(ircnsetup.display)) {
    if (($did(ircnsetup.display,24).state) && ($nvar(colnick) != on)) .timercolnick 1 1 .colnick on
    elseif (!$did(ircnsetup.display,24).state) && ($nvar(colnick) != off) .timercolnick 1 1 .colnick off
    else .timercolnick 1 1 .colnick
  }
  else .timercolnick 1 1 .colnick
}
alias _updatedlg.colors {
  var %d = ircnsetup.colors
  if (!$dialog(%d)) return
  did -g %d 4 $td(colors\ $+ $base($iifelse($nvar(colors.hc),0),10,10,2) $+ .bmp)
  did -g %d 5 $td(colors\ $+ $base($iifelse($nvar(colors.sc),0),10,10,2) $+ .bmp)
  did -g %d 6 $td(colors\ $+ $base($iifelse($nvar(colors.ac),0),10,10,2) $+ .bmp)

  did -g %d 8 $td(colors\ $+ $base($iifelse($nvar(colors.nicklist.shitlisted),0),10,10,2) $+ .bmp)
  did -g %d 9 $td(colors\ $+ $base($iifelse($nvar(colors.nicklist.user),0),10,10,2) $+ .bmp)
  did -g %d 12 $td(colors\ $+ $base($iifelse($nvar(colors.nicklist.protected),0),10,10,2) $+ .bmp)
  did -g %d 14 $td(colors\ $+ $base($iifelse($nvar(colors.nicklist.voice),0),10,10,2) $+ .bmp)
  did -g %d 16 $td(colors\ $+ $base($iifelse($nvar(colors.nicklist.op),0),10,10,2) $+ .bmp)
  did -g %d 18 $td(colors\ $+ $base($iifelse($nvar(colors.nicklist.bot),0),10,10,2) $+ .bmp)
  did -g %d 20 $td(colors\ $+ $base($iifelse($nvar(colors.nicklist.master),0),10,10,2) $+ .bmp)
  did -g %d 22 $td(colors\ $+ $base($iifelse($nvar(colors.nicklist.owner),0),10,10,2) $+ .bmp)
  did -g %d 24 $td(colors\ $+ $base($iifelse($nvar(colors.nicklist.ircop),0),10,10,2) $+ .bmp)

  did -g %d 28 $td(colors\ $+ $base($iifelse($nvar(colors.mIRC.nicklist.ops),0),10,10,2) $+ .bmp)
  did -g %d 31 $td(colors\ $+ $base($iifelse($nvar(colors.mIRC.nicklist.halfops),0),10,10,2) $+ .bmp)
  did -g %d 33 $td(colors\ $+ $base($iifelse($nvar(colors.mIRC.nicklist.voices),0),10,10,2) $+ .bmp)
  did -g %d 35 $td(colors\ $+ $base($iifelse($nvar(colors.mIRC.nicklist.regulars),0),10,10,2) $+ .bmp)

  if ($tmpdlggget(%d,colors.hc)) tmpdlggset %d colors.hc $nvar(colors.hc)
  if ($tmpdlggget(%d,colors.sc)) tmpdlggset %d colors.sc $nvar(colors.sc)
  if ($tmpdlggget(%d,colors.ac)) tmpdlggset %d colors.ac $nvar(colors.ac)
  if ($tmpdlggget(%d,colors.nicklist.shitlisted)) tmpdlggset %d colors.nicklist.shitlisted $nvar(colors.nicklist.shitlisted)
  if ($tmpdlggget(%d,colors.nicklist.user)) tmpdlggset %d colors.nicklist.user $nvar(colors.nicklist.user)
  if ($tmpdlggget(%d,colors.nicklist.protected)) tmpdlggset %d colors.nicklist.protected $nvar(colors.nicklist.protected)
  if ($tmpdlggget(%d,colors.nicklist.voice)) tmpdlggset %d colors.nicklist.voice $nvar(colors.nicklist.voice)
  if ($tmpdlggget(%d,colors.nicklist.op)) tmpdlggset %d colors.nicklist.op $nvar(colors.nicklist.op)
  if ($tmpdlggget(%d,colors.nicklist.bot)) tmpdlggset %d colors.nicklist.bot $nvar(colors.nicklist.bot)
  if ($tmpdlggget(%d,colors.nicklist.master)) tmpdlggset %d colors.nicklist.master $nvar(colors.nicklist.master)
  if ($tmpdlggget(%d,colors.nicklist.owner)) tmpdlggset %d colors.nicklist.owner $nvar(colors.nicklist.owner)
  if ($tmpdlggget(%d,colors.nicklist.ircop)) tmpdlggset %d colors.nicklist.ircop $nvar(colors.nicklist.ircop)
  if ($tmpdlggget(%d,colors.mIRC.nicklist.ops)) tmpdlggset %d colors.mIRC.nicklist.ops $nvar(colors.mIRC.nicklist.ops)
  if ($tmpdlggget(%d,colors.mIRC.nicklist.halfops)) tmpdlggset %d colors.mIRC.nicklist.halfops $nvar(colors.mIRC.nicklist.halfops)
  if ($tmpdlggget(%d,colors.mIRC.nicklist.voices)) tmpdlggset %d colors.mIRC.nicklist.voices $nvar(colors.mIRC.nicklist.voices)
  if ($tmpdlggget(%d,colors.mIRC.nicklist.regulars)) tmpdlggset %d colors.mIRC.nicklist.regulars $nvar(colors.mIRC.nicklist.regulars)
}
on *:dialog:ircnsetup.colors:init:0:{
  _refreshcolorgfx
  _updatedlg.colors
}
on 1:dialog:ircnsetup.colors:sclick:4,5,6,8,9,12,14,16,18,20,22,24,28,31,33,35:{
  if ($dialog(ircn.mirccolors))  return
  var %a = $dialog(ircn.mirccolors,ircn.mirccolors)
  var %a = $base(%mirccolorsdlg.result,10,10,2)
  if (%a !isnum) return
  if ($did == 4) tmpdlggset $dname colors.hc %a
  if ($did == 5) tmpdlggset $dname colors.sc %a
  if ($did == 6) tmpdlggset $dname colors.ac %a
  if ($did == 8) tmpdlggset $dname colors.nicklist.shitlisted %a
  if ($did == 9) tmpdlggset $dname colors.nicklist.user %a
  if ($did == 12) tmpdlggset $dname colors.nicklist.protected %a
  if ($did == 14) tmpdlggset $dname colors.nicklist.voice %a
  if ($did == 16) tmpdlggset $dname colors.nicklist.op %a
  if ($did == 18) tmpdlggset $dname colors.nicklist.bot %a
  if ($did == 20) tmpdlggset $dname colors.nicklist.master %a
  if ($did == 22) tmpdlggset $dname colors.nicklist.owner %a
  if ($did == 24) tmpdlggset $dname colors.nicklist.ircop %a
  if ($did == 28) tmpdlggset $dname colors.mIRC.nicklist.ops %a
  if ($did == 31) tmpdlggset $dname colors.mIRC.nicklist.halfops %a
  if ($did == 33) tmpdlggset $dname colors.mIRC.nicklist.voices %a
  if ($did == 35) tmpdlggset $dname colors.mIRC.nicklist.regulars %a

  did -g $dname $did $td(colors\ $+ $base(%a,10,10,2) $+ .bmp)
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Default banmask dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircN.setbanmask {
  title "Default Ban Host Mask"
  icon $gfxdir(icons\ircn.ico), 0
  size -1 -1 164 102
  option dbu
  list 1, 1 3 160 81, size
  button "&OK", 2, 132 87 30 12,ok default
}
on 1:dialog:ircN.setbanmask:init:0:{
  var %a = 0, %b = $iif(($address($me,0) && !$isip($address($me,0))),$address($me,0),nickname!ident@user-123456.dsl.host.com)
  while (%a <= 19) {
    did -a $dname 1 $lfix2(2,%a) $+ : $mask(%b,%a)
    inc %a
  }
  if ($nvar(kbmask)) did -c $dname 1 $pls($nvar(kbmask),1)
  else did -c $dname 1 4
}
on 1:dialog:ircN.setbanmask:sclick:2:nvar kbmask $calc($did(1).sel - 1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Update dialog (unfinished)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircnsetup.update {
  title "Update"
  icon $gfxdir(icons\ircn.ico), 0
  size -1 -1 184 142
  option dbu
  tab "ircN", 1, 1 1 181 139
  list 4, 5 20 174 115, tab 1 size
  tab "Modules", 2
  list 5, 5 20 174 115, tab 2 size
  tab "Themes", 3
  list 6, 5 20 174 115, tab 3 size
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Modules dialog (Core)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias modulesdlg {
  dlg -r ircn.modules
}
dialog ircn.modules {
  title "ircN Modules [/modules]"
  icon $gfxdir(icons\ircn.ico), 0
  size -1 -1 204 140
  option dbu
  list 1, 6 17 81 98, size
  list 2, 117 18 81 98, size
  box "Loaded:", 3, 3 7 87 112
  box "Unloaded:", 4, 114 7 87 112
  button "<-", 5, 94 52 17 12
  button "->", 6, 94 67 17 12
  button "&Close", 7, 164 125 37 12, ok
  text "Double-click module for more information", 8, 3 122 126 10
}
on *:dialog:ircn.modules:init:0:_ircn.modules.refresh
on *:dialog:ircn.modules:close:0:if ($dialog(ircn.modinfo)) dialog -x ircn.modinfo
on *:dialog:ircn.modules:dclick:1,2:{
  modinfodlg $did($did).seltext
}
on *:dialog:ircn.modules:sclick:5,6:{
  if (!$did($iif($did == 6,1,2)).sel) return
  if ($did == 5) .timer 1 0 module $did(2).seltext
  else .timer 1 0 unmod $did(1).seltext
  did -a $dname $iif($did == 6,2,1) $did($iif($did == 6,1,2)).seltext
  did -d $dname $iif($did == 6,1,2) $did($iif($did == 6,1,2)).sel
}
alias _ircn.modules.refresh {
  var %a = 1, %b, %d = ircn.modules
  var %mods = $findfile($md,*.mod,0)
  did -r %d 1,2
  while (%a <= %mods) {
    set %b $findfile($md,*.mod,%a)
    did -a %d $iif($ismod($nopath(%b)),1,2) $deltok($nopath(%b),-1,46)
    inc %a
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias modinfodlg {
  if (!$0) return
  if (!$isfile($md($+($1,.mod)))) return
  var %d = ircn.modinfo, %b = $md($+($1,.mod))
  dlg -r %d
  dialog -sb %d $calc($dialog(ircn.modules).x + $dialog(ircn.modules).w) $dialog(ircn.modules).y 152 140
  did -ra %d 1 $modinfo(%b,module)
  did -ra %d 2 $modinfo(%b,version)
  did -ra %d 3 $modinfo(%b,author)
  did -ra %d 4 $modinfo(%b,email)
  did -ra %d 11 $iifelse($modinfo(%b,description),none)
}
dialog ircn.modinfo {
  title "Module information"
  icon $gfxdir(icons\ircn.ico), 0
  size -1 -1 152 140
  option dbu
  text "", 1, 69 14 75 12, right
  text "", 2, 69 27 75 12, right
  text "", 3, 69 40 75 12, right
  box "Info:", 5, 4 4 144 72
  text "Name:", 6, 9 14 36 12
  text "Version:", 7, 9 27 36 12
  text "Author:", 8, 9 40 36 12
  text "Author's email:", 9, 7 53 44 12
  text "", 4, 68 53 76 12, right
  box "Description:", 10, 4 78 144 43
  text "", 11, 8 88 136 28
  button "&Close", 12, 111 123 37 10, ok
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; bad words
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircn.badwords {
  title "New Project"
  size -1 -1 193 170
  option dbu
  combo 13, 180 3 0 0, size
  tab "Channel", 11, -4 -16 261 200
  combo 14, 32 5 52 16, tab 11 size drop
  text "Channel:", 15, 87 5 27 12, tab 11
  combo 16, 115 5 52 16, tab 11 size drop
  text "Network:", 12, 4 5 27 12, tab 11
  tab "Personal", 17
  combo 1, 7 22 95 104, size
  box "Settings", 7, 107 20 82 146
  check "Censor out word with ****", 10, 8 125 94 13
  button "Edit Actions", 8, 134 38 45 12
  text "Action:", 9, 111 39 21 11
  button "Add", 2, 7 140 30 12
  button "Rem", 3, 39 140 30 12
  button "Clear", 4, 71 140 30 12
  button "Save List", 6, 55 154 46 12
  button "Load List", 5, 7 154 46 12
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Wizard dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircn.wizard {
  title "ircN Setup Wizard"
  icon $gfxdir(icons\ircn.ico), 0
  size -1 -1 218 220
  option dbu
  icon 1, 0 0 219 32,  $gfxdir(wizard\header.jpg), 0, noborder
  text "Nickname:", 2, 7 47 45 10, right
  edit "", 4, 56 45 72 12, autohs
  edit "", 5, 56 58 72 12, autohs
  text "Alt. Nickname:", 6, 7 60 45 10, right
  edit "", 7, 56 77 72 12, autohs
  text "&Full Name:", 8, 7 79 45 10, right
  edit "", 9, 56 90 72 12, autohs
  text "Email Address:", 10, 7 92 45 10, right
  edit "", 11, 56 103 72 12, autohs
  text "Ident Name:", 12, 7 105 45 10, right
  button "&Cancel", 14, 153 206 30 12, cancel
  box "Connection info:", 15, 3 38 129 98
  box "User interface:", 16, 3 139 62 64
  radio "Modern", 17, 6 150 31 10, group
  radio "Classic", 18, 6 160 39 10
  radio "/commands only", 19, 6 170 56 10
  box "Modules:", 20, 68 139 65 64
  check "Autojoin", 21, 72 149 57 10
  check "Away", 22, 72 159 56 10
  check "Flood Protection", 23, 72 169 57 10, disable
  button "Open /modules", 24, 72 189 57 10
  button "Preview/Select", 25, 6 189 55 10
  box "ircN 7 import:", 26, 137 38 78 111
  radio "Don't import anything", 27, 141 47 71 10, group
  radio "Import all", 28, 141 57 70 10
  radio "Import userlist", 29, 141 67 70 10
  radio "Import settings && files", 30, 141 77 73 10
  radio "Import settings", 31, 141 87 70 10
  radio "Import files", 32, 141 97 69 10
  button "Open iTransfer module", 33, 141 134 70 10
  button "&OK", 13, 185 206 30 12, ok
  box "Theme:", 34, 138 157 77 46
  radio "Current", 35, 141 167 50 10, group
  radio "Dark", 36, 141 177 50 10
  button "Open /themes", 37, 142 189 68 10
  text "Dir:", 38, 142 108 31 10
  edit "", 39, 141 119 52 12
  button "...", 40, 196 119 15 12
  combo 3, 56 117 72 98, edit drop
  text "Connect to:", 41, 7 117 45 10, right
  check "Getnick", 42, 72 179 50 10
}

on *:dialog:ircn.wizard:init:0:{
  var %d = ircn.wizard
  did -c %d 17,27,35
  did -ra %d 4 $mnick
  did -ra %d 5 $anick
  did -ra %d 7 $fullname
  did -ra %d 9 $email
  did -ra %d 11 $readini($mircini,ident,userid)

  var %a = 1, %b
  while (%a <= $server(0)) {
    set %b $server(%a).group
    if ((!$didwm(%d,3,%b)) && (%b) && (%b !isnum)) did -a %d 3 $server(%a).group
    inc %a
  }

  _ircn.wizard.check
}
on *:dialog:ircn.wizard:sclick:13:{
  var %d = ircn.wizard
  .nick $did(%d,4)
  .anick $did(%d,5)
  .username $did(%d,7)
  .emailaddr $did(%d,9)
  .identd on $did(%d,11)
  if ($did(%d,3)) server $did(%d,3)

  ;Load Modules
  if ($did(%d,21).state == 1) .module autojoin
  if ($did(%d,22).state == 1) .module away
  if ($did(%d,23).state == 1) .module fldprot
  if ($did(%d,42).state == 1) .module getnick

  ;Load/Unload gui modules
  if ($did(%d,17).state == 1) .module modernui
  if ($did(%d,18).state == 1) { if ($ismod(modernui)) { .unmod modernui } | .module classicui }
  if ($did(%d,19).state == 1) { 
    if ($ismod(classicui)) .unmod classicui
    if ($ismod(modernui)) .unmod modernui
  }
  ;Change theme to dark
  if ($did(%d,36).state == 1) theme.load -s1 $themedir(ircN\ircN.mts)

  var %p = $iif(*\ !iswm $did(%d,39),$iif($did(%d,39),$did(%d,39) $+ \),$did(%d,39))
  if (%p == $null) return
  if ($isfile($+(%p,SYSTEM\irc2.ALS))) {
    ;iTransfer module importing
    var %itransfer
    if ($did(%d,28).state == 1) { %itransfer = -a }
    elseif ($did(%d,29).state == 1) { %itransfer = -u }
    elseif ($did(%d,30).state == 1) { %itransfer = -s -f }
    elseif ($did(%d,31).state == 1) { %itransfer = -s }
    elseif ($did(%d,32).state == 1) { %itransfer = -f }
    if (%itransfer) {
      .module itransfer
      .timer 1 0 itransfer %itransfer -p %p
    }
  }
  .timersaveset 1 5 nsave
}
on *:dialog:ircn.wizard:sclick:37:{ _ircn.wizard.ui.check | .timer 1 0 themes }
on *:dialog:ircn.wizard:sclick:33:{ module itransfer | .timer 1 1 itransfer }
on *:dialog:ircn.wizard:sclick:24:{ _ircn.wizard.ui.check | .timer 1 0 modules }
on *:dialog:ircn.wizard:sclick:25:{
  var %n = ircn.uiselect
  dlg %n
  if ($did(18).state == 1) { did -c %n 4 | did -u %n 3 }
  elseif ($did(19).state == 1) { did -u %n 4 | did -u %n 3 }
  if ($did(36).state == 1) { did -u %n 1 | did -c %n 2 }
}
on *:dialog:ircn.wizard:edit:4,5,7,9,11,39:{
  _ircn.wizard.check
}
on *:dialog:ircn.wizard:sclick:40:{
  _ircn.wizard.ircn7b
  _ircn.wizard.check
  _ircn.wizard.i7coninfo
}
alias _ircn.wizard.i7coninfo {
  var %d = ircn.wizard
  if ($did(%d,4) == ircNuser) var %c $true
  else var %c = $input(Use connect information from ircN 7?,yq,Import settings?.)
  if (($isfile($+($did(%d,39),\SYSTEM\IRC2.ALS))) && (%c)) {
    did -ra %d 4 $readini($+($did(%d,39),\SYSTEM\mirc.ini),mirc,nick)
    did -ra %d 5 $readini($+($did(%d,39),\SYSTEM\mirc.ini),mirc,anick)
    did -ra %d 7 $readini($+($did(%d,39),\SYSTEM\mirc.ini),mirc,user)
    did -ra %d 9 $readini($+($did(%d,39),\SYSTEM\mirc.ini),mirc,email)
    did -ra %d 11 $readini($+($did(%d,39),\SYSTEM\mirc.ini),ident,userid)
  }
}
alias _ircn.wizard.ircn7b {
  var %d = ircn.wizard
  :locate
  var %p = $sdir($iifelse($did(%d,39),C:\),Please locate ircN 7 root directory.)
  if (!%p) return
  if (!$isfile($+(%p,\SYSTEM\irc2.ALS))) %p = $input(Dir doesn't seem to be an ircN 7 directory.,rw,Unable to detect ircN directory.)
  else { did -ra %d 39 %p | did -c %d 28 | did -u %d 27 | did -u %d 29 | did -u %d 30 | did -u %d 31 | did -u %d 32 | return }
  if (%p) goto locate
}
alias _ircn.wizard.ui.check {
  var %d = ircn.wizard
  if (($did(%d,17).state == 1) && (!$ismod(modernui))) var %c = $input(You have selected Modern UI $+ $chr(44) but only Classic UI is loaded. $+ $crlf $+ Load Modern UI now?,yq,User Inferface issue detected.)
  if (%c) module modernui
}
alias _ircn.wizard.check {
  var %d = ircn.wizard
  if (($did(%d,4)) && ($did(%d,5)) && ($did(%d,7)) && ($did(%d,9)) && ($did(%d,11))) did -e %d 13
  else did -b %d 13

  if ($isfile($+($did(%d,39),\SYSTEM\IRC2.ALS))) did -e %d 27-32
  else { did -b %d 27-32 | did -c %d 27 | did -u %d 28 | did -u %d 29 | did -u %d 30 | did -u %d 31 | did -u %d 32 }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircn.uiselect {
  title "ircN User Interface selection"
  icon $gfxdir(icons\ircn.ico), 0
  size -1 -1 312 249
  option dbu
  radio "Default", 1, 8 11 50 10, group
  radio "Dark", 2, 178 11 50 10
  radio "Modern", 3, 8 120 50 10, group
  radio "Classic", 4, 178 120 50 10
  box "User Interface:", 5, 3 110 306 122
  box "Theme:", 6, 4 2 305 105
  icon 7, 8 134 124 89, $gfxdir(wizard\modernui.jpg), 0, noborder
  icon 8, 179 134 124 89, $gfxdir(wizard\classicui.jpg), 0, noborder
  icon 9, 8 22 122 77, $gfxdir(wizard\thm_def.jpg), 0, noborder
  icon 10, 179 22 122 77, $gfxdir(wizard\thm_dark.jpg), 0, noborder
  button "&OK", 11, 278 235 30 12, ok
  button "&Cancel", 12, 246 235 29 12, cancel
  text "Warning: Changes take effect immediately!", 13, 3 234 147 10
}
on *:dialog:ircn.uiselect:sclick:11:{
  var %n = ircn.wizard
  if (!$dialog(%n)) unset %n
  if (%n) did -c %n 35
  if (%n) did -u %n 36
  if ($did(3).state == 1) {
    if (%n) did -c %n 17
    if (%n) did -u %n 18
    if (%n) did -u %n  19
    .module modernui
  }
  elseif ($did(4).state == 1) {
    if (%n) did -u %n 17
    if (%n) did -c %n 18
    if (%n) did -u %n  19
    .unmod modernui
    .module classicui
  }
  if ($did(1).state == 1) {
    if (($nopath($hget(nxt_data,CurTheme)) != ircN.mts) || ($nopath($hget(nxt_data,CurScheme)))) theme.load $themedir(ircN\ircN.mts)
  }
  elseif ($did(2).state == 1) {
    if (($nopath($hget(nxt_data,CurTheme)) != ircN.mts) || ($nopath($hget(nxt_data,CurScheme)) != 1)) theme.load -s1 $themedir(ircN\ircN.mts)
  }
}
on *:dialog:ircn.uiselect:init:0:{
  did -c $dname 1,3
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Auto-Connect dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircn.autoconnect {
  title "ircN Auto-Connect"
  icon $gfxdir(icons\ircn.ico), 0
  size -1 -1 190 148
  option dbu
  ;list 1, 3 3 184 130, size check extsel
  list 1, 3 3 184 130, size
  button "&Add" 2, 94 135 30 10
  button "&Edit" 3, 126 135 30 10
  button "&Del" 4, 157 135 30 10

  button "Up" 5, 3 135 30 10
  button "Down" 6, 35 135 30 10

  menu "&Session", 100
  item "&Connect (New)", 101
  item "&Connect (Current)", 102
}
on 1:dialog:ircn.autoconnect:sclick:4:{
  if ($did(1).sel) {
    var %t = $did(1).seltext
    set %t $iif($gettok(%t,1,32) == $paren(disabled), $gettok(%t,2,32),  $gettok(%t,1,32))
    var %a = $input(Are you sure you want to delete $+ $crlf $+ ' $+ %t $+ ' ?,y,ircN Sessions)
    if (!%a) return
    write -dl $+ $did(1).sel $sd(sessions.txt)
    _autoconnect.refresh.list ircn.autoconnect
  }
}
on *:dialog:ircn.autoconnect:menu:101:if ($did(1).sel) loadsession $did(1).sel
on *:dialog:ircn.autoconnect:menu:102:if ($did(1).sel) loadsession -c $did(1).sel
on *:dialog:ircn.autoconnect:sclick:2:_sessions.add $dname
on *:dialog:ircn.autoconnect:sclick:3:if ($did(1).sel) _sessions.edit $dname $did(1).sel
on *:dialog:ircn.autoconnect:dclick:1:if ($did(1).sel) _sessions.edit $dname $did(1).sel
on *:dialog:ircn.autoconnect:sclick:5:if ($did(1).sel) _autoconnect.move.up $dname $did(1).sel $did(1).lines
on *:dialog:ircn.autoconnect:sclick:6:if ($did(1).sel) _autoconnect.move.down $dname $did(1).sel $did(1).lines
on *:dialog:ircn.autoconnect:init:0:{
  var %d = ircn.autoconnect
  _sessions.check
  _autoconnect.refresh.list %d
}
alias _autoconnect.refresh.list {
  var %d = $1
  if ($dialog(ircn.autoconnect)) did -r $v1 1
  if ($dialog(ircn.autoconnect.modern)) xdid -r $v1 1
  if (!$isfile($sd(sessions.txt))) return
  var %a = 1, %b, %c, %e, %r, %z, %t
  while ($read($sd(sessions.txt),n,%a) != $null) {

    set %b $ifmatch
    _autoconnect.add.to.dlg %d append %b

    inc %a
    unset %l, %r
  }
}
alias _autoconnect.move.up {
  if ($0 < 3) return
  var %a, %b, %d = $1, %l = $2, %t = $3
  if ((%l) && (%l > 1)) {
    set %a $read($sd(sessions.txt),$calc(%l - 1))
    set %b $read($sd(sessions.txt),%l)
    write -l $+ $calc(%l - 1) $sd(sessions.txt) %b
    write -l $+ %l $sd(sessions.txt) %a
    _autoconnect.add.to.dlg %d $calc(%l - 1) %b
    _autoconnect.add.to.dlg %d %l %a
  }
}
alias _autoconnect.move.down {
  if ($0 < 3) return
  var %a, %b, %d = $1, %l = $2, %t = $3
  if ((%l) && (%l < %t)) {
    set %a $read($sd(sessions.txt),$calc(%l + 1))
    set %b $read($sd(sessions.txt),$calc(%l))
    write -l $+ $calc(%l + 1) $sd(sessions.txt) %b
    write -l $+ %l  $sd(sessions.txt) %a
    _autoconnect.add.to.dlg %d $calc(%l + 1) %b
    _autoconnect.add.to.dlg %d %l %a
  }
}
alias _autoconnect.add.to.dlg {
  var %e, %t, %r, %z, %c, %l, %d = $1, %m = $2, %b = $3-
  set %e 0

  %z = $numtok(%b,32)

  if ($gettok(%b,1,32) == 1) set %e 1
  set %c 2 
  %r = $gettok(%b,2,32)


  while (%c <= %z) {
    %t = $iif(%c >= 8, $gettok(%b,8-,32), $gettok(%b,%c,32))

    if (%c > 2) {
      var %q
      if (%t != <blank>) {
        set %q %c      
        set %q $replace(%q,3,Port, 4, Pass, 5, Nick, 6, aNick, 7, Email, 8, Name)
      }
      %l = %l %q $+ $iif(%t != <blank>,$iif(%c == 4,*****,$paren(%t)))
    }
    if (%c == 8) break
    inc %c
  }

  if ($dialog(ircn.autoconnect)) {
    if (%m == append) {
      did -a ircn.autoconnect 1 $iif(%e != 1,$paren(disabled)) %r $iif(%l,-> %l)
      ;if (%e == 1) did -s ircn.autoconnect 1 $did(%d,1).lines
    }
    else {
      did -o ircn.autoconnect 1 %m $iif(%e != 1,$paren(disabled)) %r $iif(%l,-> %l)
      ;if (%e == 1) did -s ircn.autoconnect 1 %m $did(%d,1).lines
    }
  }
  elseif ($dialog(ircn.autoconnect.modern)) {

    if (%m == append) {
      xdid -a ircn.autoconnect.modern 1 0 0 $tab(+ 0 $iif(%e == 1,2,1) 0 0 0 0 %r, + 0 0 0 0 %l )
    }
    else {
      xdid -k ircn.autoconnect.modern 1 $iif(%e == 1,2,1) %m
      xdid -v ircn.autoconnect.modern 1 %m 1 %r
      xdid -v ircn.autoconnect.modern 1 %m 2 %l
    }
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add/Edit sessions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircn.sessionae {
  title "Edit session"
  size -1 -1 147 35
  option dbu
  text "Server/Group:", 4, 3 6 40 10
  edit "", 5, 45 5 72 11, autohs
  text "Port:", 6, 9 37 12 9, hide
  edit "", 7, 55 36 39 11, hide autohs
  text "Password:", 8, 9 49 25 12, hide
  edit "", 9, 55 48 39 11, hide autohs
  text "Email Address:", 10, 9 83 40 10, hide
  text "Full Name:", 11, 9 95 37 13, hide
  text "Alternative:", 12, 9 72 46 10, hide
  text "Nickname:", 13, 9 61 30 10, hide
  edit "", 14, 55 60 59 11, hide autohs
  edit "", 15, 55 71 59 11, hide autohs
  edit "", 16, 55 82 59 11, hide autohs
  edit "", 17, 55 94 59 11, hide autohs
  button "&OK", 18, 87 19 27 11, default ok
  button "&Cancel", 19, 117 19 27 11, cancel
  check "More", 20, 3 18 26 11, push
  text "", 21, 0 0 1 1, hide
  check "Enabled", 1, 46 17 41 12
  box "Firewall", 27, 7 112 141 46
  check "Firewall:", 2, 13 126 40 8
  edit "", 3, 56 125 50 11
  text ":", 23, 107 126 5 11, center
  edit "", 22, 112 125 28 11
  radio "Socks 4", 24, 23 138 35 13
  radio "Socks 5 ", 25, 58 138 38 13
  radio "Proxy", 26, 96 138 38 13
  check "SSL", 28, 104 36 35 12
}

on *:dialog:ircn.sessionae.*:init:0:{
  did -c $dname 24

  did -b $dname 24,25,26,3,22

}
on *:dialog:ircn.sessionae.*:sclick:28:{

  if ($did(28).state) {
    if ($left($did(7),1) != +) did -ra $dname 7 + $+ $did(7)
  }
  else {
    if ($left($did(7),1) == +) did -ra $dname 7 $right($did(7),-1)
  }

}
on *:dialog:ircn.sessionae.*:sclick:2:{

  if ($did(2).state) {
    did -e $dname 24,25,26,3,22
  }
  else {
    did -b $dname 24,25,26,3,22
  }

}
on 1:dialog:ircn.sessionae.*:sclick:20:{
  if ($did(20).state) {
    dialog -sb $dname $dialog($dname).x $dialog($dname).y 147 111
    _did -v $dname 6-17
    did -ra $dname 20 Less
  }
  else {
    dialog -sb $dname $dialog($dname).x $dialog($dname).y 147 35
    _did -h $dname 6-17
    did -ra $dname 20 More
  }
}
on 1:dialog:ircn.sessionae.*:sclick:18:{
  var %ln, %d = $gettok($dname,3,46),%l = $gettok($dname,4,46), %fn = $sd(sessions.txt)
  if ($did(5)) {
    if ((%d == edit) && (%l == $null)) return
    %ln = $did(1).state $remove($did(5),$chr(32)) $iifelse($remove($did(7),$chr(32)),<blank>) $iifelse($remove($did(9),$chr(32)),<blank>) $iifelse($remove($did(14),$chr(32)),<blank>)
    %ln = %ln $iifelse($remove($did(15),$chr(32)),<blank>) $iifelse($remove($did(16),$chr(32)),<blank>) $iif($remove($did(17),$chr(32)),$did(17),<blank>)
    write $iif(%d == edit,-l $+ %l) %fn %ln
    _autoconnect.add.to.dlg $dname $iif(%d == edit,%l,append) %ln
  }
  else {
    iecho You must give a server or network
    halt
  }
}
alias _sessions.add {
  var %n = $1, %d = $+(ircn.sessionae.add)
  dialog -m %d ircn.sessionae
  did -ra %d 21 %n
  did -c %d 1
}
alias _sessions.edit {
  var %n = $1, %l = $2, %d = $+(ircn.sessionae.edit.,%l)
  dlg %d ircn.sessionae
  did -ra %d 21 %n
  var %ln = $read($sd(sessions.txt),n,%l)
  did - $+ $iif($gettok(%ln,1,32) == 1,c,u) %d 1
  did -ra %d 5 $iif($gettok(%ln,2,32) != <blank>,$v1)
  did -ra %d 7 $iif($gettok(%ln,3,32) != <blank>,$v1)
  did -ra %d 9 $iif($gettok(%ln,4,32) != <blank>,$v1)
  did -ra %d 14 $iif($gettok(%ln,5,32) != <blank>,$v1)
  did -ra %d 15 $iif($gettok(%ln,6,32) != <blank>,$v1)
  did -ra %d 16 $iif($gettok(%ln,7,32) != <blank>,$v1)
  did -ra %d 17 $iif($gettok(%ln,8-,32) != <blank>,$v1)

  if ($left($gettok(%ln,3,32),1) == +) did -c %d 28 1
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FKeys dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias fkeysettings {
  if ($ismod(modernui)) fkeysettings.modern
  else dlg -r ircn.fkeys
}
dialog ircn.fkeys {
  title "Fkeys"
  size -1 -1 184 148
  option dbu
  list 1, 3 3 178 142, size
}
on *:dialog:ircn.fkeys:dclick:1:{
  var %a = $gettok($did(1,$did(1).sel).text,1,32)
  var %cmd = $input(enter the fkey command for %a,eo,fkey edit,$nvar(fkey. $+ %a))

  if (%a == F11) {
    $iif(%cmd == fullscreen,.disable, .enable) #ircN_F11Key 
  }

  _fkey.addperm %a %cmd

  _fkey.refresh
}
on *:dialog:ircn.fkeys:init:0:_fkey.refresh
alias -l _fkey.refresh {
  var %n = ircn.fkeys
  did -r %n 1
  var %a, %b = 1, %c
  while (%b <= 3) {
    set %a 1
    while (%a <= 12) {
      set %c $iif(%b == 2,c,$iif(%b == 3,s)) $+ F $+ %a

      did -a %n 1 %c : $nvar(fkey. $+ %c)
      inc %a
    }
    inc %b
  }
}



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; /Setup dialog (Classic)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias _classicui.closeallsetupdialogs {
  if ($dialog(ircnsetup.channel))  dialog -x ircnsetup.channel
  if ($dialog(ircnsetup.general))  dialog -x ircnsetup.general
  if ($dialog(ircnsetup.network))  dialog -x ircnsetup.network
  if ($dialog(ircnsetup.display))  dialog -x ircnsetup.display
  if ($dialog(ircn.userlist))  dialog -x ircn.userlist
  if ($dialog(ircn.banlist))  dialog -x ircn.banlist
  if ($dialog(ircn.nxt))  dialog -x ircn.nxt
  if ($dialog(ircnsetup.logs))  dialog -x ircnsetup.logs
  if ($dialog(ircn.nethshdetect.list)) dialog -x ircn.nethshdetect.list
  if ($dialog(ircnsetup.transfer))  dialog -x ircnsetup.transfer
  if ($dialog(ircnsetup.usersettings)) dialog -x ircnsetup.usersettings
  if ($dialog(ircn.fkeys))  dialog -x ircn.fkeys
  if ($dialog(ircn.ctcpedit)) dialog -x ircn.ctcpedit
  if ($dialog(ircn.chandisplay))  dialog -x ircn.chandisplay
  if ($dialog(ircnsetup.nickcomp))  dialog -x ircnsetup.nickcomp
  if ($dialog(ircnsetup.netauth))  dialog -x ircnsetup.netauth
  if ($dialog(ircn.autoconnect))  dialog -x ircn.autoconnect
  if ($dialog(ircnsetup.display.hideevents)) dialog -x ircnsetup.display.hideevents
  if ($dialog(ircNsetup.editquits)) dialog -x ircNsetup.editquits
  if ($dialog(ircNsetup.editkicks)) dialog -x ircNsetup.editkicks
  if ($dialog(ircN.titlebar)) dialog -x ircN.titlebar
  if ($dialog(ircn.modules))  dialog -x ircn.modules
  if ($dialog(ircnsetup.notdone)) dialog -x ircnsetup.notdone
  if ($dialog(ircnsetup.about))  dialog -x ircnsetup.about

}

alias _classicui.resizesetupdialog {

  if ($dialog(ircn.setup)) {
    if ($dialog(%ircnsetup.currentdlg)) {
      var %x = $dialog( %ircnsetup.currentdl ).x $dialog(%ircnsetup.currentdl).y
      var %y = $dialog(ircn.setup).x $dialog(ircn.setup).y 

      if (%x != %ircnsetup.currentdlg.lastpos) || (%y != %ircnsetup.currentdlg.lastpossettup) {

        ;dialog -s %ircnsetup.currentdlg $calc($dialog(ircn.setup).x + $dialog(ircn.setup).w) $dialog(ircn.setup).y $dialog(%ircnsetup.currentdlg).w $dialog(%ircnsetup.currentdlg).h
        dialog -sb %ircnsetup.currentdlg $calc($dialog(ircn.setup).x + $dialog(ircn.setup).w) $dialog(ircn.setup).y -1 -1
        set %ircnsetup.currentdlg.lastpos %x
        set %ircnsetup.currentdlg.lastpossettup %y
      }
    }
    else .timer_classicui.resizesetup off
  }
  else .timer_classicui.resizesetup off
}
dialog ircn.setup {
  title "ircN (/setup)"
  size -1 -1 84 148
  option dbu
  list 1, 3 3 78 142, size
}
on *:dialog:ircn.setup:init:0:{

  _classicui.closeallsetupdialogs


  var %d = ircn.setup
  did -r %d 1
  var %items = About,General,:: Logging, :: Transfer, :: Fkey Bind, Network, :: Auth, :: Setting forcing, :: Auto-Connect, Channel, Display, :: Channel Display, :: Hide Events, :: NickComplete, :: Titlebar, :: Themes, $+ $iif($ismod(userlist), Userlist $+ $chr(44) :: UL Settings $+ $chr(44) Banlist ) $+ ,Message Editor, :: Quits, :: CTCP Replies, :: Kicks,  Modules
  var %i = $numtok(%items,44)
  while (%i) {
    did -i %d 1 1 $gettok(%items,%i,44)
    dec %i
  }
  _classicui.setup.showdlg about
  did -c $dname 1 1
}
on *:dialog:ircn.setup:close:0:{ 

  if ($dialog(%ircnsetup.currentdlg)) dialog -x %ircnsetup.currentdlg
  unset %ircnsetup.currentdlg*
}
alias _classicui.setup.showdlg {


  var %a = $1-, %b, %c



  if (%a == About) {
    set %c about
    set %b ircnsetup.about
  }

  if (%a == Channel) {
    set %c chansettings
    set %b ircnsetup.channel
  }
  if (%a == General) {
    set %c gensettings
    set %b ircnsetup.general
  }
  if (%a == :: Auth) {
    set %c netauth
    set %b ircnsetup.netauth
  }
  if (%a == :: Setting forcing) {
    set %c dlg ircn.nethshdetect.list
    set %b ircn.nethshdetect.list
  }
  if (%a == :: Titlebar) {

    set %c dlg ircn.titlebar
    set %b ircn.titlebar
  }
  if (%a == :: Fkey Bind) {
    set %c fkeys
    set %b ircn.fkeys
  }
  if (%a == :: Auto-Connect) {
    set %c autoconnect
    set %b ircn.autoconnect
  }
  if (%a == :: Logging) {
    set %c logsettings
    set %b ircnsetup.logs
  }
  if (%a == :: Transfer) {
    set %c transfersettings
    set %b ircnsetup.transfer
  }
  if (%a == Message Editor) { set %c dlgnotdone | set %b ircnsetup.notdone }



  if (%a == :: Kicks) {
    set %c editkicks
    set %b ircNsetup.editkicks
  }
  if (%a == :: Quits) {
    set %c editquits
    set %b ircNsetup.editquits
  }
  if (%a == Display) {
    set %c displaysettings
    set %b ircnsetup.display
  }
  if (%a == :: Channel Display) {
    set %c chandisplay
    set %b ircN.chandisplay
  }

  if (%a == :: NickComplete) {
    set %c nickcomp
    set %b ircNsetup.nickcomp
  }
  if (%a == :: Hide Events) {
    set %c hideevents
    set %b ircnsetup.display.hideevents
  }
  if (%a == :: Ctcp replies) {

    set %c ctcpedit
    set %b ircn.ctcpedit

  }
  if (%a == Network) {
    set %c netsettings
    set %b ircnsetup.network
  }
  if (%a == Userlist) {
    set %c userlist
    set %b ircn.userlist
  }
  if (%a == :: UL Settings) {
    set %c usersettings
    set %b ircnsetup.usersettings
  }
  if (%a == Banlist) {
    set %c banlist
    set %b ircn.banlist
  }
  if (%a == :: Themes) {
    set %c nxt
    set %b ircn.nxt
  }
  if (%a == Modules) {
    set %c modules
    set %b ircn.modules
  }
  if (($dialog(%b)) && (%ircnsetup.currentdlg == %b)) return
  if (%b) {
    set %ircnsetup.currentdlg %b
    _classicui.closeallsetupdialogs

    %c 

    .timer 1 0 dialog -s %b $ $+ calc($ $+ dialog(ircn.setup).x + $ $+ dialog(ircn.setup).w) $ $+ dialog(ircn.setup).y -1 -1


    if (!$timer(_classicui.resizesetup)) .timer_classicui.resizesetup -o 0 1  _classicui.resizesetupdialog
  }
  else unset %ircnsetup.currentdlg

}

on *:dialog:ircn.setup:sclick:1:{

  var %a = $did(1,$did(1).sel)
  if (%a) _classicui.setup.showdlg %a
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Userlist dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dialog ircn.userlist {
  title "ircN Userlist"
  size -1 -1 186 148 
  option dbu
  list 1, 3 3 180 128, size hsbar vsbar
  button "Delete", 2, 160 134 21 11
  button "Edit", 3, 137 134 21 11
  button "Create", 4, 114 134 21 11
}

on *:dialog:ircn.userlist:init:0:_userlistdlg.refresh
on *:dialog:ircn.userlist:sclick:4:adduserdlg
on 1:dialog:ircn.userlist:sclick:3:{
  var %a = $gettok($did(1).seltext,1,32)
  if (!%a) { var %a = $input(No user selected! $crlf $+ Please select a user from the userlist!,ow,No user selected!) | return }
  edituserdlg %a
}
on *:dialog:ircn.userlist:sclick:2:{
  if (!$did(1).sel) return
  var %a =  $gettok($did(1).seltext,1,32)
  if ($input(Are you sure you want to delete user: %a)) {
    remuser %a
    did -d $dname 1 $did(1).sel
  }
}
alias _userlistdlg.refresh {
  var %n = $1
  var %did = $iif($2 isnum,$2,1)
  if ((!$dialog(ircn.userlist)) && (!$dialog(ircnsetup.userlist))) return
  if ($dialog(ircnsetup.userlist)) xdid -r $v1 1
  if ($dialog(ircn.userlist)) did -r $v1 1
  var %a = 1, %b,%c,%d
  while ($usernum(%a) != $null) {
    set %b $ifmatch
    set %d 1
    set %c
    while ($gettok($ulinfo(%b,chans),%d,44)) {
      set %c %c $ifmatch $ulinfo(%b,flags,$ifmatch) $+ ,
      inc %d
    }
    set %c $left(%c,-1)
    if ($dialog(ircnsetup.userlist)) xdid -a $v1 1 0 0 $tab(+ 0 0 0 0 0 0 %b, + 0 0 0 0 $ulinfo(%b,hosts), + 0 0 0 0 $ulinfo(%b,flags), + 0 0 0 0 %c )      
    ;if ($dialog(ircn.userlist)) did -a $v1 1 %b :  $iif($ulinfo(%b,flags),FLAGS: $ifmatch) HOSTS: $ulinfo(%b,hosts)
    if ($dialog(ircn.userlist)) did -a $v1 1 $listvfrmt($tab(40 %b $chr(32),40 $ulinfo(%b,flags),160 $ulinfo(%b,hosts))).line
    inc %a
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CTCP Dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircn.ctcplist {
  title "ircN CTCP Settings and Replies"
  size -1 -1  184 148 
  option dbu
  box "", 5, 3 1 50 14
  box "", 6, 55 1 124 14
  text "CTCP Event:", 7, 5 6 50 8
  text "Setting/Reply:", 8, 57 6 50 8
  list 1, 3 18 178 112, size
  button "&Delete", 2, 160 134 21 11
  button "&Add/Edit", 4, 126 134 31 11
}
on *:dialog:ircn.ctcplist:sclick:4:ctcpeditdlg $gettok($did(4).seltext,1,32)
on *:dialog:ircn.ctcplist:sclick:2:{
  var %d = ircn.ctcplist
  if (!$did(%d,1).sel) { var %a = $input(No CTCP Event selected,wo,ERROR!) | return }
  if ($?!="Are you SURE you want to delete this event and all it's replies?") {
    hdel -w ctcpreplys $+($gettok($did(%d,1).seltext,1,32),.*)
  }
  _ctcplist.refresh
}
on *:dialog:ircn.ctcplist:init:0:_ctcplist.refresh
alias _ctcplist.refresh {
  if ($dialog(ircn.ctcplist.modern)) xdid -r $v1 1
  if ($dialog(ircn.ctcplist)) did -r $v1 1
  if ($dialog(ircn.ctcpedit)) { var %s = $upper($remove($did($v1,2),$chr(32))) | did -r $v1 2 }
  var %a = 1, %b, %l, %r
  while ($hfind(ctcpreplys,*.style,%a,w) != $null) {
    set %b $ifmatch
    set %l $hget(ctcpreplys,%b)
    set %b $gettok(%b,1,46)
    if (%l == custom) set %r $hget(ctcpreplys,%b $+ .defreply)
    if (%l == random) set %r Random reply
    if (%l == ignore) set %r Ignored

    if ($dialog(ircn.ctcplist.modern)) xdid -a $v1 1 0 0 $tab(+ 0 0 0 0 0 0 %b, + 0 0 0 0 %r)
    if ($dialog(ircn.ctcplist)) did -a $v1 1 $listvfrmt($tab(54 $upper(%b))).line $+ %r
    if ($dialog(ircn.ctcpedit)) did -a $v1 2 %b
    inc %a
    unset %l, %r
  }
  if ((%s) && ($dialog(ircn.ctcpedit))) did -i $v1 2 0 %s
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CTCP Add/Edit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias ctcpedit {
  dlg -r ircn.ctcpedit
  _ctcplist.refresh

}
dialog ircn.ctcpedit {
  title "CTCP Reply Editor"
  size -1 -1 245 169
  option dbu
  combo 2, 71 9 53 44, size edit drop
  radio "Custom Reply:", 3, 6 32 49 11
  edit "", 4, 63 32 173 12, autohs
  radio "Random reply (from the list below)", 5, 5 52 104 11
  list 6, 9 78 225 48, size
  button "&OK", 7, 153 151 27 12, default ok
  button "&Cancel", 8, 182 151 27 12, cancel
  radio "Ignore", 9, 6 42 46 11
  button "&Add", 10, 162 127 18 12
  box "CTCP Event", 1, 67 0 125 25
  button "Add", 13, 131 8 27 12
  box "CTCP Reply", 12, 3 25 240 143
  button "Apply", 11, 211 151 27 12
  button "&Replace", 14, 181 127 27 12
  button "&Delete", 15, 209 127 25 12
  edit "", 17, 9 127 151 12, autohs
  box "Reply list", 16, 6 64 232 86
  button "Delete", 18, 161 8 27 12
  text "Double click listbox to set as your single custom reply instead of random.", 19, 9 140 224 8, hide
}
alias _ctcpedit.disabledids {
  var %d = ircn.ctcpedit
  did -b %d 3,5,4,6,9,10,12,14,15,16,17,18
}
alias _ctcpedit.enabledids {
  var %d = ircn.ctcpedit
  did -e %d 3,5,4,6,9,10,12,14,15,16,17,18
}
alias _ctcpedit.disabledids.randomreplies {
  var %d = ircn.ctcpedit
  did -b %d 6,10,13,14,15,17
}
alias _ctcpedit.enabledids.randomreplies {
  var %d = ircn.ctcpedit
  did -e %d 6,10,13,14,15,17
}

on 1:dialog:ircn.ctcpedit:sclick:18:{
  var %d = ircn.ctcpedit
  if (!$did(%d,2)) { var %a = $input(No CTCP Event selected,wo,ERROR!) | return }
  if ($?!="Are you SURE you want to delete this event and all it's replies?") {
    hdel -w ctcpreplys $did(%d,2) $+ .*
    did -r %d 2 0
  }
  _ctcplist.refresh
  _ctcpedit.disabledids
}
on 1:dialog:ircn.ctcpedit:sclick:13:{
  var %d = $dname
  var %b = $remove($did(%d,2),$chr(32))
  if (%b != $null) {
    hadd ctcpreplys $upper(%b) $+ .style custom
    _ctcpedit.enabledids
    _ctcplist.refresh
    _ctcpedit.refreshsettings
  }
}
on 1:dialog:ircn.ctcpedit:sclick:14:{
  var %d = ircn.ctcpedit
  if ($did(%d,17) && $did(%d,2) && $did(%d,6).sel) {
    hadd ctcpreplys $upper($did(%d,2)) $+ .ctcpreply. $+ $calc($did(%d,6).sel) $did(%d,17)
    did -r %d 17
    _ctcpedit.refreshsettings
  }
}
on 1:dialog:ircn.ctcpedit:sclick:15:{
  var %d = ircn.ctcpedit
  if ($did(%d,2) && $did(%d,6).sel) {
    var %a, %b
    set %a $hfind(ctcpreplys, [ [ $did(%d,2) ] $+ ] .ctcpreply.*,0,w)
    set %b $calc($did(%d,6).sel)
    while (%b < %a) {
      hadd ctcpreplys $did(%d,2) $+ .ctcpreply. $+ %b $did(%d,6,$calc(%b + 1)).text
      inc %b
    }
    hdel ctcpreplys $did(%d,2) $+ .ctcpreply. $+ %b
  }
  .timer 1 0 _ctcpedit.refreshsettings
}

on 1:dialog:ircn.ctcpedit:sclick:7:{
  _applysettings.ctcp
  _ctcplist.refresh
}
on 1:dialog:ircn.ctcpedit:sclick:9,3:_ctcpedit.disabledids.randomreplies | did -h $dname 19
on 1:dialog:ircn.ctcpedit:edit:4:{ _ctcpedit.disabledids.randomreplies | did -u $dname 9,5 | did -c $dname 3 | did -h $dname 19 }
on 1:dialog:ircn.ctcpedit:sclick:5:{ _ctcpedit.enabledids.randomreplies | did -v $dname 19 } 
on 1:dialog:ircn.ctcpedit:sclick:8:_ctcplist.refresh
on 1:dialog:ircn.ctcpedit:sclick:11:_applysettings.ctcp
on *:dialog:ircn.ctcpedit:dclick:6:if ($did(6).seltext) { did -ra $dname 4 $did(6).seltext | _ctcpedit.disabledids.randomreplies | did -u $dname 9,5 | did -c $dname 3 | did -h $dname 19 }

alias _applysettings.ctcp {
  var %d = ircn.ctcpedit
  if (($did(%d,2)) && ($hget(ctcpreplys,[ [ $did(%d,2) ] $+ ] .style))) {
    if ($did(%d,3).state == 1) {
      hadd ctcpreplys $did(%d,2) $+ .style custom
    }
    elseif ($did(%d,5).state == 1) {
      hadd ctcpreplys $did(%d,2) $+ .style  random
    }
    elseif ($did(%d,9).state == 1) {
      hadd ctcpreplys $did(%d,2) $+ .style  ignore
    }
    hadd ctcpreplys $did(%d,2) $+ .defreply $did(%d,4)
  }
}
on 1:dialog:ircn.ctcpedit:sclick:6:{
  var %d = ircn.ctcpedit
  did -ra %d 17 $did(%d,6).seltext
}
alias ctcpeditdlg {
  var %d ircn.ctcpedit
  dlg %d
  _ctcplist.refresh
  did -i %d 2 0 $1
  _ctcpedit.refreshsettings
}
on 1:dialog:ircn.ctcpedit:sclick:10:{
  var %d = ircn.ctcpedit
  var %b = $remove($did(%d,2),$chr(32))
  if ((%b != $null) && ($did(%d,17) != $null)) {
    var %a
    set %a $hfind(ctcpreplys, %b $+ .ctcpreply.*,0,w)
    hadd ctcpreplys %b $+ .ctcpreply. $+ $calc(%a + 1) $did(%d,17)
    _applysettings.ctcp
    _ctcplist.refresh
    .timer 1 0 _ctcpedit.refreshsettings
  }
  did -r %d 17

}
on 1:dialog:ircn.ctcpedit:edit,sclick:2:_ctcpedit.refreshsettings
alias _ctcpedit.refreshsettings {
  var %d = ircn.ctcpedit
  if (!$hget(ctcpreplys,[ [ $did(%d,2) ] $+ ] .style)) { _ctcpedit.disabledids | return }
  if ($did(%d,2) != $null) {
    did -r %d 6
    var %a = $hfind(ctcpreplys, [ [ $did(%d,2) ] $+ ] .ctcpreply.*,0,w)
    var %b = 1
    while (%b <= %a) {
      did -a %d 6 $hget(ctcpreplys,$hfind(ctcpreplys, [ [ $did(%d,2) ] $+ ] .ctcpreply.*,%b,w))
      inc %b
    }
  }
  did -r %d 4
  did -u %d 3,5,9
  if ($hget(ctcpreplys,[ [ $did(%d,2) ] $+ ] .style) == custom) did -c %d 3
  if ($hget(ctcpreplys,[ [ $did(%d,2) ] $+ ] .style) == random) did -c %d 5
  if ($hget(ctcpreplys,[ [ $did(%d,2) ] $+ ] .style) == ignore)  did -c %d 9
  if ($hget(ctcpreplys,[ [ $did(%d,2) ] $+ ] .defreply))  did -ra %d 4 $hget(ctcpreplys,[ [ $did(%d,2) ] $+ ] .defreply)
  _ctcpedit.enabledids

  if ($did(%d,5).state) _ctcpedit.enabledids.randomreplies
  else _ctcpedit.disabledids.randomreplies

}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircn.titlebar {
  title "Titlebar Setup"
  size -1 -1 184 148 
  option dbu
  list 1, 15 25 62 86, size
  box "Titlebar:", 2, 12 15 68 99, center

  button "<-" 3, 83 50 12 12
  button "->" 4, 83 62 12 12

  button "up" 5, 83 36 12 12
  button "dn" 6, 83 76 12 12

  list 7, 100 25 62 86, size
  box "Unused:", 8, 97 15 68 99, center
  check "ircN Titlebar Enabled", 9, 6 2 70 10
  button "&OK", 10, 150 136 30 10, ok
  button "&Cancel", 11, 118 136 30 10, cancel
}
on *:dialog:ircn.titlebar:init:0:{ if ($nvar(titlebar) == on) did -c $dname 9 | _titlebar.updatemodes }
on *:dialog:ircn.titlebar:sclick:10:_save.titlebarsetup
on *:dialog:ircn.titlebar:sclick:3:{
  if ($did(7).sel) {
    did -a $dname 1 $did(7).seltext
    did -d $dname 7 $did(7).sel
  }
}
on *:dialog:ircn.titlebar:sclick:4:{
  if ($did(1).sel) {
    did -a $dname 7 $did(1).seltext
    did -d $dname 1 $did(1).sel
  }
}
on *:dialog:ircn.titlebar:sclick:5:{
  if ($did(1).sel > 1) {
    var %a = $did(1).seltext, %b = $did(1,$calc($did(1).sel - 1)).text, %c = $did(1).sel
    did -o $dname 1 $calc(%c - 1) %a
    did -o $dname 1 %c %b
    did -c $dname 1 $calc(%c - 1)
  }
}
on *:dialog:ircn.titlebar:sclick:6:{
  if (($did(1).sel) && ($did(1).sel < $did(1).lines)) {
    var %a = $did(1).seltext, %b = $did(1,$calc($did(1).sel + 1)).text, %c = $did(1).sel
    did -o $dname 1 $calc(%c + 1) %a
    did -o $dname 1 %c %b
    did -c $dname 1 $calc(%c + 1)
  }
}
alias _titlebar.updatemodes2 {
  if ($dialog(ircn.titlebar)) did -a $v1 $1-
  if ($dialog(ircn.titlebar.modern)) did -a $v1 $1-
}
alias _titlebar.updatemodes {
  var %a = 1
  var %c = _titlebar.updatemodes2 7
  if ($dialog(ircn.titlebar)) did -r $v1 1,7
  if ($dialog(ircn.titlebar.modern)) did -r $v1 1,7

  if (@channame !isin $nvar(titlebar.format)) %c Channel Name
  if (@chanmodes !isin $nvar(titlebar.format)) %c Channel Modes
  if (@chanusers !isin $nvar(titlebar.format)) %c Channel Users
  if (@chantotusers !isin $nvar(titlebar.format)) %c Channel Total Users
  if (@chantopic !isin $nvar(titlebar.format)) %c Channel Topic
  if (@idle !isin $nvar(titlebar.format)) %c Idle
  if (@lag !isin $nvar(titlebar.format)) %c Lag
  if (@away !isin $nvar(titlebar.format)) %c Away
  if (@server !isin $nvar(titlebar.format)) %c Server
  if (@srvrver !isin $nvar(titlebar.format)) %c Server version
  if (@srvrport !isin $nvar(titlebar.format)) %c Server port
  if (@time !isin $nvar(titlebar.format)) %c Time
  if (@me !isin $nvar(titlebar.format)) %c Your nick
  if (@usermode !isin $nvar(titlebar.format)) %c Your mode
  if (@netnum !isin $nvar(titlebar.format)) %c Network num
  if (@network !isin $nvar(titlebar.format)) %c Network
  set %c
  while ($gettok($nvar(titlebar.format),%a,32)) {
    if ($gettok($nvar(titlebar.format),%a,32) == @channame) set %c Channel Name
    elseif ($gettok($nvar(titlebar.format),%a,32) == @chanmodes) set %c Channel Modes
    elseif ($gettok($nvar(titlebar.format),%a,32) == @chanusers) set %c Channel Users
    elseif ($gettok($nvar(titlebar.format),%a,32) == @chantotusers) set %c Channel Total Users
    elseif ($gettok($nvar(titlebar.format),%a,32) == @chantopic) set %c Channel Topic
    elseif ($gettok($nvar(titlebar.format),%a,32) == @idle) set %c Idle
    elseif ($gettok($nvar(titlebar.format),%a,32) == @lag) set %c Lag
    elseif ($gettok($nvar(titlebar.format),%a,32) == @away) set %c Away
    elseif ($gettok($nvar(titlebar.format),%a,32) == @server) set %c Server
    elseif ($gettok($nvar(titlebar.format),%a,32) == @srvrver) set %c Server version
    elseif ($gettok($nvar(titlebar.format),%a,32) == @srvrport) set %c Server port
    elseif ($gettok($nvar(titlebar.format),%a,32) == @time) set %c Time
    elseif ($gettok($nvar(titlebar.format),%a,32) == @me) set %c Your Nick
    elseif ($gettok($nvar(titlebar.format),%a,32) == @usermode) set %c Your mode
    elseif ($gettok($nvar(titlebar.format),%a,32) == @netnum) set %c Network num
    elseif ($gettok($nvar(titlebar.format),%a,32) == @network) set %c Network
    else set %c $did(%d,1,%a).text
    _titlebar.updatemodes2 1 %c
    inc %a
  }
}
alias _save.titlebarsetup {
  var %d = ircn.titlebar.modern
  if (!$dialog(%d)) %d = ircn.titlebar
  if (!$dialog(%d)) return
  var %a = 1
  var %b, %c
  while (%a <= $did(%d,1).lines) {
    set %c $did(%d,1,%a).text
    if (%c == Channel Name) set %b %b @channame
    elseif (%c == Channel Modes) set %b %b @chanmodes
    elseif (%c == Channel Users) set %b %b @chanusers
    elseif (%c == Channel Total Users) set %b %b @chantotusers
    elseif (%c == Channel Topic) set %b %b @chantopic
    elseif (%c == Idle) set %b %b @idle
    elseif (%c == Lag) set %b %b @lag
    elseif (%c == Away) set %b %b @away
    elseif (%c == Server) set %b %b @server
    elseif (%c == Server version) set %b %b @srvrver
    elseif (%c == Server port) set %b %b @srvrport
    elseif (%c == Time) set %b %b @time
    elseif (%c == Your nick) set %b %b @me
    elseif (%c == Your mode) set %b %b @usermode
    elseif (%c == Network num) set %b %b @netnum
    elseif (%c == Network) set %b %b @network
    else set %b %b $did(%d,1,%a).text
    inc %a
  }
  nvar titlebar.format %b
  nvar titlebar $nro2onoff($did(%d,9).state)
  titlebar
  tb
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircn.banlist {
  title "ircN Ban list"
  size -1 -1 184 148 
  option dbu
  list 1, 3 3 178 130, size  
  button "Delete", 2, 160 134 21 11
  button "Edit", 3, 137 134 21 11
  button "Create", 4, 114 134 21 11
}
on *:dialog:ircn.banlist:init:0:_banlist.refresh
on *:dialog:ircn.banlist:sclick:4:addbandlg
on *:dialog:ircn.banlist:sclick:3:if ($did(1).sel) editbandlg $gettok($did(1).seltext,1,32)
on *:dialog:ircn.banlist:dclick:1:if ($did(1).sel) editbandlg $gettok($did(1).seltext,1,32)
on 1:dialog:ircn.banlist:sclick:2:{
  var %a = $gettok($did(1).seltext,1,32)
  if (!%a) return
  var %b = $input(Are you sure you want to remove ban of: %a,y)
  if (%b) {
    remban %a
    _banlist.refresh
  }
}
alias _banlist.refresh {
  if ($dialog(ircnsetup.banlist)) xdid -r $v1 1
  if ($dialog(ircn.banlist)) did -r $v1 1
  var %a = 1, %b, %c
  while ($bannum(%a)) {
    set %b $ifmatch
    if ($blinfo(%b,sticky) == $true) set %c $addtok(%c,sticky,46)
    if ($dialog(ircnsetup.banlist)) xdid -a $v1 1 0 0 $tab(+ 0 0 0 0 0 0 %b, + 0 0 0 0 $blinfo(%b,setby), + 0 0 0 0 %c, + 0 0 0 0 $blinfo(%b,chans), + 0 0 0 0 $bantime($blinfo(%b,setdate)),+ 0 0 0 0 $iif($blinfo(%b,lastused),$bantime($blinfo(%b,lastused))), + 0 0 0 0 $blinfo(%b,reason)  )
    if ($dialog(ircn.banlist)) did -a $v1 1 $listvfrmt($tab(90 %b,50 $blinfo(%b,chans),50 $blinfo(%b,reason),50 $blinfo(%b,setby))).line
    inc %a
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add ban / Edit ban dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias addbandlg dlg ircn.addedban_add ircn.addedban
alias editbandlg {
  var %a = $1, %d = ircn.addedban_edit
  dlg %d ircn.addedban
  var %b = $banhost2num(%a)
  did -ra %d 2 %a
  did -m %d 2
  var %z = 1
  while ($gettok($blinfo(%a,chans),%z,44) != $null) { did -a %d 4 $ifmatch | inc %z }
  did -c %d 4 1
  did -ra %d 6 $blinfo(%a,reason)
  if ($blinfo(%a,sticky)) did -c %d 9
  did -ra %d 10 remaining text: $calc(120 - $did(%d,6,1).len)
  dialog -t %d Edit Ban
}
dialog ircn.addedban {
  title "Add Ban"
  size -1 -1 128 76
  option dbu
  text "Hostmask:", 1, 4 4 27 11
  edit "", 2, 33 3 91 12, autohs
  text "Channels:", 3, 4 18 28 10
  text "Reason:", 5, 4 33 28 10
  edit "", 6, 33 31 91 13, multi autohs autovs limit 120
  button "&Cancel", 7, 104 61 21 12, cancel
  button "&OK", 8, 81 61 21 12, ok
  check "Sticky", 9, 4 61 29 9
  text "remaining text: ", 10, 55 46 67 11
  combo 4, 34 17 79 55, size edit drop
  button "+", 11, 116 16 7 7
  button "-", 12, 116 23 7 7
}
on 1:dialog:ircn.addedban_*:sclick:11:did -a $dname 4 $did(4)
on 1:dialog:ircn.addedban_*:sclick:12:{ did -d $dname 4 $did(4).sel | did -c $dname 4 $did(4).lines }
on 1:dialog:ircn.addedban_*:edit:6:did -ra $dname 10 remaining text: $calc(120 - $did(6,1).len)
/*
on 1:dialog:ircn.addedban_*:edit:8:{
  addban $did(2) $iif($did(4),$did(4),all) $did(6)
  if ($did(9).state) stickban $did(2)
}
*/
on 1:dialog:ircn.addedban_*:sclick:8:{
  if ($gettok($dname,2,95) == add) {
    var %a = 1, %b
    while ($did(4,%a) != $null) {
      set %b $addtok(%b,$did(4,%a),44)
      inc %a
    }
    addban $did(2) $iif(%b,%b,all) $did(6)
    if ($did(9).state) stickban $did(2)
    _banlist.refresh
  }
  if ($gettok($dname,2,95) == edit) {
    var %a = 1, %b
    while ($did(4,%a) != $null) {
      set %b $addtok(%b,$did(4,%a),44)
      inc %a
    }
    remban $did(2)
    addban $did(2) $iif(%b,%b,all) $did(6)
    if ($did(9).state) stickban $did(2)
    _banlist.refresh
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setting forcing dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircn.nethshdetect.list {
  title "ircN network setting detection"
  size -1 -1 378 298
  option pixels
  list 1, 2 0 368 264, size hsbar extsel
  button "&Delete", 2, 320 268 42 22
  button "&Edit", 3, 274 268 42 22
  button "&Add", 4, 228 268 42 22
}
on *:dialog:ircn.nethshdetect.list:sclick:4:nethshdetect.add $did(1).lines
on *:dialog:ircn.nethshdetect.list:sclick:3:if ($did(1).sel) nethshdetect.edit $did(1).sel
on *:dialog:ircn.nethshdetect.list:sclick:2:if ($did(1).sel) nethshdetect.del $did(1).sel
on *:dialog:ircn.nethshdetect.list:init:0:_nethshdetect.refreshlist
alias _nethshdetect.refreshlist {
  var %d = ircNsetup.nethshdetect.list
  if (!$isfile($sd(netdetect.ini))) return

  if ($dialog(ircNsetup.nethshdetect.list)) xdid -r $v1 1
  if ($dialog(ircn.nethshdetect.list)) did -r $v1 1
  var %a = 0, %b = $ini($sd(netdetect.ini),0)
  while (%a < %b) {
    ircNsetup.nethshdetect.upd.fill.list %a
    inc %a
  }
}
; network,server,serverip,port,nick,anick,emailaddr,fullname,hashname
alias ircNsetup.nethshdetect.upd.fill.list {
  var %d = ircNsetup.nethshdetect.list
  var %a, %b, %c, %x, %y, %s, %n
  set %c $1
  set %b 1
  set %a $+(<any>,$chr(9),<any>,$chr(9),<any>,$chr(9),<any>,$chr(9),<any>,$chr(9),<any>,$chr(9),<any>,$chr(9),<any>,$chr(9),<any>)
  while ($gettok($readini($sd(netdetect.ini),$+(n,%c),n0),%b,9)) {
    set %x $ifmatch
    set %y $gettok($readini($sd(netdetect.ini),$+(n,%c),n0),$calc(%b + 1),9)
    if (%x == network) set %a $puttok(%a,%y,1,9)
    if (%x == nick) set %a $puttok(%a,%y,5,9)
    if (%x == anick) set %a $puttok(%a,%y,6,9)
    if (%x == email) set %a $puttok(%a,%y,7,9)
    if (%x == fullname) set %a $puttok(%a,%y,8,9)
    if (%x == hashnro) set %a $puttok(%a,%y,9,9)

    if (%x == server)  set %a $puttok(%a,%y,2,9)
    if (%x == serverip)  set %a $puttok(%a,%y,3,9)
    if (%x == port)  set %a $puttok(%a,%y,4,9)

    inc %b
    inc %b
  }
  if ($dialog(ircNsetup.nethshdetect.list)) xdid -a $v1 1 0 0 + 0 0 0 0 -1 -1 $gettok(%a,1,9) $chr(9) + 0 0 0 $gettok(%a,2,9) $chr(9) + 0 0 0 $gettok(%a,3,9) $chr(9) + 0 0 0 $gettok(%a,4,9) $chr(9) + 0 0 0 $gettok(%a,5,9) $chr(9) + 0 0 0 $gettok(%a,6,9) $chr(9) + 0 0 0 $gettok(%a,7,9) $chr(9) + 0 0 0 $gettok(%a,8,9) $chr(9) + 0 0 0 $gettok(%a,9,9)
  if ($dialog(ircn.nethshdetect.list)) did -a $v1 1 $listvfrmt($tab(60 $gettok(%a,9,9),30 $gettok(%a,1,9),30 $gettok(%a,2,9),30 $gettok(%a,3,9),30 $gettok(%a,4,9),30 $gettok(%a,5,9),30 $gettok(%a,6,9),30 $gettok(%a,7,9),30 $gettok(%a,8,9))).line
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setting forcing Add Dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias nethshdetect.edit {
  if ($1 !isnum) return
  var %b = ircNsetup.nethshdetect.add, %c = $calc($1 - 1)
  if (!$dialog(%b)) dlg %b
  did -ra %b 23 %c
  did -ra %b 15 &Edit
  ircNsetup.nethshdetect.upd.fill %c
}
alias nethshdetect.add {
  var %b = ircNsetup.nethshdetect.add, %c = $1
  if (!$dialog(%b)) dlg %b
  did -ra %b 23 %c
  did -ra %b 15 &Add
}
alias nethshdetect.del {
  if ($1 !isnum) return
  var %b = ircNsetup.nethshdetect.add, %c = $calc($1 - 1)
  var %a = $ini($sd(netdetect.ini),0)
  remini $sd(netdetect.ini) $+(n,%c)
  if (%c == $calc(%a - 1)) { _nethshdetect.refreshlist | return }
  while (%c < $calc(%a - 1)) {
    writeini $sd(netdetect.ini) $+(n,%c) n0 $readini($sd(netdetect.ini),$+(n,$calc(%c + 1)),n0)
    inc %c
  }
  remini $sd(netdetect.ini) $+(n,$calc(%a - 1))
  _nethshdetect.refreshlist
}
dialog ircNsetup.nethshdetect.add {
  title "Network setting detection"
  size -1 -1 139 179
  option dbu
  text "Network:", 2, 16 43 25 12
  text "Nick:", 3, 16 91 25 12
  text "Alt. Nick:", 4, 16 103 29 12
  text "Email:", 5, 16 115 25 12
  text "Realname:", 6, 16 127 25 11
  combo 7, 61 43 60 150, size edit drop
  edit "", 8, 61 91 60 12
  edit "", 9, 61 103 60 12
  edit "", 10, 61 115 60 12
  edit "", 11, 61 127 60 12
  text "Network setting to use:", 12, 16 138 37 16
  edit "", 13, 61 142 60 12
  box "Settings", 1, 3 32 132 131
  text "Network setting forcing allows you to force your settings to a specific file depending on matching criteria *ADVANCED ONLY*", 14, 4 3 131 27
  button "&Add", 15, 70 165 31 12, ok
  button "&Cancel", 16, 104 165 31 12, cancel
  edit "", 17, 61 79 60 12
  edit "", 18, 61 67 60 12
  edit "", 19, 61 55 60 12
  text "Server IP:", 20, 16 67 33 12
  text "Server:", 21, 16 55 32 12
  text "Server Port:", 22, 16 79 39 12
  text "", 23, 9 167 25 8, hide
}
on *:dialog:ircNsetup.nethshdetect.add:sclick:15:{
  ircNsetup.nethshdetect.add.save
}
alias ircNsetup.nethshdetect.add.save {
  var %d = ircNsetup.nethshdetect.add
  var %c = $did(%d,23)
  if ($did(%d,13) == $null) { echo -a ERROR: You must set network setting to be used! | halt }
  var %a
  if (($did(%d,7,0) != $null) && (($did(%d,7,0) != Global))) { set %a $instok(%a,network,$calc($numtok(%a,9) + 1),9) | set %a $instok(%a,$did(%d,7,0),$calc($numtok(%a,9) + 1),9) }
  if ($did(%d,8) != $null) { set %a $instok(%a,nick,$calc($numtok(%a,9) + 1),9) | set %a $instok(%a,$did(%d,8),$calc($numtok(%a,9) + 1),9) }
  if ($did(%d,9) != $null) { set %a $instok(%a,anick,$calc($numtok(%a,9) + 1),9) | set %a $instok(%a,$did(%d,9),$calc($numtok(%a,9) + 1),9) }
  if ($did(%d,10) != $null) { set %a $instok(%a,email,$calc($numtok(%a,9) + 1),9) | set %a $instok(%a,$did(%d,10),$calc($numtok(%a,9) + 1),9) }
  if ($did(%d,11) != $null) { set %a $instok(%a,realname,$calc($numtok(%a,9) + 1),9) | set %a $instok(%a,$did(%d,11),$calc($numtok(%a,9) + 1),9) }
  if ($did(%d,13) != $null) { set %a $instok(%a,hashnro,$calc($numtok(%a,9) + 1),9) | set %a $instok(%a,$did(%d,13),$calc($numtok(%a,9) + 1),9) }
  if ($did(%d,17) != $null) { set %a $instok(%a,port,$calc($numtok(%a,9) + 1),9) | set %a $instok(%a,$did(%d,17),$calc($numtok(%a,9) + 1),9) }
  if ($did(%d,18) != $null) { set %a $instok(%a,serverip,$calc($numtok(%a,9) + 1),9) | set %a $instok(%a,$did(%d,18),$calc($numtok(%a,9) + 1),9) }
  if ($did(%d,19) != $null) { set %a $instok(%a,server,$calc($numtok(%a,9) + 1),9) | set %a $instok(%a,$did(%d,19),$calc($numtok(%a,9) + 1),9) }
  if (%a != $null) writeini $sd(netdetect.ini) $+(n,%c) n0 %a
  _nethshdetect.refreshlist
}
on *:dialog:ircNsetup.nethshdetect.add:init:0:_ircn.setup.addnetcombo.offline $dname 7

; network,server,serverip,port,nick,anick,emailaddr,fullname,hashname
alias ircNsetup.nethshdetect.upd.fill {
  var %d = ircNsetup.nethshdetect.add
  did -r %d 7,8,9,10,11,13,17,18,19
  did -ra %d 23 $1
  _ircn.setup.addnetcombo.offline %d 7
  var %a = 0, %a1 = 0, %b, %c, %x, %y, %s, %n
  set %c $1
  set %b 1
  while ($gettok($readini($sd(netdetect.ini),$+(n,%c),n0),%b,9)) {
    set %x $ifmatch
    set %y $gettok($readini($sd(netdetect.ini),$+(n,%c),n0),$calc(%b + 1),9)
    if (%x == network) { 
      set %s $didwm(%d,7,%y)
      if (%s) did -c %d 7 %s
      else did -ra %d 7 0 %y
    }
    if (%x == nick) did -ra %d 8 %y
    if (%x == anick) did -ra %d 9 %y
    if (%x == email) did -ra %d 10 %y
    if (%x == fullname) did -ra %d 11 %y
    if (%x == hashnro) did -ra %d 13 %y
    if (%x == server)  did -ra %d 19 %y
    if (%x == serverip)  did -ra %d 18 %y
    if (%x == port)  did -ra %d 17 %y
    inc %b
    inc %b
  }
}

dialog ircn.chanhighlightfilter {
  title "Channel highlight filtering"
  size -1 -1 231 284
  option dbu
  text "Active Highlights:", 1, 62 5 65 13
  combo 2, 130 4 93 62, size drop
  text "Network: Efnet", 3, 62 18 136 13
  text "Enabled in:", 4, 8 92 51 12, disable
  text "Disabled in:", 5, 131 93 51 12, disable
  list 6, 6 106 90 97, disable size
  list 7, 131 106 90 97, disable size
  button "->", 8, 103 125 22 16, disable
  button "<-", 9, 103 145 22 16, disable
  radio "Enabled in every channel on EFnet", 10, 7 41 124 10, disable
  radio "Disabled in every channel on Efnet", 11, 7 54 121 10, disable
  radio "Specified channels only:", 12, 7 64 75 15, disable
  button "&OK", 13, 190 261 37 18, default ok
  button "&Cancel", 14, 151 261 37 18, cancel
  button "Modify Highlights", 15, 3 262 51 18
  radio "Every channel except:", 16, 7 76 75 15, disable
  box "", 17, 2 32 225 179
  box "Settings", 18, 2 211 225 47
  check "Only match if highlight appears within the first ", 19, 6 222 118 11
  edit "", 20, 126 222 18 12
  text "words", 21, 147 224 27 10
}
on *:DIALOG:ircn.chanhighlightfilter:sclick:15:abook -h 
on *:DIALOG:ircn.chanhighlightfilter:sclick:2:{
  if (!$did(2)) return
  did -e $dname 10-12,16
  did -r $dname 6,7
  did -c $dname 10
  did -u $dname 11,12,16
}
on *:DIALOG:ircn.chanhighlightfilter:sclick:8:{
  if (!$did(6).sel) return
  if ($didwm(7,$did(6).seltext)) return
  did -a $dname 7 $did(6).seltext
  did -d $dname 6 $did(6).sel
}
on *:DIALOG:ircn.chanhighlightfilter:sclick:9:{
  if (!$did(7).sel) return
  if (!$didwm(6,$did(7).seltext))  did -a $dname 6 $did(7).seltext
  did -d $dname 7 $did(7).sel
}
on *:DIALOG:ircn.chanhighlightfilter:sclick:10,11,12,16:{
  did $iif(($did == 12 || $did == 16),-e,-b) $dname 4-9
  if ($did == 12) { did -ra $dname 4 Enable in: | did -ra $dname 5 Unused: | _ircn.chanhighlightfilter.refresh }
  if ($did == 16)  { did -ra $dname 4 Currently in: | did -ra $dname 5 Disable in: | _ircn.chanhighlightfilter.refresh }

}

alias -l _ircn.chanhighlightfilter.refresh {
  var %a = 1
  did -r ircn.chanhighlightfilter 6,7
  while ($chan(%a) != $null) {
    var %d = $ifmatch
    if (!$didwm(7,%d))  did -a ircn.chanhighlightfilter 6 %d
    inc %a
  }
}
on *:DIALOG:ircn.chanhighlightfilter:init:0:{
  did -ra $dname 3 Network: $curnet
  did -ra $dname 10 Enabled in every channel on $curnet
  did -ra $dname 11 Disabled in every channel on $curnet

  var %a = 1
  while ($highlight(%a) != $null) { 
    did -a $dname 2 $highlight(%a).text
    inc %a 
  }
}

dialog ircn.pruneserverlist {
  title "Prune server list"
  size -1 -1 337 185
  option dbu
  list 1, 15 22 119 116, size extsel
  box "* Always exclude these servers from prune *", 2, 192 8 139 142
  button ">>", 3, 155 54 28 18, disable
  button "<<", 4, 155 75 28 18, disable
  box "Prune these servers", 5, 7 8 139 142
  list 6, 200 22 119 116, size extsel
  button "Prune", 7, 292 160 38 17, ok
  button "Cancel", 8, 252 160 38 17, default cancel
  text "* These servers were not found in the updated servers.ini file and can be pruned. Please exclude any of your custom servers first.", 9, 7 159 163 19
}

on *:DIALOG:ircn.pruneserverlist:init:0:{
  if (!$window(@ $+ $dname)) { dialog -x $dname |   return }
  loadbuf -o $dname 6 $sd(pruneservers_exclude.dat)

  var %a = 1, %n = $line(@ $+ $dname,0), %net 

  while (%a <= %n) {
    var %b = $line(@ $+ $dname,%a)
    if (%net != $gettok(%b,3,32)) || (!%net) {  if (%net) { did -a $dname 1 } |  set %net $gettok(%b,3,32)  | did -a $dname 1 === Network: %net == }
    did -a $dname 1 $gettok(%b,1,32)
    if ((%b) && (!$didwm(6,$gettok(%b,1,32),0))) { var %q = 1 | did -ck $dname 1 $did(1,0).lines }
    inc %a
  }
  if (%q) did -e $dname 3

}
on *:DIALOG:ircn.pruneserverlist:sclick:1:{
  ; if ($did(1,0).sel == 1) && (===* iswm $did(1).seltext) { did -b $dname 3 | return }
  did $iif($did(1).sel,-e,-b) $dname 3
}
on *:DIALOG:ircn.pruneserverlist:sclick:6:did $iif($did(6).sel,-e,-b) $dname 4

on *:DIALOG:ircn.pruneserverlist:close:0: { if ($window(@ircn.pruneserverlist)) { window -c @ircn.pruneserverlist } | unset %serverprune.* } 
on *:DIALOG:ircn.pruneserverlist:sclick:7:{
  var %a = 1,%b, %n = $did(6).lines
  write -c $sd(pruneservers_exclude.dat)
  hmake pruneservers_exclude 25
  while (%a <= %n) {
    set %b $did(6,%a)
    if (%b) {
      if ($gettok(%b,1,32) == *) set %b * $gettok(%b,6-,32)
      hadd pruneservers_exclude %a %b

    }
    inc %a
  }
  hsave -n pruneservers_exclude $sd(pruneservers_exclude.dat)
  hfree pruneservers_exclude

  var %a = 1,%b, %c, %n = $line(@ $+ $dname,0), %m

  while (%a <= %n) {
    var %b = $line(@ $+ $dname,%a)
    set %c $gettok(%b,1,32)
    if ((%c) && (!$didwm(6,%c,0))) { server -r %c | inc %m }

    inc %a
  }
  if (!%serverprune.silent) iecho Pruned $hc($u(%m)) servers from server list.
  unset %serverprune.*



}
on *:DIALOG:ircn.pruneserverlist:sclick:3:{
  if (!$did(1).sel) return
  var %a = 1, %b,%c, %n = $did(1,0).sel
  did -cu $dname 6 
  while (%a <= %n) {
    set %b $did(1,%a).sel
    set %c $did(1,%b)
    if (===* iswm %c) set %c * All servers on group $+ : $gettok(%c,3,32)
    if (%c) {
      if (!$didwm(6,%c,0)) {
        did -a $dname 6 %c
        did -ck $dname 6 $did(6).lines
      }
      ;else did -d $dname 1 %b
    }

    inc %a
  }
  did $iif($did(6).sel,-e,-b) $dname 4
}
on *:DIALOG:ircn.pruneserverlist:sclick:4:{
  if (!$did(6).sel) return
  var %a = $did(6,0).sel, %b,%c

  while (%a >= 0) {
    set %b $did(6,%a).sel
    set %c $did(6,%b)
    if (%c) {
      did -d $dname 6 %b
    }

    dec %a
  }
  did $iif($did(6).sel,-e,-b) $dname 4
}

dialog ircn.chan.onjoinperform {
  title "Onjoin Perform"
  size -1 -1 226 226
  option dbu
  tab "Network: ", 2, 5 6 216 194
  radio "Chan:", 4, 13 31 82 14, tab 2
  radio "Chan: Global", 5, 99 33 63 10, tab 2
  edit "", 1, 12 50 200 121, tab 2 multi return autohs autovs hsbar vsbar
  text "ms", 14, 77 183 19 9, tab 2
  edit "", 15, 45 181 30 14, disable tab 2 autohs
  check "Delay:", 16, 15 181 31 12, tab 2
  edit "", 17, 12 50 200 121, tab 2 multi return autohs autovs hsbar vsbar hide
  tab "Network: Global", 3
  radio "Chan:", 6, 13 31 82 14, tab 3
  radio "Chan: Global", 7, 99 33 63 10, tab 3
  edit "", 8, 12 50 200 121, tab 3 multi return autohs autovs hsbar vsbar
  text "ms", 13, 77 183 19 9, tab 3
  edit "", 12, 45 181 30 14, disable tab 3 autohs
  check "Delay:", 11, 15 181 31 12, tab 3
  edit "", 18, 12 50 200 121, tab 3 multi return autohs autovs hsbar vsbar hide
  button "&Cancel", 10, 134 205 43 17, cancel
  button "&OK", 9, 179 205 43 17, ok
}

alias onjoin {
  var %d = ircn.chan.onjoinperform
  var %c = $iif($1 ischan,$1,#)
  dlg %d
  if (!%c) { did -ra %d 4,6 Chan: none | did -b %d 4,6 | did -c %d 5,7 }
  else { did -ra %d 4,6 Chan: %c | did -c %d 4,6 }
  if (!$curnet) { did -b %d 2 | did -c %d 3 }
  did -ra %d 2 Network: $curnet
}
on *:DIALOG:ircn.chan.onjoinperform:sclick:4:{ did -v $dname 1 | did -h $dname 17 | did -f $dname 1  }
on *:DIALOG:ircn.chan.onjoinperform:sclick:5:{ did -h $dname 1 | did -v $dname 17 | did -f $dname 17  }
on *:DIALOG:ircn.chan.onjoinperform:sclick:6:{ did -v $dname 8 | did -h $dname 18 | did -f $dname 8  }
on *:DIALOG:ircn.chan.onjoinperform:sclick:7:{ did -h $dname 8 | did -v $dname 18 | did -f $dname 18  }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MISC aliases & other stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on *:UNLOAD:.timer_classicui.resizesetup off
alias _nosave return
alias _save.modulesaves {
  var %b, %a = 1

  while ($hfind(tempsetup,$tab(set,ircn.setup.modern,global,global,module,*,*),%a,w)) {
    set %b $ifmatch

    if ($ismod($gettok($hget(tempsetup,%b),5,9)))  $gettok($hget(tempsetup,%b),4,9)
    inc %a
  }
}
alias dlgnotdone {

  var %d = ircnsetup.notdone

  if ($istok(%ircnsetup.docked,%d,44)) return
  dlg -r %d
  dialog -rsb %d -1 -1 176 148

}
dialog ircnsetup.notdone {
  title "Dialog Not Done"
  size -1 -1 0 0
  option dbu
  text "The feature has not been added yet, this is just a placeholder.", 1, 24 68 132 22, center
}
dialog ircnsetup.blank {
  title " "
  size -1 -1 0 0
  option dbu
}
dialog ircn.pleasewaitfreeze {
  title "Please Wait..."
  size -1 -1 140 46
  option dbu
  text "Please wait while the current operation completes.  Your mIRC may freeze for a few seconds.", 1, 6 9 131 30
  button "Button", 2, 98 127 26 27, ok
}
on *:DIALOG:ircn.pleasewaitfreeze:init:*:.timer 1 5 if ($ $+ dialog( $dname )) dialog -x $dname
