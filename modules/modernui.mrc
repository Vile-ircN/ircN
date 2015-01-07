;%%%%%%%%%%%%%%%%%%%%%%%%
;script ircN Modern UI
;author ircN Development Team
;url http://www.ircN.org
;%%%%%%%%%%%%%%%%%%%%%%%%


; __ todo ___
; add to setup dialog:
; clear bans after X
; show clones on join

; __order___
; local aliases
; aliases

; dialog
; events
; alias
; local aliases

on *:LOAD:_modernui.lock.test
on *:START:_modernui.lock.test
alias _modernui.lock.test {
  if ($lock(dll) == $true) {
    iecho ircN will not be fully functional unless DLL usage is unlocked.
    iecho 1. Press ALT + O and goto Other -> Lock and uncheck 'Disable run, dll, com commands'
    iecho 2. Restart ircN
    halt
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NXT Modern dialog / Themes dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircn.nxt.modern {
  title "ircN eXtended MTS Theme Engine [/themes]"
  size -1 -1 370 340
  option pixels
  icon $gfxdir(icons\ircn.ico), 0
  ;tab "Info", 14, 0 0 366 288
  ;text "", 17, 140 172 210 76, hide tab 14
  ;edit "", 17, 132 199 228 77, tab 14 multi vsbar
  ;list 17, 140 170 211 79, disable tab 14 size vsbar
  ;list 1, 4 30 120 226, tab 14 size
  ;icon 2, 134 30 224 167,  $icondir(mirccolors.icl), 16, tab 14 noborder top
  ;button "&Load", 19, 6 258 118 20, tab 14
  ;tab "Apply", 16
  ;text "When loading, apply:", 4, 18 30 162 24, tab 16
  ;check "Everything", 5, 208 36 100 20, tab 16
  ;check "Background images", 6, 18 68 118 20, tab 16
  ;check "Colors", 7, 18 86 100 20, tab 16
  ;check "Event Messages", 8, 18 106 136 20, tab 16
  ;check "Fonts", 9, 18 126 100 20, tab 16
  ;check "Nicklist colors", 10, 208 68 100 20, tab 16
  ;check "Timestamp", 11, 208 88 100 20, tab 16
  ;check "Toolbar buttons", 12, 208 108 100 20, tab 16
  ;check "Toolbar/Switchbar bgs", 13, 208 128 130 20, tab 16
  ;text "It is highly recommended that you apply the theme's event messages; also most themes look weird if you don't apply their color settings.", 18, 18 178 328 74, tab 16
  ;tab "Settings", 3
  ;box "Font replacement:", 26, 6 32 210 164, tab 3
  ;check "Enable", 21, 14 50 100 20, tab 3
  ;list 22, 14 70 192 90, tab 3 size
  ;button "&Add", 23, 46 166 44 20, tab 3
  ;button "&Edit", 24, 94 166 44 20, tab 3
  ;button "&Remove", 25, 142 166 62 20, tab 3
  ;box "Cache:", 20, 6 202 210 74, tab 3
  ;check "Previews", 28, 18 220 84 20, tab 3
  ;check "Compiled scripts", 27, 106 220 106 20, tab 3
  ;text "Usage: 10MB", 40, 18 242 84 22, tab 3
  ;button "&Clear cache", 29, 130 244 74 20, tab 3
  ;box "/themes dialog:", 32, 222 32 140 166, tab 3
  ;check "Autopreview", 30, 230 52 126 20, tab 3
  ;check "Close on theme load", 31, 230 74 128 20, tab 3
}
on *:dialog:ircn.nxt.modern:init:0:{
  var %d = ircn.nxt.modern
  dcx Mark %d ircn.nxt.moderndlg.event

  ;xdialog -c %d 14 tab 0 0 366 288
  ;xdialog -c %d 16 tab 0 0 366 288
  xdialog -c %d 50 tab 2 2 366 336
  xdid -a %d 50 0 1 Theme $chr(9) 51 panel 2 2 366 336 $chr(9)


  ;$chr(9) 52 divider 4 10 340 268 vertical 
  ;xdialog -c %d 1 treeview  4 30 120 226 hasbuttons haslines linesatroot showsel notooltips
  ;xdid -l %d 50 
  ;xdid -c %d 51 1 treeview  2 2 120 226 hasbuttons haslines linesatroot showsel notooltips
  ;xdid -c %d 51 17 edit 128 169 228 77 multi vsbar
  ;xdid -a %d 17 WHEE

  ;xdialog -c $dname 1 panel 12 22 366 288

  ;// Initialising control: Button (Button 19)
  xdid -c %d 51 19 button 2 288 120 20 tabstop
  xdid -t %d 19 Load

  ;// Initialising control: (Image 2)
  xdid -c %d 51 2 image 127 4 224 210
  ;xdid -i %d 2 C:\dcx\start.bmp

  ;// Initialising control: Author: whoever (Edit 17)
  xdid -c %d 51 17 edit 126 216 224 90 autohs autovs tabstop multi vsbar

  ;// Initialising control: (TreeView 1)
  xdid -c %d 51 1 treeview 2 2 120 282 hasbuttons haslines linesatroot showsel notooltips




  ;// Initialising control: (Panel 1)
  xdid -a %d 50 0 0 Apply $chr(9) 52 panel 2 2 366 336 0 0 366 336


  ;// Initialising control: Settings: (Box 3)
  xdid -c %d 52 54 box 2 2 362 332
  xdid -t %d 54 Settings:
  xdid -l %d 54 root $chr(9) +pl 0 1 0 0

  ;;;;;;;;;xdialog -c %d 1 panel 2 2 360 260

  ;// Initialising control: Colors (Check 5)
  xdid -c %d 54 7 check 10 75 150 20 tabstop
  xdid -t %d 7 Colors

  ;// Initialising control: Everything (Check 3)
  xdid -c %d 54 5 check 190 24 150 20 tabstop
  xdid -t %d 5 Everything

  ;// Initialising control: It's highly recommended that you apply the theme's event messages; also most themes look weird if you don't apply their color settings. (Text 12)
  ;  xdid -c %d 54 18 text 27 173 300 80
  xdid -c %d 54 18 text 27 230 300 80
  xdid -t %d 18 It's highly recommended that you apply the theme's event messages; also most themes look weird if you don't apply their color settings.

  ;// Initialising control: Timestamp (Check 9)
  xdid -c %d 54 11 check 190 75 150 20 tabstop
  xdid -t %d 11 Timestamp

  ;// Initialising control: Toolbar/Switchbar bgs (Check 11)
  xdid -c %d 54 13 check 190 115 150 20 tabstop
  xdid -t %d 13 Toolbar/Switchbar bgs

  ;// Initialising control: Background images (Check 4)
  xdid -c %d 54 6 check 10 55 150 20 tabstop
  xdid -t %d 6 Background images

  ;// Initialising control: Fonts (Check 7)
  xdid -c %d 54 9 check 10 115 150 20 tabstop
  xdid -t %d 9 Fonts

  ;// Initialising control: When loading, apply: (Text 2)
  xdid -c %d 54 4 text 10 24 160 20
  xdid -t %d 4 When loading, apply:

  ;// Initialising control: Nicklist colors (Check 8)
  xdid -c %d 54 10 check 190 55 150 20 tabstop
  xdid -t %d 10 Nicklist colors

  ;// Initialising control: Toolbar buttons (Check 10)
  xdid -c %d 54 12 check 190 95 150 20 tabstop
  xdid -t %d 12 Toolbar buttons

  ;// Initialising control: Event Messages (Check 6)
  xdid -c %d 54 8 check 10 95 150 20 tabstop
  xdid -t %d 8 Event Messages

  ;// Initialising control: Sounds
  xdid -c %d 54 33 check 10 135 150 20 tabstop
  xdid -t %d 33 Sounds
  xdid -h %d 33


  ;// Initialising control: (Panel 1)
  xdid -a %d 50 0 3 Settings $chr(9) 53 panel 2 2 366 336 0 0 366 336
  ;;;;;;;xdialog -c %d 1 panel 2 3 360 250

  ;// Initialising control: Cache: (Box 3)
  xdid -c %d 53 20 box 5 159 180 80
  xdid -t %d 20 Cache:
  xdid -l %d 20 root $chr(9) +pl 0 1 0 0

  ;// Initialising control: &Clear (Button 9)
  xdid -c %d 20 29 button 113 45 60 20 tabstop
  xdid -t %d 29 &Clear

  ;// Initialising control: Previews (Check 7)
  xdid -c %d 20 28 check 9 20 80 20 tabstop
  xdid -t %d 28 Previews

  ;// Initialising control: Compiled scripts (Check 8)
  xdid -c %d 20 27 check 8 45 100 20 tabstop
  xdid -t %d 27 Compiled scripts

  ;// Initialising control: Usage: 805kb (Text 10)
  xdid -c %d 20 40 text 90 22 80 20 right
  xdid -t %d 40 Usage: 805kb

  ;// Initialising control: /Themes dialog: (Box 4)
  xdid -c %d 53 32 box 190 5 164 150
  xdid -t %d 32 /Themes dialog:
  xdid -l %d 32 root $chr(9) +pl 0 1 0 0

  ;// Initialising control: Autopreview (Check 5)
  xdid -c %d 32 30 check 6 23 150 20 tabstop
  xdid -t %d 30 Autopreview

  ;// Initialising control: Close on theme load (Check 6)
  xdid -c %d 32 31 check 6 45 150 20 tabstop
  xdid -t %d 31 Close on theme load

  ;// Initialising control: Font replacement: (Box 2)
  xdid -c %d 53 26 box 4 6 180 150
  xdid -t %d 26 Font replacement:
  xdid -l %d 26 root $chr(9) +pl 0 1 0 0

  ;// Initialising control: &Remove (Button 13)
  xdid -c %d 26 25 button 114 123 60 20 tabstop
  xdid -t %d 25 &Remove

  ;// Initialising control: &Add (Button 15)
  xdid -c %d 26 23 button 15 123 50 20 tabstop
  xdid -t %d 23 &Add

  ;// Initialising control: (ListView 12)
  xdid -c %d 26 22 listview 6 39 168 80 fullrow showsel nolabelwrap tabstop report
  xdid -t %d 22 +l 0 90 Font $chr(9) +l 0 90 Replacement


  ;// Initialising control: Enable (Check 11)
  xdid -c %d 26 21 check 6 18 150 20 tabstop
  xdid -t %d 21 Enable

  ;// Initialising control: &Edit (Button 14)
  xdid -c %d 26 24 button 65 123 50 20 tabstop
  xdid -t %d 24 &Edit

  var %did = 5 6 7 8 9 10 33 11 12 13, %i = $numtok(%did, 32), %set = $hget(nxt_data, Apply)
  while (%i) { if ($isbit(%set, %i)) { xdid -c %d $gettok(%did, %i, 32) } | dec %i }
  if ($xdid(%d, 5).state) { xdid -b %d 6,7,8,9,10,33,11,12,13 }

  var %did = 28 27, %i = $numtok(%did, 32), %set = $hget(nxt_data, Cache)
  while (%i) { if ($isbit(%set, %i)) { xdid -c $dname $gettok(%did, %i, 32) } | dec %i }
  ;don't cache theme scriptfiles at this point
  xdid -b $dname 27

  ;Dialog settings
  var %did = 30 31, %i = $numtok(%did, 32), %set = $hget(nxt_data, DlgSet)
  while (%i) { if ($isbit(%set, %i)) { xdid -c %d $gettok(%did, %i, 32) } | dec %i }

  if ($hget(nxt_data, FRep.Status)) { xdid -c %d 21 }
  else { xdid -b %d 22,23,24,25 }
  ircn.nxt.updfontrepl

  nxt_load_list $themedir
  xdid -F %d 1
}
alias -l nxt_ds return $xdid($1, $2).state
alias nxt.modern dlg -r ircn.nxt.modern
alias -l nxt_frep_disp {
  var %a = $replace($1, \~, $chr(32)), %b = $2, %s
  return %a $chr(9) + 0 %b
}
alias ircn.nxt.moderndlg.updfontrepl {
  var %d = ircn.nxt.modern, %i
  xdid -r %d 22
  %i = 1 | while ($hmatch(nxt_data, FRep.Rep.*, %i)) { xdid -a %d 22 0 0 + 0 0 0 0 -1 -1 $nxt_frep_disp($mid($ifmatch, 10), + 0 $hget(nxt_data, $ifmatch)) | inc %i }
}
alias ircn.nxt.moderndlg.event {
  var %d = ircn.nxt.modern
  if ($2 == dclick) {
    if ($3 == 2) {
      var %x = $iif($xdid(%d,1, $xdid(%d,1).selpath).tooltip isnum,$v1) $shortfn($xdid(%d,1, $gettok($xdid(%d,1).selpath,1-2,32)).tooltip)
      nxt_load_bigpreview nxt_preview %x
    }
  }
  if ($2 == sclick) {
    if ($3 == 1) {
      if ($xdid(%d,1).selpath == 1) return

      var %x = $iif($xdid(%d,1, $xdid(%d,1).selpath).tooltip isnum,$v1) $shortfn($xdid(%d,1, $gettok($xdid(%d,1).selpath,1-2,32)).tooltip)


      nxt_load_preview ircn.nxt.modern small %x
      ircn.nxt.modern.info %x
    }
    if ($3 == 5) {
      if ($xdid(%d,5).state != 1) xdid -e %d 6,7,8,9,10,33,11,12,13
      else xdid -b %d 6,7,8,9,10,33,11,12,13
    }
    if ($istok(5 6 7 8 9 10 33 11 12 13,$3,32)) {
      ;nxt_ds:  41:toolbarbg 40:toolbarbtn 39:timestamp 38:sounds 37:nickcol 36:fonts 35:events 34:colors 33:bgs 29:everything
      ;nxt_ds 13:toolbarbg 12:toolbarbtn 11:timestamp _____ 10:nickcol 9:fonts 8:events 7:colors 6:bgs 5:everything
      var %apply = $base($+($nxt_ds(%d,13), $nxt_ds(%d,12), $nxt_ds(%d,11), $nxt_ds(%d,33), $nxt_ds(%d,10), $nxt_ds(%d,9), $nxt_ds(%d,8), $nxt_ds(%d,7), $nxt_ds(%d,6), $nxt_ds(%d,5)), 2, 10)
      if (!%apply) { %apply = 1 }
      hadd nxt_data Apply %apply
    }
    if ($istok(27 28,$3,32)) {
      var %cache = $base($+($nxt_ds(%d,27), $nxt_ds(%d,28)), 2, 10)
      hadd nxt_data Cache %cache
    }
    if ($istok(30 31,$3,32)) {
      var %dlgset = $base($+($nxt_ds(%d,31), $nxt_ds(%d,30)), 2, 10)
      hadd nxt_data DlgSet %dlgset
    }
    if ($3 == 23) {
      $dialog(nxt_frep_add_modern, nxt_frep, -4)
    }
    if ($3 == 24) {
      if (!$xdid(ircn.nxt.modern,22).sel) return
      $dialog(nxt_frep_edit_modern, nxt_frep, -4)
    }
    if ($3 == 25) {
      if (!$xdid(ircn.nxt.modern,22).sel) return
      var %x = $input(Do you really want to remove $xdid(%d,22,1).seltext ?,y,Remove?)
      if (%x) {
        hdel nxt_data $+(FRep.Rep.,$replace($xdid(%d,22,1).seltext,$chr(32),\~))
        ircn.nxt.updfontrepl
      }
    }
    if ($3 == 19) {
      if ($numtok($xdid(%d,1).selpath,32) < 2) return

      var %fn = $xdid(%d,1, $gettok($xdid(%d,1).selpath,1-2,32)).tooltip
      var %x = $iif($xdid(%d,1, $xdid(%d,1).selpath).tooltip isnum,$v1) $shortfn(%fn)

      var %sch

      if ($xdid(%d,1, $xdid(%d,1).selpath).tooltip isnum) { %sch = -s $+ $xdid(%d,1, $xdid(%d,1).selpath).tooltip }
      ; 29 33 34 35 36 37 38 39 40 41

      .timer -oi 1 0 if ($isfile( $+ %fn $+ )) $chr(123) $&
        nxt_load %sch %fn $chr(125)
    }
  }
}
alias -l ircn.nxt.modern.info { 
  var %d = ircn.nxt.modern
  var %t, %t.name, %mtsver, %t.version, %t.author, %t.email, %t.website, %t.description, %ln, %sch, %thm

  if ($0 >= 2) { %sch = $1 | %thm = $longfn($2-) }
  else { %thm = $longfn($1-) }

  %ln = $read(%thm, nw, [mts])
  if (!%ln) { echo -s no ln | return }

  set -n %mtsver $gettok($read(%thm, nw, MTSVersion *, %ln), 2-, 32)
  if ((!%mtsver) && ($gettok($read(%thm, nw, NXTVersion *, %ln), 2-, 32))) { var %nxtver = $gettok($read(%thm, nw, NXTVersion *, %ln), 2-, 32) | set -n %mtsver NXT }
  if (!%ln) || ((%mtsver != NXT) && (!$istok(1 1.1, $calc(%mtsver), 32))) { goto inv }
  %t.name = $gettok($read(%thm, nw, Name *, %ln), 2-, 32)
  %t.version = $gettok($read(%thm, nw, Version *, %ln), 2-, 32)
  %t.author = $gettok($read(%thm, nw, Author *, %ln), 2-, 32)
  %t.email = $gettok($read(%thm, nw, EMail *, %ln), 2-, 32)
  %t.website = $gettok($read(%thm, nw, Website *, %ln), 2-, 32)
  %t.description = $gettok($read(%thm, nw, Description *, %ln), 2-, 32)


  xdid -ra %d 17
  ;if (%t.name) xdid -a %d 17 Name: $ifmatch $crlf
  if (%t.author) xdid -a %d 17 Author: $ifmatch $crlf
  if (%t.version) xdid -a %d 17 Ver: $ifmatch $crlf
  if (%t.email) xdid -a %d 17 Email: $ifmatch $crlf
  if (%t.website) xdid -a %d 17 $+ Web: $ifmatch $crlf
  if (%t.description) xdid -a %d 17 Desc: $ifmatch
  ;xdid -c %d 17 1

  return
  :inv | echo -s invalid theme file
}
alias -l nxt_listadd_theme { 
  var %t, %f = $4, %t.name, %ln

  %ln = $read(%f, nw, [mts])
  if (!%ln) { echo -s no ln | return }
  %t.name = $gettok($read(%f, nw, Name *, %ln), 2-, 32)
  xdid -a $1 $2 $tab(-1 -1, + 1 1 0 0 0 -1 -1 $iifelse(%t.name,$3), $4) 


  var %schi = 1
  while ($gettok($read(%f, nw, Scheme $+ %schi *, %ln), 2-, 32) != $null) {
    var %t.scheme [ $+ [ %schi ] ] 
    %t.scheme [ $+ [ %schi ] ] = $ifmatch 
    xdid -a $1 $2 $tab(-1 -1 -1, + 1 1 0 0 0 -1 -1 %t.scheme [ $+ [ %schi ] ], %schi) 
    inc %schi
  }
}
alias nxt_sel_curtheme {
  var %d ircn.nxt.modern
  var %a = 1, %b = $xdid(%d,1,1).num, %c, %s
  while (%a <= %b) {
    set %c $xdid(%d,1,1,%a).tooltip
    if ($longfn(%c) == $longfn($hget(nxt_data, CurTheme))) { 
      if (!$hget(nxt_data, CurScheme)) {
        xdid -c %d 1 1 %a
        nxt_load_preview ircn.nxt.modern small %c
        ircn.nxt.modern.info $shortfn(%c)
        return
      }
      else {
        xdid -t %d 1 1 %a
        var %schmi = 1, %schmt = $xdid(%d,1,1,%a).num
        while (%schmi <= %schmt) {
          set %s $xdid(%d,1,1,%a,%schmi).tooltip
          if (%s == $hget(nxt_data, CurScheme)) { xdid -c %d 1 1 %a %schmi | ircn.nxt.modern.info $shortfn(%c) | nxt_load_preview ircn.nxt.modern small %schmi %c | return }
          inc %schmi
        }
      }
    }
    inc %a
  }
  xdid -c %d 1 1
}
alias nxt_load_list {
  var %d = ircn.nxt.modern, %s
  var %x
  xdid -r %d 1
  xdid -a %d 1 $tab(-1, +be 1 1 0 0 0 -1 -1 Themes,dir)
  %s = $findfile($1-, *.mts, 0, 9, set %x $nxt_listadd_theme(%d,1,$nopath($1-),$1-))
  inc %s $findfile($1-, *.nxt, 0, 9, set %x $nxt_listadd_theme(%d,1,$nopath($1-),$1-))
  if (%s) {
    nxt_sel_curtheme
  }
  else {
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;
;; About dialog 
;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircNsetup.about.modern {
  title "ircN About"
  size -1 -1 372 342
  option pixels
  ;tab "About", 2, 4 4 370 270
  ;icon 7, 12 40 346 170,  $icondir(mirccolors.icl), 16, tab 2 noborder top
  ;text "ircN 9.00 Reldate 0/0/00", 8, 176 212 182 16, tab 2 right
  ;text "The ircN Development Team", 9, 156 232 200 16, tab 2 right
  ;link "www.ircN.org", 10, 16 232 74 20, tab 2
  ;link "#ircN@Freenode", 3, 16 212 68 16, tab 2
  ;tab "History", 4
  ;tab "Team", 5
  ;tab "Thanks", 6
  ;edit "", 1, 12 38 348 206, read multi autovs vsbar
  ;edit "", 11, 12 126 348 118, read multi autovs vsbar
}
on *:dialog:ircNsetup.about.modern:*:*: {
  if ($devent == init) {
    dcx Mark $dname ircNsetup.about.modern_cb
    xdialog -b $dname +ty

    ;// Call initilisation alias
    ircNsetup.about.modern_init_dcx
  }
}

alias -l ircNsetup.about.modern_init_dcx {
  ;// Initialising control: (Tab 1)
  xdialog -c $dname 1 tab 6 2 370 335 tabstop

  ;// Initialising control: About (Tab Item 2)
  xdid -a $dname 1 0 0 About $chr(9) 2 panel 4 22 368 340 0 0 300 200

  ;// Initialising control: (Image 4)
  var %a = $findfile($gfxdir,ircnlogo*.jpg,0)
  var %f = $findfile($gfxdir,ircnlogo*.jpg,$rand(1,%a))
  var %w = $pic(%f).width, %h = $pic(%f).height, %x
  if (%w != 352) {
    set %x $calc(%w / 352)
    set %h $round($calc(%h * %x))
  }
  xdid -c $dname 2 10 image 4 5 352 %h
  xdid -i $dname 10 + %f

  ;// Initialising control: The ircN Development Team (Text 5)
  xdid -c $dname 2 11 text 156 286 200 20 right
  xdid -t $dname 11 The ircN Development Team

  ;// Initialising control: ircN FAQ (Link 7)
  xdid -c $dname 2 12 link 4 260 100 20 tabstop
  xdid -t $dname 12 ircN FAQ

  ;// Initialising control: ircN 9.00 (Text 8)
  xdid -c $dname 2 13 text 156 260 200 20 right
  xdid -t $dname 13 ircN $nvar(ver) release: $nvar(reldate)

  ;// Initialising control: www.ircN.org (Link 6)
  xdid -c $dname 2 14 link 4 286 100 20 tabstop
  xdid -t $dname 14 www.ircN.org

  ;// Initialising control: History (Tab Item 3)
  xdid -a $dname 1 0 0 History $chr(9) 3 panel 0 0 300 200 0 0 300 200

  ;// Initialising control: x (Edit 15)
  xdid -c $dname 3 15 edit 4 5 352 300 autovs tabstop multi vsbar readonly
  xdid -t $dname 15 $noqt($txtd(ircn_history.txt))

  ;// Initialising control: Team (Tab Item 4)
  xdid -a $dname 1 0 0 Team $chr(9) 4 panel 0 0 300 200 0 0 300 200

  ;// Initialising control: x (Edit 16)
  xdid -c $dname 4 16 edit 4 5 352 300 autovs tabstop multi vsbar readonly
  xdid -t $dname 16 $noqt($txtd(team.txt))

  ;// Initialising control: Thanks (Tab Item 5)
  xdid -a $dname 1 0 0 Thanks $chr(9) 5 panel 0 0 300 200 0 0 300 200

  ;// Initialising control: x (Edit 17)
  xdid -c $dname 5 17 edit 4 5 352 300 autovs tabstop multi vsbar readonly
  xdid -t $dname 17 $noqt($txtd(thanks.txt))
}

;// Callback alias for ircNsetup.about.modern
alias ircNsetup.about.modern_cb {
  if ($2 != mouse) {
    ;echo $color(info) -s */ ircNsetup.about.modern_cb: $1-
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  /SETUP dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on *:dialog:ircn.setup.modern:sclick:2:{
  ; ircn.setup.treeview.close.event 

  _save.general
  _save.logging
  _save.display
  _save.display.hideevents
  _save.network
  ;_save.colors
  _save.titlebarsetup
  _chanset.save
  _save.chandisplay
  _save.usersettings
  _save.nickcomp
  _netauth.save
  _save.messageedit
  _save.transfer
  _save.modulesaves
  _dlgmodules.load
  .timer 1 0 _tmpdlg.hashclose
  .timersaveset 1 5 { ircnsave | nsave }
  dialog -x $dname
}

on *:dialog:ircn.setup.modern:close:0:{
  .timer 1 1 nsave
}
on *:dialog:ircn.setup.modern:sclick:3:{
  .timer 1 0 _tmpdlg.hashclose
  dialog -x $dname
}

alias ircn.setup.treeview.event {
  var %d = $1, %item, %item2, %parent
  ;echo -a X: $1-
  tokenize 32 $2-

  if ($1 == sclick) {
    ;if ($2 == 2) { ircn.setup.treeview.close.event $1- }
    ;if ($2 == 3) { ircn.setup.treeview.close.event $1- }
    if ($2 == 5) {
      if (!$3-) return
      ; echo %d $1-
      if ($5 isnum) set %item2 $xdid(%d,$2,$3-5).text
      if ($4 isnum) set %item $xdid(%d,$2,$3-4).text
      set %parent $xdid(%d,$2,$3).text

      ;  iecho parent: %parent item: %item item2: %item2 .... $1-
      if (!%item) {
        ircn.setup.modern.collapsecertaintree 
        if (%parent == General)  ircnsetup.dockdlg ircnsetup.general
        elseif (%parent == About)   ircnsetup.dockdlg ircNsetup.about.modern
        elseif (%parent == Network)  ircnsetup.dockdlg ircnsetup.network
        elseif (%parent == Channel)  ircnsetup.dockdlg ircnsetup.channel
        elseif (%parent == Display)  {
          var %dontresize = 1
          dialog -s %d  -1 -1 660 380
          ircnsetup.dockdlg ircnsetup.display
        }
        elseif (%parent == Userlist)   ircnsetup.dockdlg ircnsetup.userlist
        elseif (%parent == Banlist)   ircnsetup.dockdlg ircnsetup.banlist
        elseif (%parent == Modules)   ircnsetup.dockdlg ircnsetup.modules.modern
        elseif (%parent == Message Editor) {
          ircnsetup.dockdlg ircnsetup.messageedit.modern
          ;ircnsetup.dockdlg  ircnsetup.notdone
        }
        elseif (%parent == Protection) ircnsetup.dockdlg ircnsetup.blank
        elseif (%parent == Update)   ircnsetup.dockdlg ircnsetup.update.release.modern
      }
      else {
        ircn.setup.modern.collapsecertaintree %parent $+ %item
        if (%parent == General) {
          if (%item == Maintenance) ircnsetup.dockdlg ircn.maintenance
          if (%item == Fkey Bind)   ircnsetup.dockdlg ircnsetup.fkey
          if (%item == Logging) {
            if (!%item2) { xdid -t %d 5 +e $3 $4 | ircnsetup.dockdlg ircnsetup.logs }
            elseif (%item2 == Cleaning) ircnsetup.dockdlg ircnsetup.logclean

          }
          if (%item == Transfer)    ircnsetup.dockdlg ircnsetup.transfer

        }
        elseif (%parent == Network) {
          if (%item == Auto-Connect)      ircnsetup.dockdlg ircn.autoconnect.modern
          if (%item == Authentication)    ircnsetup.dockdlg ircnsetup.netauth
          if (%item == Setting forcing)   ircnsetup.dockdlg ircNsetup.nethshdetect.list
        }
        elseif (%parent == Display) {
          if (%item == Appearance) {
            if (!%item2) {
              xdid -t %d 5 +e $3 $4
              ircnsetup.dockdlg  ircnsetup.appearance
            }
            else {
              if (%item2 == Colors)    ircnsetup.dockdlg ircnsetup.colors
              if (%item2 == Titlebar)    ircnsetup.dockdlg ircn.titlebar.modern
              if (%item2 == Themes)    ircnsetup.dockdlg ircn.nxt.modern
            }
          }
          if (%item == Hide Events)    ircnsetup.dockdlg ircnsetup.display.hideevents
          if (%item == Channel) {
            if (!%item2) {
              var %dontresize = 1
              dialog -s %d  -1 -1 660 380
              xdid -t %d 5 +e $3 $4
              ircnsetup.dockdlg ircn.chandisplay

            }
            else {
              if (%item2 == Nick Complete)    ircnsetup.dockdlg ircnsetup.nickcomp 
            }
          }
        }
        elseif (%parent == Protection) {
          if (%item == channel) {
            if (!%item2) {
              xdid -t %d 5 +e $3 $4
              ircnsetup.dockdlg ircnsetup.blank
            }
            if (%item2 == Badwords) {  ircnsetup.dockdlg ircn.badwords | did -c ircn.badwords 11 }
          }
          if (%item == Personal) {
            if (!%item2) {
              xdid -t %d 5 +e $3 $4
              ircnsetup.dockdlg ircnsetup.blank
            }
            if (%item2 == Badwords) {   ircnsetup.dockdlg ircn.badwords  | did -c ircn.badwords 17 }
            if (%item2 == Paste Protect) ircnsetup.dockdlg ircnsetup.pasteprot
          }
        }
        elseif (%parent == Userlist) {
          if (%item == settings)   ircnsetup.dockdlg   ircnsetup.usersettings
        }
        elseif (%parent == Banlist) {
          ;    if (%item == settings)   ircnsetup.dockdlg   ircnsetup.notdone
        }
        elseif (%parent == Message Editor) {
          if (%item == kicks)   ircnsetup.dockdlg   ircnsetup.editkicks
          if (%item == quits)   ircnsetup.dockdlg   ircnsetup.editquits
          if (%item == Ctcp replies)   ircnsetup.dockdlg   ircn.ctcplist.modern
        }


        elseif (%parent == Modules) {
          if (!%item2) set %item2 %item
          if ((%item) && (%item2)) {
            var %modulehash = $hfind(tempsetup,$tab(%item,*,%item2,*,*),1,w).data
            if (%modulehash) {
              ircnsetup.dockdlg $gettok($hget(tempsetup,%modulehash),2,9)
            }
          }
        }
      }
    }

    if (!%dontresize) && ($dialog(%d).cw != 560) && (!$istok(ircn.chandisplay ircnsetup.display,%ircnsetup.lastdocked,32)) dialog -s %d  -1 -1 560 380

  }
  elseif ($1 == close) {
    ;echo -a x: dcx-close-event
    ircn.setup.treeview.close.event $1-
    .timer 1 0 ircn.setup.treeview.close.event2
  }
}
alias ircn.setup.treeview.close.event {
  ;echo -a CLOSE EVENT

  var %a = 1, %b
  while ($gettok(%ircnsetup.dockednro,1,44) != $null) {
    set %b $ifmatch
    ;echo -a B: %b

    .xdialog -d ircn.setup.modern %b

    ;echo -a .xdialog -d ircn.setup.modern %b

    set %ircnsetup.dockednro $remtok(%ircnsetup.dockednro,%b,1,44)

    ;echo -a dnro: %ircnsetup.dockednro 
    ;inc %a
  }

  .timer 1 0 _tmpdlg.hashclose
}
alias ircn.setup.treeview.close.event2 {
  ;echo -a :close:
  var %a = 1, %b
  while ($gettok(%ircnsetup.docked,%a,44) != $null) {
    set %b $ifmatch
    ;echo -a B: %b
    ;.timer 1 1  if ($ $+ dialog( %b ))  dialog -x %b
    if ($dialog(%b))  dialog -x %b
    inc %a
  }
  ;dialog -x %ircnsetup.lastdocked 

  ;.timer 1 1 if ($ $+ dialog(%ircnsetup.lastdocked)) dialog -x %ircnsetup.lastdocked 
  unset %ircnsetup.docked %ircnsetup.lastdocked %ircnsetup.dockednro %ircnsetup.lastdid

  .timer 1 0 _tmpdlg.hashclose
}
alias ircnsetup.nextdid return $iif(%ircnsetup.dockednro,$calc($gettok(%ircnsetup.dockednro,$numtok(%ircnsetup.dockednro,44),44) + 1),20)
alias ircnsetup.dockdlg {
  var %d
  ;echo -a X1: $1-
  if (%ircnsetup.lastdid != $null) { 
    ;echo -a hiding old dialog
    ;echo xdid -h ircn.setup.modern %ircnsetup.lastdid 
    xdid -h ircn.setup.modern %ircnsetup.lastdid 
  }
  if ($istok(%ircnsetup.docked,$1,44)) { 
    ;echo -a existing dialog
    var %d = $gettok(%ircnsetup.dockednro,$findtok(%ircnsetup.docked,$1,1,44),44)
    xdid -s ircn.setup.modern %d
  }
  else {
    ;echo -a new dialog
    var %d = $ircnsetup.nextdid
    if ($dialog(%ircnsetup.lastdocked)) {
      ;.xdialog -d ircn.setup.modern %d
      ;dialog -x %ircnsetup.lastdocked
    }
    if (!$dialog($1)) dialog -m $1 $1
    else dialog -r $1

    xdialog -c ircn.setup.modern %d dialog 167 2 564 340  $1
  }
  ;echo -a setting lastdid: %d lastdocked: $1
  set %ircnsetup.lastdocked $1
  set %ircnsetup.lastdid %d
  set %ircnsetup.docked $addtok(%ircnsetup.docked,$1,44)
  set %ircnsetup.dockednro $addtok(%ircnsetup.dockednro,%d,44)
}
on *:dialog:ircn.setup.modern:init:0:{
  var %d = ircn.setup.modern
  dcx Mark %d ircn.setup.treeview.event
  _tmpdlg.hashopen

  ircnsetup.dockdlg ircNsetup.about.modern
  did -h $dname 6

  xdialog -c %d 5 treeview  2 4 164 340  hasbuttons linesatroot showsel

  ;set focus to the treeview
  xdid -F $dname 5

  ;change treeview item size to 25
  ; xdid -g %d 5 25

  xdid -a %d 5 $tab(-1, +sb 1 1 0 0 0 0 0 About, About ircN)

  xdid -a %d 5 $tab(-1 , +b 1 1 0 0 0 0 0 General, General Settings)
  xdid -a %d 5 $tab(-1 -1, + 0 0 0 0 0 0 0 Logging, Logging Settings)

  ; log cleaning isnt finished
  xdid -a %d 5 $tab(-1 -1 2, + 1 1 0 0 0 -1 -1 Cleaning, Log Cleanning)
  xdid -a %d 5 $tab(-1 -1, + 1 1 0 0 0 -1 -1 Transfer, DCC Transfer Settings)

  xdid -a %d 5 $tab(-1 -1, + 1 1 0 0 0 -1 -1 Fkey Bind, Bind commands to certain Fkeys)
  xdid -a %d 5 $tab(-1 -1, + 0 0 0 0 0 0 0 Maintenance, Maintenance)
  xdid -a %d 5 $tab(-1, +b 1 1 0 0 0 -1 -1 Network, Network Settings)
  xdid -a %d 5 $tab(-1 -1, + 1 1 0 0 0 -1 -1 Authentication, Authentication)
  xdid -a %d 5 $tab(-1 2, + 1 1 0 0 0 -1 -1 Auto-Connect, Auto-Connect on Start)
  xdid -a %d 5 $tab(-1 2, + 1 1 0 0 0 -1 -1 Setting forcing, Force Settings on same network to be saved to different setting file (ADVANCED ONLY) )
  xdid -a %d 5 $tab(-1, +b 1 1 0 0 0 -1 -1 Channel, Channel Settings)

  xdid -a %d 5 $tab(-1, +b 1 1 0 0 0 -1 -1 Display, Display Settings)
  xdid -a %d 5 $tab(-1 -1, + 1 1 0 0 0 -1 -1 Appearance, Interface Display Options)
  ; xdid -a %d 5 $tab(-1 -1 -1 , + 1 1 0 0 0 -1 -1 Interface, Interface)
  xdid -a %d 5 $tab(-1 -1 -1 , + 1 1 0 0 0 -1 -1 Titlebar, Titlebar Options)
  xdid -a %d 5 $tab(-1 -1 -1, + 1 1 0 0 0 -1 -1 Themes, Theme System)
  ; if ($ismod(statusbar)) xdid -a %d 5 $tab(-1 -1 -1 , + 1 1 0 0 0 -1 -1 Statusbar, Titlebar Options)
  ; if ($ismod(toolbar)) xdid -a %d 5 $tab(-1 -1 -1 , + 1 1 0 0 0 -1 -1 Toolbar, Titlebar Options)
  ; xdid -a %d 5 $tab(-1 -1 -1, + 1 1 0 0 0 -1 -1 Colors, Tooltip)
  xdid -a %d 5 $tab(-1 -1, + 1 1 0 0 0 -1 -1 Channel, Channel Display Options)
  xdid -a %d 5 $tab(-1 -1 -1, + 1 1 0 0 0 -1 -1 Nick Complete, Nickname autocomplete)

  xdid -a %d 5 $tab(-1 -1, + 1 1 0 0 0 -1 -1 Hide Events, Hide displaying of Events)
  ; if (($ismod(channelprot)) || ($ismod(userprot))) {

  xdid -a %d 5 $tab(-1, +b 1 1 0 0 0 -1 -1 Protection, Protection)
  xdid -a %d 5 $tab(-1 2 , + 1 1 0 0 0 -1 -1 Channel, Flood Protection)
  xdid -a %d 5 $tab(-1 2 2, + 1 1 0 0 0 -1 -1 Flood, Botnet Protection) 
  xdid -a %d 5 $tab(-1 2 2, + 1 1 0 0 0 -1 -1 Botnet, Botnet Protection) 
  xdid -a %d 5 $tab(-1 2 2, + 1 1 0 0 0 -1 -1 Badwords, Badwords Protection)
  xdid -a %d 5 $tab(-1 2 2, + 1 1 0 0 0 -1 -1 Spam, Spam Protection)
  xdid -a %d 5 $tab(-1 2, + 1 1 0 0 0 -1 -1 Personal, Flood Protection)
  xdid -a %d 5 $tab(-1 2 2, + 1 1 0 0 0 -1 -1 Flood, Botnet Protection) 
  xdid -a %d 5 $tab(-1 2 2, + 1 1 0 0 0 -1 -1 Botnet, Botnet Protection) 
  xdid -a %d 5 $tab(-1 2 2, + 1 1 0 0 0 -1 -1 Badwords, Badwords Protection)
  xdid -a %d 5 $tab(-1 2 2, + 1 1 0 0 0 -1 -1 Spam, Spam Protection)
  xdid -a %d 5 $tab(-1 2 2, + 1 1 0 0 0 -1 -1 Paste Protect, Prompts you before pasting sensitive information from your clipboard)

  xdid -a %d 5 $tab(-1 2, + 1 1 0 0 0 -1 -1 Settings, Flood Protection)

  ; }

  if ($ismod(userlist)) {
    xdid -a %d 5 $tab(-1, +b 1 1 0 0 0 -1 -1 Userlist, ircN Userlist)
    xdid -a %d 5 $tab(-1 2, + 1 1 0 0 0 -1 -1 Settings, Userlist Settings)

    xdid -a %d 5 $tab(-1, +b 1 1 0 0 0 -1 -1 Banlist, Banlist)
    ;    xdid -a %d 5 $tab(-1 2, + 1 1 0 0 0 -1 -1 Settings, Banlist Settings)
  }
  xdid -a %d 5 $tab(-1, +b 1 1 0 0 0 -1 -1 Message Editor, Message Editor)
  xdid -a %d 5 $tab(-1 2, + 1 1 0 0 0 -1 -1 Quits, Edit Quit Messages)
  xdid -a %d 5 $tab(-1 2, + 1 1 0 0 0 -1 -1 Kicks, Edit Kick Messages)
  xdid -a %d 5 $tab(-1 2, + 1 1 0 0 0 -1 -1 CTCP Replies, Edit CTCP Replies)

  xdid -a %d 5 $tab(-1, +b 1 1 0 0 0 -1 -1 Modules, ircN Modules)

  ircn.setup.modern.addmodules %d


  ; xdid -a %d 5 $tab(-1, +b 1 1 0 0 0 -1 -1 Update, Update System)



  xdid -t %d 5 +a root
  ircn.setup.modern.collapsecertaintree
  ;select 'about'
  xdid -c %d 5 1
}
alias -l ircn.setup.modern.collapsecertaintree {
  var %d = ircn.setup.modern
  if ($1 != displayappearance)  xdid -t %d 5 +c 5 1
  if ($1 != DisplayChannel)  xdid -t %d 5 +c 5 2
  if ($1 != ProtectionChannel)  xdid -t %d 5 +c 6 1
  if ($1 != Protectionpersonal)  xdid -t %d 5 +c 6 2
  if ($1 != GeneralLogging)  xdid -t %d 5 +c 2 1

}
alias ircn.setup.modern.addmodules {

  var %a = 1, %b, %titls, %dlgs, %mod, %saves

  while ($gettok($nvar(modules),%a,44) != $null) {

    set %mod $gettok($nvar(modules),%a,44)
    set %dlgs $modinfo($md(%mod),setupdialog,dialogs)

    if (%dlgs) {
      set %titls $modinfo($md(%mod), setupdialog, titles)
      set %saves $modinfo($md(%mod), setupdialog, saves)

      set %b 1

      while ($gettok(%dlgs,%b,44) != $null) {
        var %dlg = $gettok(%dlgs, %b, 44)
        var %titl = $gettok(%titls, %b, 44)
        var %save = $gettok(%saves, %b, 44)

        if (%b == 1) {
          xdid -a $1 5 $tab(-1 2, + 1 1 0 0 0 -1 -1 $iifelse(%titl, %dlg), Module Settings)    
        }

        else {
          xdid -a $1 5 $tab(-1 2 -1, + 1 1 0 0 0 -1 -1 $iifelse(%titl, %dlg), Module Settings)
        }

        ; dialog $tab(module, modcount, modsdlgcount) $tab(modname, moddlg, title, savecmd, modfile)
        ; ex: ircn.setup.modern $tab(autojoin, 5, 1) $tab(Autojoin, ircN.autojoin.modern, Autojoin, _save.autojoin, 
        tmpdlggset $1 $tab(module, %a, %b) $tab($modinfo($md(%mod), module), %dlg, %titl, %save, %mod)
        inc %b
      }
    }

    inc %a
  }

}

dialog ircN.setup.modern {
  title "ircN Setup [/setup]"
  size -1 -1 560 380
  ;option pixels notheme
  option pixels
  icon $gfxdir(icons\ircn.ico), 0
  button "&OK", 2, 310 348 74 24, default
  button "&Cancel", 3, 388 348 74 24
  button "&Help", 4, 466 348 74 24, disable
  button "&Apply", 6, 231 348 75 25
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sessions / Auto-Connect dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircn.autoconnect.modern {
  title "Load sessions on start"
  size -1 -1 0 0
  option pixels
  ; list 1, 0 2 366 262, size
  button "&Add", 2, 228 268 42 24
  button "&Del", 3, 320 268 42 24
  button "&Edit", 4, 274 268 42 24
  ; button "5", 5, 2 268 30 24
  ; button "6", 6, 34 268 30 24
  button "Load in new window", 7, 88 268 120 24
}
alias ircnsetup.sessions_cb {
  var %d = $1
  if (($2 == stateclick) && ($3 == 1)) {
    var %a 
    var %s = $xdid($1,1,$4,0).state
    var %r = $read($sd(sessions.txt),n,$4)
    set %a $puttok(%r,$iif(%s == 2,0,1),1,32)
    write -l $+ $4 $sd(sessions.txt) %a
  }
  elseif (($2 == dclick) && ($xdid(%d,1).sel) && ($3 == 1))  _sessions.edit %d $xdid(%d,1).sel
  elseif ($2 == sclick) {
    if ($3 == 5) {
      if ($xdid(%d,1).sel) _autoconnect.move.up %d $xdid(%d,1).sel $xdid(%d,1).num
    }
    if ($3 == 6) {
      if ($xdid(%d,1).sel) _autoconnect.move.down %d $xdid(%d,1).sel $xdid(%d,1).num
    }
  }
}
on 1:dialog:ircn.autoconnect.modern:init:0:{
  var %n = $dname
  _sessions.check

  dcx Mark %n ircnsetup.sessions_cb
  xdialog -c %n 1 listview 2 1 365 255  report checkbox fullrow showsel  nolabelwrap tooltip tabstop
  xdid -t %n 1 $tab(+l 0 105 Server/Group, +l 0 237 Flags)

  xdialog -c $dname 5 button 2 268 30 24 tabstop  
  xdialog -c $dname 6 button 34 268 30 24 tabstop  

  xdid -f $dname 5,6 +b symbol 12 Webdings
  xdid -t $dname 5 5 
  xdid -t $dname 6 6 


  _autoconnect.refresh.list ircn.autoconnect.modern

  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 2 0 > NOT_USED $chr(4) Opens a server when ircN starts. If more than one then new server windows will be opened.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 4 0 > NOT_USED $chr(4) Edits the session selected.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 3 0 > NOT_USED $chr(4) Deletes the session selected.
  ;  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 5 0 > NOT_USED $chr(4) Moves the session selected up in the order list.
  ;  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 6 0 > NOT_USED $chr(4) Moves the session selected down in the order list.
}
on 1:dialog:ircn.autoconnect.modern:sclick:7: if ($xdid($dname,1).sel) loadsession $xdid($dname,1).sel
on 1:dialog:ircn.autoconnect.modern:sclick:2:_sessions.add $dname
on 1:dialog:ircn.autoconnect.modern:sclick:4: if ($xdid($dname,1).sel) _sessions.edit $dname $xdid($dname,1).sel
on 1:dialog:ircn.autoconnect.modern:sclick:3:{
  if ($xdid($dname,1).sel) {
    var %t = $xdid($dname,1,1).seltext
    var %a = $input(Are you sure you want to delete your autoconnect session for ' $+ %t $+ ' ?,y,ircN Sessions)
    if (!%a) return
    write -dl $+ $xdid($dname,1).sel $sd(sessions.txt)
    _autoconnect.refresh.list ircn.autoconnect.modern
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ctcp list/edit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircn.ctcplist.modern {
  title "ircN ctcp edit"
  size -1 -1  0 0 
  option dbu
  ;list 1, 1 0 182 132, size
  button "&Delete", 2, 160 134 21 11
  button "&Add/Edit", 4, 126 134 31 11
}
on 1:dialog:ircn.ctcplist.modern:init:0:{
  var %n = $dname
  dcx Mark $dname ircn.ctcplist.modern_cb
  xdialog -c %n 1 listview 2 1 365 250 report fullrow showsel grid nolabelwrap tooltip tabstop
  xdid -t $dname 1 $tab(+l 0 83 CTCP, +r 0 277 Reply)

  _ctcplist.refresh
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 4 0 > NOT_USED $chr(4) Creates a custom CTCP reply.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 3 0 > NOT_USED $chr(4) Edits the CTCP reply selected.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 2 0 > NOT_USED $chr(4) Deletes the CTCP reply selected.
}
alias ircn.ctcplist.modern_cb { 
  if ($2 == dclick) { 
    var %d = ircn.ctcplist.modern
    var %a = $xdid(%d,1).seltext

    if (!%a) return

    ctcpeditdlg %a
  }
}
on 1:dialog:ircn.ctcplist.modern:sclick:4:{

  var %a = $xdid($dname,1).seltext

  ctcpeditdlg %a

}
on 1:dialog:ircn.ctcplist.modern:sclick:2:{
  var %d = ircn.ctcplist.modern
  if (!$xdid(%d,1).sel) { var %a = $input(No CTCP Event selected,wo,ERROR!) | return }
  if ($?!="Are you SURE you want to delete this event and all it's replies?") {
    ;hdel -w ctcpreplys $remove($hfind(ctcpreplys,*.style,$xdid(%d,1).sel,w),.style) $+ .*
    hdel -w ctcpreplys $xdid($dname,1,1).text $+ .*
  }
  _ctcplist.refresh
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Network hashsetting detection / Setting forcing dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircNsetup.nethshdetect.list {
  title "ircN network setting detection"
  ;size -1 -1 378 298
  size -1 -1 1 1
  option pixels
  ;list 1, 2 0 368 264, size
  button "&Delete", 2, 320 268 42 22
  button "&Edit", 3, 274 268 42 22
  button "&Add", 4, 228 268 42 22
}
on *:dialog:ircNsetup.nethshdetect.list:sclick:3:if ($xdid($dname,1).sel) nethshdetect.edit $xdid($dname,1).sel
on *:dialog:ircNsetup.nethshdetect.list:sclick:2:if ($xdid($dname,1).sel) nethshdetect.del $xdid($dname,1).sel
on *:dialog:ircNsetup.nethshdetect.list:sclick:4:nethshdetect.add $xdid($dname,1).num
alias ircnsetup.nethshdetect.list.event {
  var %d = ircNsetup.nethshdetect.list
  ;if (($2 != mouse) && ($2 != denter) && ($2 != dleave) && ($2 != mouseenter) && ($2 != mouseleave) && ($2 != changing)) echo -s $1-
  if ($2 == dclick) {
    if ($3 == 1) {
      if (!$4) return
      var %b = ircNsetup.nethshdetect.add, %c = $calc($4 - 1)
      if (!$dialog(%b)) dlg %b
      did -ra %b 23 %c
      ircNsetup.nethshdetect.upd.fill %c
    }
  }
  if ($2 == sclick) {
    if ($3 == 11) {
      if ((!$xdid(%d,1).sel) || ($xdid(%d,1).sel == 1)) return
      var %c = $calc($xdid(%d,1).sel - 1)
      var %y = $readini($sd(netdetect.ini),$+(n,%c),n0)
      var %x = $readini($sd(netdetect.ini),$+(n,$calc(%c - 1)),n0)
      writeini $sd(netdetect.ini) $+(n,%c) n0 %x
      writeini $sd(netdetect.ini) $+(n,$calc(%c - 1)) n0 %y
      _nethshdetect.refreshlist
      xdid -c %d 1 %c
    }
    if ($3 == 12) {
      if ((!$xdid(%d,1).sel) || ($xdid(%d,1).sel == $xdid(%d,1).num)) return
      var %c = $calc($xdid(%d,1).sel - 1)
      var %y = $readini($sd(netdetect.ini),$+(n,%c),n0)
      var %x = $readini($sd(netdetect.ini),$+(n,$calc(%c + 1)),n0)
      writeini $sd(netdetect.ini) $+(n,%c) n0 %x
      writeini $sd(netdetect.ini) $+(n,$calc(%c + 1)) n0 %y
      _nethshdetect.refreshlist
      xdid -c %d 1 $calc(%c + 2)
    }
  }
  return
}
on *:dialog:ircNsetup.nethshdetect.list:init:0:{
  var %d = $dname
  dcx Mark %d ircnsetup.nethshdetect.list.event
  xdialog -c %d 11 button 1 268 22 22
  xdialog -c %d 12 button 23 268 22 22
  xdid -t %d 11 5
  xdid -t %d 12 6
  xdid -f %d 11 + symbol 10 Webdings
  xdid -f %d 12 + symbol 10 Webdings
  xdialog -c %d 1 listview 1 1 368 264 report fullrow showsel editlabel singlesel
  xdid -t %d 1 +l 0 90 Network $chr(9) +l 0 90 Server $chr(9) +l 0 100 Server IP $chr(9) +l 0 70 Port $chr(9) +l 0 70 Nick $chr(9) +l 0 90 ANick $chr(9) +l 0 70 e-mail $chr(9) +l 0 100 Realname $chr(9) +l 0 100 Settings
  _nethshdetect.refreshlist
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Userlist dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircNsetup.userlist {
  title "ircN Userlist"
  size -1 -1 0 0 
  option dbu
  ; list 1, 1 0 184 132, size
  button "Delete", 2, 160 134 21 11
  button "Edit", 3, 137 134 21 11
  button "Create", 4, 114 134 21 11
}
on 1:dialog:ircnsetup.userlist:sclick:4:adduserdlg
on 1:dialog:ircnsetup.userlist:init:0:{

  var %n = $dname
  dcx Mark $dname ircnsetup.userlist_cb
  xdialog -c %n 1 listview 2 1 365 255 report fullrow showsel  nolabelwrap tooltip tabstop
  xdid -t $dname 1 $tab(+l 0 82 User, +l 0 89 Host, +l 0 91 Global Flags, +l 0 80 Chan Flags)

  _userlistdlg.refresh
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 4 0 > NOT_USED $chr(4) Creates a user in ircN's userlist.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 3 0 > NOT_USED $chr(4) Edits the user selected.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 2 0 > NOT_USED $chr(4) Deletes the user selected.
}
alias ircnsetup.userlist_cb {
  if ($2 == dclick) { 
    var %a =  $xdid($1,1,1).seltext
    if (%a)  edituserdlg %a
  }
}
on 1:dialog:ircnsetup.userlist:sclick:3:{
  var %a = $xdid($dname,1,1).seltext
  if (!%a) { var %a = $input(No user selected! $crlf $+ Please select a user from the userlist!,ow,No user selected!) | return }
  edituserdlg %a
}
on 1:dialog:ircnsetup.userlist:sclick:4:adduserdlg
on 1:dialog:ircnsetup.userlist:sclick:2:{
  var %a =  $xdid($dname,1,$xdid($dname,1).sel,0).text
  if ($input(Are you sure you want to delete user: %a)) {
    remuser %a
    xdid -d $dname 1 $xdid($dname,1).sel
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Banlist dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircNsetup.banlist {
  title "ircN Ban list"
  size -1 -1 0 0 
  option dbu
  ; list 1, 1 0 184 132, size
  button "Delete", 2, 160 134 21 11
  button "Edit", 3, 137 134 21 11
  button "Create", 4, 114 134 21 11
}
on 1:dialog:ircnsetup.banlist:sclick:3:{
  var %a = $xdid(ircnsetup.banlist,1).seltext
  if (!%a) return
  editbandlg %a
}
on 1:dialog:ircnsetup.banlist:sclick:4:addbandlg
on 1:dialog:ircnsetup.banlist:sclick:2:{
  var %a = $xdid(ircnsetup.banlist,1).seltext
  if (!%a) return
  var %b = $input(Are you sure you want to remove ban of: %a,y)
  if (%b) {
    remban %a
    _banlist.refresh
  }
}

alias ircnsetup.banlist_cb {
  if (($2 == dclick) && ($3 == 1))  { 
    var %a = $xdid(ircnsetup.banlist,1).seltext
    if (!%a) return
    editbandlg %a
  }
}
on 1:dialog:ircnsetup.banlist:init:0:{
  var %n = $dname
  dcx Mark $dname ircnsetup.banlist_cb
  xdialog -c %n 1 listview 2 1 365 255 report fullrow showsel nolabelwrap tooltip tabstop
  xdid -t $dname 1 $tab(+l 0 139 Hostmask, +l 0 56 Set By, +l 0 48 Flags, +l 0 80 Channels,  +l 0 80 Created,  +l 0 80 Last Used, +l 0 155 Reason)
  _banlist.refresh
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 4 0 > NOT_USED $chr(4) $lang.tooltip($dname,4,Creates a ban in ircN.)
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 3 0 > NOT_USED $chr(4) $lang.tooltip($dname,3,Edits the selected ban.)
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 2 0 > NOT_USED $chr(4) $lang.tooltip($dname,2,Deletes the selected ban.)
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Titlebar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircn.titlebar.modern {
  title "Titlebar Setup"
  size -1 -1 0 0 
  option pixels
  list 1, 31 52 126 174, size
  text "Titlebar", 2, 45 30 98 18, center

  list 7, 205 52 126 174, size
  text "Unused", 8, 219 30 98 18, center
  check "ircN Titlebar Enabled", 9, 11 2 140 22
}
alias ircn.titlebar.modern_cb {
  var %d = $1
  if ($2 == sclick) {
    if ($3 == 3) {
      if ($did(%d,7).sel) {
        did -a %d 1 $did(%d,7).seltext
        did -d %d 7 $did(%d,7).sel
      }
    }
    elseif ($3 == 4) {
      if ($did(%d,1).sel) {
        did -a %d 7 $did(%d,1).seltext
        did -d %d 1 $did(%d,1).sel
      }
    }
    elseif ($3 == 5) {
      if ($did(%d,1).sel > 1) {
        var %a = $did(%d,1).seltext
        var %b = $did(%d,1,$calc($did(%d,1).sel - 1)).text
        var %c = $did(%d,1).sel
        did -o %d 1 $calc(%c - 1) %a
        did -o %d 1 %c %b
        did -c %d 1 $calc(%c - 1)
      }
    }
    elseif ($3 == 6) {
      if (($did(%d,1).sel) && ($did(%d,1).sel < $did(%d,1).lines)) {
        var %a = $did(%d,1).seltext
        var %b = $did(%d,1,$calc($did(%d,1).sel + 1)).text
        var %c = $did(%d,1).sel
        did -o %d 1 $calc(%c + 1) %a
        did -o %d 1 %c %b
        did -c %d 1 $calc(%c + 1)
      }
    }
  }
}
on 1:dialog:ircn.titlebar.modern:init:0:{
  var %n = $dname

  dcx Mark $dname ircn.titlebar.modern_cb

  xdialog -T $dname +p

  xdialog -c $dname 3 button 162 62 40 28 tooltips
  xdialog -c $dname 4 button 162 96 40 28 tabstop tooltips
  xdialog -c $dname 5 button 162 164 40 28 tabstop tooltips
  xdialog -c $dname 6 button 162 198 40 28 tabstop tooltips

  xdid -f $dname 3,4,5,6 +b symbol 12 Webdings
  xdid -t $dname 3 3
  xdid -t $dname 4 4
  xdid -t $dname 5 5
  xdid -t $dname 6 6

  if ($nvar(titlebar) == on) did -c $dname 9 
  _titlebar.updatemodes
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FKey dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias fkeysettings.modern {
  if ($istok(%ircnsetup.docked,ircnsetup.fkey,44)) return
  dlg -r ircnsetup.fkey
  dialog -rsb ircnsetup.fkey -1 -1 184 146
}
dialog ircnsetup.fkey {
  title "Fkeys"
  size -1 -1 0 0
  option pixels
}
alias ircnsetup.fkey_cb {
  if (($2 == dclick) && ($3 == 1)) {
    var %a = $xdid($1,1,1).seltext
    var %cmd = $input(Enter the fkey command for %a,eo,FKey Edit,$nvar(fkey. $+ %a))

    _fkey.addperm %a %cmd

    if (%a == F11) {
      $iif(%cmd == fullscreen,.disable, .enable) #ircN_F11Key  
    }

    _fkey.refresh
  }
}
on 1:dialog:ircnsetup.fkey:init:0:{
  var %n = $dname

  dcx Mark $dname ircnsetup.fkey_cb
  xdialog -c %n 1 listview 2 1 365 290 report fullrow showsel  nolabelwrap tooltip tabstop
  xdid -t $dname 1 $tab(+l 0 65 Fkey, +l 0 273 Command)

  _fkey.refresh
}
alias -l _fkey.refresh {
  var %n = ircnsetup.fkey
  xdid -r %n 1
  var %a, %b = 1, %c
  while (%b <= 3) {
    set %a 1
    while (%a <= 12) {
      set %c $iif(%b == 2,c,$iif(%b == 3,s)) $+ F $+ %a

      xdid -a %n 1 0 0 $tab(+ 0 0 0 0 0 0 %c, + 0 0 0 0 $nvar(fkey. $+ %c))
      inc %a
    }
    inc %b
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Message Edit dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;message editor stuff
dialog ircnsetup.messageedit.modern {
  title "messageedit"
  size -1 -1 556 442
  option pixels
  button "&OK", 100, 232 299 60 28, hide ok
  button "&Cancel", 101, 294 299 60 28, hide cancel
  text "Editing:", 2, 172 5 57 20, right
  combo 3, 238 4 118 191, size drop
}
on *:DIALOG:ircnsetup.messageedit.modern:sclick:3:_refresh.messageedit $iif(- !isin $did(3),$did(3))

on 1:dialog:ircnsetup.messageedit.modern:init:0:{
  var %n = $dname
  _tmpdlg.hashopen

  dcx Mark %n ircnsetup.messageedit.modern_cb
  xdialog -c %n 1 listview 2 36 365 280 report showsel fullrow  nolabelwrap tooltip tabstop
  xdid -t %n 1 $tab(+l 0 69 item, +l 0 264 string)

  did -a %n 3 -All-
  did -a %n 3 $str(-,50)
  did -a %n 3 Channel Messages
  did -a %n 3 Kicks
  did -a %n 3 Userlist
  did -a %n 3 Warnings
  did -c %n 3 1
  _refresh.messageedit
  ;  .timermodules.refresh -o 0 5 _refresh.modules.check
}
alias _refresh.messageedit {
  var %d = ircnsetup.messageedit.modern
  xdid -r %d 1
  if (!$1) {
  }

  if ($1 == channel) || (!$1) {
    xdid -a %d 1 0 0 $tab(+ 0 1 0 0 0 0 default part, + 0 0 0 0 $nvar(string_partmsg))
    xdid -a %d 1 0 0 $tab(+ 0 1 0 0 0 0 wallop, + 0 0 0 0 WallOP)
    xdid -a %d 1 0 0 $tab(+ 0 1 0 0 0 0 voicemsg, + 0 0 0 0 voice)
    xdid -a %d 1 0 0 $tab(+ 0 1 0 0 0 0 nonopmsg, + 0 0 0 0 nonops)
  }
  if ($1 == kicks) || (!$1) {
    xdid -a %d 1 0 0 $tab(+ 0 1 0 0 0 0 kick on ban, + 0 0 0 0 <nick> set ban of <banmask>)
    xdid -a %d 1 0 0 $tab(+ 0 1 0 0 0 0 kick on invite, + 0 0 0 0 invites are lame)
    xdid -a %d 1 0 0 $tab(+ 0 1 0 0 0 0 default autokick, + 0 0 0 0 and dont come back...)
    xdid -a %d 1 0 0 $tab(+ 0 1 0 0 0 0 kick on banning you, + 0 0 0 0 dont ban me!)
    xdid -a %d 1 0 0 $tab(+ 0 1 0 0 0 0 mass kick, + 0 0 0 0 mass kick)
    xdid -a %d 1 0 0 $tab(+ 0 1 0 0 0 0 idle kick, + 0 0 0 0 idle for more than <text>)

  }
}


alias ircnsetup.messageedit.modern_cb {
  if ($2 == dclick) {
    var %d = $1
    var %a = $xdid(%d,1,1).seltext
    var %b = $xdid(%d,1,2).seltext
    var %c = $input(Edit ' %a $+ ' message ,e,test,%b)

    if (%a == default part) nvar string_partmsg %c
    if (%a == voicemsg) nvar string_voicemsg %c
    if (%a == nonopmsg) nvar string_nonopmsg %c
    if (%a == kick on banning you) nvar string_onselfban %c

  }
}
alias _save.messageedit {
  var %n = ircNsetup.messageedit
  if (!$dialog(%n)) return

}
on 1:dialog:ircNsetup.messageedit:sclick:3:_save.messageedit
alias msgeditor {
  dlg -r ircNsetup.messageedit
  dialog -rsb ircNsetup.messageedit -1 -1 184 146
  did -v ircNsetup.messageedit 2,3
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Update Dialogs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dialog ircnsetup.update.release.modern {
  title "Update Release"
  size -1 -1 58 0
  option dbu
  button "&OK", 100, 123 228 30 14, hide ok
  button "&Cancel", 101, 154 228 30 14, hide cancel
  button "Upgrade", 2, 145 145 38 16, disable
  text "", 3, 8 146 130 25, center
}
on *:DIALOG:ircnsetup.update.release.modern:sclick:2:{
  if ((!$ismod(http.mod)) || (!$ismod(update.mod)))  {
    var %q = $input(ircN must load the 'update' module $+ $chr(44)  and the 'httpd library' module to upgrade. Load them now?,y)
    if (%q)      module update
    else return
  }

  if (($isfile($tp(updates/ircNinstaller.exe))) && ($md5($tp(updates/ircNinstaller.exe),2) == $nvar(update.newver.md5))) {
    if ($input(ircN needs to be restarted in order to be upgraded. Is this ok?,y))  iecho upgrade
  }

  else iecho update -release

}

on 1:dialog:ircnsetup.update.release.modern:init:0:{
  var %n = $dname
  _tmpdlg.hashopen

  dcx Mark %n ircnsetup.update.release.modern_cb
  xdialog -c %n 1 listview 2 1 365 280 report checkbox fullrow showsel  nolabelwrap tooltip tabstop

  xdid -w %n 1 +n 0 $shortfn($icondir(ircn.ico))
  xdid -t %n 1 $tab(+l 0 110 release date, +l 0 134 file, +l 0 53 version,+ 0 143 author)

  if ($nvar(update.newver.date)) {
    xdid -a %n 1 0 0 $tab(+ 1 1 0 0 0 0 $nvar(update.newver.date), + 0 0 0 $nvar(update.newver.file), + 0 0 0 $nvar(update.newver.ver), + 0 0 0 ircN Development Team)
    did -ra %n 3 A new release of ircN is available. Please check the release you wish to upgrade to and hit the update button.
  }

  else { 
    if ((!$ismod(http.mod)) || (!$ismod(update.mod)))  {
      var %q = $input(ircN must load the 'update' module $+ $chr(44)  and the 'httpd library' module to display updates. Load them now?,y)
      if (%q)      module update
      else return
    }

    .update


  }
}
alias ircnsetup.update.release.modern_cb {
  if ($2 == stateclick) {
    var %f = $xdid($1,1,$4,1).text
    var %s = $xdid($1,1,$4,0).state
    did $iif(%s == 1,-e,-b) $1 2
  }
}
dialog ircnsetup.snoticeredirect.modern {
  title "sNotice Redirect"
  size -1 -1 190 150
  option dbu
  ; list 1, 1 1 183 140, size
  button "&OK", 100, 122 144 30 14, hide ok
  button "&Cancel", 101, 153 144 30 14, hide cancel

}
on 1:dialog:ircnsetup.snoticeredirect.modern:init:0:{
  var %n = $dname
  _tmpdlg.hashopen

  dcx Mark %n ircnsetup.snoticeredirect.modern_cb
  xdialog -c %n 1 listview 2 1 365 280 report checkbox fullrow showsel  nolabelwrap tooltip tabstop
  xdid -t %n 1 $tab(+l 0 208 String, +l 0 137 Output Window)

}

alias ircnsetup.snoticeredirect.modern_cb noop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Modules dialog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias modulesdlg.modern {
  if ($istok(%ircnsetup.docked,ircnsetup.modules.modern,44)) return
  dlg -r ircnsetup.modules.modern
  dialog -rsb ircnsetup.modules.modern -1 -1 184 162
  did -v ircnsetup.modules.modern 100,101
}
dialog ircnsetup.modules.modern {
  title "Modules"
  size -1 -1 0 0
  option dbu
  ; list 1, 1 1 183 140, size
  button "&OK", 100, 122 144 30 14, hide ok
  button "&Cancel", 101, 153 144 30 14, hide cancel
  link "Get more modules", 2, 4 148 43 8
}

on *:dialog:ircnsetup.modules.modern:close:0:{
  _tmpdlgdel.hash $dname
  unset %modulesdlg.numofmods
}
on 1:dialog:ircnsetup.modules.modern:sclick:100:_dlgmodules.load
on 1:dialog:ircnsetup.modules.modern:sclick:2: url http://www.ircN.org/
alias ircnsetup.modules.modern_cb {
  if (($2 == stateclick) && ($3 == 1)) {
    var %f = $nopath($xdid($1,1,$4,2).text)
    var %s = $xdid($1,1,$4,0).state
    if (%s == 2)  _dlg.unloadmodule $1 %f
    else _dlg.loadmodule $1 %f
  }
  elseif (($2 == dclick) && ($3 == 1)) {
    var %f = $xdid($1,1,$4,1).text
    var %s = $xdid($1,1,$4,0).state
    if (%s == 2) { 
      _dlg.unloadmodule $1 %f
      xdid -k $1 1 1 $4
    }
    else { 
      _dlg.loadmodule $1 %f
      xdid -k $1 1 2 $4
    }
  }
}
on 1:dialog:ircnsetup.modules.modern:init:0:{
  var %n = $dname
  _tmpdlg.hashopen

  dcx Mark %n ircnsetup.modules.modern_cb
  xdialog -c %n 1 listview 2 1 365 280 report checkbox fullrow showsel  nolabelwrap tooltip tabstop
  xdid -t %n 1 $tab(+l 0 138 module, +l 0 67 file, +l 0 61 version,+ 0 78 author)

  _refresh.modules
  .timermodules.refresh -o 0 5 _refresh.modules.check
}
alias _refresh.modules.check {
  if (!$dialog(ircnsetup.modules.modern)) { .timermodules.refresh off | unset %modulesdlg.numofmods  | return }
  var %a = $findfile($md,*.mod,0)
  if ((%a < %modulesdlg.numofmods)  || (%a > %modulesdlg.numofmods)) _refresh.modules

  set %modulesdlg.numofmods %a
}

alias _dlgmodules.load {
  var %a = 1
  var %d = ircnsetup.modules.modern
  while ($gettok($tmpdlggget(%d,unloadmod),%a,44)) {
    var %b = $ifmatch
    if (%b != modernui.mod) unmod $ifmatch
    else {
      .timer 1 3 unmod modernui.mod 
    }
    inc %a
  }
  set %a 1
  while ($gettok($tmpdlggget(%d,loadmod),%a,44)) {
    module $ifmatch
    inc %a
  }
  _tmpdlgdel.hash ircnsetup.modules.modern
}
alias _dlg.loadmodule {
  if ($istok($tmpdlggget($1,unloadmod),$2-,44)) tmpdlggset $1 unloadmod $remtok($tmpdlggget($1,unloadmod),$2-,44)
  tmpdlggset $1 loadmod $addtok($tmpdlggget($1,loadmod),$2-,44)
}
alias _dlg.unloadmodule {
  if ($istok($tmpdlggget($1,loadmod),$2-,44)) tmpdlggset $1 loadmod $remtok($tmpdlggget($1,loadmod),$2-,44)
  tmpdlggset $1 unloadmod $addtok($tmpdlggget($1,unloadmod),$2-,44)
}
alias _refresh.modules {
  var %d = ircnsetup.modules.modern
  var %a = 1, %b, %c
  xdid -r %d 1
  while (%a <= $findfile($md,*.mod,0)) {
    set %b $findfile($md,*.mod,%a)
    xdid -a %d 1 0 0 $tab(+ 0 $iif($istok($nvar(modules),$nopath(%b),44),2,1) 0 0 0 0 $iifelse($modinfo(%b,module),$deltok($nopath(%b),-1,46)), + 0 0 0 0 $remove(%b,$md), + 0 0 0 0 $modinfo(%b,version), + 0 0 0 0 $modinfo(%b,author))
    inc %a
  }
  ;sort
  xdid -z %d 1 +a 1
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TOOLTIPS FOR DIALOGS IN CLASSIC UI MODULE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 1:dialog:ircn.adduser:init:0:{
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 95 0 > NOT_USED $chr(4) Hostmasks the user will be recognized by.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 96 0 > NOT_USED $chr(4) Adds the hostmask to the user.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 97 0 > NOT_USED $chr(4) Removes the selected hostmask.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 99 0 > NOT_USED $chr(4) Password for user identification.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 100 0 > NOT_USED $chr(4) Saves the user's password.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 102 0 > NOT_USED $chr(4) Password for user identification to a bot/ircN user.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 103 0 > NOT_USED $chr(4) Saves the bot/ircN user password.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 104 0 > NOT_USED $chr(4) Sets the infoline to every channel you are on.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 105 0 > NOT_USED $chr(4) Sets the infoline to the channels listed below.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 107 0 > NOT_USED $chr(4) The list of channels the infoline is on.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 108 0 > NOT_USED $chr(4) Adds the channel to the channels that the infoline will be messaged on.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 109 0 > NOT_USED $chr(4) Removes the selected channel from the list of infoline channels.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 111 0 > NOT_USED $chr(4) Infoline displayed when the user joins a channel.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 112 0 > NOT_USED $chr(4) Saves the infoline.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 76 0 > NOT_USED $chr(4) Automatically ops the user on every channel.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 77 0 > NOT_USED $chr(4) Recognizes the user as a eggdrop bot in every channel.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 78 0 > NOT_USED $chr(4) Automatically accepts DCC Chats.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 79 0 > NOT_USED $chr(4) Automatically deops the user on every channel.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 80 0 > NOT_USED $chr(4) Protects the user from being banned in every channel.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 81 0 > NOT_USED $chr(4) Requests ops from the user. A bot password and +b (eggdrop), +x (BitchX bot), or +i (ircN user) must also be set on the user.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 82 0 > NOT_USED $chr(4) Recognizes the user as another ircN user. For use with +g.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 83 0 > NOT_USED $chr(4) Not implemented yet.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 84 0 > NOT_USED $chr(4) Automatically kicks the user on every channel.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 85 0 > NOT_USED $chr(4) Recognizes the user as a global master.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 86 0 > NOT_USED $chr(4) Recognizes the user as the owner.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 87 0 > NOT_USED $chr(4) Recognizes the user as a global op.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 88 0 > NOT_USED $chr(4) Allows the user access to the partyline.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 89 0 > NOT_USED $chr(4) Allows the user remote control access.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 90 0 > NOT_USED $chr(4) Automatically accepts DCC sends.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 91 0 > NOT_USED $chr(4) Automatically voices the user on every channel.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 92 0 > NOT_USED $chr(4) Recognizes the user as a BitchX bot. For use with +g.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 74 0 > NOT_USED $chr(4) Automatically ops the user on the selected channel.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 58 0 > NOT_USED $chr(4) Automatically deops the user on the selected channel.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 59 0 > NOT_USED $chr(4) Protects the user from being banned on the selected channel.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 60 0 > NOT_USED $chr(4) Automatically gets ops from the user on the selected channel. A bot password and +b (eggdrop), +x (BitchX bot), or +i (ircN user) must also be set on the user.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 63 0 > NOT_USED $chr(4) Automatically kicks the user on the selected channel.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 66 0 > NOT_USED $chr(4) Recognizes the user as an op on the selected channel.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 70 0 > NOT_USED $chr(4) Automatically voices the user on the selected channel.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 73 0 > NOT_USED $chr(4) Allows you to set any usable flags in a selected channel.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 114 0 > NOT_USED $chr(4) Deletes the user from ircN's userlist.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 54 0 > NOT_USED $chr(4) Before you can change channel flags, you must add the channel to the users channel-list.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 55 0 > NOT_USED $chr(4) Remove a channel from users channel-list, affects channel flags and infolines.
}
on 1:dialog:ircNsetup.channel:init:0:{
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 1 0 > NOT_USED $chr(4) Leaves and rejoins an empty channel to get ops.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 2 0 > NOT_USED $chr(4) Kicks a channel user when they are banned.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 3 0 > NOT_USED $chr(4) Sets the following modes when you join a channel and have ops.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 11 0 > NOT_USED $chr(4) Resets the following modes if they get unset.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 5 0 > NOT_USED $chr(4) Keeps track of how many kicks you do. You can append the count onto your custom kick messages.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 6 0 > NOT_USED $chr(4) Voices all users that join a channel in which you are opped.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 10 0 > NOT_USED $chr(4) Auto sets the topic you specify when you join a channel and have ops.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 13 0 > NOT_USED $chr(4) Keeps the current topic set.
}
on 1:dialog:ircnsetup.general:init:0:{
  mtooltips SetTooltipWidth 500
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 18 0 > NOT_USED $chr(4) How much you need to be lagging for ircN to echo the lag amount to your status window. $+ $crlf $+ Default: 5
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 15 0 > NOT_USED $chr(4) If you flood off when you join a large channel, reduce this number. $+ $crlf $+ IAL = Internal Address List $+ $crlf $+ When the number of people in the channel exceeds this amount, IAL wont be updated. $+ $crlf $+ Default: 300
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 2 0 > NOT_USED $chr(4) Save ircN Settings every "X" minutes.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 8 0 > NOT_USED $chr(4) Displays ircN logo on start.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 7 0 > NOT_USED $chr(4) Only shows the active session's windows and hides the others in the switchbar 
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 12 0 > NOT_USED $chr(4) Closes idle queries after X amount of time (Placeholder. Not working yet)
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 4 0 > NOT_USED $chr(4) Copies the resolved IP address to your clipboard when you use /dns.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 5 0 > NOT_USED $chr(4) Checks your lag on each server and echoes if your connection is lagged.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 9 0 > NOT_USED $chr(4) Closes a user's message window when they quit IRC.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 10 0 > NOT_USED $chr(4) Performs /whowas when there is no such user online.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 11 0 > NOT_USED $chr(4) Check for updates on startup.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 6 0 > NOT_USED $chr(4) Opens the default hostmask ban list dialog.
}
on 1:dialog:ircNsetup.usersettings:init:0:{
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 11 0 > NOT_USED $chr(4) Automatically requests ops from bots in your userlist with the +g flag.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 12 0 > NOT_USED $chr(4) Automatically ops bots on your userlist.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 13 0 > NOT_USED $chr(4) ReOps a bot on your userlist that has been deOped.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 14 0 > NOT_USED $chr(4) Voices a bot on your userlist that has been deOped.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 15 0 > NOT_USED $chr(4) Automatically sends the bot password when you DCC Chat a bot on your userlist.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 31 0 > NOT_USED $chr(4) Prevents removal of bans set by other users.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 41 0 > NOT_USED $chr(4) Info-line messages specifications in /userlist when users on your list join a common channel.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 51 0 > NOT_USED $chr(4) Removes ops from users who are not opped in your userlist.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 54 0 > NOT_USED $chr(4) Kicks those who try to deop people who have ops on your userlist.
}
on 1:dialog:ircNsetup.messageedit:init:0:mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 4 0 > NOT_USED $chr(4) Hides mIRC's CTCP version reply.
on 1:dialog:ircn.ctcpedit:init:0:{
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 13 0 > NOT_USED $chr(4) Adds a CTCP event to reply to.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 18 0 > NOT_USED $chr(4) Deletes a whole CTCP event from settings along with it's reply list.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 10 0 > NOT_USED $chr(4) Adds the reply to the selected CTCP event.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 14 0 > NOT_USED $chr(4) Replaces the selected line on the list with the line on the left.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 15 0 > NOT_USED $chr(4) Deletes the selected line from the list.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 9 0 > NOT_USED $chr(4) Ignores the CTCP event completely, doesn't echo when someone CTCPs you with the event.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 5 0 > NOT_USED $chr(4) Uses a randomly picked reply.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 4 0 > NOT_USED $chr(4) This message is used for the custom reply.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 3 0 > NOT_USED $chr(4) Replies with the message on the right.
}
on 1:dialog:ircn.addedban_*:init:0:{
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 2 0 > NOT_USED $chr(4) Hostmask to ban. Format: *!*user@host
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 4 0 > NOT_USED $chr(4) List of channels the ban will be enforced on.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 11 0 > NOT_USED $chr(4) Adds the channel to the channels the ban will be enforced on.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 12 0 > NOT_USED $chr(4) Removes the channel the ban will be enforced on.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 6 0 > NOT_USED $chr(4) This is the kick message when the user is kicked.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 9 0 > NOT_USED $chr(4) Keeps the ban enforced. If the host is unbanned it will be rebanned.
}
on *:dialog:ircNsetup.nethshdetect.add:init:0:{
  mtooltips SetTooltipWidth 500
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 7 0 > NOT_USED $chr(4) Network marked for the server you are connecting to. $+ $crlf $+ Not that accurate, think twice before using.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 8 0 > NOT_USED $chr(4) Main nick used when connecting to server.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 9 0 > NOT_USED $chr(4) Alternative nick used when connecting to server.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 10 0 > NOT_USED $chr(4) email used when connecting to server. $+ $crlf $+ It can be good to use ident@network style, if you have no other means of detecting which setting to use.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 11 0 > NOT_USED $chr(4) Real name/Fullname used when connecting to server.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 13 0 > NOT_USED $chr(4) The hash to use for the network. $ctrl $+ Syntax: <Network_name> <number> $+ $crlf $+ ie. "EFnet 3" will load settings from EFnet.set3, and "EFnet 0" will load EFnet.set.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 18 0 > NOT_USED $chr(4) The Server IP used for connecting, $+ $crlf $+ Always the IP you connect to, even if you connect to a bouncer.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 19 0 > NOT_USED $chr(4) The Server address, not accurate, $+ $crlf $+ With some bouncers this is the server the bouncer is connected to, with some it's the bouncers name.
  mtooltips SpawnTooltip +d0 $dialog($dname).hwnd 17 0 > NOT_USED $chr(4) The port used when you are connecting. $+ $crlf $+ Use +7000 when connecting to an SSL server on port 7000.
}
on *:UNLOAD:{
  unset %ircnsetup.*
  if ($timer(modules.refresh)) .timermodules.refresh off
  _classicui.closeallsetupdialogs
  .timer 1 1 if ($ $+ dialog(ircn.setup.modern)) dialog -x ircn.setup.modern 
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; START OF mTooltip UnLoad (MUST REMAIN AT THE VERY END OF THE FILE ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 1:dialog:*:close:0:{
  ;this unloads the mTooltips.dll so it will not: ERR TOO_MANY_TOOLTIPS
  if ($lock(dll)) return
  if (!$isfile($dd(mTooltips.dll))) return
  if ($dll(mToolTips.dll)) {
    if ($dialog(0) <= 1) .timer -iom 1 1000 dll -u $dd(mTooltips.dll)
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; END OF   mTooltip UnLoad (MUST REMAIN AT THE VERY END OF THE FILE ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
