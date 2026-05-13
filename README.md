# VisionClaw

![VisionClaw](assets/teaserimage.png)

A real-time AI assistant for Meta Ray-Ban smart glasses. See what you see, hear what you say, and take actions on your behalf -- all through voice.

![Cover](assets/cover.png)

Built on [Meta Wearables DAT SDK](https://github.com/facebook/meta-wearables-dat-ios) (iOS) / [DAT Android SDK](https://github.com/nichochar/openclaw) (Android) + [Gemini Live API](https://ai.google.dev/gemini-api/docs/live) + [OpenClaw](https://github.com/nichochar/openclaw) (optional).

**Supported platforms:** iOS (iPhone) and Android (Pixel, Samsung, etc.)

## What It Does

Put on your glasses, tap the AI button, and talk:

- **"What am I looking at?"** -- Gemini sees through your glasses camera and describes the scene
- **"Add milk to my shopping list"** -- delegates to OpenClaw, which adds it via your connected apps
- **"Send a message to John saying I'll be late"** -- routes through OpenClaw to WhatsApp/Telegram/iMessage
- **"Search for the best coffee shops nearby"** -- web search via OpenClaw, results spoken back

The glasses camera streams at ~1fps to Gemini for visual context, while audio flows bidirectionally in real-time.

## How It Works

![How It Works](assets/how.png)

```
Meta Ray-Ban Glasses (or phone camera)
       |
       | video frames + mic audio
       v
iOS / Android App (this project)
       |
       | JPEG frames (~1fps) + PCM audio (16kHz)
       v
Gemini Live API (WebSocket)
       |
       |-- Audio response (PCM 24kHz) --> App --> Speaker
       |-- Tool calls (execute) -------> App --> OpenClaw Gateway
       |                                              |
       |                                              v
       |                                      56+ skills: web search,
       |                                      messaging, smart home,
       |                                      notes, reminders, etc.
       |                                              |
       |<---- Tool response (text) <----- App <-------+
       |
       v
  Gemini speaks the result
```

**Key pieces:**
- **Gemini Live** -- real-time voice + vision AI over WebSocket (native audio, not STT-first)
- **OpenClaw** (optional) -- local gateway that gives Gemini access to 56+ tools and all your connected apps
- **Phone mode** -- test the full pipeline using your phone camera instead of glasses
- **WebRTC streaming** -- share your glasses POV live to a browser viewer

---

## Quick Start (iOS)

### 1. Clone and open

```bash
git clone https://github.com/sseanliu/VisionClaw.git
cd VisionClaw/samples/CameraAccess
open CameraAccess.xcodeproj
```

### 2. Add your secrets

Copy the example file and fill in your values:

```bash
cp CameraAccess/Secrets.swift.example CameraAccess/Secrets.swift
```

Edit `Secrets.swift` with your [Gemini API key](https://aistudio.google.com/apikey) (required) and optional OpenClaw/WebRTC config.

### 3. Build and run

Select your iPhone as the target device and hit Run (Cmd+R).

### 4. Try it out

**Without glasses (iPhone mode):**
1. Tap **"Start on iPhone"** -- uses your iPhone's back camera
2. Tap the **AI button** to start a Gemini Live session
3. Talk to the AI -- it can see through your iPhone camera

**With Meta Ray-Ban glasses:**

First, enable Developer Mode in the Meta AI app:

1. Open the **Meta AI** app on your iPhone
2. Go to **Settings** (gear icon, bottom left)
3. Tap **App Info**
4. Tap the **App version** number **5 times** -- this unlocks Developer Mode
5. Go back to Settings -- you'll now see a **Developer Mode** toggle. Turn it on.

![How to enable Developer Mode](assets/dev_mode.png)

Then in VisionClaw:
1. Tap **"Start Streaming"** in the app — this fork starts in **audio-only mode** (DAT SDK video is skipped to save glasses + phone battery) and auto-starts a Gemini Live session, so you can talk immediately
2. Tap the **Video** button in the controls row at any time to enable the live camera feed; tap again to go back to audio-only
3. Tap the **camera button** to capture a still photo — the JPEG is shown in the preview sheet *and* attached to the next OpenClaw tool call automatically (great for "save this to my notes" / "what is this?")

---

## Quick Start (Android)

### 1. Clone and open

```bash
git clone https://github.com/sseanliu/VisionClaw.git
```

Open `samples/CameraAccessAndroid/` in Android Studio.

### 2. Configure GitHub Packages (DAT SDK)

The Meta DAT Android SDK is distributed via GitHub Packages. You need a GitHub Personal Access Token with `read:packages` scope.

1. Go to [GitHub > Settings > Developer Settings > Personal Access Tokens](https://github.com/settings/tokens) and create a **classic** token with `read:packages` scope
2. In `samples/CameraAccessAndroid/local.properties`, add:

```properties
github_token=YOUR_GITHUB_TOKEN
```

> **Tip:** If you have the `gh` CLI installed, you can run `gh auth token` to get a valid token. Make sure it has `read:packages` scope -- if not, run `gh auth refresh -s read:packages`.
>
> **Note:** GitHub Packages requires authentication even for public repositories. The 401 error means your token is missing or invalid.

### 3. Add your secrets

```bash
cd samples/CameraAccessAndroid/app/src/main/java/com/meta/wearable/dat/externalsampleapps/cameraaccess/
cp Secrets.kt.example Secrets.kt
```

Edit `Secrets.kt` with your [Gemini API key](https://aistudio.google.com/apikey) (required) and optional OpenClaw/WebRTC config.

### 4. Build and run

1. Let Gradle sync in Android Studio (it will download the DAT SDK from GitHub Packages)
2. Select your Android phone as the target device
3. Click Run (Shift+F10)

> **Wireless debugging:** You can also install via ADB wirelessly. Enable **Wireless debugging** in your phone's Developer Options, then pair with `adb pair <ip>:<port>`.

### 5. Try it out

**Without glasses (Phone mode):**
1. Tap **"Start on Phone"** -- uses your phone's back camera
2. Tap the **AI button** (sparkle icon) to start a Gemini Live session
3. Talk to the AI -- it can see through your phone camera

**With Meta Ray-Ban glasses:**

Enable Developer Mode in the Meta AI app (same steps as iOS above), then:
1. Tap **"Start Streaming"** in the app
2. Tap the **AI button** for voice + vision conversation

---

## Setup: OpenClaw (Optional)

OpenClaw gives Gemini the ability to take real-world actions: send messages, search the web, manage lists, control smart home devices, and more. Without it, Gemini is voice + vision only.

### 1. Install and configure OpenClaw

Follow the [OpenClaw setup guide](https://github.com/nichochar/openclaw). Make sure the gateway is enabled:

In `~/.openclaw/openclaw.json`:

```json
{
  "gateway": {
    "port": 18789,
    "bind": "lan",
    "auth": {
      "mode": "token",
      "token": "your-gateway-token-here"
    },
    "http": {
      "endpoints": {
        "chatCompletions": { "enabled": true }
      }
    }
  }
}
```

Key settings:
- `bind: "lan"` -- exposes the gateway on your local network so your phone can reach it
- `chatCompletions.enabled: true` -- enables the `/v1/chat/completions` endpoint (off by default)
- `auth.token` -- the token your app will use to authenticate

### 2. Configure the app

**iOS** -- In `Secrets.swift`:
```swift
static let openClawHost = "http://Your-Mac.local"
static let openClawPort = 18789
static let openClawGatewayToken = "your-gateway-token-here"
```

**Android** -- In `Secrets.kt`:
```kotlin
const val openClawHost = "http://Your-Mac.local"
const val openClawPort = 18789
const val openClawGatewayToken = "your-gateway-token-here"
```

To find your Mac's Bonjour hostname: **System Settings > General > Sharing** -- it's shown at the top (e.g., `Johns-MacBook-Pro.local`).

> Both iOS and Android also have an in-app Settings screen where you can change these values at runtime without editing source code.

### 3. Start the gateway

```bash
openclaw gateway restart
```

Verify it's running:

```bash
curl http://localhost:18789/health
```

Now when you talk to the AI, it can execute tasks through OpenClaw.

> **Onboarding wizard caveat:** `openclaw onboard` does **not** add `gateway.http.endpoints.chatCompletions.enabled = true` to `~/.openclaw/openclaw.json` on its own. Without that key, the gateway responds **200 to GET** `/v1/chat/completions` (so the app's probe says "Connected") but **404 to POST** (so every tool call fails). After running the wizard, open `~/.openclaw/openclaw.json` and add the `chatCompletions` block manually, then restart the gateway. The app's diagnostic UI will say *"chatCompletions endpoint disabled — enable it in openclaw.json"* when this happens.

### 4. Use OpenClaw from cellular / off-LAN (Tailscale Serve + HTTPS)

By default the iOS app reaches the gateway via your Mac's Bonjour `.local` hostname, which only resolves on the same Wi-Fi network as your Mac. To use OpenClaw from cellular (5G/LTE), a different Wi-Fi network, or anywhere off-LAN, route through **Tailscale Serve** — it gives you a free auto-HTTPS endpoint with a valid Let's Encrypt cert, so iOS App Transport Security is happy without any plist hacks.

1. **Install [Tailscale](https://tailscale.com/download)** on both your Mac and your iPhone, sign in to the same tailnet on both, and confirm both devices appear in `tailscale status`.

2. **Expose the gateway over HTTPS** on the Mac:

   ```bash
   /Applications/Tailscale.app/Contents/MacOS/Tailscale serve --bg 18789
   ```

   Tailscale provisions a Let's Encrypt cert and prints your tailnet URL — something like:

   ```
   https://<your-mac>.<tailnet>.ts.net/
   |-- proxy http://127.0.0.1:18789
   ```

   The serve config persists across reboots. To inspect later: `tailscale serve status`. To remove: `tailscale serve --https=443 off`.

3. **Set the Remote URL in the app:** open VisionClaw → tap the gear icon → **Settings** → fill in **Remote URL (Tailscale / Public)** with the HTTPS URL from the previous step (no port number — Tailscale Serve uses 443) → **Save**. The gateway resolver tries this first and falls back to the LAN `.local` host when you're back on home Wi-Fi.

4. **Verify reachability without launching the app** (sanity check): turn Wi-Fi off on the iPhone, confirm cellular in the status bar, and visit the URL in Safari. A response of `{"ok":true,"status":"live"}` proves Tailscale routing is working.

> **Why not plain HTTP to the Tailscale IP?** It looks tempting but breaks: iOS App Transport Security blocks plain HTTP to `100.x.x.x` (CGNAT) addresses because they aren't covered by `NSAllowsLocalNetworking`. You can work around it with `NSAllowsArbitraryLoads`, but Tailscale Serve is the cleaner solution — proper HTTPS with a real cert, no plist exceptions needed, and no per-app local-network permission prompts.

### 5. (Optional) Run OpenClaw on a remote VPS instead of your Mac

If you want OpenClaw available even when your Mac is asleep or off your network, host the gateway on a small always-on cloud VM. Tailscale Serve still provides the HTTPS endpoint exactly the same way — the only difference is the gateway runs on a Linux droplet instead of macOS. Tested on a DigitalOcean **$6/mo 1GB Ubuntu 24.04** droplet.

1. **Provision a droplet** (or comparable Linux VPS):

   ```bash
   doctl compute droplet create openclaw \
     --image ubuntu-24-04-x64 --size s-1vcpu-1gb --region <near-you> \
     --ssh-keys <your-do-ssh-key-id> --wait
   ```

2. **Add ~4 GB of swap** before installing anything. With only 1 GB RAM the Claude Code installer's native build is OOM-killed by the kernel; swap fixes it.

   ```bash
   sudo fallocate -l 4G /swapfile && sudo chmod 600 /swapfile \
     && sudo mkswap /swapfile && sudo swapon /swapfile \
     && echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   ```

3. **Create an unprivileged user** for OpenClaw. This matters specifically because OpenClaw runs Chrome for browser automation — and Chrome refuses to run its sandbox as root. Running as a normal user keeps the sandbox enabled.

   ```bash
   sudo adduser --disabled-password --gecos "" openclaw
   echo 'openclaw ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/openclaw
   sudo chmod 0440 /etc/sudoers.d/openclaw
   sudo cp /root/.ssh/authorized_keys /home/openclaw/.ssh/authorized_keys
   sudo chown -R openclaw:openclaw /home/openclaw/.ssh
   ```

   The rest of this section assumes you SSH in as `openclaw@<droplet-ip>`.

4. **Install Node (via nvm), Google Chrome, Claude Code, and OpenClaw:**

   ```bash
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
   source ~/.bashrc
   nvm install --lts

   curl -sS https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
   echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
   sudo apt update && sudo apt install -y google-chrome-stable

   curl -fsSL https://claude.ai/install.sh | bash
   claude                          # complete the OAuth flow on your laptop
   npm install -g openclaw
   openclaw onboard                # interactive — needs a real TTY (just `ssh` in, not `ssh host '...'`)
   ```

5. **Manually enable the chatCompletions endpoint** (the wizard does not — see the callout in step 3 above). Add the `endpoints.chatCompletions.enabled` key to `~/.openclaw/openclaw.json` and restart:

   ```bash
   python3 -c "
   import json, pathlib
   p = pathlib.Path.home() / '.openclaw' / 'openclaw.json'
   d = json.loads(p.read_text())
   d.setdefault('gateway',{}).setdefault('http',{}).setdefault('endpoints',{})['chatCompletions'] = {'enabled': True}
   p.write_text(json.dumps(d, indent=2))
   "
   openclaw gateway restart
   curl -s http://127.0.0.1:18789/health    # should print {"ok":true,"status":"live"}
   ```

   > **A note on `bind`:** the wizard typically writes `"bind": "loopback"` for a server install — **keep that**. Unlike the Mac path (which uses `"bind": "lan"` so your phone can hit the gateway directly over Wi-Fi), the VPS never exposes port 18789 to the public internet. Tailscale Serve proxies from `127.0.0.1:18789` to your HTTPS URL, so the gateway only needs to listen on loopback. This keeps the gateway unreachable except via the Tailscale tunnel — strictly more secure than `"lan"` would be on a public-IP VPS.

6. **Install Tailscale and expose the gateway over HTTPS:**

   ```bash
   curl -fsSL https://tailscale.com/install.sh | sh
   sudo tailscale up                  # open the printed URL on your laptop to authenticate
   sudo tailscale serve --bg 18789
   tailscale serve status             # prints the public https://<droplet>.<tailnet>.ts.net URL
   ```

7. **Set the iOS app's Remote URL** to that HTTPS URL and copy the gateway token from `~/.openclaw/openclaw.json` (`gateway.auth.token`) into the app's **Gateway Token** field. Save in the in-app Settings, then force-quit and reopen the app — `OpenClawBridge` caches the resolved URL per session and won't pick up the change otherwise.

> **Run the gateway under systemd** for auto-restart on reboot (recommended): create `/etc/systemd/system/openclaw.service` with `User=openclaw`, `ExecStart=/home/openclaw/.nvm/versions/node/<ver>/bin/openclaw gateway start --foreground`, `Restart=always`, then `sudo systemctl enable --now openclaw`.

---

## Known Issues

### OpenClaw WebSocket handshake fails: `client.id must be equal to constant`

The proactive-notification WebSocket (the live event stream from OpenClaw to the app) is rejected by the gateway with:

```
[OpenClawWS] Connect failed: invalid connect params:
  at /client/id: must be equal to constant;
  at /client/id: must match a schema in anyOf
```

This is a schema mismatch between the iOS app's `connect` handshake (`client.id = "ios-node"` in `OpenClawEventClient.swift`) and a tightened OpenClaw gateway schema. **Tool calls (HTTP) are unaffected** — only proactive notifications are broken. The app will retry forever in the background, which is harmless but spams the logs.

### "An internal error occurred. Please try again." on Start Streaming

Comes from Meta's DAT SDK (`StreamSessionViewModel.swift:formatStreamingError`), surfaced when the SDK's internal connection to the glasses fails for a non-specific reason. **Not** related to OpenClaw, Gemini, or the network setup.

Common fixes:

- Restart the glasses (press and hold the power button until they reboot)
- Force-quit both **VisionClaw** and the **Meta AI** app, then reopen Meta AI first to confirm Developer Mode is on and the glasses are connected, then reopen VisionClaw
- Toggle Bluetooth off/on
- Take the glasses out of the charging case (low-power mode blocks streaming)

---

## Architecture

### Key Files (iOS)

All source code is in `samples/CameraAccess/CameraAccess/`:

| File | Purpose |
|------|---------|
| `Gemini/GeminiConfig.swift` | API keys, model config, system prompt |
| `Gemini/GeminiLiveService.swift` | WebSocket client for Gemini Live API |
| `Gemini/AudioManager.swift` | Mic capture (PCM 16kHz) + audio playback (PCM 24kHz) |
| `Gemini/GeminiSessionViewModel.swift` | Session lifecycle, tool call wiring, transcript state |
| `OpenClaw/ToolCallModels.swift` | Tool declarations, data types |
| `OpenClaw/OpenClawBridge.swift` | HTTP client for OpenClaw gateway |
| `OpenClaw/ToolCallRouter.swift` | Routes Gemini tool calls to OpenClaw |
| `iPhone/IPhoneCameraManager.swift` | AVCaptureSession wrapper for iPhone camera mode |
| `WebRTC/WebRTCClient.swift` | WebRTC peer connection + SDP negotiation |
| `WebRTC/SignalingClient.swift` | WebSocket signaling for WebRTC rooms |

### Key Files (Android)

All source code is in `samples/CameraAccessAndroid/app/src/main/java/.../cameraaccess/`:

| File | Purpose |
|------|---------|
| `gemini/GeminiConfig.kt` | API keys, model config, system prompt |
| `gemini/GeminiLiveService.kt` | OkHttp WebSocket client for Gemini Live API |
| `gemini/AudioManager.kt` | AudioRecord (16kHz) + AudioTrack (24kHz) |
| `gemini/GeminiSessionViewModel.kt` | Session lifecycle, tool call wiring, UI state |
| `openclaw/ToolCallModels.kt` | Tool declarations, data classes |
| `openclaw/OpenClawBridge.kt` | OkHttp HTTP client for OpenClaw gateway |
| `openclaw/ToolCallRouter.kt` | Routes Gemini tool calls to OpenClaw |
| `phone/PhoneCameraManager.kt` | CameraX wrapper for phone camera mode |
| `webrtc/WebRTCClient.kt` | WebRTC peer connection (stream-webrtc-android) |
| `webrtc/SignalingClient.kt` | OkHttp WebSocket signaling for WebRTC rooms |
| `settings/SettingsManager.kt` | SharedPreferences with Secrets.kt fallback |

### Audio Pipeline

- **Input**: Phone mic -> AudioManager (PCM Int16, 16kHz mono, 100ms chunks) -> Gemini WebSocket
- **Output**: Gemini WebSocket -> AudioManager playback queue -> Phone speaker
- **iOS iPhone mode**: Uses `.voiceChat` audio session for echo cancellation + mic gating during AI speech
- **iOS Glasses mode**: Uses `.videoChat` audio session (mic is on glasses, speaker is on phone -- no echo)
- **Android**: Uses `VOICE_COMMUNICATION` audio source for built-in acoustic echo cancellation

### Video Pipeline

- **Glasses**: DAT SDK video stream (24fps) -> throttle to ~1fps -> JPEG (50% quality) -> Gemini
- **Phone**: Camera capture (30fps) -> throttle to ~1fps -> JPEG -> Gemini

### Tool Calling

Gemini Live supports function calling. Both apps declare a single `execute` tool that routes everything through OpenClaw:

1. User says "Add eggs to my shopping list"
2. Gemini speaks a brief acknowledgment (verbal confirmation before tool call)
3. Gemini sends `toolCall` with `execute(task: "Add eggs to the shopping list")`
4. `ToolCallRouter` sends HTTP POST to OpenClaw gateway
5. OpenClaw executes the task using its 56+ connected skills
6. Result returns to Gemini via `toolResponse`
7. Gemini speaks the result

**Verbatim pass-through (this fork):** the default system prompt in `GeminiConfig.defaultSystemInstruction` configures Gemini as a transparent voice relay rather than an agent — it must immediately call `execute` for every utterance and read OpenClaw's response **word-for-word**, with no paraphrasing, summary, or commentary. The acknowledgment in step 2 is one short polite Korean phrase ("네, 확인할게요.", "잠시만요.", etc.); the response in step 7 is read in Korean (translating from the source language if needed). To customize, edit the prompt in `GeminiConfig.swift` or override at runtime via the in-app **Settings → System Prompt** field.

**Photo attachments:** tapping the camera button in glasses mode auto-attaches the captured JPEG to the next `execute` call as an OpenAI-compatible `image_url` part. OpenClaw skills can then act on the photo (e.g. "save this to my notes", "what is this object?", OCR, etc.). The pending image is cleared after one use.

### WebRTC Live Streaming

Share your glasses POV in real-time to a browser viewer with bidirectional audio and video.

1. Tap the **Live** button in the app
2. The app connects to a signaling server and gets a 6-character room code
3. Share the code -- the viewer opens the server URL in a browser and enters it
4. WebRTC peer connection is established (SDP + ICE via the signaling server)
5. Media flows peer-to-peer: glasses video to browser, browser camera back to iOS PiP

**Key details:**
- **Signaling server**: Node.js + WebSocket, located at `samples/CameraAccess/server/` -- serves the browser viewer and relays SDP/ICE
- **NAT traversal**: Google STUN servers + ExpressTURN relay (fetched from `/api/turn`)
- **Video**: 24 fps, 2.5 Mbps max bitrate
- **Background handling**: 60-second grace period for iOS app backgrounding -- room stays alive for reconnection
- **Constraint**: Cannot run simultaneously with Gemini Live (audio device conflict)

For full details, see [`samples/CameraAccess/CameraAccess/WebRTC/README.md`](samples/CameraAccess/CameraAccess/WebRTC/README.md).

---

## Requirements

### iOS
- iOS 17.0+
- Xcode 15.0+
- Gemini API key ([get one free](https://aistudio.google.com/apikey))
- Meta Ray-Ban glasses (optional -- use iPhone mode for testing)
- OpenClaw on your Mac (optional -- for agentic actions)

### Android
- Android 14+ (API 34+)
- Android Studio Ladybug or newer
- GitHub account with `read:packages` token (for DAT SDK)
- Gemini API key ([get one free](https://aistudio.google.com/apikey))
- Meta Ray-Ban glasses (optional -- use Phone mode for testing)
- OpenClaw on your Mac (optional -- for agentic actions)

---

## Troubleshooting

### General

**Gemini doesn't hear me** -- Check that microphone permission is granted. The app uses aggressive voice activity detection -- speak clearly and at normal volume.

**OpenClaw connection timeout** -- Make sure your phone and Mac are on the same Wi-Fi network, the gateway is running (`openclaw gateway restart`), and the hostname matches your Mac's Bonjour name.

**OpenClaw opens duplicate browser tabs** -- This is a known upstream issue in OpenClaw's CDP (Chrome DevTools Protocol) connection management ([#13851](https://github.com/nichochar/openclaw/issues/13851), [#12317](https://github.com/nichochar/openclaw/issues/12317)). Using `profile: "openclaw"` (managed Chrome) instead of the default extension relay may improve stability.

### iOS-specific

**"Gemini API key not configured"** -- Add your API key in Secrets.swift or in the in-app Settings.

**Echo/feedback in iPhone mode** -- The app mutes the mic while the AI is speaking. If you still hear echo, try turning down the volume.

### Android-specific

**Gradle sync fails with 401 Unauthorized** -- Your GitHub token is missing or doesn't have `read:packages` scope. Check `local.properties` for `gpr.user` and `gpr.token`. Generate a new token at [github.com/settings/tokens](https://github.com/settings/tokens).

**Gemini WebSocket times out** -- The Gemini Live API sends binary WebSocket frames. If you're building a custom client, make sure to handle both text and binary frame types.

**Audio not working** -- Ensure `RECORD_AUDIO` permission is granted. On Android 13+, you may need to grant this permission manually in Settings > Apps.

**Phone camera not starting** -- Ensure `CAMERA` permission is granted. CameraX requires both the permission and a valid lifecycle.

For DAT SDK issues, see the [developer documentation](https://wearables.developer.meta.com/docs/develop/) or the [discussions forum](https://github.com/facebook/meta-wearables-dat-ios/discussions).

## Citation

If you use VisionClaw in your research, please cite our paper:

```bibtex
@article{liu2026visionclaw,
  title={VisionClaw: Always-On AI Agents through Smart Glasses},
  author={Liu, Xiaoan and Lee, DaeHo and Gonzalez, Eric J and Gonzalez-Franco, Mar and Suzuki, Ryo},
  journal={arXiv preprint arXiv:2604.03486},
  year={2026}
}
```

## License

This source code is licensed under the license found in the [LICENSE](LICENSE) file in the root directory of this source tree.
