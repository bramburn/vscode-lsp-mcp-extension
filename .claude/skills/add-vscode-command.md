# Skill: Add VSCode Command

**When to use:** User requests a new VSCode command (button, menu, palette action).

## Workflow

### 1. Define Command in package.json

Add to `contributes.commands`:

```json
{
  "command": "ide-lsp-mcp.commandName",
  "title": "%command.commandName%",
  "icon": "$(icon-identifier)",
  "when": "config.ide-lsp-mcp.enableDebug"
}
```

**Rules:**
- Command ID must start with `ide-lsp-mcp.`
- Use i18n key `%command.commandName%` (never hardcode display text)
- `icon` is optional (use VSCode icon IDs, e.g., `$(clear-all)`)
- `when` clause is optional (controls when command appears in palette/menus)

### 2. Add i18n Strings

**package.nls.json (English):**
```json
{
  "command.commandName": "Display Name for Command"
}
```

**package.nls.zh-cn.json (Chinese):**
```json
{
  "command.commandName": "命令的中文显示名称"
}
```

**Rules:**
- Keys must match exactly between EN + ZH files
- Display name should be user-friendly and concise

### 3. Register Command (src/client/commands/index.ts)

```typescript
import { l10n } from "vscode";

export function registerCommands(context: vscode.ExtensionContext): void {
  // EN: Existing commands // CN: 现有命令
  context.subscriptions.push(
    vscode.commands.registerCommand("ide-lsp-mcp.commandName", async (args) => {
      // EN: Command implementation // CN: 命令实现
      try {
        // Call functions, show UI, etc.
        vscode.window.showInformationMessage(
          l10n.t("Command executed successfully")
        );
      } catch (err) {
        vscode.window.showErrorMessage(
          l10n.t("Error: {0}", (err as Error).message)
        );
      }
    }),
  );
}
```

**Rules:**
- Always use `l10n.t()` for user-facing text
- Wrap in try-catch and show user-friendly error messages
- Never throw; always handle errors gracefully
- Use bilingual comments for non-obvious logic

### 4. Add Runtime i18n Strings (if needed)

If command shows messages beyond the display name:

**l10n/bundle.l10n.json (English):**
```json
{
  "command.commandName.success": "Successfully executed command",
  "command.commandName.error": "Failed to execute: {0}"
}
```

**l10n/bundle.l10n.zh-cn.json (Chinese):**
```json
{
  "command.commandName.success": "成功执行命令",
  "command.commandName.error": "执行失败: {0}"
}
```

### 5. Add Unit Test (src/test/extension.test.ts)

```typescript
test("commandName command", async () => {
  const result = await vscode.commands.executeCommand(
    "ide-lsp-mcp.commandName"
  );
  assert.ok(result, "Command should complete");
});
```

### 6. Add Menu Registration (if applicable)

If command should appear in a menu, add to `contributes.menus`:

```json
"menus": {
  "view/title": [
    {
      "command": "ide-lsp-mcp.commandName",
      "when": "view == ideLspMcpDebug",
      "group": "navigation"
    }
  ]
}
```

**Rules:**
- `view/title` = top-right of a view panel
- `editor/context` = right-click in editor
- `commandPalette` = Ctrl+Shift+P
- `group` determines sort order (navigation, 1, 2, etc.)

### 7. Validate

```bash
./.claude/hooks/run-all-checks.sh
pnpm run check-types && pnpm run lint
pnpm test
```

## Common i18n Message Keys

```json
{
  "command.showStatus.title": "Show MCP Status",
  "command.reconnect.title": "Reconnect to MCP Server",
  "command.restartServer.title": "Restart MCP Server",
  "message.success": "Operation succeeded",
  "message.error": "Operation failed: {0}",
  "status.connected": "Connected",
  "status.disconnected": "Disconnected"
}
```

## Checklist

- [ ] Add command definition to `package.json` `contributes.commands`
- [ ] Add title key to `package.nls.json` (English)
- [ ] Add title key to `package.nls.zh-cn.json` (Chinese, same key)
- [ ] Register in `src/client/commands/index.ts`
- [ ] Use `l10n.t()` for all user-facing strings
- [ ] Add any message keys to both `l10n/bundle.l10n.json` files
- [ ] Add unit test to `src/test/extension.test.ts`
- [ ] Add menu registration if command should appear in UI
- [ ] `run-all-checks.sh` passes
- [ ] `pnpm test` passes

## References

- `.claude/rules/claude-dev-patterns.md` §1 — detailed command pattern
- VSCode Docs: [contributes.commands](https://code.visualstudio.com/api/references/contribution-points#contributes.commands)
- VSCode Docs: [When clauses](https://code.visualstudio.com/api/references/when-clause-contexts)
- `src/client/commands/index.ts` — existing command implementations
- `l10n/bundle.l10n.json` — current i18n strings

