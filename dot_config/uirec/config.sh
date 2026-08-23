# uirec defaults — sourced by ~/.local/bin/uirec. Everything here is optional.

VIEWPORT_W=1512            # MacBook Pro 14" logical width
VIEWPORT_H=982             # ...and height, used as the viewport, not the window

OUT_DIR="$HOME/Desktop/Recordings"
OUT_FPS=30
OUT_CRF=23                 # lower = better quality, bigger file
OUT_SCALE=1                # 1 = 1512x982 output, 2 = full 3024x1964 retina
AUDIO=keep                 # keep | strip   (override per-run with --no-audio)

UI_HEIGHT_HINT=87          # Chrome toolbar height, measured; self-corrects anyway
WATCH_TIMEOUT=7200         # seconds to wait for a recording before giving up
