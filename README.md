# DevSpaces AI Code Template

A Python project template for OpenShift DevSpaces with **Cline** (VS Code AI agent) and **OpenCode** (terminal AI agent) pre-configured.

## What you get

When you open this repo in DevSpaces, your workspace includes:

| Tool | Where | What it does |
|------|-------|-------------|
| **Cline** | VS Code sidebar | Agentic AI coding assistant inside the editor |
| **OpenCode** | Terminal sidecar | Terminal-based AI coding assistant |
| **Flask app** | Port 8080 | Simple hello-world UI to start building from |

## Quick start

1. **Set up your LLM API key** as a DevSpaces user secret.

   Create this secret in your DevSpaces user namespace (e.g. `<username>-devspaces`):

   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: llm-credentials
     namespace: <username>-devspaces
     labels:
       controller.devfile.io/mount-to-devworkspace: "true"
       controller.devfile.io/watch-secret: "true"
     annotations:
       controller.devfile.io/mount-as: env
   type: Opaque
   stringData:
     LLM_API_KEY: "<your-api-key>"
   ```

   Or via CLI:

   ```bash
   oc create secret generic llm-credentials \
     --from-literal=LLM_API_KEY='<your-api-key>' \
     -n <username>-devspaces

   oc label secret llm-credentials \
     controller.devfile.io/mount-to-devworkspace=true \
     controller.devfile.io/watch-secret=true \
     -n <username>-devspaces

   oc annotate secret llm-credentials \
     controller.devfile.io/mount-as=env \
     -n <username>-devspaces
   ```

   > **Note:** The secret injects `LLM_API_KEY` into all workspace containers.
   > The LLM endpoint (`LLM_API_BASE_URL`) and model are set directly in the
   > devfile and cannot be overridden via a secret — edit `devfile.yaml`,
   > `.vscode/settings.json`, and `opencode.json` in your fork to change them.

   Restart your workspace after creating or updating the secret.

2. **Launch the workspace** from your DevSpaces dashboard:

   ```
   https://<devspaces-url>/#https://github.com/<owner>/devspaces-ai-code-template
   ```

3. **Use Cline** -- open the Cline panel in the VS Code sidebar.

4. **Use OpenCode** -- open a terminal to the `opencode` container and run `opencode`.

## Customisation

- **LLM endpoint and model**: edit `LLM_API_BASE_URL` in `devfile.yaml`, `opencode.json`, and `.vscode/settings.json`. These are set at workspace build time and cannot be overridden via a secret.
- **App code**: replace `app.py` with your own Python application.
