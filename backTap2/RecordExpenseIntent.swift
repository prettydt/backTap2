//
//  RecordExpenseIntent.swift
//  backTap2
//
//  App Intent for quick expense logging via Shortcuts
//

import Foundation
import AppIntents

struct RecordExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Record Expense"
    static var description = IntentDescription("Quickly log an expense or income transaction")
    
    @Parameter(title: "Amount")
    var amount: Double
    
    @Parameter(title: "Type", default: .expense)
    var type: TransactionTypeEnum
    
    @Parameter(title: "Group")
    var group: String
    
    @Parameter(title: "Category")
    var category: String
    
    @Parameter(title: "Note")
    var note: String?
    
    func perform() async throws -> some IntentResult {
        // In a production app, this would access the shared store
        // For now, we'll simulate the operation
        
        // Create a transaction
        let transaction = Transaction(
            amount: amount,
            type: type == .expense ? .expense : .income,
            groupId: UUID(), // In production, lookup by group name
            categoryId: UUID(), // In production, lookup by category name
            note: note,
            source: "shortcut",
            createdAt: Date()
        )
        
        // In production: StoreManager.shared.addTransaction(transaction)
        // For this MVP, the store is injected via SwiftUI environment
        // and accessed by views. For shortcuts to work properly, you would need
        // a shared singleton or app group container to persist data.
        
        return .result(dialog: "Recorded \(type == .expense ? "expense" : "income") of ¥\(String(format: "%.2f", amount)) for \(category)")
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Record \(\.$type) of ¥\(\.$amount) for \(\.$category)") {
            \.$group
            \.$note
        }
    }
}

// Transaction type enum for App Intents
enum TransactionTypeEnum: String, AppEnum {
    case expense
    case income
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Transaction Type"
    
    static var caseDisplayRepresentations: [TransactionTypeEnum: DisplayRepresentation] = [
        .expense: "Expense",
        .income: "Income"
    ]
}

// App Intents provider
struct BackTapShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: RecordExpenseIntent(),
            phrases: [
                "Record an expense in \(.applicationName)",
                "Log expense with \(.applicationName)",
                "Add transaction to \(.applicationName)"
            ],
            shortTitle: "Record Expense",
            systemImageName: "dollarsign.circle"
        )
    }
}
