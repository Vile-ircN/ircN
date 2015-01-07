
alias hlist {
  if (!$1) { ntmp hlist* }
  .timerhlist off
  if ($hget($1)) {
    ntmp hlist $1
    window -lesk @hlist "courier new" 12
    clear @hlist
    var %a,%b
    if (* isin $2) {
      set %a 1
      while (%a <= $hfind($1,$2,0,w)) {
        aline -l @hlist $fix2(20,$hfind($1,$2,%a,w)) = $hget($1,$hfind($1,$2,%a,w))
        inc %a
      }
      iline -l @hlist 1 $fix2(20,Found $hfind($1,$2,0,w) Results) dclick to go up, rclick to refresh
      ntmp hlist.num $hfind($1,$2,0,w)
      .timerhlist -o 0 2 _hlist.update
    }
    else {
      set %a 1
      set %b $1
      while (%a <= $hget(%b,0).item) {
        aline -l @hlist $fix2(20,$hc($hget(%b,%a).item)) $hget(%b,$hget(%b,%a).item)
        inc %a
      }
      iline -l @hlist 1 $fix2(20,Found $hget(%b,0).item Results) dclick to go up, rclick to refresh
      ntmp hlist.num $hget(%b,0).item
      .timerhlist -o 0 2 _hlist.update
    }
  }
  else {
    window -leisk @hlist $qt($window(1).font) $window(1).fontsize
    clear @hlist
    var %a = 1
    while ($hget(%a) != $null) {
      aline -l @hlist $fix2(20,$hc($hget(%a))) $chr(160) $hget(%a,0).item $+ / $+ $hget(%a).size
      inc %a
    }
    ntmp hlist.num $hget(0)
    .timerhlist -o 0 2 _hlist.update
  }
}
on *:UNLOAD:.timerhlist off
on *:INPUT:@hlist:{
  hlist $ntmp(hlist)
}
menu @hlist {
  lbclick {
    var %a = $gettok($strip($sline(@hlist,1)),1,160)
    if (Found * Results* iswm %a) { hlist | return }
    if ($ntmp(hlist)) { 
      var %c = $remove($gettok($strip($sline(@hlist,1)),-1,160),$chr(160))
      editbox -p @hlist /hadd $ntmp(hlist) %a $hget($ntmp(hlist),%a)

    }
    ;elseif ($hget(%a)) hlist %a
  }
  dclick {
    var %a = $gettok($strip($sline(@hlist,1)),1,160)
    if (Found * Results* iswm %a) { hlist | return }
    if ($ntmp(hlist)) { 
      var %c = $remove($gettok($strip($sline(@hlist,1)),-1,160),$chr(160))
      .timer 1 0 $chr(123) var % $+ b = $ $+ input(Set [ %a ] to new value:,e,Set new value, %c ) $chr(124) if (% $+ b) $chr(123) hadd $ntmp(hlist) %a % $+ b $chr(124) hlist $ntmp(hlist)  $chr(125) $chr(125)
    }
    elseif ($hget(%a))  hlist %a
  }
  rclick {
    hlist $ntmp(hlist)
  }
}
alias _hlist.update {
  if (!$window(@hlist)) { .timerhlist off | ntmp hlist* | return }
  if ($ntmp(hlist)) {
    if (($hget($ntmp(hlist),0).item > $ntmp(hlist.num)) || ($hget($ntmp(hlist),0).item < $ntmp(hlist.num)) || ($ntmp(hlist.num) == $null)) {
      ntmp hlist.num $hget($ntmp(hlist),0).item 
      hlist $ntmp(hlist)
    }
  }
  elseif (($hget(0) > $ntmp(hlist.num)) || ($hget(0) < $ntmp(hlist.num)) || ($ntmp(hlist.num) == $null)) { ntmp hlist.num $hget(0) | hlist }
}
