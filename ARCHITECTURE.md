# Architecture Guide - backTap2

## Overview

backTap2 follows a clean architecture pattern with clear separation between data models, business logic, and presentation layers. The design emphasizes:

- **Testability**: Protocol-based store abstraction
- **Maintainability**: Single responsibility principle
- **Scalability**: Easy migration path to Core Data
- **SwiftUI-first**: Reactive data flow with `@Published` properties

## Layer Architecture

```
┌─────────────────────────────────────┐
│     Presentation Layer (SwiftUI)    │
│   - BudgetHomeView.swift            │
│   - BudgetEditorSheet               │
└──────────────┬──────────────────────┘
               │ @EnvironmentObject
               │ @Published bindings
┌──────────────▼──────────────────────┐
│      Business Logic Layer           │
│   - Store Protocol                  │
│   - InMemoryStore (current)         │
│   - CoreDataStore (future)          │
└──────────────┬──────────────────────┘
               │ Conforms to Store
               │ protocol interface
┌──────────────▼──────────────────────┐
│        Data Model Layer             │
│   - Models.swift                    │
│   - CategoryGroup, Category         │
│   - Budget, Transaction             │
└─────────────────────────────────────┘
```

## File Structure

```
backTap2/
├── backTap2App.swift          # App entry point, dependency injection
├── Models.swift               # Pure data models (Codable structs)
├── Store.swift                # Store protocol + implementations
├── BudgetHomeView.swift       # Main UI + editor sheet
└── RecordExpenseIntent.swift  # App Intents integration
```

## Component Details

### 1. Models.swift - Data Layer

**Purpose**: Define the domain models as simple, serializable structs.

**Key Components**:

```swift
// Core entities
struct CategoryGroup: Identifiable, Codable
struct Category: Identifiable, Codable
struct Budget: Identifiable, Codable
struct Transaction: Identifiable, Codable

// Enums
enum TransactionType: String, Codable, CaseIterable

// View models
struct CategoryBudgetRow: Identifiable  // Computed view data

// Extensions
extension Date { 
    func monthString() -> String  // YYYYMM formatting
}
```

**Design Decisions**:
- ✅ Structs (value types) for thread safety
- ✅ Codable for easy serialization
- ✅ UUID identifiers for stable references
- ✅ Immutable by default (use `var` only for Budget.amount)

**Future Considerations**:
- Core Data entities will mirror these structs
- Easy mapping: `struct` ↔ `NSManagedObject`
- Consider adding `Equatable` for comparison operations

### 2. Store.swift - Business Logic Layer

**Purpose**: Abstract data access and mutations behind a protocol.

**Store Protocol**:

```swift
protocol Store: ObservableObject {
    var groups: [CategoryGroup] { get }
    var categories: [Category] { get }
    var budgets: [Budget] { get }
    var transactions: [Transaction] { get }
    
    func addTransaction(_ transaction: Transaction)
    func updateBudget(categoryId: UUID, month: String, amount: Double)
    func actual(for categoryId: UUID, in month: String) -> Double
}
```

**Why a Protocol?**:
- ✅ Dependency inversion: Views depend on abstraction, not concrete implementation
- ✅ Easy testing: Mock store for unit tests
- ✅ Simple migration: Swap InMemoryStore → CoreDataStore
- ✅ ObservableObject: Works seamlessly with SwiftUI

**Current Implementation: InMemoryStore**:

```swift
class InMemoryStore: Store, ObservableObject {
    @Published var groups: [CategoryGroup]
    @Published var categories: [Category]
    @Published var budgets: [Budget]
    @Published var transactions: [Transaction]
    
    // Implementation uses array operations
    // Data stored in memory only
    // Includes preview() factory for demo data
}
```

**Characteristics**:
- ✅ Simple and fast for MVP
- ✅ No persistence overhead
- ✅ Perfect for development and testing
- ⚠️ Data lost when app terminates
- ⚠️ Not suitable for production

### 3. BudgetHomeView.swift - Presentation Layer

**Purpose**: Display budget data and handle user interactions.

**Component Hierarchy**:

```
BudgetHomeView (main screen)
├── monthSelector (HStack with chevrons)
├── chartsSection
│   ├── groupedBarChart (Chart with BarMark)
│   └── pieChart (Chart with SectorMark)
└── budgetTable
    ├── tableHeader
    ├── tableRow (foreach budgetRows)
    └── summaryRow
```

**State Management**:

```swift
@EnvironmentObject var store: InMemoryStore  // Injected dependency
@State private var selectedCategory: CategoryBudgetRow?
@State private var showBudgetEditor = false
@State private var currentMonth: String = Date().monthString()
```

**Data Flow**:
1. Store publishes changes via `@Published`
2. SwiftUI observes via `@EnvironmentObject`
3. View recomputes `budgetRows` computed property
4. UI updates automatically (reactive)

**Editor Sheet**:

```swift
BudgetEditorSheet
├── Category display
├── Budget amount (large)
├── Plus/minus buttons (stepper)
├── Step selector (5/10/50/100)
└── Save/cancel actions
```

**Interaction Flow**:
1. User taps row → `selectedCategory` set → `showBudgetEditor` = true
2. Sheet presents modally
3. User adjusts budget via +/- buttons
4. Tap Save → `store.updateBudget()` → sheet dismisses
5. SwiftUI observes store change → UI updates

### 4. RecordExpenseIntent.swift - App Intents

**Purpose**: Enable Shortcuts and Back Tap integration.

**Intent Definition**:

```swift
struct RecordExpenseIntent: AppIntent {
    @Parameter var amount: Double
    @Parameter var type: TransactionTypeEnum
    @Parameter var group: String
    @Parameter var category: String
    @Parameter var note: String?
    
    func perform() async throws -> some IntentResult
}
```

**Current Limitation**:
- ⚠️ No shared store between app and intent
- ⚠️ Cannot affect in-app data in MVP
- ✅ Intent is discoverable in Shortcuts
- ✅ Back Tap integration works

**Future Solution**:
```swift
// Shared singleton or app group container
class StoreManager {
    static let shared = StoreManager()
    let store: CoreDataStore
    // Use shared container for Shortcuts extension
}
```

### 5. backTap2App.swift - Entry Point

**Purpose**: Initialize app and inject dependencies.

```swift
@main
struct backTap2App: App {
    @StateObject private var store = InMemoryStore.preview()
    
    var body: some Scene {
        WindowGroup {
            BudgetHomeView()
                .environmentObject(store)
        }
    }
}
```

**Dependency Injection**:
- Store created at app level
- Injected via `.environmentObject()`
- Available to all child views
- Single source of truth

## Data Flow Patterns

### 1. Reading Data (Query)

```
View → @EnvironmentObject → Store → @Published arrays → Computed properties → UI
```

Example:
```swift
private var budgetRows: [CategoryBudgetRow] {
    store.categories
        .filter { $0.isActive }
        .map { category in
            let budget = store.budgets.first(...)?.amount ?? 0.0
            let actual = store.actual(for: category.id, in: currentMonth)
            return CategoryBudgetRow(...)
        }
}
```

### 2. Writing Data (Command)

```
User Action → State Change → Store Method → @Published update → SwiftUI refresh
```

Example:
```swift
Button("Save") {
    store.updateBudget(categoryId: id, month: month, amount: newAmount)
    // Store updates @Published property
    // SwiftUI automatically recomputes dependent views
    isPresented = false
}
```

### 3. Computed Values

```
Store → Transactions array → Filter + Reduce → Actual amount
```

Example:
```swift
func actual(for categoryId: UUID, in month: String) -> Double {
    transactions
        .filter { $0.categoryId == categoryId && 
                  $0.type == .expense && 
                  $0.createdAt.monthString() == month }
        .reduce(0.0) { $0 + $1.amount }
}
```

## Migration Path to Core Data

### Step 1: Create Core Data Model

Create `backTap2.xcdatamodeld` with entities:

```
CategoryGroupEntity
├── id: UUID
├── name: String
└── order: Int16

CategoryEntity
├── id: UUID
├── groupId: UUID
├── name: String
├── order: Int16
└── isActive: Bool

BudgetEntity
├── id: UUID
├── categoryId: UUID
├── month: String
└── amount: Double

TransactionEntity
├── id: UUID
├── amount: Double
├── type: String
├── groupId: UUID
├── categoryId: UUID
├── note: String?
├── source: String
├── createdAt: Date
└── clientId: String
```

### Step 2: Implement CoreDataStore

```swift
class CoreDataStore: Store, ObservableObject {
    private let container: NSPersistentContainer
    
    @Published var groups: [CategoryGroup] = []
    @Published var categories: [Category] = []
    @Published var budgets: [Budget] = []
    @Published var transactions: [Transaction] = []
    
    init() {
        container = NSPersistentContainer(name: "backTap2")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed: \(error)")
            }
        }
        fetchAll()
    }
    
    private func fetchAll() {
        // Fetch from Core Data and populate @Published arrays
        // Use NSFetchRequest for each entity
        // Convert NSManagedObject → Struct
    }
    
    func addTransaction(_ transaction: Transaction) {
        let entity = TransactionEntity(context: container.viewContext)
        entity.id = transaction.id
        entity.amount = transaction.amount
        // ... map all properties
        try? container.viewContext.save()
        fetchAll()  // Refresh @Published arrays
    }
    
    func updateBudget(categoryId: UUID, month: String, amount: Double) {
        let fetchRequest: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "categoryId == %@ AND month == %@",
            categoryId as CVarArg, month
        )
        
        if let entity = try? container.viewContext.fetch(fetchRequest).first {
            entity.amount = amount
        } else {
            let newEntity = BudgetEntity(context: container.viewContext)
            newEntity.id = UUID()
            newEntity.categoryId = categoryId
            newEntity.month = month
            newEntity.amount = amount
        }
        
        try? container.viewContext.save()
        fetchAll()
    }
    
    func actual(for categoryId: UUID, in month: String) -> Double {
        // Option 1: Fetch from Core Data with predicate
        // Option 2: Use in-memory transactions array (already fetched)
        return transactions
            .filter { $0.categoryId == categoryId && 
                      $0.type == .expense && 
                      $0.createdAt.monthString() == month }
            .reduce(0.0) { $0 + $1.amount }
    }
}
```

### Step 3: Swap Implementation

In `backTap2App.swift`:

```swift
// Before (MVP):
@StateObject private var store = InMemoryStore.preview()

// After (Production):
@StateObject private var store = CoreDataStore()
```

**That's it!** No changes needed in views because they depend on the `Store` protocol, not the concrete implementation.

### Step 4: Data Migration

For existing users (future):

```swift
class DataMigration {
    static func migrateFromInMemoryToCoreData() {
        let inMemoryStore = InMemoryStore.loadFromDisk()  // If saved to JSON
        let coreDataStore = CoreDataStore()
        
        for group in inMemoryStore.groups {
            coreDataStore.addGroup(group)
        }
        // ... migrate all data
    }
}
```

## Best Practices

### 1. State Management

✅ **DO**:
- Use `@Published` for data that views observe
- Use `@State` for view-local temporary state
- Use `@EnvironmentObject` for shared app state
- Keep view state minimal

❌ **DON'T**:
- Pass store through multiple view layers
- Use global variables
- Mutate state directly without store methods

### 2. Computed Properties

✅ **DO**:
- Use computed properties for derived data
- Keep computations fast and simple
- Cache if computation is expensive

❌ **DON'T**:
- Perform expensive operations in computed properties
- Trigger side effects in getters

### 3. Error Handling

Current: Simple force-unwrapping for MVP
Future: Proper error handling

```swift
// Current (MVP):
try? container.viewContext.save()

// Future (Production):
do {
    try container.viewContext.save()
} catch {
    logger.error("Failed to save: \(error)")
    // Show alert to user
    // Maybe retry or sync later
}
```

### 4. Testing

Mock store for unit tests:

```swift
class MockStore: Store, ObservableObject {
    @Published var groups: [CategoryGroup] = []
    @Published var categories: [Category] = []
    @Published var budgets: [Budget] = []
    @Published var transactions: [Transaction] = []
    
    var addTransactionCalled = false
    var updateBudgetCalled = false
    
    func addTransaction(_ transaction: Transaction) {
        addTransactionCalled = true
        transactions.append(transaction)
    }
    
    func updateBudget(categoryId: UUID, month: String, amount: Double) {
        updateBudgetCalled = true
        // Mock implementation
    }
    
    func actual(for categoryId: UUID, in month: String) -> Double {
        return 100.0  // Mock value
    }
}

// In test:
let mockStore = MockStore()
let view = BudgetHomeView().environmentObject(mockStore)
// Test view logic
XCTAssertTrue(mockStore.updateBudgetCalled)
```

## Performance Considerations

### Current Performance

✅ **Fast**: In-memory arrays, O(n) operations
✅ **Responsive**: Immediate updates, no disk I/O
✅ **Simple**: No database overhead

### Future with Core Data

Potential bottlenecks:
- Fetching large datasets
- Frequent saves triggering UI updates
- Main thread blocking on database operations

Solutions:
- Use NSFetchedResultsController for table views
- Batch saves and debounce frequent updates
- Perform fetches on background context
- Use predicates to limit fetch size

### Optimization Tips

```swift
// Lazy loading for charts
private var chartData: [CategoryBudgetRow] {
    // Only compute when chart is visible
    guard showChart else { return [] }
    return budgetRows
}

// Debounced saving
private var saveCancellable: AnyCancellable?

func debouncedSave() {
    saveCancellable?.cancel()
    saveCancellable = Just(())
        .delay(for: .seconds(0.5), scheduler: RunLoop.main)
        .sink { [weak self] in
            self?.save()
        }
}
```

## Security Considerations

### Data Protection

Current: None (in-memory only)

Future with Core Data:
- Enable Data Protection: `.complete` or `.completeUnlessOpen`
- Encrypt sensitive fields (if storing personal financial data)
- Use Keychain for any credentials

```swift
// Core Data with encryption
let description = NSPersistentStoreDescription()
description.setOption(
    FileProtectionType.complete as NSObject,
    forKey: NSPersistentStoreFileProtectionKey
)
```

### App Intent Security

- Validate all input parameters
- Rate limit intent calls if needed
- Don't expose sensitive data in intent results

## Accessibility

Current implementation includes:
- Semantic colors (red for over budget)
- Monospaced digits for alignment
- System fonts with Dynamic Type support

Future improvements:
- VoiceOver labels for all buttons
- Accessibility hints for interactive elements
- High contrast mode support
- Reduced motion alternatives for animations

## Localization

Current: Chinese strings hardcoded

Future: Use `LocalizedStringResource`:

```swift
// Replace:
Text("本月预算")

// With:
Text("budget.home.title")

// Add Localizable.strings files for each language
```

## Summary

The current architecture provides:
- ✅ Clean separation of concerns
- ✅ Easy testing with protocol abstraction
- ✅ Straightforward Core Data migration path
- ✅ Reactive UI with SwiftUI
- ✅ Extensible for future features

Next steps:
1. Build and test on device
2. Implement Core Data (production)
3. Add unit tests with MockStore
4. Enhance App Intent with shared store
5. Add error handling and logging
6. Implement analytics (if needed)

---

**Architecture Version**: 1.0 (MVP)
**Last Updated**: December 2024
