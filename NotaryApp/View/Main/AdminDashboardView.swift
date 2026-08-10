//
//  AdminDashboardView.swift
//  NotoryApp
//
//  Created by Fedor Overchenko
//

import SwiftUI
import CoreData

struct AdminDashboardView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.managedObjectContext) var context
    @State private var showAddSheet = false
    
    // Получаем всех нотариусов
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \NotaryEntity.fio, ascending: true)])
    var notaries: FetchedResults<NotaryEntity>
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(notaries) { notary in
                    VStack(alignment: .leading) {
                        Text(notary.fio ?? "Нотариус без ФИО").bold()
                        Text(notary.region ?? "").font(.caption).foregroundColor(.gray)
                    }
                }
                // Возможность удаления нотариуса
                .onDelete(perform: deleteNotary)
            }
            .navigationTitle("Управление (Админ)")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 15) {
                        // Кнопка Edit/Done для активации режима удаления
                        EditButton()
                        
                        // Кнопка добавления нового нотариуса
                        Button(action: { showAddSheet = true }) {
                            Image(systemName: "person.badge.plus")
                                .foregroundColor(Theme.accentStart)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Выйти") { vm.logout() }
                }
            }
            // Форма добавления/редактирования
            .sheet(isPresented: $showAddSheet) {
                AddNotaryView()
            }
        }
    }
    
    func deleteNotary(offsets: IndexSet) {
        guard let userId = vm.currentUser?.id else {
            print("❌ Ошибка: Текущий пользователь не найден")
            return
        }
        
        withAnimation {
            offsets.map { notaries[$0] }.forEach { notary in
                guard let notaryID = notary.id else {
                    print("⚠️ Пропуск нотариуса без ID")
                    return
                }
                
                print("🗑️ Начало удаления нотариуса: \(notary.fio ?? "N/A") (ID: \(notaryID.uuidString.prefix(8)))")
                
                // 1. Удаляем все связанные заявки (AppointmentEntity)
                let appointmentFetchRequest: NSFetchRequest<AppointmentEntity> = AppointmentEntity.fetchRequest()
                appointmentFetchRequest.predicate = NSPredicate(format: "notaryID == %@", notaryID as CVarArg)
                
                if let relatedAppointments = try? context.fetch(appointmentFetchRequest) {
                    print("   📋 Найдено заявок: \(relatedAppointments.count)")
                    relatedAppointments.forEach { appointment in
                        print("   🗑️ Удаление заявки: \(appointment.id?.uuidString.prefix(8) ?? "N/A")")
                        context.delete(appointment)
                    }
                } else {
                    print("   ℹ️ Связанных заявок не найдено")
                }
                
                // 2. Удаляем связанные записи из избранного
                let favoriteFetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
                favoriteFetchRequest.predicate = NSPredicate(format: "ANY favorites.id == %@", notaryID as CVarArg)
                
                if let favoriteUsers = try? context.fetch(favoriteFetchRequest) {
                    print("   ⭐ Найдено пользователей с этим нотариусом в избранном: \(favoriteUsers.count)")
                    favoriteUsers.forEach { user in
                        user.removeFromFavorites(notary)
                        print("   🗑️ Удален из избранного пользователя: \(user.email ?? "N/A")")
                    }
                }
                
                // 3. Удаляем связанного пользователя (UserEntity)
                let userFetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
                userFetchRequest.predicate = NSPredicate(format: "id == %@ OR notaryID == %@", 
                                                        notaryID as CVarArg, 
                                                        notaryID as CVarArg)
                
                if let relatedUsers = try? context.fetch(userFetchRequest) {
                    print("   👤 Найдено связанных UserEntity: \(relatedUsers.count)")
                    relatedUsers.forEach { user in
                        print("   🗑️ Удаление UserEntity: \(user.email ?? "N/A")")
                        context.delete(user)
                    }
                } else {
                    print("   ℹ️ Связанных UserEntity не найдено")
                }
                
                // 4. Удаляем самого нотариуса
                print("   🗑️ Удаление NotaryEntity: \(notary.fio ?? "N/A")")
                context.delete(notary)
            }
            
            // Сохраняем изменения
            do {
                try context.save()
                vm.logAction(userId: userId, action: "Deleted \(offsets.count) notary/notaries")
                print("✅ Успешно удалено нотариусов: \(offsets.count)")
            } catch let error as NSError {
                print("❌ Ошибка при удалении: \(error.localizedDescription)")
                print("   Детали: \(error.userInfo)")
                
                // Откатываем изменения
                context.rollback()
                print("⚠️ Изменения отменены (rollback)")
            }
        }
    }
}

// Форма добавления/редактирования нотариуса
struct AddNotaryView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel
    
    @State private var fio = ""
    @State private var region = ""
    @State private var address = ""
    @State private var specialization = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Личные данные")) {
                    TextField("ФИО", text: $fio)
                    TextField("Специализация", text: $specialization)
                }
                Section(header: Text("Контактные данные")) {
                    TextField("Регион/Город", text: $region)
                    TextField("Адрес конторы", text: $address)
                }
            }
            .navigationTitle("Добавить нотариуса")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить", action: saveNotary)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }
    
    func saveNotary() {
        // Генерируем единый ID для нотариуса
        let sharedID = UUID()
        
        // 1. Создаем сущность нотариуса (инфо)
        let newNotaryInfo = NotaryEntity(context: context)
        newNotaryInfo.id = sharedID // Используем общий ID
        newNotaryInfo.fio = fio
        newNotaryInfo.region = region
        newNotaryInfo.address = address
        newNotaryInfo.specialization = specialization
        
        // 2. Создаем сущность пользователя (для входа в систему)
        let newNotaryUser = UserEntity(context: context)
        newNotaryUser.id = sharedID // Используем тот же ID!
        newNotaryUser.name = fio
        newNotaryUser.email = "\(fio.replacingOccurrences(of: " ", with: "."))@notary.ru"
        newNotaryUser.password = "123456" // Пароль по умолчанию
        newNotaryUser.role = "notary"
        newNotaryUser.notaryID = sharedID // Связываем с профилем
        
        do {
            try context.save()
            vm.logAction(userId: vm.currentUser!.id!, action: "Added new notary: \(fio)")
            print("✅ Нотариус добавлен с общим ID: \(sharedID.uuidString.prefix(8))")
            dismiss()
        } catch {
            print("❌ Ошибка при сохранении нотариуса: \(error.localizedDescription)")
        }
    }
}
