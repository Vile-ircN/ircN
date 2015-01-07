                          ------------------
                          | NTX/NTO README |
                          ------------------
                          
 What is NTX?
 ------------
 
 NTX is an MTS (mIRC Theme Standard) based themeing system/standard, that
 has been extended to support features MTS doesn't cover, many of these
 are ircN features, but there are also plain mIRC features that the MTS
 stardard just doesn't cover.
 
 What is NTO?
 ------------
 
 NTO is an MTS override format, an external .nto to allow additions/overrides
 to existing MTS themes.
 
 What are the new events in NTX?
 -------------------------------
 
 Here is a small incomplete list of the events, hopefully this document will
 get updated soon.
 
 DCCChatReq
 DCCGetReq
 DCCFileSent
 DCCFileRCVD
 HighlightActive
 HighlightChan
 HighlightWin
 JoinSynced
 QueryOpen
 QueryComChans
 TextChanEncrypted
 TextChanSelfEncrypted
 
 iHelp.lc                        - number of ihelp topic on one line
 iHelp.line
 iHelp.main.top
 iHelp.main.bottom
 iHelp.cmd.top
 iHelp.cmd.bottom

 ircN.AC                         - to provide backwards compatibility with
                                   modules when using MTS themes, mostly
                                   for NTO use. BaseColors should be adapted
                                   to be used if ircN.* don't exist in the
                                   theme.
 ircN.HC                         - same as previous one
 ircN.SC                         - same as previous one
 
 ircN.col.nicklist.shitlisted
 ircN.col.nicklist.user
 ircN.col.nicklist.protected
 ircN.col.nicklist.voice
 ircN.col.nicklist.op
 ircN.col.nicklist.bot
 ircN.col.nicklist.master
 ircN.col.nicklist.owner
 ircN.col.nicklist.ircop