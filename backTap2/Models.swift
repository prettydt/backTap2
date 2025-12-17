//
//  Models.swift
//  backTap2
//
//  Data models for budget tracking app
//

import Foundation

// MARK: - Enums

enum TransactionType: String, Codable, CaseIterable {
    case expense
    case income
}

// MARK: - Data Models

struct CategoryGroup: Identifiable, Codable {
    let id: UUID
    let name: String
    let order: Int
    
    init(id: UUID = UUID(), name: String, order: Int) {
        self.id = id
        self.name = name
        self.order = order
    }
}

struct Category: Identifiable, Codable {
    let id: UUID
    let groupId: UUID
    let name: String
    let order: Int
    let isActive: Bool
    
    init(id: UUID = UUID(), groupId: UUID, name: String, order: Int, isActive: Bool = true) {
        self.id = id
        self.groupId = groupId
        self.name = name
        self.order = order
        self.isActive = isActive
    }
}

struct Budget: Identifiable, Codable {
    let id: UUID
    let categoryId: UUID
    let month: String // YYYYMM format
    var amount: Double
    
    init(id: UUID = UUID(), categoryId: UUID, month: String, amount: Double) {
        self.id = id
        self.categoryId = categoryId
        self.month = month
        self.amount = amount
    }
}

struct Transaction: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let type: TransactionType
    let groupId: UUID
    let categoryId: UUID
    let note: String?
    let source: String // "shortcut", "manual", etc.
    let createdAt: Date
    let clientId: String
    
    init(id: UUID = UUID(), amount: Double, type: TransactionType, groupId: UUID, categoryId: UUID, note: String? = nil, source: String, createdAt: Date = Date(), clientId: String = UIDevice.current.identifierForVendor?.uuidString ?? "unknown") {
        self.id = id
        self.amount = amount
        self.type = type
        self.groupId = groupId
        self.categoryId = categoryId
        self.note = note
        self.source = source
        self.createdAt = createdAt
        self.clientId = clientId
    }
}

// MARK: - Helper Extensions

extension Date {
    func monthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        return formatter.string(from: self)
    }
    
    static func from(monthString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        return formatter.date(from: monthString)
    }
}

// MARK: - View Models

struct CategoryBudgetRow: Identifiable {
    let id: UUID
    let categoryId: UUID
    let categoryName: String
    let budget: Double
    let actual: Double
    
    var diff: Double {
        actual - budget
    }
}
