#
# xFish Lite v3.80
#
# Minimal xFish for Docker containers and lightweight environments
# https://github.com/Memphizzz/xFish-Lite
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
# Local customizations:
#   Create xfish-lite-local.fish in the same directory for custom
#   functions/aliases. This file is sourced on start and not overwritten.
#
# Generated from xFish - do not edit manually
#

set -g XFISH_LITE_VERSION 3.80

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
	_xfish.echo.red 'The method or operation is not implemented.'
end

# --- lib/platform.fish ---
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

# Per-terminal member session name for a session group, so every client gets
# its own view. Keyed on the shell's pid rather than the lowest free number:
# names must never be reused, because a window that outlived its terminal
# detaches its client by session name when it closes, and a recycled name
# would send that detach to somebody else's terminal.
function _xfish.tmux.uniqueSession -a socket base
	set -l stamp $fish_pid"_"(date +%s)
	set -l candidate $base"_"$stamp
	set -l n 2
	while tmux -S $socket has-session -t "=$candidate" &> /dev/null
		set candidate $base"_"$stamp"_"$n
		set n (math $n + 1)
	end
	echo $candidate
end

# --- lib/prompts.fish ---
function _xfish.confirm -a question
	_xfish.echo.yellow $question
	read -p "set_color red; echo -n \"Do you want to continue? [y/N] \"; set_color normal" _xfish_continue

	if contains -- "$_xfish_continue" Y y yes YES
		return 0
	else
		return 1
	end
end

function _xfish.ask -a question -a default
	if test -n "$default"
		# Text input mode with default value
		read -p "set_color yellow; echo -n \"$_xfish_prefix $question [$default]: \"; set_color normal" _xfish_answer
		if test -z "$_xfish_answer"
			echo $default
		else
			echo $_xfish_answer
		end
		return 0
	else
		# Yes/no mode (original behavior)
		read -p "set_color yellow; echo -n \"$_xfish_prefix $question [y/N] \"; set_color normal" _xfish_continue

		if contains -- "$_xfish_continue" Y y yes YES
			return 0
		else
			return 1
		end
	end
end

function _xfish.ask.output
	read -p "set_color yellow; echo -n \"$_xfish_prefix Show error log? [y/N] \"; set_color normal" _xfish_continue

	if contains -- "$_xfish_continue" Y y yes YES
		cat $_xfish_output
		return 0
	else
		return 1
	end
end

# --- lib/aliases.fish ---
function _xfish.aliases.load
	_xfish.init.echo 'B' "Setting aliases.."
	if type -q rg
		alias grep='rg -i --color=always'
	end
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
		if type -q gsed
			_xfish.init.echo '' "Found gsed, replacing sed.."
			alias sed='gsed'
		end

		if type -q fd
			_xfish.init.echo '' "Found fd, replacing find.."
			alias find='fd'
		end
	end
end

function _ssh
	set -l session (tmux display-message -p '#S')
	tmux new-window -n "$argv[1]" -a -t $session env SSH_AUTH_SOCK=$SSH_AUTH_SOCK SSH_AGENT_PID=$SSH_AGENT_PID (string split ' ' $argv[2..99])
end

function _ssh2
	set -l session (tmux display-message -p '#S')
	tmux new-window -n "$argv[1]" -a -t $session $argv[2..99]
end

function xfish.installers.brew
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
end

function xfish.installers.brewbasics
	if not type -q brew
		_xfish.echo.red "brew not found! Run 'xfish.installers.brew' first!"
		return
	end

	# Packages to remove (obsolete versions)
	set obsolete_packages youtube-dl ack lsd exa tldr dog

	# Packages to install (new/correct versions)
	set tmp btop bat eza ncdu duf tlrc gping procs ripgrep
	set tmp $tmp curlie aria2 fd zoxide yt-dlp
	set tmp $tmp lolcat figlet dust fzf jq
	set tmp $tmp git-delta hyperfine sd doggo glow bandwhich speedtest-cli
	# GNU sed backs the 'sed' alias on macOS (BSD sed lacks GNU flags like -i without a suffix)
	IsMacOSX; and set tmp $tmp gnu-sed

	# apt package names to remove (same as tmp, plus apt-specific names)
	set apt_conflicts $tmp fd-find

	_xfish.echo.blue "Obsolete brew packages to remove:"
	_xfish.echo "  $obsolete_packages"

	if IsDebian
		_xfish.echo.blue "Apt packages to remove (replaced by brew):"
		_xfish.echo "  $apt_conflicts"
	end

	_xfish.echo.blue "Packages to install via Brew:"
	_xfish.echo "  $tmp"
	_xfish.echo ""

	if not _xfish.ask "Do you want to continue with the installation?"
		_xfish.echo "Installation cancelled."
		return
	end

	# Remove obsolete brew packages first
	_xfish.echo.blue "Removing obsolete brew packages..."
	brew uninstall $obsolete_packages; or true

	# Remove conflicting apt packages (older versions)
	if IsDebian
		_xfish.echo.blue "Removing conflicting apt packages..."
		sudo apt remove -y $apt_conflicts; or true
	end

	# Install new/correct versions
	for item in $tmp
		_xfish.echo.blue "Installing $item.."
		brew install $item; or _xfish.echo.red "Failed to install $item!"
	end
end

function xfish.installers.nano
	if test -d ~/.nano
		_xfish.echo "Nano syntax highlighting already configured, skipping.."
		return 0
	end

	mkdir -p ~/.nano
	if not curl -sL -o ~/.nano/fish.nanorc https://raw.githubusercontent.com/scopatz/nanorc/master/fish.nanorc
		_xfish.echo.red "Failed to download fish.nanorc!"
		return 1
	end

	# Add includes to .nanorc if not present
	if not test -e ~/.nanorc; or not grep -q 'include "/usr/share/nano/\*.nanorc"' ~/.nanorc 2>/dev/null
		echo 'include "/usr/share/nano/*.nanorc"' >> ~/.nanorc
	end
	if not grep -q 'include "~/.nano/fish.nanorc"' ~/.nanorc 2>/dev/null
		echo 'include "~/.nano/fish.nanorc"' >> ~/.nanorc
	end

	_xfish.echo.green "Nano syntax highlighting configured!"
end

function xfish.installers.fishtools
	_xfish.echo.blue "This will install the following Fish shell tools:"
	_xfish.echo "  - Fisher (Fish package manager)"
	_xfish.echo "  - bobthefish theme (xFish recommended theme)"
	_xfish.echo ""
	_xfish.echo.yellow "Note: This will download and execute scripts from the internet."

	if not _xfish.ask "Do you want to continue with the installation?"
		_xfish.echo "Installation cancelled."
		return
	end

	curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher oh-my-fish/theme-bobthefish
end

function xfish.installers.claude-config
	set -l repo_path
	set -l claude_dir ~/.claude
	set -l default_path

	# Determine default path based on platform
	if IsWSL
		if not set -q WSL_USER
			_xfish.echo.red "WSL_USER not set. Run setup.fish first."
			return 1
		end
		set default_path "/mnt/c/Users/$WSL_USER/clones/claude-config"
	else if IsMacOSX
		set default_path ~/clones/claude-config
	else if IsLinux
		set default_path ~/clones/claude-config
	else
		_xfish.echo.red "Unsupported platform"
		return 1
	end

	_xfish.echo.blue "Claude Code Configuration Installer"
	_xfish.echo ""
	set repo_path (_xfish.ask "Clone location" $default_path)
	_xfish.echo ""
	_xfish.echo "  Repo path:  $repo_path"
	_xfish.echo "  Claude dir: $claude_dir"
	_xfish.echo ""
	_xfish.echo "This will:"
	_xfish.echo "  - Clone claude-config repo (if not present)"
	_xfish.echo "  - Symlink CLAUDE.md, skills/, scripts/ and the statusline script"
	_xfish.echo ""

	if not _xfish.ask "Continue with installation?"
		_xfish.echo "Installation cancelled."
		return
	end

	# Ensure ~/.claude exists
	mkdir -p $claude_dir

	# Clone repo if not present
	if not test -d $repo_path
		_xfish.echo.blue "Cloning claude-config repository..."
		mkdir -p (dirname $repo_path)
		if not git clone git@github.com:Memphizzz/claude-config.git $repo_path
			_xfish.echo.red "Failed to clone repository"
			return 1
		end
	else
		_xfish.echo "Repository already exists at $repo_path"
	end

	# Create symlinks
	_xfish.echo.blue "Creating symlinks..."

	for item in CLAUDE.md skills scripts statusline-command.sh
		set -l src $repo_path/$item
		set -l dst $claude_dir/$item

		if test -e $src
			if test -L $dst
				_xfish.echo "  $item already symlinked"
			else if test -e $dst
				_xfish.echo.yellow "  $item exists, backing up..."
				mv $dst $dst.bak
				ln -sv $src $dst
			else
				ln -sv $src $dst
			end
		else
			_xfish.echo.yellow "  $item not found in repo, skipping"
		end
	end

	# Make statusline script executable
	chmod +x $repo_path/statusline-command.sh 2>/dev/null

	# Platform-specific screenshot setup and settings.json generation
	set -l settings_file $claude_dir/settings.json
	set -l template_file $repo_path/settings.template.json

	if test -e $settings_file
		_xfish.echo.yellow "  settings.json already exists, skipping"
	else if not test -e $template_file
		_xfish.echo.red "  Template not found: $template_file"
	else
		set -l screenshots_path ""

		if IsWSL
			set screenshots_path "/mnt/c/Users/$WSL_USER/Pictures/Screenshots"
			_xfish.echo "  Screenshots: $screenshots_path"

		else if IsMacOSX
			set screenshots_path "$HOME/Pictures/Screenshots"
			if not test -d $screenshots_path
				mkdir -p $screenshots_path
				_xfish.echo "  Created $screenshots_path"
			end
			defaults write com.apple.screencapture location $screenshots_path
			_xfish.echo "  Set macOS screenshot location"

		else if IsLinux
			_xfish.echo "  Skipping screenshots (headless)"
		end

		# Generate settings.json and latest-screenshot.sh from templates
		if test -n "$screenshots_path"
			sed -e "s|{{CLAUDE_DIR}}|$claude_dir|g" \
			    -e "s|{{SCREENSHOTS_PATH}}|$screenshots_path|g" \
			    $template_file > $settings_file
			_xfish.echo.green "  Created settings.json"

			# Generate latest-screenshot.sh
			set -l screenshot_template $repo_path/latest-screenshot.template.sh
			set -l screenshot_script $claude_dir/latest-screenshot.sh
			if test -e $screenshot_template
				sed -e "s|{{SCREENSHOTS_DIR}}|$screenshots_path|g" \
				    $screenshot_template > $screenshot_script
				chmod +x $screenshot_script
				_xfish.echo.green "  Created latest-screenshot.sh"
			end
		else
			# Linux: minimal settings without screenshot permissions
			echo '{
  "statusLine": {
    "type": "command",
    "command": "'$claude_dir'/statusline-command.sh"
  },
  "promptSuggestionEnabled": false
}' > $settings_file
			_xfish.echo.green "  Created minimal settings.json"
		end
	end

	_xfish.echo.green "Claude Code configuration installed!"
end


function xservice
	if IsLinux
		switch $argv[2]
			case 'u' 'up' 'start'
				_xfish.echo.blue "Starting Service '$argv[1]'.."
				sudo systemctl start $argv[1]
				sudo systemctl status $argv[1]
			case 'd' 'down' 'stop'
				_xfish.echo.blue "Stopping Service '$argv[1]'.."
				sudo systemctl stop $argv[1]
			case 'r' 'reload'
				_xfish.echo.blue "Reloading Service '$argv[1]'.."
				sudo systemctl reload $argv[1]
			case 'rs' 'restart'
				_xfish.echo.blue "Restarting Service '$argv[1]'.."
				sudo systemctl restart $argv[1]
				sudo systemctl status $argv[1]
			case 's' 'status'
				sudo systemctl status $argv[1]
			case 'enable'
				_xfish.echo.blue "Enabling Service '$argv[1]'.."
				sudo systemctl enable $argv[1]
			case 'disable'
				_xfish.echo.blue "Disabling Service '$argv[1]'.."
				sudo systemctl disable $argv[1]
			case '*'
				_xfish.echo.red "Unknown command."
		end
	else
		throw_new_NotImplementedException
	end
end

# --- modules/claudecode.fish ---
set -g _xfish_cc_pending ~/.xfish_cc_pending

# Folder-name patterns inside the project folders that are not projects: git
# worktree containers, and the per-session scratch folders of Claude itself
set -g _xfish_cc_skip '*.worktrees' CC-tmp

function _cc_open -a name path resume
    set -l session (tmux display -p '#{session_name}')
    set -l cmd "claude --enable-auto-mode"
    test -n "$resume"; and set cmd "$cmd --resume $resume"
    tmux new-window -n "CC: $name" -c "$path" -a -t "$session" "$cmd"
end

# Picker lists. Each loader fills its own globals with one entry per row: the
# label fzf shows, the name used for the tmux window and terminal title, the
# path, and whatever the row needs to launch (Claude session id, CC_* session).

# Projects: xFish favorites, then every folder directly inside each of the
# $_xfish_devtemp folders, newest first across all of them. A project folder
# that sits inside another one (e.g. ~/Developer/Personal in ~/Developer) is
# only listed for its contents, not as an entry itself. Entries from the first
# folder show their plain name, the others are prefixed with their parent
# ('Personal/xPing') to tell them apart.
function _cc_load_projects
    set -g _cc_proj_labels
    set -g _cc_proj_names
    set -g _cc_proj_paths

    # $_xfish_devtemp is a list. Prompt for the first one only if none of them
    # exists; add more with 'set -U _xfish_devtemp ... <dir>'.
    set -l roots
    for r in $_xfish_devtemp
        test -d "$r"; and set -a roots (path resolve $r)
    end
    if test (count $roots) -eq 0
        read -P (set_color yellow)"[xFish] Enter projects directory: "(set_color normal) devtemp_path
        # read doesn't expand ~
        set devtemp_path (string replace -r '^~' $HOME -- $devtemp_path)
        if test -n "$devtemp_path" -a -d "$devtemp_path"
            set -Ux _xfish_devtemp (path resolve $devtemp_path)
            set roots $_xfish_devtemp
        else
            _xfish.echo.red "Not a directory: '$devtemp_path', only showing favorites"
        end
    end

    set -a _cc_proj_labels "xFish"
    set -a _cc_proj_names "xFish"
    set -a _cc_proj_paths "$_xfish_base"
    if test -n "$_xfish_base_local"; and test -d "$_xfish_base_local"
        set -a _cc_proj_labels "xFish-local"
        set -a _cc_proj_names "xFish-local"
        set -a _cc_proj_paths "$_xfish_base_local"
    end

    # path mtime instead of 'find -printf', which is GNU-only (and 'find' is
    # aliased to fd on macOS)
    for d in (for root in $roots
            for dir in $root/*/
                set dir (string trim -r -c / -- $dir)
                set -l skip 0
                for pat in $_xfish_cc_skip
                    string match -q -- $pat (path basename $dir); and set skip 1
                end
                test $skip -eq 1; and continue
                contains -- (path resolve $dir) $roots; and continue
                echo (path mtime $dir) $dir
            end
        end | sort -rn | cut -d' ' -f2-)
        if test (path dirname $d) = "$roots[1]"
            set -a _cc_proj_labels (path basename $d)
        else
            set -a _cc_proj_labels (path basename (path dirname $d))/(path basename $d)
        end
        set -a _cc_proj_names (path basename $d)
        set -a _cc_proj_paths $d
    end
end

# Running: every live '$_xfish_cc_master_*' session. Each is a standalone tmux
# session that outlives the terminal it was started from, so this is how you get
# back after a terminal (or the whole terminal app) is closed. '@cc_mode' is the
# placement it was started with; empty for sessions from before that was recorded.
function _cc_load_running
    set -g _cc_run_labels
    set -g _cc_run_names
    set -g _cc_run_paths
    set -g _cc_run_tmux
    set -g _cc_run_modes

    # The Claude session title for each CC_* session, so three windows in one
    # project read as what they're about rather than three times the folder name.
    # Claude runs under the pane's shell; a few parents up from its pid is plenty.
    set -l pane_sessions
    set -l pane_pids
    for line in (tmux -S $_xfish_tmux_socket list-panes -a -F '#{session_name} #{pane_pid}' 2>/dev/null)
        set -l f (string split ' ' -- $line)
        string match -q "$_xfish_cc_master"'_*' -- $f[1]; or continue
        set -a pane_sessions $f[1]
        set -a pane_pids $f[2]
    end
    set -l titled_sessions
    set -l titles
    set -l finder ~/.claude/scripts/session-find.py
    if test -f $finder
        # sessionId, last activity epoch, running pid, cwd, title
        for line in (python3 $finder list --tsv --running-only --limit 50 2>/dev/null)
            set -l f (string split \t -- $line)
            test -n "$f[5]"; or continue
            set -l p $f[3]
            for i in 1 2 3
                test -n "$p" -a "$p" != 1; or break
                if set -l idx (contains -i -- $p $pane_pids)
                    set -a titled_sessions $pane_sessions[$idx]
                    set -a titles $f[5]
                    break
                end
                set p (ps -o ppid= -p $p 2>/dev/null | string trim)
            end
        end
    end

    set -l fmt (printf '#{session_name}\t#{session_created}\t#{session_attached}\t#{pane_current_path}\t#{window_name}\t#{@cc_mode}')
    for line in (tmux -S $_xfish_tmux_socket list-sessions -F $fmt 2>/dev/null)
        set -l f (string split \t -- $line)
        string match -q "$_xfish_cc_master"'_*' -- $f[1]; or continue

        set -l name (string replace 'CC: ' '' -- $f[5])
        if set -l t (contains -i -- $f[1] $titled_sessions)
            set name $titles[$t]
        end
        set -l suffix ""
        test "$f[3]" != "0"; and set suffix " (attached)"
        set -l mode (test -n "$f[6]"; and echo $f[6]; or echo '?')
        set -a _cc_run_labels (printf '● %-28s %-9s %-9s %s%s' (string shorten -m 28 -- $name) (_cc_age $f[2]) $mode (string replace -r "^$HOME" '~' -- $f[4]) $suffix)
        set -a _cc_run_names $name
        set -a _cc_run_paths $f[4]
        set -a _cc_run_tmux $f[1]
        set -a _cc_run_modes "$f[6]"
    end
end

# Sessions: recent Claude sessions to resume, in projects or anywhere else (e.g.
# /tmp), minus running ones: the Running view has those. Uses session-find.py
# from xclaude-config, so transcripts are parsed in one place.
function _cc_load_sessions
    set -g _cc_sess_labels
    set -g _cc_sess_names
    set -g _cc_sess_paths
    set -g _cc_sess_ids

    set -l finder ~/.claude/scripts/session-find.py
    test -f $finder; or return 1

    # sessionId, last activity epoch, running pid, cwd, title
    for line in (python3 $finder list --tsv --limit 30 2>/dev/null)
        set -l f (string split \t -- $line)
        test -z "$f[3]"; or continue
        test -d "$f[4]"; or continue

        set -l title $f[5]
        test -n "$title"; or set title (path basename $f[4])
        set -l when (test -n "$f[2]"; and _cc_age $f[2]; or echo "?")

        set -a _cc_sess_labels (printf '↻ %-28s %-34s %s' (string shorten -m 28 -- $title) (string replace -r "^$HOME" '~' -- $f[4]) $when)
        set -a _cc_sess_names (string shorten -m 30 -- $title)
        set -a _cc_sess_paths $f[4]
        set -a _cc_sess_ids $f[1]
    end
end

# Geometry picker. Without fzf the default from _cc_select stands.
function _cc_select_mode
    type -q fzf; or return 0

    set -l mode (printf '%s\n' "← Left" "→ Right" "◇ Windowed" "◇ Bare" | fzf \
        --tmux=center,18,6 \
        --no-input \
        --no-sort \
        --reverse \
        --border=rounded \
        --border-label=" Mode " \
        --pointer="▶" \
        --color="border:yellow,label:yellow" \
        --info=hidden \
        --no-scrollbar)

    # Escape cancels
    test -n "$mode"; or return 1

    if string match -q "*Windowed*" "$mode"
        set -g _cc_selected_mode "windowed"
    else if string match -q "*Bare*" "$mode"
        set -g _cc_selected_mode "bare"
    else if string match -q "*Right*" "$mode"
        set -g _cc_selected_mode "right"
    end
end

# _cc_pick <view> [mode] - one fzf picker over three views: Projects (start a new
# Claude), Running (reattach a live CC_* session) and Sessions (resume a past
# one). Tab / Shift+Tab cycle through them; each loads on its first visit, so
# opening on Projects stays as fast as before. With 'mode' set, picks that open a
# window also get the Mode picker. Sets _cc_selected_{name,path,mode,resume,tmux};
# returns 1 when cancelled.
function _cc_pick -a view need_mode
    set -g _cc_selected_name
    set -g _cc_selected_path
    set -g _cc_selected_mode left
    set -g _cc_selected_resume
    set -g _cc_selected_tmux

    set -l views projects running sessions
    set -l titles Projects Running Sessions
    set -l loaded

    while true
        if not contains -- $view $loaded
            switch $view
                case projects
                    _cc_load_projects
                case running
                    _cc_load_running
                case sessions
                    _cc_load_sessions
            end
            set -a loaded $view
        end

        set -l items
        switch $view
            case projects
                set items $_cc_proj_labels
            case running
                set items $_cc_run_labels
            case sessions
                set items $_cc_sess_labels
        end

        # Rows are picked by position, not text: two Claudes in one project can
        # carry the same label
        set -l idx
        if not type -q fzf
            # No view switching without fzf: a numbered list of this view only
            if test (count $items) -eq 0
                _xfish.echo.yellow "Nothing to pick."
                return 1
            end
            _xfish.echo.yellow "Select for Claude Code:"
            for i in (seq (count $items))
                echo "  $i) $items[$i]"
            end
            read -P "Choice [1-"(count $items)"]: " choice
            if test -z "$choice"; or not test "$choice" -ge 1 2>/dev/null; or test "$choice" -gt (count $items)
                return 1
            end
            set idx $choice
        else
            # Index 0 is the placeholder for an empty view
            set -l rows
            for i in (seq (count $items))
                set -a rows "$i"\t"$items[$i]"
            end
            test (count $rows) -gt 0; or set rows "0"\t"(nothing here · Tab for the next view)"

            # Title marks the current view: ' [Projects] · Running · Sessions · ⇥ '
            set -l marks
            for i in (seq (count $views))
                test $views[$i] = $view; and set -a marks "[$titles[$i]]"; or set -a marks $titles[$i]
            end
            set -l title " "(string join ' · ' $marks)" · ⇥ "

            # Width from the longest entry or title, plus border and pointer
            set -l max_len (string length -- $title)
            for n in $rows
                set -l len (string length -- "$n")
                test $len -gt $max_len; and set max_len $len
            end

            set -l out (printf '%s\n' $rows | fzf \
                --expect=tab,btab \
                --delimiter=\t \
                --with-nth=2.. \
                --tmux=center,(math $max_len + 6),50% \
                --no-input \
                --no-sort \
                --reverse \
                --border=rounded \
                --border-label="$title" \
                --pointer="▶" \
                --color="border:yellow,label:yellow" \
                --info=hidden \
                --no-scrollbar)

            # Escape: no output at all. Otherwise line 1 is the key, line 2 the pick.
            test (count $out) -ge 2; or return 1
            set -l current (contains -i -- $view $views)
            switch $out[1]
                case tab
                    set view $views[(math $current % 3 + 1)]
                    continue
                case btab
                    set view $views[(math "($current + 1) % 3 + 1")]
                    continue
            end
            test -n "$out[2]"; or return 1
            set idx (string split -m1 \t -- $out[2])[1]
        end
        test "$idx" -ge 1 2>/dev/null; or continue

        switch $view
            case projects
                set -g _cc_selected_name $_cc_proj_names[$idx]
                set -g _cc_selected_path $_cc_proj_paths[$idx]
            case running
                set -g _cc_selected_name $_cc_run_names[$idx]
                set -g _cc_selected_path $_cc_run_paths[$idx]
                set -g _cc_selected_tmux $_cc_run_tmux[$idx]
                # Reattach the way it was placed; only sessions from before the
                # mode was recorded need the Mode picker
                set -g _cc_selected_mode $_cc_run_modes[$idx]
                if test -n "$need_mode" -a -z "$_cc_selected_mode"
                    set -g _cc_selected_mode windowed
                    _cc_select_mode; or return 1
                end
                return 0
            case sessions
                set -g _cc_selected_name $_cc_sess_names[$idx]
                set -g _cc_selected_path $_cc_sess_paths[$idx]
                set -g _cc_selected_resume $_cc_sess_ids[$idx]
        end
        break
    end

    if test -n "$need_mode"
        if not _cc_select_mode
            set -g _cc_selected_name
            return 1
        end
    end
end

# _cc_select [path] [mode] - with a path, skips the picker and uses that directory
# directly (resolved to an absolute path, since the launched shell starts
# elsewhere); otherwise opens the picker on Projects. 'mode' as in _cc_pick.
function _cc_select -a target need_mode
    if test -z "$target"
        _cc_pick projects $need_mode
        return $status
    end

    set -g _cc_selected_mode left
    set -g _cc_selected_resume
    set -g _cc_selected_tmux
    if not test -d "$target"
        _xfish.echo.red "Not a directory: $target"
        return 1
    end
    set -g _cc_selected_path (path resolve "$target")
    set -g _cc_selected_name (path basename $_cc_selected_path)
    if test -n "$need_mode"
        _cc_select_mode; or return 1
    end
end

# Config (WSL): Windows Terminal positions for new Claude windows
# Your setup: left=-1152,0  center=0,0  right=5000,0
set -g _xfish_cc_pos_left "-1152,0"
set -g _xfish_cc_pos_right "5000,0"
set -g _xfish_cc_window_size "142,36"
set -g _xfish_cc_window_pos "4180,280"

# Config (macOS): Moom hotkeys that place the new Ghostty window per mode.
# Format: modifiers (control/option/command/shift) followed by a character key.
# Hotkeys rather than Moom's AppleScript 'run', because 'run' opens Moom's
# settings window and applies the action to it.
set -g _xfish_cc_moom_left control option command l
set -g _xfish_cc_moom_right control option command r
set -g _xfish_cc_moom_window control option command c

# Opens a window in the running Ghostty and has Moom place it. The window runs
# Ghostty's configured command, so init picks up the pending file as on WSL.
# Ghostty's AppleScript can't position windows, hence Moom.
function _cc_launch_ghostty -a mode
    set -l hotkey $_xfish_cc_moom_window
    switch "$mode"
        case left
            set hotkey $_xfish_cc_moom_left
        case right
            set hotkey $_xfish_cc_moom_right
    end

    set -l press "keystroke \"$hotkey[-1]\""
    if test (count $hotkey) -gt 1
        set press "$press using {"(string join ', ' (string replace -r '$' ' down' -- $hotkey[1..-2]))"}"
    end

    # Ghostty's own 'frontmost' is unreliable, so readiness is checked via
    # System Events; the hotkey must only fire once the new window has focus,
    # or Moom moves whatever window is in front instead.
    set -l result (osascript 2>&1 -e '
tell application "Ghostty"
	set w to new window
	set wid to id of w
	activate window w
end tell
repeat 40 times
	tell application "System Events" to set fp to name of first process whose frontmost is true
	tell application "Ghostty" to set fw to id of front window
	if fp is "ghostty" and fw is wid then
		tell application "System Events" to '$press'
		return "placed"
	end if
	delay 0.05
end repeat
return "unplaced"')

    switch "$result"
        case placed
            return 0
        case unplaced
            _xfish.echo.yellow "Window opened but never got focus, so Moom couldn't place it."
            return 0
        case '*'
            _xfish.echo.red "Failed to open Ghostty window: $result"
            return 1
    end
end

# Opens a new terminal window for a Claude: Windows Terminal on WSL, Ghostty on
# macOS, placed according to the mode. Everything else is handed to the new
# shell through the pending file, where 'init.tmux' acts on it: with a tmux
# session it reattaches that session, otherwise it starts Claude, resuming the
# Claude session id in 'resume' when given.
function _cc_open_window -a name path mode session resume
    if not IsWSL; and not IsMacOSX
        throw_new_NotImplementedException
        return 1
    end

    printf '%s\n%s\n%s\n%s\n%s\n' "$name" "$path" "$mode" "$session" "$resume" > $_xfish_cc_pending

    if IsWSL
        set -l wt_args -w new

        switch "$mode"
            case left
                set -a wt_args --pos $_xfish_cc_pos_left -F
            case right
                set -a wt_args --pos $_xfish_cc_pos_right -F
            case '*'
                set -a wt_args --pos $_xfish_cc_window_pos --size $_xfish_cc_window_size
        end

        wt.exe $wt_args
    else if not _cc_launch_ghostty $mode
        # Nothing will consume the hand-off, and a stale one would hijack
        # the next shell that starts
        rm -f $_xfish_cc_pending
        return 1
    end
end

# Opens what was picked in a new terminal window: reattaches a running CC_*
# session, or starts Claude, resuming a past session when one was picked. All
# modes but bare host Claude in their own standalone tmux session; bare skips
# tmux entirely and dies with the terminal.
function _cc_launch
    if test -n "$_cc_selected_tmux"
        _cc_open_window $_cc_selected_name $_cc_selected_path $_cc_selected_mode $_cc_selected_tmux; or return 1
        _xfish.echo.green "Reattaching $_cc_selected_name ($_cc_selected_mode).."
        return 0
    end

    _cc_open_window $_cc_selected_name $_cc_selected_path $_cc_selected_mode "" "$_cc_selected_resume"; or return 1
    if test -n "$_cc_selected_resume"
        _xfish.echo.green "Resuming $_cc_selected_name ($_cc_selected_mode).."
    else
        _xfish.echo.green "Launching $_cc_selected_name ($_cc_selected_mode).."
    end
end

# cc [path] - Claude Code launcher: a new Claude in a project, a running one to
# reattach, or a past session to resume (Tab switches), each in a new placed
# window. With a path it starts straight in that directory.
function claudecode -a target
    _cc_select "$target" mode; or return 1
    _cc_launch
end

# cc.init [path] - the same picker, but into a new tmux window of the current session
function claudecode.init -a target
    _cc_select "$target"; or return 1

    if test -n "$_cc_selected_tmux"
        # Already running in its own session: hop this client over to it
        if string match -q "$_xfish_tmux_socket,*" -- "$TMUX"
            tmux -S $_xfish_tmux_socket switch-client -t "=$_cc_selected_tmux"
            return $status
        end
        _xfish.echo.yellow "'$_cc_selected_name' runs in $_cc_selected_tmux, use cc.attach to get to it."
        return 1
    end
    _cc_open $_cc_selected_name $_cc_selected_path "$_cc_selected_resume"
end

function _cc_age -a epoch
    set -l secs (math (date +%s) - $epoch)
    if test $secs -lt 60
        echo "just now"
    else if test $secs -lt 3600
        echo (math -s0 $secs / 60)"m ago"
    else if test $secs -lt 86400
        echo (math -s0 $secs / 3600)"h ago"
    else
        echo (math -s0 $secs / 86400)"d ago"
    end
end

# cc.attach [--here] - the picker opened on Running. The pick opens in a new
# window placed by its recorded mode; with --here (and on platforms without
# window support) a running session attaches in the current terminal instead.
function claudecode.attach
    set -l here 0
    contains -- --here $argv; and set here 1
    begin; IsWSL; or IsMacOSX; end; or set here 1

    if test $here -eq 0
        _cc_pick running mode; or return 1
        _cc_launch
        return
    end

    _cc_pick running; or return 1
    if test -z "$_cc_selected_tmux"
        _xfish.echo.yellow "--here only attaches running sessions."
        return 1
    end
    set -l target $_cc_selected_tmux

    # Attach the standalone session directly. No grouping, no new session, so
    # nothing here can disturb any other terminal.
    if not set -q TMUX
        tmux -S $_xfish_tmux_socket attach-session -t "=$target"
    else if string match -q "$_xfish_tmux_socket,*" -- $TMUX
        # Same server, so hop the current client over instead of nesting
        tmux -S $_xfish_tmux_socket switch-client -t "=$target"
    else
        _xfish.echo.red "Already inside a tmux on another socket."
        _xfish.echo "Detach first, or run: tmux -S $_xfish_tmux_socket attach -t $target"
        return 1
    end
end

# Shortcuts. 'cc' shadows the C compiler's name in interactive fish only; builds
# run /usr/bin/cc through PATH and never see fish functions.
alias cc='claudecode'
alias cc.new='claudecode'
alias cc.init='claudecode.init'
alias cc.attach='claudecode.attach'

# --- modules/xdocker.fish ---
function _xdocker_get_projects
    # Returns tab-separated: project_name \t working_dir \t status \t service_count \t type
    # Status: running (any running), stopped (all stopped), partial (mixed)
    # Type: compose or standalone

    set -l projects
    set -l workdirs
    set -l running_counts
    set -l total_counts
    set -l types

    # Get all compose-managed containers
    for line in (docker ps -a --filter "label=com.docker.compose.project" --format '{{.Label "com.docker.compose.project"}}\t{{.Label "com.docker.compose.project.working_dir"}}\t{{.State}}' 2>/dev/null)
        set -l parts (string split \t $line)
        set -l project $parts[1]
        set -l workdir $parts[2]
        set -l state $parts[3]

        # Find or add project
        set -l idx (contains -i $project $projects)
        if test -z "$idx"
            set -a projects $project
            set -a workdirs $workdir
            set -a running_counts 0
            set -a total_counts 0
            set -a types "compose"
            set idx (count $projects)
        end

        # Count containers
        set total_counts[$idx] (math $total_counts[$idx] + 1)
        if test "$state" = "running"
            set running_counts[$idx] (math $running_counts[$idx] + 1)
        end
    end

    # Get standalone containers (no compose label)
    for line in (docker ps -a --format '{{.Names}}\t{{.State}}\t{{.Label "com.docker.compose.project"}}' 2>/dev/null)
        set -l parts (string split \t $line)
        set -l container_name $parts[1]
        set -l state $parts[2]
        set -l compose_project $parts[3]

        # Skip if it's a compose container
        if test -n "$compose_project"
            continue
        end

        set -a projects $container_name
        set -a workdirs ""
        set -a types "standalone"
        set -a total_counts 1

        if test "$state" = "running"
            set -a running_counts 1
        else
            set -a running_counts 0
        end
    end

    # Output results
    for i in (seq (count $projects))
        set -l run_state
        if test $running_counts[$i] -eq 0
            set run_state "stopped"
        else if test $running_counts[$i] -eq $total_counts[$i]
            set run_state "running"
        else
            set run_state "partial"
        end
        printf '%s\t%s\t%s\t%s\t%s\n' $projects[$i] $workdirs[$i] $run_state $total_counts[$i] $types[$i]
    end
end

function _xdocker_get_services -a workdir
    # Get services for a compose project
    pushd "$workdir" 2>/dev/null; or return 1
    docker compose config --services 2>/dev/null
    popd
end

function _xdocker_find_project -a name
    # Find project by name, sets _xdocker_workdir and _xdocker_type
    set -g _xdocker_workdir
    set -g _xdocker_type

    for line in (_xdocker_get_projects)
        set -l parts (string split \t $line)
        if test "$parts[1]" = "$name"
            set -g _xdocker_workdir $parts[2]
            set -g _xdocker_type $parts[5]
            return 0
        end
    end

    _xfish.echo.red "Project '$name' not found"
    return 1
end

function _xdocker_get_image_ids -a workdir
    # Get sorted image IDs for comparison (compose projects)
    pushd "$workdir" 2>/dev/null; or return 1
    docker compose config --images 2>/dev/null | xargs -I {} docker image inspect {} --format '{{.Id}}' 2>/dev/null | sort
    popd
end

function _xdocker_recreate_standalone -a name
    # Recreate a standalone container with the same config but new image
    # Returns 0 on success, 1 on failure

    # Extract all config from the container
    set -l image (docker inspect $name --format '{{.Config.Image}}' 2>/dev/null)
    if test -z "$image"
        _xfish.echo.red "Failed to get image name"
        return 1
    end

    # Build docker run command arguments
    set -l run_args

    # Hostname
    set -l container_hostname (docker inspect $name --format '{{.Config.Hostname}}' 2>/dev/null)
    set -l container_short_id (docker inspect $name --format '{{.Id}}' 2>/dev/null | string sub -l 12)
    if test -n "$container_hostname" -a "$container_hostname" != "$container_short_id"
        set -a run_args --hostname "$container_hostname"
    end

    # Restart policy
    set -l restart (docker inspect $name --format '{{.HostConfig.RestartPolicy.Name}}' 2>/dev/null)
    if test -n "$restart" -a "$restart" != "no"
        set -l max_retry (docker inspect $name --format '{{.HostConfig.RestartPolicy.MaximumRetryCount}}' 2>/dev/null)
        if test "$restart" = "on-failure" -a -n "$max_retry" -a "$max_retry" != "0"
            set -a run_args --restart "$restart:$max_retry"
        else
            set -a run_args --restart "$restart"
        end
    end

    # Network mode
    set -l network (docker inspect $name --format '{{.HostConfig.NetworkMode}}' 2>/dev/null)
    if test -n "$network" -a "$network" != "default"
        set -a run_args --network "$network"
    end

    # Port mappings
    for port in (docker inspect $name --format '{{range $p, $conf := .NetworkSettings.Ports}}{{if $conf}}{{(index $conf 0).HostIp}}:{{(index $conf 0).HostPort}}:{{$p}}{{"\n"}}{{end}}{{end}}' 2>/dev/null)
        if test -n "$port"
            # Clean up empty host IP (0.0.0.0)
            set port (string replace -r '^:' '' $port)
            set port (string replace '0.0.0.0:' '' $port)
            set -a run_args -p "$port"
        end
    end

    # Volume mounts
    for mount in (docker inspect $name --format '{{range .Mounts}}{{.Type}}:{{.Source}}:{{.Destination}}:{{.RW}}{{"\n"}}{{end}}' 2>/dev/null)
        if test -n "$mount"
            set -l parts (string split ':' $mount)
            set -l type $parts[1]
            set -l source $parts[2]
            set -l dest $parts[3]
            set -l rw $parts[4]

            if test "$type" = "bind"
                if test "$rw" = "false"
                    set -a run_args -v "$source:$dest:ro"
                else
                    set -a run_args -v "$source:$dest"
                end
            else if test "$type" = "volume"
                if test "$rw" = "false"
                    set -a run_args -v "$source:$dest:ro"
                else
                    set -a run_args -v "$source:$dest"
                end
            end
        end
    end

    # Environment variables
    for env in (docker inspect $name --format '{{range .Config.Env}}{{.}}{{"\n"}}{{end}}' 2>/dev/null)
        if test -n "$env"
            # Skip common default env vars
            if not string match -qr '^(PATH|HOME|HOSTNAME)=' $env
                set -a run_args -e "$env"
            end
        end
    end

    # Labels (skip com.docker.* internal labels)
    for label in (docker inspect $name --format '{{range $k, $v := .Config.Labels}}{{$k}}={{$v}}{{"\n"}}{{end}}' 2>/dev/null)
        if test -n "$label"
            if not string match -q 'com.docker.*' $label
                set -a run_args --label "$label"
            end
        end
    end

    # Privileged mode
    set -l privileged (docker inspect $name --format '{{.HostConfig.Privileged}}' 2>/dev/null)
    if test "$privileged" = "true"
        set -a run_args --privileged
    end

    # User
    set -l user (docker inspect $name --format '{{.Config.User}}' 2>/dev/null)
    if test -n "$user"
        set -a run_args --user "$user"
    end

    # Working dir
    set -l workdir (docker inspect $name --format '{{.Config.WorkingDir}}' 2>/dev/null)
    if test -n "$workdir"
        set -a run_args --workdir "$workdir"
    end

    # Entrypoint (if customized)
    set -l entrypoint (docker inspect $name --format '{{json .Config.Entrypoint}}' 2>/dev/null)
    if test -n "$entrypoint" -a "$entrypoint" != "null"
        set -a run_args --entrypoint (echo $entrypoint | string trim -c '[]"')
    end

    # Command/args
    set -l cmd (docker inspect $name --format '{{json .Config.Cmd}}' 2>/dev/null)

    # Stop the old container
    _xfish.echo "Stopping old container..."
    docker stop $name >/dev/null 2>&1

    # Rename old container as backup
    set -l backup_name "$name-xdocker-old"
    docker rename $name $backup_name >/dev/null 2>&1

    # Create new container
    _xfish.echo "Creating new container..."
    set -l create_result
    if test -n "$cmd" -a "$cmd" != "null"
        # Parse JSON array for command
        set -l cmd_args (echo $cmd | string trim -c '[]' | string split ',' | string trim -c '" ')
        set create_result (docker run -d --name $name $run_args $image $cmd_args 2>&1)
    else
        set create_result (docker run -d --name $name $run_args $image 2>&1)
    end

    if test $status -ne 0
        _xfish.echo.red "Failed to create new container: $create_result"
        _xfish.echo "Restoring old container..."
        docker rename $backup_name $name >/dev/null 2>&1
        docker start $name >/dev/null 2>&1
        return 1
    end

    # Verify new container is running
    sleep 1
    set -l new_state (docker inspect $name --format '{{.State.Running}}' 2>/dev/null)
    if test "$new_state" != "true"
        set -l logs (docker logs -t $name 2>&1 | tail -5)
        _xfish.echo.red "New container failed to start"
        _xfish.echo.red "Logs: $logs"
        _xfish.echo "Restoring old container..."
        docker rm -f $name >/dev/null 2>&1
        docker rename $backup_name $name >/dev/null 2>&1
        docker start $name >/dev/null 2>&1
        return 1
    end

    # Success - remove old container
    docker rm $backup_name >/dev/null 2>&1
    return 0
end

# ============================================================================
# Core Commands
# ============================================================================

function xdocker.status
    set -l projects_data (_xdocker_get_projects)

    if test (count $projects_data) -eq 0
        _xfish.echo.yellow "No Docker containers found"
        return 0
    end

    # Header
    echo ""
    printf "  %-25s %-12s %-12s %s\n" "PROJECT" "TYPE" "STATUS" "CONTAINERS"
    printf "  %-25s %-12s %-12s %s\n" "-------" "----" "------" "----------"

    for line in $projects_data
        set -l parts (string split \t $line)
        set -l project $parts[1]
        set -l run_state $parts[3]
        set -l count $parts[4]
        set -l type $parts[5]

        set -l state_display
        switch $run_state
            case "running"
                set state_display (set_color green)"[running]"(set_color normal)
            case "stopped"
                set state_display (set_color red)"[stopped]"(set_color normal)
            case "partial"
                set state_display (set_color yellow)"[partial]"(set_color normal)
        end

        set -l type_display
        if test "$type" = "compose"
            set type_display (set_color cyan)"compose"(set_color normal)
        else
            set type_display (set_color magenta)"standalone"(set_color normal)
        end

        printf "  %-25s %-22s %-22s %s\n" $project $type_display $state_display $count
    end
    echo ""
end

function xdocker.update -a name
    # Parse flags
    set -l follow_logs 0
    set -l project_name

    for arg in $argv
        switch $arg
            case '-f' '--follow'
                set follow_logs 1
            case '-*'
                _xfish.echo.red "Unknown flag: $arg"
                return 1
            case '*'
                set project_name $arg
        end
    end

    if test -z "$project_name"
        _xfish.echo.red "Usage: xdocker.update <project> [-f]"
        return 1
    end

    if not _xdocker_find_project $project_name
        return 1
    end

    _xfish.echo.blue "Updating '$project_name'..."

    # Handle standalone containers differently
    if test "$_xdocker_type" = "standalone"
        # Get image name from container
        set -l image (docker inspect $project_name --format '{{.Config.Image}}' 2>/dev/null)
        if test -z "$image"
            _xfish.echo.red "Failed to get image name"
            return 1
        end

        # Get current image ID
        set -l before (docker inspect $project_name --format '{{.Image}}' 2>/dev/null)

        # Pull new image
        _xfish.echo "Pulling $image..."
        docker pull $image
        if test $status -ne 0
            _xfish.echo.red "Pull failed"
            return 1
        end

        # Get new image ID
        set -l after (docker inspect $image --format '{{.Id}}' 2>/dev/null)

        # Compare
        if test "$before" = "$after"
            _xfish.echo.green "Already up to date - no restart needed"
            test $follow_logs -eq 1; and xdocker.logs $project_name
            return 0
        end

        # Image changed, recreate container
        _xfish.echo "Image updated, recreating container..."
        if not _xdocker_recreate_standalone $project_name
            return 1
        end

        _xfish.echo.green "Update complete!"
        test $follow_logs -eq 1; and xdocker.logs $project_name
        return 0
    end

    # Compose project update
    # Get image IDs before pull
    set -l before (_xdocker_get_image_ids $_xdocker_workdir)

    # Pull
    _xfish.echo "Pulling images..."
    pushd "$_xdocker_workdir"
    docker compose pull
    set -l pull_status $status

    if test $pull_status -ne 0
        _xfish.echo.red "Pull failed"
        popd
        return 1
    end

    # Get image IDs after pull
    set -l after (_xdocker_get_image_ids $_xdocker_workdir)

    # Compare
    if test "$before" = "$after"
        _xfish.echo.green "Already up to date - no restart needed"
        popd
        test $follow_logs -eq 1; and xdocker.logs $project_name
        return 0
    end

    # Images changed, restart
    _xfish.echo "Images updated, restarting..."
    docker compose down
    docker compose up -d
    popd

    _xfish.echo.green "Update complete!"
    test $follow_logs -eq 1; and xdocker.logs $project_name
    return 0
end

function xdocker.logs -a name service
    if test -z "$name"
        _xfish.echo.red "Usage: xdocker.logs <project> [service]"
        return 1
    end

    if not _xdocker_find_project $name
        return 1
    end

    if test "$_xdocker_type" = "standalone"
        _xfish.echo.blue "Following logs for '$name'..."
        docker logs -tf $name
    else
        pushd "$_xdocker_workdir"
        if test -n "$service"
            _xfish.echo.blue "Following logs for '$name/$service'..."
            docker compose logs -tf $service
        else
            _xfish.echo.blue "Following logs for '$name'..."
            docker compose logs -tf
        end
        popd
    end
    return 0
end

function xdocker.stop -a name
    if test -z "$name"
        _xfish.echo.red "Usage: xdocker.stop <project>"
        return 1
    end

    if not _xdocker_find_project $name
        return 1
    end

    _xfish.echo.blue "Stopping '$name'..."
    if test "$_xdocker_type" = "standalone"
        docker stop $name
    else
        pushd "$_xdocker_workdir"
        docker compose down
        popd
    end
    _xfish.echo.green "Stopped"
end

function xdocker.start -a name
    if test -z "$name"
        _xfish.echo.red "Usage: xdocker.start <project>"
        return 1
    end

    if not _xdocker_find_project $name
        return 1
    end

    _xfish.echo.blue "Starting '$name'..."
    if test "$_xdocker_type" = "standalone"
        docker start $name
    else
        pushd "$_xdocker_workdir"
        docker compose up -d
        popd
    end
    _xfish.echo.green "Started"
end

function xdocker.restart -a name
    if test -z "$name"
        _xfish.echo.red "Usage: xdocker.restart <project>"
        return 1
    end

    if not _xdocker_find_project $name
        return 1
    end

    _xfish.echo.blue "Restarting '$name'..."
    if test "$_xdocker_type" = "standalone"
        docker restart $name
    else
        pushd "$_xdocker_workdir"
        docker compose down
        docker compose up -d
        popd
    end
    _xfish.echo.green "Restarted"
end

function xdocker.cd -a name
    if test -z "$name"
        _xfish.echo.red "Usage: xdocker.cd <project>"
        return 1
    end

    if not _xdocker_find_project $name
        return 1
    end

    # Get all mount sources for the project
    set -l mounts
    if test "$_xdocker_type" = "standalone"
        set mounts (docker inspect $name --format '{{range .Mounts}}{{.Source}}{{"\n"}}{{end}}' 2>/dev/null | string match -v '')
    else
        # Get all containers for the compose project
        for container in (docker ps -a --filter "label=com.docker.compose.project=$name" --format '{{.Names}}')
            for mount in (docker inspect $container --format '{{range .Mounts}}{{.Source}}{{"\n"}}{{end}}' 2>/dev/null | string match -v '')
                if not contains $mount $mounts
                    set -a mounts $mount
                end
            end
        end
    end

    if test (count $mounts) -eq 0
        _xfish.echo.red "No volumes found for '$name'"
        return 1
    end

    set -l target
    if test (count $mounts) -eq 1
        set target $mounts[1]
    else if type -q fzf
        set target (printf '%s\n' $mounts | fzf \
            --tmux=center,60,50% \
            --no-sort \
            --reverse \
            --border=rounded \
            --border-label=" Volume: $name " \
            --pointer="▶" \
            --color="border:blue,label:blue" \
            --info=hidden \
            --no-scrollbar)
    else
        # No fzf, use first mount
        set target $mounts[1]
    end

    if test -z "$target"
        return 0
    end

    if not test -d "$target"
        _xfish.echo.red "Directory does not exist: $target"
        return 1
    end

    cd "$target"
    _xfish.echo.green "Changed to $target"
end

# ============================================================================
# Interactive UI Mode
# ============================================================================

function xdocker
    # fzf-based interactive mode
    if not type -q fzf
        _xfish.echo.red "fzf is required for interactive mode"
        _xfish.echo "Use xdocker.status, xdocker.update, etc. for CLI mode"
        return 1
    end

    set -l projects_data (_xdocker_get_projects)

    if test (count $projects_data) -eq 0
        _xfish.echo.yellow "No Docker containers found"
        return 0
    end

    # Build display list with status colors (ANSI codes for fzf)
    set -l display_lines
    set -l project_names
    set -l project_workdirs
    set -l project_types
    set -l project_states

    for line in $projects_data
        set -l parts (string split \t $line)
        set -l project $parts[1]
        set -l workdir $parts[2]
        set -l run_state $parts[3]
        set -l count $parts[4]
        set -l type $parts[5]

        set -a project_names $project
        set -a project_workdirs $workdir
        set -a project_types $type
        set -a project_states $run_state

        set -l state_color
        switch $run_state
            case "running"
                set state_color \e'[32m[running]'\e'[0m'
            case "stopped"
                set state_color \e'[31m[stopped]'\e'[0m'
            case "partial"
                set state_color \e'[33m[partial]'\e'[0m'
        end

        set -l type_color
        if test "$type" = "compose"
            set type_color \e'[36mcompose'\e'[0m'
        else
            set type_color \e'[35mstandalone'\e'[0m'
        end

        set -a display_lines (printf "%-25s %-10s %s" $project $type_color $state_color)
    end

    # Sort by state: running first, then partial, then stopped
    set -l sorted_indices
    # Running first
    for i in (seq (count $project_names))
        if test "$project_states[$i]" = "running"
            set -a sorted_indices $i
        end
    end
    # Partial second
    for i in (seq (count $project_names))
        if test "$project_states[$i]" = "partial"
            set -a sorted_indices $i
        end
    end
    # Stopped last
    for i in (seq (count $project_names))
        if test "$project_states[$i]" = "stopped"
            set -a sorted_indices $i
        end
    end

    # Build sorted display lines
    set -l sorted_display_lines
    for i in $sorted_indices
        set -a sorted_display_lines $display_lines[$i]
    end

    # Reorder all arrays to match sorted order
    set -l tmp_names
    set -l tmp_workdirs
    set -l tmp_types
    set -l tmp_states
    for i in $sorted_indices
        set -a tmp_names $project_names[$i]
        set -a tmp_workdirs $project_workdirs[$i]
        set -a tmp_types $project_types[$i]
        set -a tmp_states $project_states[$i]
    end
    set project_names $tmp_names
    set project_workdirs $tmp_workdirs
    set project_types $tmp_types
    set project_states $tmp_states
    set display_lines $sorted_display_lines

    # Calculate dimensions
    set -l max_len 55
    for line in $display_lines
        set -l len (string length "$line")
        if test $len -gt $max_len
            set max_len $len
        end
    end
    set -l width (math $max_len + 6)
    set -l height (math (count $display_lines) + 4)
    # Cap height at reasonable maximum
    if test $height -gt 20
        set height 20
    end

    # Step 1: Select project
    set -l selected (printf '%s\n' $display_lines | fzf \
        --ansi \
        --tmux=center,$width,$height \
        --no-sort \
        --reverse \
        --border=rounded \
        --border-label=" Docker " \
        --pointer="▶" \
        --color="border:blue,label:blue" \
        --info=hidden \
        --no-scrollbar)

    if test -z "$selected"
        return 0
    end

    # Extract project name (first word)
    set -l selected_project (string split ' ' $selected)[1]
    set -l idx (contains -i $selected_project $project_names)
    set -l selected_workdir $project_workdirs[$idx]
    set -l selected_type $project_types[$idx]
    set -l selected_state $project_states[$idx]

    # Step 2: Select action (based on type and state)
    set -l actions

    # Update actions (always available)
    if test "$selected_type" = "compose"
        set -a actions "↑ Update        Pull & restart if changed"
        set -a actions "↑ Update+Logs   Pull & restart, follow logs"
    else
        set -a actions "↑ Update        Pull & recreate if changed"
        set -a actions "↑ Update+Logs   Pull & recreate, follow logs"
    end

    # Logs (always available)
    set -a actions "📋 Logs          Follow container logs"

    # Start/Stop based on state
    if test "$selected_state" = "stopped"
        if test "$selected_type" = "compose"
            set -a actions "▶ Start         Start containers"
        else
            set -a actions "▶ Start         Start container"
        end
    else if test "$selected_state" = "running"
        if test "$selected_type" = "compose"
            set -a actions "■ Stop          Stop containers"
            set -a actions "↻ Restart       Stop and start"
        else
            set -a actions "■ Stop          Stop container"
            set -a actions "↻ Restart       Restart container"
        end
    else
        # Partial state - show all
        if test "$selected_type" = "compose"
            set -a actions "▶ Start         Start containers"
            set -a actions "■ Stop          Stop containers"
            set -a actions "↻ Restart       Stop and start"
        else
            set -a actions "▶ Start         Start container"
            set -a actions "■ Stop          Stop container"
            set -a actions "↻ Restart       Restart container"
        end
    end

    set -l action_count (count $actions)
    set -l action_height (math $action_count + 4)

    set -l action (printf '%s\n' $actions | fzf \
        --tmux=center,50,$action_height \
        --no-sort \
        --reverse \
        --border=rounded \
        --border-label=" Action: $selected_project " \
        --pointer="▶" \
        --color="border:blue,label:blue" \
        --info=hidden \
        --no-scrollbar)

    if test -z "$action"
        return 0
    end

    # Parse action (first word after emoji/symbol)
    set -l action_name (string match -r '^\S+\s+(\S+)' $action)[2]

    switch $action_name
        case "Update"
            xdocker.update $selected_project
        case "Update+Logs"
            xdocker.update $selected_project -f
        case "Logs"
            # For compose projects with multiple services, let user pick
            if test "$selected_type" = "compose"
                set -l services (_xdocker_get_services $selected_workdir)

                if test (count $services) -gt 1
                    set -l service_options "All Services"
                    set -a service_options $services

                    set -l selected_service (printf '%s\n' $service_options | fzf \
                        --tmux=center,30,50% \
                        --no-sort \
                        --reverse \
                        --border=rounded \
                        --border-label=" Service " \
                        --pointer="▶" \
                        --color="border:blue,label:blue" \
                        --info=hidden \
                        --no-scrollbar)

                    if test -z "$selected_service"
                        return 0
                    end

                    if test "$selected_service" = "All Services"
                        xdocker.logs $selected_project
                    else
                        xdocker.logs $selected_project $selected_service
                    end
                else
                    xdocker.logs $selected_project
                end
            else
                xdocker.logs $selected_project
            end
        case "Start"
            xdocker.start $selected_project
        case "Stop"
            xdocker.stop $selected_project
        case "Restart"
            xdocker.restart $selected_project
    end
end

# ============================================================================
# Aliases
# ============================================================================

alias xd='xdocker'
alias xd.status='xdocker.status'
alias xd.update='xdocker.update'
alias xd.logs='xdocker.logs'
alias xd.stop='xdocker.stop'
alias xd.start='xdocker.start'
alias xd.restart='xdocker.restart'
alias xd.cd='xdocker.cd'

set -g _xfish_base (dirname (realpath (status filename)))

# Theme settings
set -g fish_prompt_pwd_dir_length 0
set -g theme_color_scheme dark
set -g theme_display_vi no
set -g theme_display_ruby no
set -g theme_display_vagrant no
set -g theme_display_k8s_context no
set -g theme_display_user ssh
set -g theme_date_format '+%T'

# Simple tmux init with session independence
function xfish.lite.tmux
	if IsTmux
		return
	end

	if not type -q tmux
		_xfish.echo.red "tmux not installed"
		return 1
	end

	# Sanitize hostname (dots are invalid in tmux session names)
	set -l master_session (hostname | string replace -a '.' '_')

	# Create master session if it doesn't exist
	if not tmux has-session -t $master_session 2>/dev/null
		tmux new-session -d -s $master_session
	end

	# Find next available session ID for independence
	set -l session_id 1
	while tmux has-session -t {$master_session}_{$session_id} 2>/dev/null
		set session_id (math $session_id + 1)
	end

	set -l session_name {$master_session}_{$session_id}

	# Create linked session with destroy-unattached for independence
	exec tmux new-session -d -t $master_session -s $session_name \; set-option destroy-unattached \; attach-session -t $session_name
end

# Setup tmux configs
function xfish.lite.setup
	set -l lite_base (dirname (realpath (status filename)))

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

	# Optionally symlink tmux_admin.conf
	if _xfish.ask "Enable admin tmux layout?"
		if test -e ~/.tmux_admin.conf; and not test -L ~/.tmux_admin.conf
			_xfish.echo.yellow "Backing up existing ~/.tmux_admin.conf"
			mv ~/.tmux_admin.conf ~/.tmux_admin.conf.bak
		end

		if not test -L ~/.tmux_admin.conf
			ln -sv $lite_base/xfish_tmux_admin.conf ~/.tmux_admin.conf
		else
			_xfish.echo "~/.tmux_admin.conf already symlinked"
		end
	end

	# Symlink init function
	mkdir -p ~/.config/fish/functions
	if not test -L ~/.config/fish/functions/__xfish_init.fish
		ln -sv $lite_base/__xfish_init.fish ~/.config/fish/functions/
	else
		_xfish.echo "__xfish_init.fish already symlinked"
	end

	# Nano syntax highlighting
	if _xfish.ask "Setup nano syntax highlighting?"
		xfish.installers.nano
	end

	# Fisher + bobthefish theme
	if _xfish.ask "Install Fisher and bobthefish theme?"
		xfish.installers.fishtools
	end

	_xfish.echo.green "Setup complete!"
	_xfish.echo "Tip: Install figlet and lolcat for a fancy startup banner."
end

# Reload
function xfish.lite.reload
	_xfish.echo.blue "Reloading.."
	source (status filename)
end

# Self-update
function xfish.lite.pull
	_xfish.echo.blue "Checking for updates.."

	# Fetch tags from remote
	git -C $_xfish_base fetch --tags -q

	# Get remote version from latest tag
	set -l remote_ver (git -C $_xfish_base describe --tags --abbrev=0 origin/main 2>/dev/null)
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
		_xfish.echo.blue "Pulling updates.."
		if git -C $_xfish_base pull
			_xfish.echo.green "Updated to $remote_ver!"
			xfish.lite.reload
		else
			_xfish.echo.red "Git pull failed!"
			return 1
		end
	end
end

# Load
set -g _xfish_initEcho 1
_xfish.aliases.load
umask 022

# Claude Code aliases (WSL only)
if IsWSL
	alias cc.new='claudecode.new'
	alias cc.init='claudecode.init'
end

# Source local customizations (not overwritten by updates)
set -l _lite_local (dirname (realpath (status filename)))/xfish-lite-local.fish
if not test -e $_lite_local
	echo '# xFish Lite - Local Customizations
# This file is sourced on startup and not overwritten by updates.
# Add your custom functions, aliases, and settings here.

# Default init command for SSH connections (starts xfish-lite with tmux)
set -g InitCommand "__xfish_init --exec-tmux"

# Example: Conditional alias (only if tool is installed)
# if type -q btop
# 	alias top btop
# end

# Example: Custom SSH function
# function myserver
# 	_ssh "MyServer" "ssh -t user@myserver.com $InitCommand"
# end

# Example: SSH with custom working directory
# function myserver.logs
# 	_ssh "Logs" "ssh -t user@myserver.com"
# end

# Example: Environment variable
# set -gx EDITOR vim
' > $_lite_local
	_xfish.echo.green "Created $_lite_local for local customizations"
end
source $_lite_local

# Auto-setup on first run
if not test -L ~/.config/fish/functions/__xfish_init.fish
	_xfish.echo.yellow "First run detected, running setup.."
	xfish.lite.setup
end

# Auto-attach to tmux if requested
if contains -- --exec-tmux $argv
	xfish.lite.tmux
end

# Startup banner
set -l _lolcat
set -l _figlet
if type -q lolcat
	set _lolcat lolcat
else if test -x /usr/games/lolcat
	set _lolcat /usr/games/lolcat
end
if type -q figlet
	set _figlet figlet
else if test -x /usr/games/figlet
	set _figlet /usr/games/figlet
end
if test -n "$_figlet"; and test -n "$_lolcat"
	$_figlet "xFish Lite v$XFISH_LITE_VERSION" | $_lolcat
else
	_xfish.echo.green "xFish Lite v$XFISH_LITE_VERSION loaded on "(hostname)".."
end

