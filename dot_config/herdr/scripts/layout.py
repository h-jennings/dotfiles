#!/usr/bin/env python3
"""Named layouts: open a new tab pre-split from ~/.config/herdr/layouts/<name>.json.

  layout.py <name>          open the layout in a new tab, in the active pane's folder
  layout.py save <name>     save the active tab's split shape as <name>
  layout.py list            list saved layouts
  layout.py pick            choose one with fzf (used by the popup key binding)
"""
import json
import os
import socket
import subprocess
import sys
from pathlib import Path

SOCKET = os.environ.get("HERDR_SOCKET_PATH") or os.path.expanduser("~/.config/herdr/herdr.sock")
LAYOUTS = Path(os.path.expanduser("~/.config/herdr/layouts"))


def call(method, params):
    with socket.socket(socket.AF_UNIX) as s:
        s.connect(SOCKET)
        s.sendall((json.dumps({"id": method, "method": method, "params": params}) + "\n").encode())
        buf = b""
        while not buf.endswith(b"\n"):
            chunk = s.recv(65536)
            if not chunk:
                break
            buf += chunk
    resp = json.loads(buf)
    if "error" in resp:
        raise SystemExit(f"{method}: {resp['error']}")
    return resp["result"]


def active_layout():
    tab = os.environ.get("HERDR_ACTIVE_TAB_ID") or os.environ.get("HERDR_TAB_ID")
    return call("layout.export", {"tab_id": tab})["layout"]


def find_pane(node, pane_id):
    if node["type"] == "pane":
        return node if node.get("pane_id") == pane_id else None
    return find_pane(node["first"], pane_id) or find_pane(node["second"], pane_id)


def fill(node, cwd):
    if node["type"] == "split":
        return {**node, "first": fill(node["first"], cwd), "second": fill(node["second"], cwd)}
    pane = {k: v for k, v in node.items() if k != "pane_id"}
    pane["cwd"] = os.path.expanduser(pane["cwd"]) if pane.get("cwd") else cwd
    if isinstance(pane.get("command"), str):
        pane["command"] = ["sh", "-c", pane["command"]]
    return pane


def strip(node):
    if node["type"] == "split":
        return {k: node[k] for k in ("type", "direction")} | {
            "ratio": round(node["ratio"], 2),
            "first": strip(node["first"]),
            "second": strip(node["second"]),
        }
    return {"type": "pane"}


def names():
    return sorted(p.stem for p in LAYOUTS.glob("*.json"))


def apply(name):
    path = LAYOUTS / f"{name}.json"
    if not path.exists():
        raise SystemExit(f"no layout '{name}' (have: {', '.join(names()) or 'none'})")
    spec = json.loads(path.read_text())
    current = active_layout()
    focused = find_pane(current["root"], current.get("focused_pane_id")) or {}
    cwd = focused.get("cwd") or os.getcwd()
    call(
        "layout.apply",
        {
            "workspace_id": current["workspace_id"],
            "tab_label": spec.get("label", name),
            "root": fill(spec["root"], cwd),
            "focus": True,
        },
    )


def save(name):
    LAYOUTS.mkdir(parents=True, exist_ok=True)
    spec = {"label": name, "root": strip(active_layout()["root"])}
    (LAYOUTS / f"{name}.json").write_text(json.dumps(spec, indent=2) + "\n")
    print(f"saved {LAYOUTS / name}.json")


def pick():
    choice = subprocess.run(
        ["fzf", "--prompt", "layout> ", "--height", "100%"],
        input="\n".join(names()),
        capture_output=False,
        stdout=subprocess.PIPE,
        text=True,
    ).stdout.strip()
    if choice:
        apply(choice)


args = sys.argv[1:]
if not args or args[0] == "list":
    print("\n".join(names()))
elif args[0] == "save" and len(args) == 2:
    save(args[1])
elif args[0] == "pick":
    pick()
else:
    apply(args[0])
