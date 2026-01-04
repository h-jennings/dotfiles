#!/bin/bash
# Auto-detect system theme and run delta with appropriate flag

if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q Dark; then
  THEME="--dark"
else
  THEME="--light"
fi

exec delta $THEME --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format="lazygit-edit://{path}:{line}" "$@"
