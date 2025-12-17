//
//  Store.swift
//  backTap2
//
//  Store protocol and in-memory implementation
//

import Foundation

// MARK: - Store Protocol

protocol Store: ObservableObject {
    var groups: [CategoryGroup] { get }
    var categories: [Category] { get }
    var budgets: [Budget] { get }
    var transactions: [Transaction] { get }
    
    func addTransaction(_ transaction: Transaction)
    func updateBudget(categoryId: UUID, month: String, amount: Double)
    func actual(for categoryId: UUID, in month: String) -> Double
}

// MARK: - InMemoryStore

class InMemoryStore: Store, ObservableObject {
    @Published var groups: [CategoryGroup]
    @Published var categories: [Category]
    @Published var budgets: [Budget]
    @Published var transactions: [Transaction]
    
    init(groups: [CategoryGroup] = [], categories: [Category] = [], budgets: [Budget] = [], transactions: [Transaction] = []) {
        self.groups = groups
        self.categories = categories
        self.budgets = budgets
        self.transactions = transactions
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
    }
    
    func updateBudget(categoryId: UUID, month: String, amount: Double) {
        if let index = budgets.firstIndex(where: { $0.categoryId == categoryId && $0.month == month }) {
            budgets[index].amount = amount
        } else {
            let newBudget = Budget(categoryId: categoryId, month: month, amount: amount)
            budgets.append(newBudget)
        }
    }
    
    func actual(for categoryId: UUID, in month: String) -> Double {
        transactions
            .filter { $0.categoryId == categoryId && $0.type == .expense && $0.createdAt.monthString() == month }
            .reduce(0.0) { $0 + $1.amount }
    }
    
    // MARK: - Preview/Demo Data
    
    static func preview() -> InMemoryStore {
        let currentMonth = Date().monthString()
        
        // Create groups
        let foodGroup = CategoryGroup(name: "饮食", order: 0)
        let transportGroup = CategoryGroup(name: "交通", order: 1)
        let entertainmentGroup = CategoryGroup(name: "娱乐", order: 2)
        let lifeGroup = CategoryGroup(name: "生活", order: 3)
        
        let groups = [foodGroup, transportGroup, entertainmentGroup, lifeGroup]
        
        // Create categories
        let categories = [
            Category(groupId: foodGroup.id, name: "餐饮", order: 0),
            Category(groupId: foodGroup.id, name: "零食", order: 1),
            Category(groupId: transportGroup.id, name: "公交地铁", order: 2),
            Category(groupId: transportGroup.id, name: "打车", order: 3),
            Category(groupId: entertainmentGroup.id, name: "电影", order: 4),
            Category(groupId: entertainmentGroup.id, name: "游戏", order: 5),
            Category(groupId: lifeGroup.id, name: "日用品", order: 6),
            Category(groupId: lifeGroup.id, name: "服装", order: 7)
        ]
        
        // Create budgets for current month
        let budgets = [
            Budget(categoryId: categories[0].id, month: currentMonth, amount: 1500.00),
            Budget(categoryId: categories[1].id, month: currentMonth, amount: 300.00),
            Budget(categoryId: categories[2].id, month: currentMonth, amount: 200.00),
            Budget(categoryId: categories[3].id, month: currentMonth, amount: 300.00),
            Budget(categoryId: categories[4].id, month: currentMonth, amount: 200.00),
            Budget(categoryId: categories[5].id, month: currentMonth, amount: 150.00),
            Budget(categoryId: categories[6].id, month: currentMonth, amount: 400.00),
            Budget(categoryId: categories[7].id, month: currentMonth, amount: 500.00)
        ]
        
        // Create some sample transactions
        let calendar = Calendar.current
        let now = Date()
        
        let transactions = [
            // Dining expenses
            Transaction(amount: 85.50, type: .expense, groupId: foodGroup.id, categoryId: categories[0].id, note: "午餐", source: "manual", createdAt: calendar.date(byAdding: .day, value: -5, to: now)!),
            Transaction(amount: 120.00, type: .expense, groupId: foodGroup.id, categoryId: categories[0].id, note: "晚餐", source: "manual", createdAt: calendar.date(byAdding: .day, value: -3, to: now)!),
            Transaction(amount: 95.80, type: .expense, groupId: foodGroup.id, categoryId: categories[0].id, note: "工作餐", source: "shortcut", createdAt: calendar.date(byAdding: .day, value: -1, to: now)!),
            
            // Snacks
            Transaction(amount: 35.00, type: .expense, groupId: foodGroup.id, categoryId: categories[1].id, note: "咖啡", source: "manual", createdAt: calendar.date(byAdding: .day, value: -4, to: now)!),
            Transaction(amount: 28.50, type: .expense, groupId: foodGroup.id, categoryId: categories[1].id, note: "水果", source: "shortcut", createdAt: calendar.date(byAdding: .day, value: -2, to: now)!),
            
            // Transport
            Transaction(amount: 6.00, type: .expense, groupId: transportGroup.id, categoryId: categories[2].id, note: "地铁", source: "shortcut", createdAt: calendar.date(byAdding: .day, value: -6, to: now)!),
            Transaction(amount: 45.00, type: .expense, groupId: transportGroup.id, categoryId: categories[3].id, note: "打车回家", source: "manual", createdAt: calendar.date(byAdding: .day, value: -2, to: now)!),
            
            // Entertainment
            Transaction(amount: 70.00, type: .expense, groupId: entertainmentGroup.id, categoryId: categories[4].id, note: "电影票", source: "manual", createdAt: calendar.date(byAdding: .day, value: -7, to: now)!),
            
            // Daily necessities
            Transaction(amount: 156.00, type: .expense, groupId: lifeGroup.id, categoryId: categories[6].id, note: "洗漱用品", source: "manual", createdAt: calendar.date(byAdding: .day, value: -8, to: now)!)
        ]
        
        return InMemoryStore(groups: groups, categories: categories, budgets: budgets, transactions: transactions)
    }
}

// MARK: - CoreDataStore Placeholder

// This is a placeholder for future Core Data implementation
// The Store protocol provides the abstraction layer to swap implementations

/*
class CoreDataStore: Store, ObservableObject {
    // TODO: Implement Core Data stack
    // - NSPersistentContainer
    // - Fetch requests for groups, categories, budgets, transactions
    // - Create, update, delete operations
    // - Migration from InMemoryStore if needed
    
    @Published var groups: [CategoryGroup] = []
    @Published var categories: [Category] = []
    @Published var budgets: [Budget] = []
    @Published var transactions: [Transaction] = []
    
    func addTransaction(_ transaction: Transaction) {
        // TODO: Save to Core Data
    }
    
    func updateBudget(categoryId: UUID, month: String, amount: Double) {
        // TODO: Update in Core Data
    }
    
    func actual(for categoryId: UUID, in month: String) -> Double {
        // TODO: Fetch and compute from Core Data
        return 0.0
    }
}
*/
