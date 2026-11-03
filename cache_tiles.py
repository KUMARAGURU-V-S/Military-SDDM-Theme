#!/usr/bin/env python3
"""
Military SDDM Theme — Tactical Map Tile Cache Downloader
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Pre-caches OpenStreetMap satellite/street tiles for offline use,
focusing on India, orbital flight paths, and global overview.

Usage:
    sudo python3 cache_tiles.py
    sudo python3 cache_tiles.py --zoom-max 6
    sudo python3 cache_tiles.py --cache-dir /var/cache/sddm-worldmap-tiles
"""

import os
import sys
import math
import time
import argparse
import urllib.request
import ssl
from pathlib import Path
from collections import OrderedDict

DEFAULT_CACHE_DIR = "/var/cache/sddm-worldmap-tiles"
TILE_SERVER = "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
USER_AGENT = "MilitarySDDMTheme/1.0 (Linux; tile-cache-downloader)"
REQUEST_DELAY = 0.1
MAX_RETRIES = 3

REGIONS = OrderedDict({
    "india": [
        ("India Strategic Command Zone", 8.0, 36.0, 68.0, 97.0, 4, 7),
    ],
    "orbital_path": [
        ("Orbital Trajectory Corridor", 20.0, 60.0, 30.0, 85.0, 3, 5),
    ],
    "world": [
        ("World Tactical Overview", -85, 85, -180, 180, 0, 3),
    ]
})

def deg2num(lat_deg, lon_deg, zoom):
    lat_rad = math.radians(lat_deg)
    n = 2.0 ** zoom
    xtile = int((lon_deg + 180.0) / 360.0 * n)
    ytile = int((1.0 - math.asinh(math.tan(lat_rad)) / math.pi) / 2.0 * n)
    xtile = max(0, min(int(n) - 1, xtile))
    ytile = max(0, min(int(n) - 1, ytile))
    return (xtile, ytile)

def get_tiles_for_bbox(lat_min, lat_max, lon_min, lon_max, zoom):
    x_min, y_max = deg2num(lat_min, lon_min, zoom)
    x_max, y_min = deg2num(lat_max, lon_max, zoom)
    tiles = []
    for x in range(x_min, x_max + 1):
        for y in range(y_min, y_max + 1):
            tiles.append((zoom, x, y))
    return tiles

def download_tile(z, x, y, cache_dir, dry_run=False):
    dest_path = Path(cache_dir) / str(z) / str(x) / f"{y}.png"
    if dest_path.exists() and dest_path.stat().st_size > 0:
        return True, "cached"
    if dry_run:
        return True, "dry-run"

    dest_path.parent.mkdir(parents=True, exist_ok=True)
    url = TILE_SERVER.format(z=z, x=x, y=y)
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})

    for attempt in range(MAX_RETRIES):
        try:
            ctx = ssl.create_default_context()
            with urllib.request.urlopen(req, timeout=10, context=ctx) as resp:
                data = resp.read()
                dest_path.write_bytes(data)
                return True, "downloaded"
        except Exception:
            if attempt < MAX_RETRIES - 1:
                time.sleep(1)
            else:
                return False, "failed"

def main():
    parser = argparse.ArgumentParser(description="Cache OSM map tiles for Military SDDM Theme")
    parser.add_argument("--cache-dir", default=DEFAULT_CACHE_DIR, help="Tile cache directory")
    parser.add_argument("--zoom-max", type=int, default=7, help="Maximum zoom level to cache")
    parser.add_argument("--dry-run", action="store_true", help="Calculate tiles without downloading")
    args = parser.parse_args()

    print("🛰️  Military SDDM Theme — Tactical Map Tile Cacher")
    print(f"Target Cache Directory: {args.cache_dir}")
    print(f"Maximum Zoom: {args.zoom_max}")
    print("-" * 55)

    all_tiles = set()
    for reg_key, bboxes in REGIONS.items():
        for name, lat_min, lat_max, lon_min, lon_max, z_min, z_max in bboxes:
            actual_max = min(z_max, args.zoom_max)
            for z in range(z_min, actual_max + 1):
                tiles = get_tiles_for_bbox(lat_min, lat_max, lon_min, lon_max, z)
                all_tiles.update(tiles)

    print(f"Total Unique Tiles Scheduled: {len(all_tiles)}")
    if args.dry_run:
        return

    downloaded = 0
    cached = 0
    failed = 0

    for i, (z, x, y) in enumerate(all_tiles, 1):
        success, status = download_tile(z, x, y, args.cache_dir)
        if status == "downloaded":
            downloaded += 1
            time.sleep(REQUEST_DELAY)
        elif status == "cached":
            cached += 1
        else:
            failed += 1

        if i % 25 == 0 or i == len(all_tiles):
            print(f"[{i}/{len(all_tiles)}] Downloaded: {downloaded} | Cached: {cached} | Failed: {failed}")

    print("\n✅ Caching complete!")

if __name__ == "__main__":
    main()
