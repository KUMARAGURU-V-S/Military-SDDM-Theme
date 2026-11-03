#!/usr/bin/env python3
"""
SDDM World Map Theme — Tile Cache Downloader
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Downloads OpenStreetMap tiles for offline use with the SDDM world map theme.
Pre-caches the most commonly viewed map areas so the login screen works
without network connectivity.

Usage:
    sudo python3 cache_tiles.py                     # Default: all standard regions
    sudo python3 cache_tiles.py --regions world     # World overview only
    sudo python3 cache_tiles.py --regions asia europe americas
    sudo python3 cache_tiles.py --zoom-max 6        # Limit max zoom for smaller cache
    sudo python3 cache_tiles.py --cache-dir /custom/path

Tile Usage Policy:
    This script respects OpenStreetMap's Tile Usage Policy by rate-limiting
    requests. See: https://operations.osmfoundation.org/policies/tiles/
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

# ─── Configuration ───────────────────────────────────────────────────

DEFAULT_CACHE_DIR = "/var/cache/sddm-worldmap-tiles"
TILE_SERVER = "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
USER_AGENT = "SDDMWorldMapTheme/1.0 (Linux; tile-cacher)"
REQUEST_DELAY = 0.1  # seconds between requests (be polite to OSM servers)
MAX_RETRIES = 3

# ─── Region Definitions ─────────────────────────────────────────────
# Each region: (name, lat_min, lat_max, lon_min, lon_max, zoom_min, zoom_max)

REGIONS = OrderedDict({
    "world": [
        ("World Overview", -85, 85, -180, 180, 0, 4),
    ],
    "asia": [
        ("India",          6,   36,   68,  98,  5, 7),
        ("China",         18,   54,   73, 135,  4, 6),
        ("Japan",         24,   46,  123, 149,  5, 7),
        ("South Korea",   33,   39,  124, 132,  6, 8),
        ("Southeast Asia", -10, 25,   95, 145,  4, 6),
        ("Singapore",      1.1,  1.5, 103.6, 104.0, 10, 12),
    ],
    "europe": [
        ("UK & Ireland",     49, 61,   -11,   2,  5, 7),
        ("France",           42, 51,    -5,   9,  5, 7),
        ("Germany",          47, 55,     5,  16,  5, 7),
        ("Italy",            36, 47,     6,  19,  5, 7),
        ("Spain & Portugal", 35, 44,   -10,   5,  5, 7),
        ("Netherlands",      50, 54,     3,   8,  6, 8),
        ("Scandinavia",      54, 72,     4,  32,  4, 6),
        ("Central Europe",   45, 55,    10,  25,  5, 7),
    ],
    "americas": [
        ("US East Coast",    24, 47,  -90, -66,  4, 7),
        ("US West Coast",    32, 49, -125, -104, 4, 7),
        ("US Central",       25, 50, -104, -82,  4, 6),
        ("Canada South",     42, 62, -140, -52,  3, 5),
        ("Mexico",           14, 33, -118, -86,  4, 6),
        ("Brazil",          -34,   6, -74, -34,  4, 6),
        ("Argentina",       -55, -22, -74, -53,  4, 6),
    ],
    "mideast": [
        ("UAE & Gulf",       22, 30,   50,  57,  6, 8),
        ("Saudi Arabia",     16, 33,   34,  56,  5, 7),
        ("Middle East",      12, 42,   26,  64,  4, 6),
    ],
    "africa": [
        ("Egypt & Nile",     22, 32,   24,  37,  5, 7),
        ("South Africa",    -35, -22,  16,  33,  5, 7),
        ("Nigeria & W.Africa", 4, 14,   2,  15,  5, 7),
        ("East Africa",     -12, 12,   28,  42,  4, 6),
    ],
    "oceania": [
        ("Australia",       -44, -10, 112, 155,  4, 6),
        ("New Zealand",     -48, -34, 165, 179,  5, 7),
    ],
})


# ─── Tile Math ───────────────────────────────────────────────────────

def deg2tile(lat_deg, lon_deg, zoom):
    """Convert lat/lon to tile coordinates at given zoom level."""
    lat_rad = math.radians(lat_deg)
    n = 2.0 ** zoom
    x = int((lon_deg + 180.0) / 360.0 * n)
    y = int((1.0 - math.asinh(math.tan(lat_rad)) / math.pi) / 2.0 * n)
    # Clamp to valid range
    x = max(0, min(int(n) - 1, x))
    y = max(0, min(int(n) - 1, y))
    return x, y


def count_tiles_for_region(lat_min, lat_max, lon_min, lon_max, zoom_min, zoom_max):
    """Count total tiles needed for a region across zoom levels."""
    total = 0
    for z in range(zoom_min, zoom_max + 1):
        x_min, y_max = deg2tile(lat_min, lon_min, z)
        x_max, y_min = deg2tile(lat_max, lon_max, z)
        if x_min > x_max:
            x_min, x_max = x_max, x_min
        if y_min > y_max:
            y_min, y_max = y_max, y_min
        total += (x_max - x_min + 1) * (y_max - y_min + 1)
    return total


def get_tiles_for_region(lat_min, lat_max, lon_min, lon_max, zoom_min, zoom_max):
    """Yield (z, x, y) tuples for all tiles in a region."""
    for z in range(zoom_min, zoom_max + 1):
        x_min, y_max = deg2tile(lat_min, lon_min, z)
        x_max, y_min = deg2tile(lat_max, lon_max, z)
        if x_min > x_max:
            x_min, x_max = x_max, x_min
        if y_min > y_max:
            y_min, y_max = y_max, y_min
        for x in range(x_min, x_max + 1):
            for y in range(y_min, y_max + 1):
                yield z, x, y


# ─── Tile Downloader ─────────────────────────────────────────────────

def download_tile(z, x, y, cache_dir, server_url=TILE_SERVER):
    """Download a single tile and save to cache directory.

    Saves in Qt Location's OSM offline format:
        {cache_dir}/osm_100-l-1-{z}-{x}-{y}.png

    Also saves in standard z/x/y format for alternative use.
    """
    # Qt offline format
    qt_filename = f"osm_100-l-1-{z}-{x}-{y}.png"
    qt_path = os.path.join(cache_dir, qt_filename)

    # Standard z/x/y format (backup / alternative)
    std_dir = os.path.join(cache_dir, "standard", str(z), str(x))
    std_path = os.path.join(std_dir, f"{y}.png")

    # Skip if already cached
    if os.path.exists(qt_path):
        return True, "cached"

    url = server_url.format(z=z, x=x, y=y)

    for attempt in range(MAX_RETRIES):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
            ctx = ssl.create_default_context()
            with urllib.request.urlopen(req, context=ctx, timeout=15) as resp:
                data = resp.read()

            # Save Qt format
            os.makedirs(os.path.dirname(qt_path) or cache_dir, exist_ok=True)
            with open(qt_path, "wb") as f:
                f.write(data)

            # Save standard format
            os.makedirs(std_dir, exist_ok=True)
            with open(std_path, "wb") as f:
                f.write(data)

            return True, "downloaded"

        except Exception as e:
            if attempt < MAX_RETRIES - 1:
                time.sleep(1)
            else:
                return False, str(e)

    return False, "max retries exceeded"


# ─── Progress Bar ────────────────────────────────────────────────────

def progress_bar(current, total, width=40, prefix=""):
    """Print a nice progress bar."""
    pct = current / total if total > 0 else 1
    filled = int(width * pct)
    bar = "█" * filled + "░" * (width - filled)
    size_mb = get_cache_size_mb(args.cache_dir) if 'args' in dir() else 0
    sys.stdout.write(f"\r  {prefix} [{bar}] {current}/{total} ({pct*100:.1f}%)")
    sys.stdout.flush()


def get_cache_size_mb(cache_dir):
    """Get total size of cache directory in MB."""
    total = 0
    for dirpath, _, filenames in os.walk(cache_dir):
        for f in filenames:
            fp = os.path.join(dirpath, f)
            if os.path.isfile(fp):
                total += os.path.getsize(fp)
    return total / (1024 * 1024)


# ─── Main ────────────────────────────────────────────────────────────

def main():
    global args

    parser = argparse.ArgumentParser(
        description="Download and cache map tiles for SDDM World Map Theme",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Available regions:
  world     - Global overview (zoom 0-4)
  asia      - India, China, Japan, Korea, SE Asia, Singapore
  europe    - UK, France, Germany, Italy, Spain, Netherlands, Scandinavia
  americas  - USA (East/West/Central), Canada, Mexico, Brazil, Argentina
  mideast   - UAE, Saudi Arabia, broader Middle East
  africa    - Egypt, South Africa, Nigeria, East Africa
  oceania   - Australia, New Zealand

Examples:
  %(prog)s                                # Cache all regions
  %(prog)s --regions world asia europe    # Only world + Asia + Europe
  %(prog)s --zoom-max 5                   # Lower detail, smaller cache
  %(prog)s --dry-run                      # See what would be downloaded
        """
    )
    parser.add_argument(
        "--cache-dir", default=DEFAULT_CACHE_DIR,
        help=f"Directory to store cached tiles (default: {DEFAULT_CACHE_DIR})"
    )
    parser.add_argument(
        "--regions", nargs="+", default=list(REGIONS.keys()),
        choices=list(REGIONS.keys()),
        help="Regions to cache (default: all)"
    )
    parser.add_argument(
        "--zoom-max", type=int, default=None,
        help="Override maximum zoom level for all regions"
    )
    parser.add_argument(
        "--zoom-min", type=int, default=None,
        help="Override minimum zoom level for all regions"
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Show what would be downloaded without downloading"
    )
    parser.add_argument(
        "--delay", type=float, default=REQUEST_DELAY,
        help=f"Delay between requests in seconds (default: {REQUEST_DELAY})"
    )

    args = parser.parse_args()

    print()
    print("  ╔════════════════════════════════════════════════╗")
    print("  ║   🌍 SDDM World Map — Tile Cache Downloader  ║")
    print("  ╚════════════════════════════════════════════════╝")
    print()
    print(f"  Cache directory: {args.cache_dir}")
    print(f"  Regions:         {', '.join(args.regions)}")
    print()

    # ── Calculate total tiles ──
    total_tiles = 0
    region_counts = {}

    for region_name in args.regions:
        region_total = 0
        for name, lat_min, lat_max, lon_min, lon_max, z_min, z_max in REGIONS[region_name]:
            if args.zoom_max is not None:
                z_max = min(z_max, args.zoom_max)
            if args.zoom_min is not None:
                z_min = max(z_min, args.zoom_min)
            if z_min > z_max:
                continue
            region_total += count_tiles_for_region(lat_min, lat_max, lon_min, lon_max, z_min, z_max)
        region_counts[region_name] = region_total
        total_tiles += region_total

    # ── Print summary ──
    print("  ┌──────────────────────────────────────────┐")
    print("  │  Region            │  Tiles              │")
    print("  ├──────────────────────────────────────────┤")
    for rn, rc in region_counts.items():
        print(f"  │  {rn:<18} │  {rc:>8,} tiles       │")
    print("  ├──────────────────────────────────────────┤")
    print(f"  │  {'TOTAL':<18} │  {total_tiles:>8,} tiles       │")
    est_mb = total_tiles * 15 / 1024  # ~15KB per tile average
    print(f"  │  {'Est. size':<18} │  ~{est_mb:>6.0f} MB           │")
    print("  └──────────────────────────────────────────┘")
    print()

    if args.dry_run:
        print("  ℹ️  Dry run — no tiles downloaded.")
        return

    # ── Create cache directory ──
    os.makedirs(args.cache_dir, exist_ok=True)

    # ── Download tiles ──
    downloaded = 0
    skipped = 0
    failed = 0
    current = 0

    for region_name in args.regions:
        print(f"\n  📍 Region: {region_name}")

        for name, lat_min, lat_max, lon_min, lon_max, z_min, z_max in REGIONS[region_name]:
            if args.zoom_max is not None:
                z_max = min(z_max, args.zoom_max)
            if args.zoom_min is not None:
                z_min = max(z_min, args.zoom_min)
            if z_min > z_max:
                continue

            area_count = count_tiles_for_region(lat_min, lat_max, lon_min, lon_max, z_min, z_max)
            print(f"\n     🗺️  {name} (zoom {z_min}-{z_max}, {area_count:,} tiles)")

            area_current = 0
            for z, x, y in get_tiles_for_region(lat_min, lat_max, lon_min, lon_max, z_min, z_max):
                current += 1
                area_current += 1

                success, status = download_tile(z, x, y, args.cache_dir)

                if success:
                    if status == "cached":
                        skipped += 1
                    else:
                        downloaded += 1
                        time.sleep(args.delay)
                else:
                    failed += 1

                if area_current % 10 == 0 or area_current == area_count:
                    progress_bar(area_current, area_count, prefix=name[:15].ljust(15))

            print()  # newline after progress bar

    # ── Final summary ──
    cache_mb = get_cache_size_mb(args.cache_dir)
    print()
    print("  ╔════════════════════════════════════════════╗")
    print("  ║             📊 Cache Complete              ║")
    print("  ╠════════════════════════════════════════════╣")
    print(f"  ║  ✅ Downloaded:  {downloaded:>8,} tiles             ║")
    print(f"  ║  ⏭️  Skipped:     {skipped:>8,} tiles (cached)    ║")
    print(f"  ║  ❌ Failed:      {failed:>8,} tiles             ║")
    print(f"  ║  💾 Cache size:  {cache_mb:>8.1f} MB               ║")
    print("  ╚════════════════════════════════════════════╝")
    print()

    if failed > 0:
        print(f"  ⚠️  {failed} tiles failed to download. Re-run the script to retry.")
        print()

    print("  ✅ Your SDDM world map theme can now work offline!")
    print(f"  📁 Tiles cached in: {args.cache_dir}")
    print()


if __name__ == "__main__":
    main()
