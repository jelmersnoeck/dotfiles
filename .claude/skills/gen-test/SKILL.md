---
name: gen-test
description: Generate unit tests (Vitest) or E2E tests (Playwright) for this project. Usage - /gen-test <file-or-feature>
disable-model-invocation: true
---

# Generate Tests

Generate tests for the Threshold Coaching codebase.

## Arguments

- A file path (e.g., `lib/preconfigure.ts`) — generates unit tests for that file
- A feature name (e.g., `auth`, `analysis`, `step-entry`) — generates E2E tests for that feature

## Conventions

### Unit Tests (Vitest)

- Place test files next to the source: `lib/preconfigure.test.ts`
- Use `describe` / `it` blocks with clear test names
- Import from `vitest`: `import { describe, it, expect } from "vitest"`
- Import Zod v4 as `zod/v4`
- For Prisma-dependent code, mock `lib/prisma.ts`
- For Anthropic SDK, mock `@anthropic-ai/sdk`

Example structure:
```typescript
import { describe, it, expect } from "vitest"
import { preconfigureSteps, formatPace, parsePace } from "./preconfigure"

describe("preconfigureSteps", () => {
  it("generates correct number of steps", () => {
    const steps = preconfigureSteps("CYCLING", 100, 20, 5)
    expect(steps).toHaveLength(5)
  })

  it("rounds cycling intensity to whole watts", () => {
    const steps = preconfigureSteps("CYCLING", 100.7, 20.3, 3)
    steps.forEach(s => expect(Number.isInteger(s.intensity)).toBe(true))
  })

  it("rounds running intensity to 1 decimal", () => {
    const steps = preconfigureSteps("RUNNING", 10.0, 0.5, 3)
    steps.forEach(s => {
      const decimals = s.intensity.toString().split(".")[1]?.length ?? 0
      expect(decimals).toBeLessThanOrEqual(1)
    })
  })
})
```

### E2E Tests (Playwright)

- Place in `e2e/` directory at project root
- Use page object pattern for reusable selectors
- Test authenticated flows by seeding a test user + session cookie
- Base URL: `http://localhost:3000`

### Setup

If Vitest or Playwright is not yet installed, install it first:

```bash
# Vitest
npm install -D vitest

# Playwright
npm install -D @playwright/test
npx playwright install
```

Create `vitest.config.ts` if missing:
```typescript
import { defineConfig } from "vitest/config"
import path from "path"

export default defineConfig({
  test: {
    globals: true,
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "."),
    },
  },
})
```

## Behavior

1. Read the target file/feature to understand what to test
2. Identify edge cases and important behaviors
3. Generate the test file
4. Run the tests to verify they pass
5. Report results
