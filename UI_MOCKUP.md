# UI Mockup - backTap2

## Home Screen Layout (本月预算)

```
┌─────────────────────────────────────┐
│  ← [本月预算]                    →  │  ← Navigation Bar
├─────────────────────────────────────┤
│                                     │
│  ←      2024年12月      →           │  ← Month Selector
│                                     │
├─────────────────────────────────────┤
│  预算 vs 实际                        │  ← Chart Title
│  ┌────────────────────────────┐    │
│  │     ▓  ░                   │    │
│  │     ▓  ░   ▓  ░           │    │  ← Grouped Bar Chart
│  │     ▓  ░   ▓  ░  ▓  ░     │    │    (Blue=Budget, Orange=Actual)
│  │  ▓  ▓  ░   ▓  ░  ▓  ░  ▓  │    │
│  │  ▓  ▓  ░   ▓  ░  ▓  ░  ▓  │    │
│  │  ▓  ▓  ░   ▓  ░  ▓  ░  ▓  │    │
│  └────────────────────────────┘    │
│   餐饮 零食 公交 打车 电影 游戏 日用 服装  │
│                                     │
├─────────────────────────────────────┤
│  预算分布                            │  ← Pie Chart Title
│       ┌─────────────┐               │
│       │   ░░░░░░    │               │
│       │ ▓▓░░░░░░▒▒  │               │  ← Donut Pie Chart
│       │ ▓▓▓░░░▒▒▒▒  │               │    (Different colors per category)
│       │   ▓▓▒▒▒▒    │               │
│       └─────────────┘               │
│                                     │
├─────────────────────────────────────┤
│  分类详情                            │  ← Table Title
│  ┌─────────────────────────────┐   │
│  │分类    │ 预算 │ 实际 │ 差额 │   │  ← Table Header (Gray)
│  ├─────────────────────────────┤   │
│  │餐饮 ⇅│1500.00│301.30│-1198.70│  │  ← Row 1 (White bg)
│  │零食 ⇅│ 300.00│ 63.50│ -236.50│  │  ← Row 2 (Light gray bg)
│  │公交地铁⇅│200.00│  6.00│ -194.00│  │  ← Zebra striping
│  │打车 ⇅│ 300.00│ 45.00│ -255.00│  │
│  │电影 ⇅│ 200.00│ 70.00│ -130.00│  │
│  │游戏 ⇅│ 150.00│  0.00│ -150.00│  │
│  │日用品⇅│ 400.00│156.00│ -244.00│  │
│  │服装 ⇅│ 500.00│  0.00│ -500.00│  │
│  ├─────────────────────────────┤   │
│  │合计  │3550.00│641.80│-2908.20│  │  ← Summary Row (Bold)
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘

Legend:
  ⇅ = Chevron icon (indicates editable)
  Bold numbers = Monospaced digits
  Red text = Positive diff (over budget)
  Gray text = Negative diff (under budget)
```

## Budget Editor Sheet

When tapping a category row (e.g., "餐饮"):

```
┌─────────────────────────────────────┐
│  取消                                │  ← Navigation Bar
├─────────────────────────────────────┤
│                                     │
│           餐饮                       │  ← Category Name (Title)
│                                     │
│         预算金额                     │  ← Label
│      ¥1500.00                       │  ← Large Amount Display
│                                     │
│                                     │
│     ⊖                    ⊕          │  ← Plus/Minus Buttons
│   (Red)               (Blue)        │    (Large, 60pt)
│                                     │
│                                     │
│         调整步长                     │  ← Step Label
│   ┌──┐ ┌──┐ ┌──┐ ┌──┐             │
│   │¥5│ │¥10│ │¥50│ │¥100│          │  ← Step Selector
│   └──┘ └──┘ └──┘ └──┘             │    (Blue when selected)
│                ▲                    │
│              Selected               │
│                                     │
│                                     │
│                                     │
│  ┌─────────────────────────────┐   │
│  │          保 存               │   │  ← Save Button (Blue)
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘

Interaction Flow:
1. Tap "-" button → Budget decreases by selected step (¥50)
2. Tap "+" button → Budget increases by selected step (¥50)
3. Tap step button → Changes increment/decrement amount
4. Tap "保存" → Saves and returns to home screen
5. Tap "取消" → Discards changes and returns
```

## Key Design Elements

### Typography
- **Navigation Title**: System Bold, 17pt
- **Month Display**: Headline, 17pt
- **Chart Titles**: Headline, 17pt
- **Table Headers**: Subheadline Semibold, 15pt
- **Table Data**: Body, 17pt, **Monospaced Digits**
- **Summary Row**: Subheadline Bold, 15pt, **Monospaced Digits**
- **Budget Amount (Editor)**: System Rounded Bold, 48pt

### Colors
- **Budget Bars**: Blue (System Blue)
- **Actual Bars**: Orange (System Orange)
- **Plus Button**: Blue fill
- **Minus Button**: Red fill
- **Over Budget (Positive Diff)**: Red text
- **Under Budget (Negative Diff)**: Secondary gray text
- **Selected Step**: Blue background, white text
- **Unselected Step**: Secondary background

### Spacing
- **Padding**: 12-20px between sections
- **Table Cell Padding**: 12px horizontal, 8px vertical
- **Chart Height**: 200pt each
- **Button Size**: 60pt diameter (editor buttons)
- **Step Button**: 60x36pt

### Layout
- **Column Widths**:
  - Category: Flexible (remaining space)
  - Budget: 80pt fixed
  - Actual: 80pt fixed
  - Diff: 80pt fixed

### Interactions
- **Row Tap**: Opens budget editor sheet
- **Modal Presentation**: Bottom sheet with drag handle
- **Button Feedback**: System haptics (optional)
- **Animation**: Smooth transitions (0.3s)

## Responsive Behavior

### Portrait Orientation (Only)
- All elements stack vertically
- Charts are scrollable if needed
- Table is scrollable within its container

### Keyboard (Not applicable in this version)
- No text input in main UI
- Editor uses stepper controls only

### Accessibility
- VoiceOver labels for all buttons
- Semantic headings for sections
- Dynamic Type support
- High contrast mode compatible

## Data Display Rules

### Number Formatting
- Always 2 decimal places: `%.2f`
- Monospaced digit font
- Currency symbol: ¥ (Yuan)
- Thousands separator: Not shown in v1 (can add later)

### Color Coding
```swift
if diff > 0 {
    color = .red      // Over budget
} else {
    color = .secondary // Under/at budget
}
```

### Chart Synchronization
- Charts read from same data source as table
- Updates are immediate (@Published state)
- No delay between editor save and chart update

### Empty States (Not in v1 with demo data)
- Categories with no budget: Show "0.00"
- Categories with no transactions: Show "0.00" actual
- Future: Add empty state views

## Navigation Flow

```
Home Screen (BudgetHomeView)
    │
    ├─→ Tap Category Row
    │   └─→ Budget Editor Sheet (BudgetEditorSheet)
    │       ├─→ Adjust budget
    │       ├─→ Save → Returns to Home (data updated)
    │       └─→ Cancel → Returns to Home (no changes)
    │
    ├─→ Chevron Left (Future: Previous month)
    └─→ Chevron Right (Future: Next month)
```

## Shortcut Integration UI (External)

Not shown in app UI, but configured in iOS Settings:

```
Settings App
  └─→ Accessibility
      └─→ Touch
          └─→ Back Tap
              ├─→ Double Tap: [Record Expense Shortcut]
              └─→ Triple Tap: [Record Expense Shortcut]

Shortcuts App
  └─→ My Shortcuts
      └─→ [Record Expense]
          ├─→ Action: backTap2 - Record Expense
          ├─→ Amount: [Ask Each Time / Set Value]
          ├─→ Type: Expense
          ├─→ Group: 饮食
          ├─→ Category: 餐饮
          └─→ Note: [Optional]
```

## Preview Configuration

SwiftUI Preview setup:
```swift
struct BudgetHomeView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetHomeView()
            .environmentObject(InMemoryStore.preview())
    }
}
```

Preview shows:
- All demo categories
- Sample transactions from past 8 days
- Calculated actuals and diffs
- Fully interactive budget editing
