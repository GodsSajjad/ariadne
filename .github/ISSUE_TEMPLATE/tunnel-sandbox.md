Sweet—moved the feature table out of the template and linked to the README’s table. Here’s the updated **issue template** (drop in at `.github/ISSUE_TEMPLATE/tunnel-sandbox.md`):

````markdown
---
name: Tunnel Sandbox
about: Spin up a Hello World server and expose it via a chosen tunnel
title: Tunnel Sandbox
labels: tunnel-sandbox
assignees: ''
---

# Ariadne Tunnel Sandbox

*Spin up a short-lived server on a GitHub Actions runner and expose it with your tunnel of choice. Each time you change the Control Panel below and save, the workflow re-runs with the new options. You can also edit this comment directly.*

> [!WARNING]
> **Public URL = public.** Don’t serve secrets. Sessions are ephemeral and auto-stop.

> [!TIP]
> Toggle the **Control Panel** checkboxes any time to reconfigure. You can also edit the issue. The previous run cancels, a fresh one starts, and the status comment updates.

> [!NOTE]
> Want tunnel comparisons? See the **full table in the README** →  
> **`../../blob/main/README.md#tunnels-supported`**

---

## 🔧 Control Panel

Select a runner OS and tunnel, then check **ON** to start.

### 1. Runner OS (select one OS)

- [x] Ubuntu (ubuntu-latest)
- [ ] macOS (macos-14)
- [ ] Windows (windows-latest)

### 2. Tunnel (select one tunnel)

- [x] Cloudflare Tunnel
- [ ] localhost.run
- [ ] ngrok<sup>*</sup>
- [ ] Tailscale<sup>†</sup>
- [ ] Tor<sup>‡</sup>
- [ ] Tunnelmole

### 3. Power (toggle on or off)

- [ ] ON (check this box to start the sandbox)

### 4. Config (Optional)

You can override the defaults here. The parser will use these values if the block is present.
If the block is removed or invalid, defaults apply (Port: 8080, Minutes: 40).

```yaml
# Port the Hello World server will listen on
port: 8080

# Minutes to keep the runner alive (workflow hard-cap is 80)
minutes: 40
````

<details>
  <summary><strong>Overview, Requirements & Troubleshooting</strong></summary>

### Overview

> **What is this?**
> Opening or editing this issue launches a short-lived server on a GitHub Actions runner (Ubuntu, macOS, or Windows) and exposes it via the tunnel you pick. It demonstrates a clean “issue-as-control-panel” pattern, and it’s easy to copy into your repo so people can try your app **without** provisioning infra. Every GitHub user gets \~2,000 free Actions minutes per month—put them to work.

> **What happens after I change options?**
> A bot posts a status comment with your access method (URL or SSH command) and updates it automatically. If something breaks, it opens a short debug shell.

---

### Requirements for some tunnels

> \[!IMPORTANT]
> **ngrok** (*token required*)
> Add a repository secret named **`NGROK_AUTHTOKEN`**. If it’s missing, the run fails early and the status comment tells you how to fix it.
>
> 1. Create a free ngrok account. 2) Add `NGROK_AUTHTOKEN` as an Actions repo secret.

> \[!NOTE]
> **Tailscale** (private, no public URL)
>
> 1. Add an **ephemeral** `TAILSCALE_AUTHKEY` as an Actions repo secret.
> 2. Your access device and the runner must be on the **same tailnet**.
> 3. Enable **Tailscale SSH** and update ACLs to allow “accept” for SSH to the runner’s tag.
> 4. **Tip:** Turn off other VPNs (ExpressVPN, NordVPN, etc.) while using Tailscale to avoid dropped tailnet packets.

> **Tor** (requires Tor Browser)
> Use the \[Tor Browser] to open the `.onion` URL the bot posts.

---

> \[!TIP]
> Compare tunnels (perf, NAT, privacy): **`../blob/main/README.md#tunnels-supported`**

</details>
