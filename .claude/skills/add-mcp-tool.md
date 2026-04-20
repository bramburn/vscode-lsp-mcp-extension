# Skill: Add MCP Tool

**When to use:** User requests a new MCP tool (new LSP capability for AI clients).

## Workflow

### 1. Define Tool Schema (src/server/MCPTools.ts)

Add entry to `TOOL_SCHEMAS`:

```typescript
toolName: {
  description: "What this tool does for the MCP client",
  inputSchema: z.object({
    projectPath: z.string().describe("Project root path (absolute)"),
    filePath: z.string().describe("File path (absolute or relative to project)"),
    line: z.number().describe("Line number (1-based)"),
    character: z.number().describe("Column offset (0-based)"),
    // Add any tool-specific args here
  }),
},
```

**Rules:**
- ALWAYS include `projectPath` (required for smart routing)
- Use 1-based line numbers, 0-based character offsets
- Use shared zod primitives when possible (see existing tools)
- Write clear, actionable descriptions for AI clients

### 2. Create Tool Class (src/client/tools/ToolNameTool.ts)

```typescript
import * as vscode from "vscode";
import { BaseTool } from "./BaseTool";
import { StringBuilder } from "../utils/StringBuilder";

interface ToolResult {
  // EN: Tool-specific result type // CN: 工具特定的结果类型
}

/**
 * ToolNameTool - Brief description
 * // CN: 工具描述
 */
export class ToolNameTool extends BaseTool {
  readonly name = "toolName";

  async execute(args: Record<string, unknown>): Promise<ToolResult> {
    // EN: Implementation // CN: 实现
    const uri = this.resolveUri(
      args.projectPath as string,
      args.filePath as string,
    );
    const position = new vscode.Position(
      (args.line as number) - 1,
      args.character as number,
    );
    // ... tool logic using vscode LSP commands
    return { /* result */ };
  }

  format(result: ToolResult, _args: Record<string, unknown>): string {
    if (/* no results */) {
      return this.emptyContent("No content available");
    }
    const sb = new StringBuilder();
    // EN: Format output as Markdown // CN: 格式化为 Markdown 输出
    if (/* paginated results */) {
      return PaginationHelper.wrapPaginated(
        "Tool Title",
        page,
        totalPages,
        totalItems,
        hasMore,
        (sb) => { /* append results */ }
      );
    }
    return sb.toString();
  }
}
```

**Rules:**
- Use `this.resolveUri()` to convert paths
- Convert `line - 1` for VSCode Position
- Return a typed result object (never throw)
- Use `PaginationHelper` for lists; never implement ad-hoc pagination
- Bilingual comments with `// EN:` / `// CN:` format

### 3. Register Tool (src/client/TaskExecutor.ts)

```typescript
import { ToolNameTool } from "./tools/ToolNameTool";

private registerTools(): void {
  this.registry.registerAll([
    // ... existing tools
    new ToolNameTool(),
  ]);
}
```

### 4. Export from tools/index.ts

```typescript
export { ToolNameTool } from "./ToolNameTool";
```

### 5. Add i18n Strings (if needed)

Add to `l10n/bundle.l10n.json` + `l10n/bundle.l10n.zh-cn.json`:

```json
{
  "tool.toolName.empty": "No results found",
  "tool.toolName.error": "Failed to execute tool"
}
```

### 6. Add Tests

Create `src/test/testData/mcp/toolName.json`:

```json
[
  {
    "name": "test case description",
    "args": {
      "projectPath": "${projectPath}",
      "filePath": "src/file.ts",
      "line": 1,
      "character": 0
    },
    "expectedFile": "testCase.md"
  }
]
```

Create `src/test/testData/mcp/expected/toolName/testCase.md` with expected output.

Register in `src/test/mcp.test.ts`:
```typescript
test("toolName", () => runToolTest(client, "toolName"));
```

### 7. Validate

```bash
./.claude/hooks/run-all-checks.sh
pnpm test-unit && pnpm test-mcp
```

## Checklist

- [ ] Schema in `src/server/MCPTools.ts` with `projectPath` + args
- [ ] Tool class in `src/client/tools/ToolNameTool.ts` extending `BaseTool`
- [ ] Exported from `src/client/tools/index.ts`
- [ ] Registered in `src/client/TaskExecutor.ts#registerTools()`
- [ ] Test data in `src/test/testData/mcp/toolName.json`
- [ ] Expected results in `src/test/testData/mcp/expected/toolName/`
- [ ] Registered test in `src/test/mcp.test.ts`
- [ ] i18n strings in both l10n bundles (if user-facing)
- [ ] `run-all-checks.sh` passes
- [ ] `pnpm test-mcp` passes

## References

- `.claude/rules/claude-dev-patterns.md` §2 — detailed tool pattern
- `.claude/rules/testing-strategy.md` — test commands & McpTestClient
- `src/client/tools/FindReferencesTool.ts` — example with pagination
- `src/client/tools/BaseTool.ts` — base class interface

