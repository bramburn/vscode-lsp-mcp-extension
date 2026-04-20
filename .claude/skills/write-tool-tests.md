# Skill: Write Tool Tests

**When to use:** Adding tests for a new MCP tool or updating existing tool tests.

## Test Architecture

```
src/test/
├── testData/
│   └── mcp/
│       ├── {toolName}.json           # Test input definitions
│       └── expected/
│           └── {toolName}/
│               └── {testCase}.md     # Expected output
└── integration/
    └── mcp.test.ts                   # Test runner
```

## Workflow

### 1. Create Test Data File

**File:** `src/test/testData/mcp/{toolName}.json`

```json
[
  {
    "name": "should find symbol in current file",
    "args": {
      "projectPath": "${projectPath}",
      "filePath": "src/client/tools/MyTool.ts",
      "line": 25,
      "character": 10,
      "symbolName": "mySymbol",
      "page": 1
    },
    "expectedFile": "findSymbol.md"
  },
  {
    "name": "should handle missing symbol",
    "args": {
      "projectPath": "${projectPath}",
      "filePath": "src/client/tools/MyTool.ts",
      "line": 1,
      "character": 0,
      "symbolName": "nonExistent"
    },
    "expectedFile": "missingSymbol.md"
  }
]
```

**Rules:**
- Array of test objects (one per test case)
- Use `${projectPath}` placeholder (replaced at runtime via `TEST_PROJECT_PATH` env var)
- `name` = human-readable test case description
- `args` = exact tool arguments (must match schema in `MCPTools.ts`)
- `expectedFile` = filename under `expected/{toolName}/` (relative path)
- Include edge cases: errors, empty results, pagination

### 2. Create Expected Output Files

**Directory:** `src/test/testData/mcp/expected/{toolName}/`

Create one `.md` file per test case:

**File:** `src/test/testData/mcp/expected/{toolName}/findSymbol.md`

```markdown
## Symbol Search

> Page 1/1 | Total: 2 items

### Location 1
`src/client/tools/OtherTool.ts:15:5`

```
  export class OtherTool extends BaseTool {
    readonly name = "otherTool";
```

### Location 2
`src/client/tools/MyTool.ts:25:10`

```
  readonly name = "myTool";
```
```

**File:** `src/test/testData/mcp/expected/{toolName}/missingSymbol.md`

```markdown
*No content available*

**Suggested positions for this symbol:**
- Line 10:5
- Line 32:0

Did you mean one of these positions?
```

**Rules:**
- Output must be exact Markdown format returned by tool's `format()` method
- Include pagination headers if tool uses pagination
- Include error messages with suggestions if applicable
- Copy actual output from first test run (framework auto-creates files)

### 3. Register Test

**File:** `src/test/integration/mcp.test.ts`

```typescript
test("{toolName}", () => runToolTest(client, "{toolName}"));
```

**Rules:**
- Test name should match the tool name (camelCase)
- Use `runToolTest(client, "{toolName}")` helper
- Framework automatically loads test data + expected files
- Tests run sequentially; timeout is 60000ms

### 4. Run Tests

```bash
# Set test project path (directory containing code to analyze)
export TEST_PROJECT_PATH="/path/to/vscode-lsp-mcp-extension"

# Start MCP server (required, separate terminal)
pnpm run server:dev

# Run MCP integration tests
pnpm test-mcp
```

**Rules:**
- Server MUST be running on port 53221
- `TEST_PROJECT_PATH` must point to an actual project with LSP support
- Tests compare formatted output against expected files
- On first run, expected files are created (review before committing)

## Test Data Tips

### Using Placeholders

```json
{
  "args": {
    "projectPath": "${projectPath}",
    "filePath": "${projectPath}/src/shared/protocol.ts",
    "line": 50,
    "character": 0
  }
}
```

Replaced at runtime: `${projectPath}` → value of `TEST_PROJECT_PATH` env var

### Testing Edge Cases

Add test cases for:

1. **Empty result**
```json
{
  "name": "should handle no matches",
  "args": { /* args that produce no results */ },
  "expectedFile": "noMatches.md"
}
```

2. **Error condition**
```json
{
  "name": "should handle invalid position",
  "args": {
    "line": 999999,  /* Out of bounds */
    "character": 0
  },
  "expectedFile": "invalidPosition.md"
}
```

3. **Pagination (if tool supports)**
```json
{
  "name": "should paginate results",
  "args": { /* args with many results */, "page": 1 },
  "expectedFile": "page1.md"
},
{
  "name": "should show page 2",
  "args": { /* same args but */, "page": 2 },
  "expectedFile": "page2.md"
}
```

## Checklist

- [ ] Create `src/test/testData/mcp/{toolName}.json` with test cases
- [ ] Create expected output files in `src/test/testData/mcp/expected/{toolName}/`
- [ ] Register test in `src/test/integration/mcp.test.ts`
- [ ] `export TEST_PROJECT_PATH=...`
- [ ] Run `pnpm run server:dev` in separate terminal
- [ ] Run `pnpm test-mcp` and verify all cases pass
- [ ] Review expected output files before committing
- [ ] Include edge cases (empty results, errors, pagination)

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Test timeout | Server not running? Check `curl http://127.0.0.1:53221/health` |
| "TEST_PROJECT_PATH not set" | `export TEST_PROJECT_PATH="/your/project/path"` |
| Expected file mismatch | Actual output differs; review & update expected file |
| Tool not found | Check tool is registered in `TaskExecutor.registerTools()` |

## References

- `.claude/rules/testing-strategy.md` — full testing guide
- `src/test/integration/mcp.test.ts` — test runner code
- `src/test/testData/mcp/` — existing test data examples
- `src/test/McpTestClient.ts` — MCP client for testing

