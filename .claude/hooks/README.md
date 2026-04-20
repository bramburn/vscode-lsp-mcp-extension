# Pre-commit Hooks & Validation

This directory contains validation hooks that enforce the project's architectural constraints, patterns, and quality standards.

## Quick Start

Before pushing code, run all checks:

```bash
./.claude/hooks/run-all-checks.sh
```

This orchestrates five sub-checks (see below). If all pass, you're ready to:

```bash
pnpm run check-types && pnpm run lint && pnpm test-unit && pnpm test-mcp && git push
```

## Individual Hooks

### `pre-commit-clauderules-check.sh`

Validates architectural constraints from `.clauderules`:

- ✅ `src/server/**` has no `import "vscode"` (server isolation)
- ✅ `src/client/**` has no imports from `src/server/**` (client isolation)
- ✅ `esbuild.js` preserves dual-entry-point config (extension + server)
- ✅ `src/shared/constants.ts` has correct port/paths (53221, /mcp, /ws)
- ✅ Protocol messages have matching handlers in both `McpServer.ts` and `ServerConnection.ts`

**Run individually:**
```bash
./.claude/hooks/pre-commit-clauderules-check.sh
```

### `pre-commit-i18n-check.sh`

Ensures bilingual text coverage (English + Chinese Simplified):

- ✅ All keys in `l10n/bundle.l10n.json` have matching entries in `l10n/bundle.l10n.zh-cn.json`
- ✅ All keys in `package.nls.json` have matching entries in `package.nls.zh-cn.json`

**Run individually:**
```bash
./.claude/hooks/pre-commit-i18n-check.sh
```

### `pre-commit-protocol-check.sh`

Validates that every protocol message type (in `src/shared/protocol.ts`) has handler switch cases in both:
- `src/server/McpServer.ts` → `handleMessage()`
- `src/client/ServerConnection.ts` → `handleMessage()`

**Run individually:**
```bash
./.claude/hooks/pre-commit-protocol-check.sh
```

### `pre-commit-test-check.sh`

Ensures new tools and protocol messages have corresponding test definitions:

- ✅ New tools in `src/client/tools/` have test data in `src/test/testData/mcp/`
- ✅ New protocol messages have test cases in `src/test/unit/protocol.test.ts`
- ✅ Changes to `TaskManager` / `ClientRegistry` have unit tests

**Run individually:**
```bash
./.claude/hooks/pre-commit-test-check.sh
```

### `pre-commit-audit-critical-check.sh`

Fails the commit when unresolved `TODO(audit:*:critical)` markers remain in
source files. These markers are inserted by the `code-quality-auditor`
sub-agent (`.claude/agents/code-quality-auditor.md`) and removed by the
`code-quality-remediator` sub-agent (`.claude/agents/code-quality-remediator.md`)
once the finding is addressed.

- ✅ No `TODO(audit:<CATEGORY>:critical)` comments left in `src/**`
- ℹ️ Lower severities (`high` / `medium` / `low`) are informational and do not
  block commits

**Run individually:**
```bash
./.claude/hooks/pre-commit-audit-critical-check.sh
```

## How Claude Should Use These

1. **Before making a commit**, Claude runs `./.claude/hooks/run-all-checks.sh` to validate the work.
2. **If a hook fails**, Claude fixes the cause (does NOT edit the hook to pass).
3. **The hooks are read-only**; they document what is checked, not what to bypass.

## Failed Checks? Here's What to Do

| Check Fails | Root Cause | Fix |
|-------------|-----------|-----|
| `.clauderules` → vscode import in `src/server/` | Server code imports VSCode APIs | Move LSP calls to `src/client/tools/` |
| `.clauderules` → server import in `src/client/` | Client imports from server | Move shared code to `src/shared/` |
| `.clauderules` → esbuild missing entry | Build config edited incorrectly | Restore dual entry points per `esbuild.js` template |
| `i18n` → missing key in Chinese file | Incomplete localization | Add matching key to `l10n/bundle.l10n.zh-cn.json` |
| `protocol` → missing handler | New message type not implemented | Add case to both `McpServer.ts` and `ServerConnection.ts` |
| `test` → no test data | New tool/message without tests | Create test files in `src/test/testData/mcp/` |
| `audit-critical` → unresolved critical marker | Auditor flagged a critical issue still unfixed | Invoke `code-quality-remediator`, or fix and remove the `TODO(audit:*)` block |

## Architecture Enforced by Hooks

```
┌─────────────────────────────────────────────────────────────┐
│ .clauderules (definitive guardrails)                        │
├─────────────────────────────────────────────────────────────┤
│ src/server/** (pure Node.js, no vscode)                     │
│   ↔ WebSocket ↔                                             │
│ src/client/** (VSCode extension, owns LSP execution)        │
│                                                             │
│ Shared: src/shared/** (protocol, constants, types)          │
└─────────────────────────────────────────────────────────────┘
```

Every hook enforces a different layer of this separation.

