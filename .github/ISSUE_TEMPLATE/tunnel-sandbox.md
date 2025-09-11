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
> Want tunnel comparisons? See the **full table in the README](../blob/main/README.md#tunnels-supported)** →  

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
- [ ] ngrok<sup>\*</sup>
- [ ] Tailscale<sup>†</sup>
- [ ] Tor<sup>‡</sup>
- [ ] Tunnelmole

### 3. Power (power on your runner)

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
