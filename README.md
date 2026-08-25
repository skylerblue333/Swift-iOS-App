# Sky Tasks — Swift Mobile Core

Sky Tasks is a small SwiftUI task-management component for the SKYCOIN4444 engineering portfolio. It provides a bounded local task model and accessible SwiftUI interaction surface that can be embedded in a larger iOS application.

## Implemented

- native Swift / SwiftUI source
- task creation with trimmed 1–200 character titles
- priorities from 1–5
- deterministic pending-first, priority-aware ordering
- completion and deletion state transitions
- bounded 1,000-task in-memory capacity
- pending/completed counters
- XCTest coverage for validation and state behavior
- Swift Package debug/test/release CI

## Product boundary

Status: **engineering beta / mobile component**.

This repository does not currently claim a signed `.ipa`, committed Xcode app project, App Store/TestFlight release, cloud synchronization, authentication, push notifications, durable persistence, secure storage, analytics, backend integration, device-farm verification, or production deployment. Task state is process-local and is lost when the owning app discards the store.

## Development

```bash
swift build
swift test
swift build -c release
```

The package targets iOS 16+ and macOS 13+ so the core can be tested with Swift Package Manager while remaining suitable for SwiftUI integration.

## SKYCOIN4444 integration

Use `TaskStore` and `ContentView` as a local mobile task surface. Persistence, identity, synchronization, notifications, and network behavior should be connected through separately verified application adapters rather than fabricated inside this package.
