//
//  NotaryDashboardView.swift
//  NotoryApp
//
//  Created by Fedor Overchenko
//
//  Полностью переработан для поддержки двух основных функций
//  (Заявки и Профиль) через TabView, используя поиск по ID.

import SwiftUI
import CoreData

// MARK: - 1. Главный контейнер (TabView)

struct NotaryDashboardView: View {
    @EnvironmentObject var vm: AppViewModel
    
    // Получаем ID профиля нотариуса, сохраненный в UserEntity
    private var currentNotaryID: UUID? {
        // !!! ПРОВЕРЬТЕ: Убедитесь, что у вас есть 'notaryID' в UserEntity
        vm.currentUser?.notaryID
    }
    
    var body: some View {
        TabView {
            // MARK: - Вкладка 1: Заявки (Управление приёмами)
            AppointmentsManagementView()
                .tabItem {
                    Label("Заявки", systemImage: "list.bullet.rectangle")
                }
            
            // MARK: - Вкладка 2: Профиль (Редактирование своего NotaryEntity)
            NotaryProfileView(notaryProfileID: currentNotaryID) // Передаем ID
                .tabItem {
                    Label("Профиль", systemImage: "person.text.rectangle")
                }
            
            // MARK: - Вкладка 3: Выход
            Text("Выход")
                .onAppear { vm.logout() }
                .tabItem {
                    Label("Выйти", systemImage: "arrow.right.square")
                }
        }
        .navigationTitle("Кабинет нотариуса")
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - 2. Вспомогательная структура: Логика управления заявками (Без изменений)

struct AppointmentsManagementView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var vm: AppViewModel
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AppointmentEntity.date, ascending: true)]
    ) var allAppointments: FetchedResults<AppointmentEntity>
    
    var pendingAppointments: [AppointmentEntity] {
        allAppointments.filter {
            $0.notaryID == vm.currentUser?.id && $0.status == "pending"
        }
    }
    
    var confirmedAppointments: [AppointmentEntity] {
        allAppointments.filter {
            $0.notaryID == vm.currentUser?.id && $0.status == "confirmed"
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Заявки на подтверждение (\(pendingAppointments.count))")) {
                    if pendingAppointments.isEmpty {
                        Text("Новых заявок нет").foregroundColor(.gray)
                    } else {
                        ForEach(pendingAppointments) { appointment in
                            appointmentRow(appointment, actionText: "Подтвердить") {
                                updateAppointmentStatus(appointment, newStatus: "confirmed")
                            }
                        }
                    }
                }
                
                Section(header: Text("Подтвержденные записи (\(confirmedAppointments.count))")) {
                    ForEach(confirmedAppointments) { appointment in
                        appointmentRow(appointment, actionText: "Завершить") {
                            updateAppointmentStatus(appointment, newStatus: "completed")
                        }
                    }
                }
            }
            .navigationTitle("Заявки на приём")
        }
    }
    
    @ViewBuilder
    private func appointmentRow(_ appointment: AppointmentEntity, actionText: String, action: @escaping () -> Void) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(appointment.date?.formatted(date: .abbreviated, time: .shortened) ?? "Дата не указана")
                    .font(.headline)
                Text("Пользователь ID: \(appointment.userID?.uuidString.prefix(8) ?? "")")
                    .font(.caption).foregroundColor(.gray)
            }
            Spacer()
            Button(actionText) {
                action()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    func updateAppointmentStatus(_ appointment: AppointmentEntity, newStatus: String) {
        appointment.status = newStatus
        if let userId = vm.currentUser?.id {
            vm.logAction(userId: userId, action: "Appointment updated to \(newStatus)")
        }
        try? context.save()
    }
}

// MARK: - 3. Вспомогательная структура: Логика профиля (ИСПРАВЛЕНА НА ПОИСК ПО ID)

struct NotaryProfileView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var isEditingProfile = false
    
    @FetchRequest var notaryProfiles: FetchedResults<NotaryEntity>
    
    init(notaryProfileID: UUID?) {
        var predicate: NSPredicate
        
        if let id = notaryProfileID {
            // Надежный поиск по UUID
            // Используем CVarArg для корректной передачи UUID в NSPredicate
            predicate = NSPredicate(format: "id == %@", id as CVarArg)
        } else {
            // Если ID нет, ищем то, что гарантированно не существует
            predicate = NSPredicate(value: false)
        }

        _notaryProfiles = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \NotaryEntity.fio, ascending: true)],
            predicate: predicate
        )
    }
    
    var body: some View {
        NavigationStack {
            
            let myProfile = notaryProfiles.first
            
            VStack(alignment: .leading, spacing: 20) {
                
                if let profile = myProfile {
                    // MARK: - Отображение данных
                    Text("Информация о нотариусе").font(.title).bold()
                    
                    ProfileDetailRow(title: "ФИО", value: profile.fio)
                    ProfileDetailRow(title: "Адрес", value: profile.address)
                    ProfileDetailRow(title: "Телефон", value: profile.phone)
                    ProfileDetailRow(title: "График работы", value: profile.schedule)

                    Spacer()
                    
                    // MARK: - Кнопка редактирования
                    Button("Редактировать профиль") {
                        isEditingProfile = true
                    }
                    .frame(maxWidth: .infinity)
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)

                } else {
                    // ИСПРАВЛЕНО: Надежное использование ContentUnavailableView с SF Symbol
                    ContentUnavailableView {
                        Label("Профиль нотариуса не найден", systemImage: "person.slash.fill")
                    } description: {
                        Text("Учетная запись нотариуса не связана с профилем в реестре. Обратитесь к администратору для привязки вашего ID.")
                    }
                }
            }
            .padding()
            .navigationTitle("Мой профиль")
            .sheet(isPresented: $isEditingProfile) {
                if let profileToEdit = myProfile {
                    NotaryEditView(notary: profileToEdit)
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                }
            }
        }
    }
}

// Вспомогательная View для красивого отображения данных
fileprivate struct ProfileDetailRow: View {
    let title: String
    let value: String?
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundColor(.gray)
            Text(value ?? "—").font(.body)
            Divider()
        }
    }
}
