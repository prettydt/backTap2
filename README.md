# backTap2

An iOS budget tracking app with quick expense logging via App Intents and Shortcuts, featuring a Numbers-style budget table with visual charts.

## Features

- 📱 **iPhone-only iOS 16+ app** with SwiftUI
- 🎯 **Quick logging via App Intent** - Record expenses through Shortcuts or Back Tap workflow
- 📊 **Numbers-style budget table** - Editable budgets with monospaced digits and zebra rows
- 📈 **Visual charts** - Grouped bar chart (Budget vs Actual) and pie chart for budget distribution
- 💾 **Local-only storage** - In-memory store with architecture ready for Core Data migration
- 🎨 **Intuitive UI** - Stepper-based budget editor with preset step amounts

## Requirements

- iOS 16.0+
- Xcode 15.0+
- iPhone device or simulator (portrait orientation only)

## Getting Started

### Building the App

1. Clone the repository:
   ```bash
   git clone https://github.com/prettydt/backTap2.git
   cd backTap2
   ```

2. Open the project in Xcode:
   ```bash
   open backTap2.xcodeproj
   ```

3. Select an iPhone simulator (e.g., iPhone 15 Pro) or connect a physical iPhone device

4. Build and run the project (⌘+R)

### Using the App

#### Home Screen (本月预算)

The main screen displays:

1. **Month Selector** - Navigate between months (currently displays current month)
2. **Charts Section**:
   - **Grouped Bar Chart**: Compare Budget vs Actual spending per category
   - **Pie Chart**: Visualize budget distribution across categories
3. **Budget Table**: Numbers-style table with columns:
   - **Category**: Expense category name
   - **Budget**: Planned amount (editable)
   - **Actual**: Actual spending (read-only)
   - **Diff**: Difference (Actual - Budget, red when over budget)
4. **Summary Row**: Total amounts for all categories

#### Editing Budgets

1. Tap any category row in the table
2. A bottom sheet opens with:
   - Current budget amount
   - **−** and **+** buttons to adjust the budget
   - **Step amount selector**: Choose from ¥5, ¥10, ¥50, or ¥100 increments
   - **Save** button to confirm changes
3. Changes update immediately in the table and charts

#### Sample Data

The app includes demo data with Chinese category names:
- **饮食** (Food): 餐饮 (Dining), 零食 (Snacks)
- **交通** (Transportation): 公交地铁 (Metro), 打车 (Taxi)
- **娱乐** (Entertainment): 电影 (Movies), 游戏 (Games)
- **生活** (Daily Life): 日用品 (Necessities), 服装 (Clothing)

## App Intents & Shortcuts Integration

### RecordExpenseIntent

The app provides an App Intent called **RecordExpenseIntent** for quick expense logging.

#### Parameters:
- **amount** (Double): Transaction amount
- **type** (enum): expense or income
- **group** (String): Category group name
- **category** (String): Specific category name
- **note** (String, optional): Additional note

#### Setting up in Shortcuts:

1. Open the **Shortcuts** app on your iPhone
2. Create a new shortcut with the **+** button
3. Search for "Record Expense" or "backTap2"
4. Add the **Record Expense** action
5. Configure the parameters:
   - Amount: Set a fixed value or ask for input
   - Type: Choose "expense" or "income"
   - Group: Enter category group (e.g., "饮食")
   - Category: Enter specific category (e.g., "餐饮")
   - Note: Optional description

#### Wiring to Back Tap:

1. Go to **Settings** → **Accessibility** → **Touch** → **Back Tap**
2. Choose **Double Tap** or **Triple Tap**
3. Scroll to **Shortcuts** section
4. Select your expense recording shortcut
5. Now tapping the back of your iPhone will trigger quick expense logging!

**Note**: The current MVP uses in-memory storage. For production use with Shortcuts, implement persistent storage using Core Data or an app group container to share data between the app and the Shortcuts extension.

## Architecture

### Data Models

- **CategoryGroup**: Top-level grouping (e.g., Food, Transportation)
- **Category**: Specific expense category within a group
- **Budget**: Planned spending amount per category per month
- **Transaction**: Individual expense or income record with metadata

### Store Protocol

The app uses a `Store` protocol to abstract data access:

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

### Current Implementation: InMemoryStore

For the MVP, an `InMemoryStore` class implements the protocol with sample data. All data is stored in memory and resets when the app closes.

### Future: Core Data Migration

The architecture is designed for easy migration to Core Data:
1. Create Core Data model (.xcdatamodeld) with entities matching the structs
2. Implement `CoreDataStore` conforming to `Store` protocol
3. Swap `InMemoryStore.preview()` with `CoreDataStore()` in `backTap2App.swift`

A placeholder for `CoreDataStore` is included in `Store.swift` with TODO comments.

## Project Structure

```
backTap2/
├── backTap2.xcodeproj/           # Xcode project file
├── backTap2/
│   ├── backTap2App.swift         # App entry point
│   ├── Models.swift              # Data model definitions
│   ├── Store.swift               # Store protocol & implementations
│   ├── BudgetHomeView.swift      # Main UI with table & charts
│   ├── RecordExpenseIntent.swift # App Intent for Shortcuts
│   ├── Assets.xcassets/          # App icons & assets
│   └── Info.plist                # App configuration
├── README.md                     # This file
└── .gitignore                    # Git ignore rules
```

## Testing

### Preview

The project includes SwiftUI previews with sample data. In Xcode:
1. Open `BudgetHomeView.swift`
2. Click **Resume** in the preview canvas (⌥+⌘+Return)
3. Interact with the preview to test budget editing

### Simulator Testing

1. Build and run on iPhone simulator
2. Test budget editing by tapping category rows
3. Verify:
   - Budget values update in real-time
   - Charts reflect changes immediately
   - Summary row totals are correct
   - Step selector changes adjustment increments
   - Validation prevents negative budgets

### App Intent Testing

Testing the RecordExpenseIntent requires either:
- Running shortcuts that call the intent
- Using Xcode's Shortcuts testing interface (requires physical device)

## Validation

The budget editor includes validation:
- **Non-negative amounts**: Budget cannot go below ¥0.00
- **Two decimal precision**: All amounts rounded to 2 decimal places
- **Real-time updates**: Changes reflect immediately in UI

## Future Enhancements

Out of scope for v1 but planned for future versions:

- ✨ **Core Data persistence** - Permanent storage with migration from InMemoryStore
- ☁️ **CloudKit sync** - Multi-device synchronization
- 🔍 **Advanced filtering** - Search and filter transactions
- 📅 **Multi-month navigation** - Full calendar navigation
- 🎨 **Category customization** - Add, edit, delete categories
- 📸 **OCR support** - Scan receipts for automatic entry
- 📤 **Export** - Export data to CSV or PDF
- 🔔 **Budget alerts** - Notifications when approaching limits

## Contributing

This is an MVP implementation. Contributions welcome for:
- Core Data implementation
- CloudKit sync
- Additional chart types
- Localization support
- Accessibility improvements

## License

MIT License - See LICENSE file for details

## Contact

For questions or feedback, please open an issue on GitHub.

---

**Version**: 1.0.0 (MVP)  
**Last Updated**: December 2024