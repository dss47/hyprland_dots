pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Simple polled resource usage service with RAM, Swap, and CPU usage.
 */
Singleton {
    id: root
	property real memoryTotal: 1
	property real memoryFree: 0
	property real memoryUsed: memoryTotal - memoryFree
    property real memoryUsedPercentage: memoryUsed / memoryTotal
    property real swapTotal: 1
	property real swapFree: 0
	property real swapUsed: swapTotal - swapFree
    property real swapUsedPercentage: swapTotal > 0 ? (swapUsed / swapTotal) : 0
    property real cpuUsage: 0
    property real cpuTemp: 45
    property real cpuClockGhz: 2.8
    property string cpuClockString: cpuClockGhz > 0 ? (cpuClockGhz.toFixed(2) + " GHz") : "--"
    property var previousCpuStats

    property real memoryUsedGb: memoryUsed / (1024 * 1024)
    property real memoryTotalGb: memoryTotal / (1024 * 1024)
    property string memoryUsedString: memoryUsedGb.toFixed(1) + " GB"
    property string memoryTotalString: memoryTotalGb.toFixed(1) + " GB"
    property string memoryHoverString: memoryUsedGb.toFixed(1) + " GB of " + memoryTotalGb.toFixed(1) + " GB used"

    property string maxAvailableMemoryString: kbToGbString(ResourceUsage.memoryTotal)
    property string maxAvailableSwapString: kbToGbString(ResourceUsage.swapTotal)
    property string maxAvailableCpuString: "--"

    readonly property int historyLength: Config?.options.resources.historyLength ?? 60
    property list<real> cpuUsageHistory: []
    property list<real> memoryUsageHistory: []
    property list<real> swapUsageHistory: []

    function kbToGbString(kb) {
        return (kb / (1024 * 1024)).toFixed(1) + " GB";
    }

    function updateMemoryUsageHistory() {
        memoryUsageHistory = [...memoryUsageHistory, memoryUsedPercentage]
        if (memoryUsageHistory.length > historyLength) {
            memoryUsageHistory.shift()
        }
    }
    function updateSwapUsageHistory() {
        swapUsageHistory = [...swapUsageHistory, swapUsedPercentage]
        if (swapUsageHistory.length > historyLength) {
            swapUsageHistory.shift()
        }
    }
    function updateCpuUsageHistory() {
        cpuUsageHistory = [...cpuUsageHistory, cpuUsage]
        if (cpuUsageHistory.length > historyLength) {
            cpuUsageHistory.shift()
        }
    }
    function updateHistories() {
        updateMemoryUsageHistory()
        updateSwapUsageHistory()
        updateCpuUsageHistory()
    }

	Timer {
		interval: 1
        running: true 
        repeat: true
		onTriggered: {
            // Reload files
            fileMeminfo.reload()
            fileStat.reload()
            fileCpuTemp.reload()
            fileCpuFreq.reload()

            // Parse memory and swap usage
            const textMeminfo = fileMeminfo.text()
            memoryTotal = Number(textMeminfo.match(/MemTotal: *(\d+)/)?.[1] ?? 1)
            memoryFree = Number(textMeminfo.match(/MemAvailable: *(\d+)/)?.[1] ?? 0)
            swapTotal = Number(textMeminfo.match(/SwapTotal: *(\d+)/)?.[1] ?? 1)
            swapFree = Number(textMeminfo.match(/SwapFree: *(\d+)/)?.[1] ?? 0)

            // Parse CPU usage
            const textStat = fileStat.text()
            const cpuLine = textStat.match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)
            if (cpuLine) {
                const stats = cpuLine.slice(1).map(Number)
                const total = stats.reduce((a, b) => a + b, 0)
                const idle = stats[3]

                if (previousCpuStats) {
                    const totalDiff = total - previousCpuStats.total
                    const idleDiff = idle - previousCpuStats.idle
                    cpuUsage = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0
                }

                previousCpuStats = { total, idle }
            }

            // Parse CPU Temperature
            const textTemp = fileCpuTemp.text()
            if (textTemp) {
                const rawTemp = parseInt(textTemp.trim(), 10)
                if (!isNaN(rawTemp)) {
                    cpuTemp = Math.round(rawTemp > 1000 ? rawTemp / 1000 : rawTemp)
                }
            }

            // Parse CPU Frequency
            const textFreq = fileCpuFreq.text()
            if (textFreq) {
                const rawFreq = parseInt(textFreq.trim(), 10)
                if (!isNaN(rawFreq) && rawFreq > 0) {
                    cpuClockGhz = rawFreq / 1000000
                }
            }

            root.updateHistories()
            interval = Config.options?.resources?.updateInterval ?? 3000
        }
	}

	FileView { id: fileMeminfo; path: "/proc/meminfo" }
    FileView { id: fileStat; path: "/proc/stat" }
    FileView { id: fileCpuTemp; path: "/sys/class/thermal/thermal_zone7/temp" }
    FileView { id: fileCpuFreq; path: "/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq" }

    Process {
        id: findCpuTempPathProc
        command: ["bash", "-c", "for z in /sys/class/thermal/thermal_zone*; do [ \"$(cat $z/type 2>/dev/null)\" = \"x86_pkg_temp\" ] && echo -n \"$z/temp\" && exit 0; done; echo -n '/sys/class/thermal/thermal_zone7/temp'"]
        running: true
        stdout: StdioCollector {
            id: tempPathCollector
            onStreamFinished: {
                const foundPath = tempPathCollector.text.trim()
                if (foundPath.length > 0) {
                    fileCpuTemp.path = foundPath
                    fileCpuTemp.reload()
                }
            }
        }
    }

    Process {
        id: findCpuMaxFreqProc
        environment: ({
            LANG: "C",
            LC_ALL: "C"
        })
        command: ["bash", "-c", "lscpu | grep 'CPU max MHz' | awk '{print $4}'"]
        running: true
        stdout: StdioCollector {
            id: outputCollector
            onStreamFinished: {
                root.maxAvailableCpuString = (parseFloat(outputCollector.text) / 1000).toFixed(0) + " GHz"
            }
        }
    }
}
