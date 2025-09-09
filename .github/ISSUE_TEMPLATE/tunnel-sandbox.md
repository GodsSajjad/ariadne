---
name: Tunnel Sandbox
about: Spin up a Hello World server and expose it via a chosen tunnel
title: Tunnel Sandbox
labels: tunnel-sandbox
assignees: ''

---

> **What is this?**  
> Open this issue, tick your options, and the workflow will spin up a short-lived test server on a GitHub Actions runner and expose it via the tunnel you choose. Edit the issue to re-run with new options.

## Tunneling Access Overview

| Option | Public link? | Setup (Runner → User) | Typical perf | Reliability/NAT | Privacy / Exposure | Best for |
|---|---|---|---|---|---|---|
| **Cloudflare Tunnel** | Yes (`*.trycloudflare.com`) | Auto-install client → you click URL | Good–very good | High | Public at edge; origin stays private | Quick public demos |
| **localhost.run** | Yes (`http(s)://…lhr.life`) | SSH reverse tunnel → we scrape URL | OK–good | Medium (shared infra) | Public at edge | Fast, zero-config link |
| **Inlets PRO** | Yes (your controller) | Client connects to your inlets server | Very good | High (you control edge) | Public via your infra; TLS options | Prod-like, your domain |
| **Tailscale** | No public URL | Runner joins tailnet → you SSH port-forward | LAN-like, low-latency | Very high (P2P/NAT-punch) | Private to tailnet | Private evals / team-only |
| **Tor** | Yes (`.onion`) | Local hidden service → onion URL | Variable (high latency) | High | Pseudonymous; Tor-only | Privacy-focused access |

> Notes:  
> • **Tailscale** requires you (and testers) to be on the same tailnet; we’ll comment a ready `ssh -L ...` command.  
> • **Inlets PRO** needs secrets for your controller (see below).  
> • **Tor** requires Tor Browser to visit `.onion` URLs.

---

# 🔧 Control Panel

## Runner OS (pick ONE)
- [x] Ubuntu (ubuntu-latest)
- [ ] macOS (macos-14)
- [ ] Windows (windows-latest)

## Tunnel (pick ONE)
- [x] Cloudflare Tunnel (ephemeral trycloudflare.com)
- [ ] localhost.run (free SSH reverse tunnel)
- [ ] Inlets PRO (requires secrets)
- [ ] Tailscale (VPN overlay; SSH port-forward from your device)
- [ ] Tor (hidden service onion URL)

## Power
- [x] ON (uncheck to turn off)

## Settings
**Port:** `8080`  
**Minutes to keep running:** `40`

---

### Notes / Secrets (only if applicable)

**Inlets PRO**  
- `INLETS_REMOTE` (e.g., `wss://inlets.example.com/connect`)  
- `INLETS_TOKEN`  
- `INLETS_LICENSE`  
- (Optional) `INLETS_PUBLIC_URL`

**Tailscale**  
- Maintainer provides an **ephemeral** `TAILSCALE_AUTHKEY` (repo secret).  
- Your device must be logged into the same tailnet. The workflow will comment a copy-paste SSH port-forward command.

> Click options to change them — the action will re-run with the options you select. You can also edit the issue manually.
