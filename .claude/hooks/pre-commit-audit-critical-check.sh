#!/bin/bash
#
# pre-commit-audit-critical-check.sh
# Fails the commit if any `TODO(audit:*:critical)` markers remain in tracked source files.
#
# Markers are inserted by the `code-quality-auditor` Claude sub-agent
# (see .claude/agents/code-quality-auditor.md) and removed by the
# `code-quality-remediator` sub-agent once the finding is resolved.
#
# Pattern matched:
#   // TODO(audit:<CATEGORY>:critical): ...
#
# Search scope: src/**/*.{ts,tsx,js,mjs,cjs}
# Skips: node_modules, dist, out, .vscode-test, *.d.ts
#
# Exit codes:
#   0 — no critical audit markers found
#   1 — one or more critical markers found (printed with file:line)
#

set -e

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

echo "[audit-critical] Scanning for unresolved critical audit markers..."

# EN: Regex matches TODO(audit:<anything-without-colon>:critical)
# CN: 正则匹配 TODO(audit:<非冒号>:critical)
PATTERN='TODO\(audit:[^:]+:critical\)'

# Collect matches across source files only.
MATCHES=$(grep -rEn "$PATTERN" src/ \
    --include='*.ts' \
    --include='*.tsx' \
    --include='*.js' \
    --include='*.mjs' \
    --include='*.cjs' \
    --exclude='*.d.ts' \
    2>/dev/null || true)

if [ -z "$MATCHES" ]; then
    echo "✅ No critical audit markers found."
    exit 0
fi

COUNT=$(echo "$MATCHES" | wc -l | tr -d ' ')

echo ""
echo "❌ Found $COUNT unresolved critical audit marker(s):"
echo ""
echo "$MATCHES"
echo ""
echo "Resolution options:"
echo "  1. Fix the issue and remove the TODO(audit:*) block."
echo "  2. Invoke the 'code-quality-remediator' Claude sub-agent to batch-fix."
echo "  3. Downgrade severity (critical → high|medium|low) only if justified."
echo ""
echo "See .claude/agents/code-quality-auditor.md for marker format."
exit 1

