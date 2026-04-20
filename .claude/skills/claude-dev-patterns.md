# Skill: claude-dev-patterns

Quick reference for common development tasks on vscode-lsp-mcp-extension.

## Skills (Detailed Workflows)

Each skill provides a complete, step-by-step workflow for a specific task:

| Task | Skill | Use When |
|------|-------|----------|
| **Add MCP Tool** | `.claude/skills/add-mcp-tool.md` | New LSP capability (find definitions, references, etc.) |
| **Add Protocol Message** | `.claude/skills/add-protocol-message.md` | New inter-process communication (window ↔ server) |
| **Add VSCode Command** | `.claude/skills/add-vscode-command.md` | New button/menu/palette action |
| **Write Tool Tests** | `.claude/skills/write-tool-tests.md` | Test data + expected outputs for tools |

## Quick Reference

### Add MCP Tool (3 core files)
1. Schema in `src/server/MCPTools.ts`
2. Tool class in `src/client/tools/ToolNameTool.ts` extending `BaseTool`
3. Register in `src/client/TaskExecutor.ts`

**See:** `.claude/skills/add-mcp-tool.md`

### Add Protocol Message (3 core files)
1. Interface in `src/shared/protocol.ts`, add to union
2. Handler in `src/server/McpServer.ts#handleMessage()`
3. Handler in `src/client/ServerConnection.ts#handleMessage()`

**See:** `.claude/skills/add-protocol-message.md`

### Add VSCode Command (3 core files)
1. Definition in `package.json` + i18n keys
2. Registration in `src/client/commands/index.ts`
3. i18n strings in both `l10n/bundle.l10n*.json`

**See:** `.claude/skills/add-vscode-command.md`

### Write Tool Tests (2 core files)
1. Test data in `src/test/testData/mcp/{toolName}.json`
2. Expected outputs in `src/test/testData/mcp/expected/{toolName}/`
3. Register in `src/test/integration/mcp.test.ts`

**See:** `.claude/skills/write-tool-tests.md`