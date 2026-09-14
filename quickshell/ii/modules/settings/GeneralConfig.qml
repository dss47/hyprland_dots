import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

ContentPage {
    forceWidth: true

    Process {
        id: translationProc
        property string locale: ""
        command: [Directories.aiTranslationScriptPath, translationProc.locale]
    }

    ContentSection {
        icon: "volume_up"
        title: Translation.tr("Audio")

        ConfigSwitch {
            buttonIcon: "hearing"
            text: Translation.tr("Earbang protection")
            checked: Config.options.audio.protection.enable
            onCheckedChanged: {
                Config.options.audio.protection.enable = checked;
            }
            StyledToolTip {
                text: Translation.tr("Prevents abrupt increments and restricts volume limit")
            }
        }
        ConfigRow {
            enabled: Config.options.audio.protection.enable
            ConfigSpinBox {
                icon: "arrow_warm_up"
                text: Translation.tr("Max allowed increase")
                value: Config.options.audio.protection.maxAllowedIncrease
                from: 0
                to: 100
                stepSize: 2
                onValueChanged: {
                    Config.options.audio.protection.maxAllowedIncrease = value;
                }
            }
            ConfigSpinBox {
                icon: "vertical_align_top"
                text: Translation.tr("Volume limit")
                value: Config.options.audio.protection.maxAllowed
                from: 0
                to: 154 // pavucontrol allows up to 153%
                stepSize: 2
                onValueChanged: {
                    Config.options.audio.protection.maxAllowed = value;
                }
            }
        }
    }

    ContentSection {
        icon: "battery_android_full"
        title: Translation.tr("Battery")

        ConfigRow {
            uniform: true
            ConfigSpinBox {
                icon: "warning"
                text: Translation.tr("Low warning")
                value: Config.options.battery.low
                from: 0
                to: 100
                stepSize: 5
                onValueChanged: {
                    Config.options.battery.low = value;
                }
            }
            ConfigSpinBox {
                icon: "dangerous"
                text: Translation.tr("Critical warning")
                value: Config.options.battery.critical
                from: 0
                to: 100
                stepSize: 5
                onValueChanged: {
                    Config.options.battery.critical = value;
                }
            }
        }
        ConfigRow {
            uniform: false
            Layout.fillWidth: false
            ConfigSwitch {
                buttonIcon: "pause"
                text: Translation.tr("Automatic suspend")
                checked: Config.options.battery.automaticSuspend
                onCheckedChanged: {
                    Config.options.battery.automaticSuspend = checked;
                }
                StyledToolTip {
                    text: Translation.tr("Automatically suspends the system when battery is low")
                }
            }
            ConfigSpinBox {
                enabled: Config.options.battery.automaticSuspend
                text: Translation.tr("at")
                value: Config.options.battery.suspend
                from: 0
                to: 100
                stepSize: 5
                onValueChanged: {
                    Config.options.battery.suspend = value;
                }
            }
        }
        ConfigRow {
            uniform: true
            ConfigSpinBox {
                icon: "charger"
                text: Translation.tr("Full warning")
                value: Config.options.battery.full
                from: 0
                to: 101
                stepSize: 5
                onValueChanged: {
                    Config.options.battery.full = value;
                }
            }
        }
    }

    ContentSection {
        icon: "language"
        title: Translation.tr("Language")

        ContentSubsection {
            title: Translation.tr("Interface Language")
            tooltip: Translation.tr("Select the language for the user interface.\n\"Auto\" will use your system's locale.")

            StyledComboBox {
                id: languageSelector
                buttonIcon: "language"
                textRole: "displayName"

                model: [
                    {
                        displayName: Translation.tr("Auto (System)"),
                        value: "auto"
                    },
                    ...Translation.allAvailableLanguages.map(lang => {
                        return {
                            displayName: lang,
                            value: lang
                        };
                    })]

                currentIndex: {
                    const index = model.findIndex(item => item.value === Config.options.language.ui);
                    return index !== -1 ? index : 0;
                }

                onActivated: index => {
                    Config.options.language.ui = model[index].value;
                }
            }
        }
        ContentSubsection {
            title: Translation.tr("Generate translation with Gemini")
            tooltip: Translation.tr("You'll need to enter your Gemini API key first.\nType /key on the sidebar for instructions.")

            ConfigRow {
                MaterialTextArea {
                    id: localeInput
                    Layout.fillWidth: true
                    placeholderText: Translation.tr("Locale code, e.g. fr_FR, de_DE, zh_CN...")
                    text: Config.options.language.ui === "auto" ? Qt.locale().name : Config.options.language.ui
                }
                RippleButtonWithIcon {
                    id: generateTranslationBtn
                    Layout.fillHeight: true
                    nerdIcon: ""
                    enabled: !translationProc.running || (translationProc.locale !== localeInput.text.trim())
                    mainText: enabled ? Translation.tr("Generate\nTypically takes 2 minutes") : Translation.tr("Generating...\nDon't close this window!")
                    onClicked: {
                        translationProc.locale = localeInput.text.trim();
                        translationProc.running = false;
                        translationProc.running = true;
                    }
                }
            }
        }
    }

    ContentSection {
        icon: "rule"
        title: Translation.tr("Policies")

        ConfigRow {

            // AI policy
            ColumnLayout {
                ContentSubsectionLabel {
                    text: Translation.tr("AI")
                }

                ConfigSelectionArray {
                    currentValue: Config.options.policies.ai
                    onSelected: newValue => {
                        Config.options.policies.ai = newValue;
                    }
                    options: [
                        {
                            displayName: Translation.tr("No"),
                            icon: "close",
                            value: 0
                        },
                        {
                            displayName: Translation.tr("Yes"),
                            icon: "check",
                            value: 1
                        },
                        {
                            displayName: Translation.tr("Local only"),
                            icon: "sync_saved_locally",
                            value: 2
                        }
                    ]
                }
            }

            // Weeb policy
            ColumnLayout {

                ContentSubsectionLabel {
                    text: Translation.tr("Weeb")
                }

                ConfigSelectionArray {
                    currentValue: Config.options.policies.weeb
                    onSelected: newValue => {
                        Config.options.policies.weeb = newValue;
                    }
                    options: [
                        {
                            displayName: Translation.tr("No"),
                            icon: "close",
                            value: 0
                        },
                        {
                            displayName: Translation.tr("Yes"),
                            icon: "check",
                            value: 1
                        },
                        {
                            displayName: Translation.tr("Closet"),
                            icon: "ev_shadow",
                            value: 2
                        }
                    ]
                }
            }
        }
    }

    ContentSection {
        icon: "notification_sound"
        title: Translation.tr("Sounds")
        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "battery_android_full"
                text: Translation.tr("Battery")
                checked: Config.options.sounds.battery
                onCheckedChanged: {
                    Config.options.sounds.battery = checked;
                }
            }
            ConfigSwitch {
                buttonIcon: "av_timer"
                text: Translation.tr("Pomodoro")
                checked: Config.options.sounds.pomodoro
                onCheckedChanged: {
                    Config.options.sounds.pomodoro = checked;
                }
            }
        }
    }

    ContentSection {
        icon: "nest_clock_farsight_analog"
        title: Translation.tr("Time")

        ConfigSwitch {
            buttonIcon: "pace"
            text: Translation.tr("Second precision")
            checked: Config.options.time.secondPrecision
            onCheckedChanged: {
                Config.options.time.secondPrecision = checked;
            }
            StyledToolTip {
                text: Translation.tr("Enable if you want clocks to show seconds accurately")
            }
        }

        ContentSubsection {
            title: Translation.tr("Format")
            tooltip: ""

            ConfigSelectionArray {
                currentValue: Config.options.time.format
                onSelected: newValue => {
                    if (newValue === "hh:mm") {
                        Quickshell.execDetached(["bash", "-c", `sed -i 's/\\TIME12\\b/TIME/' '${FileUtils.trimFileProtocol(Directories.config)}/hypr/hyprlock.conf'`]);
                    } else {
                        Quickshell.execDetached(["bash", "-c", `sed -i 's/\\TIME\\b/TIME12/' '${FileUtils.trimFileProtocol(Directories.config)}/hypr/hyprlock.conf'`]);
                    }

                    Config.options.time.format = newValue;
                }
                options: [
                    {
                        displayName: Translation.tr("24h"),
                        value: "hh:mm"
                    },
                    {
                        displayName: Translation.tr("12h am/pm"),
                        value: "h:mm ap"
                    },
                    {
                        displayName: Translation.tr("12h AM/PM"),
                        value: "h:mm AP"
                    },
                ]
            }
        }
    }

    ContentSection {
        icon: "work_alert"
        title: Translation.tr("Work safety")

        ConfigSwitch {
            buttonIcon: "assignment"
            text: Translation.tr("Hide clipboard images copied from sussy sources")
            checked: Config.options.workSafety.enable.clipboard
            onCheckedChanged: {
                Config.options.workSafety.enable.clipboard = checked;
            }
        }
        ConfigSwitch {
            buttonIcon: "wallpaper"
            text: Translation.tr("Hide sussy/anime wallpapers")
            checked: Config.options.workSafety.enable.wallpaper
            onCheckedChanged: {
                Config.options.workSafety.enable.wallpaper = checked;
            }
        }
    }

    // ── Display & Monitors ──
    ContentSection {
        icon: "monitor"
        title: Translation.tr("Display & Monitors")

        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "sync"
                text: Translation.tr("VRR (Adaptive Sync)")
                checked: true
                onCheckedChanged: {
                    var v = checked ? 2 : 0;
                    Quickshell.execDetached(["bash", "-c", `sed -i 's/vrr = [0-9]*/vrr = ${v}/' ~/.config/hypr/custom/general.lua && hyprctl reload`]);
                }
                StyledToolTip {
                    text: Translation.tr("Enables Variable Refresh Rate / FreeSync / G-Sync for smooth gaming")
                }
            }
            ConfigSwitch {
                buttonIcon: "screen_rotation"
                text: Translation.tr("Tearing (Low Latency)")
                checked: true
                onCheckedChanged: {
                    Quickshell.execDetached(["bash", "-c", `sed -i 's/allow_tearing = [a-z]*/allow_tearing = ${checked}/' ~/.config/hypr/custom/general.lua && hyprctl reload`]);
                }
                StyledToolTip {
                    text: Translation.tr("Reduces input latency in full-screen games")
                }
            }
        }
    }

    // ── Power & Inactivity ──
    ContentSection {
        icon: "power_settings_new"
        title: Translation.tr("Power & Screen Timeout")

        ConfigRow {
            uniform: true
            ConfigSpinBox {
                icon: "timer"
                text: Translation.tr("Screen off timeout (minutes)")
                value: 10
                from: 1
                to: 120
                stepSize: 5
                onValueChanged: {
                    Quickshell.execDetached(["bash", "-c", `sed -i 's/timeout = [0-9]*/timeout = ${value * 60}/' ~/.config/hypr/hypridle.conf 2>/dev/null || true`]);
                }
            }
            ConfigSpinBox {
                icon: "bedtime"
                text: Translation.tr("Suspend timeout (minutes)")
                value: 30
                from: 5
                to: 240
                stepSize: 10
                onValueChanged: {
                    Quickshell.execDetached(["bash", "-c", `sed -i 's/timeout = [0-9]*/timeout = ${value * 60}/' ~/.config/hypr/hypridle.conf 2>/dev/null || true`]);
                }
            }
        }
    }

    // ── Display Resolution & Scale ──
    ContentSection {
        icon: "display_settings"
        title: Translation.tr("Display Resolution & Scale")

        ConfigRow {
            uniform: true
            ContentSubsection {
                title: Translation.tr("Refresh Rate")
                ConfigSelectionArray {
                    currentValue: "60"
                    onSelected: newValue => {
                        Quickshell.execDetached(["bash", "-c", `hyprctl keyword monitor ",preferred,auto,1,vrr,2" 2>/dev/null || true`]);
                    }
                    options: [
                        { displayName: "60 Hz", value: "60" },
                        { displayName: "120 Hz", value: "120" },
                        { displayName: "144 Hz", value: "144" },
                        { displayName: "165 Hz", value: "165" },
                        { displayName: "Auto", value: "auto" }
                    ]
                }
            }

            ContentSubsection {
                title: Translation.tr("Display Scale")
                ConfigSelectionArray {
                    currentValue: "1"
                    onSelected: newValue => {
                        Quickshell.execDetached(["bash", "-c", `hyprctl keyword monitor ",preferred,auto,${newValue}" 2>/dev/null || true`]);
                    }
                    options: [
                        { displayName: "100%", value: "1" },
                        { displayName: "125%", value: "1.25" },
                        { displayName: "150%", value: "1.5" },
                        { displayName: "175%", value: "1.75" },
                        { displayName: "200%", value: "2" }
                    ]
                }
            }
        }
    }

    // ── Night Light / Blue Light Filter ──
    ContentSection {
        icon: "nightlight"
        title: Translation.tr("Night Light & Color Temperature")

        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "wb_sunny"
                text: Translation.tr("Night light filter")
                checked: false
                onCheckedChanged: {
                    if (checked) {
                        Quickshell.execDetached(["bash", "-c", "hyprsunset -t 4500 2>/dev/null || gammastep -O 4500 &"]);
                    } else {
                        Quickshell.execDetached(["bash", "-c", "pkill -f hyprsunset ; pkill -f gammastep"]);
                    }
                }
                StyledToolTip {
                    text: Translation.tr("Reduces blue light at night to reduce eye strain")
                }
            }

            ConfigSpinBox {
                icon: "thermostat"
                text: Translation.tr("Color temperature (K)")
                value: 4500
                from: 2500
                to: 6500
                stepSize: 250
                onValueChanged: {
                    Quickshell.execDetached(["bash", "-c", `pkill -f hyprsunset ; pkill -f gammastep ; hyprsunset -t ${value} 2>/dev/null || gammastep -O ${value} &`]);
                }
            }
        }
    }

    // ── Wireless & Bluetooth Quick Toggles ──
    ContentSection {
        icon: "wifi"
        title: Translation.tr("Network & Connectivity")

        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "wifi"
                text: Translation.tr("Wi-Fi Radio")
                checked: true
                onCheckedChanged: {
                    var state = checked ? "on" : "off";
                    Quickshell.execDetached(["nmcli", "radio", "wifi", state]);
                }
            }

            ConfigSwitch {
                buttonIcon: "bluetooth"
                text: Translation.tr("Bluetooth Radio")
                checked: true
                onCheckedChanged: {
                    var state = checked ? "unblock" : "block";
                    Quickshell.execDetached(["rfkill", state, "bluetooth"]);
                }
            }
        }

        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "airplanemode_active"
                text: Translation.tr("Airplane Mode")
                checked: false
                onCheckedChanged: {
                    var state = checked ? "block" : "unblock";
                    Quickshell.execDetached(["rfkill", state, "all"]);
                }
                StyledToolTip {
                    text: Translation.tr("Disables all wireless communications (Wi-Fi, Bluetooth, Cellular)")
                }
            }
        }
    }
}
