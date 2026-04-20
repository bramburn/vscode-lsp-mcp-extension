# Claude Skills — vscode-lsp-mcp-extension

Actionable workflows for common development tasks. Each skill provides a complete step-by-step guide.

## Available Skills

### 🔧 [add-mcp-tool.md](./add-mcp-tool.md)

**Use when:** Adding a new MCP tool (LSP capability for AI clients).

**Covers:**
- Define schema in `src/server/MCPTools.ts`
- Create tool class in `src/client/tools/`
- Register in `src/client/TaskExecutor.ts`
- Add unit + integration tests
- i18n strings for user-facing text
- Full validation & testing checklist

**Example tasks:**
- "Add a tool to find all implementations of a symbol"
- "Add a refactoring preview tool"
- "Expose VSCode's goto-type-definition as an MCP tool"

---

### 📡 [add-protocol-message.md](./add-protocol-message.md)

**Use when:** Adding new inter-process communication (window ↔ server messages).

**Covers:**
- Define message interface in `src/shared/protocol.ts`
- Add to `ClientMessage` or `ServerMessage` union
- Implement handler in `src/server/McpServer.ts`
- Implement handler in `src/client/ServerConnection.ts`
- Request-response vs. one-way patterns
- Unit test in `src/test/unit/protocol.test.ts`

**Example tasks:**
- "Add progress update messages for long-running tools"
- "Add heartbeat/keepalive messages between server and windows"
- "Add debug logging channel messages"

---

### 🎮 [add-vscode-command.md](./add-vscode-command.md)

**Use when:** Adding a new VSCode command (button, menu action, palette command).

**Covers:**
- Define command in `package.json`
- Add i18n keys to `package.nls.json` + `package.nls.zh-cn.json`
- Register implementation in `src/client/commands/index.ts`
- Add runtime i18n strings to `l10n/bundle.l10n.json`
- Use `l10n.t()` for all user-facing text
- Menu integration (optional)
- Unit test in `src/test/extension.test.ts`

**Example tasks:**
- "Add a 'Show Debug Panel' command"
- "Add a 'Export MCP Tool Results' command"
- "Add status bar items with commands"

---

### ✅ [write-tool-tests.md](./write-tool-tests.md)

**Use when:** Writing tests for an MCP tool (test data + expected outputs).

**Covers:**
- Create test input JSON in `src/test/testData/mcp/`
- Create expected output MD files
- Register test in `src/test/integration/mcp.test.ts`
- Run MCP server + tests
- Edge cases (empty results, errors, pagination)
- Test data placeholders (`${projectPath}`)

**Example tasks:**
- "Add test cases for the new 'findImplementations' tool"
- "Test pagination on a tool with 100+ results"
- "Test error handling for invalid positions"

---

## Related Sub-Agents

Sub-agents live in `.claude/agents/` and are invoked automatically based on
their `description` frontmatter, or by name.

### 🔍 [code-quality-auditor](../agents/code-quality-auditor.md)

**Use when:** Performing a comprehensive, graph-aware code quality audit.

**Covers:**
- BFS over the application call graph via IDE-LSP MCP (`getFileStruct`,
  `getSymbolStruct`, `findReferences`, `incomingCalls`, `goToImplementation`,
  `getDiagnostics`, …)
- Inserts categorized `TODO(audit:<CATEGORY>:<SEVERITY>)` markers with
  stable `CQ-####` IDs
- Optional Context7 MCP usage for external API verification
- Produces a severity-ranked Markdown summary report

**Example tasks:**
- "Audit the whole extension for bugs and smells"
- "Run a code quality review of `src/server/**`"
- "Flag architectural violations against `.clauderules`"

### 🛠 [code-quality-remediator](../agents/code-quality-remediator.md)

**Use when:** Turning `TODO(audit:*)` markers from the auditor into minimal,
reviewable patches.

**Covers:**
- Enumerates findings via `grep -rn "TODO(audit:" src/`
- Batches by severity and category; resolves highest-priority first
- Verifies blast radius with `findReferences` / `incomingCalls` before editing
- Preserves i18n parity and `.clauderules` architectural boundaries
- Emits resolved / deferred / proposal report per batch

**Example tasks:**
- "Fix all `CQ-*` critical findings"
- "Apply the high-severity BUG and API fixes"
- "Remediate the audit but defer any signature changes"

---

## Workflow Integration

### For New Features

1. **Identify the type:** Tool? Command? Message?
2. **Select skill:** Use the table above
3. **Follow steps:** Complete each numbered step
4. **Run validation:** Execute the skill's validation commands
5. **Commit:** Code passes all checks

### Before Committing

```bash
# Always run the master check
./.claude/hooks/run-all-checks.sh

# Then build, lint, test
pnpm run check-types && pnpm run lint
pnpm test-unit && pnpm test-mcp && pnpm test
```

## Quick Decision Tree

```
What are you doing?
│
├─→ A new LSP capability (e.g., find references, go to definition)
│   └─→ Use: add-mcp-tool.md
│
├─→ A new command/button/menu item
│   └─→ Use: add-vscode-command.md
│
├─→ New window ↔ server communication
│   └─→ Use: add-protocol-message.md
│
├─→ Tests for a tool
│   └─→ Use: write-tool-tests.md
│
├─→ Audit the codebase for quality issues
│   └─→ Delegate to: code-quality-auditor (sub-agent)
│
└─→ Fix findings left behind by the auditor
    └─→ Delegate to: code-quality-remediator (sub-agent)
```

## Related Documentation

| Document | Purpose |
|----------|---------|
| `.clauderules` | Architectural constraints (read first) |
| `.claude/rules/claude-dev-patterns.md` | Detailed patterns (reference) |
| `.claude/rules/testing-strategy.md` | Full testing guide |
| `.claude/rules/i18n.md` | Localization rules |
| `.claude/QUICK-START.md` | Developer quick reference |
| `.claude/hooks/README.md` | Hook validation & troubleshooting |

## Skill Template Structure

Each skill follows this structure:

1. **Workflow** — Step-by-step numbered steps
2. **Rules** — Critical constraints (never violate)
3. **Patterns** — Common variations (request-response vs. one-way, etc.)
4. **Checklist** — All-or-nothing validation
5. **References** — Links to detailed rules + examples
6. **Troubleshooting** — Common failure modes

Use the **checklist** before moving on to validation.

## Asking Claude for Help

When requesting a feature, be specific:

✅ **Good:** "Add an MCP tool to get the type definition of a symbol"
- Claude loads `.claude/skills/add-mcp-tool.md`
- Follows all steps + checklist

❌ **Vague:** "Add a new tool"
- Claude may skip steps or miss i18n/tests

## Feedback

If a skill is incomplete or confusing:
- Open an issue with which skill + step number
- Include error messages from `run-all-checks.sh`
- Skills are maintained at `.claude/skills/*.md`

