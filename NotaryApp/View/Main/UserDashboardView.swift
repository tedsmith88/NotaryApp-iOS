//
//  UserDashboardView.swift
//  NotoryApp
//
//  Created by Fedor Overchenko
//

import SwiftUI

struct UserDashboardView: View {
    
    var body: some View {
        TabView {
            // 1. Главный Реестр (Поиск и просмотр)
            NavigationStack {
                NotaryListView()
            }
            .tabItem { Label("Реестр", systemImage: "list.bullet") }
            
            // 2. ВКЛАДКА: Карта Нотариатов
            MapView()
                .tabItem { Label("На карте", systemImage: "map.fill") }
            
            // 3. ВКЛАДКА: Избранные нотариусы
            FavoriteNotariesView()
                .tabItem { Label("Избранное", systemImage: "heart.fill") }
            
            // 4. Мои Записи
            MyAppointmentsView()
                .tabItem { Label("Мои записи", systemImage: "calendar") }
            
            // 5. ВКЛАДКА: Статьи и Инструкции
            ArticlesView()
                .tabItem { Label("Статьи и Инструкции", systemImage: "book.closed.fill") }
                
            // 6. Профиль
            ProfileView()
                .tabItem { Label("Профиль", systemImage: "person.crop.circle") }
        }
    }
}

// Список записей пользователя
struct MyAppointmentsView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.managedObjectContext) var context
    
    // Получаем записи текущего пользователя
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \AppointmentEntity.date, ascending: true)])
    var appointments: FetchedResults<AppointmentEntity>
    
    var body: some View {
        NavigationStack {
            List {
                // Фильтруем записи по ID текущего пользователя
                ForEach(appointments.filter { $0.userID == vm.currentUser?.id }) { app in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Запись на: \(app.date?.formatted(date: .abbreviated, time: .shortened) ?? "")")
                                .font(.headline)
                            Text("К нотариусу ID: \(app.notaryID?.uuidString.prefix(8) ?? "")")
                                .font(.caption).foregroundColor(.gray)
                        }
                        Spacer()
                        Text(app.status ?? "pending")
                            .foregroundColor(app.status == "confirmed" ? .green : .orange)
                    }
                }
            }
            .navigationTitle("Моя история записей")
            .background(Theme.background)
        }
    }
}

