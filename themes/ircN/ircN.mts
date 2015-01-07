[mts]
Name ircN Default
Author ircN Development Team
EMail zkx@ircN.org
Website http://www.ircN.org
Description ircN default theme with multiple schemes
Version 1.00
MTSVersion 1.1
Script ircN.mrc
 
Timestamp ON
TimestampFormat [hh:nntt]

Colors 15,06,01,05,02,02,03,10,04,12,03,01,05,02,06,01,10,04,03,12,01,15,01,15,01,14,14,15,15,01
RGBColors 255,255,255 0,0,0 0,0,127 0,147,0 255,0,0 127,0,0 156,0,156 252,127,0 255,255,0 0,252,0 0,147,147 0,255,255 0,0,252 255,0,255 127,127,127 210,210,210

;Text color, Nickname color, Text highlight color, Bracket color
;BaseColors 01,04,14,12
BaseColors 01,14,12,04


FontDefault Courier New,12
FontQuery Courier New,12
FontChan Courier New,12

CLineOwner 03
CLineOP 12
CLineHOP 02
CLineVoice 06
CLineRegular 01
CLineEnemy 04
CLineMe 07
CLineIrcOp 11

Prefix <c1>[<c3>N<c1>]
ParenText (<text>)

TextQuery !script %:echo < $+ %::nick $+ > %::text
TextQuerySelf !script %:echo < $+ %::me $+ > %::text
TextChan !script %:echo < $+ %::c2 $+ %::cmode $+  $+ %::nick $+ > %::text
TextChanSelf !script %:echo < $+ %::c2 $+ %::cmode $+  $+ %::nick $+ > %::text
ActionChan * <nick> <text>
ActionChanSelf * <me> <text>
NoticeChan -<nick>:<chan>- <text>
Notice -<nick>- <text>
NoticeServer <c2>-<c3><nick><c2>- <text>
WallOP <c2>-<c3><nick><c2>- <text>

Join *** <nick> (<address>) has joined <chan>
JoinSelf *** <me> has joined <chan>
Part *** <nick> (<address>) has left <chan> <parentext>
Quit *** <nick> (<address>) has left IRC <parentext>
Topic * <nick> changes topic to '<text>'
Kick <knick> was kicked by <nick> <parentext>
KickSelf You were kicked by <nick> <parentext>
Mode * <nick> sets mode: <modes>
Invite *** <nick> (<address>) invites you to join <chan>
Nick * <nick> is now known as <newnick>
NickSelf * <nick> is now known as <newnick>


Whois !script _ircn.whois
Whowas !script _ircn.whowas

CtcpSelf !script %:echo %::pre  $+ %::c2 $+ - $+ > [[ $+  $+ %::c2 $+ ctcp $+ ( $+  $+ %::c3 $+ %::target $+  $+ )] $upper($gettok(%::ctcp,1,32)) $gettok(%::ctcp,2-,32)
CtcpChan !script %:echo  $+ %::c3 $+ %::nick $+  has requested a channel  $+ %::c2 $+ %::ctcp $+  on  $+ %::c3 $+ %::chan $+  at  $+ %::c3 $+ $atime $+  $+ $cpms(%::ctcp %::text)
Ctcp !script %:echo %::pre CTCP  $+ %::c3 $+ %::ctcp $+   $+ %::c2 $+ request by $b( $+ %::c3 $+ %::nick $+ ) at  $+ %::c3 $+ $atime $+  $+ $cpms(%::ctcp %::text)
CtcpChanSelf !script %:echo  $+ %::c1 %::pre  $+ %::c3 $+ - $+ > [[ $+  $+ %::c3 $+ ctcp $+ ( $+  $+ %::c4 $+ %::target $+  $+ )] $upper($gettok(%::ctcp,1,32)) $gettok(%::ctcp,2-,32)
CtcpReply !script %:echo CTCP   $+ %::c3 $+ %::ctcp $+   $+ %::c2 $+ reply from  $+ %::c3 $+ %::nick $+  $iif(%::ctcp == PING && %::text isnum,$chr(58) $iduration(%::text),$cpms(%::ctcp %::text))
CtcpReplySelf !script %:echo CTCP   $+ %::c3 $+ %::ctcp $+   $+ %::c2 $+ reply from  $+ %::c3 $+ %::nick $+  $iif(%::ctcp == PING && %::text isnum,$chr(58) $iduration(%::text),$cpms(%::ctcp %::text))


DNSError <pre> Unable to resolve <c4><address>
DNSResolve <pre> Resolved <address> -<gt> <raddress>
Echo <pre> <text>
EchoTarget <pre> <text>
Error <pre> <c4>Error: <text>
ServerError <pre> <c4>Error: <text>
Load !script if (!$hget(ircN.deftheme)) { hmake ircN.deftheme 16 } | %:echo  $+ %::c3 $+ ircN theme  $+ %::c4 $+ loaded. (http://www.ircN.org)
Unload !script if ($hget(ircN.deftheme)) { hfree ircN.deftheme } | %:echo  $+ %::c3 $+ ircN theme  $+ %::c4 $+ unloaded.

RAW.324 !script %:echo [o:  $+ %::c3 $+ $opnick(%::chan,0) $+ ] $+ $iif(% isin $issupport(prefix),$ab(h:  $+ %::c3 $+ $hnick(%::chan,0) $+ $o $+ )) $+ [v:  $+ %::c3 $+ $vnick(%::chan,0) $+ ][n:  $+ %::c3 $+ $rnick(%::chan,0) $+ ][t:  $+ %::c3 $+ $nick(%::chan,0) $+ ][m:  $+ %::c3 $+ $iif($remove(%::modes,+,-),%::modes,none) $+ ]
RAW.329 !script %:echo %::pre Created $asctime(%::value)
RAW.332 !script _ircn.topic1
RAW.333 !script _ircn.topic2
RAW.353 !script _ircn.names1
RAW.366 !script _ircn.names2
RAW.482 <pre> <c1>You do not have ops on <c3><chan>
RAW.436 <pre> <c1>Nickname collision!!
RAW.Other <pre> <text>

Scheme1 Dark
Scheme2 multiple spaces
Scheme3 Black timestamp
Scheme4 Black 24h timestamp

[Scheme1]
Colors 1,13,15,8,12,12,3,10,4,12,3,15,13,13,13,15,10,4,3,12,15,1,15,1,14,14,14,1,1,15
BaseColors 15,14,12,04
CLineOwner 03
CLineOP 12
CLineHOP 02
CLineVoice 06
CLineRegular 14
CLineEnemy 04
CLineMe 07
CLineIrcOp 11

[Scheme2]
TextChan
TextQuery
TextMsg

CLineMe 01

[Scheme3]
TimestampFormat <c1>[hh:nntt]

[Scheme4]
TimestampFormat <c1>[HH:nn]