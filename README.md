# Tunnel Sandbox

Spin up a short-lived server inside a GitHub Actions runner and expose it to the world (or your private tailnet) through a tunnel of your choice.
All controlled from a single **GitHub Issue** — no local setup required.

## ✨ Features

* **One-click issue template**: open an issue, tick boxes, and Actions does the rest.
* **Multiple tunneling options**:

  * 🌐 **Cloudflare Tunnel** – ephemeral `*.trycloudflare.com` URL.
  * ⚡ **localhost.run** – free reverse SSH tunnel with public `lhr.life` link.
  * 🔒 **Inlets PRO** – connect to your own Inlets controller (needs secrets).
  * 🐟 **Tailscale** – runner joins your tailnet; SSH port-forward like it’s on your LAN.
  * 🧅 **Tor** – hidden service `.onion` URL (Tor Browser only).
* **Cross-platform**: run the sandbox on `ubuntu-latest`, `macos-14`, or `windows-latest` runners.
* **Single living status comment**: status and access instructions are always kept in one place, updated live.
* **ON/OFF switch**: uncheck `ON` in the issue to stop or cancel the sandbox at any time.
* **Concurrency control**: editing the issue cancels the previous run and starts fresh.

## 🚀 Quickstart

1. Go to the **Issues** tab in this repo.
2. Click **New issue** → **Tunnel Sandbox** template.
3. Pick:

   * Runner OS (Ubuntu, macOS, Windows)
   * Tunnel method (Cloudflare, localhost.run, Inlets PRO, Tailscale, or Tor)
   * Port (default: `8080`)
   * Minutes to keep alive (default: `40`)
4. Leave `ON` checked and submit the issue.
5. Watch the bot comment update with your **access instructions**:

   * Cloudflare / localhost.run / Inlets → browser link.
   * Tailscale → ready-to-copy `ssh -L` port-forward command.
   * Tor → `.onion` URL with link to Tor Browser.

## 📊 Tunneling Access Overview

| Option            | Public link?                | Setup (Runner → User)              | Typical perf      | Reliability/NAT    | Privacy / Exposure          | Best for                  |
| ----------------- | --------------------------- | ---------------------------------- | ----------------- | ------------------ | --------------------------- | ------------------------- |
| **Cloudflare**    | Yes (`*.trycloudflare.com`) | Auto client → click URL            | Good–very good    | High               | Public edge; origin private | Quick public demos        |
| **localhost.run** | Yes (`lhr.life` URL)        | Reverse SSH tunnel → scrape URL    | OK–good           | Medium             | Public at edge              | Fast, zero-config link    |
| **Inlets PRO**    | Yes (your domain)           | Connects to your Inlets controller | Very good         | High (you control) | Public via your infra       | Prod-like with own domain |
| **Tailscale**     | No public URL               | Runner joins tailnet → SSH forward | LAN-like, low-lat | Very high          | Private to tailnet          | Private evals, team-only  |
| **Tor**           | Yes (`.onion`)              | Hidden service → onion URL         | Variable          | High               | Tor-only pseudonymous       | Privacy-focused access    |

> Notes:
> • Tailscale requires you (and testers) to be on the same tailnet.
> • Inlets PRO needs repo secrets (`INLETS_REMOTE`, `INLETS_TOKEN`, `INLETS_LICENSE`).
> • Tor requires [Tor Browser](https://www.torproject.org/).

## 🔑 Secrets

* **Tailscale**: `TAILSCALE_AUTHKEY` (ephemeral auth key from your tailnet).
* **Inlets PRO**: `INLETS_REMOTE`, `INLETS_TOKEN`, `INLETS_LICENSE` (+ optional `INLETS_PUBLIC_URL`).

Other tunnels (Cloudflare, localhost.run, Tor) need no secrets.

## 🛠 How it Works

* A tiny Node.js **Hello World** HTTP server is started on the chosen port.
* The selected tunnel client is installed and launched on the runner.
* Access details (URLs or SSH commands) are scraped from logs and posted into the issue’s status comment.
* The server stays alive for the configured number of minutes, then the job exits.

## 🧯 Debugging

If something fails, a **tmate rescue shell** is always offered at the end.
This opens a debug session on a fresh Ubuntu runner (not the job runner) for quick poking around.

## ⚠️ Disclaimer

This is a **sandbox**. Ephemeral tunnels may expose your runner to the internet.
Use only for demos, testing, or experimentation — **not for production**.
