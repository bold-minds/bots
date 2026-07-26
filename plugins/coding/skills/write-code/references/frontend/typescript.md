# TypeScript Reference

## Strict Mode

Always enable `strict: true` in tsconfig. Also add additional strictness flags:

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noFallthroughCasesInSwitch": true,
    "forceConsistentCasingInFileNames": true,
    "target": "ES2022",
    "module": "ESNext"
  }
}
```

`strict` enables: `noImplicitAny`, `strictNullChecks`, `strictFunctionTypes`, `strictBindCallApply`, `strictPropertyInitialization`, `noImplicitThis`, `useUnknownInCatchVariables`, `alwaysStrict`.

`noUncheckedIndexedAccess` makes index access return `T | undefined`, forcing missing key handling:

```typescript
const map: Record<string, number> = { a: 1 };
const val = map["b"]; // type is number | undefined, not number
if (val !== undefined) {
  console.log(val * 2); // safe
}
```

## Interface vs Type

Use `interface` for object shapes and public APIs. Use `type` for unions, intersections, mapped types, conditional types.

```typescript
// interface for object shapes
interface User {
  id: string;
  name: string;
  email: string;
}

// type for unions
type Status = "active" | "inactive" | "suspended";

// type for intersections
type AdminUser = User & { permissions: string[] };

// type for mapped types
type Optional<T> = { [K in keyof T]?: T[K] };

// type for conditional types
type ExtractString<T> = T extends string ? T : never;
```

`interface` supports declaration merging and `extends` is cached by the compiler for faster type checking:

```typescript
interface Animal {
  name: string;
}
interface Animal {
  age: number;
}
// Animal now has both name and age

interface Dog extends Animal {
  breed: string;
}
```

`type` supports mapped types, conditional types, template literal types, tuples -- things `interface` cannot:

```typescript
type Tuple = [string, number, boolean];
type EventKey = `on${Capitalize<string>}`;
type IsString<T> = T extends string ? true : false;
```

Never use `interface` to enforce properties on classes -- interfaces cannot have private properties.

## Generics

Use generics when the type relationship between inputs and outputs matters. Not when a simple union suffices.

```typescript
// Good: generic captures relationship between input and output
function first<T>(arr: T[]): T | undefined {
  return arr[0];
}

// Bad: generic not needed, union works fine
function bad<T extends string | number>(x: T): void {} // just use (x: string | number)
```

Use `extends` constraints when the generic must have specific properties:

```typescript
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}
```

Provide default type parameters when reasonable defaults exist. Order: required first, optional (defaulted) last:

```typescript
type ApiResponse<T, E = Error> = {
  data: T | null;
  error: E | null;
};
```

Never have generics that don't use their type parameters. Prefer generics that infer types over requiring explicit type arguments:

```typescript
// Good: T is inferred from the argument
function identity<T>(value: T): T {
  return value;
}
const result = identity("hello"); // T inferred as "hello"

// Avoid: forcing callers to specify types
function create<T>(): T { /* ... */ } // T cannot be inferred
```

## Discriminated Unions

Use a shared literal property (the "discriminant") across all union members:

```typescript
type Shape =
  | { kind: "circle"; radius: number }
  | { kind: "rectangle"; width: number; height: number }
  | { kind: "triangle"; base: number; height: number };

function area(shape: Shape): number {
  switch (shape.kind) {
    case "circle":
      return Math.PI * shape.radius ** 2;
    case "rectangle":
      return shape.width * shape.height;
    case "triangle":
      return (shape.base * shape.height) / 2;
    default:
      const _exhaustiveCheck: never = shape;
      throw new Error(`Unhandled: ${_exhaustiveCheck}`);
  }
}
```

Use a standalone `assertNever` helper for reuse:

```typescript
function assertNever(x: never): never {
  throw new Error(`Unexpected value: ${x}`);
}
```

Adding a new variant without handling it produces a compile-time error.

## Type Narrowing & Guards

Use built-in narrowing (`typeof`, `instanceof`, `in`, equality) before writing custom guards:

```typescript
function process(value: string | number) {
  if (typeof value === "string") {
    return value.toUpperCase(); // narrowed to string
  }
  return value.toFixed(2); // narrowed to number
}

function handle(err: unknown) {
  if (err instanceof Error) {
    console.log(err.message); // narrowed to Error
  }
}
```

Type predicates (`paramName is Type`) for boolean-returning guards:

```typescript
interface Fish {
  swim(): void;
}
interface Bird {
  fly(): void;
}

function isFish(pet: Fish | Bird): pet is Fish {
  return "swim" in pet;
}
```

Assertion functions (`asserts paramName is Type`) for guards that throw on failure:

```typescript
function assertIsString(value: unknown): asserts value is string {
  if (typeof value !== "string") {
    throw new Error(`Expected string, got ${typeof value}`);
  }
}

const input: unknown = getData();
assertIsString(input);
console.log(input.toUpperCase()); // input is now string
```

"Parse, Don't Validate" at system boundaries -- use Zod to parse untyped data into well-typed data once at the boundary, then work with fully-typed data throughout:

```typescript
import { z } from "zod";

const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1),
  email: z.string().email(),
  age: z.number().int().positive(),
});

type User = z.infer<typeof UserSchema>;

// At the API boundary: parse once
function handleRequest(body: unknown): User {
  return UserSchema.parse(body); // throws ZodError if invalid
}
```

## Utility Types

`Partial<T>` for update operations. Never for creation (allows `{}`):

```typescript
interface User {
  name: string;
  email: string;
}

function updateUser(id: string, updates: Partial<User>): void {
  // updates can be { name: "new" } or { email: "new@x.com" } or both
}

// Bad: allows creating empty users
function createUser(data: Partial<User>): User { /* ... */ } // {} is valid!
```

`Pick<T, K>` when needing a few properties. `Omit<T, K>` when removing a few:

```typescript
type UserPreview = Pick<User, "name" | "email">;
type UserWithoutEmail = Omit<User, "email">;
```

`Required<T>` makes all mandatory. `Readonly<T>` prevents mutation:

```typescript
type CompleteConfig = Required<Partial<Config>>;
type FrozenState = Readonly<AppState>;
```

`Record<K, V>` for dictionary/map-like objects:

```typescript
const statusMessages: Record<Status, string> = {
  active: "User is active",
  inactive: "User is inactive",
  suspended: "User is suspended",
};
```

`NonNullable<T>` strips `null | undefined`. `ReturnType<T>` and `Parameters<T>` extract function signatures:

```typescript
type MaybeString = string | null | undefined;
type DefinitelyString = NonNullable<MaybeString>; // string

type FetchReturn = ReturnType<typeof fetch>; // Promise<Response>
type FetchParams = Parameters<typeof fetch>; // [input: RequestInfo | URL, init?: RequestInit]
```

Combine utility types but don't over-nest. Split and name intermediate types:

```typescript
// Bad: deeply nested, hard to read
type Bad = Readonly<Partial<Pick<Omit<User, "id">, "name" | "email">>>;

// Good: named intermediate types
type EditableUserFields = Omit<User, "id">;
type UserDraft = Partial<EditableUserFields>;
type FrozenDraft = Readonly<UserDraft>;
```

Be careful with `Omit` removing required fields silently -- omitting a misspelled key produces no error.

## Enums vs Const Objects vs Unions

Prefer union types as default:

```typescript
type Direction = "north" | "south" | "east" | "west";
```

Use `as const` objects when runtime values are needed:

```typescript
const DIRECTION = {
  North: "north",
  South: "south",
  East: "east",
  West: "west",
} as const;

type Direction = (typeof DIRECTION)[keyof typeof DIRECTION];
// "north" | "south" | "east" | "west"
```

Avoid `enum` in new code -- generates reverse-mapping overhead, was added anticipating a JS standard that never happened:

```typescript
// Avoid: generates extra runtime code
enum Color {
  Red,
  Green,
  Blue,
}

// If enums necessary, prefer string enums over numeric
enum LogLevel {
  Error = "ERROR",
  Warn = "WARN",
  Info = "INFO",
}
```

## unknown vs any vs never

`unknown`: all possible values (top type). Can assign anything to it, must narrow before use:

```typescript
function processInput(input: unknown): string {
  if (typeof input === "string") return input;
  if (typeof input === "number") return String(input);
  throw new Error("Unsupported input type");
}
```

`any`: opts out of type checking entirely. Never use except as a last-resort escape hatch.

`never`: no possible values (bottom type). For functions that always throw, impossible conditional branches, exhaustive checks:

```typescript
function fail(message: string): never {
  throw new Error(message);
}
```

`string | any` collapses to `any` -- mixing `any` destroys type information. `T | never` simplifies to `T` (identity element for unions).

Use `unknown` for catch variables, external data, function params accepting any value:

```typescript
try {
  riskyOperation();
} catch (err: unknown) {
  if (err instanceof Error) {
    console.error(err.message);
  }
}
```

## Result Pattern

Use the Result pattern instead of throwing for expected errors:

```typescript
type Result<T, E = Error> = { ok: true; value: T } | { ok: false; error: E };

function parseJson<T>(input: string): Result<T> {
  try {
    return { ok: true, value: JSON.parse(input) as T };
  } catch (e) {
    return { ok: false, error: e instanceof Error ? e : new Error(String(e)) };
  }
}

const result = parseJson<User>(rawData);
if (result.ok) {
  console.log(result.value.name); // fully typed
} else {
  console.error(result.error.message);
}
```

Reserve `throw` for truly exceptional/unexpected defects (programmer errors, invariant violations).

Consider the `neverthrow` library for production Result types with `.match()`, `.map()`, `.andThen()`:

```typescript
import { ok, err, Result } from "neverthrow";

function divide(a: number, b: number): Result<number, string> {
  if (b === 0) return err("Division by zero");
  return ok(a / b);
}

divide(10, 2)
  .map((val) => val * 100)
  .match(
    (val) => console.log(`Result: ${val}`),
    (error) => console.error(error),
  );
```

Use discriminated union tags (`_tag`) on error classes for exhaustive matching:

```typescript
class NotFoundError {
  readonly _tag = "NotFoundError" as const;
  constructor(public message: string) {}
}
class ValidationError {
  readonly _tag = "ValidationError" as const;
  constructor(public fields: string[]) {}
}

type AppError = NotFoundError | ValidationError;

function handleError(error: AppError): string {
  switch (error._tag) {
    case "NotFoundError":
      return `Not found: ${error.message}`;
    case "ValidationError":
      return `Invalid fields: ${error.fields.join(", ")}`;
  }
}
```

## Readonly & Immutability

Use `as const` for literal constants -- recursively applies `readonly` and narrows to literal types:

```typescript
const CONFIG = {
  apiUrl: "https://api.example.com",
  retries: 3,
  features: ["auth", "logging"],
} as const;
// typeof CONFIG.retries is 3, not number
// typeof CONFIG.features is readonly ["auth", "logging"], not string[]
```

Use `Readonly<T>` for shallow immutability. Create `DeepReadonly<T>` for nested:

```typescript
type DeepReadonly<T> = T extends object
  ? { readonly [K in keyof T]: DeepReadonly<T[K]> }
  : T;

type FrozenConfig = DeepReadonly<Config>;
```

Accept `readonly` parameters in functions that don't mutate input:

```typescript
function sum(numbers: readonly number[]): number {
  return numbers.reduce((a, b) => a + b, 0);
}

const nums = [1, 2, 3] as const;
sum(nums); // works because function accepts readonly
```

`readonly` is compile-time only -- combine with `Object.freeze()` for runtime (but freeze is shallow).

Beware aliasing: passing readonly data to a function with mutable params allows mutation:

```typescript
const frozen: Readonly<{ items: string[] }> = { items: ["a"] };

function mutate(obj: { items: string[] }) {
  obj.items.push("b"); // allowed! Readonly was stripped by the mutable param type
}

mutate(frozen); // compiles, but mutates frozen.items
```

## Template Literal Types

Enforce string patterns at compile time:

```typescript
type EventName = `on${Capitalize<string>}`;

function addEventListener(event: EventName, handler: () => void): void {
  // ...
}

addEventListener("onClick", () => {}); // valid
addEventListener("click", () => {});   // compile error
```

Combine with mapped types for typed event handlers:

```typescript
type Events = "click" | "focus" | "blur";
type EventHandlers = {
  [E in Events as `on${Capitalize<E>}`]: (event: Event) => void;
};
// { onClick: ..., onFocus: ..., onBlur: ... }
```

Use for type-safe string patterns (routes, CSS properties, i18n keys):

```typescript
type Route = `/${string}`;
type CSSCustomProperty = `--${string}`;
type I18nKey = `${string}.${string}`;
```

## Branded/Nominal Types

Prevent logical errors where structurally identical types are semantically different:

```typescript
type Brand<T, B extends string> = T & { readonly __brand: B };
type UserId = Brand<string, "UserId">;
type OrderId = Brand<string, "OrderId">;

function getUser(id: UserId): User { /* ... */ }
function getOrder(id: OrderId): Order { /* ... */ }

const userId = "abc" as UserId;
const orderId = "xyz" as OrderId;

getUser(userId);  // valid
getUser(orderId); // compile error: OrderId is not assignable to UserId
```

Brands exist at compile-time only -- zero runtime overhead.

Use constructor/factory functions with validation to create branded values safely:

```typescript
function createUserId(raw: string): UserId {
  if (!raw.match(/^usr_[a-z0-9]+$/)) {
    throw new Error(`Invalid user ID format: ${raw}`);
  }
  return raw as UserId;
}
```

## Module Patterns

Avoid barrel files (`index.ts`) in large codebases -- Atlassian found 75% build time reduction removing them:

```typescript
// Bad: barrel file re-exports everything
// src/components/index.ts
export { Button } from "./Button";
export { Modal } from "./Modal";
export { Sidebar } from "./Sidebar";

// Good: import directly from source files
import { Button } from "@/components/Button";
import { Modal } from "@/components/Modal";
```

Prefer named exports over default exports -- enables static analysis, auto-imports, rename refactoring:

```typescript
// Prefer
export function formatDate(date: Date): string { /* ... */ }

// Avoid
export default function formatDate(date: Date): string { /* ... */ }
```

Keep side-effects out of modules -- enables tree-shaking and testing:

```typescript
// Bad: side effect on import
const cache = new Map();
populateCache(); // runs when module is imported

// Good: explicit initialization
export function createCache() {
  const cache = new Map();
  return cache;
}
```

## Official Do's and Don'ts

Never use boxed types `Number`, `String`, `Boolean`. Use lowercase:

```typescript
// Bad
let name: String = "hello";
let count: Number = 42;

// Good
let name: string = "hello";
let count: number = 42;
```

Use `void` (not `any`) as return type for callbacks whose return is ignored:

```typescript
// Good
function onComplete(callback: () => void): void { /* ... */ }

// Bad
function onComplete(callback: () => any): void { /* ... */ }
```

Don't make callback parameters optional -- JS allows ignoring them naturally:

```typescript
// Bad
function forEach(callback: (item: string, index?: number) => void): void {}

// Good
function forEach(callback: (item: string, index: number) => void): void {}
// callers can write: forEach((item) => ...) -- ignoring index is fine
```

Don't write overloads differing only in trailing params -- use optional params:

```typescript
// Bad
function log(message: string): void;
function log(message: string, level: string): void;

// Good
function log(message: string, level?: string): void { /* ... */ }
```

Don't write overloads differing only in one arg's type -- use unions:

```typescript
// Bad
function parse(input: string): Result;
function parse(input: Buffer): Result;

// Good
function parse(input: string | Buffer): Result { /* ... */ }
```

Order overloads most specific to most general (TypeScript picks first match):

```typescript
// Good: specific first
function createElement(tag: "input"): HTMLInputElement;
function createElement(tag: "div"): HTMLDivElement;
function createElement(tag: string): HTMLElement;
function createElement(tag: string): HTMLElement {
  return document.createElement(tag);
}
```
