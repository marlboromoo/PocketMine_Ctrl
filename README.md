# PocketMine_Ctrl
Script to manage PocketMine server on linux.
```
 ____            _        _   __  __ _            
|  _ \ ___   ___| | _____| |_|  \/  (_)_ __   ___ 
| |_) / _ \ / __| |/ / _ \ __| |\/| | | '_ \ / _ \
|  __/ (_) | (__|   <  __/ |_| |  | | | | | |  __/
|_|   \___/ \___|_|\_\___|\__|_|  |_|_|_| |_|\___|_Ctrl

```
## Features
 - Manage PocketMine server with tmux session.
 - Remap `Ctrl+c` key to prevent killing PocketMine server.
 - Control script with convenient functions(see [below](#usage)).
 - ...

## Requirments 
 - [BASH] [1]
 - [tmux] [2]

## Install with PocketMine
```
su - pocketmine
#. install PocketMine-MP
mkdir -p ~/pocketmine
cd ~/pocketmine
curl -L -O http://sourceforge.net/projects/pocketmine/files/linux/PocketMine-MP_Installer_Alpha_1.3.9.sh | bash
#. install PocketMine Ctrl
cd ~
git clone https://github.com/marlboromoo/PocketMine_Ctrl.git
ln -s ~/PocketMine_Ctrl/pocketmine.sh ~/pocketmine/
~/pocketmine/pocketmine.sh
```

## Usage
Control script for PocketMine server.
```
./pocketmine.sh 
Usage: pocketmine.sh [CMD]

Available CMDs:
  start			Start PocketMine server.
  attach		Attach PocketMine server console.
  console		Alias for attach.
  stop			Stop PocketMine server. (graceful)
  restart		Restart PocketMine server. (graceful)
  kill			Kill the PocketMine server.
  cmd "MY COMMAND"	Send command to PocketMine server.
  plainlog "LOGFILE"	Strip color code from log file.
  log-rotate		Log rotate.
  remake-world		Regenerate worlds and keep old worlds. (need restart)
  purge-world		Regenerate worlds. (need restart)

```

## Daily Jobs
Add settings to `/etc/crontab` like below.
```
# m h dom mon dow user	command
59 23	* * *   pocketmine /home/pocketmine/pocketmine/pocketmine.sh log-rotate
51 0	* * *   pocketmine /home/pocketmine/pocketmine/pocketmine.sh cmd "say Server will restart in 10 minute."
56 0	* * *   pocketmine /home/pocketmine/pocketmine/pocketmine.sh cmd "say Server will restart in 5 minute."
0  1	* * *   pocketmine /home/pocketmine/pocketmine/pocketmine.sh cmd "say Server will restart in 1 minute."
#1  1	* * *   pocketmine /home/pocketmine/pocketmine/pocketmine.sh restart
```

## TODO
 - Solution to clear the command in the console.
 - Bootstrap.
 - Configuration file.
 - Updater.
 - You tell me.

## FAQ
### How to I detach the console? ###
Press `Ctrl+a`, then press `d`.
### Why do I see a lot of 'iamjustaspam' in the console.log? ###
I need to clear the console input while use the 'cmd' function, but PocketMine
can't handle the `Ctrl+b`,`Ctrl+e` or `UP`/`Down`/`LEFT`/`RIGHT` keys, so sending
a spam instead, I will try to find out the solution.
### I can't understand what you say! ###
Because the English is't my native language, sorry :(

## Author
Timothy.Lee a.k.a MarlboroMoo.

## License
Released under the [MIT License] [3].

  [1]: http://tiswww.case.edu/php/chet/bash/bashtop.html "BASH"
  [2]: http://tmux.sourceforge.net/ "tmux"
  [3]: http://opensource.org/licenses/MIT   "MIT License"

