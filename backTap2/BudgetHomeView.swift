//
//  BudgetHomeView.swift
//  backTap2
//
//  Main budget screen with charts and Numbers-style table
//

import SwiftUI
import Charts

struct BudgetHomeView: View {
    @EnvironmentObject var store: InMemoryStore
    @State private var selectedCategory: CategoryBudgetRow?
    @State private var showBudgetEditor = false
    @State private var currentMonth: String = Date().monthString()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Month selector placeholder
                    monthSelector
                    
                    // Charts section
                    chartsSection
                    
                    // Budget table
                    budgetTable
                }
                .padding()
            }
            .navigationTitle("本月预算")
            .sheet(isPresented: $showBudgetEditor) {
                if let category = selectedCategory {
                    BudgetEditorSheet(
                        categoryRow: category,
                        currentMonth: currentMonth,
                        isPresented: $showBudgetEditor
                    )
                    .environmentObject(store)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: - Month Selector
    
    private var monthSelector: some View {
        HStack {
            Button(action: {
                // TODO: Navigate to previous month
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatMonthString(currentMonth))
                .font(.headline)
            
            Spacer()
            
            Button(action: {
                // TODO: Navigate to next month
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Charts Section
    
    private var chartsSection: some View {
        VStack(spacing: 16) {
            // Grouped Bar Chart: Budget vs Actual
            groupedBarChart
            
            // Pie Chart: Budget distribution
            pieChart
        }
    }
    
    private var groupedBarChart: some View {
        VStack(alignment: .leading) {
            Text("预算 vs 实际")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(budgetRows) { row in
                    BarMark(
                        x: .value("Category", row.categoryName),
                        y: .value("Amount", row.budget)
                    )
                    .foregroundStyle(Color.blue)
                    .position(by: .value("Type", "预算"))
                    
                    BarMark(
                        x: .value("Category", row.categoryName),
                        y: .value("Amount", row.actual)
                    )
                    .foregroundStyle(Color.orange)
                    .position(by: .value("Type", "实际"))
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel(orientation: .vertical)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var pieChart: some View {
        VStack(alignment: .leading) {
            Text("预算分布")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(budgetRows) { row in
                    SectorMark(
                        angle: .value("Budget", row.budget),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("Category", row.categoryName))
                }
            }
            .frame(height: 200)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Budget Table
    
    private var budgetTable: some View {
        VStack(spacing: 0) {
            Text("分类详情")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 8)
            
            // Header
            tableHeader
            
            // Rows
            ForEach(Array(budgetRows.enumerated()), id: \.element.id) { index, row in
                tableRow(row: row, isEven: index % 2 == 0)
            }
            
            // Summary row
            summaryRow
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(UIColor.separator), lineWidth: 1)
        )
    }
    
    private var tableHeader: some View {
        HStack(spacing: 0) {
            Text("分类")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.subheadline.weight(.semibold))
            
            Text("预算")
                .frame(width: 80, alignment: .trailing)
                .font(.subheadline.weight(.semibold))
            
            Text("实际")
                .frame(width: 80, alignment: .trailing)
                .font(.subheadline.weight(.semibold))
            
            Text("差额")
                .frame(width: 80, alignment: .trailing)
                .font(.subheadline.weight(.semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    private func tableRow(row: CategoryBudgetRow, isEven: Bool) -> some View {
        Button(action: {
            selectedCategory = row
            showBudgetEditor = true
        }) {
            HStack(spacing: 0) {
                HStack {
                    Text(row.categoryName)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(String(format: "%.2f", row.budget))
                    .frame(width: 80, alignment: .trailing)
                    .monospacedDigit()
                    .foregroundColor(.primary)
                
                Text(String(format: "%.2f", row.actual))
                    .frame(width: 80, alignment: .trailing)
                    .monospacedDigit()
                    .foregroundColor(.primary)
                
                Text(String(format: "%.2f", row.diff))
                    .frame(width: 80, alignment: .trailing)
                    .monospacedDigit()
                    .foregroundColor(row.diff > 0 ? .red : .secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isEven ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground).opacity(0.3))
        }
        .buttonStyle(.plain)
    }
    
    private var summaryRow: some View {
        HStack(spacing: 0) {
            Text("合计")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.subheadline.weight(.bold))
            
            Text(String(format: "%.2f", totalBudget))
                .frame(width: 80, alignment: .trailing)
                .monospacedDigit()
                .font(.subheadline.weight(.bold))
            
            Text(String(format: "%.2f", totalActual))
                .frame(width: 80, alignment: .trailing)
                .monospacedDigit()
                .font(.subheadline.weight(.bold))
            
            Text(String(format: "%.2f", totalDiff))
                .frame(width: 80, alignment: .trailing)
                .monospacedDigit()
                .font(.subheadline.weight(.bold))
                .foregroundColor(totalDiff > 0 ? .red : .secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(UIColor.tertiarySystemBackground))
    }
    
    // MARK: - Computed Properties
    
    private var budgetRows: [CategoryBudgetRow] {
        store.categories
            .filter { $0.isActive }
            .sorted { $0.order < $1.order }
            .map { category in
                let budget = store.budgets.first(where: { $0.categoryId == category.id && $0.month == currentMonth })?.amount ?? 0.0
                let actual = store.actual(for: category.id, in: currentMonth)
                
                return CategoryBudgetRow(
                    id: category.id,
                    categoryId: category.id,
                    categoryName: category.name,
                    budget: budget,
                    actual: actual
                )
            }
    }
    
    private var totalBudget: Double {
        budgetRows.reduce(0) { $0 + $1.budget }
    }
    
    private var totalActual: Double {
        budgetRows.reduce(0) { $0 + $1.actual }
    }
    
    private var totalDiff: Double {
        totalActual - totalBudget
    }
    
    private func formatMonthString(_ monthString: String) -> String {
        guard let date = Date.from(monthString: monthString) else {
            return monthString
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter.string(from: date)
    }
}

// MARK: - Budget Editor Sheet

struct BudgetEditorSheet: View {
    let categoryRow: CategoryBudgetRow
    let currentMonth: String
    @Binding var isPresented: Bool
    @EnvironmentObject var store: InMemoryStore
    
    @State private var budgetAmount: Double
    @State private var selectedStep: Double = 50.0
    
    let stepOptions: [Double] = [5, 10, 50, 100]
    
    init(categoryRow: CategoryBudgetRow, currentMonth: String, isPresented: Binding<Bool>) {
        self.categoryRow = categoryRow
        self.currentMonth = currentMonth
        self._isPresented = isPresented
        self._budgetAmount = State(initialValue: categoryRow.budget)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Category name
                Text(categoryRow.categoryName)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                // Current budget display
                VStack(spacing: 8) {
                    Text("预算金额")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("¥\(String(format: "%.2f", budgetAmount))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
                .padding()
                
                // Stepper controls
                HStack(spacing: 40) {
                    Button(action: {
                        decrementBudget()
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        incrementBudget()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                
                // Step selector
                VStack(spacing: 12) {
                    Text("调整步长")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        ForEach(stepOptions, id: \.self) { step in
                            Button(action: {
                                selectedStep = step
                            }) {
                                Text("¥\(Int(step))")
                                    .font(.subheadline)
                                    .fontWeight(selectedStep == step ? .bold : .regular)
                                    .foregroundColor(selectedStep == step ? .white : .primary)
                                    .frame(width: 60, height: 36)
                                    .background(selectedStep == step ? Color.blue : Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Save button
                Button(action: {
                    saveBudget()
                }) {
                    Text("保存")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func incrementBudget() {
        budgetAmount += selectedStep
        budgetAmount = round(budgetAmount * 100) / 100
    }
    
    private func decrementBudget() {
        budgetAmount = max(0, budgetAmount - selectedStep)
        budgetAmount = round(budgetAmount * 100) / 100
    }
    
    private func saveBudget() {
        store.updateBudget(categoryId: categoryRow.categoryId, month: currentMonth, amount: budgetAmount)
        isPresented = false
    }
}

// MARK: - Previews

struct BudgetHomeView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetHomeView()
            .environmentObject(InMemoryStore.preview())
    }
}
