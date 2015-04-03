# InputStation

A graphical front-end for generating game controller configuration files. It is based on the work for [EmulationStation](https://www.github.com/aloshi/EmulationStation) by Aloshi.

Project website: http://github.com/petrockblock/inputstation

InputStation is used by RetroPie, an open-source project that aims at turning system-on-chip platforms like the Raspberry Pi into old-school gaming machines. You can find that project at [retropie.net](http://retropie.net).


## Troubleshooting

- First, try to check the [issue list](https://github.com/petrockblog/InputStation/issues?state=open) for some entries that might match your problem.  Make sure to check closed issues too!

- Try to update to the latest version of InputStation using git:
```bash
cd InputStationDirectory
git pull
cmake .
make clean
make
```

- If your problem still isn't gone, the best way to report a bug is to post an issue on GitHub. Try to post the simplest steps possible to reproduce the bug. Include files you think might be related. If you haven't re-run InputStation since the crash, the log file `~/.inputstation/is_log.txt` is also helpful.

## Building

InputStation uses some C++11 code, which means you'll need to use at least g++-4.7.

InputStation has a few dependencies. For building, you'll need CMake, SDL2, Boost (System, Filesystem, DateTime, Locale), FreeImage, FreeType, Eigen3, and cURL.

All of this be easily installed with apt-get:
```bash
sudo apt-get install libsdl2-dev libboost-system-dev libboost-filesystem-dev libboost-date-time-dev libboost-locale-dev libfreeimage-dev libfreetype6-dev libeigen3-dev libcurl4-openssl-dev libasound2-dev libgl1-mesa-dev build-essential cmake fonts-droid
```

Then, generate and build the Makefile with CMake:
```bash
cd YourEmulationStationDirectory
cmake .
make clean
make
```


## Thanks

InputStation is based on [EmulationStation](http://www.emulationstation.org) by Aloshi. Without the work of Aloshi, InputStation would not exist in the way it does now.


-Florian Mueller,
[http://www.petrockblock.com](http://www.petrockblock.com)
[http://www.retropie.net](http://www.retropie.net)
