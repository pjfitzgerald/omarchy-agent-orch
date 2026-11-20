import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// agent-orch bar icon. State comes from `agent-orch status --json` (which checks the orchestrator's
// host over ssh and reports a local fallback when it is unreachable); every action is a fixed argv.
//
//   left click    toggle the orchestrator popout (same as SUPER+ALT+O)
//   right click   refresh now
BarWidget {
  id: root
  moduleName: "pjf.agent-orch"

  readonly property string cli: Quickshell.env("HOME") + "/dotfiles/bin/agent-orch"
  readonly property int refreshMs: Math.max(5, Number(setting("refreshIntervalSec", 20))) * 1000

  // {mode: host|fallback|local, host, orchHost, harness, orchestrator: running|exited|down, streams}
  property var st: ({})
  property bool checked: false

  function clean(v) { return String(v === undefined ? "" : v).replace(/[<>&]/g, "").slice(0, 64) }

  readonly property bool fallback: st.mode === "fallback"
  readonly property bool running: st.orchestrator === "running"
  readonly property int streams: Number(st.streams) || 0

  readonly property string stateLabel: !checked ? "Checking…"
    : !st.mode ? "agent-orch unavailable"
    : (fallback ? clean(st.orchHost) + " unreachable · local fallback on " + clean(st.host)
               : "On " + clean(st.host))
      + " · " + (running ? "running" : clean(st.orchestrator) || "down")
      + " · " + streams + (streams === 1 ? " stream" : " streams")

  function refresh() {
    if (statusProc.running) return
    statusProc.command = [cli, "status", "--json"]
    statusProc.running = true
  }

  function parse(text) {
    checked = true
    try {
      var d = JSON.parse(String(text).trim().split("\n").pop())
      st = (d && typeof d === "object") ? d : {}
    } catch (e) {
      st = {}
    }
  }

  Process {
    id: statusProc
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.parse(text) }
  }
  Process { id: openProc; command: [root.cli, "open"]; onExited: settle.restart() }
  Timer { id: settle; interval: 1500; onTriggered: root.refresh() }
  Timer {
    interval: root.refreshMs
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  IpcHandler {
    target: "pjf.agent-orch"
    function toggle(): void { if (!openProc.running) openProc.running = true }
    function refresh(): void { root.refresh() }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ""  // nf-fa-sitemap: an orchestrator over its streams
    foreground: root.fallback ? Color.urgent : (root.bar ? root.bar.barForeground : Color.foreground)
    dimmed: root.checked && !root.running
    useActiveColor: false
    tooltipText: "Orchestrator · " + root.stateLabel + "\nClick: popout (SUPER+ALT+O) · right-click: refresh"
    onPressed: function(b) {
      if (b === Qt.RightButton) root.refresh()
      else if (!openProc.running) openProc.running = true
    }
  }
}
