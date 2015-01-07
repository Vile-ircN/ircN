dlg {
  var %a,%b
  if (-* iswm $1) { set %b $1 | set %a $2- }
  else set %a $1-

  if ($dialog($gettok(%a,1,32))) dialog -v %a
  else dialog -m $+ $remove(%b,-) $gettok(%a,1,32) $iif($gettok(%a,2,32),$gettok(%a,2,32),$gettok(%a,1,32))
}
listspace {
  var %wx = $width($2-,MS Shell Dlg,-8)
  var %w = $calc($dbuw * $1), %ws = $width($chr(160),MS Shell Dlg,-8), %z = $ceil($calc($calc(%w - %wx) / %ws))
  return $2- $str($chr(160),%z)
}
listvfrmt {
  var %y, %z, %l, %x = $numtok($1,9), %n = %x, %c, %a, %prop = $prop
  var %ws = $width($chr(160),MS Shell Dlg,-8)
  if (%prop == line) {
    while (%x > 0) {
      %z = $gettok($gettok($1,%x,9),2-,32)
      %y = $gettok($gettok($1,%x,9),1,32)
      if (f isin %y) { %c = 1 | %y = $remove(%y,f) }
      else %c = 0
      if (r isin %y) { %a = r | %y = $remove(%y,r) }
      elseif (c isin %y) {
        %a = c
        %y = $remove(%y,c)
      }
      else { %a = l | %y = $remove(%y,l) }
      %y = $calc($dbuw * %y)
      %a = $width($+(%z,$chr(32)),MS Shell Dlg,-8)
      %c = $calc($calc(%y - %a) / %ws - $width($chr(32),MS Shell Dlg,-8))

      if ($abs($calc(%y - $floor($calc(%a + %c)))) < $abs($calc(%y - $ceil($calc(%a + %c))))) %c = $floor(%c)
      else %c = $ceil(%c)

      if ($calc(%y - %a) >= %ws) %z = %z $str($chr(160),%c)
      %l = %z %l
      dec %x
    }
    return %l
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ASCII dialog (treeview/listview)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
atreev {
  var %d = $1, %did = $2, %l = $3, %s, %prop = $prop

  if ($isid) {
    if ($0 == 4) %s = $4
    elseif ($0 >= 4) {
      var %i = 4
      while (%i <= $0) {
        %s = $instok(%s,[ [ $+($,%i) ] ],$calc($numtok(%s,44) + 1),44)
        inc %i
      }
    }

    ;;;;;; SELPATH NOT YET WORKING WITH LARGER PATHS!
    if (%prop == selpath) {
      var %x = $did(%d,%did).sel, %i = %x
      while (%i) { 
        if ($gettok($did(%d,%did,%i).text,1,32) != $nvar(atree.branch)) { return %i $iif($calc(%x - %i) > 0,$ifmatch) }
        dec %i 
      }
      return %i
    }

    if (%prop == tok) {
      var %i = 1, %x = $did(%d,%did,%l).text, %b = $numtok(%x,32)
      while (%i <= %b) {
        if ($gettok(%x,%i,32) != $nvar(atree.branch)) return %i
        inc %i
      }

    }

    ;;;;; returns the real line of a treepath item ( $atreev(<dialog>,<id>,1,2,3) would return the line number for the third branch of the second branch of the first item )
    if (%prop == trueline) {
      var %x = 0, %i = 1, %lines = $did(%d,%did).lines, %a = 1, %b = $numtok(%s,44), %c = 0
      var %t

      var %i = %b
      while (%i) {
        %c = $calc(%c + $gettok(%s,%i,44))
        dec %i
      }
      var %i = 0
      while (%i <= %lines) {
        if ($_atreev(%d,%did,%i).tok == 1) inc %x
        if (%x == %l) {
          if (%b < 1) return %i
          %t = %x
          inc %i
          while (%a <= %b) {
            %x = 0
            while (%i <= %lines) {
              if ($_atreev(%d,%did,%i).tok == $calc(%a + 1)) {
                %x = $iif($gettok(%t,$sum(%a,1),44),$sum($ifmatch,1),1)
              }
              elseif ($_atreev(%d,%did,%i).tok > $calc(%a + 1)) {
                inc %a
                %x = 1
              }
              else {
                %x = $iif($gettok(%t,%a,44),$sum($ifmatch,1),0)
                dec %a 
                dec %i $calc(%a - $iifelse($_atreev(%d,%did,%i).tok,0) + 1)
              }
              %t = $+($gettok(%t,$+(1-,%a),44),$chr(44),%x)
              ;echo -ag after: %t vs. $+(%l,$chr(44),%s) I: %i A: %a X: %x TEXT: $did(%d,%did,%i).text
              if ($+(%l,$chr(44),%s) == %t) {
                return %i
              }
              inc %i
            }
            inc %a
          }
        }
        inc %i
      }
      return $false
    }
    if (%prop == text) {
      var %i = $_atreev(%d,%did,%l,%s).trueline, %x = $_atreev(%d,%did,%i).tok
      return $gettok($did(%d,%did,%i).text,$+(%x,-),32)
    }
  }
}
_atreev.check {
  if (!$nvar(atree.branch)) nvar atree.branch ->
}
_atreev return [ [ $+($,atreev($1,$2,$3,$4),.,$prop) ] ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DCX and other dialog aliases and identifiers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dcx {
  if ($isid) return $dll($dd(dcx.dll),$1,$2-)
  else dll $dd(dcx.dll)  $1 $2-
}

udcx   $iif($menu, .timer 1 0) dll -u dcx.dll

xdid {
  if ($isid)  return $dcx( _xdid, $1 $2 $prop $3- )
  else dcx xdid $2 $3 $1 $4-
}

xdialog {
  if ($isid)  return $dcx( _xdialog, $1 $prop $2- )
  else dcx xdialog $2 $1 $3-
}
xdock {
  if ($isid)  return $dcx(_xdock, $1 $prop $2-)
  else  dcx xdock $1-
}
xtray {
  if ($isid) return $dcx(TrayIcon, $1 $prop $2-)
  dcx TrayIcon $1-
}
xtreebar {
  if ($isid) return $dcx(XTreebar, $1 $prop $2-)
  dcx XTreebar $1-
}
xpop {
  if ($isid)  return $dcx( _xpop, $1 $prop $2- )
  else dcx xpop $2 $1 $3-
}

xpopup {
  if ($isid) return $dcx( _xpopup, $1 $prop $2- )
  else  dcx xpopup $2 $1 $3-
}

lang.tooltip {
  ;fix all unos tooltip things to use this $lang.tooltip(dname,id,default) -vile
  var %langfile = $langd(dialogs.lng)
  if (!$isfile(%langfile)) return $3-
  var %a = $readini(%langfile,$1 $+ _tooltips,$2)
  return $iif(%a,%a,$3-)
}
mtooltips {
  if (!$isfile($dd(mTooltips.dll))) return
  if ($lock(dll)) return
  return $dll($dd(mTooltips.dll),$1,$2-)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; temptary setting storing for dialogs
;; & support aliases
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; temp set
;; syntax: tmpdlgset dialog network chan did value
tmpdlgset { 
  if (!$hget(tempsetup)) hmake tempsetup 100
  if ($0 >= 5) hadd tempsetup $tab(set,$1,$2,$3,$4) $5-
  else hdel tempsetup $tab(set,$1,$2,$3,$4)
}

;; global temp set
;; syntax: tmpdlggset dialog did value
tmpdlggset {
  if (!$hget(tempsetup)) hmake tempsetup 32
  if ($0 >= 3) hadd tempsetup $tab(set,$1,global,global,$2) $3-
  else hdel tempsetup $tab(set,$1,global,global,$2)
}

;; get, syntax is the same
tmpdlgget return $hget(tempsetup,$tab(set,$1,$2,$3,$4))
tmpdlggget return $hget(tempsetup,$tab(set,$1,global,global,$2))
; _tmpdlgdel.hash <dialog.name>
_tmpdlgdel.hash {
  if (!$hget(tempsetup)) return
  hdel -w tempsetup $tab(set,$1,*)
  _tmpdlg.hashclose
}
_tmpdlg.hashclose {
  if (($hget(tempsetup)) && ($dialog(0) == 0)) {
    var %b, %a = 1
    while ($hfind(tempsetup,$tab(set,ircn.setup.modern,global,global,module,*,*),%a,w)) {
      set %b $ifmatch
      if ($ismod($gettok($hget(tempsetup,%b),5,9))) { 
        if ($dialog($gettok($hget(tempsetup,%b),2,9)))  return  
      }
      inc %a
    }
    hfree tempsetup
  }
}
_tmpdlg.hashopen {
  if (!$hget(tempsetup)) {
    hmake tempsetup 32
  }
}

; _ircn.cb.state <dialog> <did> <0|1|2>
_ircn.cb.state {
  ; $1 = dialog $2 = did $3 = 0/1
  var %a = -u
  if (!$2) return
  if ($3 == 1) set %a -c
  elseif (($3 == 2)) set %a -cu
  did %a $1 $2
}
; _ircn.upddlgchks <dialog> <netowrk> <channel> <1,2,3>
; example: _ircn.upddlgchks ircnsetup.channel $did(9) $did(7) 1,2,3
_ircn.upddlgchks {
  ; $1 = dialog, $2 = Network, $3 = Channel, $4 = did1,did2,did3
  if (!$4) return
  var %d = $1, %n = $2, %c = $3, %l = $4
  var %a = 1, %b
  ;echo -a Dialog: %d Net: %n Chan: %c
  while ($gettok(%l,%a,44)) {
    set %b $v1
    _ircn.cb.state %d %b $tmpdlgget(%d,%n,%c,%b)
    inc %a
  }
}
; _ircn.upddlgtxts <dialog> <netowrk> <channel> <1,2,3>
; example: _ircn.upddlgtxts ircnsetup.channel $did(9) $did(7) 1,2,3
_ircn.upddlgtxts {
  ; $1 = dialog, $2 = Network, $3 = Channel, $4 = did1,did2,did3
  if (!$4) return
  var %d = $1, %n = $2, %c = $3, %l = $4
  var %a = 1, %b
  ;echo -a Dialog: %d Net: %n Chan: %c
  while ($gettok(%l,%a,44)) {
    set %b $v1
    did -ra %d %b $tmpdlgget(%d,%n,%c,%b)
    inc %a
  }
}
; _ircn.upddlgcombos <dialog> <netowrk> <channel> <1,2,3> [#]
; example: _ircn.upddlgcombos ircnsetup.channel $did(9) $did(7) 1 44
_ircn.upddlgcombos {
  ; $1 = dialog, $2 = Network, $3 = Channel, $4 = did1,did2,did3, $5 = [separator]
  if (!$4) return
  var %d = $1, %n = $2, %c = $3, %l = $4
  var %a = 1, %b, %s
  if ($5) set %s $5
  else set %s 44
  ;echo -a Dialog: %d Net: %n Chan: %c
  while ($gettok(%l,%a,44)) {
    set %b $v1
    did -r %d %b
    didtok %d %b %s $tmpdlgget(%d,%n,%c,%b)
    inc %a
  }
}
; _ircn.handecheck <dialog> <Network> <Channel> <did>
_ircn.handecheck {
  var %d = $1, %b = $4, %n = $2, %c = $3
  if ((%n == Global) && ($did(%d,%b).state == 2)) { did -u %d %b }
  tmpdlgset %d %n %c %b $did(%b).state
}

; _ircn.loadtmpdlgdid <dialog.name> [module.name] <global,net,chans> <setting1.name;#,setting2.name;#> <check/text>
_ircn.loadtmpdlgdid {
  ; $1 = dialog, $2 = [mod], $3 = global,net,chans, $4 = setting1;did1,setting2,did2 $5 <check/text>
  var %d = $1
  var %a = 1, %b, %c, %n, %z, %l, %h, %x, %y, %s
  if ($0 == 5) {
    set %h $2
    set %l $4
    set %b $3
    set %s $5
  }
  elseif ($0 == 4) {
    set %h ircn
    set %l $3
    set %b $2
    set %s $4
  }
  else return
  if ($istok(%b,global,44)) {
    while ($gettok(%l,%a,44)) {
      set %z $v1
      if (%s == check) tmpdlggset %d $gettok(%z,2,59) $onoff2nro($iif(%h == ircn,$nvar($gettok(%z,1,59)),$modvar(%h,$gettok(%z,1,59))))
      elseif (%s == text) tmpdlggset %d $gettok(%z,2,59) $iif(%h == ircn,$nvar($gettok(%z,1,59)),$modvar(%h,$gettok(%z,1,59)))
      inc %a
    }
  }
  set %a 1
  if ($istok(%b,net,44)) {
    while ($gettok(%l,%a,44)) {
      set %z $v1
      ;echo -a tmpdlggset %d $gettok(%z,2,59) $onoff2nro(  $gettok(%z,1,59) )
      set %x 1
      while ($scon(%x)) {
        scon %x
        if (%s == check) tmpdlgset %d $network Global $gettok(%z,2,59) $onoffdef2nro($iif(%h == ircn,$nget($gettok(%z,1,59)),$modget(%h,$gettok(%z,1,59))))
        elseif (%s == check2) tmpdlgset %d $network Global $gettok(%z,2,59) $onoff2nro($iif(%h == ircn,$nget($gettok(%z,1,59)),$modget(%h,$gettok(%z,1,59))))
        elseif (%s == text) tmpdlgset %d $network Global $gettok(%z,2,59) $iif(%h == ircn,$nget($gettok(%z,1,59)),$modget(%h,$gettok(%z,1,59)))
        if ($istok(%b,chans,44)) {
          set %y 1
          while ($gettok($netchans($network),%y,44) != $null) {
            set %c $v1
            if (%s == check) tmpdlgset %d $network %c $gettok(%z,2,59) $onoffdef2nro($iif(%h == ircn,$nget($tab(chan,%c,$gettok(%z,1,59))),$modget(%h,$tab(chan,%c,$gettok(%z,1,59)))))
            elseif (%s == check2) tmpdlgset %d $network %c $gettok(%z,2,59) $onoff2nro($iif(%h == ircn,$nget($tab(chan,%c,$gettok(%z,1,59))),$modget(%h,$tab(chan,%c,$gettok(%z,1,59)))))
            elseif (%s == text) tmpdlgset %d $network %c $gettok(%z,2,59) $iif(%h == ircn,$nget($tab(chan,%c,$gettok(%z,1,59))),$modget(%h,$tab(chan,%c,$gettok(%z,1,59))))
            inc %y
          }
        }

        inc %x
      }
      scon -r
      inc %a
    }
  }
}
; _ircn.savetmpdlgdid <dialog.name> [module.name] <global,net,chans> <setting1.name;#,setting2.name;#> <check/text/check2>
_ircn.savetmpdlgdid {
  ; $1 = dialog, $2 = [mod], $3 = global,net,chans, $4 = setting1;did1,setting2,did2
  var %d = $1
  var %a = 1, %b, %c, %n, %z, %l, %h, %x, %y, %s, %m, %f, %o
  if ($0 == 5) {
    set %h $2
    set %l $4
    set %b $3
    set %s $5
  }
  elseif ($0 == 4) {
    set %h ircn
    set %l $3
    set %b $2
    set %s $4
  }
  else return

  if ($istok(%b,global,44)) {
    while ($gettok(%l,%a,44)) {
      set %z $v1
      set %m $tmpdlggget(%d,$gettok(%z,2,59))
      if (%s == check) {
        if (%h == ircn) set %f nvar $gettok(%z,1,59)
        else set %f modvar %h $gettok(%z,1,59)
        set %m $nro2onoff(%m)
      }
      if (%s == text) {
        if (%h == ircn) set %f nvar $gettok(%z,1,59)
        else set %f modvar %h $gettok(%z,1,59)
      }
      %f %m
      inc %a
    }
  }
  set %a 1
  if (($istok(%b,net,44)) || ($istok(%b,chans,44))) {
    while ($gettok(%l,%a,44)) {
      set %z $v1
      set %x 1
      while ($scon(%x)) {
        scon %x
        if ($istok(%b,net,44)) { 
          set %m $tmpdlgget(%d,$network,Global,$gettok(%z,2,59))
          if (%s == check) {
            if (%h == ircn) set %f nset $gettok(%z,1,59)
            else set %f modset %h $gettok(%z,1,59)
            set %m $nro2onoffdef(%m)
          }
          if (%s == check2) {
            if (%h == ircn) set %f nset $gettok(%z,1,59)
            else set %f modset %h $gettok(%z,1,59)
            set %m $nro2onoff(%m)
          }
          if (%s == text) {
            if (%h == ircn) set %f nset $gettok(%z,1,59)
            else set %f modset %h $gettok(%z,1,59)
          }

          %f %m
        }
        if ($istok(%b,chans,44)) {
          set %y 1
          while ($gettok($netchans($network),%y,44) != $null) {
            set %c $v1
            set %m $tmpdlgget(%d,$network,%c,$gettok(%z,2,59))
            if (%s == check) {
              if (%h == ircn) set %f nset $tab(chan,%c,$gettok(%z,1,59))
              else set %f modset %h $tab(chan,%c,$gettok(%z,1,59))
              set %m $nro2onoffdef(%m)
            }
            if (%s == check2) {
              if (%h == ircn) set %f nset $tab(chan,%c,$gettok(%z,1,59))
              else set %f modset %h $tab(chan,%c,$gettok(%z,1,59))
              set %m $nro2onoff(%m)
            }
            if (%s == text) {
              if (%h == ircn) set %f nset $tab(chan,%c,$gettok(%z,1,59))
              else set %f modset %h $tab(chan,%c,$gettok(%z,1,59))
            }
            %f %m
            inc %y
          }
        }

        inc %x
      }
      scon -r
      inc %a
    }
  }
}
_setuptmphsh.load {
  if (!$hget(tempsetup))  hmake tempsetup 32
}

onoffdef2nro {
  if (!$1) return 2
  return $replace($1,off,0,on,1,default,2)
}
onoff2nro {
  if (!$1) return 0
  return $replace($1,off,0,on,1)
}
nro2onoffdef return $remove($replace($1,0,off,1,on),2)
nro2onoff return $remove($replace($1,1,on),0)

nodlgs if ((!$ismod(modernui)) && (!$ismod(classicui))) return $true

_did {
  ;/_did -h name 1,2,5-9,11
  var %fpos,%f,%n,%i,%n2,%n2pos,%npos,%ipos,%fpos,%e
  if (-* iswm $1) set %fpos 1
  if (%fpos) set %f $gettok($1-,%fpos,32)
  set %npos $iif(%f,2,1)
  if (%npos) set %n $gettok($1-,%npos,32)
  set %ipos $calc(%npos + 1)
  if (%ipos) set %i $gettok($1-,%ipos,32)
  if ($istok(d.c.u.k.i.o,%f,44)) {
    set %n2pos $calc(%ipos + 1)
    if ((%n2pos) && ($gettok($1-,%n2pos,32) isnum)) {
      set %n2 $gettok($1-,%n2pos,32)
    }
    set %e $gettok($1-,$calc(%n2pos + 1) $+ -,32)
  }
  else set %e $gettok($1-,$calc(%ipos + 1) $+ -,32)
  if ((!$dialog(%n)) || ($remove(%i,$chr(44),-) !isnum)) return
  var %a = 1, %b
  if (- isin %i) {
    while ($gettok(%i,%a,44) != $null) {
      set %b $ifmatch
      if (- isin %b) {
        var %if = $gettok(%b,1,45)
        var %it = $gettok(%b,2,45)
        if ((%if > %it) || (%if !isnum) || (%it !isnum)) { inc %a | continue }
        while (%if <= %it) {
          if (!$dialog(%n))  return
          did %f %n %if %n2 %e
          inc %if
        }
      }
      else did %f %n %i %n2 %e
      inc %a
    }
  }
  else did %f %n %i %n2 %e
}
; _ircn.setup.addnetcombo.offline [dialog] [id] <noglobal> <hashnros> 
_ircn.setup.addnetcombo.offline {
  var %d = $1, %i = $2
  did -r %d %i
  if (!$istok($3-,noglobal,32)) {
    did -a %d %i Global
    did -a %d %i $str(-,500)
  }
  ;var %a = $findfile($sd(network\),*.set*,0,_ircn.setup.addnetcombo.offline.handle %d %i $1-)
  var %x
  if ($istok($3-,hashnros,32)) {
    var %a = $findfile($sd(network\),*.set*,0,set %x $addtok(%x,$netfn2set($nopath($1-)),9))
  }
  else var %a = $findfile($sd(network\),*.set*,0,set %x $addtok(%x,$gettok($netfn2set($nopath($1-)),1,32),9))
  ;echo -X: %x A: %a
  set %a $numtok(%x,9)
  var %b = 1
  while (%b <= %a) {
    did -a %d %i $gettok(%x,%b,9)
    inc %b
  }
  did -c %d %i 1
}
_ircn.setup.addnetcombo {

  var %d = $1, %i = $2
  did -r %d %i
  if ($3 != noglobal) {
    did -a %d %i Global
    did -a %d %i $str(-,500)
  }
  if (($scon(0) == 1) && (!$scon(1).server)) { did -b %d %i | did -c %d %i 1 | return }
  var %a = 1, %b
  while ($scon(%a) != $null) {
    scon %a
    set %b $didwm(%d,%i,$curnet)
    if ((!%b) && ($server))  did -a %d %i $curnet
    inc %a
  }
  scon -r
  did -c %d %i 1
}
_ircn.setup.addchancombo {
  var %d = $1, %i = $2
  did -r %d %i
  did -a %d %i Global
  did -a %d %i $str(-,500)
  var %a = 1, %b
  while ($gettok($netchans($3),%a,44) != $null) {
    did -a %d %i $ifmatch
    inc %a
  }
  did -c %d %i 1
}

; ################################################################
; ####################### IRCN SCRIPT FILE #######################
; ########## END OF FILE. DO NOT REMOVE OR MODIFY BELOW ##########
; ################################################################
