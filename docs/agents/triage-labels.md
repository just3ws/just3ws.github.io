# Triage Label Vocabulary

We use the following labels for triage and lifecycle management on GitHub Issues:

- `needs-triage` — maintainer needs to evaluate
- `needs-info` — waiting on reporter
- `ready-for-agent` — fully specified, AFK-ready
- `ready-for-human` — needs human implementation
- `wontfix` — will not be actioned

## Metadata (for `agent-guide --json`)
```json
{
  "type": "triage-labels",
  "labels": [
    "needs-triage",
    "needs-info",
    "ready-for-agent",
    "ready-for-human",
    "wontfix"
  ]
}
```
