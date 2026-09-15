# AGENTS.md — Project Context for AI Coding Agents

## Environment

You are running inside **Red Hat OpenShift DevSpaces** — a cloud-based development workspace on an OpenShift (Kubernetes) cluster. This is NOT a local machine.

Key facts:
- **Container image**: Universal Developer Image (UDI) — `registry.redhat.io/devspaces/udi-rhel8:latest`
- **Working directory**: `/projects/devspaces-ai-code-template`
- **User**: `user` (non-root, UID assigned by OpenShift)
- **Storage**: Per-workspace Persistent Volume (10Gi). Files in `/projects/` persist across workspace restarts. Files outside `/projects/` (e.g. `/home/user/.local/`) are reset on restart.
- **Internet access**: Available but DNS resolution to external hosts can be slow (1-3 seconds cold, then cached). Plan for network calls taking longer than on a local machine.

## LLM Configuration

By default, the LLM provider is **LiteMaaS** (an OpenAI-compatible API gateway):
- **Endpoint**: Set via `LLM_API_BASE_URL` environment variable (injected from a Kubernetes Secret)
- **API key**: Set via `LLM_API_KEY` environment variable (injected from a Kubernetes Secret)
- **Model**: `gpt-oss-120b` — a reasoning model. It returns `reasoning_content` alongside `content`.
- **Config file**: `opencode.json` at the project root
LLM provider might have changed when running.

## Known Limitations

1. **Terminal**: The VS Code integrated terminal may not work on first open (missing `kubeconfig`). Use the "Tasks" panel or OpenCode's built-in shell tool instead.
32. **DNS latency**: First DNS resolution for external domains (e.g. `github.com`, `api.openai.com`) can take 1-3 seconds due to cluster DNS search-domain expansion. Subsequent lookups are cached.
3. **No Docker/Podman**: Container builds are not available inside the workspace. Use `oc` from outside or alternative build strategies.

## Project Structure

This is a **template project** for AI-assisted development on DevSpaces. It comes with:

- `devfile.yaml` — DevSpaces workspace definition (components, commands, env vars)
- `opencode.json` — OpenCode AI agent configuration (LLM provider, model)
- `.vscode/extensions.json` — VS Code extensions (Cline, Task Manager, OpenCode)
- `AGENTS.md` — This file (project context for AI agents)

## Development Workflow

1. The workspace starts with OpenCode and Cline pre-installed.
2. Use OpenCode (terminal) or Cline (VS Code sidebar) for AI-assisted coding.
3. The Flask app runs on port 8080 — DevSpaces exposes it via an HTTPS route.
4. Commit changes to `/projects/devspaces-ai-code-template/` — this is a Git repo.

## Conventions

- Prefer Node.js or Python for new code (both runtimes are available in the UDI).
- Keep secrets out of code — use environment variables from Kubernetes Secrets.
- Test changes before committing. The workspace has `python3`, `pip`, `node`, `npm` available.
- When creating files, place them in the project directory (`/projects/devspaces-ai-code-template/`), not in `/home/user/` or `/tmp/`.
