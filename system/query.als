chat dcc chat $$1
clist {
  if ($1 != $null) ctcp $1 CDCC LIST
  elseif (($query($active) !isnum) || ($chan($active) !isnum)) ctcp $active CDCC LIST
  else iecho Syntax: /clist [nick|chan]
}
cget {
  if ($2 != $null) {
    ctcp $1 CDCC SEND #$2
  }
  elseif ((($query($active) !isnum) || ($chan($active) !isnum)) && ($1 != $null)) ctcp $active CDCC SEND #$1
  else iecho Syntax: /cget [nick|chan] <pack>
}
q query $1-
send dcc send $$1 $2-
ver {
  if ($isid) return $version
  if ($1 != $null) ctcp $1 VERSION
  elseif (($query($active) !isnum) || ($chan($active) !isnum)) ctcp $active VERSION
  else iecho Syntax: /ver [nick|chan]
}
ping {
  if ($window($active).type == status) quote PING $1-
  elseif ($1 != $null) ctcp $1 PING
  elseif (($query($active) !isnum) || ($chan($active) !isnum)) ctcp $active PING
  else iecho Syntax: /ping <nick|chan>
}
sping {
  ncid slagtmp on
  ncid slag $ticks
  .quote time $1-
}
www url $$1-
wii iwhois $1-
wi whois $1-
w whois $1-
ww whowas $1-
cwi cwhois $1-
iwhois  whois $1 $1
whois {
  if (!$server) return
  ncid whois $addtok($ncid(whois),$1,44)
  _recentwhois $1

  .quote whois $1- $iif($nvar(alwaysidlewhois),$1-)

  set -nu0 %::nick $1
  if ($0)  .signal -n ircN_hook_cmd_whois %::nick
  unset %::nick

}
qwhois {
  if (!$server) return
  ncid quietwhois $addtok($ncid(quietwhois),$1,44)
  .quote whois $1- $1-
}
whowas {
  if ((!$0) || (!$server)) { theme.syntax /whowas [-Num] <nick> | theme.syntax Whowas will only echo the first match. Use /whowas <-Num> <nick> to specify how many results are returned. Ex: /whowas -10 $me $paren(Maximum of 10 results)  | return }
  if ($regex($1,-([0-9]*))) var %n = $iif($regml(1) > 1,$regml(1))
  if ($left($1,1) == -) tokenize 32 $2-

  ncid whowas $addtok($ncid(whowas),$1,44)
  _recentwhois $1
  ncid -r whowas.inc. $+ $1 $+ , $+ whowas.maxnum. $+ $1
  if (%n)  ncid whowas.maxnum. $+ $1 %n 

  .quote whowas $1-
}
xget {
  if ($2 != $null) {
    ctcp $1 XDCC SEND #$2
  }
  elseif ((($query($active) !isnum) || ($chan($active) !isnum)) && ($1 != $null)) ctcp $active XDCC SEND #$1
  else iecho Syntax: /xget [nick|chan] <pack>
}
xlist {
  var %a = 1
  if ($1 != $null) {
    while ($gettok($1-,%a,32)) {
      putserv PRIVMSG $v1 :XDCC LIST
      inc %a
    }
  }
  elseif (($query($active) !isnum) || ($chan($active) !isnum)) ctcp $active XDCC LIST
  else iecho Syntax: /xlist [nick|chan]
}

; ################################################################
; ####################### IRCN SCRIPT FILE #######################
; ########## END OF FILE. DO NOT REMOVE OR MODIFY BELOW ##########
; ################################################################
