---
name: Tunnel Sandbox
about: Spin up a Hello World server and expose it via a chosen tunnel
title: Tunnel Sandbox
labels: tunnel-sandbox
assignees: ''
---

# Ariadne Tunnel Sandbox

*This sandbox lets you create a variety of tunnels into a GitHub Actions runner to serve web content. Each time you edit and save the issue, the action will re-run with the new options.*

## 🔧 Control Panel

Select a runner OS and a tunnel type, then check the "ON" box to start.

### 1. Runner OS (pick ONE)

- [x] Ubuntu (ubuntu-latest)
- [ ] macOS (macos-14)
- [ ] Windows (windows-latest)

### 2. Tunnel (pick ONE)

- [x] Cloudflare Tunnel
- [ ] localhost.run
- [ ] ngrok\*
- [ ] Tailscale†
- [ ] Tor‡

### 3. Power

- [ ] ON (check this box to start the sandbox)

### 4. Config (Optional)

You can override the defaults here. The parser will use these values if the block is present.
If this block is removed or the values are invalid, the workflow will use its defaults (Port: 8080, Minutes: 40).

```yaml
# Port the Hello World server will listen on
port: 8080

# Minutes to keep the runner alive (workflow hard-cap is 80)
minutes: 40
```

<details>
  <summary>

## How it Works & Tunnel Details

  </summary>

### Overview

> **What is this?**
> When you open or edit this issue, a workflow spins up a short-lived test server on a GitHub Actions runner and exposes it using the tunnel you choose.

> **What happens next?**
> A bot will post a status comment below, which will update with your access link or command. If the job fails, it will automatically provide a temporary debug shell.

### Required Secrets (if using these tunnels)

**ngrok***
1. Sign up for a free [ngrok account](https://ngrok.com).
2. Add your `NGROK_AUTHTOKEN` as a repository secret.

**Tailscale†**
1. Sign up for a free [Tailscale account](https://tailscale.com).
2. Add an **ephemeral** `TAILSCALE_AUTHKEY` as a Actions repository secret.
3. Your access device must be logged into the same tailnet.

### Tunneling Access Overview

| Option | Public link? | Setup (Runner → User) | Typical Perf. | Reliability/NAT | Privacy / Exposure | Best For |
|---|---|---|---|---|---|---|
| **Cloudflare Tunnel** | Yes (`*.trycloudflare.com`) | Auto-install client → you click URL | Good–Very Good | High | Public at edge; origin stays private | Quick public demos |
| **localhost.run** | Yes (`http(s)://…lhr.life`) | SSH reverse tunnel → URL is generated | OK–Good | Medium | Public at edge | Fast, zero-config link |
| **ngrok*** | Yes (`*.ngrok-free.app`) | Auto-install client → you click URL | Good–Very Good | High | Public at edge; shows interstitial page | Quick demos & webhook testing |
| **Tailscale†** | No public URL | Runner joins tailnet → you SSH port-forward | LAN-like, low latency | Very High | Private to your tailnet | Private team access / debugging |
| **Tor‡** | Yes (`.onion`) | Local hidden service → onion URL | Variable (high latency) | High | Pseudonymous; Tor-only access | Privacy-focused access |

> **Notes:**
> • ***ngrok** sessions are temporary unless an `NGROK_AUTHTOKEN` secret is provided.*
> • **†Tailscale** requires you (and testers) to be on the same tailnet; we provide a ready-to-use `ssh -L ...` command.
> • **‡Tor** requires the [Tor Browser](https://www.torproject.org/download/) to visit `.onion` URLs.
> • **Max runtime is capped at 80 minutes**, even if you request longer.

</details>
