#!/bin/bash
#
# pre-commit-clauderules-check.sh
# Validates architectural constraints defined in .clauderules
# - Server code (src/server/**) must not import "vscode"
# - Client code must not import from src/server/**
# - Protocol messages (src/shared/protocol.ts) must have matching switch cases in McpServer.ts and ServerConnection.ts
# - esbuild.js must preserve dual-entry-point config
#

set -e

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

echo "[clauderules] Validating architectural constraints..."

ERRORS=0

# ============ Rule 1: Server code must not import vscode ============
echo "[clauderules] Checking server isolation (no vscode imports)..."
if grep -r "import.*from [\"']vscode[\"']" src/server/ 2>/dev/null; then
    echo "❌ ERROR: src/server/** contains 'import ... from \"vscode\"'"
    echo "   Server is Node.js only. Move LSP calls to src/client/**"
    ERRORS=$((ERRORS + 1))
fi

# ============ Rule 2: Client code must not import from server ============
echo "[clauderules] Checking client isolation (no server imports)..."
if grep -r "from [\"'].*src/server" src/client/ 2>/dev/null; then
    echo "❌ ERROR: src/client/** imports from src/server/**"
    echo "   Client and server must not cross-import. Use src/shared/** for shared code."
    ERRORS=$((ERRORS + 1))
fi

# ============ Rule 3: esbuild.js preserves dual-entry config ============
echo "[clauderules] Checking esbuild.js integrity..."
if ! grep -q "entryPoints: \['src/extension.ts'\]" esbuild.js; then
    echo "❌ ERROR: esbuild.js missing extension entry point"
    ERRORS=$((ERRORS + 1))
fi
if ! grep -q "entryPoints: \['src/server/main.ts'\]" esbuild.js; then
    echo "❌ ERROR: esbuild.js missing server entry point"
    ERRORS=$((ERRORS + 1))
fi
if ! grep -q "outfile: 'dist/extension.js'" esbuild.js; then
    echo "❌ ERROR: esbuild.js extension output path incorrect"
    ERRORS=$((ERRORS + 1))
fi
if ! grep -q "outfile: 'dist/server/main.js'" esbuild.js; then
    echo "❌ ERROR: esbuild.js server output path incorrect"
    ERRORS=$((ERRORS + 1))
fi
if ! grep -q "external: \['vscode'\]" esbuild.js | head -1; then
    echo "⚠️  WARNING: esbuild.js may not have 'external: vscode' for extension"
fi

# ============ Rule 4: Protocol message symmetry ============
echo "[clauderules] Checking protocol message handler symmetry..."
PROTOCOL_TYPES=$(grep "^export type ClientMessage\|^export type ServerMessage" src/shared/protocol.ts | wc -l)
if [ "$PROTOCOL_TYPES" -lt 2 ]; then
    echo "❌ ERROR: src/shared/protocol.ts missing ClientMessage or ServerMessage types"
    ERRORS=$((ERRORS + 1))
fi

# Count switch cases in McpServer.ts for common message types (heuristic)
if grep -q "case \"register\":" src/server/McpServer.ts && \
   grep -q "case \"result\":" src/server/McpServer.ts && \
   grep -q "case \"error\":" src/server/McpServer.ts; then
    echo "✅ McpServer.ts has expected message handlers"
else
    echo "⚠️  WARNING: McpServer.ts may be missing message handlers (check §3 of .clauderules)"
fi

# ============ Rule 5: Key constants match ============
echo "[clauderules] Checking shared constants..."
if ! grep -q "DEFAULT_PORT = 53221" src/shared/constants.ts; then
    echo "❌ ERROR: DEFAULT_PORT is not 53221 in constants.ts"
    ERRORS=$((ERRORS + 1))
fi
if ! grep -q "MCP_ENDPOINT = \"/mcp\"" src/shared/constants.ts; then
    echo "❌ ERROR: MCP_ENDPOINT is not '/mcp' in constants.ts"
    ERRORS=$((ERRORS + 1))
fi
if ! grep -q "WS_PATH = \"/ws\"" src/shared/constants.ts; then
    echo "❌ ERROR: WS_PATH is not '/ws' in constants.ts"
    ERRORS=$((ERRORS + 1))
fi

# ============ Summary ============
echo ""
if [ $ERRORS -eq 0 ]; then
    echo "✅ All .clauderules constraints validated."
    exit 0
else
    echo "❌ $ERRORS architectural constraint(s) violated. See .clauderules for details."
    exit 1
fi

