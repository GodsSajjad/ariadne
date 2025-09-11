---
name: Tunnel Sandbox
about: Spin up a Hello World server and expose it via a chosen tunnel.
title: Tunnel Sandbox
labels: tunnel-sandbox
assignees: ''
---
# Ariadne

Start a Hello World server and expose it via various tunnels.

## 🔧 Control Panel

### 1. Runner OS (select one OS)

- [ ] Ubuntu (ubuntu-latest)
- [ ] macOS (macos-14)
- [x] Windows (windows-latest)

### 2. Tunnel (select one tunnel)

- [ ] Cloudflare Tunnel
- [ ] localhost.run
- [ ] ngrok               <sup>\*</sup>
- [ ] Tailscale           <sup>†</sup>
- [x] Tor                 <sup>‡</sup>
- [ ] Tunnelmole

### 3. Power (power up your runner)

- [x] ON (check this box to start the sandbox)

> [!TIP]
> *Change the power or options anytime to create a fresh server. You never need to open another issue.*

### 4. Optional Config

You can override the defaults here. The parser will use these values if the block is present. If the block is removed or invalid, defaults apply (Port: 8080, Minutes: 40).

```yaml
# Port the Hello World server will listen on
port: 8080

# Minutes to keep the runner alive (workflow hard-cap is 80)
minutes: 40
````

#### Common Sense

**Public URL = public.** Don’t serve secrets. Sessions are ephemeral and auto-stop.

> [!NOTE]
> Want tunnel comparisons? See the **[full table in the README](../blob/main/README.md#tunnels-supported)** 

