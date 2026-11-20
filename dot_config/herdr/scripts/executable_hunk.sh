#!/bin/sh
# Custom Hunk themes can't follow the system appearance, so the nushu variant is picked at launch.
case "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" in
  Dark) variant=dark ;;
  *) variant=light ;;
esac
command=$1
shift
exec hunk "$command" --theme "nushu-$variant" "$@"
