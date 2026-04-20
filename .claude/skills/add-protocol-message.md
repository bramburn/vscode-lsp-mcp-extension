# Skill: Add Protocol Message

**When to use:** User requests new inter-process communication (window ↔ server messages).

## Workflow

### 1. Define Message Interface (src/shared/protocol.ts)

Add new interface:

```typescript
/** Message description // CN: 消息描述 */
export interface NewMessageType {
  type: "newMessageType";
  // Add required + optional fields
  requestId?: string;
  data: unknown;
  // ...
}
```

**Rules:**
- Always include a unique `type` string literal (matches the interface name in camelCase)
- Include `requestId` if this is request-response (async)
- Use `unknown` for dynamic payloads, specific types for structured data
- Bilingual comment with `// EN:` / `// CN:` format

### 2. Add to Union Type

Determine if message flows **window → server** or **server → window**:

**Window → Server:** Add to `ClientMessage` union:
```typescript
export type ClientMessage =
  | RegisterMessage
  | ResultMessage
  | ErrorMessage
  | RestartMessage
  | NewMessageType;  // Add here
```

**Server → Window:** Add to `ServerMessage` union:
```typescript
export type ServerMessage =
  | RegisteredMessage
  | TaskMessage
  | NewMessageType;  // Add here
```

### 3. Add Handler in Server (src/server/McpServer.ts)

In `handleMessage()` method, add case:

```typescript
private async handleMessage(data: string): Promise<void> {
  try {
    const msg = JSON.parse(data) as ClientMessage;
    switch (msg.type) {
      // ... existing cases
      case "newMessageType":
        // EN: Handle message // CN: 处理消息
        this.handleNewMessage(msg as NewMessageType);
        break;
    }
  } catch (err) {
    console.error("[Connection] Failed to handle message:", err);
  }
}

private handleNewMessage(msg: NewMessageType): void {
  // Implementation
}
```

**Rules:**
- Cast `msg` to the specific type for safety
- Use `[Connection]` log prefix
- Never throw; catch and log errors

### 4. Add Handler in Client (src/client/ServerConnection.ts)

In `handleMessage()` method, add case:

```typescript
private async handleMessage(data: string): Promise<void> {
  try {
    const msg = JSON.parse(data) as ServerMessage;
    switch (msg.type) {
      // ... existing cases
      case "newMessageType":
        // EN: Handle message // CN: 处理消息
        this.handleNewMessage(msg as NewMessageType);
        break;
    }
  } catch (err) {
    console.error("[Connection] Failed to handle message:", err);
  }
}

private handleNewMessage(msg: NewMessageType): void {
  // Implementation
}
```

**Rules:**
- Match the server-side interface exactly
- Use `[Connection]` log prefix for consistency
- Use callbacks/events (see `onTaskCallback`) for async responses

### 5. Add Unit Test (src/test/unit/protocol.test.ts)

```typescript
test("NewMessageType", () => {
  const msg: NewMessageType = {
    type: "newMessageType",
    requestId: "test-123",
    data: { /* test data */ },
  };
  // Assert serialization + union type compatibility
  const serialized = JSON.stringify(msg);
  const deserialized = JSON.parse(serialized);
  assert.equal(deserialized.type, "newMessageType");
});
```

### 6. Validate

```bash
./.claude/hooks/run-all-checks.sh  # Checks for handler symmetry
pnpm run check-types && pnpm lint
pnpm test-unit
```

## Protocol Message Patterns

### Request-Response (async)

Use if window sends request → server → response:

```typescript
// Client → Server
export interface MyRequestMessage {
  type: "myRequest";
  requestId: string;
  args: Record<string, unknown>;
}

// Server → Client (response)
export interface MyResponseMessage {
  type: "myResponse";
  requestId: string;
  result: unknown;
}
```

### One-Way (no response)

Use if server broadcasts to all windows:

```typescript
export interface MyNotificationMessage {
  type: "myNotification";
  data: unknown;
}
```

## Checklist

- [ ] Define interface in `src/shared/protocol.ts` with unique `type` field
- [ ] Add to appropriate union (`ClientMessage` or `ServerMessage`)
- [ ] Add switch case in `src/server/McpServer.ts#handleMessage()`
- [ ] Add switch case in `src/client/ServerConnection.ts#handleMessage()`
- [ ] Test in `src/test/unit/protocol.test.ts`
- [ ] `run-all-checks.sh` passes (will validate handler symmetry)
- [ ] `pnpm test-unit` passes

## References

- `.claude/rules/claude-dev-patterns.md` §3 — detailed protocol pattern
- `src/shared/protocol.ts` — current messages (RegisterMessage, TaskMessage, etc.)
- `src/server/McpServer.ts` — server message handler example
- `src/client/ServerConnection.ts` — client message handler example
- `src/test/unit/protocol.test.ts` — protocol tests

