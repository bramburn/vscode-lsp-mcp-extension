# Quick Start — Claude Guardrails

TL;DR for developers using Claude on this project.

## Pre-Commit Checklist

Before `git push`:

```bash
# Step 1: Run all validation hooks
./.claude/hooks/run-all-checks.sh

# Step 2: TypeScript + Lint
pnpm run check-types && pnpm run lint

# Step 3: Tests (if you changed code)
pnpm test-unit          # changed server/client
pnpm test-mcp           # changed tools
pnpm test               # changed extension

# Step 4: Push
git push
```

## Adding a New Tool

1. Define schema in `src/server/MCPTools.ts`
2. Create `src/client/tools/MyNameTool.ts` extending `BaseTool`
3. Register in `src/client/TaskExecutor.ts#registerTools()`
4. Add test data in `src/test/testData/mcp/myName.json`
5. Run `./.claude/hooks/run-all-checks.sh` ✅

**Template:** See `.claude/rules/claude-dev-patterns.md` §2

## Adding a New Protocol Message

1. Define interface in `src/shared/protocol.ts`
2. Add to `ClientMessage` or `ServerMessage` union
3. Add switch case in `src/server/McpServer.ts#handleMessage()`
4. Add switch case in `src/client/ServerConnection.ts#handleMessage()`
5. Add test in `src/test/unit/protocol.test.ts`
6. Run `./.claude/hooks/run-all-checks.sh` ✅

**Template:** See `.claude/rules/claude-dev-patterns.md` §3

## Adding a New VSCode Command

1. Add to `package.json` `contributes.commands`
2. Add title keys to `package.nls.json` + `package.nls.zh-cn.json`
3. Register in `src/client/commands/index.ts`
4. Use `l10n.t()` for user-facing strings
5. Run `./.claude/hooks/run-all-checks.sh` ✅

**Template:** See `.claude/rules/claude-dev-patterns.md` §1

## Architecture in One Picture

```
┌────────────────────────────────────────────────────┐
│ MCP Client (AI)                                     │
└────────────────────┬─────────────────────────────────┘
                     │ HTTP/SSE
                     ▼
┌────────────────────────────────────────────────────┐
│ MCP Server (Node.js)  port 53221                   │
│ - ClientRegistry (finds window by projectPath)     │
│ - TaskManager (dispatches via WebSocket)           │
│ - MCPTools (defines all tool schemas)              │
└────────────────┬────────────────────────────────────┘
                 │ WebSocket (/ws)
       ┌─────────┴──────────┬──────────────┐
       ▼                    ▼              ▼
  ┌─────────┐          ┌─────────┐    ┌─────────┐
  │ Window 1│          │ Window 2│    │ Window 3│
  │ ExtHost │          │ ExtHost │    │ ExtHost │
  │ (VSCode)│          │(VSCode) │    │(VSCode) │
  └────┬────┘          └────┬────┘    └────┬────┘
       │                    │              │
       ▼ TaskExecutor       ▼ TaskExecutor ▼ TaskExecutor
  ┌─────────┐          ┌─────────┐    ┌─────────┐
  │ Tools   │          │ Tools   │    │ Tools   │
  │(BaseTool)          │(BaseTool)    │(BaseTool)
  └────┬────┘          └────┬────┘    └────┬────┘
       │                    │              │
       ▼ vscode LSP         ▼ vscode LSP   ▼ vscode LSP
```

## Guardrails (Never Break These)

| Rule | Why | Check |
|------|-----|-------|
| `src/server/**` has no `import "vscode"` | Server is pure Node.js | `pre-commit-clauderules-check.sh` |
| `src/client/**` doesn't import `src/server/**` | No circular deps | `pre-commit-clauderules-check.sh` |
| Every tool has `projectPath` arg | Smart routing | Manual code review |
| esbuild has dual entries (extension + server) | Build integrity | `pre-commit-clauderules-check.sh` |
| Protocol messages have handlers in both McpServer + ServerConnection | Request flow | `pre-commit-protocol-check.sh` |
| All user-facing text in both l10n files (EN + ZH) | i18n coverage | `pre-commit-i18n-check.sh` |
| New tools/protocol have tests | Quality | `pre-commit-test-check.sh` |

## Files You Need to Know

| File | Purpose |
|------|---------|
| `.clauderules` | Authoritative guardrails |
| `.claude/rules/claude-dev-patterns.md` | Detailed patterns (tool/command/protocol) |
| `.claude/rules/testing-strategy.md` | How to test |
| `.claude/rules/i18n.md` | Localization rules |
| `src/server/MCPTools.ts` | Tool schemas |
| `src/client/tools/BaseTool.ts` | Tool base class |
| `src/client/TaskExecutor.ts` | Tool registration |
| `src/shared/protocol.ts` | Message types |
| `src/server/ClientRegistry.ts` | Smart routing |
| `src/server/TaskManager.ts` | Task dispatch |

## Help! Hook Failed

See `.claude/hooks/README.md` → "Failed Checks? Here's What to Do" table.

## Questions?

- **Architecture**: `doc/ARCHITECTURE.md` + `doc/architecture/*.md`
- **Patterns**: `.claude/rules/claude-dev-patterns.md`
- **Tests**: `.claude/rules/testing-strategy.md`
- **i18n**: `.claude/rules/i18n.md`
- **This file**: `.claude/QUICK-START.md`

