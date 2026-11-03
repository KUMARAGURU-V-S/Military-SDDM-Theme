# 🌍 SDDM World Map Interactive Theme

A custom SDDM (Simple Desktop Display Manager) login theme featuring an **interactive, zoomable world map** as the background with country quick-navigation, smooth animations, and offline tile caching.

![Theme Preview](preview.png)

## ✨ Features

- **Interactive World Map** — Pan, zoom, drag the OpenStreetMap-based map right on your login screen
- **Country Quick-Nav** — Sidebar with 25+ countries; click to smoothly zoom to any country
- **Search Filter** — Type to filter countries in the navigation panel
- **Offline Tile Cache** — Pre-download map tiles so the theme works without network at login
- **Smooth Animations** — Cinematic zoom transitions with configurable easing and duration
- **Glassmorphism UI** — Semi-transparent login card with dark cyberpunk aesthetic
- **Clock Display** — Large digital clock with date, fully customizable format
- **Session Selector** — Switch between desktop sessions (KDE, GNOME, Hyprland, etc.)
- **Power Controls** — Shutdown, restart, suspend with hover animations
- **Caps Lock Warning** — Visual alert when Caps Lock is on
- **Login Error Shake** — Card shakes on wrong credentials
- **Zoom Controls** — On-screen +/−/reset buttons plus mouse wheel zoom
- **Keyboard Shortcuts** — Escape to reset view, Tab navigation, Enter to login
- **Fully Configurable** — Colors, sizes, behavior all customizable via `theme.conf`

## 📦 Dependencies

### Required
| Package | Arch Linux (Plasma 6 / Qt 6) | Ubuntu/Debian | Fedora |
|---------|------------------------------|---------------|--------|
| SDDM | `sddm` | `sddm` | `sddm` |
| Qt Location | `qt6-location` | `qml-module-qtlocation` | `qt6-qtlocation` |
| Qt Positioning | `qt6-positioning` | `qml-module-qtpositioning` | `qt6-qtpositioning` |

### Optional
| Package | Purpose |
|---------|---------|
| Python 3 | Tile cache download script |
| Qt GraphicalEffects | Blur effects (future) |

## 🚀 Quick Install

```bash
# Clone or download this theme
cd sddm-worldmap-theme

# Install with tile caching (recommended)
sudo ./install.sh

# Or install without caching (needs network at login)
sudo ./install.sh --no-cache
```

## 📋 Manual Install

```bash
# 1. Install dependencies
# Arch:
sudo pacman -S sddm qt5-location

# Ubuntu/Debian:
sudo apt install sddm qml-module-qtlocation qml-module-qtpositioning

# 2. Copy theme files
sudo cp -r . /usr/share/sddm/themes/sddm-worldmap-theme

# 3. Set as active theme
sudo mkdir -p /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=sddm-worldmap-theme" | sudo tee /etc/sddm.conf.d/worldmap.conf

# 4. Pre-cache tiles for offline use
sudo python3 cache_tiles.py

# 5. Test without logging out
sddm-greeter --test-mode --theme /usr/share/sddm/themes/sddm-worldmap-theme

# 6. Activate
sudo systemctl restart sddm
```

## 🗺️ Tile Caching

The theme uses OpenStreetMap tiles. By default it fetches them over the network, but you can pre-cache tiles for **fully offline** operation:

```bash
# Cache all standard regions (~300-500 MB)
sudo python3 cache_tiles.py

# Cache only specific regions (smaller)
sudo python3 cache_tiles.py --regions world asia europe

# See what would be downloaded (dry run)
sudo python3 cache_tiles.py --dry-run

# Lower detail for smaller cache (~50 MB)
sudo python3 cache_tiles.py --zoom-max 5

# Custom cache directory
sudo python3 cache_tiles.py --cache-dir /custom/path
```

### Available Regions
| Region | Areas Covered |
|--------|--------------|
| `world` | Global overview (zoom 0-4) |
| `asia` | India, China, Japan, Korea, SE Asia, Singapore |
| `europe` | UK, France, Germany, Italy, Spain, Netherlands, Scandinavia |
| `americas` | USA, Canada, Mexico, Brazil, Argentina |
| `mideast` | UAE, Saudi Arabia, broader Middle East |
| `africa` | Egypt, South Africa, Nigeria, East Africa |
| `oceania` | Australia, New Zealand |

## ⚙️ Configuration

Edit `/usr/share/sddm/themes/sddm-worldmap-theme/theme.conf`:

```ini
[General]
# Colors (hex)
accentColor=#00d4ff        # Cyan accent (buttons, highlights)
backgroundColor=#0a0e17    # Deep navy background
cardColor=#1a1e2e          # Login card background
textColor=#e8e8e8          # Text color

# Login Card
cardOpacity=0.88           # Card transparency (0.0-1.0)
cardWidth=400              # Card width in pixels
cardRadius=16              # Corner radius

# Map Settings
defaultLatitude=20.0       # Initial map center latitude
defaultLongitude=0.0       # Initial map center longitude
defaultZoom=2.5            # Initial zoom level
maxZoom=12                 # Maximum zoom allowed
mapDarken=0.25             # Overlay darkness (0.0-1.0)
animationDuration=1200     # Zoom animation speed (ms)

# Country Navigation
showCountryNav=true        # Show/hide country panel
countryNavPosition=left    # "left" or "right"
countryNavWidth=220        # Panel width

# Clock
showClock=true
clockFormat=hh:mm          # Qt time format
dateFormat=dddd, MMMM d, yyyy
clockFontSize=48
```

## 🎨 Color Themes

### Cyberpunk (Default)
```ini
accentColor=#00d4ff
backgroundColor=#0a0e17
cardColor=#1a1e2e
```

### Emerald
```ini
accentColor=#2ed573
backgroundColor=#0a1710
cardColor=#1a2e1e
```

### Sunset
```ini
accentColor=#ff6348
backgroundColor=#170a0e
cardColor=#2e1a1e
```

### Purple Haze
```ini
accentColor=#a855f7
backgroundColor=#0e0a17
cardColor=#1e1a2e
```

## 🔧 Troubleshooting

### Map shows blank/gray
- Check if Qt Location is installed: `ls /usr/lib/qt/qml/QtLocation`
- Ensure network is available at boot (for first-time tile loading)
- Run the cache script: `sudo python3 cache_tiles.py`

### Theme doesn't appear in SDDM settings
- Verify files are in `/usr/share/sddm/themes/sddm-worldmap-theme/`
- Check `metadata.desktop` is present
- Run: `sddm --example-config` to see available themes

### Login doesn't work
- Check SDDM logs: `journalctl -u sddm -b`
- Test in preview mode first: `sddm-greeter --test-mode --theme /path/to/theme`

### Map is too slow
- Reduce `maxZoom` in theme.conf
- Pre-cache tiles to avoid network latency
- Set `animationsEnabled=false` to disable transitions

## 📁 File Structure

```
sddm-worldmap-theme/
├── metadata.desktop    # Theme metadata for SDDM
├── theme.conf          # User configuration
├── Main.qml            # Main theme (map + login UI)
├── cache_tiles.py      # Tile download script
├── install.sh          # Installer
├── README.md           # This file
└── tiles/              # Pre-cached tiles (populated by cache script)
```

## 📜 License

MIT License. Map tiles © OpenStreetMap contributors.

## 🙏 Credits

- Map data: [OpenStreetMap](https://www.openstreetmap.org/)
- Built with: Qt/QML, Qt Location
- Inspired by: [sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme), r/unixporn community
