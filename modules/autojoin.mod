[module]
module=Autojoin
description=Allows you to auto-join certain channels on connect
version=8.0
author=ircN Development Team
script1=autojoin.mrc

[setupdialog]
dialogs=ircN.autojoin.modern
titles=Autojoin
saves=_save.autojoin

[popup.channel.join]
#clear out the old ones from upgrade
&add=
&remove=
&list=
&edit=

[popup.channel.chan]
#clear out the old ones from upgrade
&autojoin=
&add=
&remove=
&list=

[popup.menu.setup.modules]
&autojoin=ajoin

