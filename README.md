# xFish Lite

Minimal xFish for Docker containers, servers, and lightweight environments.

## Quick Start

```fish
# Clone the repo
git clone https://gitlab.x-toolz.com/X-ToolZ/xfish-lite.git ~/xfish-lite

# Source it (run manually or add to your init)
source ~/xfish-lite/xfish-lite.fish

# Setup tmux configs (optional, creates symlinks)
xfish.lite.setup
```

## One-liner (fish shell)

```fish
git clone https://gitlab.x-toolz.com/X-ToolZ/xfish-lite.git ~/xfish-lite && source ~/xfish-lite/xfish-lite.fish
```

## What's Included

- **Aliases**: `ll`, `cls`, `df`, `du`, plus smart replacements (eza→ls, batcat→cat, etc.)
- **Platform detection**: `IsLinux`, `IsWSL`, `IsMacOSX`, `IsDebian`, `IsTmux`
- **Helper functions**: `FileExists`, `DirectoryExists`
- **Output helpers**: `_xfish.echo`, `_xfish.echo.green`, `_xfish.echo.blue`, etc.
- **tmux configs**: Clean tmux setup with status bar (run `xfish.lite.setup`)

## Commands

| Command | Description |
|---------|-------------|
| `xfish.lite.setup` | Symlink tmux configs to `~/.tmux.conf` and `~/.tmux_admin.conf` |
| `xfish.lite.tmux` | Start/attach to tmux session |
| `xfish.lite.reload` | Reload xfish-lite without restarting shell |
| `xfish.lite.pull` | Self-update to latest version |

## Auto-start tmux

Set `XFISH_LITE_TMUX` before sourcing to auto-attach:

```fish
set -gx XFISH_LITE_TMUX 1
source ~/xfish-lite/xfish-lite.fish
```

## Update

```fish
xfish.lite.pull
```

Or manually:
```fish
cd ~/xfish-lite && git pull
```

## Note on Login Shells

Avoid adding to `config.fish` or `/etc/fish/conf.d/` if fish is your login shell - some scripts may break. Instead, source manually or use an init command in your terminal emulator.
