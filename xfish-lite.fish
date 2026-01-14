#
# xFish Lite v3.70
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

set -g XFISH_LITE_VERSION 3.70

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

# --- lib/prompts.fish ---
function _xfish.confirm -a question
	_xfish.echo.yellow $question
	read -p "set_color red; echo -n \"Do you want to continue? [y/N] \"; set_color normal" _xfish_continue

	if test $_xfish_continue = 'Y' -o $_xfish_continue = 'y' -o $_xfish_continue = 'yes' -o $_xfish_continue = 'YES'
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

		if test $_xfish_continue = 'Y' -o $_xfish_continue = 'y' -o $_xfish_continue = 'yes' -o $_xfish_continue = 'YES'
			return 0
		else
			return 1
		end
	end
end

function _xfish.ask.output
	read -p "set_color yellow; echo -n \"$_xfish_prefix Show error log? [y/N] \"; set_color normal" _xfish_continue

	if test $_xfish_continue = 'Y' -o $_xfish_continue = 'y' -o $_xfish_continue = 'yes' -o $_xfish_continue = 'YES'
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
		_xfish.init.echo '' "Replacing sed with gsed.."
		alias sed='gsed'

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
	set obsolete_packages youtube-dl ack lsd exa

	# Packages to install (new/correct versions)
	set tmp btop bat eza ncdu duf tldr gping procs ripgrep
	set tmp $tmp curlie aria2 fd zoxide yt-dlp
	set tmp $tmp lolcat figlet dust fzf jq
	set tmp $tmp git-delta hyperfine sd dog glow bandwhich speedtest-cli

	# apt package names that conflict (apt name -> brew name)
	set apt_conflicts bat fd-find ripgrep ncdu speedtest-cli

	_xfish.echo.blue "The following obsolete brew packages will be removed:"
	for item in $obsolete_packages
		_xfish.echo "  - $item"
	end
	_xfish.echo ""

	if IsDebian
		_xfish.echo.blue "The following apt packages will be removed (older than brew):"
		for item in $apt_conflicts
			_xfish.echo "  - $item"
		end
		_xfish.echo ""
	end

	_xfish.echo.blue "The following packages will be installed via Brew:"
	for item in $tmp
		_xfish.echo "  - $item"
	end
	_xfish.echo ""

	if not _xfish.ask "Do you want to continue with the installation?"
		_xfish.echo "Installation cancelled."
		return
	end

	# Remove obsolete brew packages first
	_xfish.echo.blue "Removing obsolete brew packages..."
	for item in $obsolete_packages
		brew uninstall $item 2>/dev/null; or true
	end

	# Remove conflicting apt packages (older versions)
	if IsDebian
		_xfish.echo.blue "Removing conflicting apt packages..."
		for item in $apt_conflicts
			sudo apt remove -y $item 2>/dev/null; or true
		end
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
	_xfish.echo "  - Symlink CLAUDE.md, skills/, and helper scripts"
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

	for item in CLAUDE.md skills statusline-command.sh
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

function _cc_open
    set -l name $argv[1]
    set -l path $argv[2]
    set -l session (tmux display -p '#{session_name}')
    tmux new-window -n "CC: $name" -c "$path" -a -t "$session" "claude"
end

function _cc_select
    # Returns: sets _cc_selected_name, _cc_selected_path, _cc_selected_monitor
    set -g _cc_selected_name
    set -g _cc_selected_path
    set -g _cc_selected_monitor "left"

    # Prompt for projects directory if not configured
    if not set -q _xfish_devtemp; or not test -d "$_xfish_devtemp"
        read -P (set_color yellow)"[xFish] Enter projects directory: "(set_color normal) devtemp_path
        test -n "$devtemp_path" -a -d "$devtemp_path"; and set -Ux _xfish_devtemp $devtemp_path
    end

    set -l names
    set -l paths

    # Static favorites
    set -a names "xFish"
    set -a paths "$_xfish_base"

    if test -n "$_xfish_base_local"; and test -d "$_xfish_base_local"
        set -a names "xFish-local"
        set -a paths "$_xfish_base_local"
    end

    # Dynamic projects from DevTemp (all folders, sorted by modification time)
    if test -d "$_xfish_devtemp"
        for d in (find "$_xfish_devtemp" -maxdepth 1 -mindepth 1 -type d ! -name '*.worktrees' -printf '%T@ %p\n' | sort -rn | cut -d' ' -f2-)
            set -a names (basename $d)
            set -a paths $d
        end
    end

    if test (count $names) -eq 0
        _xfish.echo.red "No projects found"
        return 1
    end

    if type -q fzf
        # Calculate width based on longest name + padding for border/pointer
        set -l max_len 0
        for n in $names
            set -l len (string length "$n")
            if test $len -gt $max_len
                set max_len $len
            end
        end
        set -l width (math $max_len + 6)

        # Step 1: Select project
        set -l selected (printf '%s\n' $names | fzf \
            --tmux=center,$width,50% \
            --no-input \
            --no-sort \
            --reverse \
            --border=rounded \
            --border-label=" Claude Code " \
            --pointer="▶" \
            --color="border:yellow,label:yellow" \
            --info=hidden \
            --no-scrollbar)

        if test -n "$selected"
            set -l idx (contains -i $selected $names)
            set -g _cc_selected_name $selected
            set -g _cc_selected_path $paths[$idx]

            # Step 2: Select mode/monitor
            set -l mode (printf '%s\n' "← Left" "→ Right" "◇ Standalone" | fzf \
                --tmux=center,18,5 \
                --no-input \
                --no-sort \
                --reverse \
                --border=rounded \
                --border-label=" Mode " \
                --pointer="▶" \
                --color="border:yellow,label:yellow" \
                --info=hidden \
                --no-scrollbar)

            # Escape cancels (empty mode)
            if test -z "$mode"
                set -g _cc_selected_name
                return 1
            end

            if string match -q "*Standalone*" "$mode"
                set -g _cc_selected_monitor "standalone"
            else if string match -q "*Right*" "$mode"
                set -g _cc_selected_monitor "right"
            end
        end
    else
        _xfish.echo.yellow "Select project for Claude Code:"
        for i in (seq (count $names))
            echo "  $i) $names[$i]"
        end
        echo ""
        read -P "Choice [1-"(count $names)"]: " choice

        if test -n "$choice"; and test "$choice" -ge 1; and test "$choice" -le (count $names)
            set -g _cc_selected_name $names[$choice]
            set -g _cc_selected_path $paths[$choice]
        end
    end

    test -n "$_cc_selected_name"
end

# Config: positions for new Claude windows
# Your setup: left=-1152,0  center=0,0  right=5000,0
set -g _xfish_cc_pos_left "-1152,0"
set -g _xfish_cc_pos_right "5000,0"
set -g _xfish_cc_standalone_size "142,36"
set -g _xfish_cc_standalone_pos "4180,280"

# Open in new Windows Terminal window
function claudecode.new
    if _cc_select
        set -l wt_args -w new

        if test "$_cc_selected_monitor" = "standalone"
            # Standalone mode: pending file with standalone flag, windowed size + position
            printf '%s\n%s\n%s\n' "$_cc_selected_name" "$_cc_selected_path" "standalone" > $_xfish_cc_pending
            set -a wt_args --pos $_xfish_cc_standalone_pos --size $_xfish_cc_standalone_size
            wt.exe $wt_args
            _xfish.echo.green "Launching $_cc_selected_name standalone..."
        else
            # Tmux mode: pending file without standalone flag, fullscreen
            printf '%s\n%s\n' "$_cc_selected_name" "$_cc_selected_path" > $_xfish_cc_pending

            if test "$_cc_selected_monitor" = "left"
                set -a wt_args --pos $_xfish_cc_pos_left
            else
                set -a wt_args --pos $_xfish_cc_pos_right
            end
            set -a wt_args -F

            wt.exe $wt_args
            _xfish.echo.green "Launching $_cc_selected_name on $_cc_selected_monitor monitor..."
        end
    end
end

function claudecode.init
    if _cc_select
        _cc_open $_cc_selected_name $_cc_selected_path
    end
end

# Shortcuts
alias cc.init='claudecode.init'
alias cc.new='claudecode.new'

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

