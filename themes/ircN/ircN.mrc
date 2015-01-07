alias _ircn.no.timestamp {
  if ($gettok(%:echo,1,32) == echo) set -u1 %:echo $puttok(%:echo,$remove($gettok(%:echo,3,32),t),3,32)
}
alias _ircn.whois {
  _ircn.no.timestamp
  %:echo  _______________ $+ %::c3 $+ _______________ $+ %::c2 $+ _______________
  %:echo $|  $+ %::c2 $+ $b(%::nick) $+  $u($chr(40)) $+ $replace(%::address,@, $+ %::c3 $+ @) $+ $u($chr(41))
  %:echo $|  $+ %::c3 $+ name  $+ %::c2 $+ : %::realname
  if (%::isregd == is) %:echo $|  $+ %::c3 $+ auth  $+ %::c2 $+ : %::nick is a registered nickname
  if (%::operline) { %:echo $|  $+ %::c3 $+ oper  $+ %::c2 $+ : %::operline }
  if (%::chan) %:echo $|  $+ %::c3 $+ chan  $+ %::c2 $+ : %::chan
  if (%::wserver) %:echo $|  $+ %::c3 $+ serv  $+ %::c2 $+ : %::wserver %::serverinfo
  if (%::away) %:echo $|  $+ %::c3 $+ away  $+ %::c2 $+ : %::away
  if (%::idletime) { %:echo $|  $+ %::c3 $+ idle  $+ %::c2 $+ : $duration(%::idletime) $+ , signed on $duration($calc($ctime - $ctime(%::signontime))) ago }
  if (%::usermodes) %:echo $|  $+ %::c3 $+ umodes  $+ %::c2 $+ : %nick %::usermodes
  if (%::realhost) %:echo $|  $+ %::c3 $+ host  $+ %::c2 $+ : $gettok(%::realhost,1,32)
  if (%::ssl) %:echo $|  $+ %::c3 $+ SSL   $+ %::c2 $+ : %::ssl
  %:echo  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ $+ %::c3 $+ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ $+ %::c2 $+ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
}
alias _ircn.whowas {
  _ircn.no.timestamp
  %:echo  _______________ $+ %::c3 $+ _______________ $+ %::c2 $+ _______________
  if (%::address) %:echo $| %::nick $+ $replace(%::address,@, $+ %::c3 $+ @) $+ $u($chr(41)) was
  else %:echo $| %::nick was
  if (%::name) %:echo $|  $+ %::c3 $+ name  $+ %::c2 $+ : %::realname
  if (%::wserver) %:echo $|  $+ %::c3 $+ server  $+ %::c2 $+ : %::wserver
  if (%::serverinfo) %:echo $|  $+ %::c3 $+ quit $asctime($ctime(%::serverinfo),dddd $chr(44) mmm dd yyyy $chr(44) HH:nn:ss)
  %:echo  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ $+ %::c3 $+ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ $+ %::c2 $+ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
}
alias _ircn.names1 {
  var %w = $+(@mts.ircn.names.,$cid,.,%::chan)
  if (!$window(%w)) window -shl %w
  var %i = $numtok(%::text,32)
  while (%i > 1) {
    aline %w $gettok(%::text,%i,32)
    dec %i
  }
}
alias _ircn.names2 {
  var %w = $+(@mts.ircn.names.,$cid,.,%::chan)
  if (!$window(%w)) return
  _ircn.no.timestamp
  var %i = 1, %line, %x = $line(%w,0)
  var %perline = 4
  
  %:echo   $+ %::c1 $+ . $+ $str($str(-,15) $+ .,%perline)
  while (%i <= %x) {
    %line = $addtok(%line,$gettok($line(%w,%i),1,33),32)
    if (($numtok(%line,32) == %perline) || (%i == %x)) {
      %line = $replace(%line,@, $+ %::c3 $+ @ $+ %::c1,+, $+ %::c2 $+ + $+ %::c1)
      %:echo   $+ %::c1 $+ $vl $_ircn.fix(13,$_ircn.nll($gettok(%line,1,32)))  $+ %::c1 $+ $vl $_ircn.fix(13,$_ircn.nll($gettok(%line,2,32)))  $+ %::c1 $+ $vl $_ircn.fix(13,$_ircn.nll($gettok(%line,3,32)))  $+ %::c1 $+ $vl $_ircn.fix(13,$_ircn.nll($gettok(%line,4,32)))  $+ %::c1 $+ $vl
      set %line
    }
    
    inc %i 1
  }
  %:echo   $+ %::c1 $+ ' $+ $str($str(-,15) $+ ',%perline)
  window -c %w
}
alias _ircn.topic1 {
  _ircn.no.timestamp
  %:echo   $+ %::c1 $+ . $+ $str(-,63) $+ .
  %:echo  $+ %::c1 $chr(124)  $+ %::c2 $+ Topic $+ %::c1 $+ : %::text
}
alias _ircn.topic2 {
  _ircn.no.timestamp
  var %b = ddd, mmm dd yyyy
  %:echo  $+ %::c1 $vl  $+ %::c2 $+ SetBy $+ %::c1 $+ :  $+ %::c3 $+ %::nick $+  $_ircn.lfix($calc(57 - $len(%::nick)), $+ %::c1 $+ $asctime($ctime(%::text),%b) at $asctime($ctime(%::text),h:nntt))
  %:echo   $+ %::c1 $+ ' $+ $str(-,63) $+ '
}
alias _ircn.fix {
  var %z
  if ($2- != $null) set %z $2-
  set %z %z $+ $str( ,$calc($1 - $len($strip(%z))))
  return $replace(%z,,)
}
alias _ircn.lfix {
  var %z
  if ($2- != $null) set %z $2-
  set %z $str( ,$calc($1 - $len($strip(%z)))) $+ %z
  return $replace(%z,,)
}
alias _ircn.nll {
  if ($1 != $null) return $1
  else return 
}
