#!/bin/bash
# Delta wrapper for lazygit's git.pagers list.
#
# $1 picks the diff layout: side-by-side | stacked | auto (default side-by-side).
# lazygit re-runs this for every diff it renders, so both the layout and the
# light/dark choice re-evaluate on the fly -- flipping the macOS appearance or
# resizing the window needs no restart.

case "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" in
  Dark) theme=--dark ;;
  *)    theme=--light ;;
esac

layout=${1:-side-by-side}

if [ "$layout" = auto ]; then
  # stdout is a pipe here (lazygit captures the render), so delta's own width
  # detection can't see the terminal -- ask the tty directly. The threshold is
  # total terminal width, not panel width: at 160 columns the main panel keeps
  # ~128 of them and each side of the diff still gets a readable ~55.
  # Braces so a missing controlling tty fails inside the silenced subshell --
  # a bare `</dev/tty` redirection error would land in lazygit's diff panel.
  cols=$( { stty size </dev/tty | cut -d' ' -f2; } 2>/dev/null )
  [ -n "$cols" ] || cols=$(tput cols 2>/dev/null)
  case "$cols" in ''|*[!0-9]*) cols=80 ;; esac
  if [ "$cols" -ge 160 ]; then layout=side-by-side; else layout=stacked; fi
fi

case "$layout" in
  side-by-side) layout_args=(--side-by-side) ;;
  # Stacked is delta's own default, so there is no flag to pass for it.
  stacked)      layout_args=() ;;
  *) echo "delta-auto.sh: unknown layout '$layout'" >&2; exit 2 ;;
esac

exec delta "$theme" "${layout_args[@]}" \
  --paging=never \
  --line-numbers \
  --hyperlinks \
  --hyperlinks-file-link-format="lazygit-edit://{path}:{line}"
