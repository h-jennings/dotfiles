#!/usr/bin/env python3
"""Make every pane in the active tab the same size (tmux `select-layout -E`).

Each split's ratio is set to leaves(first) / leaves(first + second), counting
only panes laid out along that split's direction, so a run of N side-by-side
panes each gets 1/N of the width no matter how the splits are nested.
"""
import json
import os
import socket

SOCKET = os.environ.get("HERDR_SOCKET_PATH") or os.path.expanduser("~/.config/herdr/herdr.sock")
TAB = os.environ.get("HERDR_ACTIVE_TAB_ID")


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


def span(node, direction):
    if node["type"] == "split" and node["direction"] == direction:
        return span(node["first"], direction) + span(node["second"], direction)
    return 1


def equalize(node, path):
    if node["type"] != "split":
        return
    first = span(node["first"], node["direction"])
    second = span(node["second"], node["direction"])
    call("layout.set_split_ratio", {"tab_id": TAB, "path": path, "ratio": first / (first + second)})
    equalize(node["first"], path + [False])
    equalize(node["second"], path + [True])


layout = call("layout.export", {"tab_id": TAB})["layout"]
TAB = layout["tab_id"]
equalize(layout["root"], [])
