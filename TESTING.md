# Testing Checklist for backTap2

## Build and Run Tests

### Prerequisites
- [ ] Xcode 15.0 or later installed
- [ ] iPhone device or simulator with iOS 16.0+
- [ ] Project opened in Xcode

### Initial Build
- [ ] Project builds without errors (⌘+B)
- [ ] No compiler warnings for critical issues
- [ ] App launches successfully on simulator/device
- [ ] No runtime crashes on launch

## UI/UX Testing

### Home Screen Display
- [ ] Navigation title displays "本月预算"
- [ ] Month selector shows current month in format "YYYY年MM月"
- [ ] Left/right chevrons are visible (functionality TBD)
- [ ] Grouped bar chart displays with Budget and Actual bars
- [ ] Pie chart shows budget distribution by category
- [ ] All 8 demo categories are visible in table
- [ ] Table header shows: 分类 | 预算 | 实际 | 差额
- [ ] Zebra striping alternates between rows (even/odd)
- [ ] Monospaced digits display correctly in all numeric columns
- [ ] Summary row appears at bottom with totals
- [ ] Red text appears for positive diff values (over budget)

### Demo Data Validation
- [ ] Categories display with Chinese names correctly
- [ ] Budget column shows preset values (e.g., 餐饮: 1500.00)
- [ ] Actual column shows computed transaction totals
- [ ] Diff column calculates correctly (Actual - Budget)
- [ ] Summary row totals match column sums

### Budget Editing Flow
- [ ] Tapping any category row opens bottom sheet
- [ ] Bottom sheet displays category name
- [ ] Current budget amount shows in large font
- [ ] Plus (+) and minus (-) buttons are visible and styled
- [ ] Step selector shows 4 options: ¥5, ¥10, ¥50, ¥100
- [ ] Default selected step is ¥50
- [ ] Selected step button is highlighted in blue
- [ ] "保存" (Save) button appears at bottom
- [ ] "取消" (Cancel) button appears in navigation bar

### Budget Editor Interactions
- [ ] Tapping + button increments budget by selected step
- [ ] Tapping - button decrements budget by selected step
- [ ] Budget cannot go below ¥0.00 (validation)
- [ ] Amounts round to 2 decimal places
- [ ] Selecting different step changes increment/decrement amount
- [ ] Budget amount updates live as buttons are pressed
- [ ] Tapping Cancel closes sheet without saving
- [ ] Tapping Save closes sheet and updates budget

### Real-time Updates
- [ ] After saving budget change, table updates immediately
- [ ] Budget column reflects new value
- [ ] Diff column recalculates
- [ ] Summary row totals update
- [ ] Charts update to reflect new budget
- [ ] Grouped bar chart shows updated budget bar
- [ ] Pie chart proportions adjust accordingly

### Data Consistency
- [ ] Multiple budget edits persist during app session
- [ ] Editing different categories works independently
- [ ] Summary calculations remain accurate after multiple edits
- [ ] Charts stay synchronized with table data

## App Intent Testing

### Intent Discovery
- [ ] App appears in Shortcuts app
- [ ] "Record Expense" action is searchable
- [ ] Intent parameters are configurable in Shortcuts

### Intent Parameters
- [ ] Amount parameter accepts numeric input
- [ ] Type parameter shows expense/income options
- [ ] Group parameter accepts text input
- [ ] Category parameter accepts text input
- [ ] Note parameter accepts optional text input

### Intent Execution
- [ ] Running intent from Shortcuts shows success dialog
- [ ] Dialog displays recorded amount and category
- [ ] Intent completes without errors

### Back Tap Integration
- [ ] Shortcut can be assigned to Back Tap in Settings
- [ ] Double/Triple tap triggers shortcut
- [ ] Intent executes when triggered via Back Tap

**Note**: Full integration testing with actual data persistence requires Core Data implementation.

## Performance Testing

### Responsiveness
- [ ] UI animations are smooth (60fps)
- [ ] No lag when opening budget editor sheet
- [ ] Chart rendering is performant
- [ ] Table scrolling is smooth
- [ ] Button presses respond immediately

### Memory
- [ ] No memory leaks during budget editing
- [ ] App memory usage is reasonable
- [ ] No warnings in Xcode memory debugger

## Accessibility Testing

### VoiceOver
- [ ] All buttons have proper labels
- [ ] Table rows are navigable
- [ ] Budget values are announced correctly
- [ ] Chart data is accessible

### Dynamic Type
- [ ] Text scales appropriately with system font size
- [ ] Layout doesn't break with larger text
- [ ] Monospaced digits remain aligned

### Orientation
- [ ] App locks to portrait orientation
- [ ] No crashes when device rotates
- [ ] Layout maintains proper constraints

## Edge Cases

### Budget Validation
- [ ] Cannot set negative budget
- [ ] Large budget amounts (>999999) display correctly
- [ ] Zero budget amount is allowed
- [ ] Decimal precision maintains 2 places

### Data Edge Cases
- [ ] Categories with no transactions show ¥0.00 actual
- [ ] Categories with no budget show ¥0.00 budget
- [ ] Empty month shows all zeros
- [ ] Summary row handles zero values

### UI Edge Cases
- [ ] Long category names don't overflow
- [ ] Very large amounts fit in table cells
- [ ] Chart handles zero values gracefully
- [ ] Pie chart works with single category

## Known Limitations (v1 MVP)

- ⚠️ Data persists only during app session (in-memory)
- ⚠️ App Intent doesn't actually add to visible transactions (needs shared store)
- ⚠️ Month navigation is placeholder only
- ⚠️ No transaction history view
- ⚠️ No category customization
- ⚠️ No data export

## Acceptance Criteria Summary

✅ **PASS**: App builds on Xcode 15+ and runs on iOS 16+ iPhone simulator
✅ **PASS**: Home screen shows charts and table with seeded demo data
✅ **PASS**: Budget editing via Stepper sheet updates table/charts immediately
✅ **PASS**: Changes persist in-memory during app session
⚠️ **PARTIAL**: RecordExpenseIntent runs but doesn't affect visible data (needs shared store implementation)

## Next Steps for Production

1. Implement Core Data persistence
2. Create shared app group for Shortcuts extension
3. Wire RecordExpenseIntent to persistent store
4. Add unit tests for Store protocol implementations
5. Add UI tests for critical flows
6. Implement month navigation
7. Add transaction history view
8. Localization for multiple languages
