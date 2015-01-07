on *:START:install
alias install {

  if (!$hget(ircN)) hmake ircN 100
  echo -a 01[12N01] Installing ircN 9.00 $+ ...
  if (!$isfile($quo($scriptdir $+ settings.als))) {
    echo -a 01[12N01] ERROR: settings.als and the other ircN script files need to be in the $quo($scriptdir) folder
    goto end
  }
  if ($version < 6.35) {
    echo -a 01[12N01] ERROR: %lver requires mIRC 6.35 and up.
    goto end
  }

  set -u %install $true

  .load -a $quo($scriptdir $+ settings.als)

  default.setup
  newircnset 
  if ($server) nload
  nxt_firststart

  .timer 1 1 if ( $+ $+($chr(36),isfile,$chr(40),$chr(36),md,$chr(40),classicui.mod,$chr(41),$chr(41)) $+ ) $chr(123) .module classicui $| .timer 1 0 dlg ircn.wizard $chr(125)

  .timer 1 1 if ( $+ $+($chr(36),isfile,$chr(40),$chr(36),md,$chr(40),userlist.mod,$chr(41),$chr(41)) $+ ) $chr(123) .module userlist $chr(125)

  .timer 1 1 if ( $+ $+($chr(36),isfile,$chr(40),$chr(36),md,$chr(40),services.mod,$chr(41),$chr(41)) $+ ) $chr(123) .module services $chr(125)

   .timer 1 1 _ircnevents_onstart

   .timer 1 2 ircnsave

  :end

  .unload -rs $quo($script)
}

alias -l cc2txt return $replace($1-,,<c>,,<b>,,<u>,,<o>,,<r>)
alias -l txt2cc return $replace($1-,<c>,,<b>,,<u>,,<o>,,<r>,)
alias -l nvar {
  if ($isid) return $txt2cc($hget(ircN,$1))
  if ($2-) hadd ircN $1 $cc2txt($2-)
  elseif ($1) hdel ircN $1
}
alias -l quo if ($1-) return " $+ $1- $+ "


; ################################################################
; ####################### IRCN SCRIPT FILE #######################
; ########## END OF FILE. DO NOT REMOVE OR MODIFY BELOW ##########
; ################################################################
