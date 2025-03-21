#!/usr/bin/env bash
case $1 in
    "startup")
		# mv ~/.bash_history /tmp/bsh
		# rm ~/.*_history
		# mv /tmp/bsh ~/.bash_history
        # rm ~/.wget-hsts
        # rm ~/.viminfo
		printf '=== STARTUP ===\n'
		/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
        xrdb -merge ~/rice/Xresources
		blueman-applet &
		transmission-gtk -m &
		printf '==== STARTUP FIN ===\n'
        exit
        ;;

    "i3Startup")
        killall picom
        killall hsetroot
        killall polybar 
        picom -b --config ~/rice/.config/picom.conf
        hsetroot -cover ~/Pictures/lisboa.jpg # -cursor_name left_ptr
        polybar example &
        xrdb -merge ~/rice/Xresources
        # stalonetray -t --sticky --window-layer bottom --window-type desktop --geometry 1x1+50-50 
        exit
        ;;
esac

# -- ALIASES & SETUP -- 

alias gdb='gdb -q '
# alias rm='trash -v' 
alias mv='mv -v'
alias cp='cp -v'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias nvim='XTERM_VERSION= nvim' # We do this to preserve scrolling
alias vim='XTERM_VERSION= nvim'
alias emacs='TERM=xterm-direct emacs '  # Get true color working in emacs terminal mode
alias wget='wget --hsts-file /dev/null -c' # Disable Wget History
alias killall='pkill'
alias colemak='setxkbmap us -variant colemak && xmodmap -e "keycode 113 = Left"'
alias gitFixup='git commit --fixup=HEAD'    # Make a new fixup ~HEAD commit
alias gitShallowClone='git clone --depth 1' # Clone only last commit
alias gitS='git status --short'

shopt -s autocd   # Allow Changing Directory Without Explicit cd
shopt -s globstar # Make ** actually work.
bind 'set enable-bracketed-paste on' # Enable Bracket Paste Mode

export DOTNET_CLI_TELEMETRY_OPTOUT=1
# export GTK_THEME="phocus"
export LESSHISTFILE=- # Disable Less History
# export HISTFILE= # Disable History File
export PATH="$PATH:$HOME/.local/bin:$HOME/.deno/bin:$HOME/Downloads/Flutter/bin:$HOME/.zig" # Path
export PS1="\[\e]0;  \W\a\]\[\e[36m\]\w\[\e[m\] \[\e[32m\]->\[\e[m\] " # Prompt

# Set Config Directory To Dotfiles
# export XDG_CONFIG_HOME=$HOME/rice/.config

case "$(uname -r)" in
    *microsoft-standard-WSL2)

        # For WSL (Windows Subsystem For Linux)
        # shellcheck disable=2155
        export DISPLAY="$(grep nameserver /etc/resolv.conf | sed 's/nameserver //'):0"
        # shellcheck disable=2155
        export DISPLAY="$(sed -n 's/nameserver //p' /etc/resolv.conf):0"
        # shellcheck disable=2155
        export DISPLAY=$(ip route | awk '/^default/{print $3}'):0.0
        #export LIBGL_ALWAYS_INDIRECT=1

        ;;

esac

# Run polkit

# -- FUNCTIONS --

# Memory Usage
memoryUsage () {
    ps_mem -p "$(pgrep "$1")"
}

buildDepReverse () {
	read -r -p "Enter package name: " packageName
	sudo apt-mark auto $(apt-cache showsrc $packageName | sed -e '/Build-Depends/!d;s/Build-Depends: \|,\|([^)]*),*\|\[[^]]*\]//g' | sed -E 's/\|//g; s/<.*>//g')
	sudo apt-mark manual build-essential fakeroot devscripts
	sudo apt autoremove --purge
}

m () {
	nvim $@
}

# Symlink Files
symlink () {
	# print symlink
	echo "Creating link $1 -> $2"
    ln -s "$(realpath "$1")" "$(realpath "$2")"
}

# Search In Files
# shellcheck disable=2086
ack () {
    grep -rs --color=always $2 -- "$1"
}

# Use Nvim's Manpager as its simply better than less
if command -v "nvim" &> /dev/null; then
    man () {
        nvim +"Man $*" +"only"
    }
    export EDITOR="nvim" # Set Editor
fi

# Get Package Size
packageSize() {
    if [ -n "$1" ]; then
        apt-cache --no-all-versions show "$1" \
            | grep --color=none  '^Size: ' \
            | numfmt --field=2 --to=si
    else
        dpkg --list | grep "^rc" | cut -d " " -f 3 | xargs sudo dpkg --purge 2> /dev/null
        dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | numfmt --to=si --invalid=warn --field=1
    fi
}

# Get X11 Keynames & Numbers (From Arch Wiki)
keyNames () {
    xev | awk -F'[ )]+' '/^KeyPress/ { a[NR+2] } NR in a { printf "%-3s %s\n", $5, $8 }'
}

download () {
    if [[ $1 == *.git ]]; then
        git clone $1 $(basename "$1")
    else
        curl --progress-bar -L -o "$(basename "$1")" "$1"
    fi
}

pspConvert() {
	ffmpeg -y -i $1 -flags +bitexact -vcodec libx264 -profile:v baseline -level 3.0 -s 480x272 -r 29.97 -b:v 384k -acodec aac -b:a 96k -ar 48000 -f psp -strict -2 ${1%.*}.MP4
}

whatsappConvert() {
	ffmpeg -i $1 -vcodec libx264 -acodec aac output.mp4
}

manipulateImage () {
    case "$1" in
        "replace")
            convert "$2" -fill "$3" -opaque "$4" "$5" 
        ;;
        "nnscale")
            file=$2
            shift; shift;
            convert "$file" -interpolate Nearest -filter -point "$@"
            ;;
        "view")
            convert $2 -resize $(( COLUMNS * 10 ))x$(( LINES * 10 ))\> sixel:
            ;;
        "nview")
            if [ -f "$2" ]; then
                display -frame 15 -mattecolor snow "$2"
            else
                printf 'File %s does not exist\n' "$2"
            fi
            ;;
        "help")
            printf 'nnscale -> Nearest Neighbour Scaling
nview -> Display image in new window
\n'
            ;;
    esac
}

createDesktopFile() {
	ofile=$1
	printf 'Name: \n\e[3m'
	read -r name
	printf '\e[0mComment: \n\e[3m'
	read -r comment
	printf '\e[0mExec: \n\e[3m'
	read -r _exec
	printf '[Desktop Entry]\nType=Application\nVersion=1.0\nName=%s\nComment=%s\nExec=%s' "$name" "$comment" "$_exec" >> "$ofile"
}

testAwesome () {
	 Xephyr :2 -ac -br -noreset -screen 1152x720 &
	sleep 1
	DISPLAY=:2.0 awesome
}

source ~/rice/scripts/gh-comp.sh
