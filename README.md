# 🇮🇳 Military SDDM Theme (NIA Tactical Login)

A high-security, authentic tactical military SDDM login theme built with pure **Qt 6 / QML**, **QtLocation**, and **QtPositioning** without heavy web engines. Featuring the **National Investigation Agency (NIA)** emblem, state-machine security protocols, and an interactive satellite surveillance and laser-targeting sequence.

---

## 🎨 Visual Design & Architecture

### Case 1: Central Command Authentication Terminal
- **Background:** Deep military stealth charcoal (`#080a08`) with tactical reticle crosshairs.
- **Centerpiece:** National Investigation Agency (NIA) vector SVG emblem enlarged to **250px** for commanding visual authority.
- **Login Prompts:** Tactical monospace input fields (`OPERATOR //:` and `PASSCODE //:`) positioned directly beneath the emblem, with night-vision phosphor green active focus highlights.
- **Action Button:** Grammatically precise military command: **`[ AUTHENTICATE ]`** (configurable to `[ LOG IN ]` with proper verb spacing).
- **Session & Power Controls:**
  - Tactical Desktop Session Selector: `SESSION //: [ PLASMA (WAYLAND) ▾ ]`.
  - Military Power Station: `[ ⏻ SHUTDOWN ]`, `[ ⟳ REBOOT ]`, `[ ⏾ SLEEP ]`.
- **UI Toggle:** Bottom-right corner military radio switch labeled `Turn on Fun Mode` $\rightarrow$ arms to `[ FUN MODE: ARMED ]` with crimson beacon.

---

### Case 2: Tactical Satellite Reconnaissance & Laser Sequence
When Fun Mode is armed and authentication fails (or upon direct trigger):
1. Error changes to `"Login Attempt Failed"` in glowing alert red (`#ff0033`).
2. Rapidly blinks **exactly 3 times**.
3. Seamlessly triggers **Case 2**:
   - **Interactive Base Map:** Live OpenStreetMap layer starting from a global orbital perspective.
   - **Geographical Pan & Zoom:** Animates dynamically to center on India ($23.5937^\circ\text{ N}, 78.9629^\circ\text{ E}$) at zoom $5.5$.
   - **Satellite Deployment:** `GSAT-7A // MIL-ORBIT` (`MapQuickItem`) flies across real-world GPS coordinates into northern India airspace ($34.50^\circ\text{ N}, 76.50^\circ\text{ E}$).
   - **Pulsing Ground Reticle:** Locks onto Central India Command ($21.1458^\circ\text{ N}, 79.0882^\circ\text{ E}$) with expanding radar rings and crosshairs.
   - **Laser Targeting Beam:** Fires a glowing, energy-pulsing coherent red beam (`MapPolyline`) from the satellite directly into the ground target.
   - **Tactical HUD Feed:** Top-left semi-transparent red console typing out live synchronized events:
     * `> INITIALIZING ORBITAL TRACKING...`
     * `> SATELLITE UPLINK ESTABLISHED.`
     * `> SECURING ENCRYPTED CHANNELS...`
     * `> ACQUIRING GPS COORDINATES...`
     * `> TRIANGULATING TRAJECTORY...`
     * `> TARGET LOCKED.`
   - **Live Cursor Telemetry:** Real-time GPS coordinate reader tracking cursor hover across the map.

---

## 🚀 Quick Installation

To install and activate the theme on your system:

```bash
cd /mnt/linux_d_drive/Github/Military-SDDM-Theme
sudo ./install.sh
```

*(Optional: use `./install.sh --no-cache` to skip tile pre-downloading, or `./install.sh --uninstall` to remove).*

---

## 🧪 Live Preview & Testing

To test the theme in a standalone test window without logging out:

```bash
# Using Plasma 6 / Qt 6 SDDM Greeter:
sddm-greeter-qt6 --test-mode --theme /mnt/linux_d_drive/Github/Military-SDDM-Theme

# Or using qml6 directly:
cd /mnt/linux_d_drive/Github/Military-SDDM-Theme
qml6 Main.qml
```
