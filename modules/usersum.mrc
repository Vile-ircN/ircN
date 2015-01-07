;%%%%%%%%%%%%%%%%%%%%%%%%
;script ircN Usersum Script
;version 9.00
;author ircN Development Team
;email ircn@ircN.org
;url http://www.ircN.org
;%%%%%%%%%%%%%%%%%%%%%%%%

; Based on the usersum.tcl available for eggdrop bots.
; Includes two aliases:
; 1: usersum
; -  Use this alias by typing "/usersum" in ircN.
; 2: partyline.usersum
; -  Do NOT invoke this alias manually.  It is to be invoked by the ircN
;    partyline interface of the telnet daemon by typing ".usersum"
;    IF you are an owner.
;
; These aliases will freeze mIRC for a second or two while they calculate
; userlist statistics.  The larger your userlist, the longer the delay.

alias usersum {
  if (($lines($sd($nusr(ini))) == 0) || (!$exists($sd($nusr(ini))))) {
    iecho /usersum command requires at least one user in your userlist!
    return
  }
  window -ak @UserSum $getcenter(640,480) @UserSum $id(ircN.ico)
  clear @UserSum
  titlebar @UserSum -- Compiling a summary of the userlist, please wait...
  if ($hget(usersum)) hfree usersum
  hmake usersum 16
  var %a, %b, %c, %d, %e, %t, %u, %v, %w, %x, %y, %z
  var %_b, %_bn, %_d, %_f, %_j, %_k, %_m, %_n, %_o, %_p, %_r, %_v, %_x
  var %__bn, %__o, %__v, %__f, %__d, %__k
  dec %a $ticks
  set %b 1
  while ($usernum(%b) != $null) {
    set %z $ifmatch
    set %x $ulinfo(%z,flags)
    if (b isincs %x) inc %_b
    if (d isincs %x) inc %_d
    if (f isincs %x) inc %_f
    if (j isincs %x) inc %_j
    if (k isincs %x) inc %_k
    if (m isincs %x) inc %_m
    if (n isincs %x) inc %_n
    if (o isincs %x) inc %_o
    if (p isincs %x) inc %_p
    if (r isincs %x) inc %_r
    if (v isincs %x) inc %_v
    if (x isincs %x) inc %_x
    set %w $ulinfo(%z,chans)
    if (%w) {
      set %c 1
      while ($gettok(%w,%c,44)) {
        set %u $ifmatch
        set %v $ulinfo(%z,flags,%u)
        if ($findtok(%t,%u,1,44) != $null) set %u $ifmatch
        else {
          set %t $addtok(%t,%u,44)
          set %u $findtok(%t,%u,1,44)
          var %_ [ $+ [ %u ] $+ ] _d, %_ [ $+ [ %u ] $+ ] _f, %_ [ $+ [ %u ] $+ ] _k, %_ [ $+ [ %u ] $+ ] _o, %_ [ $+ [ %u ] $+ ] _v, %_ [ $+ [ %u ] $+ ] _bn
        }
        if (d isincs %v) inc %_ [ $+ [ %u ] $+ ] _d
        if (f isincs %v) inc %_ [ $+ [ %u ] $+ ] _f
        if (k isincs %v) inc %_ [ $+ [ %u ] $+ ] _k
        if (o isincs %v) inc %_ [ $+ [ %u ] $+ ] _o
        if (v isincs %v) inc %_ [ $+ [ %u ] $+ ] _v
        inc %c
      }
    }
    set %d 0
    if (($ulinfo(%z,pass) == $null) && (b !isincs %x)) {
      inc %d
      hadd usersum %d %z
    }
    inc %e
    inc %b
  }
  set %b 1
  while ($bannum(%b) != $null) {
    set %y $ifmatch
    set %z $blinfo(%y,ban)
    if (%z == $null) {
      echo @UserSum Removed invalid ban %b $+ : %y
      .remban %y
      continue
    }
    set %z $blinfo(%y,chans)
    if (%z == all) inc %_bn
    else {
      set %c 1
      while ($gettok(%z,%c,44)) {
        set %u $ifmatch
        if ($findtok(%t,%u,1,44) == $null) {
          set %t $addtok(%t,%u,44)
          set %u $findtok(%t,%u,1,44)
          var %_ [ $+ [ %u ] $+ ] _d, %_ [ $+ [ %u ] $+ ] _f, %_ [ $+ [ %u ] $+ ] _k, %_ [ $+ [ %u ] $+ ] _o, %_ [ $+ [ %u ] $+ ] _v, %_ [ $+ [ %u ] $+ ] _bn
        }
        else set %u $findtok(%t,%u,1,44)
        inc %_ [ $+ [ %u ] $+ ] _bn
        inc %c
      }
    }
    inc %b
  }
  inc %a $ticks
  titlebar @UserSum -- Completed in $rrpt(%a) seconds.
  echo @UserSum Stats compiled, displaying...
  echo @UserSum $hc(Totals:) $sc($num($ulist(*,20,0))) bans
  echo @UserSum $fix(2,-) Users: $fix(4,$sc($num(%e))) Hostmasks: $fix(4,$sc($num($ulist(*,40,0)))) Bots: $sc($num(%_b))
  echo @UserSum $hc(Global User Statistics) $+ : $sc($num(%_bn)) bans
  echo @UserSum - Owners: $fix(4,$sc($num(%_n))) Masters: $fix(7,$sc($num(%_m))) Remote: $sc($num(%_r))
  echo @UserSum $fix(2,-) Files: $fix(4,$sc($num(%_x))) Janitors: $fix(3,$sc($num(%_j))) Partyline: $sc($num(%_p))
  echo @UserSum $fix(4,-) Ops: $fix(4,$sc($num(%_o))) Voice: $fix(6,$sc($num(%_v))) Protected: $sc($num(%_f))
  echo @UserSum $fix(2,-) Deops: $fix(4,$sc($num(%_d))) Kicks: $sc($num(%_k))
  set %b 1
  while ($gettok(%t,%b,44) != $null) {
    set %__bn %_ [ $+ [ %b ] $+ ] _bn
    set %__o %_ [ $+ [ %b ] $+ ] _o
    set %__v %_ [ $+ [ %b ] $+ ] _v
    set %__f %_ [ $+ [ %b ] $+ ] _f
    set %__d %_ [ $+ [ %b ] $+ ] _d
    set %__k %_ [ $+ [ %b ] $+ ] _k
    echo @UserSum $hc($ifmatch) $hc(Channel Statistics:) $sc($num(%__bn)) bans
    echo @UserSum $fix(3,-) Ops: $fix(4,$sc($num(%__o))) Voice: $fix(4,$sc($num(%__v))) Protected: $sc($num(%__f))
    echo @UserSum - Deops: $fix(4,$sc($num(%__d))) Kicks: $sc($num(%__k))
    inc %b
  }
  echo -i2 @UserSum $hc(Users without passwords) $rbrk(%d $+ $o $+ ) $+ :
  set %z
  set %b 1
  while (1) {
    if (%b > %d) break
    while (($len(%z) < 768) && (%b <= %d)) {
      set %z %z $hget(usersum,%b)
      inc %b
    }
    echo -i2 @UserSum %z
    set %z
    inc %b
  }
  echo -i2 @UserSum $hc(All usernames) $rbrk(%e) $+ :
  set %z
  set %b 1
  while (1) {
    if ($usernum(%b) == $null) break
    while (($len(%z) < 768) && ($usernum(%b))) {
      set %z %z $usernum(%b)
      inc %b
    }
    echo -i2 @UserSum %z
    set %z
    inc %b
  }
  hfree usersum
}
alias partyline.usersum {
  if ($chkflag($gettok($1,2,46),*,n) == $false) return -1
  sockwrite -n $1 Compiling a summary of the userlist, please wait...
  if ($hget(usersum)) hfree usersum
  hmake usersum 16
  var %b, %c, %d, %e, %f, %t, %u, %v, %w, %x, %y, %z
  var %_b, %_d, %_f, %_j, %_k, %_m, %_n, %_o, %_p, %_r, %_v, %_x
  var %__bn, %__o, %__v, %__f, %__d, %__k
  set %b 1
  while ($usernum(%b) != $null) {
    set %z $ifmatch
    set %x $ulinfo(%z,flags)
    if (b isincs %x) inc %_b
    if (d isincs %x) inc %_d
    if (f isincs %x) inc %_f
    if (j isincs %x) inc %_j
    if (k isincs %x) inc %_k
    if (m isincs %x) inc %_m
    if (n isincs %x) inc %_n
    if (o isincs %x) inc %_o
    if (p isincs %x) inc %_p
    if (r isincs %x) inc %_r
    if (v isincs %x) inc %_v
    if (x isincs %x) inc %_x
    set %w $ulinfo(%z,chans)
    if (%w) {
      set %c 1
      while ($gettok(%w,%c,44)) {
        set %u $ifmatch
        set %v $ulinfo(%z,flags,%u)
        if ($findtok(%t,%u,1,44) == $null) {
          set %t $addtok(%t,%u,44)
          set %u $findtok(%t,%u,1,44)
          var %_ [ $+ [ %u ] $+ ] _d, %_ [ $+ [ %u ] $+ ] _f, %_ [ $+ [ %u ] $+ ] _k, %_ [ $+ [ %u ] $+ ] _o, %_ [ $+ [ %u ] $+ ] _v, %_ [ $+ [ %u ] $+ ] _bn
        }
        else set %u $findtok(%t,%u,1,44)
        if (d isincs %v) inc %_ [ $+ [ %u ] $+ ] _d
        if (f isincs %v) inc %_ [ $+ [ %u ] $+ ] _f
        if (k isincs %v) inc %_ [ $+ [ %u ] $+ ] _k
        if (o isincs %v) inc %_ [ $+ [ %u ] $+ ] _o
        if (v isincs %v) inc %_ [ $+ [ %u ] $+ ] _v
        inc %c
      }
    }
    if (($ulinfo(%z,pass) == $null) && (b !isincs %x)) {
      inc %d
      hadd usersum %d %z
    }
    inc %e
    inc %b
  }
  set %b 1
  while ($bannum(%b) != $null) {
    set %y $ifmatch
    set %z $blinfo(%y,ban)
    if (%z == $null) {
      sockwrite -n $1 Removed invalid ban %b $+ : %y
      .remban %y
      continue
    }
    set %z $blinfo(%y,chans)
    if (%z == all) inc %f
    else {
      set %c 1
      while ($gettok(%z,%c,44)) {
        set %u $ifmatch
        if ($findtok(%t,%u,1,44) == $null) {
          set %t $addtok(%t,%u,44)
          set %u $findtok(%t,%u,1,44)
          var %_ [ $+ [ %u ] $+ ] _d, %_ [ $+ [ %u ] $+ ] _f, %_ [ $+ [ %u ] $+ ] _k, %_ [ $+ [ %u ] $+ ] _o, %_ [ $+ [ %u ] $+ ] _v, %_ [ $+ [ %u ] $+ ] _bn
        }
        else set %u $findtok(%t,%u,1,44)
        inc %_ [ $+ [ %u ] $+ ] _bn
        inc %c
      }
    }
    inc %b
  }
  sockwrite -n $1 Stats compiled, displaying...
  sockwrite -n $1 Totals: $num($ulist(*,20,0)) bans
  sockwrite -n $1 $fix(2,-) Users: $fix(4,$num(%e)) Hostmasks: $fix(4,$num($ulist(*,40,0))) Bots: $num(%_b)
  sockwrite -n $1 Global User Statistics: $num(%f) bans
  sockwrite -n $1 - Owners: $fix(4,$num(%_n)) Masters: $fix(7,$num(%_m)) Remote: $num(%_r)
  sockwrite -n $1 $fix(2,-) Files: $fix(4,$num(%_x)) Janitors: $fix(3,$num(%_j)) Partyline: $num(%_p)
  sockwrite -n $1 $fix(4,-) Ops: $fix(4,$num(%_o)) Voice: $fix(6,$num(%_v)) Protected: $num(%_f)
  sockwrite -n $1 $fix(2,-) Deops: $fix(4,$num(%_d)) Kicks: $num(%_k)
  set %b 1
  while ($gettok(%t,%b,44) != $null) {
    set %__bn %_ [ $+ [ %b ] $+ ] _bn
    set %__o %_ [ $+ [ %b ] $+ ] _o
    set %__v %_ [ $+ [ %b ] $+ ] _v
    set %__f %_ [ $+ [ %b ] $+ ] _f
    set %__d %_ [ $+ [ %b ] $+ ] _d
    set %__k %_ [ $+ [ %b ] $+ ] _k
    sockwrite -n $1 $ifmatch Channel Statistics: $num(%__bn) bans
    sockwrite -n $1 $fix(3,-) Ops: $fix(4,$num(%__o)) Voice: $fix(4,$num(%__v)) Protected: $num(%__f)
    sockwrite -n $1 - Deops: $fix(4,$num(%__d)) Kicks: $num(%__k)
    inc %b
  }
  sockwrite -n $1 Users without passwords ( $+ %d $+ ) $+ :
  set %z
  set %b 1
  while (1) {
    if (%b > %d) break
    while (($len(%z) < 768) && (%b <= %d)) {
      set %z %z $hget(usersum,%b)
      inc %b
    }
    sockwrite -n $1 %z
    set %z
    inc %b
  }
  sockwrite -n $1 All usernames ( $+ %e $+ ):
  set %z
  set %b 1
  while (1) {
    if ($usernum(%b) == $null) break
    while (($len(%z) < 768) && ($usernum(%b))) {
      set %z %z $usernum(%b)
      inc %b
    }
    sockwrite -n $1 %z
    set %z
    inc %b
  }
  hfree usersum
  return 1
}
alias -l num return $iif($1 isnum,$1,0)
