#!/usr/bin/env python3
"""Turn a written script into spoken audio via the ElevenLabs CLI, then play it.

Nothing personal lives in this file. Voices, models and defaults come from the
config file (--help shows its shape) or from flags.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime
from pathlib import Path

CONFIG = Path(os.environ.get("VOICE_BRIEF_CONFIG", "~/.config/claude/voice-brief.json")).expanduser()
CACHE = Path("~/.cache/claude/voice-brief").expanduser()
VOICE_CACHE = CACHE / "voices.json"

CHUNK_LIMIT = 3800        # chars per text-to-speech request
DIALOGUE_LIMIT = 1800     # chars per text-to-dialogue request (API cap is 2000)

DEFAULTS = {
    "voice": "Brian",
    "model_id": "eleven_turbo_v2_5",
    "dialogue_model_id": "eleven_v3",
    "output_format": "mp3_44100_128",
    "speed": 1.0,
    "stability": 0.5,
    "output_dir": str(CACHE),
    "dialogue_voices": {},
    "dialogue_fallback_voices": ["Brian", "Alice", "Sarah", "Eric"],
}

CONFIG_EXAMPLE = """config: $VOICE_BRIEF_CONFIG or ~/.config/claude/voice-brief.json
  {
    "voice": "Brian",
    "model_id": "eleven_turbo_v2_5",
    "output_format": "mp3_44100_128",
    "speed": 1.0,
    "stability": 0.5,
    "output_dir": "~/.cache/claude/voice-brief",
    "dialogue_voices": {"Host": "Brian", "Guest": "Alice"}
  }
"""


def die(msg: str) -> None:
    print(f"speak.py: {msg}", file=sys.stderr)
    sys.exit(1)


def load_config() -> dict:
    cfg = dict(DEFAULTS)
    if CONFIG.exists():
        try:
            cfg.update({k: v for k, v in json.loads(CONFIG.read_text()).items() if v is not None})
        except json.JSONDecodeError as e:
            die(f"{CONFIG} is not valid JSON ({e})")
    return cfg


def run(cmd: list[str], **kw) -> subprocess.CompletedProcess:
    proc = subprocess.run(cmd, capture_output=True, text=True, **kw)
    if proc.returncode != 0:
        detail = (proc.stderr or proc.stdout or "").strip()
        die(f"`{' '.join(cmd[:3])} ...` failed:\n{detail[:1500]}")
    return proc


# --------------------------------------------------------------------------- voices


def list_voices(query: str | None) -> None:
    cmd = ["elevenlabs", "voices", "search", "--page-size", "60", "--format", "json"]
    if query:
        cmd += ["--search", query]
    for v in json.loads(run(cmd).stdout).get("voices", []):
        print(f"{v['name']}\t{v['voice_id']}")


def resolve_voice(name: str, strict: bool = True) -> str | None:
    """Voice name -> id, memoized on disk. Returns None on a miss when not strict."""
    if re.fullmatch(r"[A-Za-z0-9]{20}", name):
        return name
    cache = {}
    if VOICE_CACHE.exists():
        try:
            cache = json.loads(VOICE_CACHE.read_text())
        except json.JSONDecodeError:
            cache = {}
    if name in cache:
        return cache[name]
    cmd = ["elevenlabs", "voices", "search", "--search", name, "--page-size", "5", "--format", "json"]
    voices = json.loads(run(cmd).stdout).get("voices", [])
    if not voices:
        if not strict:
            return None
        die(f'no voice matched "{name}" — try --list-voices')
    cache[name] = voices[0]["voice_id"]
    VOICE_CACHE.parent.mkdir(parents=True, exist_ok=True)
    VOICE_CACHE.write_text(json.dumps(cache, indent=2))
    return cache[name]


# --------------------------------------------------------------------------- text


def split_chunks(text: str, limit: int) -> list[str]:
    """Split on paragraph, then sentence boundaries — never mid-sentence."""
    units: list[str] = []
    for para in (p.strip() for p in re.split(r"\n\s*\n", text.strip())):
        if not para:
            continue
        if len(para) <= limit:
            units.append(para)
            continue
        buf = ""
        for sentence in re.split(r"(?<=[.!?])\s+", para):
            if buf and len(buf) + len(sentence) + 1 > limit:
                units.append(buf)
                buf = sentence
            else:
                buf = f"{buf} {sentence}".strip()
        if buf:
            units.append(buf)

    chunks: list[str] = []
    buf = ""
    for unit in units:
        if buf and len(buf) + len(unit) + 2 > limit:
            chunks.append(buf)
            buf = unit
        else:
            buf = f"{buf}\n\n{unit}".strip()
    if buf:
        chunks.append(buf)
    return chunks


TURN_RE = re.compile(r"^([A-Za-z][A-Za-z0-9 _-]{0,30}):\s+(.*)$")


def parse_turns(text: str) -> list[tuple[str, str]]:
    turns: list[tuple[str, str]] = []
    for line in text.splitlines():
        if not line.strip():
            continue
        m = TURN_RE.match(line.strip())
        if m:
            turns.append([m.group(1).strip(), m.group(2).strip()])
        elif turns:
            turns[-1][1] += " " + line.strip()
    return [(s, t) for s, t in turns]


# --------------------------------------------------------------------------- audio


def concat(parts: list[Path], out: Path) -> None:
    if len(parts) == 1:
        shutil.move(str(parts[0]), out)
        return
    if not shutil.which("ffmpeg"):
        die(f"ffmpeg is needed to join {len(parts)} audio parts (brew install ffmpeg)")
    listing = parts[0].parent / "parts.txt"
    listing.write_text("".join(f"file '{p}'\n" for p in parts))
    run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-f", "concat",
         "-safe", "0", "-i", str(listing), "-c", "copy", str(out)])


def duration(path: Path) -> str:
    if not shutil.which("ffprobe"):
        return ""
    proc = subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration",
         "-of", "default=nw=1:nk=1", str(path)],
        capture_output=True, text=True,
    )
    try:
        secs = round(float(proc.stdout.strip()))
    except ValueError:
        return ""
    return f"{secs // 60}m{secs % 60:02d}s" if secs >= 60 else f"{secs}s"


# --------------------------------------------------------------------------- generate


def gen_speech(chunks, voice_id, cfg, args, work: Path) -> list[Path]:
    settings = json.dumps({"speed": float(args.speed), "stability": float(args.stability)})
    parts = []
    for i, chunk in enumerate(chunks):
        cmd = [
            "elevenlabs", "text-to-speech", "convert",
            "--voice-id", voice_id,
            "--model-id", args.model or cfg["model_id"],
            "--output-format", cfg["output_format"],
            "--text", chunk,
            "--voice-settings", settings,
        ]
        if i > 0:
            cmd += ["--previous-text", chunks[i - 1][-400:]]
        if i < len(chunks) - 1:
            cmd += ["--next-text", chunks[i + 1][:400]]
        part = work / f"part.{i:03d}.mp3"
        run(cmd + ["-o", str(part), "-q"])
        parts.append(part)
    return parts


def gen_dialogue(turns, cfg, args, work: Path) -> list[Path]:
    mapping = {k.lower(): v for k, v in (cfg.get("dialogue_voices") or {}).items()}
    fallbacks = list(cfg.get("dialogue_fallback_voices") or DEFAULTS["dialogue_fallback_voices"])
    resolved: dict[str, str] = {}

    def voice_for(speaker: str) -> str:
        key = speaker.lower()
        if key in resolved:
            return resolved[key]
        # An explicit mapping wins; otherwise a speaker named after a real voice
        # gets it, and anything else takes the next unused fallback voice.
        vid = resolve_voice(mapping[key]) if key in mapping else resolve_voice(speaker, strict=False)
        if vid is None:
            pool = [v for v in fallbacks if resolve_voice(v) not in resolved.values()] or fallbacks
            vid = resolve_voice(pool[0])
        resolved[key] = vid
        return vid

    batches, batch, size = [], [], 0
    for speaker, line in turns:
        if batch and size + len(line) > DIALOGUE_LIMIT:
            batches.append(batch)
            batch, size = [], 0
        batch.append({"text": line, "voice_id": voice_for(speaker)})
        size += len(line)
    if batch:
        batches.append(batch)

    parts = []
    for i, b in enumerate(batches):
        part = work / f"part.{i:03d}.mp3"
        run([
            "elevenlabs", "text-to-dialogue", "convert",
            "--inputs", json.dumps(b),
            "--model-id", args.model or cfg["dialogue_model_id"],
            "--output-format", cfg["output_format"],
            "--settings", json.dumps({"stability": float(args.stability)}),
            "-o", str(part), "-q",
        ])
        parts.append(part)
    return parts


# --------------------------------------------------------------------------- main


def main() -> None:
    p = argparse.ArgumentParser(
        prog="speak.py",
        description="Write a script, hear it back.",
        epilog=CONFIG_EXAMPLE,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    p.add_argument("--text", help="inline text")
    p.add_argument("--file", help="read the script from a file")
    p.add_argument("--voice", help="voice name (fuzzy-matched) or raw voice id")
    p.add_argument("--model", help="model id override")
    p.add_argument("--speed", help="0.7-1.2, default from config")
    p.add_argument("--stability", help="0.0-1.0, default from config")
    p.add_argument("--title", help="slug used in the generated filename")
    p.add_argument("--out", help="write the mp3 here instead of the cache dir")
    p.add_argument("--no-play", action="store_true", help="generate only, don't play")
    p.add_argument("--wait", action="store_true", help="block until playback finishes")
    p.add_argument("--dialogue", action="store_true", help="input is a 'Name: text' two-voice script")
    p.add_argument("--list-voices", nargs="?", const="", metavar="QUERY", help="list voices and exit")
    p.add_argument("--dry-run", action="store_true", help="report the plan, call nothing")
    args = p.parse_args()

    if not shutil.which("elevenlabs"):
        die("elevenlabs CLI not found (brew install elevenlabs), then `elevenlabs auth login`")

    if args.list_voices is not None:
        list_voices(args.list_voices or None)
        return

    cfg = load_config()
    args.speed = args.speed or cfg["speed"]
    args.stability = args.stability or cfg["stability"]

    if args.file:
        path = Path(args.file).expanduser()
        if not path.is_file():
            die(f"no such file: {args.file}")
        text = path.read_text()
    elif args.text:
        text = args.text
    elif not sys.stdin.isatty():
        text = sys.stdin.read()
    else:
        p.print_help()
        sys.exit(1)
    if not text.strip():
        die("nothing to say")

    out_dir = Path(str(cfg["output_dir"])).expanduser()
    if args.out:
        out = Path(args.out).expanduser()
    else:
        slug = re.sub(r"[^a-z0-9]+", "-", (args.title or "brief").lower()).strip("-")[:40]
        out = out_dir / f"{datetime.now():%Y%m%d-%H%M%S}-{slug or 'brief'}.mp3"
    out.parent.mkdir(parents=True, exist_ok=True)

    if args.dialogue:
        turns = parse_turns(text)
        if not turns:
            die("--dialogue expects lines shaped like 'Name: what they say'")
        if args.dry_run:
            speakers = sorted({s for s, _ in turns})
            print(f"dialogue speakers={','.join(speakers)} turns={len(turns)} "
                  f"chars={len(text)} out={out}")
            return
    else:
        chunks = split_chunks(text, CHUNK_LIMIT)
        voice_id = resolve_voice(args.voice or str(cfg["voice"]))
        if args.dry_run:
            words = len(text.split())
            print(f"voice={args.voice or cfg['voice']}({voice_id}) "
                  f"model={args.model or cfg['model_id']} speed={args.speed} "
                  f"chunks={len(chunks)} words={words} ~{round(words / 150 * 60)}s out={out}")
            return

    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp)
        parts = (gen_dialogue(turns, cfg, args, work) if args.dialogue
                 else gen_speech(chunks, voice_id, cfg, args, work))
        if not parts:
            die("generation produced no audio")
        concat(parts, out)

    if not out.exists() or out.stat().st_size == 0:
        die("generation produced no audio")

    if not args.no_play and shutil.which("afplay"):
        if args.wait:
            subprocess.run(["afplay", str(out)])
        else:
            subprocess.Popen(["afplay", str(out)],
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                             start_new_session=True)

    d = duration(out)
    print(f"{out}{f'  ({d})' if d else ''}")


if __name__ == "__main__":
    main()
