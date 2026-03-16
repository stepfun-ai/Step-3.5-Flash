# OpenClaw + Step 3.5 Flash Setup Guide

Install, Configure, and Deploy **OpenClaw** on MacOS with **Step 3.5 Flash**.

## Prerequisites

- **OS:** MacOS (Apple Silicon/Intel)
- **Runtime:** Node.js (optional, if using npm)

## Installation

Choose one of the following methods to install OpenClaw:

### Option 1: Official Script (Recommended)
```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

### Option 2: NPM
```bash
npm i -g openclaw
# If you encounter permission errors, use sudo
```

## Quick Start: Onboarding

Initialize your agent using the setup wizard.

1.  **Run the onboard command:**
    ```bash
    openclaw onboard
    ```

2.  **Follow the Wizard:**
    *   **Welcome:** Select `Yes`.
    *   **Mode:** Select `Quick Start`.
    *   **Model Config:** Select `Skip for now` (we will configure Step 3.5 Flash in the WebUI).
    *   **Integrations:** Select `Skip for now` (configure Telegram later if needed).
    *   **Finalize:** Keep defaults (press `Enter`).

    <details>
    <summary>📷 View Onboarding Screenshots</summary>

    | Step | Screenshot |
    | :--- | :--- |
    | **Welcome** | ![Welcome](assets/(null)-20260205105935763.(null)) |
    | **Quick Start** | ![Quick Start](assets/(null)-20260205105935750.(null)) |
    | **Skip Model** | ![Skip Model](assets/(null)-20260205105935751.(null)) |
    | **Complete** | ![Complete](assets/(null)-20260205105936846.(null)) |

    </details>

3.  **Launch WebUI:**
    If prompted, select **WebUI** to open the dashboard. If missed, run:
    ```bash
    openclaw dashboard
    ```

## Automated Setup Scripts ⚡

If you prefer command-line automation, use our one-line setup scripts.

### Linux / macOS

```bash
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/stepfun-ai/Step-3.5-Flash/main/cookbooks/openclaw/add_stepfun.sh | sudo bash
```

> **Note:** If `gh-proxy.com` is slow, use the direct link:
> ```bash
> curl -fsSL https://raw.githubusercontent.com/stepfun-ai/Step-3.5-Flash/main/cookbooks/openclaw/add_stepfun.sh | sudo bash
> ```

### Windows (PowerShell)

Run PowerShell **as Administrator** and execute:

```powershell
irm "https://gh-proxy.com/https://raw.githubusercontent.com/stepfun-ai/Step-3.5-Flash/main/cookbooks/openclaw/install_stepfun.ps1" -UseBasicParsing | iex
```

> The script will automatically request elevation if not already running as admin.

### What the Scripts Do

- ✅ Interactive selection: **OpenRouter Free** (50 RPM limit) or **StepFun Official API** (pay-as-you-go)
- ✅ Automatic backup of `~/.openclaw/openclaw.json` with timestamp
- ✅ Validates dependencies (`jq` on Linux/macOS, admin rights on Windows)
- ✅ Configures provider settings and sets Step 3.5 Flash as primary model
- ✅ UTF-8 encoding support for Windows console

### Configuration Result

After running the script, your `~/.openclaw/openclaw.json` will have:

<details>
<summary>📄 View configuration template</summary>

```json
{
  "models": {
    "providers": {
      "stepfun": {
        "baseUrl": "https://api.stepfun.com/v1",
        "apiKey": "YOUR_API_KEY",
        "api": "openai-completions",
        "models": [
          {
            "id": "stepfun/step-3.5-flash",
            "name": "Step 3.5 Flash",
            "reasoning": false,
            "input": ["text"],
            "cost": {
              "input": 0,
              "output": 0,
              "cacheRead": 0,
              "cacheWrite": 0
            },
            "contextWindow": 256000,
            "maxTokens": 8192
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "stepfun/step-3.5-flash"
      }
    }
  }
}
```
</details>

---

## Configuring Step 3.5 Flash

You can configure the model via the **WebUI** (Recommended) or by editing the **JSON config**.

### Method 1: WebUI Configuration (Recommended)

1.  **Open Settings:** Navigate to **Config** -> **Models** -> **Providers**.
    ![Providers](assets/(null)-20260205105937100.(null))

2.  **Add Provider:**
    *   Click **Add Entry**.
    *   **Name:** `stepfun` (or `custom-1`).
    *   **API Type:** `openai-completions`.
    *   **Base URL:**
        -   **StepFun (International):** `https://api.stepfun.ai/v1`
        -   **StepFun (China):** `https://api.stepfun.com/v1`
        -   **OpenRouter:** `https://openrouter.ai/api/v1`
    *   **API Key:** Enter your StepFun API Key.
    ![Add Provider](assets/(null)-20260205105937478.(null))

3.  **Add Model:**
    *   Scroll to the **Models** section and click **Add**.
    *   **ID:** `step-3.5-flash` (or `stepfun/step-3.5-flash` for OpenRouter).
    *   **Name:** `Step 3.5 Flash`.
    *   **Context Window:** `256000` (This is the maxium context window size for Step 3.5 Flash).
    ![Add Model](assets/(null)-20260205105937340.(null))

4.  **Set as Primary:**
    *   Search for `primary` in the settings.
    *   Set value to `"stepfun/step-3.5-flash"`.
    *   **Save & Reload**: Click the Save icon 💾, then the Reload icon 🔄.
    ![Primary](assets/(null)-20260205105938037.(null))

### Method 2: Manual JSON Configuration

Edit `~/.openclaw/openclaw.json` directly.

<details>
<summary>📄 Click to view `openclaw.json` template</summary>

```json
{
  "models": {
    "providers": {
      "stepfun": {
        "baseUrl": "https://api.stepfun.ai/v1", // OR https://api.stepfun.com/v1 (China) OR https://openrouter.ai/api/v1
        "apiKey": "YOUR_SK_KEY_HERE",
        "auth": "api-key",
        "api": "openai-completions",
        "models": [
          {
            "id": "step-3.5-flash", // OR stepfun/step-3.5-flash
            "name": "Step 3.5 Flash",
            "contextWindow": 256000,
            "maxTokens": 8192
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "stepfun/step-3.5-flash"
      }
    }
  }
}
```
</details>

## Integrations (Optional)

### Telegram Bot
1. **Create Bot:** Chat with [BotFather](https://t.me/botfather), run `/newbot` to get a **Token**.
2. **Get User ID:** Chat with [userinfobot](https://t.me/userinfobot) to get your **ID**.
3. **Configure:** In `openclaw onboard` (or GUI), input the Token and ID.

## Command Reference

| Command | Description |
| :--- | :--- |
| `openclaw onboard` | Re-run setup wizard. |
| `openclaw dashboard` | Open the WebUI. |
| `openclaw gateway` | Start background service (Telegram/WhatsApp). |
| `openclaw gui` | Open native desktop app. |

## Troubleshooting

**WebUI Won't Open**
Run `openclaw onboard` again to ensure the gateway is initialized correctly.

**Model Not Responding**
1. Check **Error Logs** in WebUI.
2. Verify `apiKey` and `baseUrl` are correct.
3. Use the connection test script below.

<details>
<summary>🐍 Python Connection Test Script</summary>

```python
import os
from openai import OpenAI

# Configuration
MODEL = "step-3.5-flash" 
API_KEY = "YOUR_API_KEY"      
BASE_URL = "https://api.stepfun.ai/v1" # OR https://api.stepfun.com/v1 (China) OR https://openrouter.ai/api/v1

client = OpenAI(api_key=API_KEY, base_url=BASE_URL)

try:
    print("Testing connection...")
    resp = client.chat.completions.create(
        model=MODEL,
        messages=[{"role": "user", "content": "Hello, are you working?"}],
        stream=False
    )
    print(f"Response: {resp.choices[0].message.content}")
except Exception as e:
    print(f"Error: {e}")
```
</details>
