# Ariadne Tunneling Sandbox for GitHub Actions

**Spin up ephemeral test environments on demand, directly from a GitHub issue.**

Ariadne is a powerful, issue-driven automation that allows developers to instantly create temporary servers on GitHub Actions runners. These environments are exposed to the world via a selection of secure tunnels, providing a flexible and secure way to test, debug, and share work in progress.

The entire system is controlled by a "Control Panel" within a GitHub issue template. Simply check the boxes for your desired OS and tunnel, submit the issue, and a bot will comment back with the access details.

![Ariadne Demo](https://user-images.githubusercontent.com/12345/your-demo-image.gif)  
*(Suggestion: You should create a short screen recording of the process and replace this link!)*

## Features

*   **Issue-Driven:** No command line or special tools needed. If you can edit a GitHub issue, you can launch a server.
*   **Multi-Platform:** Supports `Ubuntu`, `macOS`, and `Windows` runners.
*   **Multi-Tunnel:** Choose the best way to expose your server:
    *   **Cloudflare Tunnel:** Quick, public, and reliable HTTPS URLs.
    *   **localhost.run:** Zero-config, free SSH reverse tunnel for instant public access.
    *   **Tailscale:** Securely join the runner to your private tailnet for SSH access.
    *   **Tor:** Expose the server as an anonymous Onion Service.
*   **Automated Status Updates:** A bot keeps the issue updated with the latest status, from parsing selections to providing the final access URL or command.
*   **Debug-Ready:** Failed runs automatically open a secure, private `tmate` SSH session for live debugging directly on the runner.

## How It Works

The process is simple and powerful, orchestrating several key components:

1.  **GitHub Issue Trigger:** A user opens or edits an issue using the `Tunnel Sandbox` template.
2.  **`parse` Job:** A GitHub Action workflow triggers. The first job uses a robust Bash script (`./.github/scripts/parse_issue_body.sh`) to parse the checkboxes and YAML configuration from the issue body.
3.  **`run` Job:** The main job launches on the user-selected OS. It starts a simple "Hello World" Node.js server.
4.  **Tunnel Activation:** Based on the user's choice, the workflow installs the necessary tools and starts the selected tunnel, pointing it at the running web server.
5.  **Status Comment:** The workflow uses a `github-script` step to post and update a comment on the original issue, providing the public URL or the `ssh` command needed to access the sandbox.

## Quick Start (For Users)

1.  Navigate to the "Issues" tab of this repository.
2.  Click "New Issue" and choose the **"Tunnel Sandbox"** template.
3.  Fill out the **🔧 Control Panel** by checking the boxes for your desired OS and tunnel.
4.  (Optional) Edit the YAML block to change the default port or runtime.
5.  Check the **"ON"** box to power on the sandbox.
6.  Click "Submit new issue".
7.  Within a minute, a bot will post a status comment. This comment will automatically update with the access URL or command once the runner is ready.

To change settings, simply edit the issue body. The workflow will cancel the previous run and start a new one with the updated configuration.

## Setup (For Repository Admins)

To get Ariadne working in your own repository, you need to add four components:

1.  **Secrets:**
    *   `TAILSCALE_AUTHKEY`: An ephemeral, reusable auth key from your Tailscale Admin Console. It's recommended to associate this key with a specific tag (e.g., `tag:ci-runner`).

2.  **Workflow File:**
    *   Copy the main workflow file to `.github/workflows/tunnel-sandbox.yml`.

3.  **Parsing Script:**
    *   Create the helper script at `.github/scripts/parse_issue_body.sh`.

4.  **Issue Template:**
    *   Create the issue template at `.github/ISSUE_TEMPLATES/tunnel-sandbox.md`.

5.  **Tailscale ACLs (Required for Tailscale SSH):**
    *   You must update your tailnet's Access Controls to allow SSH connections to the tag you are using. For example, add a rule to allow your `group:devops` to connect to your `tag:ci-runner` on port 22.

## Supported Platforms & Tunnels

This matrix shows the current working status of each tunnel across the supported operating systems.

| Tunnel | Ubuntu | macOS | Windows |
| :--- | :---: | :---: | :---: |
| **Cloudflare Tunnel** | ✅ | ✅ | ✅ |
| **localhost.run** | ✅ | ✅ | ✅ |
| **Tor Onion Service** | ✅ | ✅ | ✅ |
| **Tailscale** | ✅ | ✅ | ℹ️ |

**Note on Tailscale for Windows:** While the runner will successfully join your tailnet, the `tailscale ssh` feature is **not yet supported by Tailscale on the Windows platform.** The workflow will provide an informational message. You can track the progress in [tailscale/tailscale#4697](https://github.com/tailscale/tailscale/issues/4697).

