#!/usr/bin/env bash
#
# Military SDDM Theme (NIA Tactical Login) — Installer
# ══════════════════════════════════════════════════════
#
# Usage:
#   sudo ./install.sh              # Install theme + pre-cache India tiles
#   sudo ./install.sh --no-cache   # Install theme only
#   sudo ./install.sh --uninstall  # Remove theme and restore defaults
#

set -euo pipefail

THEME_NAME="Military-SDDM-Theme"
THEME_DIR="/usr/share/sddm/themes/${THEME_NAME}"
SDDM_CONF_DIR="/etc/sddm.conf.d"
SDDM_CONF="${SDDM_CONF_DIR}/military-theme.conf"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be executed with sudo / root privileges."
        exit 1
    fi
}

do_install() {
    local cache_tiles=true
    if [[ "${1:-}" == "--no-cache" ]]; then
        cache_tiles=false
    fi

    echo
    echo -e "  ${BOLD}🇮🇳 Installing Military SDDM Theme...${NC}"
    echo

    info "Creating theme directory at ${THEME_DIR}..."
    mkdir -p "${THEME_DIR}"

    info "Copying theme assets and QML files..."
    cp -r "${SCRIPT_DIR}/Main.qml" "${THEME_DIR}/"
    cp -r "${SCRIPT_DIR}/metadata.desktop" "${THEME_DIR}/"
    cp -r "${SCRIPT_DIR}/theme.conf" "${THEME_DIR}/"
    cp -r "${SCRIPT_DIR}/assets" "${THEME_DIR}/"

    if [[ -d "${SCRIPT_DIR}/tiles" ]]; then
        cp -r "${SCRIPT_DIR}/tiles" "${THEME_DIR}/"
    fi

    info "Activating theme in SDDM configuration..."
    mkdir -p "${SDDM_CONF_DIR}"
    cat << CONF > "${SDDM_CONF}"
[Theme]
Current=${THEME_NAME}
CONF
    success "Configured ${SDDM_CONF}"

    if [[ "$cache_tiles" == true ]] && [[ -f "${SCRIPT_DIR}/cache_tiles.py" ]]; then
        info "Pre-caching India tactical map tiles for offline boot..."
        python3 "${SCRIPT_DIR}/cache_tiles.py" --zoom-max 6 || warn "Tile caching encountered minor network warnings."
    fi

    echo
    success "Installation complete!"
    echo -e "  Test anytime using: ${BOLD}sddm-greeter-qt6 --test-mode --theme ${THEME_DIR}${NC}"
    echo
}

do_uninstall() {
    echo
    echo -e "  ${BOLD}Uninstalling Military SDDM Theme...${NC}"
    echo
    rm -rf "${THEME_DIR}"
    rm -f "${SDDM_CONF}"
    success "Military SDDM Theme removed successfully."
}

check_root

case "${1:-}" in
    --uninstall)
        do_uninstall
        ;;
    --no-cache)
        do_install "--no-cache"
        ;;
    *)
        do_install ""
        ;;
esac
