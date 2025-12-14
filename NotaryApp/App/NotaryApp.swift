//
//  NotaryApp.swift
//  NotoryApp
//
//  Created by Fedor Overchenko
//

import SwiftUI
import CoreData

@main
struct NotaryApp: App {
    // Инициализация Core Data (SQLite)
    let persistenceController = PersistenceController.shared
    // Инициализация глобального состояния MVVM
    @StateObject var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Передача контекста Core Data в окружение
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                // Передача AppViewModel в окружение
                .environmentObject(appViewModel)
        }
    }
}
