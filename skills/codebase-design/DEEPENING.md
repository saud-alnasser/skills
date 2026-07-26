# Deepening

How to deepen a cluster of shallow modules safely, given its dependencies. Assumes the vocabulary in [SKILL.md](SKILL.md) — **module**, **interface**, **seam**, **adapter**.

## Dependency categories

When assessing a candidate for deepening, classify its dependencies. The category determines how the deepened module is tested across its seam.

### 1. In-process

Pure computation, in-memory state, no I/O. Always deepenable — merge the modules and test through the new interface directly. No adapter needed.

### 2. Local-substitutable

Dependencies that have local test stand-ins (PGLite for Postgres, in-memory filesystem). Deepenable if the stand-in exists. The deepened module is tested with the stand-in running in the test suite. The seam is internal; no port at the module's external interface.

### 3. Remote but owned (Ports & Adapters)

Your own services across a network boundary (microservices, internal APIs). Define a **port** (interface) at the seam. The deep module owns the logic; the transport is injected as an **adapter**. Tests use an in-memory adapter. Production uses an HTTP/gRPC/queue adapter.

Recommendation shape: *"Define a port at the seam, implement an HTTP adapter for production and an in-memory adapter for testing, so the logic sits in one deep module even though it's deployed across a network."*

### 4. True external (Mock)

Third-party services (Stripe, Twilio, etc.) you don't control. The deepened module takes the external dependency as an injected port; tests provide a mock adapter.

## Seam discipline

[SKILL.md](SKILL.md) has the two principles — *two adapters make a real seam*, and *internal seams are not part of the interface*. Applied to a port: don't define one unless at least two adapters are justified, typically production plus test. A single-adapter port is indirection wearing a seam's clothes.

## Testing strategy: replace, don't layer

The deepening is only finished when the old tests are gone. Write the new tests at the deepened module's interface — it is the test surface — then **delete the unit tests on the shallow modules underneath**. They now assert internals, and keeping them is what makes a deepening feel like it made testing worse.

Layering the new tests on top of the old ones is the failure. Two suites cover the same behaviour, the old one breaks on every refactor, and the pressure is to re-shallow the module.
