# omarchy-agent-orch

Omarchy bar icon for [`agent-orch`](https://github.com/pjfitzgerald/dotfiles): a long-running
orchestrator agent session on a host machine, reached over SSH, with a local fallback when the
host is unreachable.

- **Icon**: sitemap (orchestrator over streams). Dimmed when the orchestrator isn't running; in the urgent colour while on the
  local fallback. Tooltip: host, state, number of streams.
- **Left click**: toggle the orchestrator's drop-down popout (`agent-orch open`, same as SUPER+ALT+O).
- **Right click**: refresh now. Otherwise it polls `agent-orch status --json` every 20 s
  (setting `refreshIntervalSec`).

Expects `agent-orch` at `~/dotfiles/bin/agent-orch`.

Install: clone to `~/.config/omarchy/plugins/pjf.agent-orch` and add `{ "id": "pjf.agent-orch" }`
to a section of `bar.layout` in `~/.config/omarchy/shell.json`.
