# return #$1
| if ($isid) return $chr(124)
ab if ($1) return [[ $+ $1- $+ ]]
address.def return $address($1,$iifelse($nvar(kbmask),3))
alof return $bytes($1).suf
ascode {
  var %a, %b, %z
  set %b 0
  set %a 1
  while ($asc($mid($3-,%a,1)) != $null) {
    set %z $ifmatch
    if ((%z != 32) && (($1 <= %z) && (%z <= $2))) inc %b
    inc %a
  }
  return $calc(%b / $len($3-) * 100)
}
asc-time {
  var %a = ddd, mmm dd yyyy
  return $asctime($1,%a) at $asctime($1,h:nntt)
}
asctime.short {
  ; ctime
  ; if < 1day .. 1:00pm
  ; if > day but < 1 week .. yesterday ... tuesday.. 
  ; if > week but same month Wed 7th 5:02pm
  ; 
  if ($asctime($1,mmddyyyy) == $asctime(mmddyyyy)) return $asctime($1,h:nntt)  
  ; if it was ysterday
  ;  echo -s .... yesterdaday? $asctime($1,mmddyyyy) == $asctime($calc( $ctime - 86400),mmddyyyy)
  if ($asctime($1,mmddyyyy) == $asctime($calc( $ctime - 86400),mmddyyyy)) return Yesterday $asctime($1,h:nntt) 

  ;if ($calc($ctime - $1) <= 86400) return Yesterday $asctime($1,h:nntt) 

  ;  if ($asctime($1,dd) == $calc($ctime - 86400)

  if ($asctime($1,mmyyyy) == $asctime(mmyyyy))  return $iif($asctime($1,ddd) == $asctime(ddd),Last) $asctime($1,ddd doo h:nntt)
  if ($asctime($1,yyyy) == $asctime(yyyy)) return $asctime($1,mmm doo h:nntt)
  return $asctime($1,mmm doo h:nntt yyyy)
}
atime return $asctime(h:nntt)
;return ascii list example: $alistfrm($tab(20 item1,c10 item2,30 item3)).line
alistfrmt {
  var %y, %z, %l, %x = $numtok($1,9), %n = %x, %c, %a, %prop = $prop
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
      if ((%c == 1) && ($len(%z) > %y)) %z = $left(%z,%y)

      var %left = $iif(%a == r,$calc(%y - $len($strip(%z))),$iif(%a == c,$floor($calc($calc(%y - $len($strip(%z))) / 2)),0))
      var %right = $iif(%a == l,$calc(%y - $len($strip(%z))),$iif(%a == c,$floor($calc($calc(%y - $len($strip(%z))) - %left)),0))
      if ($len(%z) == 0) %z = 


      %z = $iif(%x == 1,$|) $+ $str( $+ $chr(32),%left) %z $str( $+ $chr(32),%right) $|
      %l = %z %l
      dec %x
    }
    return %l
  }
}
b return  $+ $1- $+ $iif($1,)
backspace {
  if ($1 == $null) return
  var %a, %b, %c
  bunset &backspace.y &backspace.z
  bset -t &backspace.z 1 $1-
  set %a 0
  set %b 0
  :start
  inc %a
  inc %b
  if ($bvar(&backspace.z,%a) != $null) {
    set %c $ifmatch
    if (%c == 8) {
      bset &backspace.y %b 0
      dec %b 2
      if (%b < 0) set %b 0
      goto start
    }
    bset &backspace.y %b %c
    goto start
  }
  return $bvar(&backspace.y,1-).text
}
bantime {
  if ($calc($ctime - $1) > 86400) return $int($calc($ifmatch / 86400)) day $+ $plural($int($calc($ifmatch / 86400))) ago
  else return $time($1,HH:nn)
}
brak return $paren($1-,[,])
brkt return $b([) $+ $hc($1-) $+ $b(])
c return  $+ $1- $+ $iif($1,)
cc2txt return $replace($1-,,<c>,,<b>,,<u>,,<o>,,<r>)
caps return $ascode(65,90,$1-)
cpms {
  tokenize 32 $1-
  if ((($1 == PING) && (($2- isnum) || (($2 isnum) && ($3- isnum)))) || ($2- == $null)) return .
  else return : $2-
}
center {
  if ($len($strip($2-)) >= $1) return $2-
  else {
    if ($calc($sub($1,$len($strip($2-))) % 2) == 0) return $str( ,$int($div($sub($1,$len($strip($2-))),2))) $+ $2- $+ $str( ,$int($div($sub($1,$len($strip($2-))),2)))
    else return $str( ,$int($div($sub($1,$len($strip($2-))),2))) $+ $2- $+ $str( ,$pls($int($div($sub($1,$len($strip($2-))),2)),1))
  }
}
comptxt {
  bset -t &z 1 $1-
  var %a = $compress(&z,b)
  if (%a) return $bvar(&z,1-).text
}
decomptxt {
  bset -t &z 1 $1-
  var %a = $decompress(&z,b)
  if (%a) return $bvar(&z,1-).text
}
cmcolor {
  if (@ isin $1) return 12
  if (% isin $1) return 07
  if (+ isin $1) return 06
  return 01
}
cmdchar return $iifelse($readini($mircini,n,text,commandchar),/)
cmdtip if (!$nvar(commandtip.hidepopups)) return $tab $brak($iif($left($1,1) != $cmdchar,$cmdchar) $+ $1)
connected return $iif($status == connected,$true,$false)
totalconnected {
  var %a = 1, %b
  while ($scon(%a) != $null) {
    scon %a
    if ($connected) inc %b
    inc %a
  }
  scon -r 
  return %b
}
com.channels {
  var %a, %b, %z
  set %a 1
  while ($comchan($1,%a)) {
    set %b $ifmatch
    if ($prop == prefix) set %z $addtok(%z,$remove($nick(%b,$1).pnick,$1) $+ %b,44)
    else  set %z $addtok(%z,%b,44)
    inc %a
  }
  return %z
}
com.opchannels {
  var %a, %y, %z
  set %a 1
  while ($comchan($1,%a)) {
    set %y $ifmatch
    if ($me isop %y) set %z $addtok(%z,%y,44)
    inc %a
  }
  return %z
}
commaseparate return $replace($1-,$chr($iifelse($prop,32)),$chr(44) $+ $chr($iifelse($prop,32)))
clop {
  if ($1 isop $2) return @ $+ $1
  elseif ($1 ishop $2) return % $+ $1
  elseif ($1 isvo $2) return + $+ $1
  else return $1
}
clop2 {
  if ($me isop $1) return @ $+ $1
  elseif ($me ishop $1) return % $+ $1
  elseif ($me isvo $1) return + $+ $1
  else return $1
}
hlightt {
  if ($1 == $null) return $false
  var %a = $highlight($1-)
  if ((%a) && (%a isin $1-) && (%a != $highlight(0))) return %a
  else return $false
}
hlightt.floodannoy {
  var %a = 1, %t, %n, %m = 0, %r
  while ($gettok($2-,%a,32) != $null) {
    set %n $gettok($2-,%a,32)
    if (%n ison $1) inc %m
    inc %a
  }
  if (%m <= 3) return 0
  set %r $calc(%m / $numtok($2-,32) * 100)
  return %r
}
hload.datafiles {
  if ($isid) {
    if ($0 < 2) { goto syntax }
    var %hash = $1
    var %fname = $tp($1 $+ $ticks $+ .tmp)
    if ($isfile(%fname))  .remove %fname
    var %a = 1, %b = $calc($0 - 1), %c, %d
    while (%a <= %b ) {
      set %c $eval($+($,$calc(%a + 1)),2)
      if ($isfile($qt(%c))) { 
        .copy -a $qt(%c) %fname 
        bread %fname $calc($file(%fname) - 4) 4 &z 
        if ($bvar(&z,1-4) == 13 10 13 10) write -dl $+ $lines(%fname) %fname
        bunset &z
        inc %d 
      }
      inc %a
    }
  }
  if (!%d) { return -ERR no files }

  if (!$hget(%hash)) .hmake %hash $lines(%fname)
  .hload -n %hash %fname
  if ($isfile(%fname))  .remove %fname
  return +OK %hash %d
  :syntax
  if (!$isid) theme.syntax -a $ $+ hloadall(table,file1,file2,file3,file4)
}
curnet {
  var %a = $ncid(network)
  if (%a == $null) set %a $network
  if (%a == $null) set %a $server($server).group
  if ($1 != noserver) {
    if (%a == $null) set %a $server
  }
  return %a
}
curircd {
  var %v = $ncid(server_version)

  ;change this to set a ncid "ircd"  on connect

  if (ratbox isin %v) return Ratbox $iif(ircd-ratbox-* iswm %v ,  $gettok(%v,3-,45))
  if (hybrid isin %v) return Hybrid $iif(hybrid-* iswm %v, $gettok(%v,2-,45))
  if (bahamut isin %v) return Bahamut $iif(bahamut-* iswm %v,  $gettok(%v,2-,45))
  if (unreal isin %v) return Unreal $iif($remove(%v,unreal,.) isnum, $remove(%v,unreal))
  if (conferenceroom isin %v) return Conferenceroom $iif(/ isin %v, $gettok(%v,2-,47))
  if ($regex(%v, u[0-9]\..*)) return ircU $right(%v,-1)
  if (ircu isin %v) return ircU
  if (Inspircd isin %v) return InspIRCd $iif(inspircd-* iswm %v, $gettok(%v,2-,45)) 
  if (beware isin %v) return Beware $remove(%v,beware)
  if (snircd isin %v) return Snircd
  if (akusa isin %v) return Akusa
  if (ircd-seven isin %v) return ircd-seven $iif(ircd-seven-* iswm %v,  $gettok(%v,3-,45))
  if (bIRCd isincs %v) return bIRCd $iif(bIRCd-* iswm %v, $remove(%v,bIRCd-))
  if (sorircd isin %v) return sorircd $iif(sorircd-* iswm %v, $gettok(%v,2-,45))
  if (WeIRCd isincs %v) return WeIRCd $iif($mid(%v,7,1) isnum, $remove(%v,weircd))
  if (UltimateIRCd isincs %v) return UltimateIRCd $right(%v,-12)
  if (nemesis isincs %v) return nemesis $right(%v,-7)

}
sanitize_chrs {
  ;string, "'()
  if (!$2) return
  var %a = 1, %chr, %txt = $1
  while ($mid($2-,%a,1) != $null) {
    set %chr $ifmatch
    set %txt $regsubex(%txt, /\\?(\ $+ %chr $+ )/g $+ $iif($prop == insensitive,i),\\1)
    inc %a
  }
  return %txt
}
desanitize_chrs {
  ;string, "'()
  if (!$2) return
  var %a = 1, %chr, %txt = $1
  while ($mid($2-,%a,1) != $null) {
    set %chr $ifmatch
    set %txt $replace(%txt,\ $+ %chr,%chr)
    inc %a
  }
  return %txt
}
desanitize_utf return $regsubex($iif($len($1) == 1,$2-,$1-),/\\ $+ $iif($len($1) == 1,$1,u) $+ ([0-9a-z]{ $+ $iif($prop isnum,$prop,4) $+ })/ig,$chr($base(\1,16,10)))
de-op {
  var %z
  set %z $address($1,$iifelse($nvar(kbmask),3))
  if ($1 isop $2) return +b-o %z $1
  else return +b %z
}
div {
  if (($1 isnum) && ($2 isnum)) return $calc($1 / $2)
  elseif (($1 isnum) && ($2 == $null)) return $1
  elseif (($1 == $null) && ($2 isnum)) return 0
  elseif (($1 == $null) && ($2 == $null)) return
  else iecho DIV Error, $1 and $2 are not numbers!
}
fix {
  var %z
  if ($2- != $null) set %z $2-
  set %z %z $+ $str( ,$calc($1 - $len($strip(%z))))
  return $replace(%z,,)
}
fix2 {
  var %z
  if ($2- != $null) set %z $2-
  set %z %z $+ $str( ,$calc($1 - $len($strip(%z))))
  return %z
}
full-date return $asc-time($ctime)
get.incomplete {
  var %a = $calc($get(0) - $get.complete) 
  return $iif(%a >= 0,%a,0)
}
get.complete {
  var %a = 1, %b = 0
  while ($get(%a) != $null) { 
    if ($get(%a).done) inc %b
    inc %a 
  } 
  return %b
}
getright return $right($1-,-1)
getcenter return $int($calc(($window(-3).w / 2) - ($1 / 2))) $int($calc(($window(-3).h / 2) - ($2 / 2))) $1 $2
_getpop return $hget(popups,$tab($1, $2, $3))
getdate {
  var %z
  set %z dddd, mmmm d h:nn tt yyyy
  return $replace($asctime(%z),pm,PM,am,AM)
}
gone {
  var %a = $calc($ctime - $iif($1,$modget(away,$1,awaytime),$modget(away,awaytime)))
  return $iif($away,$rsc2($trimdur(%a,$iif(%a > 60,s))),0s)
}
ischanhid return $iif($window($1).sbstate $+ $window($1).tbstate > 0,$false,$true)
hiddenchans {
  if (!$nvar(hidechans)) return 0

  var %s = 1, %x = 0
  while ($scon(%s) != $null) {
    if ($nvar(tinyswitchbar)) { }
    else scon %s
    var %a = 1 
    while ($chan(%a) != $null) {
      if ($istok($nvar(hidechans),$chan(%a),44)) {
        if ($ischanhid($chan(%a))) inc %x
      }
      inc %a
    }
    if ($nvar(tinyswitchbar)) break
    inc %s
  }
  scon -r
  return %x
}
hideablechans {
  if (!$nvar(hidechans)) return 0

  var %s = 1, %x = 0
  while ($scon(%s) != $null) {
    if ($nvar(tinyswitchbar)) { }
    else scon %s
    var %a = 1 
    while ($chan(%a) != $null) {
      if ($istok($nvar(hidechans),$chan(%a),44)) {
        if (!$ischanhid($chan(%a))) inc %x
      }
      inc %a
    }
    if ($nvar(tinyswitchbar)) break

    inc %s
  }
  scon -r
  return %x
}

hlag return $iifelse($ncid(lag),0) $+ s
ialhostnicks {
  var %a = 1, %b
  while ($ial(*!*@ $+ $1,%a).nick != $null) { 
    set %b $addtok(%b,$ifmatch,44)
    inc %a
  }
  return %b
}
iasctime { 
  ;returns asctime but takes into account the users preference for 24/12hr format
  var %n, %f
  if ($1 isnum) { set %n $1 | set %f $2- }
  else set %f $1
  if (!$0) || ((%n) && (!%f)) return $asctime($ctime, ddd mmm dd hh:nn:ss)

  set %f $replacecs(%f,H,h) $+ $iif($prop == ampm, tt)

  if (%n) return $asctime(%n, %f)
  else return $asctime(%f)
}
iduration {
  if ($1 !isnum) {
    iecho IDURATION: $1 is not a number!
    return
  }
  var %a, %b
  if ($1 < 60) return $1 second $+ $plural($1)
  elseif ($1 < 3600) {
    set %a $int($calc($1 / 60))
    set %b $calc($1 % 60)
    return %a minute $+ $plural(%a) $+ , %b second $+ $plural(%b)
  }
  else return $duration($round($1,0))
}
infobox {
  if (!$isid) return
  ; <name>, <title>, [timeout], <text>

  var %title, %text, %time

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

  if ($isalias(infobox.dialog)) {
    return $infobox.dialog( $1, %title, %time, %text)

  }
  else {


    $iif($isalias(iecho),iecho,echo) -s %title $+ : %text

  }

}
iifelse return $iif($1,$1,$2)
iifelsenull return $iif($1 != $null,$1,$2)
isauthuser  return $iif($nget($tab(auth,$iifelse($1,$me),passwd)), $true)
isblankcloaked {
  if ($ismod(userlist)) {
    if ($chkflag($usrh($1),$null,m)) return $false
  }
  if ($nget(cloak. $+ $2) == blank) return $true
  return $false
}
ischanset {
  if ($nget($tab(chan,$2,$1)) == on) return $true
  elseif ($nget($tab(chan,$2,$1)) == off) return $false
  elseif ((!$nget($tab(chan,$2,$1))) && ($nget($tab(chan,global,$1)) == on)) return $true
  elseif ((!$nget($tab(chan,$2,$1))) && ($nget($tab(chan,global,$1)) == off)) return $false
  elseif (($nget($tab(chan,$2,$1)) != off) || ($nget($tab(chan,global,$1)) != off)) {
    if ($nvar($1) == on) return $true
    return $false
  }
  return $false
}
isqueryset {
  ;isqueryset stripcodes vile
  ;query.stripcodes.vile

  if ($nget($tab(query,$2,$1)) == on) return $true
  elseif ($nget($tab(query,$2,$1)) == off) return $false
  if ($nvar(query. $+ $1) == on) return $true
  return $false
}
isfullcloaked {
  if ($ismod(userlist)) {
    if ($chkflag($usrh($1),$null,m)) return $false
  }
  if ($nget(cloak. $+ $2) == on) return $true
  return $false
}
isdccrelaynick {
  var %a = 1, %b, %c
  while ($var(%dccrelay.*,%a) != $null) {
    set %b $ifmatch
    set %c $eval(%b,2)
    if ($gettok(%c,3,32) == $1) return %c
    inc %a
  }
}
ismoddeppended {
  var %a = 1, %b, %c, %d
  while ($gettok($nvar(modules),%a,44) != $null) {
    set %b $ifmatch
    set %c $modinfo($md(%b),depmod)
    if (!%c) { inc %a | continue }
    if ($istok(%c,$remove($nopath($1-),.mod),32)) set %d $addtok(%d,%b,44)
    inc %a
  }
  return %d
}
iscloaked {
  if ($ismod(userlist)) {
    if ($chkflag($usrh($1),$null,m)) return $false
  }
  var %z = $iif($hget(ctcpreplys,$2 $+ .style) == ignore,on)
  if ((%z == on) || (%z == blank)) return $true
  return $false
}
ispwctcp1 {
  var %z = CHAN OP INVITE INFO IDENT NOTES
  if (%pwctcp1 != $null) set %z %z $ifmatch
  if ($istok(%z,$1,32)) return $true
  else return $false
}
ispwctcp2 {
  var %z = PASS
  if (%pwctcp2 != $null) set %z %z $ifmatch
  if ($istok(%z,$1,32)) return $true
  else return $false
}
isuri {
  var %a = /(ftp|http|https|file):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i
  return $iif($regex($1,%a),$true,$false)  
}
isurl return $iif(($isuri($1-) || $isdomain($1-)),$true,$false)
isdomain {
  var %a = /^ $+ $iif($prop != nohttp,(https?:\/\/)?) $+ ([\da-z\.-]+)\.([a-z\.]{2,6}) $+ $iif($prop != nohttp,([\/\w \.-]*)*\/?) $+ $/
  return $iif($regex($1,%a),$true,$false)
}
isurlext {
  var %n = $iif($2 isnum,$2,1)
  var %e = $replace($3-,$chr(32),$chr(124))
  if (!%e) set %e jpg|jpeg|gif|png
  var %r = (http://(?:[a-z0-9\-]+\.)+[a-z0-9]{2,6}(?:/[^/#?]+)+\.(?: $+ %e $+ ))
  if ($regex(isurlext,$1,/ $+ %r $+ /ig)) {
    return $regml(isurlext,%n)
  }
}
isip { 
  var %a = /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/
  return $iif($regex($1,%a),$true,$false)
}
issupport {
  var %a
  set %a $istok($ncid(server_supported),$1,32)
  if (%a) return %a
  set %a $ncid(server_ $+ $1)
  if (%a) return %a
}
isserver {
  var %a = $read($srvfile,ns,$1)
  if (%a) return $true
}
isvalidchan return $iif(($istok($1,$2,44)) || ($1 == all),$true,$false)
kps {
  if ($prop == suf) return $bytes($1).suf $+ /s
  else return $bytes($1,k)
}
lfix {
  var %z
  if ($2- != $null) set %z $2-
  set %z $str( ,$calc($1 - $len($strip(%z)))) $+ %z
  return $replace(%z,,)
}
lfix2 {
  var %z
  if ($2- != $null) set %z $2-
  set %z $str( ,$calc($1 - $len($strip(%z)))) $+ %z
  return %z
}
toklfix {
  var %z, %a = 1, %b = $numtok($1,$2)
  while (%a <= %b) {
    set %z %z $lfix($3,$gettok($1,%a,$2))
    inc %a
  }
  return %z
}
toklfix2 {
  var %z, %a = 1, %b = $numtok($1,$2)
  while (%a <= %b) {
    set %z %z $lfix2($3,$gettok($1,%a,$2))
    inc %a
  }
  return %z
}
toksubr {
  var %b = $numtok($1,$2), %z = $gettok($1,%b,$2)
  dec %b
  while (%b > 0) {
    set %z $sub(%z,$gettok($1,%b,$2))
    dec %b
  }
  return %z
}
tokfix {
  var %z, %a = 1, %b = $numtok($1,$2)
  while (%a <= %b) {
    set %z %z $fix($3,$gettok($1,%a,$2))
    inc %a
  }
  return %z
}
tokfix2 {
  var %z, %a = 1, %b = $numtok($1,$2)
  while (%a <= %b) {
    set %z %z $fix2($3,$gettok($1,%a,$2))
    inc %a
  }
  return %z
}
mevnt return $gettok($hget(nxt_events,$1),$2,44)
mopt return $gettok($readini($mircini,options,n [ $+ [ $1 ] ] ),$2,44)
mode.match {
  ; +qvvv $~q test test test
  ; +q-q+q $~q $~q $~q
  ; +s-q $~q
  var %t = $2
  var %a = 1, %b, %f, %an = 1
  var %modepos = 1
  while ($mid($1,%a,1) != $null) {
    set %b $ifmatch
    if (%b == +) set %modepos 1 
    elseif (%b == -) set %modepos 0
    elseif (%b isalpha) {
      if (%b isincs $gettok($chanmodes,4,44)) {
        if ($wildtok(%f,$+(%b,=*),1,32)) set %f $reptok(%f,$ifmatch,$+(%b,=,%modepos),1,32)
        else set %f %f $+(%b,=,%modepos) 
      }
      elseif (%b isincs $gettok($chanmodes,1,44)) {
        ;   iecho %b val: $gettok(%t,%an,32) applies to %an
        if ($wildtok(%f,$+(%b,:,$gettok(%t,%an,32),=*),1,32)) set %f $reptok(%f,$ifmatch,$+(%b,:,$gettok(%t,%an,32),=,%modepos),1,32)
        else set %f %f $+(%b,:,$gettok(%t,%an,32),=,%modepos) 
        inc %an
      }
    }
    inc %a
  }
  return %f
}
mode.match_handle {
  ; (s=1 p=0 q:$~a=1, 1) = +s or -s .... if .mode
  if ($2 == 0) return $numtok($1,32)
  var %a = 1, %b
  while ($gettok($1,%a,32) != $null) {
    set %b $ifmatch
    if (%a == $2) {
      if (: isin %b) {
        if ($prop == value) return $gettok($gettok(%b,1,61),2,58)
        return $iif(*=1 iswm %b,+,-) $+ $gettok($gettok(%b,1,61),1,58)
      }
      else  return $iif(*=1 iswm %b,+,-) $+ $gettok(%b,1,61)
    }
    inc %a
  }
}
mod {
  if ($isid) {
    if (($1 isnum) && ($2 isnum)) return $calc($1 % $2)
    elseif (($1 == $null) && ($2 isnum)) return 0
    elseif ($2 == $null) return
    else iecho MOD Error, $1 and $2 are not numbers!
  }
  else module $1-
}
mpy {
  if (($1 isnum) && ($2 isnum)) return $calc($1 * $2)
  elseif (($1 isnum) && ($2 == $null)) return $1
  elseif (($1 == $null) && ($2 isnum)) return 0
  elseif (($1 == $null) && ($2 == $null)) return
  else iecho MPY Error, $1 and $2 are not numbers!
}
mysite return $gettok($address($me,0),2-,64)
mychans return $com.channels($me) 
mychans.public {
  var %a = 1, %b, %c
  while ($gettok($mychans,%a,44) != $null) {
    set %b $ifmatch
    if (s !isincs $chan(%b).mode) && (p !isincs $chan(%b).mode)  set %c $addtok(%c,%b,44)

    inc %a
  }
  return %c
}
networknum {
  var %a = 1, %b, %c,  %n
  while (%a <= $scon(0)) {
    set %b $scon(%a)
    set %n $ncid($scid(%b),network)
    if (%n == $null) set %n $scid(%b).network
    if (%n == $null) set %n $server($scid(%b).server).group
    if (%n == $null) set %n $scid(%b).server
    if (%n == $1) inc %c
    inc %a
  }
  return %c
}
canqwhois {
  if (!$1) return
  if (!$ial($1)) return
  if ($ncid(qwhois.ratelimit)) return
  if (($cwiget($1,ircop)) && ($1 != $me))  return
  if ((!$cwiget($1,cwho)) && (!$cwiget($1,cwhois))) return
  if ((!$cwiget($1,cwho)) && ($cwiget($1,cwhois))) cwiset $1 cwho $cwiget($1,cwhois)
  if ($cwiget($1,away)) {
    var %t = $iif($cwiget($1,cwhois) > $cwiget($1,cwho),$cwiget($1,cwhois),$cwiget($1,cwho))
    if (!%t) return
    if ($calc($ctime - %t) > 210) return $ifmatch
  }
  elseif ($cwiget($1,cwhois)) {
    if ($calc($ctime - $cwiget($1,cwhois)) > 600) return $ifmatch
  }
}
cwiaddr {
  if (!$1) return
  var %a 
  if ($query($1).addr) return $gettok($ifmatch,2-,64)
  if ($ial($1)) return $gettok($gettok($ial($1),2-,33),2-,64)
  if ($cwiget($1,address)) return $ifmatch
}
cwiident {
  if (!$1) return
  var %a 
  if ($query($1).addr) return  $gettok($ifmatch,1,64)
  if ($ial($1)) return $gettok($gettok($ial($1),2-,33),1,64)
  if ($cwiget($1,ident)) return $ifmatch
}
channum {
  var %a = 1
  while ($chan(%a) != $null) {
    if ($ifmatch == $1) return %a
    inc %a
  }
}
globalchannum {
  var %a, %b = 1, %c = 0
  while ($scon(%b) != $null) {
    scon %b
    set %a 1
    while ($chan(%a) != $null) {
      inc %c
      inc %a
    }
    scon -r
    inc %b
  }
  return %c
}
chan.ishideevent {
  var %a = 1, %b, %c

  if (!$istok(join.part.quit.kick.mode.topic.ctcp.nick.action.text,$1,46)) return $false

  if ($changet($2,chanevent. $+ $1) == hide) return $true
  if ($istok(channel status,$changet($2,chanevent. $+ $1),32)) return $false
  if ($changet(global,chanevent. $+ $1) == hide) return $true
  if ($istok(channel status,$changet(global,chanevent. $+ $1),32)) return $false
  if ($nvar(chanevent. $+ $1) == hide) return $true

  return $false
}
chan.showevent.status {
  if (!$istok(join.part.quit.kick.mode.topic.ctcp.nick,$1,46)) return $false

  if ($changet($2,chanevent. $+ $1) == status) return $true
  if ($changet(global,chanevent. $+ $1) == status) return $true
  if ($nvar(chanevent. $+ $1) == status) return $true

  return $false
}
chanwasted {
  if ($me !ison $1) || (!$connected) return
  var %a = $changet($1,lastjoin)
  if (!%a) return
  var %b = $calc($ctime - %a)
  if (%b) return %b
}
chan.eventtarget {
  if ($chan.showevent.status($1, $2)) return 2
}
chan.ignoretextmatch {
  var %a = 1, %b, %c
  while (%a <= $hfind(ircN, $tab(chanevent.ignorematch,*),0,w)) {
    set %b $hfind(ircN, $tab(chanevent.ignorematch,*),%a,w)
    set %c $hget(ircN,%b)
    if ($gettok(%c,1,32) == <r>) {
      if ($regex($2-,$gettok(%c,2-,32))) return $true
    }
    else {
      if (%c iswm $2-) return $true
    }
    inc %a
  }
  var %a = 1, %b, %c

  while (%a <= $hfind($ncid($cid,network.hash) $+ .ircN.settings, $tab(chan,$1,chanevent.ignorematch,*),0,w)) {
    set %b $hfind($+($ncid($cid,network.hash),.ircN.settings), $tab(chan,$1,chanevent.ignorematch,*),%a,w)
    set %c $hget($+($ncid($cid,network.hash),.ircN.settings),%b)
    if ($gettok(%c,1,32) == <r>) {
      if ($regex($2-,$gettok(%c,2-,32))) return $true
    }
    else {
      if (%c iswm $2-) return $true
    }
    inc %a
  }
  var %a = 1, %b, %c

  while (%a <= $hfind($ncid($cid,network.hash) $+ .ircN.settings, $tab(chan,global,chanevent.ignorematch,*),0,w)) {
    set %b $hfind($+($ncid($cid,network.hash),.ircN.settings), $tab(chan,global,chanevent.ignorematch,*),%a,w)
    set %c $hget($+($ncid($cid,network.hash),.ircN.settings),%b)
    if ($gettok(%c,1,32) == <r>) {
      if ($regex($2-,$gettok(%c,2-,32))) return $true
    }
    else {
      if (%c iswm $2-) return $true
    }
    inc %a
  }

  return $false
}
cid2netset return $ncid($iif($1 isnum,$1,$cid),network.hash)
cid2scon {
  var %a = 1, %b, %c,  %n
  while (%a <= $scon(0)) {
    set %b $scon(%a)
    if (%b == $1) return %a
    inc %a
  }
}
cidwin return $iif($1,$+($iif(@* !iswm $1,@),$1,.,$cid))
numnetconns {
  var %a = 1, %b, %c = 0,  %n
  while (%a <= $scon(0)) {
    set %b $scon(%a)
    set %n $ncid($scid(%b),network)
    if (%n == $null) set %n $scid(%b).network
    if (%n == $null) set %n $server($scid(%b).server).group
    if (%n == $null) set %n $scid(%b).server
    if (%n == $1) inc %c
    inc %a
  }
  return %c
}
nettable return $+($ncid($iif($1,$1,$cid),network.hash),.ircN.settings)
net2scon {
  var %a = 1, %b, %c,  %n, %n2, %x = $1-
  while (%a <= $scon(0)) {
    set %b $scon(%a)
    set %n $ncid($scid(%b),network)
    set %n2 $ncid($scid(%b),network.hash)
    if (%n == $null) set %n $scid(%b).network
    if (%n == $null) set %n $server($scid(%b).server).group
    if (%n == $null) set %n $scid(%b).server

    if ($numtok(%x,32) > 1) if ($nethash2set(%n2) == %x) return %a
    else if (%n == %x) return %a
    inc %a
  }
}

net2scid {
  var %a = 1, %b, %c,  %n, %n2, %x = $1-
  while (%a <= $scon(0)) {
    set %b $scon(%a)
    set %n $ncid($scid(%b),network)
    set %n2 $ncid($scid(%b),network.hash)
    if (%n == $null) set %n $scid(%b).network
    if (%n == $null) set %n $server($scid(%b).server).group
    if (%n == $null) set %n $scid(%b).server

    if ($numtok(%x,32) > 1) if ($nethash2set(%n2) == %x) return $scon(%a).cid 
    else if (%n == %x) return $scon(%a).cid
    inc %a
  }
}
netchans {
  var %a = 1, %b, %c, %z
  while ($scon(%a)) {
    scon %a
    set %b $curnet
    if (%b == $1) {
      set %z 1
      while ($chan(%z) != $null) {
        set %c $addtok(%c,$chan(%z),44)
        inc %z
      }
    }
    inc %a
  }
  scon -r
  return %c
}
totalchans {
  var %a = 1, %b
  while ($scon(%a)) {
    scon %a
    inc %b $chan(0)
    inc %a
  }
  scon -r
  return %b
}
totalchats {
  var %a = 1, %b
  while ($scon(%a)) {
    scon %a
    inc %b $chat(0)
    inc %a
  }
  scon -r
  return %b
}
totalquery {
  var %a = 1, %b
  while ($scon(%a)) {
    scon %a
    inc %b $query(0)
    inc %a
  }
  scon -r
  return %b
}
nc { 
  var %v, %w, %x, %y, %z 
  if (($nvar(nickcomp) == on) && ($1)) { 
    set %v $nvar(nickcomp.nch) 
    set %w $remove($1,%v) 
    if (%w == $null) return $1 
    set %z $addtok(%w,*!*@*,0) 
    set %y $addtok(*,%z,0) 
    if ($2) set %x $2 
    else set %x $active 
    if (%w ison %x) return %w $+ %v 
    elseif ($nc.matches(%z,%x)) {
      var %t = $ifmatch
      if ($nvar(nickcomp.sort))   return $gettok($sorttok(%t,32),1,32) $+ %v 
      return $gettok(%t,1,32) $+ %v 
    }
    elseif ($nc.matches(%y,%x)) {
      var %t = $ifmatch
      if ($nvar(nickcomp.sort))   return $gettok($sorttok(%t,32),1,32) $+ %v 
      return $gettok(%t,1,32) $+ %v 
    }
    else return $1 
  } 
  else return $1 
} 
nc.matches {
  var %a = 1, %b
  while ($ialchan($1,$2,%a).nick != $null) {
    set %b $addtok(%b,$ifmatch,32)
    inc %a
  }
  return %b
}
nll {
  if ($1 != $null) return $1
  else return 
}
nocolon return $iif($left($1,1) == :,$right($1-,-1),$1-)
noext return $deltok($1-,-1,46)
notifyonline {
  var %a = 1, %b = 0, %c
  while (%a <= $notify(0)) {
    if ($notify(%a).ison) {
      if (!$notify(%a).network) || (($notify(%a).network) && ($istok($notify(%a).network,$curnet,44))) {
        if ($1 == nicks) set %c $addtok(%c,$notify(%a),44)
        inc %b
      }
    }
    inc %a
  }
  return $iif($1 == nicks, %c, %b)
}
notifynotonline {
  var %a = 1, %b = 0, %c
  while (%a <= $notify(0)) {
    if (!$notify(%a).ison) {
      if (!$notify(%a).network) || (($notify(%a).network) && ($istok($notify(%a).network,$curnet,44))) {
        if ($1 == nicks) set %c $addtok(%c,$notify(%a),44)
        inc %b
      }
    }
    inc %a
  }
  return $iif($1 == nicks, %c, %b)
}
_notifypopup.online {
  if (($nvar(contacts.userlistmenuonly) == on) && ($ismod(userlist.mod))) {
    var %a = 1, %n = 0
    while ($gettok($ncid(notify.online),%a,44) != $null) {
      var %u = $usrh(%a $+ ! $+ $iifelse($notify($ifmatch).addr,$ncid(notify. [ $+ [ $ifmatch ] $+ ] .addr)))
      if (%u) inc %n
      inc %a
    }
    return %n
  }
  return $numtok($ncid(notify.online),44)
}
notifyaddr {
  if (!$notify($1)) return
  return $iifelse($notify($1).addr,$ncid($+(notify.,$1,.addr)))
}
o return  $+ $1- $+ $iif($1,)
paren { 
  if ($3) return $2 $+ $1 $+ $3
  elseif ($2) return $2 $+ $1 $+ $2
  elseif ($1 != $null) return ( $+ $1- $+ )
}
pls {
  if (($1 isnum) && ($2 isnum)) return $calc($1 + $2)
  elseif (($1 isnum) && ($2 == $null)) return $1
  elseif (($1 == $null) && ($2 isnum)) return $2
  elseif (($1 == $null) && ($2 == $null)) return
  else iecho PLS Error, $1 and $2 are not numbers!
}
prefixmatch {
  var %a = $ncid(server_prefix)
  if ($paren(*) $+ * iswm %a) {
    var %c = $remove($gettok(%a,1,41),$chr(40),$chr(41))
    var %p = $gettok(%a,2-,41)
    if ($pos(%c,$1,1)) return $mid(%p,$ifmatch,1)
    if ($pos(%p,$1,1)) return $mid(%c,$ifmatch,1)
  }
}

plural return $2- $+ $iif(($1 > 1 && $1 isnum),s)
pwr {
  if (($1 isnum) && ($2 isnum)) return $calc($1 ^ $2)
  elseif (($1 isnum) && ($2 == $null)) return 1
  elseif (($1 == $null) && ($2 isnum)) return 0
  elseif (($1 == $null) && ($2 == $null)) return
  else iecho PWR Error, $1 and $2 are not numbers!
}
quo if ($1-) return " $+ $1- $+ "
rndstr { 
  var %a = 1,%b 
  while (%a <= $1) {
    if ($rand(0,1)) set %b %b $+ $iif($rand(0,1),$rand(a,z),$rand(A,Z)) 
    else set %b %b $+ $rand(1,9)
    inc %a 
  } 
  return %b
}
rndstrstrong { 
  var %a = 1, %b, %c, %q
  set %c & $chr(37) . ^ $chr(35) $ @ * _ + - !
  while (%a <= $1) {
    set %q $rand(0,7)
    if (%q < 5) {
      if ($rand(0,1)) set %b %b $+ $iif($rand(0,1),$rand(a,z),$rand(A,Z)) 
      else set %b %b $+ $rand(1,9)
    }
    else set %b %b $+ $gettok(%c, $rand(1, $numtok(%c,32)), 32)
    inc %a 
  } 
  return %b
}
rbrk if ($1 != $null) return $paren($sc($1-))
rot {
  if (($1 isnum) && ($2 isnum) && ($2 != 0)) return $calc($1 ^ (1 / $2))
  elseif (($1 isnum) && ($2 == $null)) return
  elseif (($1 == $null) && ($2 isnum)) return 0
  elseif (($1 == $null) && ($2 == $null)) return
  else iecho ROT Error, $1 and $2 are not numbers!
}
rfileordernum {
  var %a = 1, %b, %c
  while (%a <= $ini($mircini,rfiles,0)) {
    set %b $ini($mircini,rfiles,%a)
    set %c $readini($mircini,rfiles,%b)
    if ($remove(%c,") == $remove($1-,")) return $remove(%b,n)
    inc %a
  }
}
reldate { 
  var %a = $nvar(reldate)
  if ($1) return $replace($1-,yyyy,$left(%a,4),mm,$mid(%a,5,2),dd,$mid(%a,7,2),yy,$left(%a,2))
  return %a
}
readtbl {
  if (!$isfile($1)) return
  window -h @readtbl
  clear @readtbl
  loadbuf @readtbl $1
  var %a = $fline(@readtbl,$2)
  if (!%a) return
  var %b = $line(@readtbl,$pls(%a,1))
  window -c @readtbl
  return %b
}
rtime {
  var %z
  set %z ddd, dd mmm yyyy HH:nn:ss zz
  if ($1) return $asctime($1,%z)
  else return $asctime(%z)
}
rq return $trim($1-,")
rb return $remove($1-,[,])
rmnum return $remove($1-,1,2,3,4,5,6,7,8,9,0)
isinchr {
  ;string, .,[]]
  var %a = 1, %b, %c, %d
  while ($mid($2,%a,1) != $null) {
    set %b $ifmatch
    if ($prop == and) {
      if (%b isin $1) { inc %c | set %d %d $+ %b }
      else dec %c
    }
    else {
      if (%b isin $1) return %b
    }

    inc %a
  }
  if ($len($2) == %c) return %d
}
rsc return $remove($rsc2($1-),$chr(32))
rsc2 return $remove($1-,rs,ons,ecs,ins,rs,ays,ks,ec,in,r,ay,k)
rrpt return $round($calc($1 / 1000),3)
txt2cc return $replace($1-,<c>,,<b>,,<u>,,<o>,,<r>,)
trimdur {
  var %a = $duration($1)
  if (s isin $2) set %a $remove(%a,$wildtok(%a,*sec*,1,32))
  if (m isin $2) set %a $remove(%a,$wildtok(%a,*min*,1,32))
  if (h isin $2) set %a $remove(%a,$wildtok(%a,*hr*,1,32))
  if (d isin $2) set %a $remove(%a,$wildtok(%a,*day*,1,32))
  if (w isin $2) set %a $remove(%a,$wildtok(%a,*wk*,1,32))
  return %a
}
time2secs {
  ; 3w 6ds 5h 25ms 52s = 2352352
  ; 3wks 6days 5hrs 25mins 52secs = 2352352
  ; .long, 2yrs 2mons 3wks 6days 5hrs 25mins 52secs = 70680352
  var %a
  if ($regex($1-,([0-9]+)s)) inc %a $regml(1)
  if ($regex($1-,([0-9]+) $+ $iif($prop == long,mins?,m))) inc %a $calc($regml(1) * 60)
  if ($regex($1-,([0-9]+)h)) inc %a $calc($regml(1) * 3600)
  if ($regex($1-,([0-9]+)d)) inc %a $calc($regml(1) * 86400)
  if ($regex($1-,([0-9]+)w)) inc %a $calc($regml(1) * 604800)
  if ($prop == long) {
    if ($regex($1-,([0-9]+)mons?)) inc %a $calc($regml(1) * 2628000)
    if ($regex($1-,([0-9]+)yrs?)) inc %a $calc($regml(1) * 31536000)
  }
  return %a
}
trimall {
  var %a = 1, %b = $1
  tokenize 32 $2-
  while ($gettok($1-,%a,32) != $null) {
    var %q = 1
    while (%q <= $numtok($1-,32)) { set %b $trim(%b,$gettok($1-,%a,32)) | inc %q }
    inc %a
  }
  return %b
}
trim  return $triml($trimr($1,$iif($3,$3,$2)),$2)
trimr {
  var %a = 1, %b, %s = $1, %c = $iif($2,$2,")
  while ($mid(%c,%a,1) != $null) {
    set %b $mid(%c,%a,1)
    while ($len(%s)) {
      if ($right(%s,1) == %b)  set %s $left(%s,-1)
      else break
    }
    inc %a
  }
  return %s
}
triml {
  var %a = 1, %b, %s = $1, %c = $iif($2,$2,")
  while ($mid(%c,%a,1) != $null) {
    set %b $mid(%c,%a,1)
    while ($len(%s)) {
      if ($left(%s,1) == %b)  set %s $right(%s,-1)
      else break
    }
    inc %a
  }
  return %s
}
trimnonalpha  return $triml.nonalpha($trimr.nonalpha($1))
trimnonalphanum  return $triml.nonalphanum($trimr.nonalphanum($1))
trim  return $triml($trimr($1,$iif($3,$3,$2)),$2)
triml.nonalpha {
  var %s = $1-
  while ($len(%s)) {
    if ($stripalpha($left(%s,1)))  set %s $right(%s,-1)
    else   return %s
  } 
}
triml.nonalphanum {
  var %s = $1-
  while ($len(%s)) {
    if ($stripalphanum($left(%s,1)))  set %s $right(%s,-1)
    else   return %s
  } 
}
trimr.nonalpha {
  var %s = $1-
  while ($len(%s)) {
    if ($stripalpha($right(%s,1)))  set %s $left(%s,-1)
    else   return %s
  } 
}
trimr.nonalphanum {
  var %s = $1-
  while ($len(%s)) {
    if ($stripalphanum($right(%s,1)))  set %s $left(%s,-1)
    else   return %s
  } 
}

trncte return $mod($1,$2)
tab {
  if ($0 == 0) return  $iif($prop isnum,$chr($prop),$chr(9))
  var %a = 1, %b, %c
  while (%a <= $0) {
    set %c $ [ $+ [ %a ] ]
    if (%c)  set %b %b $+ %c $+ $iif($prop isnum,$chr($prop),$chr(9))
    inc %a
  }
  return $left(%b,-1)
}
_gettok {
  ;$_gettok(text,N,C,N,C,...)
  if ($0 < 3) {
    echo $colour(info) -a Invalid format: $ $+ _gettok
    halt
  }
  var %a = 2, %b, %c, %d = $1
  while (%a <= $0) {
    set %b $ [ $+ [ %a ] ]
    set %c $ [ $+ [ $calc(%a + 1) ] ]
    if (($remove(%b,-) isnum) && (%b > 0) && ($remove(%c,-) isnum) && (%c > 0)) set %d $gettok(%d,%b,%c)
    inc %a 2
  }
  return %d
}
_deltok {
  ;$_deltok(text,N,C,N,C,...)
  if ($0 < 3) {
    echo $colour(info) -a Invalid format: $ $+ _deltok
    halt
  }
  var %a = 2, %b, %c, %d = $1
  while (%a <= $0) {
    set %b $ [ $+ [ %a ] ]
    set %c $ [ $+ [ $calc(%a + 1) ] ]
    if (($remove(%b,-) isnum) && (%b > 0) && ($remove(%c,-) isnum) && (%c > 0)) set %d $deltok(%d,%b,%c)
    inc %a 2
  }
  return %d
}
sub {
  if (($1 isnum) && ($2 isnum)) return $calc($1 - $2)
  elseif (($1 isnum) && ($2 == $null)) return $1
  elseif (($1 == $null) && ($2 isnum)) return $calc(0 - $2)
  elseif (($1 == $null) && ($2 == $null)) return
  else iecho SUB Error, $1 and $2 are not numbers!
}
sum {
  var %a = 1, %b = 0
  while ($gettok($1-,%a,32) != $null) {
    set %b $pls(%b,$gettok($1-,%a,32))
    inc %a
  }
  return %b
}
avg {
  var %a = 1, %b = 0
  while ($gettok($1-,%a,32) != $null) {
    set %b $pls(%b,$gettok($1-,%a,32))
    inc %a
  }
  return $calc(%b / $0)
}
shorttext return $iif($len($2-) > $1, $left($2-,$1) $+ ..., $2-)
shownetinfopop {
  if ($nvar(collapse.ircN.status/network/networkinfo)) return $false

  if ($1 == server)  return $server
  if ($1 == noserver) return $iif(!$server,$true,$false)
  if ($1 == ircop)   return $iif(o isincs $usermode,$true)
  if ($1 == away) return $away
  if ($1 == ircd) return $curircd
  if ($1 == network) return $iif($curnet(noserver),$ifmatch)

  return $true
}
stripnonalpha return $regsubex($1-,/[^a-z]+/ig,)
stripnonnum return $regsubex($1-,/[^0-9\.]+/ig,)
stripnonalphanum return $regsubex($1-,/[^a-z0-9]+/ig,)
stripnonalphanumdec return $regsubex($1-,/[^a-z0-9.]+/ig,)
stripalpha return $regsubex($1-,/[a-z]+/ig,)
stripnum return $regsubex($1-,/[0-9\.]+/ig,)
stripalphanum return $regsubex($1-,/[a-z0-9]+/ig,)
stripalphanumdec return $regsubex($1-,/[a-z0-9.]+/ig,)
stripnonnickchars return $regsubex($1-,/[^a-z0-9\`\-\_\^\]\[]+/ig,)


split {
  var %a, %b
  if ($3 isnum) set %a $4-
  else set %a $3-
  set %b $remove($mid(%a,$pos(%a,$1,$iif($3 isnum,$3,1))),$1)
  if ($2 isin %b) return $remove($left(%b,$calc($pos(%b,$2,1) - 1)),$2)
  else return %b

}
insertstr {
  var %s1, %s2, %s, %pos 
  set %s1 $1
  set %s2 $2
  set %pos $int($3)
  if ((%pos !isnum) || (%pos < 0)) return %s1
  if (%pos == 0) return %s2 $+ %s1
  set %s $mid(%s1,1,%pos) $+ %s2 $+ $mid(%s1,$calc(%pos + 1))
  return %s
}
swlc return $window($1).x $window($1).y $window($1).w $window($1).h
toggled return $iif(($1 == on || $1 == $true),$style(1))
popcmode {
  ; <chan> <mode> <require> <text>
  if ($2 isincs $chanmodes) {
    var %s = 1
    if ($remove($3,-)) var %s = $popcmode.flags($1, $iif($prop == and,AND,OR), $3)
    return $style($iif($2 isincs $gettok($chan($1).mode, 1,32), $iif(%s,1, 3) , $iif(!%s, 2) )) $4-
  }
}
popcmode.flags {
  ;  '<CHAN> <AND|OR> <op hop voice normal umode;A>
  if ($me !ison $1) return $false
  if (!$istok(and or, $2, 32)) return $false
  var %a = 1, %b, %c, %n
  while ($gettok($3-,%a,32) != $null) {
    set %b $ifmatch
    if ($2 == AND) {
      if (%b == admin) {
        if ($ncid(chanmode_adminchar)) {
          if ($ncid(chanmode_adminchar) !isin $chan($1,$me).pnick) inc %c       
        }
      }
      if (%b == owner) {
        if ($ncid(chanmode_ownerchar)) {
          if ($ncid(chanmode_ownerchar) !isin $chan($1,$me).pnick) inc %c       
        }
      }
      if (%b == op) {
        if ($me !isop $1) inc %c
      }
      if (%b == hop) {
        if ($me !ishop $1) inc %c
      }
      if (%b == voice) {
        if ($me !isvoice $1) inc %c
      }
      if (%b == normal) {
        if ($me !isreg $1) inc %c
      }
      if (umode;* iswm %b) {
        if ($remove(%b,umode;) !isincs $usermode) inc %c
      }
    }
    else {
      if (%b == admin) && ($ncid(chanmode_adminchar) isin $nick($1,$me).pnick) set %c 1 
      if (%b == owner) && ($ncid(chanmode_ownerchar) isin $nick($1,$me).pnick) set %c 1 
      if (%b == op) && ($me isop $1) set %c 1
      if (%b == hop) && ($me ishop $1) set %c 1
      if (%b == voice)  && ($me isvoice $1) set %c 1
      if (%b == normal)  && ($me isreg $1) set %c 1
      if (umode;* iswm %b) && ($remove(%b,umode;) isincs $usermode) set %c 1
    }
    inc %a
  }
  if ($2 == and) return $iif(%c,$false,$true)
  return $iif(%c,$true,$false)
}
popumode.flags {
  ;  <AND|OR> <A>
  if (!$server) return
  if (!$istok(and or, $1, 32)) return $false
  var %a = 1, %b, %c, %n
  while ($gettok($2-,%a,32) != $null) {
    set %b $ifmatch
    if ($1 == AND) {
      if (%b !isincs $usermode) inc %c
    }
    else {
      if (%b isincs $usermode) set %c 1
    }
    inc %a
  }
  if ($1 == and) return $iif(%c,$false,$true)
  return $iif(%c,$true,$false)
}
_popup.sub {
  ; menu, setup, $1

  var %a
  if ($3 == begin) return $iif(($2 != setup && $1-2 != channel cmds),-)
  if ($3 isnum) {
    set %a $hfind(popups, $tab($1, $2, *), $3, w)
    if (%a)  return $eval($replace($gettok(%a,3-,9),_,$chr(32),~,$),2)  : .timer 1 0 $hget(popups,%a)
  }
  if ($3 == end) return $iif(($2 != setup && $2-3 != channel cmds),-)
}
_popup.tokenlist {
  ;$1, token list, 32, command 
  var %a
  if ($1 == begin) return -
  if ($1 isnum) {
    set %a $gettok($2,$1,$3) 
    if (%a)  return $iif($prop == num,$1 $+ .) $shorttext(35, %a) : $4- %a
  }
  if ($1 == end) return -
}
_popup.quitmsgs {
  if (!$isfile($sd(quits.txt))) return
  var %a
  if ($1 == begin) return -
  if ($1 isnum) {
    if ($1 > 15) return
    set %a $read($sd(quits.txt),$1)
    if (%a)  return $shorttext(35, $strip(%a)) :  $iif($2 == global,g) $+ quit %a
  }
  if ($1 == end) return -
}
_popup.authusers {
  var %a
  if ($1 == begin) return -
  if ($1 isnum) {
    if ($1 > 30) return
    set %a $hfind($nget, $tab(auth,*,passwd),$1,w)
    var %u = $gettok(%a,2,9)
    if (%u)  return $iif($iifelse($ncid(netauth.user),$me) == %u,$style(1)) $1 $+ . %u : ncid netauth.user %u
  }
  if ($1 == end) return -
}
_popup.recentserver {
  var %a
  if ($1 == begin) return -
  if ($1 isnum) {
    if ($1 > 30) return
    set %a $gettok($nvar(recentservers), $1, 44)

    if (%a)  return $1 $+ . $gettok(%a,1,9) $tab $gettok(%a,2,9)  $paren($gettok(%a,3,9)) : .timer 1 0 server $iif($server,-m) $gettok(%a,1,9) $gettok(%a,2,9)
  }
  if ($1 == end) return -
}
_popup.recentnetwork {
  var %a
  if ($1 == begin) return -
  if ($1 isnum) {
    if ($1 > 30) return
    set %a $gettok($nvar(recentnetworks), $1, 44)

    if (%a)  return $1 $+ . %a $tab   : .timer 1 0 server $iif($server,-m)  %a
  }
  if ($1 == end) return -
}
_popup.recentwhois {
  var %a
  if ($1 == begin) return -
  if ($1 isnum) {
    if ($1 > 30) return
    set %a $gettok($nget(recentwhois), $1, 44)

    if (%a)  return  $1 $+ .  %a : .timer 1 0 $iif($2,$2,whois) %a
  }
  if ($1 == end) return -
}
_popup.favoriteconnect {
  var %a
  if ($1 == begin) return -
  if ($1 isnum) {
    set %a $gettok($nvar(favoriteconnect), $1, 44)
    if (%a)   return $1 $+ . $gettok(%a,1,9)  $tab $gettok(%a,2,9) $paren($gettok(%a,3,9)) : .timer 1 0 server $iif($server,-m) $gettok(%a,1,9) $gettok(%a,2,9)
  }
  if ($1 == end) return -
}
_popup.favoritechannel {
  var %a
  if ($1 == begin) return -
  if ($1 isnum) { 
    set %a $readini($mircini,n, chanfolder, n $+ $calc($1 - 1))
    if (%a) {
      return $1 $+ . $gettok(%a,1,44) $tab $paren($rq($gettok(%a,-1,44))) : iecho .timer 1 1 _favjoin $gettok(%a,1,44) $rq($gettok(%a,-1,44))
    }
  }
  if ($1 == end) return -
}
_popup.networksserver {
  var %a
  if ($1 == begin) return -
  if ($1 isnum)  && ($1 <= 50) {
    set %a $nget(serverlist. $+ $calc($1 - 1))
    if (%a)   return $iif($gettok(%a,1,32) == $server,$style(3)) $1 $+ . $gettok(%a,1,32) :  .timer 1 0 server $gettok(%a,1,32) 
  }
  if ($1 == end) return -
}
_popup.chanhistory {
  var %a
  if ($1 == begin) return -
  if ($1 isnum) {
    if ($1 > 30) return
    if (!$ini($mircini,chanhist,0)) return
    set %a $readini($mircini,n,chanhist, n $+ $calc($1 - 1) )
    if (%a)   return  $1 $+ . $gettok(%a,1,44) $tab $paren($gettok(%a,2,44)) : iecho .timer 1 1 _favjoin $gettok(%a,1,44)  $gettok(%a,2,44)
  }
  if ($1 == end) return -
}
_popup.notify {
  if ($nvar(collapse.ircN.status/contacts/showonline) == on) return
  if ($1 isnum) {
    var %a =  $gettok($ncid(notify.online),$1,44)
    if ($ismod(userlist.mod)) {
      var %u = $usrh(%a $+ ! $+ $iifelse($notify(%a).addr,$ncid(notify. [ $+ [ %a ] $+ ] .addr)))
      if ($nvar(contacts.userlistmenuonly) == on) {
        if (%a) {
          if (%u) return %a $tab $iif(%u,$chr(10003),) :query %a
          else return -
        }
      }
    }
    if (%a) return %a $tab  $iif(%u,$chr(10003),) :query %a
  }
}
_popup.notify.lastseen {
  if ($nvar(collapse.ircN.status/contacts/showoffline) == on) return
  if ($1 isnum) {
    var %a = $gettok($ncid(notify.notonline),$1,44)
    if (%a) {
      var %b = $calc($ctime - $gettok($nget(notify. $+ %a $+ .lastseen),1,32))
      var %c = $rsc($trimdur(%b,$iif(%b > 60,s)))
      var %d = $nget(notify. $+ %a $+ .lastseen)
      if (!%d) return %a :!
      return %a $tab %c :iecho Notify: I last saw $u($hc(%a)) $paren($gettok(%d,2,32)) online $duration(%b) ago, on $sc($asctime($gettok(%d,1,32) )) $paren($ac(/whowas %a) for more information)
    }
  }
}
poptog {
  if (!$2) {
    if ($1) return $style(1)
  }
  else {
    if ($1 == $2) return $style(1)
  }
}
u return  $+ $1- $+ $iif($1,)
validchantype {
  if ($left($1,1) isin $chantypes) return $true
  else {
    if ($left($1,1) == $chr(35)) return $true
    else return $false
  }
}
vl if ($isid) return $chr(124)
wid2chan {
  var %s = 1
  while ($scon(%s) != $null) {
    var %a = 1
    scon %s
    while ($chan(%a) != $null) {
      if ($chan(%a).wid == $1) return $chan(%a) %s
      inc %a
    }

    inc %s
  }
  scon -r
}

whilearray {
  ; string 44 command identifier2useonresult
  ; ex:  $whilearray($nvar(modules), 44, iecho, strip) = loop thru $nvar(modules) perform " iecho $strip(result) " on them
  var %a = 1, %b
  while ($gettok($1 , %a, $2) != $null) {
    set %b $ifmatch

    if ($4) {
      var %m = $eval( $ $+ $4 $+ ( $+ %b $+ ) , 2)
      if ($prop == skipnull) && (%m == $null) { inc %a | continue }
      if (<match> isincs $3) $replace($3,<match>,%m)
      else $3 %m
    }
    else $3 %b
    inc %a
  } 
}
wwrap {
  if (($right($mid($3-,$1,$2),1) == $chr(32)) || ($right($mid($3-,$1,$calc($2 + 1)),1) == $chr(32)) || ($calc($1 + $2) > $len($3-))) {
    ncid wrap.pos $2
    return $replace($mid($3-,$1,$2), , )
  }
  ncid wrap.text $mid($3-,$1,$2)
  ncid wrap.text2 $ncid(wrap.text)
  ncid wrap.pos 1
  if ($chr(32) isin $ncid(wrap.text)) {
    while ($pos($ncid(wrap.text2),$chr(32)) > 1) {
      ncid -i wrap.pos $pos($ncid(wrap.text2),$chr(32))
      ncid wrap.text2 $mid($ncid(wrap.text2),$calc($pos($ncid(wrap.text2),$chr(32)) + 1),$calc($len($ncid(wrap.text) - 2) - $pos($ncid(wrap.text2),$chr(32))))
    }
  }
  elseif (  isin $ncid(wrap.text)) {
    while ($pos($ncid(wrap.text2), )) {
      ncid -i wrap.pos $pos($ncid(wrap.text2), )
      ncid wrap.text2 $mid($ncid(wrap.text2),$calc($pos($ncid(wrap.text2), ) + 1),$calc($len($ncid(wrap.text2)) - $pos($ncid(wrap.text2), )))
    }
  }
  else {
    ncid -r wrap.text2
    ncid wrap.pos $2
    return $replace($ncid(wrap.text), , )
  }
  ncid -r wrap.text2
  return $replace($left($ncid(wrap.text),$ncid(wrap.pos)), , )
}
;;;;; WORDS ARE WRAPPED ON WHITESPACE ONLY
;;;;; REGEX FOR COLOR
;;;;; REGEX number of match check for BOLD AND UNDERLINE
wwrap2 {
  var %a, %b, %c, %d, %x, %y, %s
  set %b 0
  set %s $iif($1 == 1,$3-,$right($3-,$calc(1 - $1)))

  set %a $regex($left($3-,$1),/(\d{1,2})/g)
  if (%a) set %c $base($regml($regml(0)),10,10,2)

  set %x $regex($left($3-,$1),/(\ )/g) 	 
  if (2 \\ %x) set %x bold

  set %y $regex($left($3-,$1),/()/g)
  if (2 \\ %y) set %y underline

  var %l $2
  set %b $len($3)
  set %a 1
  while ($pos(%s,$chr(32),%a)) {
    set %b $pos(%s,$chr(32),%a)
    set %d $pos($strip(%s),$chr(32),%a)
    if (($prop == bigwrap) && ($len($gettok(%s,1,32)) >= %l)) { break }
    if ($calc(%d - 1 + $len($gettok($strip(%s),$calc(%a + 1),32))) >= %l) { set %l %b | break }
    elseif (%d >= %l) { break }
    inc %a
  }

  ;;if (($right($mid($3-,$1,%l),1) == $chr(32)) || ($right($mid($3-,$1,$calc(%l + 1)),1) == $chr(32)) || ($calc($1 + %l) > $len($3-))) {
  ncid wrap2.pos %l
  return $iif(%c,$iif(%y == underline,) $+ $iif(%x == bold,\) $+  $+ %c) $+ $replace($mid($3-,$1,%l), , ) 	 
  ;;}
}
wwrap3 {
  ;;;;;;;;;;$1 start, $2 lenght, $3- string
  var %a, %b, %c, %x
  set %a 1
  while ($pos($3-,$chr(32),%a)) {
    set %b $ifmatch
    echo -a XXXXXX: %b
    inc %a
  }
  echo -a X: %x
}
wrpt {
  if ($len($1) < 4) return 0. $+ $str(0,$sub($len($1),1)) $+ $1 $+ s
  elseif ($mid($1,1,$sub($len($1),3)) < 60) return $mid($1,1,$sub($len($1),3)) $+ . $+ $right($1,3) $+ s
  else return $rsc($duration($mid($1,1,$sub($len($1),3))))
}
flagsold {
  var %a = 1, %b, %c, %d, %f, %q, %g, %t, %v
  while ($gettok($1,%a,32) != $null) {
    set %c $ifmatch
    if ((%d) && (-* !iswm %c)) { 
      set %f %f %c 
      set %d 
    }
    elseif (-* iswm %c) { set %f %f %c  | set %g $addtok(%g,$remove(%c,-),44) | set %d 1  }
    else { set %t $gettok($1, [ [ %a ] $+ ] -,32)  | break } 
    inc %a
  }
  set %v $iif($gettok(%f,$calc($findtok(%f,- $+ $2,1,32) + 1),32),$ifmatch)
  if ($prop == flags) return %g
  if ($prop == text) return %t
  if ($2 isin %g) {
    if ($prop == val) return %v
    return $true
  }
}
flags {
  ;$flags(string,item,[bolean flags])
  if ($hget([ [ $cid ] $+ ] .ircN.cid)) {
    hdel -w [ [ $cid ] $+ ] .ircN.cid *_quoteend
    hdel -w [ [ $cid ] $+ ] .ircN.cid *_quotestart
    hdel [ [ $cid ] $+ ] .ircN.cid flags
    hdel [ [ $cid ] $+ ] .ircN.cid text
  }
  if (($prop == text) && (-* !iswm $1)) return $1
  var %a = 1, %b, %c, %d
  while ($gettok($1,%a,32) != $null) {
    set %c $ifmatch
    if (%d) {
      if ("*" iswm %c) {
        ncid %d $+ _quotestart %a 
        ncid %d $+ _quoteend %a 
        set %d
      }
      elseif (($ncid(%d $+ _quotestart)) && ($right(%c,1) == ")) { ncid %d $+ _quoteend %a | set %d }
      elseif ($left(%c,1) == ") { ncid %d $+ _quotestart %a }
      elseif (!$ncid(%d $+ _quotestart)) { 
        ncid %d $+ _quotestart %a 
        ncid %d $+ _quoteend %a 
        set %d
      }
    }
    elseif ((-* iswm %c) && ($mid(%c,2,1) isalpha)) { 
      ncid flags $addtokcs($ncid(flags),$remove(%c,-),44) 
      if (!$istokcs($3,$remove(%c,-),32)) { set %d $remove(%c,-) } 
    }
    else { ncid text $gettok($1, [ [ %a ] $+ ] -,32) | break }
    inc %a
  }


  if ($prop == flags) {
    set %a $ncid(flags) 
    return %a 
  }
  if ($prop == text) { 
    set %a $ncid(text) 
    return %a 
  }
  if ($istokcs($ncid(flags),$2,44)) {
    if ($prop == val) {
      set %a $gettok($1,[ [ $ncid($2 $+ _quotestart) ] $+ ] - [ $+ [ $ncid($2 $+ _quoteend) ] ],32)
      if ($left(%a,1) == ") set %a $right(%a,-1)
      if ($right(%a,1) == ") set %a $left(%a,-1)
      return %a
    }
    return $true
  }
}
flag {
  var %f, %t
  if (-* iswm $1) { 
    set %f $right($gettok($1-,1,32),-1)
    set %t $gettok($1-,2-,32)
  }
  if ($prop == flags) return %f
  if ($prop == text) return %t
  if ($2 isincs %f) return $true
}
flags2 {
  var %a = 1, %b, %c, %d, %f, %q, %g, %t, %v
  while ($gettok($1,%a,32) != $null) {
    set %c $ifmatch
    if ((%d) && (-* !iswm %c)) { 
      set %f %f %c 
      if ($left(%c,1) == ") set %q 1
      if ((!%q) || ($right(%c,1) == ")) set %d
    }
    elseif (-* iswm %c) { set %f %f %c | set %g $addtok(%g,$remove(%c,-),44) | set %d 1 }
    else { set %t $gettok($1, [ [ %a ] $+ ] -,32)  | break } 
    inc %a
  }

  set %v $iif($gettok(%f,$calc($findtok(%f,- $+ $2,1,32) + 1),32),$ifmatch)
  if ($prop == flags) return %g
  if ($prop == text) return %t
  if ($2 isin %g) {
    if ($prop == val) return %v
    return $true
  }
}
fascbar {
  var %z, %y = $calc($remove($1,%) / 10)
  set %z $str($iif($2,$2,$sc($chr(124))),$calc(10 - (10 - $int(%y))))
  set %z %z $+ $str($iif($3,$3,$hc($chr(124))),$calc(10 - $int(%y)))
  return %z
}
networkuses {
  if ($isid) {
    var %a, %b
    set %b $nget(uses.firstdate)
    if ($asctime(%b,mm/dd/yyyy) == $asctime(mm/dd/yyyy)) set %a Today
    else {
      set %a $asctime(%b,mmm) $ord($asctime(%b,d))
      if ($asctime(yyyy) != $asctime(%b,yyyy)) set %a $asctime(%b,mm/dd/yyyy)
    }
    if ($1 == color) return $hc($iifelse($nget(uses),1)) time $+ $plural($nget(uses)) $iif(%b,since $sc(%a))
    return $iifelse($nget(uses),1) time $+ $plural($nget(uses)) $iif(%b,since %a)
  }
}
notifyison {
  if ($notify($1)) {
    if (($istok($notify($1).network,$curnet,44)) || ($notify($1).network == $null)) return $notify($1).ison
    return $false aaaa
  }
}
uascbar {
  var %z, %y = $calc($remove($1,%) / 10)
  set %z $str($iif($3,$3,$hc($chr(124))),$calc(10 - (10 - $int(%y))))
  set %z %z $+ $str($iif($2,$2,$sc($chr(124))),$calc(10 - $int(%y)))
  return %z
}
firstcap {
  if ($left($1,1) isupper) return $1-
  var %a = $upper($left($1-,1)) 
  var %b = $right($1-,-1)
  return %a $+ $iif($prop == firstonly, %b, $lower(%b))
}
firstcon {
  var %a = 1
  while ($scon(%a)) {
    if ($scon(%a).status == connected) return $scon(%a).cid
    inc %a
  }
}
_fade {
  var %b = $len($4), %a = $4
  if (%b >= 5) return $c($1 $+ $left(%a,2)) $+ $c($2 $+ $right($left(%a,-2),-2)) $+ $c($3 $+ $right(%a,2))
  elseif (%b == 4) return $c($1 $+ $left(%a,1)) $+ $c($2 $+ $right($left(%a,-1),-1)) $+ $c($3 $+ $right(%a,1))
  elseif (%b == 3) return $c($1 $+ $left(%a,1)) $+ $c($2 $+ $mid(%a,2,1)) $+ $c($3 $+ $right(%a,1))
  elseif (%b == 2) return $c($1 $+ $left(%a,1)) $+ $c($3 $+ $right(%a,1))
  else return $c($1 $+ %a)
}
fade {
  var %z, %a = 1, %b = $numtok($4-,32)
  while (%a <= %b) {
    set %z %z $_fade($1,$2,$3,$gettok($4-,%a,32))
    inc %a
  }
  return %z
}
pst {
  if (!$mopt(2,30)) return $1
  var %a = $iif($nick($2,$1),$nick($2,$1).pnick,$1)

  if ($nvar(colorprefix) == on) {

    if ($nvar(colorprefix.mode) == on) {
      if (@ isin %a) set %a $replace(%a,@, $+ $base($nxtget(CLineOP),10,10,2) $+ @)
      if (% isin %a) set %a $replace(%a,%, $+ $base($nxtget(CLineHOP),10,10,2) $+ % $+ )
      if (+ isin %a) set %a $replace(%a,+, $+ $base($nxtget(CLineVoice),10,10,2) $+ +)
    }
    else {
      if ($ismod(userlist)) {
        var %z = $usr($1)
        if (@ isin %a) {
          if ($chkflag(%z,$2,o)) set %a $replace(%a,@,$hc(@))
          elseif ($me isop $2) set %a $replace(%a,@,$ac(@))
          else set %a $replace(%a,@,$sc(@))
        }
        if (% isin %a) {
          if ($chkflag(%z,$2,h)) set %a $replace(%a,%,$hc(%))
          elseif ($me isop $2) set %a $replace(%a,%,$ac(%))
          else set %a $replace(%a,%,$sc(%))
        }
        if (+ isin %a) {
          if (($chkflag(%z,$2,v)) || ($chkflag(%z,$2,o))) set %a $replace(%a,+,$hc(+))
          else set %a $replace(%a,+,$sc(+))
        }
      }
    }
  }
  return %a
}
pst2 {
  if (!$mopt(2,30)) return
  if (!$nick($2,$1).pnick) return
  if ($nick($2,$1).pnick == $1) return
  else var %a = $left($pst($1,$2),$calc(0 - $len($1)))
  return %a
}

srvfile return $nd($curnet $+ .srv)
srvmapfile return $nd($curnet $+ .map)

modinfo {
  ; <file> [table] <item>
  if ($0 == 3) return $readini($qt($1), $2, $3)
  elseif ($0 == 2) return $readini($qt($1),module,$2) 
}
ismod return $istok($nvar(modules),$1 $+ $iif(*.mod !iswm $1,.mod),44)

isnumnotnull {



  ;checks if $1 isnum & isnt null. ex: $iif(%numberresult isnum,true,false)
  ;would not since 0 still passes isnum.. 

  ; ex: $iif(0 isnum) = $true .. $iif(1 isnum) = $true...
  ;but ex:  $isnumnotnull(1) $true. $isnumnotnull(0) false.. 

  ;usage: $isnumnotnull(<val>,[num range]) .. ex: $isnumnotnull(4,1-5)

  if ($1 != $null) {
    if ($remove($2,-) isnum) && (- isin $2) {

      if ($1 isnum $2) return $1
    }
    elseif ($1 isnum) {
      if ($1 == 0) return 
      return $1
    }
  }
}
_thminfo return $gettok($read($1, nw, * $+ $chr(59) $+ * $+ $2 $+ =*),2-,61)
ialget return $gettok($wildtok($ial($1).mark,$2 $+ =*,1,1),2-,61)
ialbytes return $calc($len($1) + $len($ial($1)) + $len($ial($1).mark))
ialclearglobal scon -a ialclear
ialtotalbytes {
  var %a = 1, %b, %c = 0
  while ($ial(*,%a) != $null) {
    set %b $ial(*,%a).nick
    inc %c $ialbytes(%b)
    inc %a
  }
  return %c
}
ialchantotalbytes {
  if ($1 !ischan) return 
  var %a = 1, %b, %c = 0
  while ($ialchan(*,$1,%a) != $null) {
    set %b $ialchan(*,$1,%a).nick
    inc %c $ialbytes(%b)
    inc %a
  }
  return %c
}
ialtotalglobalbytes { 
  var %a = 1, %b = 0
  while ($scon(%a) != $null) {
    scon %a
    inc %b $ialtotalbytes
    inc %a
  }
  scon -r 
  return %b
}
ialnum return $ial($iifelse($1,*),0)
ialglobalnum {
  var %a = 1, %b = 0
  while ($scon(%a) != $null) {
    scon %a
    inc %b $ialnum
    inc %a
  }
  scon -r 
  return %b
}
ialchannum if ($1 ischan) return $ialchan($iifelse($2,*),$1,0)
ialglobalnum { 
  var %a = 1, %b = 0
  while ($scon(%a) != $null) {
    scon %a
    inc %b $ial($iifelse($1,*@*),0)
    inc %a
  }
  scon -r 
  return %b
}
scripttype return $iif($ini($1,script),ini,$iif($gettok($1-,-1,46) == als,als,mrc))
loadstype return $iif($scripttype($1-) == als,-a,-rs)
lastactive {
  var %a = $1
  if (!%a) set %a $me
  if (!%a) return
  var %b = 1, %c, %d, %e
  if ($ncid($tab(query,%a,lastactive))) { var %q = $calc($ctime - $ifmatch) | set %d %q | set %e query } 
  if ($ncid($tab(dccchat,%a,lastactive))) { var %q = $calc($ctime - $ifmatch) | if (%q < %d) { set %d %q  | set %e dcc-chat } }
  while ($comchan(%a,%b) != $null) {
    set %c $ifmatch

    if ($ial(%a)) {
      ; q is time joined channel minus the time they're idle.. $nick(#,nick).idle sucks 
      ; might just make it store it in a ncid when they speak
      if ($changet(%c,lastjoin))  var %q = $calc(($ctime - $changet(%c,lastjoin)) - $nick(%c,%a).idle)
      if ($nick(%c,%a).idle < %d) || (!%d) { 
        if (%q) {
          if (%q < 600) { inc %b | continue }
        }
        set %d $nick(%c,%a).idle 
        set %e %c
      }
    }
    inc %b
  }
  return %d %e
}
lastidle {
  if (!$1) return

  var %ls = $gettok($lastactive($1),1,32)
  var %li = $cwiget($1,idle)
  return %li
  ; test
  if (%ls > %li) return %ls
  return %li
}
;;;
;;; ircN DIRS
;;;

;main tree
idir {
  set %dir $deltok($shortfn($nofile($mircexe)),-1,92) $+ \
  if ($isdir(%dir)) return %dir $+ $1-
  elseif ($nvar(dir)) return $nvar(dir) $+ $1-
  if ($hget(ircN)) nvar dir %dir
}

;sub folder in main tree
sys return $iif(!$0, $idir(system\), $qt($idir(system\ $+ $1-)))
res return $iif(!$0, $idir(resources\), $qt($idir(resources\ $+ $1-)))
resu return $iif(!$0, $usrdir(resources\), $qt($usrdir(resources\ $+ $1-)))
md {
  if ($isuserdir) && ($1-) {
    var %f = $qt($usrdir(modules\ $+ $1-))
    if ($isfile(%f))  return %f
  }
  return $iif(!$0, $idir(modules\), $qt($idir(modules\ $+ $1-)))
}
ld return $iif(!$0, $+($res,libraries\), $res(libraries\ $+ $1-))

themedir return $iif(!$0, $idir(themes\), $qt($idir(themes\ $+ $1-)))

;resources
sd {
  if ($isuserdir) return $iif(!$0, $+($resu,settings\), $resu(settings\ $+ $1-))
  return $iif(!$0, $+($res,settings\), $res(settings\ $+ $1-))
}
bkd {
  if ($isuserdir) return $iif(!$0, $+($resu,backups\), $resu(backups\ $+ $1-))
  return $iif(!$0, $+($res,backups\), $res(backups\ $+ $1-))
}
nd return $iif(!$0, $+($sd, network\), $sd(network\ $+ $1-))
txtd return $iif(!$0, $+($res,text), $res(text\ $+ $1- ))
bd {

  if ($isuserdir) {
    var %f = $qt($+($resu,bin\,$1-))
    return %f
  }
  return $iif(!$0, $+($res,bin\), $res(bin\ $+ $1-))
}
dd {
  if ($isuserdir) && ($1-) {
    var %f = $qt($+($resu,dlls\,$1-))
    if ($isfile(%f))  return %f
  }
  return $iif(!$0, $+($res,dlls\), $res(dlls\ $+ $1-))
}
hd return $iif(!$0, $+($res,help\), $res(help\ $+ $1-))
gfxdir  return $iif(!$0, $+($res,graphics\), $res(graphics\ $+ $1-))
icondir  return $iif(!$0, $+($res,graphics\icons\), $gfxdir(icons\ $+ $1-))
supdir  return $iif(!$0, $+($res,networksupport\), $res(networksupport\ $+ $1-))
netdir  return $iif(!$0, $+($supdir,network\), $supdir(network\ $+ $1-))
ircddir return $iif(!$0, $+($supdir,ircd\), $supdir(ircd\ $+ $1-))
td {
  if ($isuserdir)  return $iif(!$0, $+($resu,temp\), $resu(temp\ $+ $1-))
  return $iif(!$0, $+($res,temp\), $res(temp\ $+ $1-))
}
tp return $td($1-)
_nickcol {
  var %a = 1, %b, %col, %nomode
  while (%a <= $cnick(0)) {
    if ($cnick(%a).nomode) set %nomode $cnick(%a).color
    inc %a
  }

  if ($cnick($1)) set %b $cnick($1).color
  if ((%b) && (%b != %nomode)) set %col %b
  else set %col $iifelsenull($ialget($1,ulcol),$ialget($1,nickcol))
  return %col
}
_nickcol.randcolor {
  ;chan, nick, lastnick
  if ($1 !ischan) return
  var %defcols = 02 03 04 05 06 07 08 09 10 11 12 13 14 15

  var %bgcol = $base($color(background),10,10,2)
  if ($istok(%defcols,%bgcol,32)) set %defcols $remtok(%defcols,%bgcol,1,32)
  var %def = chancid $1 $tab(nickcol, availpool) %defcols
  if (!$chancid($1,$tab(nickcol,availpool))) %def
  var %loops 
  :top

  ;protect against slow/inf loop


  ; fix thsi so it has 'avail colors/ used colors' .. then it will have a smaller selection.. when avail is <2 unset it used 
  var %cols = $chancid($1,$tab(nickcol,availpool))
  if ($numtok(%cols,32) < 1) { %def | set %cols %defcols }

  var %r =  $base($gettok(%cols,$rand(1,$numtok(%cols,32)),32),10,10,2)
  ; if ($ialget($3,nickcol)) {
  ;   var %q = $ifmatch
  ;   if (%q == %r) goto top
  ; }
  set %cols $remtok(%cols, %r, 1, 32)
  chancid $1 $tab(nickcol, availpool) %cols
  return %r
}

; ################################################################
; ####################### IRCN SCRIPT FILE #######################
; ########## END OF FILE. DO NOT REMOVE OR MODIFY BELOW ##########
; ################################################################
