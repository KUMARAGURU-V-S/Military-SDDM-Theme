#!/usr/bin/env bash
#
# SDDM World Map Theme — Installer
# ═══════════════════════════════════
#
# Usage:
#   sudo ./install.sh              # Install theme + cache tiles
#   sudo ./install.sh --no-cache   # Install theme only (needs network at login)
#   sudo ./install.sh --uninstall  # Remove theme
#

set -euo pipefail

THEME_NAME="sddm-worldmap-theme"
THEME_DIR="/usr/share/sddm/themes/${THEME_NAME}"
CACHE_DIR="/var/cache/sddm-worldmap-tiles"
SDDM_CONF="/etc/sddm.conf.d/worldmap-theme.conf"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ─── Colors ──────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "  ${CYAN}ℹ${NC}  $*"; }
success() { echo -e "  ${GREEN}✅${NC} $*"; }
warn()    { echo -e "  ${YELLOW}⚠️${NC}  $*"; }
error()   { echo -e "  ${RED}❌${NC} $*"; }

# ─── Check root ──────────────────────────────
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (sudo)"
        exit 1
    fi
}

# ─── Check dependencies ─────────────────────
check_deps() {
    echo
    echo -e "  ${BOLD}Checking dependencies...${NC}"
    echo

    local missing=()

    # Check for SDDM
    if ! command -v sddm &>/dev/null && ! command -v sddm-greeter &>/dev/null; then
        missing+=("sddm")
    else
        success "SDDM found"
    fi

    # Check for Qt Location QML module
    local qt_loc_found=false
    for path in \
        /usr/lib/qt/qml/QtLocation \
        /usr/lib/x86_64-linux-gnu/qt5/qml/QtLocation \
        /usr/lib64/qt5/qml/QtLocation \
        /usr/lib/qt5/qml/QtLocation \
        /usr/lib/qt6/qml/QtLocation \
        /usr/lib/x86_64-linux-gnu/qt6/qml/QtLocation; do
        if [[ -d "$path" ]]; then
            qt_loc_found=true
            break
        fi
    done

    if $qt_loc_found; then
        success "Qt Location module found"
    else
        missing+=("qt-location")
        warn "Qt Location QML module not found"
    fi

    # Check for Qt Positioning QML module
    local qt_pos_found=false
    for path in \
        /usr/lib/qt/qml/QtPositioning \
        /usr/lib/x86_64-linux-gnu/qt5/qml/QtPositioning \
        /usr/lib64/qt5/qml/QtPositioning \
        /usr/lib/qt5/qml/QtPositioning \
        /usr/lib/qt6/qml/QtPositioning \
        /usr/lib/x86_64-linux-gnu/qt6/qml/QtPositioning; do
        if [[ -d "$path" ]]; then
            qt_pos_found=true
            break
        fi
    done

    if $qt_pos_found; then
        success "Qt Positioning module found"
    else
        missing+=("qt-positioning")
        warn "Qt Positioning QML module not found"
    fi

    # Check Python (for cache script)
    if command -v python3 &>/dev/null; then
        success "Python 3 found"
    else
        warn "Python 3 not found (needed for tile caching)"
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo
        warn "Missing dependencies: ${missing[*]}"
        echo
        echo "  Install them with:"
        echo
        echo "  ${BOLD}Arch Linux (Qt 6):${NC}"
        echo "    sudo pacman -S qt6-location qt6-positioning qt6-declarative sddm"
        echo
        echo "  ${BOLD}Ubuntu/Debian:${NC}"
        echo "    sudo apt install qml-module-qtlocation qml-module-qtpositioning sddm"
        echo
        echo "  ${BOLD}Fedora:${NC}"
        echo "    sudo dnf install qt5-qtlocation sddm"
        echo

        if [[ " ${missing[*]} " == *" sddm "* ]]; then
            error "SDDM is required. Install it first."
            exit 1
        fi

        read -p "  Continue anyway? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# ─── Install theme ──────────────────────────
install_theme() {
    echo
    echo -e "  ${BOLD}Installing theme...${NC}"
    echo

    # Copy theme files
    mkdir -p "$THEME_DIR"
    cp -r "${SCRIPT_DIR}/Main.qml" "$THEME_DIR/"
    cp -r "${SCRIPT_DIR}/metadata.desktop" "$THEME_DIR/"
    cp -r "${SCRIPT_DIR}/theme.conf" "$THEME_DIR/"
    cp -r "${SCRIPT_DIR}/cache_tiles.py" "$THEME_DIR/"

    # Copy tiles directory if it exists
    if [[ -d "${SCRIPT_DIR}/tiles" ]]; then
        cp -r "${SCRIPT_DIR}/tiles" "$THEME_DIR/"
    else
        mkdir -p "$THEME_DIR/tiles"
    fi

    # Create cache directory
    mkdir -p "$CACHE_DIR"
    chmod 755 "$CACHE_DIR"

    # Set permissions
    chmod -R 644 "$THEME_DIR"/*.qml "$THEME_DIR"/*.conf "$THEME_DIR"/*.desktop
    chmod 755 "$THEME_DIR" "$THEME_DIR/tiles"
    chmod 755 "$THEME_DIR/cache_tiles.py"

    success "Theme files installed to $THEME_DIR"

    # Configure SDDM to use this theme
    mkdir -p "$(dirname "$SDDM_CONF")"
    cat > "$SDDM_CONF" << EOF
[Theme]
Current=${THEME_NAME}
EOF
    success "SDDM configured to use ${THEME_NAME}"
}

# ─── Cache tiles ─────────────────────────────
cache_tiles() {
    echo
    echo -e "  ${BOLD}Caching map tiles for offline use...${NC}"
    echo

    if command -v python3 &>/dev/null; then
        python3 "${THEME_DIR}/cache_tiles.py" --cache-dir "$CACHE_DIR"
    else
        warn "Python 3 not available. Skipping tile caching."
        warn "The theme will download tiles on-demand (requires network at login)."
        echo
        echo "  To cache tiles later, install Python 3 and run:"
        echo "    sudo python3 ${THEME_DIR}/cache_tiles.py"
    fi
}

# ─── Uninstall ───────────────────────────────
uninstall_theme() {
    echo
    echo -e "  ${BOLD}Uninstalling SDDM World Map theme...${NC}"
    echo

    if [[ -d "$THEME_DIR" ]]; then
        rm -rf "$THEME_DIR"
        success "Theme directory removed"
    fi

    if [[ -f "$SDDM_CONF" ]]; then
        rm -f "$SDDM_CONF"
        success "SDDM configuration removed"
    fi

    read -p "  Remove cached tiles ($CACHE_DIR)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$CACHE_DIR"
        success "Tile cache removed"
    fi

    echo
    success "Theme uninstalled. Restart SDDM to apply changes."
    echo "    sudo systemctl restart sddm"
    echo
}

# ─── Test mode ───────────────────────────────
test_theme() {
    echo
    echo -e "  ${BOLD}Testing theme...${NC}"
    echo

    local greeter=""
    if command -v sddm-greeter-qt6 &>/dev/null; then
        greeter="sddm-greeter-qt6"
    elif command -v sddm-greeter &>/dev/null; then
        greeter="sddm-greeter"
    else
        error "sddm-greeter not found"
        exit 1
    fi

    info "Launching theme in test mode (window preview)..."
    info "Close the window when done."
    echo
    $greeter --test-mode --theme "$THEME_DIR"
}

# ─── Main ────────────────────────────────────

echo
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║   🌍 SDDM World Map Theme — Installer       ║"
echo "  ╚══════════════════════════════════════════════╝"

case "${1:-}" in
    --uninstall|-u)
        check_root
        uninstall_theme
        ;;
    --test|-t)
        test_theme
        ;;
    --no-cache)
        check_root
        check_deps
        install_theme
        echo
        success "Theme installed (without tile cache)."
        warn "The login screen needs network access for map tiles."
        echo
        echo "  To cache tiles later:"
        echo "    sudo python3 ${THEME_DIR}/cache_tiles.py"
        echo
        echo "  To test the theme:"
        echo "    sddm-greeter --test-mode --theme ${THEME_DIR}"
        echo
        echo "  To activate, restart SDDM:"
        echo "    sudo systemctl restart sddm"
        echo
        ;;
    --help|-h)
        echo
        echo "  Usage: sudo ./install.sh [OPTION]"
        echo
        echo "  Options:"
        echo "    (none)        Install theme and cache tiles"
        echo "    --no-cache    Install theme without caching tiles"
        echo "    --test, -t    Test the theme in a window"
        echo "    --uninstall   Remove the theme"
        echo "    --help        Show this help"
        echo
        ;;
    *)
        check_root
        check_deps
        install_theme
        cache_tiles
        echo
        success "🎉 Installation complete!"
        echo
        echo "  To test the theme (without logging out):"
        echo "    sddm-greeter --test-mode --theme ${THEME_DIR}"
        echo
        echo "  To activate, restart SDDM:"
        echo "    sudo systemctl restart sddm"
        echo
        echo "  To uninstall:"
        echo "    sudo ./install.sh --uninstall"
        echo
        ;;
esac
