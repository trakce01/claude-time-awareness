# claude-time-awareness

## what is this?

an experiment. not a product, not a tool, not a feature request.

i was working with claude code and realized something obvious...claude has no idea what time it is. like, at all. you can say "i have 2 hours" and it'll nod and then spend 45 minutes exploring three directions when you needed one, done. it can't do something any human collaborator does instinctively: pace their work.

you'd never have to tell a coworker "hey, we only have 30 minutes, maybe don't start a second exploration." they'd just...know. claude doesn't.

so i tried something: what if claude just...knew the time? not rules about what to do with it. just the raw data. current time, how much is left. and then let it figure out what that means.

this is that experiment.

## how it works

two hooks inject a small timestamp before every tool call and every user message. the injection only fires when you've told claude a time constraint ("i have 2 hours", "gotta be done by 4", "quick one, maybe 20 minutes"). claude parses that, sets a deadline, and from that point on, it sees something like this on every action:

```
[3:15 PM | ~75 min remaining]
```

if you want to see the countdown yourself (not just claude), you can add this to your statusline script (`~/.claude/statusline.sh`). it checks for the budget file and appends remaining time:

```bash
# Check for time budget
BUDGET_FILE="/tmp/claude-time-budget-$PPID"
TIME_DISPLAY=""
if [ -f "$BUDGET_FILE" ]; then
    DEADLINE=$(cat "$BUDGET_FILE" 2>/dev/null)
    if [ -n "$DEADLINE" ]; then
        NOW=$(date +%s)
        DIFF=$((DEADLINE - NOW))
        if [ "$DIFF" -le 0 ]; then
            TIME_DISPLAY=" | budget expired"
        else
            HOURS=$((DIFF / 3600))
            MINS=$(( (DIFF % 3600) / 60 ))
            if [ "$HOURS" -gt 0 ] && [ "$MINS" -gt 0 ]; then
                TIME_DISPLAY=" | ~${HOURS}h ${MINS}m left"
            elif [ "$HOURS" -gt 0 ]; then
                TIME_DISPLAY=" | ~${HOURS}h left"
            else
                TIME_DISPLAY=" | ~${MINS}m left"
            fi
        fi
    fi
fi
```

then append `$TIME_DISPLAY` to your existing printf. it updates whenever claude responds, not in real-time, but enough to glance at.

## try it

### option 1: install as a plugin (recommended)

```
/plugin marketplace add trakce01/claude-time-awareness
/plugin install time-awareness@claude-time-awareness
```

then add this to your `~/.claude/CLAUDE.md` (or project-level CLAUDE.md):

```
## Time Awareness

Hook injections give you time data before each tool call and user message:
`[3:15 PM | ~75 min remaining]`

This only appears when a time budget is active. When you detect a time budget
from the user (e.g. "I have 2 hours"), write the deadline as a Unix timestamp:
`echo "$(date -v+2H +%s)" > /tmp/claude-time-budget-$PPID`

Each session gets its own budget file (namespaced by process ID via $PPID).

To clear a budget: `rm -f /tmp/claude-time-budget-$PPID`

No budget file = no injections = no time pressure.
```

the plugin handles the hooks (time injection on every action). the CLAUDE.md snippet tells claude what the data means and how to set a budget. both are needed.

<details>
<summary>option 2: manual setup</summary>

1. copy `scripts/time-awareness.sh` to `~/.claude/hooks/time-awareness.sh`
2. make it executable: `chmod +x ~/.claude/hooks/time-awareness.sh`
3. add the hooks to your `~/.claude/settings.json`:

```json
"hooks": {
  "PreToolUse": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/hooks/time-awareness.sh inject-json"
        }
      ]
    }
  ],
  "UserPromptSubmit": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/hooks/time-awareness.sh inject-text"
        }
      ]
    }
  ]
}
```

4. add this to your `~/.claude/CLAUDE.md` (or project-level CLAUDE.md):

```
## Time Awareness

Hook injections give you time data before each tool call and user message:
`[3:15 PM | ~75 min remaining]`

This only appears when a time budget is active. When you detect a time budget
from the user (e.g. "I have 2 hours"), write the deadline as a Unix timestamp:
`echo "$(date -v+2H +%s)" > /tmp/claude-time-budget-$PPID`

Each session gets its own budget file (namespaced by process ID via $PPID).

To clear a budget: `rm -f /tmp/claude-time-budget-$PPID`

No budget file = no injections = no time pressure.
```

</details>

### test it

start a new session. say "i have 1 hour." then give claude a task. you should see time injections on every tool call and message. when you're done, the budget auto-expires, or you can clear it.

## share what you find

this is an experiment. the whole point is to see what happens.

does claude feel different to work with when it knows your time constraint? does it scope tighter? rush too much? flag tradeoffs at the right moments? or does it make no difference at all?

whatever you notice, good or bad, [open an issue](https://github.com/trakce01/claude-time-awareness/issues). no format, no template. just what you observed. even "tried it, didn't notice anything" is useful signal.

some things that might be interesting to pay attention to:
- did claude scope work differently than it usually does?
- did it feel like working with someone who's aware of the clock?
- did the time injections feel noisy or invisible?
- anything surprising?
