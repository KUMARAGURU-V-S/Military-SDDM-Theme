# 🇮🇳 Military SDDM Theme (NIA Tactical Login)

A tactical, high-security SDDM (Simple Desktop Display Manager) login theme based on pure Qt/QML, featuring the **National Investigation Agency (NIA)** emblem and an interactive multi-state architecture.

---

## 🎨 Visual Design (Initial State)

- **Background:** Dark military charcoal / pitch black (`#0a0a0a`).
- **Centerpiece:** The National Investigation Agency (NIA) logo rendered in crisp vector SVG format, centered on the display.
- **Login Prompts:** Clean, military-styled standard SDDM Username and Password input boxes positioned directly below the logo.
- **UI Toggle:** A sleek, unobtrusive button in the bottom-right corner: `"Turn on Fun Mode"`.

---

## ⚙️ Logic & Behavior (State Machine)

### 1. Default Mode (Fun Mode OFF)
- Operates as a standard, high-security SDDM greeter.
- Normal authentication workflow applies.
- Standard failure messages appear without extra animations.

### 2. Active Mode (Fun Mode ON)
- Clicking the bottom-right toggle enables **Fun Mode** (boolean flag = `true`).
- Visual indicator switches to active state.

### 3. Failure Sequence (When Fun Mode is ON and Login Fails)
1. **Error Text Update:** Text directly below the password box changes to `"Login Attempt Failed"`.
2. **Alert Glow:** Color immediately shifts to a glowing tactical **RED** (`#ff0033`).
3. **Rapid Blinking:** A fast opacity animation causes the red alert text to blink rapidly **exactly 3 times**.
4. **Trigger Case 2:** Immediately following the 3rd blink, the system triggers **"Case 2"** (the tactical interactive OpenStreetMap satellite and laser sequence).

---

## 📁 Repository Structure

```
Military-SDDM-Theme/
├── Main.qml                # Primary SDDM QML script with state machine
├── metadata.desktop        # SDDM theme metadata
├── theme.conf              # Theme configuration properties
├── assets/
│   ├── NIA-logo.svg        # Centered SVG logo
│   └── NIA-logo.png        # Source high-resolution PNG
├── raw-sddm-prototype/     # Prototype reference assets
└── v1/
    └── sddm-worldmap-theme/ # Archived v1 World Map interactive theme
```

---

## 🧪 Testing the Theme

To test without logging out:

```bash
# Using sddm-greeter test mode
sddm-greeter --test-mode --theme /mnt/linux_d_drive/Github/Military-SDDM-Theme

# Or using qml6
QT_QPA_PLATFORM=xcb qml6 Main.qml
```
