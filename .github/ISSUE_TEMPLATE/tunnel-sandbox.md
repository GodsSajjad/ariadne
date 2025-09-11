---
name: Tunnel Sandbox
about: Spin up a Hello World server and expose it via a chosen tunnel
title: Tunnel Sandbox
labels: tunnel-sandbox
assignees: ''
---

# Ariadne Tunnel Sandbox

*Create a variety of tunnels into GitHub Actions runners to serve web content.*

**Each time you toggle an option the action will re-run.**

## 🔧 Control Panel

Select a runner, a tunnel, then check "ON" to start!

### 1. Runner OS (pick ONE)

- [x] Ubuntu (ubuntu-latest)
- [ ] macOS (macos-14)
- [ ] Windows (windows-latest)

### 2. Tunnel (pick ONE)

- [x] Cloudflare Tunnel
- [ ] localhost.run 
- [ ] ngrok
- [ ] Tailscale<sup>†</sup>
- [ ] Tor<sup>‡</sup>

### 3. Power

- [ ] ON (check this box to start the sandbox)

### 4. Config (Optional)

You can override defaults here. The parser will use the values below if this block is present.
If this block is removed or values are invalid, the workflow defaults (Port: 8080, Minutes: 40) will be used.

```yaml
# Port the Hello World server will listen on
port: 8080

# Minutes to keep the runner alive (workflow hard-cap is 80)
minutes: 40
```

<details>
  <summary>

## Troubleshooting and More Information

  </summary>

### Overview

> **What is this?**
> Open this issue, tick your options, and the workflow will spin up a short-lived test server on a GitHub Actions runner and expose it via the tunnel you choose. Edit the issue to re-run with new options.

> **What happens next?**
> After you submit, the bot comments a status block that includes your access link or SSH command. If something fails, it automatically opens a private tmate shell for you.

### Notes / Secrets (only if applicable)

**Tailscale**
- Maintainer provides an **ephemeral** `TAILSCALE_AUTHKEY` (repo secret).
- Your device must be logged into the same tailnet. The workflow will comment a copy-paste SSH port-forward command.

### Tunneling Access Overview

| Option | Public link? | Setup (Runner → User) | Typical perf | Reliability/NAT | Privacy / Exposure | Best for |
|---|---|---|---|---|---|---|
| **Cloudflare Tunnel** | Yes (`*.trycloudflare.com`) | Auto-install client → you click URL | Good–very good | High | Public at edge; origin stays private | Quick public demos |
| **localhost.run** | Yes (`http(s)://…lhr.life`) | SSH reverse tunnel → we scrape URL | OK–good | Medium (shared infra) | Public at edge | Fast, zero-config link |
| **Inlets PRO** | Yes (your controller) | Client connects to your inlets server | Very good | High (you control edge) | Public via your infra; TLS options | Prod-like, your domain |
| **Tailscale** | No public URL | Runner joins tailnet → you SSH port-forward | LAN-like, low-latency | Very high (P2P/NAT-punch) | Private to tailnet | Private evals / team-only |
| **Tor** | Yes (`.onion`) | Local hidden service → onion URL | Variable (high latency) | High | Pseudonymous; Tor-only | Privacy-focused access |

> Notes:
> • **Tailscale** requires you (and testers) to be on the same tailnet; we comment a ready `ssh -L ...` command.
> • **Inlets PRO** needs secrets for your controller (see below).
> • **Tor** requires Tor Browser to visit `.onion` URLs.
> • **Max runtime is capped at 80 minutes**, even if you request longer.

</details>

> † *needs [Tailscale](https://tailscale.com/kb/1347/installation) at your access point*
> ‡ *needs [Tor Browser](https://www.torproject.org/download/) at your access point*

