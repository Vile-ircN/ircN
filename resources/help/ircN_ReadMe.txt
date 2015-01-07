                    .__                  _______   
                    |__|_______   ____   \      \  
                    |  |\_  __ \_/ ___\  /   |   \ 
                    |  | |  | \/\  \___ /    |    \
                    |__| |__|    \___  >\____|__  /
                                     \/         \/ 8.00
 ----------
 | ReadMe |
 ----------                                          

 #1 About ircN
 #1.1 Main ircN features
 #1.2 Main ircN modules

 #2. Installation
 #2.1 After install
 #2.2 Important commands/aliases
 
 -----------------------------------------------------------------------------
 
 #1 About ircN

   ircN tries to be an unobtrusive all-around script that doesn't have excessive
   color usage in all of it's public messages. Keeping a lot of features away 
   from the core script, and putting them in loadable modules has been one of 
   the key-values on creating ircN 8.
    
   IrcN was first created by icN during the period of July 1996-December 1996 
   as a script known as Imm0rtal SC.  Upon its release in January of 1997, icN 
   renamed the script ircN.  During the months that followed icN developed the 
   first five versions of ircN.  Despite the fact that he was in his Junior 
   year of college he still found time to work with the script, because in his 
   own words mIRC scripting "is like typing".  After ircN 5 icN quit scripting 
   ircN, seeking more of a challenge. These days he idles online and does html. 
   
   A more in-depth look to ircN history is available in '/setup' in the 'About'
   screen, behind the 'History' tab, or the 'ircn_history.txt' in the 'help'
   folder inside ircN installation directory.
 
 -----------------------------------------------------------------------------
 
 #1.1 Main ircN features
 
   - Multinetwork & multiconnection support
   - Eggdrop style userlist
   - Autoconnect
   - Nickserv auto-auth & auto-ghost
   - MTS Theme support (with ircN extensions)
   - Module-system
   - Themed nick completion
   - Custom ctcp reply & ignore
   + more
 
 -----------------------------------------------------------------------------
 
 #1.2 Main ircN modules
 
   - Autojoin
   - Away system*
   - Dialogs
   - ircN encryption**
   - Getnick (regain nick)
   - HTTP downloader
   
   *(Currently beta)
   **(compatible with other ircN clients equiped with ircN encryption,
     a module with blowcrypt/mircryption support is in the works)
   
   And more modules are available at our website. (www.ircN.org)
 
 -----------------------------------------------------------------------------
  
 #2. Installation
 
   After you have downloaded mIRC and ircN, here is how to install ircN;
 
    1) Install mIRC
       - Install mIRC to it's own location (ie. C:\Program Files\mIRC)
    2) Run ircN installer
       - Tell the installer where to put ircN (a location outside of
         mIRC dir, ie. C:\ircN)
       - Tell the installer where your mIRC installation is
         (Where you installed mIRC in step 1)
       - Start ircN
       - For the first time you join a channel you MUST be connected 
         directly to a irc server, NOT through a bouncer.
 
 
 -----------------------------------------------------------------------------
 
 #2.1 After install
 
   After you have installed, you may run ircN.
   
   When ircN is run for the first time it will present a setup wizard for you,
   which will simply ask for your primary nick and other information required
   for a connection to be made to an irc server.
   
   When connecting to irc for the first time, it's important not to connect
   through a bouncer, as ircN will try to detect your hostmask and other
   settings.
 
   Once you have connected for the first time, and join a channel, ircN will
   prompt you for a user and password. This information must be filled out,
   or ircN will not function as intended, as many of ircN's functions are
   very userlist based. You may also want to make sure that the hostmask
   selected for your 'owner' user is detected properly.
   
   ...
   
   Congratulations, you may now start ircing with ircN. It is recommended
   that you take a look as chapter '#2.2 Important commands/aliases' in
   this readme, for the very basic of ircN commands, and you can use
   '/ihelp' command inside ircN to get a list of available ircN commands.
   You might want to also take a look at the ircN_FAQ.txt file inside
   the 'help' folder inside ircN, so that you can avoid the most common
   of problems early on.
 
 -----------------------------------------------------------------------------
 
 #2.2 Important commands/aliases
 
   /iHelp
     - Help interface for ircN's command/aliases, with a list of the most
       important available commands
       (The list of commands looks best when using a fixed width font,
       but should be readable with any other type font also)
   /setup
     - Opens the setup dialog, the place where you can change all of ircN's
       settings, but you will most likely want to take a look at mIRC's
       own options too, accessible with Alt+O or through the menu via
       'Tools -> Options'
   /modules
     - There are many available modules that can be loaded through this alias.
       A lot of the features are kept in the optional modules. You may want
       to keep the 'dialogs' module loaded, as the module contains most of
       ircN's setup-windows, which you will most likely need. You can also
       take a look at modules that don't come with ircN by default, you can
       see find all at www.ircN.org
 
 