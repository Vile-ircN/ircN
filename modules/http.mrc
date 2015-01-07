alias http {
  if ($1 == $null) {
    iecho Syntax: /http -p [proxy] -h -c -f [headerfile] <URL> [destination file/dir]
    return
  }
  var %a, %isproxy, %proxyaddr, %proxyport, %url, %user, %pass, %host, %port, %file, %dest, %hide, %cmd, %headerfile


  set %a 1
  while ($sock($addtok(http,%a,46)) != $null) { inc %a }
  set %a $addtok(http,%a,46)


  if ($left($1,1) == -) {
    if (p isin $1) {
      set %isproxy $true
      if ($3 == $null) {
        iecho /http: No proxy entered!
        return
      }
      set %proxyaddr $gettok($3,1,58)
      if ($gettok($3,2,58) != $null) set %proxyport $ifmatch
      else set %proxyport 80
      tokenize 32 $1-2 $4-
    }
    if (h isin $1) set %hide $true
    if (c isin $1) {
      set %cmd $4-
      tokenize 32 $1-3
    }
    if ((%hide) && (%cmd == $null)) {
      iecho /http: Cannot hide dialog without specifying command
      return
    }
    tokenize 32 $2-
  }



  if ($1 == $null) {
    iecho /http: No URL specified!
    return
  }
  set %url $1
  if ($left(%url,7) != http://) {
    iecho /http: Invalid URL syntax!
    return
  }
  set %host $gettok(%url,2,47)
  if (@ isin %host) {
    set %user $gettok(%host,1,64)
    set %host $deltok(%host,1,64)
    if (: isin %user) {
      set %pass $gettok(%user,2,58)
      set %user $deltok(%user,2,58)
    }
  }
  if (: isin %host) {
    set %port $gettok(%host,2,58)
    set %host $deltok(%host,2,58)
  }
  if (%port !isnum) set %port 80
  set %file / $+ $gettok(%url,3-,47)
  if (($right(%url,1) == /) && (%file != /)) set %file %file $+ /
  if ($2 != $null) {
    if ($isdir($2)) set %dest $instok($2,$gettok(%file,-1,47),0,92)
    else set %dest $2
    goto gotfile
  }
  :getfile
  set %dest $sfile($addtok($getdir($iif($right(%file,1) == /,index.html,%file)),$iif($right(%file,1) == /,index.html,$gettok(%file,-1,47)),0),Save As...,Save)
  :gotfile
  if (%dest == $null) return
  if ("*" !iswm %dest) set %dest " $+ %dest $+ "
  if (($isfile(%dest)) && ($?!=" $+ $remove(%dest,") already exists. Overwrite?" == $false)) goto getfile
  write -c %dest
  if (%isproxy) sockopen %a %proxyaddr %proxyport
  else sockopen %a %host %port
  httpset %a isproxy %isproxy
  httpset %a url %url
  httpset %a user %user
  httpset %a pass %pass
  httpset %a host %host
  httpset %a port %port
  httpset %a file %file
  httpset %a dest %dest
  httpset %a hide %hide
  httpset %a cmd %cmd
  httpset %a numeric 0
  httpset %a state header
  httpset %a lastupdate 0
  if (%hide) return %a
  if ($dialog(%a)) dialog -k %a
  dialog -md %a ircN.http
  did -ra %a 2 %url
  did -ra %a 4 $replace($remove(%dest,"),$chr(32),$chr(160))
  did -ra %a 13 %host
  did -ra %a 11 $str(|,512)
  did -ra %a 11 $len($did(%a,11))
  return %a
}

alias http2 { 

  if ($1 == $null) {
    iecho Syntax: /http -p [proxy] -h -c [cmd] -f [headerfile]  -modifytime [time] -t [GET/POST] -d [post data]  <URL> [destination file/dir]
    return
  }

  var %a, %isproxy, %proxyaddr, %proxyport, %url, %user, %pass, %host, %port, %file, %dest, %hide, %nofollow, %cmd, %headerfile, %modifytime
  var %flg_h, %flg_p, %flg_c, %flg_f, %flg_t, %headeronly, %gettype, %postdata, %tgl = h H nofollow
  var %t = $flags($1-,_,%tgl).text


  if ($flags($1-,p,%tgl c)) {
    set %isproxy $true
    var %p = $flags($1-,p,%tgl c).val
    set %proxyaddr $gettok(%p,1,58)
    if ($gettok(%p,2,58) != $null) set %proxyport $ifmatch
    else set %proxyport 80
  }
  if ($flags($1-,h,H c t f d nofollow)) { set %hide $true } 
  if ($flags($1-,H, h c t f d nofollow)) { set %headeronly $true } 
  if ($flags($1-,nofollow,c t f d h H)) { set %nofollow $true } 
  if ($flags($1-,c,%tgl)) { set %cmd $flags($1-,c,%tgl).val } 
  if ($flags($1-,f,%tgl)) { set %headerfile $flags($1-,f,%tgl).val } 
  if ($flags($1-,t,%tgl)) { 
    var %gettype $flags($1-,t,h H).val 

    if (%gettype == POST) {
      var %postdata $flags($1-,d,%tgl).val   
      if (!%postdata) set %gettype GET 
    }

  } 
  if ($flags($1-,host,h H)) { var %tmphost $flags($1-,host,%tgl).val } 
  if ($flags($1-,modifytime,%tgl c)) { set %modifytime $flags($1-,modifytime,%tgl).val } 
  if ((%hide) && (%cmd == $null)) {
    iecho /http: Cannot hide dialog without specifying command
    return
  }


  tokenize 32 %t


  set %a 1
  while ($sock($addtok(http,%a,46)) != $null) { inc %a }
  set %a $addtok(http,%a,46)


  if ($1 == $null) {
    iecho /http: No URL specified!
    return
  }
  set %url $1
  if ($left(%url,7) != http://) {
    iecho /http: Invalid URL syntax!
    return
  }
  set %host $gettok(%url,2,47)
  if (@ isin %host) {
    set %user $gettok(%host,1,64)
    set %host $deltok(%host,1,64)
    if (: isin %user) {
      set %pass $gettok(%user,2,58)
      set %user $deltok(%user,2,58)
    }
  }
  if (: isin %host) {
    set %port $gettok(%host,2,58)
    set %host $deltok(%host,2,58)
  }
  if (%port !isnum) set %port 80

  set %file / $+ $gettok(%url,3-,47)



  if (($right(%url,1) == /) && (%file != /)) set %file %file $+ /
  if ($2 != $null) {
    if ($isdir($2)) set %dest $instok($2,$gettok(%file,-1,47),0,92)
    else set %dest $2
    goto gotfile
  }




  :getfile
  set %dest $sfile($addtok($getdir($iif($right(%file,1) == /,index.html,%file)),$iif($right(%file,1) == /,index.html,$gettok(%file,-1,47)),0),Save As...,Save)
  :gotfile
  if (%dest == $null) return
  if ("*" !iswm %dest) set %dest " $+ %dest $+ "
  if (($isfile(%dest)) && ($?!=" $+ $remove(%dest,") already exists. Overwrite?" == $false)) goto getfile
  write -c %dest
  if (%isproxy) sockopen %a %proxyaddr %proxyport
  else sockopen %a %host %port
  httpset %a isproxy %isproxy
  httpset %a url %url
  httpset %a user %user
  httpset %a pass %pass
  httpset %a host $iif(%tmphost,%tmphost,%host)
  httpset %a port %port
  httpset %a file %file
  httpset %a dest %dest
  httpset %a hide %hide
  httpset %a headeronly %headeronly
  httpset %a nofollow %nofollow
  httpset %a modifytime %modifytime
  httpset %a gettype %gettype
  httpset %a headerfile %headerfile
  httpset %a cmd %cmd
  httpset %a numeric 0
  httpset %a state header
  httpset %a lastupdate 0
  httpset %a postdata %postdata
  if (%hide) return %a
  if ($dialog(%a)) dialog -k %a
  dialog -md %a ircN.http
  did -ra %a 2 %url
  did -ra %a 4 $replace($remove(%dest,"),$chr(32),$chr(160))
  did -ra %a 13 %host
  did -ra %a 11 $str(|,512)
  did -ra %a 11 $len($did(%a,11))
  return %a
}
on 1:SOCKOPEN:http.*:{
  if ($httpvar($sockname,state) == error) return
  if ($sockerr) {
    if ($sockerr == 3) httperror $sockname refused
    if ($sockerr == 4) httperror $sockname nodns
    return
  }


  sockwrite -n $sockname $iif($httpvar($sockname,gettype),$httpvar($sockname,gettype),GET) $iif($httpvar($sockname,isproxy),$httpvar($sockname,url),$httpvar($sockname,file)) HTTP/1. $+ $iif($httpvar($sockname,gettype) == POST,1,0)

  sockwrite -n $sockname Host: $addtok($httpvar($sockname,host),$httpvar($sockname,port),58)
  sockwrite -n $sockname Accept: */*
  sockwrite -n $sockname User-Agent: $addtok(ircN,$gettok(%iver,2,32),47) [en] (Win $+ $os $+ ; U)
  var %z
  if ($httpvar($sockname,user)) {
    set %z $ifmatch
    if ($httpvar($sockname,pass)) set %z %z $+ : $+ $ifmatch
    sockwrite -n $sockname Authorization: Basic $encode(%z,m)
  }
  if ($httpvar($sockname,referer)) sockwrite -n $sockname Referer: $ifmatch
  if ($httpvar($sockname,modifytime)) {
    var %mt = $httpvar($sockname,modifytime)
    sockwrite -n $sockname If-Modified-Since: $iif(%mt isnum,$rtime(%mt),%mt)
  }
  if ($httpbuildcook($httpvar($sockname,host))) {
    sockwrite -n $sockname Cookie: $ifmatch

  }
  if ($httpvar($sockname,headerfile)) {
    if ($isfile($httpvar($sockname,headerfile))) { 
      bread $httpvar($sockname,headerfile) 0 $file($httpvar($sockname,headerfile)) &headread

      sockwrite $sockname &headread
    }
  }
  if ($httpvar($sockname,gettype) == POST) {
    var %pd = $httpvar($sockname,postdata)
    if (%pd) {
      sockwrite -n $sockname Content-Length: $iif($isfile($qt(%pd)), $file(%pd), $len(%pd))
    }
  }

  sockwrite -n $sockname
  if (%pd) {
    if ($isfile($qt(%pd))) {
      bread $qt(%pd) 0 $file($qt(%pd)) &postdata
      sockwrite $sockname &postdata

    }
    else sockwrite $sockname %pd


  }
  if ($httpvar($sockname,hide)) return
  if ($dialog($sockname))  did -ra $sockname 6 Host contacted, waiting for reply...
}
on 1:SOCKREAD:http.*:{
  var %z
  if ($sockerr > 0) {
    httperror $sockname reset
    return
  }
  if ($httpvar($sockname,state) == header) {
    sockread %z
    http.parseheader %z
  }
  elseif ($httpvar($sockname,state) == forward) {
    sockread %z
    http.parseforward %z
  }
  elseif ($httpvar($sockname,state) == error) {
    sockread %z
    return
  }
  elseif ($httpvar($sockname,state) == download) {
    sockread &z
    while ($sockbr) {
      bwrite $httpvar($sockname,dest) -1 $sockbr &z
      http.upd $sockname
      sockread &z
    }
  }
}
alias -l http.parseheader {
  var %z = $httpvar($sockname,numeric) 
  if ($1 == $null) {
    if ($httpvar($sockname,headeronly)) {
      if ($httpvar($sockname,cmd)) $ifmatch 0 $httpvar($sockname,dest)
      sockclose $sockname
      return
    }
    httpset $sockname state download
    httpset $sockname time $ticks
    httpset $sockname numeric 0
  }
  if (($1-) && ($httpvar($sockname,headeronly))) write $httpvar($sockname,dest) $1-

  if (($gettok($1,1,47) == HTTP) && ($2 isnum)) httpset $sockname numeric $2
  elseif (2?? iswm %z) {
    if ($1 == Content-length:) httpset $sockname length $2
    if ($1 == Set-Cookie:) httpsetcook $sockname $2-
  }
  elseif (3?? iswm %z) {
    if ($httpvar($sockname,nofollow)) {
      if ($httpvar($sockname,cmd)) $ifmatch %z $httpvar($sockname,dest) 
      sockclose $sockname 
      return
    }

    httpset $sockname state forward

  }
  elseif ((4?? iswm %z) || (5?? iswm %z)) httperror $sockname %z

}

alias -l httpsetcook {
  var %p = $wildtok($2-,path=*,1,32)
  var %d = $httpvar($1,host)
  writeini $sd(httpcookies.ini) %d $gettok($2,1,61) $gettok($2,2-,61)

}
alias -l httpgetcook return $readini($_sd(cookies.txt),n,$1)
alias httpbuildcook {

  var %a = 1, %b, %c, %line
  while (%a <= $ini($sd(httpcookies.ini),$1,0)) {
    var %b = $ini($sd(httpcookies.ini),$1, %a)
    var %c = $readini($sd(httpcookies.ini), n, $1, %b)
    set %line %line %b $+ = $+ %c 

    inc %a

  }
  return %line
}

alias -l http.parseforward {
  if ($1 == Location:) {
    var %p, %q, %r, %s, %t, %u, %v, %w, %x, %y, %z
    set %p $sockname
    set %q $sock(%p).ip
    set %r $sock(%p).port
    set %s $httpvar(%p,isproxy)
    set %t $httpvar(%p,url)
    set %u $httpvar(%p,user)
    set %v $httpvar(%p,pass)
    set %w $httpvar(%p,host)
    set %x $httpvar(%p,port)
    set %y $httpvar(%p,file)
    set %z $httpvar(%p,dest)
    sockclose %p
    set %w $gettok($2-,2,47)
    if (@ isin %w) {
      set %u $gettok(%w,1,64)
      set %w $deltok(%w,1,64)
      if (: isin %u) {
        set %v $gettok(%u,2,58)
        set %u $deltok(%u,2,58)
      }
    }
    if (: isin %w) {
      set %x $gettok(%w,2,58)
      set %w $deltok(%w,2,58)
    }
    if (%x !isnum) set %x 80
    set %y / $+ $gettok($2-,3-,47)
    if ($right($2-,1) == /) set %y %y $+ /
    if (%s) sockopen %p %q %r
    else sockopen %p %w %x
    httpset %p isproxy %s
    httpset %p url $2-
    httpset %p user %u
    httpset %p pass %v
    httpset %p host %w
    httpset %p port %x
    httpset %p file %y
    httpset %p dest %z
    httpset %p numeric 0
    httpset %p state header
    httpset %p referer %t
    httpset %p lastupdate 0
    halt
  }
}
on 1:SOCKCLOSE:http.*:{
  var %z = $sockname
  if ($httpvar(%z,state) == error) {
    http.resetsocket $sockname $sock($sockname).mark
    return
  }
  if ($httpvar(%z,gettype) != head) {
    if (($httpvar(%z,length)) && ($file($httpvar(%z,dest)).size < $httpvar(%z,length))) iecho Error in download of $httpvar(%z,url) $+ : file size does not match ( $+ $file($httpvar(%z,dest)).size vs $httpvar(%z,length) $+ ).
  }
  if ($httpvar(%z,cmd)) $ifmatch 0 $httpvar(%z,dest)
  if ($dialog(%z)) dialog -k %z
}
dialog ircN.httperror {
  title "ircN"
  option dbu
  size -1 -1 180 64
  icon 1, 6 6 32 32, c:\windows\system32\COMCTL32.DLL, 3
  text "", 2, 32 4 144 24
  text "", 3, 32 24 144 24
  button "OK", 4, 80 44 36 12, ok default
  text "", 5, 0 0 0 0, hide
}
on 1:DIALOG:http.*.error.*:*:*:{
  var %a = $gettok($dname,4,46), %z = $gettok($dname,1-2,46)
  if ($devent == init) {
    dialog -ov %z
    dialog -ov $dname
    did -ra $dname 5 $sock(%z).mark
    if (%a == refused) {
      did -ra $dname 2 There was no response. The server could be down or is not responding.
      did -ra $dname 3 If you are unable to connect again later, contact the server's administrator.
    }
    elseif (%a == reset) {
      did -ra $dname 2 ircN encountered an error:
      did -ra $dname 3 Read error (Connection reset by peer)
    }
    elseif (%a == nodns) {
      did -ra $dname 2 ircN is unable to locate the server $gettok($dname,5-,46) $+ .
      did -ra $dname 3 Please check the server name and try again.
    }
    elseif (%a == 400) {
      did -ra $dname 2 Error 400 - Bad Request
      did -ra $dname 3 The HTTP request sent by ircN was invalid. $+ $lf $+ Please contact the ircN Development Team.
    }
    elseif (%a == 401) {
      did -ra $dname 2 Error 401 - No Authorization
      did -ra $dname 3 The username and/or password you supplied was incorrect.
    }
    elseif (%a == 403) {
      did -ra $dname 2 Error 403 - Forbidden
      did -ra $dname 3 You are not authorized to access $httpvar(%z,file) on this server.
    }
    elseif (%a == 404) {
      did -ra $dname 2 Error 404 - File Not Found
      did -ra $dname 3 The file $httpvar(%z,file) could not be found on $httpvar(%z,host) $+ .
    }
    elseif (%a == 500) {
      did -ra $dname 2 Error 500 - Internal Server Error
      did -ra $dname 3 The server encountered an unexpected error. $+ $lf $+ Please try again later.
    }
    elseif (%a == 501) {
      did -ra $dname 2 Error 501 - Not Implemented
      did -ra $dname 3 The server lacks the functionality necessary to fulfill your request.
    }
    elseif (%a == 502) {
      did -ra $dname 2 Error 502 - Bad Gateway
      did -ra $dname 3 Your HTTP proxy encountered an invalid response.
    }
    elseif (%a == 503) {
      did -ra $dname 2 Error 503 - Service Unavailable
      did -ra $dname 3 The server was unable to fulfill your request.
    }
    else {
      did -ra $dname 2 Error %a - Unknown Error
      did -ra $dname 3 ircN did not recognize the reply received from the server. $+ $lf $+ Please contact the ircN Development Team.
    }
    sockclose %z
  }
  elseif (($devent == sclick) && ($did == 4)) {
    http.resetsocket %z $did(5)
    dialog -c %z
    return
  }
}
alias -l httperror {
  httpset $1 state error
  http.resetsocket $1 $sock($1).mark
  if ($httpvar($1,cmd)) $httpvar($1,cmd) $2 $httpvar($1,dest)
  if ($httpvar($1,hide)) {
    sockclose $1
    return
  }
  else .timer 1 0 return $!dialog( $addtok($1,$addtok(error,$addtok($2,$httpvar($1,host),46),46),46) ,ircN.httperror, $1 )
  halt
}
alias -l http.resetsocket {
  var %a
  sockclose $1
  set %a 1
  while (%a < 65535) { if ($portfree(%a)) break | inc %a }
  sockopen $1 127.0.0.1 %a
  sockmark $1 $2-
}
dialog ircN.http {
  title "Saving location"
  option dbu
  size -1 -1 160 80
  text "Location:", 1, 6 5 30 7
  text "", 2, 36 5 120 7
  text "Saving", 3, 6 15 30 7
  text "", 4, 36 15 120 7
  text "Status:", 5, 6 25 30 7
  text "Contacting host...", 6, 36 25 120 7
  text "Time Left:", 7, 6 35 30 7
  text "Unknown", 8, 36 35 120 7
  edit "", 9, 6 50 148 11, disabled
  text "", 10, 0 0 0 0, hide
  edit "", 11, 0 0 148 11, hide
  button "Cancel", 12, 63 65 35 11, cancel default
  button "", 13, 0 0 0 0, ok disabled hide
}
on 1:DIALOG:http.*:*:*:{
  if ($devent == sclick) {
    if ($did == 12) {
      ; .remove $httpvar($dname,dest)
      sockclose $dname
    }
  }
}
alias -l http.size {
  if (($1 isnum) && ($1 >= 0)) {
    if ($1 < 1024) return $1 bytes
    return $int($calc($1 / 1024)) $+ K
  }
}
alias -l http.speed {
  if (($1 isnum) && ($1 >= 0)) {
    if ($1 == 0) return stalled
    elseif ($1 < 1024) return $int($1) bytes/sec
    return $round($calc($1 / 1024),1) $+ K/sec
  }
}
alias -l http.upd {
  if ($httpvar($sockname,hide)) return
  if ($httpvar($sockname,lastupdate) == $ctime) return
  if (!$dialog($sockname)) return
  httpset $sockname lastupdate $ctime
  var %a, %b, %c, %d, %e, %f
  set %a $file($httpvar($sockname,dest)).size
  set %b $httpvar($1,length)
  set %d $httpvar($1,time)
  set %e $calc(%a / (($ticks - %d) / 1000))
  did -ra $1 6 $http.size(%a) $iif(%b,of) $http.size(%b) ( $+ $http.speed(%e) $+ )
  if (%b != $null) {
    set %f $int($calc((%a / %b) * 100))
    did -ra $1 10 %f $+ %
    set %c $round($calc((%b - %a) / %e),0)
    if (%c >= 86400) did -ra $1 8 $int($calc(%c / 86400)) $iif($int($calc(%c / 86400)) == 1,day,days) $+ , $asctime($calc(%c + ($gmt - $ctime)),HH:nn:ss)
    else did -ra $1 8 $asctime($calc(%c + ($gmt - $ctime)),HH:nn:ss)
    did -ra $1 9 $str(|,$int($calc($did($1,11) * %f / 100)))
  }
  else {
    did -ra $1 8 Unknown
    did -r $1 9,10
  }
}
alias -l httpset {
  var %z
  set %z $sock($1).mark
  if ($wildtok(%z,$addtok($2,*,61),1,127) != $null) set %z $remtok(%z,$ifmatch,1,127)
  if ($3 != $null) set %z $addtok(%z,$addtok($2,$3-,61),127)
  sockmark $1 %z
}
alias -l httpvar return $deltok($wildtok($sock($1).mark,$addtok($2,*,61),1,127),1,61)
