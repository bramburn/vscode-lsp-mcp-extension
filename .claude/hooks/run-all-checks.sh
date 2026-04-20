#!/bin/bash
#
# run-all-checks.sh
# Run all pre-commit checks before pushing to remote.
# Usage: ./.claude/hooks/run-all-checks.sh
#
# This script runs:
# 1. pre-commit-clauderules-check.sh — architectural constraints
# 2. pre-commit-i18n-check.sh — bilingual text coverage
# 3. pre-commit-protocol-check.sh — protocol message symmetry
# 4. pre-commit-test-check.sh — test coverage for new tools/protocol
# 5. pre-commit-audit-critical-check.sh — unresolved critical audit markers
#

set -e

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

HOOK_DIR=".claude/hooks"
FAILED=0

echo "=================================="
echo "Running all pre-commit checks..."
echo "=================================="
echo ""

# Run clauderules check
echo "▶️  Running .clauderules validation..."
if "$HOOK_DIR/pre-commit-clauderules-check.sh"; then
    echo "✅ .clauderules check passed"
else
    echo "❌ .clauderules check failed"
    FAILED=$((FAILED + 1))
fi
echo ""

# Run i18n check
echo "▶️  Running i18n check..."
if "$HOOK_DIR/pre-commit-i18n-check.sh"; then
    echo "✅ i18n check passed"
else
    echo "❌ i18n check failed"
    FAILED=$((FAILED + 1))
fi
echo ""

# Run protocol check
echo "▶️  Running protocol check..."
if "$HOOK_DIR/pre-commit-protocol-check.sh"; then
    echo "✅ protocol check passed"
else
    echo "❌ protocol check failed"
    FAILED=$((FAILED + 1))
fi
echo ""

# Run test check
echo "▶️  Running test coverage check..."
if "$HOOK_DIR/pre-commit-test-check.sh"; then
    echo "✅ test check passed"
else
    echo "❌ test check failed"
    FAILED=$((FAILED + 1))
fi
echo ""

# Run audit critical marker check
echo "▶️  Running audit critical marker check..."
if "$HOOK_DIR/pre-commit-audit-critical-check.sh"; then
    echo "✅ audit critical check passed"
else
    echo "❌ audit critical check failed"
    FAILED=$((FAILED + 1))
fi
echo ""

# Summary
echo "=================================="
if [ $FAILED -eq 0 ]; then
    echo "✅ All pre-commit checks passed!"
    echo "=================================="
    echo ""
    echo "Next steps:"
    echo "  1. pnpm run check-types"
    echo "  2. pnpm run lint"
    echo "  3. pnpm test-unit (if changed server/client code)"
    echo "  4. pnpm test-mcp (if changed tools)"
    echo "  5. git push"
    exit 0
else
    echo "❌ $FAILED check(s) failed. Fix errors above before committing."
    echo "=================================="
    exit 1
fi

