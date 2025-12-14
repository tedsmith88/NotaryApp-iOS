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
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "person.badge.plus").foregroundColor(Theme.accentStart)
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
        withAnimation {
            offsets.map { notaries[$0] }.forEach { notary in
                context.delete(notary)
            }
            try? context.save()
            vm.logAction(userId: vm.currentUser!.id!, action: "Deleted notary")
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
        // 1. Создаем сущность нотариуса (инфо)
        let newNotaryInfo = NotaryEntity(context: context)
        let notaryID = UUID()
        newNotaryInfo.id = notaryID
        newNotaryInfo.fio = fio
        newNotaryInfo.region = region
        newNotaryInfo.address = address
        newNotaryInfo.specialization = specialization
        
        // 2. Создаем сущность пользователя (для входа в систему)
        let newNotaryUser = UserEntity(context: context)
        newNotaryUser.id = notaryID // Связываем
        newNotaryUser.name = fio
        newNotaryUser.email = "\(fio.replacingOccurrences(of: " ", with: "."))@notary.ru" // Генерируем email
        newNotaryUser.password = "123456" // Пароль по умолчанию
        newNotaryUser.role = "notary"
        
        try? context.save()
        vm.logAction(userId: vm.currentUser!.id!, action: "Added new notary: \(fio)")
        dismiss()
    }
}
