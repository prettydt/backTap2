//
//  backTap2App.swift
//  backTap2
//
//  Main app entry point
//

import SwiftUI

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
