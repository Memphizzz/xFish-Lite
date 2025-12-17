#
# xFish Lite v3.34
#
# Minimal xFish for Docker containers and lightweight environments
# https://gitlab.x-toolz.com/X-ToolZ/xfish-lite
#
# Usage:
#   source /path/to/xfish-lite.fish
#
# Setup (symlinks tmux configs):
#   xfish.lite.setup
#
# Update:
#   xfish.lite.pull
#
# Generated from xFish - do not edit manually
#

set -g XFISH_LITE_VERSION 3.34

# Platform detection
set -g _xfish_isLinux 0
set -g _xfish_isMacOSX 0
set -g _xfish_isWSL 0
set -g _xfish_isDebian 0

switch (string upper (uname))
	case '*LINUX*'
		set -g _xfish_isLinux 1
	case '*DARWIN*'
		set -g _xfish_isMacOSX 1
end

if type -q powershell.exe
	set -g _xfish_isWSL 1
end

if test -e /etc/debian_version
	set -g _xfish_isDebian 1
end

# --- lib/output.fish ---
set -g _xfish_prefix "[xFish]"

function ShowMessage -a text
	tmux display-message $text
end

function ClearLastLine
	tput cuu1	# Move cursor up by one line
	tput el		# Clear the line
end

function ClearPanes
	tmux setw synchronize-panes on \; send-keys clear\n \; setw synchronize-panes off
end

function _xfish.init.echo -a color text
	if IsTmux; and not set -q _xfish_initEcho
		return
	else if test -z $text
		_xfish.echo.red "_xfish.init.echo: Missing text!"
	else
		switch $color
			case 'B'
			_xfish.echo.blue $text
			case 'G'
			_xfish.echo.green $text
			case ''
			_xfish.echo $text
		end
	end
end

function _xfish.echo -a text quiet
	if not test -z $quiet
		return
	end
	echo "$_xfish_prefix $text"
end

function _xfish.echo.green -a text
	set_color green; _xfish.echo $text; set_color normal
end

function _xfish.echo.blue -a text
	set_color blue; _xfish.echo $text; set_color normal
end

function _xfish.echo.yellow -a text
	set_color yellow; _xfish.echo $text; set_color normal
end

function _xfish.echo.red -a text
	set_color red; _xfish.echo $text; set_color normal
end

function _xfish.echo.debug -a text
	if set -q _xfish_debug_mode
		set_color white; echo "Debug: $text"; set_color normal
	end
end

function throw_new_NotImplementedException
	_xfish.echo.red 'throw new NotImplementedException()'
end

# --- lib/platform.fish ---
# exit code or return value 0 is success

function IsTmux
	if test -z $TMUX
		return 1
	else
		return 0
	end
end

function IsSSH
	if test -z $SSH_CONNECTION
		return 1
	else
		return 0
	end
end

function IsWSL
	if test $_xfish_isWSL -eq 1
		return 0
	else
		return 1
	end
end

function IsMacOSX
	if test $_xfish_isMacOSX -eq 1
		return 0
	else
		return 1
	end
end

function IsLinux
	if test $_xfish_isLinux -eq 1
		return 0
	else
		return 1
	end
end

function IsDebian
	if test $_xfish_isDebian -eq 1
		return 0
	else
		return 1
	end
end

# --- lib/helpers.fish ---
function FileExists -a path
	if test -z $path
		return 1
	else if test -e $path
		return 0
	else
		return 1
	end
end

function DirectoryExists -a path
	if test -z $path
		return 1
	else if test -d $path
		return 0
	else
		return 1
	end
end

# --- lib/aliases.fish ---
function _xfish.aliases.load
	_xfish.init.echo 'B' "Setting aliases.."
	alias grep='rg -i --color=always'
	alias dir='ls --color=always --format=vertical'
	alias vdir='ls --color=always --format=long'
	alias ll='ls -lah --color=always --group-directories-first'
	alias lls='ls -lahSr --color=always --group-directories-first'
	alias df='df -h'
	alias du='du -h'
	alias cls='clear'
	alias unset='set --erase'
	alias hostname='uname -n'
	alias killall='killall -9'
	function this.ip; curl icanhazip.com; end

	if set -q _xfish_base
		alias rcode=$_xfish_base/bin/rcode
		abbr --add srcode sudo $_xfish_base/bin/rcode
	end

	functions -e tail
	functions -e xtail
	functions -e cat

	# trash-cli
	if type -q trash
		_xfish.init.echo '' "Found trash, replacing rm.."
		alias rm='trash'
	end

	# eza & exa
	if type -q eza
		_xfish.init.echo '' "Found eza, replacing ls.."
		alias ls='eza'
	else if type -q exa
		_xfish.init.echo '' "Found exa, replacing ls.."
		alias ls='exa'
	end

	# ack
	if type -q ack
		_xfish.init.echo '' "Found ack, adding -i.."
		alias ack='ack -i'
	end

	#aria
	if type -q aria2c
		_xfish.init.echo '' "Found aria, disabling space allocation.."
		alias aria='aria2c --file-allocation=none'
		alias aria2c='aria2c --file-allocation=none'
	end

	#cat
	if type -q batcat
		_xfish.init.echo '' "Found batcat, replacing cat.."
		alias cat='batcat -p'
	end

	#fd
	if type -q fdfind
		_xfish.init.echo '' "Found fdfind, replacing find and fd.."
		alias fd='fdfind'
		alias find='fdfind'
	end

	#zoxide
	if type -q zoxide
		_xfish.init.echo '' "Found zoxide, sourcing.."
		zoxide init fish | source
	end

	#procs
	if type -q procs
		_xfish.init.echo '' "Found procs, replacing ps.."
		alias ps=procs
	end

	#gping
	if type -q gping
		_xfish.init.echo '' "Found gping, replacing ping.."
		alias ping=gping
	end

	#tldr
	if type -q tldr
		_xfish.init.echo '' "Found tldr, replacing man.."
		alias man=tldr
	end

	#duf
	if type -q duf
		_xfish.init.echo '' "Found duf, replacing df.."
		alias df=duf
	end

	#yt-dlp
	if type -q yt-dlp
		if type -q aria2c
			_xfish.init.echo '' "Found yt-dlp and aria, creating alias.."
			alias yt.dl="yt-dlp -f bestvideo+bestaudio --downloader aria2c --downloader-args '-c -j 3 -x 3 -s 3 -k 1M'"
		else
			_xfish.init.echo '' "Found yt-dlp, creating alias.."
			alias yt.dl="yt-dlp -f bestvideo+bestaudio"
		end
	end

	#ripgrep aliases
	if type -q rg
		alias rgcs='rg --type-add "csall:*.{cs,razor,cshtml}" -tcsall'
	end

	#MacOSX sed and fd
	if IsMacOSX
		_xfish.init.echo '' "Replacing sed with gsed.."
		alias sed='gsed'

		if type -q fd
			_xfish.init.echo '' "Found fd, replacing find.."
			alias find='fd'
		end
	end
end


# Theme settings
set -g fish_prompt_pwd_dir_length 0
set -g theme_color_scheme dark
set -g theme_display_vi no
set -g theme_display_ruby no
set -g theme_display_vagrant no
set -g theme_display_k8s_context no
set -g theme_display_user ssh
set -g theme_date_format '+%T'

# Simple tmux init
function xfish.lite.tmux
	if IsTmux
		return
	end

	if not type -q tmux
		_xfish.echo.red "tmux not installed"
		return 1
	end

	set -l session_name (hostname)
	if not tmux has-session -t $session_name 2>/dev/null
		tmux new-session -d -s $session_name
	end
	exec tmux attach-session -t $session_name
end

# Setup tmux configs
function xfish.lite.setup
	set -l lite_base (dirname (status filename))

	_xfish.echo.blue "Setting up tmux configuration.."

	# Backup and symlink tmux.conf
	if test -e ~/.tmux.conf; and not test -L ~/.tmux.conf
		_xfish.echo.yellow "Backing up existing ~/.tmux.conf"
		mv ~/.tmux.conf ~/.tmux.conf.bak
	end

	if not test -L ~/.tmux.conf
		ln -sv $lite_base/xfish_tmux.conf ~/.tmux.conf
	else
		_xfish.echo "~/.tmux.conf already symlinked"
	end

	# Backup and symlink tmux_admin.conf
	if test -e ~/.tmux_admin.conf; and not test -L ~/.tmux_admin.conf
		_xfish.echo.yellow "Backing up existing ~/.tmux_admin.conf"
		mv ~/.tmux_admin.conf ~/.tmux_admin.conf.bak
	end

	if not test -L ~/.tmux_admin.conf
		ln -sv $lite_base/xfish_tmux_admin.conf ~/.tmux_admin.conf
	else
		_xfish.echo "~/.tmux_admin.conf already symlinked"
	end

	_xfish.echo.green "tmux setup complete!"
end

# Reload
function xfish.lite.reload
	_xfish.echo.blue "Reloading.."
	source (status filename)
end

# Self-update
function xfish.lite.pull
	set -l repo_url "https://gitlab.x-toolz.com/X-ToolZ/xfish-lite/-/raw/master/xfish-lite.fish"
	set -l self (status filename)

	_xfish.echo.blue "Checking for updates.."

	# Get remote version
	set -l remote_ver (curl -sf $repo_url | head -3 | string match -r 'v[\d.]+')
	set -l local_ver "v$XFISH_LITE_VERSION"

	if test -z "$remote_ver"
		_xfish.echo.red "Failed to check remote version"
		return 1
	end

	if test "$remote_ver" = "$local_ver"
		_xfish.echo.green "Already up to date ($local_ver)"
		return 0
	end

	_xfish.echo.yellow "Update available: $local_ver -> $remote_ver"
	read -p "set_color yellow; echo -n 'Update now? [y/N] '; set_color normal" confirm

	if test "$confirm" = 'y' -o "$confirm" = 'Y'
		_xfish.echo.blue "Downloading.."
		if curl -sf $repo_url -o $self
			_xfish.echo.green "Updated to $remote_ver!"
			xfish.lite.reload
		else
			_xfish.echo.red "Download failed!"
			return 1
		end
	end
end

# Load
set -g _xfish_initEcho 1
_xfish.aliases.load
umask 022

# Auto-attach to tmux if requested
if set -q XFISH_LITE_TMUX
	xfish.lite.tmux
end

# Startup banner
if type -q figlet; and type -q lolcat
	figlet "xFish Lite v$XFISH_LITE_VERSION" | lolcat
else
	_xfish.echo.green "xFish Lite v$XFISH_LITE_VERSION loaded on "(hostname)".."
end

