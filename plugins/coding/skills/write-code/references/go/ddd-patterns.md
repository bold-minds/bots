# DDD, CQRS & Event Sourcing Patterns

Distilled from Fowler, Evans, Stemmler, Chris Kiehl, Arkency, ThreeDots, Uncle Bob, and production war stories.
Bounded Context basics are in `craft/references/architecture-wisdom.md` -- not repeated here.

---

## DDD Strategic Design

### Screaming Architecture (Uncle Bob)
- **Your top-level directory structure should scream the domain, not the framework.** If someone opens your repo and sees `controllers/`, `models/`, `services/`, they know you used MVC. If they see `billing/`, `scheduling/`, `inventory/`, they know what the system *does*. The latter is correct.
- **Organize by use case, not by technical layer.** `order/place.go`, `order/cancel.go`, `order/fulfill.go` -- not `handlers/order.go`, `services/order.go`, `repos/order.go`.
- **Frameworks are details, not architecture.** Fiber, GORM, Redis -- these live at the edges. Your domain package should have zero framework imports. If swapping Fiber for stdlib `net/http` requires touching domain code, your boundaries are wrong.
- **The test: can you understand what the system does from `ls` alone?** If not, restructure until you can.

### DDD + Clean Architecture: How They Complement
- **DDD provides the *what* (tactical modeling tools).** Entities, Value Objects, Aggregates, Domain Events, Domain Services.
- **Clean Architecture provides the *how* (dependency direction).** All dependencies point inward. Domain knows nothing about infrastructure.
- **Application Services (DDD) = Use Cases (Clean Architecture).** Thin orchestrators that fetch aggregates, delegate to domain logic, persist results. Zero business rules live here.
- **Domain Services handle cross-aggregate operations.** When a business rule spans multiple aggregates (e.g., transferring money between accounts), a Domain Service coordinates. Don't shove multi-aggregate logic into one aggregate arbitrarily.

### Intention-Revealing Interfaces (Stemmler)
- **Name classes and methods by effect and purpose, never by mechanism.** `BillCustomer` not `ProcessPayment`. `AnnualSubscription` not `RecurringCharge`. `PlaceOrder` not `CreateOrderRecord`.
- **Ban generic names:** `Manager`, `Processor`, `Handler`, `Service`, `Helper`, `Utils`. These are symptoms of unclear domain thinking.
- **If a developer must read the implementation to use the interface, encapsulation has failed.** The method signature and name must be sufficient.
- **Use domain language from experts, not developer jargon.** When code reads like how the business talks, onboarding cost drops and bugs from misunderstanding decrease.
- **Separate use cases into distinct types.** `BillCustomerUseCase` and `RefundCustomerUseCase` -- not a single `PaymentService` with 15 methods. Each use case is independently testable and replaceable.

### Context Mapping (Beyond Bounded Context Basics)
- **Shared Kernel:** Two teams share a subset of the domain model. High coordination cost. Use only when the shared concept is truly identical in both contexts and worth the coupling.
- **Customer-Supplier:** Upstream team's decisions affect downstream. Downstream must negotiate or adapt. Formalize this with explicit API contracts and versioning.
- **Conformist:** Downstream team has no influence on upstream. They conform to whatever the upstream provides. Common with third-party APIs. Don't fight it -- wrap it.
- **Anti-Corruption Layer (ACL):** A translation layer that prevents a foreign model from leaking into your domain. This is the most important pattern for integrating with legacy systems or third-party services. The ACL converts external concepts into your domain's language.
- **Open Host Service + Published Language:** Expose a well-defined protocol (REST, gRPC, events) with a documented schema. This is how you become a good upstream neighbor.

---

## DDD Tactical Patterns

### Entities vs Value Objects: The Decision
- **Entity:** Has identity that persists across state changes. Two `User` objects with different fields but the same ID are the same user. Identity matters.
- **Value Object:** Defined entirely by its attributes. Two `Money{100, "USD"}` are interchangeable. No identity. Immutable. Equality by value, not reference.
- **Default to Value Object.** Most concepts are values, not entities. Address, Money, DateRange, Email, Coordinates, Color -- all value objects. Entities are rarer than you think.
- **Value Objects in Go:** Implement as structs with no exported setters. Methods return new instances. Implement `Equal()` for comparison. Consider implementing `String()` for debugging.

```go
// Value Object pattern in Go
type Money struct {
    amount   int64  // cents, avoid float
    currency string
}

func (m Money) Add(other Money) (Money, error) {
    if m.currency != other.currency {
        return Money{}, errors.New("currency mismatch")
    }
    return Money{amount: m.amount + other.amount, currency: m.currency}, nil
}
```

- **Value Object interface pattern (codeinabox/go-go-valueobject):** Define a common interface for all value objects, then implement with validation-on-construction. The constructor is the only way to create a valid instance.

```go
// Common interface -- every value object is comparable and printable.
// (Source: codeinabox/go-go-valueobject/interface.go)
type Value interface {
    fmt.Stringer
    Equals(value Value) bool
}

// Concrete value object: validates on construction, unexported field.
// (Source: codeinabox/go-go-valueobject/email_address.go)
type EmailAddress struct { value string }

func NewEmailAddress(email string) (EmailAddress, error) {
    if !emailRegex.MatchString(email) {
        return EmailAddress{}, ErrInvalidEmailAddress
    }
    return EmailAddress{value: email}, nil  // only valid instances escape
}

func (n EmailAddress) Equals(value Value) bool {
    other, ok := value.(EmailAddress)
    return ok && n.value == other.value  // equality by value, type-safe
}
```

- **The hidden power of Value Objects (Arkency):** They push you toward richer domain models. When you extract `Email` from a raw string, you gain a place to put validation, normalization, and formatting. When you extract `OrderTotal` from a float, you gain currency safety and rounding rules. Value Objects are where domain knowledge accumulates.

### Aggregates: The Hardest Part of DDD
- **An Aggregate is a consistency boundary, not just a cluster of objects.** Everything inside the boundary must be consistent after every operation. Everything outside is eventually consistent.
- **Only the Aggregate Root is accessible from outside.** External code never holds a reference to an internal entity. All access goes through the root.
- **One Repository per Aggregate.** The repository loads and saves the entire aggregate atomically. No repository for internal entities.
- **Keep Aggregates small.** Large aggregates create contention (multiple users modifying the same aggregate) and performance problems (loading the entire graph for every operation). Prefer references by ID over direct object references.
- **Cross-aggregate references are by ID only.** `Order` holds `customerID string`, not `customer *Customer`. This enforces the boundary and prevents lazy loading traps.
- **Aggregates communicate via Domain Events.** When an `Order` is placed, it emits `OrderPlaced`. The `Inventory` aggregate reacts asynchronously. They don't call each other directly.

### Domain Events
- **Past tense, always.** `OrderPlaced`, `PaymentReceived`, `UserRegistered`. Never `PlaceOrder` (that's a command).
- **Events are facts.** They happened. They cannot be rejected or rolled back. Design compensating events instead (`OrderCancelled`, `PaymentRefunded`).
- **Fat events over thin events.** Include all data consumers need to process the event. Thin events that require callbacks to the source service create temporal coupling and defeat the purpose of event-driven architecture.
- **Events are part of your public API.** Once published, they're a contract. Consumers depend on their schema. Version them from day one.

---

## Event Storming & Domain Discovery

### Event Storming (Alberto Brandolini)
- **What it is:** A workshop technique where domain experts and developers collaboratively map a business process using sticky notes on a wall. Output: a shared understanding of the domain that maps directly to bounded contexts, aggregates, and events.
- **The color code:** Orange = Domain Events (past tense facts). Blue = Commands (user intent). Yellow = Actors (who triggers). Pink = External Systems. Lilac = Policies ("when X happens, then Y"). Green = Read Models (information needed to make decisions).
- **Start with events, not structure.** Have domain experts place orange stickies for everything that happens in the process, in rough chronological order. Don't organize yet. Chaos first, structure later.
- **Look for pivotal events.** Events where the process fundamentally changes direction: `OrderPaid`, `ClaimApproved`, `ShipmentDispatched`. These often mark aggregate or bounded context boundaries.
- **Hotspots = where the stickies cluster.** Dense areas indicate complex business logic. Sparse areas are CRUD. This tells you where to invest modeling effort and where to keep it simple.
- **The output maps to code:** Events become Domain Events. Commands become command handlers. Aggregates emerge from consistency boundaries around event clusters. Policies become event-driven process managers.

### Domain Storytelling
- **Complementary to Event Storming, not a replacement.** Domain Storytelling captures narratives ("Alice creates an order, then Bob reviews it"), while Event Storming captures mechanics ("OrderCreated, then OrderReviewed").
- **Use Domain Storytelling first** to understand the big picture and identify bounded contexts. Then use Event Storming to dive deep into each context.
- **Artifacts:** Visual story diagrams showing actors, activities, and work items. These become the ubiquitous language and reveal boundaries where the language changes.
- **The boundary test:** When two stories use the same word differently, you've found a bounded context boundary.

---

## CQRS Patterns

### CQRS Without Event Sourcing (The Pragmatic Default)
- **CQRS and Event Sourcing are independent patterns.** You can use CQRS without ES. In most systems, you should. ES adds significant complexity that is only justified in specific domains.
- **State-based projection (no events needed):** Write side uses a normalized relational model. Read side uses denormalized views, materialized views, or a separate read database. Sync via database views, change data capture, or application-level projections.
- **The simplest CQRS: SQL views.** Write to normalized tables, read from views that join and denormalize. Zero infrastructure overhead. Works until your read and write performance requirements diverge significantly.
- **When to physically separate read/write stores:** When read patterns require a different data model (search index, graph, time-series), when read/write load ratios are extreme (1000:1), or when read latency requirements demand caching/denormalization that would pollute the write model.

### Command Design
- **Commands express user intent, not data mutations.** `PlaceOrder`, not `InsertOrderRow`. `ChangeAddress`, not `UpdateCustomerRecord`.
- **Commands are imperative, present tense.** They represent a request that may be rejected. `PlaceOrder` can fail validation. `OrderPlaced` (event) cannot.
- **One handler per command.** Each command has exactly one handler. If multiple handlers need to react, the handler emits a domain event and subscribers handle the rest.

### Returning From Command Buses
- **The purist position:** Commands return void. The command bus is fire-and-forget. Query for results separately.
- **The pragmatic position:** Returning the ID of the created resource (or a simple success/failure) from a command handler is fine. It avoids a clunky extra query round-trip and solves the "what ID was assigned?" problem.
- **The compromise:** Commands return only enough to locate the result -- typically the aggregate ID. Never return the full read model from a command handler. That's query logic leaking into the write side.

### CQRS in Go: Practical Patterns (ThreeDots / Wild Workouts)
- **Command and Query as distinct types:**

```go
type PlaceOrderCommand struct {
    CustomerID string
    Items      []OrderItem
}

type GetOrderQuery struct {
    OrderID string
}
```

- **Handlers as single-method interfaces:**

```go
type CommandHandler[C any] interface {
    Handle(ctx context.Context, cmd C) error
}

type QueryHandler[Q any, R any] interface {
    Handle(ctx context.Context, query Q) (R, error)
}
```

- **Decorator pattern for cross-cutting concerns.** Logging, metrics, validation, authorization -- implement as handler decorators (middleware), not as logic inside handlers. Each decorator wraps the handler and adds one concern.

---

## Event Sourcing

### When Event Sourcing Is Worth It
- **Audit trail is a regulatory requirement** (finance, healthcare, legal). A history table is 80% of the value at 20% of the cost -- but regulators sometimes want the other 20%.
- **Temporal queries are a core use case.** "What was the account balance at 3pm last Tuesday?" If this is a frequent question, ES gives it to you for free.
- **The domain is inherently event-driven.** Banking (transactions), logistics (shipments), insurance (claims). If domain experts already think in events, ES aligns with their mental model.
- **You need to build multiple read models from the same source of truth.** ES makes this natural -- each projection consumes the same event stream.

### When Event Sourcing Is NOT Worth It (Kiehl)
- **"Auditability" as the only justification is weak.** An append-only history table or CDC-based audit log gives you auditability without the full ES machinery.
- **CRUD-heavy domains with simple state.** A user profile, a settings page, a CMS -- these don't benefit from event streams.
- **If you actually just need a message queue,** use a message queue. ES is not a messaging system. The event store is a database, not a broker.
- **If the team hasn't built one before,** budget entire sprints for infrastructure before a single feature ships. The learning curve is steep and the failure modes are subtle.

### The Hard Truths (Kiehl + Arkency)
1. **Projections are not free.** Each new read model is another consumer of the event stream with its own code, its own bugs, and its own consistency concerns. N projections means N things that can break when you change an event schema.
2. **Materialization lag is real and painful.** Once you need projections, you have eventual consistency. Users create a resource, then immediately query for it and get a 404. You must solve this with read-your-writes consistency, synchronous projections for critical paths, or UX that accounts for lag.
3. **Events in the store are immutable, but your schema isn't.** Events written a year ago must still be deserializable. This is the versioning problem, and it never goes away.
4. **The "perfect audit log" degrades over time.** Software changes make old events semantically meaningless. The event `PriceAdjusted{amount: 50}` means nothing if the pricing model changed three times since it was written.
5. **UI impedance mismatch.** Most UIs produce form blobs ("save this entire form"). ES backends want fine-grained semantic commands. Either redesign the UI to be task-based or accept a translation layer between UI and commands.
6. **Debugging via replay rarely solves real problems.** Most bad states come from bad events (human error, business logic bugs), not from data corruption. Replaying the same bad events produces the same bad state.
7. **Coupling hides behind the event stream.** Services reading raw events from the store are coupled to the producer's internal model. This is worse than direct API calls because the coupling is invisible. Use published events (explicitly designed for consumers) or an anti-corruption layer.

### Event Versioning Strategies
- **Weak schema (recommended starting point):** Use a flexible format (JSON with optional fields). New fields have defaults. Old events without new fields are handled gracefully. This covers 80% of evolution needs.
- **Upcasting:** Transform old event versions to new versions during deserialization. The event store contains the original bytes, but the application sees the latest version. Keep upcasters as a chain: v1 -> v2 -> v3.
- **Event migration (use sparingly):** Rewrite events in the store to match the new schema. Irreversible and dangerous. Only for cases where upcasting is impractical (removing PII, fixing corruption).
- **New event type:** When the semantics change fundamentally, introduce a new event type rather than versioning the old one. `OrderPlacedV2` is a code smell -- `OrderSubmitted` with different semantics is cleaner.
- **Copy-and-replace stream:** Create a new stream with transformed events, redirect reads, then archive the old stream. Useful for major migrations.

### GDPR and Event Sourcing: Crypto-Shredding
- **The problem:** GDPR's right to erasure conflicts with immutable event stores. You can't delete events, and you can't retroactively remove PII from them.
- **Crypto-shredding pattern:** Encrypt PII fields in events with a per-user encryption key stored in a key management system (e.g., HashiCorp Vault). To "delete" a user's data, delete their encryption key. The events remain but the PII is irrecoverable.
- **Implementation:** Each user gets a unique encryption key at registration. All PII in events is encrypted with that key before storage. Projections decrypt at read time using the key. When deletion is requested, revoke the key -- projections rebuild with encrypted (unreadable) fields.
- **Separate PII from domain data in events.** Design events so PII fields are clearly isolated, making encryption surgical rather than whole-event.

### The Outbox Pattern (Transactional Event Publishing)
- **The dual-write problem:** Writing to the database AND publishing to a message broker is not atomic. If the app crashes between the two, you get inconsistency -- the DB has the change but the event was never published, or vice versa.
- **The solution:** Write events to an "outbox" table in the same database transaction as the state change. A separate process polls the outbox table and publishes events to the broker. Atomicity comes from the database transaction.
- **Polling vs CDC:** Polling is simpler but adds latency and database load. Change Data Capture (CDC, e.g., Debezium) tails the database WAL and publishes changes with minimal latency and no polling overhead. CDC is better at scale but adds operational complexity.
- **Ordering guarantees:** The outbox table should include a sequence number. The publisher processes events in order per aggregate. Global ordering across aggregates is usually unnecessary and extremely expensive.
- **Idempotent consumers are mandatory.** The outbox guarantees at-least-once delivery. Consumers must handle duplicates. Include an event ID and use it for deduplication.

---

## Useful Go Libraries

| Library | Purpose | When to Use | Notes |
|---------|---------|-------------|-------|
| **[looplab/eventhorizon](https://github.com/looplab/eventhorizon)** | Full CQRS/ES framework | When you want batteries-included CQRS/ES with multiple backend options | Supports MongoDB, PostgreSQL, DynamoDB event stores; GCP Pub/Sub, Kafka, NATS event buses. Production-grade but opinionated. |
| **[mishudark/eventhus](https://github.com/mishudark/eventhus)** | Lightweight CQRS/ES toolkit | When eventhorizon is too heavy and you want a simpler starting point | MongoDB event store, RabbitMQ/NATS for publishing. Less ecosystem, but less ceremony. |
| **[go-ozzo/ozzo-validation](https://github.com/go-ozzo/ozzo-validation)** | Code-based validation | When struct tag validation is too limiting or unreadable | Validation rules as Go code, not struct tags. Supports conditional validation, custom rules, nested structs. Pairs well with DDD value objects. |
| **[rs/zerolog](https://github.com/rs/zerolog)** | Zero-allocation JSON logger | For structured logging in hot paths where allocation matters | Fastest Go logger. Chain API: `log.Info().Str("key", "val").Msg("done")`. No reflection, no allocations in common paths. |
| **[uber-go/goleak](https://github.com/uber-go/goleak)** | Goroutine leak detector | In test suites to catch goroutine leaks from event handlers, subscribers, projections | Add `defer goleak.VerifyNone(t)` to tests. Essential for CQRS/ES systems where background goroutines proliferate. |

### Library Selection Guidance
- **Starting a new CQRS/ES project?** Start without a framework. Implement command/query handlers as plain Go interfaces. Add eventhorizon only when you need its event store or bus abstractions -- you may never need them.
- **Validation in DDD?** ozzo-validation > struct tags. Value Objects should validate on construction, and ozzo lets you express complex rules as code inside the constructor.
- **Logging?** zerolog for services. See also `go-wisdom.md` logging section -- the rule is still "only Info and Debug matter."
- **Testing event-driven code?** goleak catches the goroutines your projections and event handlers leak. Combine with `-race` flag.

---

## Code Pattern Examples

Real patterns extracted from reference implementations. Each demonstrates a structural idea worth stealing.

### Clean Architecture Layer Separation (bxcodec/go-clean-arch)

Domain structs live in `domain/` with zero dependencies. Use-case logic lives in feature packages (`article/`) that depend on domain but define their own repository interfaces. This is the dependency inversion principle in action -- the service owns the interface, not the infrastructure.

```go
// domain/article.go -- pure data, no behavior, no imports beyond stdlib
type Article struct {
    ID        int64     `json:"id"`
    Title     string    `json:"title" validate:"required"`
    Content   string    `json:"content" validate:"required"`
    Author    Author    `json:"author"`
    UpdatedAt time.Time `json:"updated_at"`
    CreatedAt time.Time `json:"created_at"`
}

// article/service.go -- the USE CASE layer defines the repo interface it needs
type ArticleRepository interface {
    Fetch(ctx context.Context, cursor string, num int64) ([]domain.Article, string, error)
    GetByID(ctx context.Context, id int64) (domain.Article, error)
    Store(ctx context.Context, a *domain.Article) error
    Delete(ctx context.Context, id int64) error
}

// Service depends on interfaces, not implementations
type Service struct {
    articleRepo ArticleRepository
    authorRepo  AuthorRepository
}
```

**Key insight:** The repository interface is declared next to the service that uses it, not next to the implementation. Infrastructure adapters (Postgres, in-memory, etc.) implement this interface from the outside.

### DDD Aggregate with Rich Domain Language (marcusolsson/goddd)

The goddd shipping example shows how aggregates should read like domain prose. Methods are named for business operations, not CRUD. Value objects (`RouteSpecification`, `TrackingID`) carry domain semantics. The `Cargo` aggregate coordinates state transitions through domain-meaningful methods.

```go
// Root entity of the Cargo aggregate -- domain operations, not setters
type Cargo struct {
    TrackingID         TrackingID          // value object, not raw string
    Origin             UNLocode            // value object
    RouteSpecification RouteSpecification  // value object (origin, dest, deadline)
    Itinerary          Itinerary           // value object
    Delivery           Delivery            // derived state
}

func (c *Cargo) SpecifyNewRoute(rs RouteSpecification) {
    c.RouteSpecification = rs
    c.Delivery = c.Delivery.UpdateOnRouting(c.RouteSpecification, c.Itinerary)
}

func (c *Cargo) AssignToRoute(itinerary Itinerary) {
    c.Itinerary = itinerary
    c.Delivery = c.Delivery.UpdateOnRouting(c.RouteSpecification, c.Itinerary)
}

// Repository interface -- one per aggregate, in the domain package
type CargoRepository interface {
    Store(cargo *Cargo) error
    Find(id TrackingID) (*Cargo, error)
    FindAll() []*Cargo
}
```

**Key insight:** `SpecifyNewRoute` and `AssignToRoute` are domain verbs, not `SetRoute`. The `Delivery` is automatically recalculated -- the aggregate maintains its own invariants.

### DDD Application Service / Booking Service (marcusolsson/goddd)

The booking service shows the Application Service pattern: a thin orchestrator that delegates to domain objects. It loads aggregates from repos, calls domain methods, persists results. Zero business logic in the service itself.

```go
// Service interface uses domain language -- BookNewCargo, not CreateCargo
type Service interface {
    BookNewCargo(origin, destination UNLocode, deadline time.Time) (TrackingID, error)
    AssignCargoToRoute(id TrackingID, itinerary Itinerary) error
    ChangeDestination(id TrackingID, destination UNLocode) error
}

// Implementation: load, delegate to domain, persist. That's it.
func (s *service) AssignCargoToRoute(id TrackingID, itinerary Itinerary) error {
    c, err := s.cargos.Find(id)   // load aggregate
    if err != nil { return err }
    c.AssignToRoute(itinerary)     // delegate to domain
    return s.cargos.Store(c)       // persist
}
```

**Key insight:** The service is a 3-line pattern: load, delegate, persist. If your application services contain business rules, those rules belong on the aggregate or a domain service instead.

### Event-Sourced Aggregate (andrewdodd/m-r -- Greg Young's SimpleCQRS in Go)

This is the canonical CQRS/ES reference ported to Go. The aggregate applies changes through events, accumulates uncommitted events, and rebuilds from history. Commands live on the aggregate as methods that validate and emit events.

```go
// Aggregate root base -- tracks uncommitted events, supports replay
type AggRoot struct {
    changes  []Event
    _version int
    id       Guid
    InnerApply func(e Event) error  // polymorphic event handler
}

func (ag *AggRoot) ApplyChange(e Event) error {
    return ag.applyChangeInternal(e, true)  // apply + track as new
}

func (ag *AggRoot) LoadsFromHistory(history []Event) error {
    for _, e := range history {
        ag.applyChangeInternal(e, false)  // apply but don't track
    }
    return nil
}

// Concrete aggregate -- commands validate, then emit events
func (ii *InventoryItem) Remove(count int) error {
    if count <= 0 {
        return errors.New("cannot remove negative count")
    }
    ii.ApplyChange(NewItemsRemovedFromInventory(ii.id, count))
    return nil
}

// Event handler -- mutates state, called for both new and replayed events
func (ii *InventoryItem) handleEvent(event Event) error {
    switch e := event.(type) {
    case InventoryItemCreated:
        ii.id = e.Id()
        ii.activated = true
    case InventoryItemDeactivated:
        ii.activated = false
    }
    return nil
}
```

**Key insight:** The separation between commands (which validate) and event handlers (which mutate state) is the core of event sourcing. Commands can fail; event application cannot. `LoadsFromHistory` replays events without re-tracking them.

### Hex Architecture Package Structure (katzien/go-structure-examples)

The `domain-hex` variant organizes by use case (`adding/`, `listing/`, `reviewing/`), each package owning its own service interface and repository interface. Compare with flat, layered, and modular variants in the same repo.

```
domain-hex/
  pkg/
    adding/       # use case: add a beer
      beer.go     # input DTO for this use case
      service.go  # Service interface + Repository interface + implementation
    listing/      # use case: list/get beers
      beer.go     # read model for this use case
      review.go
      service.go
    reviewing/    # use case: review a beer
    storage/      # infrastructure adapters
    http/         # delivery layer (handlers)
```

```go
// adding/service.go -- each use case defines its own repository contract
type Service interface {
    AddBeer(...Beer) error
}
type Repository interface {
    AddBeer(Beer) error
    GetAllBeers() []listing.Beer
}

// listing/service.go -- separate read interface
type Service interface {
    GetBeer(string) (Beer, error)
    GetBeers() []Beer
    GetBeerReviews(string) []Review
}
```

**Key insight:** Each use case package is independently testable. The `adding.Repository` and `listing.Repository` are different interfaces even if backed by the same database -- the read and write contracts are separated at the interface level.
