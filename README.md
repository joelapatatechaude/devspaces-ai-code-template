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
     name: litemass-llm
     namespace: <username>-devspaces
     labels:
       controller.devfile.io/devworkspace-mount-secret: "true"
     annotations:
       controller.devfile.io/mount-as: env
   type: Opaque
   stringData:
     LLM_API_KEY: "<your-api-key>"
     LLM_API_BASE_URL: "<your-llm-endpoint, e.g. https://api.litemass.com/v1>"
   ```

   Or via CLI:

   ```bash
   oc create secret generic litemass-llm \
     --from-literal=LLM_API_KEY='<your-api-key>' \
     --from-literal=LLM_API_BASE_URL='<your-llm-endpoint>' \
     -n <username>-devspaces

   oc label secret litemass-llm \
     controller.devfile.io/devworkspace-mount-secret=true \
     -n <username>-devspaces

   oc annotate secret litemass-llm \
     controller.devfile.io/mount-as=env \
     -n <username>-devspaces
   ```

   The secret values override the defaults in the devfile. Restart your workspace after creating or updating the secret.

2. **Launch the workspace** from your DevSpaces dashboard:

   ```
   https://<devspaces-url>/#https://github.com/<owner>/devspaces-ai-code-template
   ```

3. **Use Cline** -- open the Cline panel in the VS Code sidebar.

4. **Use OpenCode** -- open a terminal to the `opencode` container and run `opencode`.

## Customisation

- **LLM endpoint**: the recommended way is via the user secret above. To change the defaults baked into the workspace, edit `LLM_API_BASE_URL` and `LLM_MODEL_ID` in `devfile.yaml`, `.vscode/settings.json`, and `opencode.json`.
- **LLM model**: change `LLM_MODEL_ID` in the devfile and update `.vscode/settings.json` and `opencode.json` to match.
- **App code**: replace `app.py` with your own Python application.
