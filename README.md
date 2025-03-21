# RICE
When cloning this repo, please clone with submodules `git clone --recurse-submodules https://github.com/undefinedDarkness/rice` or if you have already cloned, run `git submodule update --init --recursive`
Also please clone it to `~/rice`, many paths are coded to expect the repo to be there

## Requirements
- awesomewm (see below)
- playerctl & playerctl gir for bling to load
- wezterm ~ you need some kind of terminal, this is what I use but you can easily swap it out ig
- nvim ~ a modern version should just work technically (see below)
- dmenu ~ or you can use something else 
- mkr (see below)
- xclip
- picom (this one's important)

For `notion-dashboard` and many other scripts to work, you will need `python3-gi` installed
To build awesome and others you'll need `build-essential cmake meson libgtk-3-dev`

## Installation
once you have all the requirements, installation is pretty much just symlinking folders from `~/rice/.config` to `~/.config`

## Special Notes

## notion-dashboard
You will need to modify the script `~/rice/scripts/notion-dashboard.py` to match your notion, the rest should be okay

You'll need `convert` (imagemagick) for the blurred background - NOTE TO SELF, Consider only depending on ffmpeg

## dmenu
```
cd rice/misc/dmenu
sudo make install
```

### Mkr
**UPDATE** - You don't need this anymore, It's still in this repo but it's not used anywhere
Mkr is my custom launcher and you'll have to build it or swap it out with rofi or the like, To build it:
```
cd rice/misc/mkr
meson setup build
meson compile -C build
```

Might rip it out later, I dunno

### Neovim
Please do `:TSInstall` for any languages you often use or it won't look quite right, besides that it should just work,
It's just a standard lazy.nvim setup

I think you might need `rg` installed for telescope to work properly

### Awesome
This rice uses a custom build of awesome with a few patches applied which you can find in misc/
On Ubuntu, you need to 
1. clone awesome source code
2. apply the patch
3. install build dependencies
   `sudo apt-get build-dep awesome`
   for this you will need to enable source code repos, by either modifying `/etc/apt/sources.list` or using the additional software menu
4. Run the build  commands:
```
mkdir build
cd build
cmake ..
make package
sudo apt install ./*.deb
```

Refer to awesomewm documentation for building if you get stuck

## Credits
this rice wouldn't be possible w/o awesome wm, bling and rubato
