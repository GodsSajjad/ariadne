# Ariadne: turn your **2000 free Actions minutes** into live demos

Spin up an ephemeral server on a GitHub Actions runner and get a **shareable URL**—from a single GitHub issue. Pick the OS, pick a tunnel, check **ON**. A bot replies with the link or SSH command.

## TL;DR — Try it in \~60 seconds

1. **Fork this repo** → [Fork »](../../fork)
2. **Enable Actions** → [Settings » Actions »](../../settings/actions) choose *Allow all actions and reusable workflows*
3. **Create the sandbox issue** → [New Issue with template »](../../issues/new?template=tunnel-sandbox.md&title=Tunnel%20Sandbox)

   * Pick **OS** (Ubuntu / macOS / Windows)
   * Pick a **tunnel** (Cloudflare, localhost.run, ngrok, Tailscale, Tor, Tunnelmole)
   * Check **ON** 

4. Watch the bot’s comment for your access link/command. To create a different host you don't have to open a new issue, just toggle the checkboxes to restart or re-run with different options.

## Common Sense

> [!TIP]
> **Start here:** **[Fork »](../../fork)** • **[Enable Actions »](../../settings/actions)** • **[Get Started »](../../issues/new?template=tunnel-sandbox.md)**
>
> If your chosen tunnel needs a token, add it under **Actions secrets**: **[Open Secrets »](../../settings/secrets/actions)**
> – ngrok → `NGROK_AUTHTOKEN`  •  Tailscale → `TAILSCALE_AUTHKEY` (ephemeral)

> [!WARNING]
> **Public URL = public.** Don’t serve secrets. Sessions are ephemeral and auto‑stop.

> [!NOTE]
> Works on **Ubuntu, macOS, Windows** with tunnels: **Cloudflare**, **localhost.run**, **ngrok**, **Tailscale**, **Tor**, and **Tunnelmole**

---
## What you get

* **Issue‑driven UX** — anyone can spin a demo by ticking checkboxes.
* **Multi‑OS** — Ubuntu, macOS, Windows runners.
* **Multi‑Tunnel** — pick the edge you want (public URL vs private tailnet vs Tor).
* **Auto status** — bot comment shows the link/command and required next steps.
* **Debug on failure** — short‑lived `tmate` rescue shell for triage.
* **Hard cap** — sessions stop at **80 minutes** max (configurable lower).

## Bring your own app (BYO)

We ship a tiny Node “Hello World” for the demo. To expose **your** service instead:

* Edit the [workflow file](../../edit/main/.github/workflows/tunnel-sandbox.yml)
* Start your app before the tunnel step (Docker/Python/Go/etc.).
* Make sure it listens on the configured port (default **8080**), or change the config.
* The tunnel simply forwards that port to a public URL (or tailnet for Tailscale, or `.onion` for Tor).

> [!NOTE]
> The **Control Panel** stays the same—only your app steps change.

---

## Minimal setup

Most tunnels are zero‑config. Only two need secrets:

* **ngrok** → add `NGROK_AUTHTOKEN` (repo: [Actions secrets »](../../settings/secrets/actions)).
* **Tailscale** → add ephemeral `TAILSCALE_AUTHKEY` (repo: [Actions secrets »](../../settings/secrets/actions)). Ensure your ACLs permit SSH to the runner’s tag.

Everything else (Cloudflare, localhost.run, **Tunnelmole**, Tor) auto‑installs as needed.

> [!IMPORTANT]
> **ngrok requires a token.** If `NGROK_AUTHTOKEN` is missing, the run fails early and the bot comment explains how to add it.

---

## Tunnels supported

| Tunnel                                                                                                         | Public link?                         | Setup (Runner → User)                        | Typical perf              | Reliability/NAT | Privacy / Exposure                | Best for                         |
| -------------------------------------------------------------------------------------------------------------- | ------------------------------------ | -------------------------------------------- | ------------------------- | --------------- | --------------------------------- | -------------------------------- |
| **Cloudflare Tunnel** ([docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)) | Yes (`*.trycloudflare.com`)          | Auto‑install client → click URL              | Good–Very good            | High            | Public at edge; origin private    | Quick public demos               |
| **localhost.run** ([site](https://localhost.run))                                                              | Yes (`http(s)://…lhr.life`)          | SSH reverse tunnel → URL appears             | OK–Good                   | Medium          | Public at edge                    | Free, zero‑config link           |
| **Tunnelmole** ([site](https://tunnelmole.com))                                                                | Yes (`https://…tunnelmole.net/.com`) | Auto‑install client → click URL              | Good                      | High            | Public at edge; origin private    | OSS ngrok‑style demos; easy URLs |
| **ngrok** \* ([site](https://ngrok.com))                                                                       | Yes (`*.ngrok‑free.app`)             | Client + **auth token required** → click URL | Good–Very good            | High            | Public at edge; interstitial page | Webhooks & shareable demos       |
| **Tailscale** † ([site](https://tailscale.com))                                                                | No public URL                        | Runner joins tailnet → SSH port‑forward      | LAN‑like, low latency     | Very high       | Private to your tailnet           | Private team access/debug        |
| **Tor** ‡ ([site](https://www.torproject.org))                                                                 | Yes (`.onion`)                       | Hidden service → onion URL                   | Variable (higher latency) | High            | Pseudonymous; Tor‑only            | Privacy‑focused access           |

Notes:

* \* **ngrok** requires a repo secret `NGROK_AUTHTOKEN`. Without it, the ngrok path is blocked and the bot comment tells you how to fix it.
* † **Tailscale SSH on Windows** is not yet supported by Tailscale; we show an informational message (runner still joins the tailnet).
* ‡ **Tor** links require the Tor Browser at the access point.

---

## Platforms matrix (tunnel × OS)

| Tunnel                | Ubuntu | macOS | Windows |
| :-------------------- | :----: | :---: | :-----: |
| **Cloudflare Tunnel** |    ✅   |   ✅   |    ✅    |
| **localhost.run**     |    ✅   |   ✅   |    ✅    |
| **Tunnelmole**        |    ✅   |   ✅   |    ✅    |
| **ngrok** \*          |    ✅   |   ✅   |    ✅    |
| **Tailscale** †       |    ✅   |   ✅   |    ℹ️   |
| **Tor**               |    ✅   |   ✅   |    ✅    |

ℹ️ **Tailscale on Windows:** the runner joins the tailnet, but **Tailscale SSH** has upstream limitations; the workflow posts guidance in the status comment.

---

## How it works

1. **Parse** — a script reads the issue’s checkboxes + optional YAML (`port`, `minutes`).
2. **Run** — selected OS runner boots; your app (or demo server) starts; chosen tunnel activates.
3. **Comment** — we upsert a status comment with the access method and any required instructions.
4. **Keep‑alive** — holds up to your requested time (max **80 min**), then exits.

On errors, we dump concise logs and open a time‑boxed `tmate` shell.

---

## Troubleshooting

> [!IMPORTANT]
> **ngrok** (*token required*)
1. Add a repository secret named **`NGROK_AUTHTOKEN`**. If it’s missing, the run fails early and the status comment tells you how to fix it.
2. Create a free ngrok account → then add `NGROK_AUTHTOKEN` here: [Actions secrets »](../../settings/secrets/actions)

> [!NOTE]
> **Tailscale** (private, no public URL)
>
1. Add an **ephemeral** `TAILSCALE_AUTHKEY` as an Actions repo secret.
2. Your access device and the runner must be on the **same tailnet**.
3. Enable **Tailscale SSH** and update ACLs to allow “accept” for SSH to the runner’s tag.
4. **Tip:** Turn off other VPNs (ExpressVPN, NordVPN, etc.) while using Tailscale to avoid dropped tailnet packets.

> [!TIP]
> **Tor** (requires Tor Browser)
1. Use the [Tor Browser](https://www.torproject.org/download/) to open the `.onion` URL the bot posts.
2. The `.onion` site might not be findable right away, sometimes takes a minute to appear.


> [!TIP]
> Want tunnel comparisons (perf, NAT, privacy)? See **[Tunnels supported](#tunnels-supported)** above.

---

## Handy links

* Open the sandbox issue now → **[New Issue with template](../../issues/new?template=tunnel-sandbox.md&title=Tunnel%20Sandbox)**
* Enable Actions → **[Repo Settings » Actions](../../settings/actions)**
* Add secrets → **[Repo Settings » Secrets (Actions)](../../settings/secrets/actions)**

---

## Repo anatomy

* Workflow → `.github/workflows/tunnel-sandbox.yml`
* Parser → `.github/scripts/parse_issue_body.sh`
* Issue template → `.github/ISSUE_TEMPLATE/tunnel-sandbox.md`

Forked repos can tweak defaults (port, cap), edit the Control Panel copy, or add/remove tunnels without changing the UX.

---

## Security

* Runners are **ephemeral**; files vanish when the job ends.
* Public tunnels are… public. Don’t expose credentials.
* Loops are bounded; timeouts prevent hangs; max runtime is capped.

---

## FAQ

**Can I demo my own project?**
Yes—start your app before the tunnel step and listen on the configured port.

**Stable subdomains?**
Possible with some tunnels (e.g., ngrok reserved domain, Cloudflare with account, Tunnelmole paid plan). Tor `.onion` lasts for the session.

**Cost?**
Uses your GitHub Actions minutes (about **2,000 free minutes/month** on personal accounts).

