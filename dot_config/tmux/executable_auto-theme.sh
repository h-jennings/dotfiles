#!/usr/bin/env bash

# Handle toggle — flips and stores an override so focus-in hook doesn't revert it
if [[ "$1" == "toggle" ]]; then
    current=$(tmux show-option -gv @nushu_theme 2>/dev/null)
    if [[ -z "$current" ]]; then
        # Determine current auto-detected theme to know what to flip to
        if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q Dark; then
            current="dark"
        else
            current="light"
        fi
    fi
    if [[ "$current" == "dark" ]]; then
        tmux set-option -g @nushu_theme "light"
    else
        tmux set-option -g @nushu_theme "dark"
    fi
fi

# Use manual override if set, otherwise auto-detect from macOS
override=$(tmux show-option -gv @nushu_theme 2>/dev/null)
if [[ -n "$override" ]]; then
    theme="$override"
elif defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q Dark; then
    theme="dark"
else
    theme="light"
fi

if [[ "$theme" == "dark" ]]; then
    bg="#26231e"
    fg="#d3cdc6"
    accent="#79d070"
    muted="#6f757f"
    border="#494e57"
    tab_bg="#353028"
else
    bg="#f7f6f1"
    fg="#292821"
    accent="#3c7d3f"
    muted="#585f69"
    border="#6f7680"
    tab_bg="#e9e8e3"
fi

# Status bar
tmux set-option -g status-style "bg=${bg},fg=${fg}"
tmux set-option -g status-left-length 50
tmux set-option -g status-right-length 50

# Session badge (left)
tmux set-option -g status-left "#[fg=${accent},bg=${bg}]#[fg=${bg},bg=${accent},bold] #S #[fg=${accent},bg=${bg}] "

# Time (right)
tmux set-option -g status-right "#[fg=${muted}] %I:%M %p "

# Window tabs — powerline rounded style
tmux set-option -g window-status-separator ""
tmux set-option -g window-status-format "#[fg=${tab_bg},bg=${bg}]#[fg=${muted},bg=${tab_bg}] #I  #W #[fg=${tab_bg},bg=${bg}]"
tmux set-option -g window-status-current-format "#[fg=${accent},bg=${bg}]#[fg=${bg},bg=${accent},bold] #I  #W #[fg=${accent},bg=${bg}]"

# Panes
tmux set-option -g pane-border-style "fg=${border}"
tmux set-option -g pane-active-border-style "fg=${accent}"

# Messages and copy mode
tmux set-option -g message-style "bg=${tab_bg},fg=${fg}"
tmux set-option -g message-command-style "bg=${tab_bg},fg=${fg}"
tmux set-option -g mode-style "bg=${tab_bg},bold"
