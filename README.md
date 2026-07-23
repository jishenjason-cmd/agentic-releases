# Agentic

Agentic is a proprietary coding-agent distribution maintained by Vector Workshop and derived from the MIT-licensed [OpenCode](https://github.com/anomalyco/opencode) project. It keeps OpenCode-compatible providers, plugins, configuration, OAuth, Zen, and Go service boundaries while adding an independent Agentic product identity, release channel, desktop distribution, and selected workflow improvements.

This page is the canonical public entry point for Agentic-specific behavior. For upstream-compatible configuration and APIs, use the [OpenCode documentation](https://opencode.ai/docs).

## Current release

| Product | Version | Published platform |
|---|---:|---|
| CLI / npm | `agency-agentic@1.0.0` | npm package; the current GitHub compatibility archive is macOS arm64 |
| Agentic Desktop | `1.0.0` | macOS arm64, ad-hoc signed and not Apple-notarized |
| Upstream baseline | OpenCode `v1.18.4` | Agentic follows stable OpenCode releases and does not pre-emptively adopt the unfinished dev/v2 runtime |

The published platform list describes what was built and verified for this release. It is not a claim that other operating systems or architectures have passed the same release gates.

## Install

Install the npm CLI:

```bash
npm install --global agency-agentic
agentic --version
```

Install the current compatible GitHub binary for a supported platform:

```bash
curl -fsSL https://raw.githubusercontent.com/jishenjason-cmd/agentic-releases/main/install.sh | bash
agentic --version
```

Desktop packages are published in [Agentic Desktop Releases](https://github.com/jishenjason-cmd/agentic-desktop-releases/releases). Check the release notes, checksum, signing, notarization, architecture, and operating-system scope before installing.

## Agentic-specific behavior

Agentic intentionally keeps its fork surface narrow. Current product-specific or explicitly retained capabilities include:

- Agentic command, configuration, data, application, protocol, visual identity, and independent release channels.
- CLI, TUI, version-matched Web UI, and Desktop product surfaces.
- `AGENTS.md` instruction discovery across global, project-root, and nested directory scopes, with closer instructions applied as files are accessed.
- Upstream model-specific prompt strategies plus a thin generic engineering discipline covering diagnosis, sensitive information, minimal changes, and truthful verification.
- Agentic Desktop aligned with the official Electron `utilityProcess` and Node server-sidecar lifecycle.
- Session recovery when a persisted working directory was deleted but the same project's valid worktree still exists.
- Optional Agentic Flow orchestration through the separately versioned `@vector-workshop/agentic-flow` plugin.
- Optional working-memory or Agentmemory integrations through standard plugin or MCP boundaries; Agentic 1.0 does not embed Agentmemory in its core runtime.

Agentic does not replace OpenCode service identities, provider IDs, protocol headers, package names, OAuth endpoints, Zen, Go, Share, or plugin SDK compatibility identifiers with invented Agentic services.

## Runtime surfaces

```text
CLI
  Agentic stable CLI runtime
    ├─ providers, sessions, tools and standard plugins
    └─ version-matched local Web UI

Desktop
  Electron main process
    └─ Node utility-process sidecar
         └─ the same Agentic server and plugin boundary

Browser
  Web UI connected to an Agentic server
  Plugins and MCP servers run on that server, not in the browser
```

CLI, Desktop, and Web can operate at the same time, but each server process owns its own live session lifecycle. Shared external services, such as a memory daemon, must define their own concurrency, identity, storage, and migration behavior.

## Configuration and project instructions

Agentic's native user configuration is stored under:

```text
~/.config/agentic/agentic.json
~/.config/agentic/agentic.jsonc
```

Project configuration can use `.agentic/`; compatible `.opencode/` configuration and required OpenCode ecosystem fields continue to be read where supported. Agentic-specific configuration takes precedence when both forms are present.

Project rules use the upstream-standard filename `AGENTS.md`. Agentic does not introduce an `AGENTIC.md` alias. A project can combine global instructions, a root `AGENTS.md`, and nested `AGENTS.md` files for directory-specific guidance.

For the complete upstream schema, providers, agents, commands, permissions, MCP, plugins, and SDK behavior, consult [OpenCode Docs](https://opencode.ai/docs).

## Flow and optional memory

Agentic Flow is not enabled implicitly. Install and configure the separately released `@vector-workshop/agentic-flow` plugin only when its orchestration behavior is wanted; ordinary Agentic sessions should not pay its routing cost by default.

Agentic 1.0 does not define a private `agentmemory` schema or register built-in `memory_*` tools. Memory integrations are external and must document their own Node/Bun compatibility, data location, hooks, model or embedding costs, migration, and failure behavior. Existing `~/.agentmemory` data is not deleted or migrated automatically.

## Agentic docs versus OpenCode docs

Use this repository for:

- Agentic versions, release artifacts, installation, checksums, and supported platforms.
- Agentic CLI/Desktop/Web architecture and product-specific behavior.
- Agentic Flow and optional memory integration boundaries.
- Agentic branding, feedback, and distribution questions.

Use [OpenCode Docs](https://opencode.ai/docs) for:

- Upstream-compatible configuration fields and schema.
- Providers, models, agents, commands, tools, permissions, MCP, plugins, and SDK APIs.
- OpenCode OAuth, Console, Zen, Go, Share, and other OpenCode-operated services.

Do not infer an Agentic-specific capability solely from OpenCode documentation, and do not treat an Agentic product difference as an upstream OpenCode guarantee.

## Distribution and security

Agentic release artifacts declare `UNLICENSED`; OpenCode's MIT license and applicable third-party notices remain bundled with the distribution. Do not mirror or redistribute Agentic packages without explicit permission.

Verify release checksums before installation. Signing and notarization are platform-specific release properties and are disclosed per release rather than inferred from whether a release is marked stable.

## Feedback

Report Agentic installation, packaging, Desktop, branding, or Agentic-specific behavior issues in [Agentic Releases issues](https://github.com/jishenjason-cmd/agentic-releases/issues).

When a problem reproduces in upstream OpenCode without an Agentic-specific change, consult the [OpenCode repository](https://github.com/anomalyco/opencode) and its documentation instead.
