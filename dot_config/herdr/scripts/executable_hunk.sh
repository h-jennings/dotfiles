#!/bin/sh
# Custom Hunk themes can't follow the system appearance, so the nushu variant is picked at launch.
case "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" in
  Dark) variant=dark ;;
  *) variant=light ;;
esac
command=$1
shift
if [ "$command" = stash ] && [ $# -gt 0 ]; then
  sub=$1
  shift
  exec hunk stash "$sub" --theme "nushu-$variant" "$@"
fi
exec hunk "$command" --theme "nushu-$variant" "$@"
