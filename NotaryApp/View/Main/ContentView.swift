//
//  ContentView.swift
//  NotoryApp
//
//  Created by Fedor Overchenko
//

import SwiftUI

// Определяем перечисление для вкладок Гостя
private enum GuestTab {
    case registry
    case map
    case logout
}

struct ContentView: View {
    @EnvironmentObject var vm: AppViewModel
    
    // Переменная для отслеживания выбранной вкладки Гостя
    @State private var selectedGuestTab: GuestTab = .registry // Начинаем с реестра
    
    var body: some View {
        Group {
            if vm.isAuthenticated {
                switch vm.currentRole {
                case .admin:
                    TabView {
                        NavigationStack {
                            NotaryListView()
                        }
                        .tabItem { Label("Реестр", systemImage: "list.bullet.clipboard") }
                        
                        NavigationStack {
                            ArticlesView()
                        }
                        .tabItem {
                            Image(systemName: "doc.text.fill")
                            Text("Инструкции")
                        }
                        
                        NavigationStack {
                            ProfileView()
                        }
                        .tabItem {
                            Label("Профиль", systemImage: "person.circle.fill")
                        }
                    }

                case .notary:
                    NotaryDashboardView()
                case .user:
                    UserDashboardView()
                    
                case .guest:
                    TabView(selection: $selectedGuestTab) {
                        NavigationStack {
                            NotaryListView()
                        }
                        .tag(GuestTab.registry) // Присваиваем тег
                        .tabItem { Label("Реестр", systemImage: "list.bullet") }
                        
                        MapView()
                            .tag(GuestTab.map) // Присваиваем тег
                            .tabItem { Label("На карте", systemImage: "map.fill") }
                        
                        // Используем пустой или "прозрачный" View для вкладки "Выход"
                        Color.clear
                            .tag(GuestTab.logout) // Присваиваем тег
                            .tabItem {
                                Label("Выход", systemImage: "arrow.left.circle.fill")
                            }
                    }
                    // Перехватываем изменение выбранной вкладки
                    .onChange(of: selectedGuestTab) { oldValue, newValue in
                        if newValue == .logout {
                            // !!! МГНОВЕННО ВЫПОЛНЯЕМ ВЫХОД, как только выбрана вкладка !!!
                            vm.isAuthenticated = false
                            vm.currentUser = nil
                            vm.currentRole = .guest
                        }
                    }
                    
                default:
                    LoginView()
                }
            } else {
                LoginView()
            }
        }
        .environmentObject(vm)
    }
}
