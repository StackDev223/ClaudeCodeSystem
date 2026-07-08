# Connect: Set Up Your Tool Connections (Cloud Edition)

This is Part 3 of 4 in the setup process. The user has already run `/onboard` (personalized their vault) and `/train` (learned how the system works). Now we connect their actual tools.

**Prerequisites:** CLAUDE.md exists with tool preferences from `/onboard`.

**Voice:** Patient, step-by-step guide. Never assume they know what an API key is or where to find settings in an app. Every instruction should be "click this, then click that."

**Important:** Use `AskUserQuestion` at EVERY step to confirm before moving on. Test EVERY connection with real data before moving to the next tool. Do not leave any tool half-connected.

**The three connection paths (cloud edition):**

1. **claude.ai Connectors** (preferred) — the user connects the tool at claude.ai → Settings → Connectors; it shows up in sessions as ready-to-use tools. Auth is held by Anthropic, nothing to store. Google Calendar, Gmail, Google Drive, Slack, and many task managers work this way.
2. **Environment variables** — for API-key tools (Fathom, Rize, etc.). The user adds the key in the Claude Code environment configuration; scripts and curl read it from the environment. Requires the tool's API domain on the environment's network allowlist.
3. **`.mcp.json`** — for tools with an MCP server but no connector. You (Claude) add the server entry to `.mcp.json` at the vault root, referencing env vars for secrets, commit, and it loads next session.

**Never store any credential in a repo file.** If the user pastes a key into the chat, put it in the environment configuration flow below — never into a committed file.

**Two rules about restarts:** new connectors and new environment variables generally attach when a **new session** starts. Plan the flow so all claude.ai-side changes happen in a batch, then the user starts one fresh session and you verify everything at once (Step 3).

---

## Step 0: Figure Out What to Connect

1. Run `git pull --ff-only` (protocol).
2. Read CLAUDE.md to find which tools the user selected during `/onboard`.
3. Check what is already live in this session:
   - Which connector tools are available to you right now (Calendar, Gmail, Slack tools present?)
   - `printenv FATHOM_API_KEY RIZE_API_KEY` etc. for expected env vars
   - Read `.mcp.json` for configured servers

Present the list:

"During setup, you said you use these tools:"
- [Each tool, with status: already connected / not yet connected, and which path it uses]

AskUserQuestion: "Which one should we start with?"
Options:
- [Their tools as options, recommending the most impactful one first — usually Calendar]
- Just go in order

---

## Step 1: Connector-Based Tools (Google, Slack, task managers)

For each tool that has a claude.ai connector, walk through:

1. "Open **claude.ai** in another tab and sign in."
2. "Click your **profile icon**, then **Settings**."
3. "Find **Connectors** in the settings menu."
4. "Find **[Tool]** in the list and click **Connect**."
5. "[Tool] will ask you to sign in and approve access. Use your **work account** and click **Allow** on each screen."

AskUserQuestion: "Does [Tool] show as connected on claude.ai?"
Options:
- Yes, it shows connected
- I got an error
- My work account was blocked — it says my organization does not allow this

**If blocked by their organization:**
AskUserQuestion: "Your work account restricts this. What would you like to do?"
Options:
- Try with my personal account instead
- Ask IT to allow the Claude connector (I will do this later)
- Skip this tool for now

**Slack note:** if they have multiple workspaces, connect each one through the connector flow. Note which workspaces are connected in CLAUDE.md.

**Repeat for every connector-based tool before moving on** — batching them means one restart covers all of them (Step 3 verifies).

---

## Step 2: API-Key Tools (Fathom, Rize, and similar)

For each API-key tool:

### 2a: Get the key

Walk them through the tool's own UI, one step at a time (example for Fathom):
1. "Open **fathom.video** and sign in."
2. "Go to **Settings**, look for **API** or **Integrations**."
3. "Generate or copy your API key."

AskUserQuestion: "Got the API key copied?"
Options:
- Yes
- I cannot find it (may require a specific plan)
- My plan does not include API access

(If plan issue: "We can skip this and process transcripts manually, or check the pricing page for which plan includes API access.")

### 2b: Store it in the environment (NOT the repo)

1. "Go to **claude.ai/code**, open this repository's **environment settings**, and find **Environment variables**."
2. "Add a variable: name **[VAR_NAME]** (e.g. `FATHOM_API_KEY`), value: paste the key."
3. "Save."

AskUserQuestion: "Is the variable saved?"
Options:
- Yes
- I cannot find environment settings
- Something went wrong

### 2c: Network access for the tool's API

"One more setting in the same place: **Network access**. If it is not already on **Custom** with extra domains, set it to **Custom** and add: **[the tool's API domain]**." Common domains:
- Fathom: `api.fathom.ai`
- Rize: `api.rize.io`
- (For other tools, find the API base URL in their docs and add that domain.)

### 2d: Create the reference pointer

Write `Resources/API Keys/[Tool].md` (pointer only, never the value):
```markdown
# [Tool] API Key
- **Stored as**: environment variable `[VAR_NAME]` (Claude Code environment config)
- **Type**: [API key header / Bearer token]
- **Scopes**: [what it can access]
- **Network**: requires `[domain]` on the environment allowlist
```

---

## Step 3: Restart and Verify Everything

Once all claude.ai-side changes are done:

1. Commit and push any repo changes made so far (`git add -A && git commit -m "Connect: integration docs" && git push`).
2. Tell the user: "Now the moment of truth. Environment changes load when a fresh session starts. Close this session, start a **new session** on this repo at claude.ai/code, and type `/connect` — I will pick up right here and test everything." (The command detects already-documented tools in Step 0 and jumps to verification.)

**In the fresh session, verify each tool with real data:**

- **Calendar**: list the next 3-5 upcoming events. AskUserQuestion: "I found these events: [list]. Does that look right?"
- **Gmail**: fetch today's most recent 3 subjects (read-only). Confirm.
- **Slack**: list a few channels from each workspace. Confirm.
- **Task manager**: list their spaces/projects. Confirm.
- **API-key tools**: `printenv [VAR]` to confirm presence, then one lightweight API call (e.g., Fathom: list last 3 meetings). Confirm. If the call fails with a network error, the domain is missing from the allowlist — walk them back to network settings.

After each: "[Tool] is connected! [N] more to go."

**If a connector's tools are not available in the session**, the connector is not attached: check it shows "Connected" on claude.ai, then start one more fresh session. If it still does not appear, note it and move on — tell the user to check the connector's status later; do not fabricate access.

---

## Step 4: MCP Servers (only if needed)

If a selected tool has no connector and no simple REST API, check for an MCP server (WebSearch: `"[tool name] MCP server"`).

If a maintained server exists:
1. Add it to `.mcp.json` at the vault root. Reference env vars for secrets — never paste values:
   ```json
   {
     "mcpServers": {
       "toolname": {
         "command": "npx",
         "args": ["-y", "some-mcp-server-package"],
         "env": { "TOOL_API_KEY": "${TOOL_API_KEY}" }
       }
     }
   }
   ```
2. Have the user add `TOOL_API_KEY` to the environment variables (Step 2b pattern), plus any domains the server calls to the network allowlist.
3. Commit `.mcp.json`, push, fresh session, verify with a lightweight tool call.

---

## Step 5: Final Check

When all tools are connected (or explicitly skipped):

### Verify documentation

1. CLAUDE.md lists every connected tool under the right section (Connectors / API-Key Tools / MCP Servers), and skipped tools are removed
2. Every API-key tool has a pointer file in `Resources/API Keys/`
3. `Resources/Reference/API Integration Guide.md` documents endpoints and gotchas for any tool you called via REST

### Present the summary

"Here is where we stand:"
- Each tool with ✓ (connected and tested) or ○ (skipped, with reason)
- Which path each uses (connector / env var / MCP)

### Save

```bash
git add -A && git commit -m "Connect: [N] tools connected and documented" && git push
```

Then: "All your tools are connected and tested. The last step is `/finish` — I will show you the system in action with your real data, set up your nightly automation, and teach you how to get the most out of it. Type `/finish` when you are ready."
