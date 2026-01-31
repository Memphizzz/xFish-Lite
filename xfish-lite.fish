#
# xFish Lite v3.74
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

set -g XFISH_LITE_VERSION 3.74

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
	set obsolete_packages youtube-dl ack lsd exa tldr dog speedtest-cli

	# Packages to install (new/correct versions)
	set tmp btop bat eza ncdu duf tlrc gping procs ripgrep
	set tmp $tmp curlie aria2 fd zoxide yt-dlp
	set tmp $tmp lolcat figlet dust fzf jq
	set tmp $tmp git-delta hyperfine sd doggo glow bandwhich speedtest

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
        set -l logs (docker logs $name 2>&1 | tail -5)
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
        docker logs -f $name
    else
        pushd "$_xdocker_workdir"
        if test -n "$service"
            _xfish.echo.blue "Following logs for '$name/$service'..."
            docker compose logs -f $service
        else
            _xfish.echo.blue "Following logs for '$name'..."
            docker compose logs -f
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

