//
//  AppViewModel.swift
//  NotoryApp
//
//  Created by Fedor Overchenko
//

import SwiftUI
import CoreData
import Combine

// Перечисление ролей
enum UserRole: String {
    case guest = "guest"
    case user = "user"
    case notary = "notary"
    case admin = "admin"
}

class AppViewModel: ObservableObject {
    @Published var currentUser: UserEntity?
    @Published var currentRole: UserRole = .guest
    @Published var isAuthenticated: Bool = false
    
    // Избранные нотариусы
    @Published var favoriteNotaryIDs: Set<UUID> = []
    
    private let context = PersistenceController.shared.container.viewContext
    
    // Вход в систему (Core Data)
    func login(email: String, pass: String) -> Bool {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@ AND password == %@", email, pass)
        
        do {
            if let user = try context.fetch(request).first {
                self.currentUser = user
                self.currentRole = UserRole(rawValue: user.role ?? "user") ?? .user
                self.isAuthenticated = true
                logAction(userId: user.id!, action: "Login: \(user.role ?? "")")
                return true
            }
        } catch {
            print("Login error: \(error)")
        }
        return false
    }
    
    // Выход
    func logout() {
        if let id = currentUser?.id {
            logAction(userId: id, action: "Logout")
        }
        self.currentUser = nil
        self.currentRole = .guest
        self.isAuthenticated = false
    }
    
    // Логирование действий (LogEntity)
    func logAction(userId: UUID, action: String) {
        let log = LogEntity(context: context)
        log.id = UUID()
        log.userID = userId
        log.action = action
        log.timestamp = Date()
        try? context.save()
    }
    
    // Регистрация обычного пользователя
    func register(email: String, pass: String, name: String) {
        let newUser = UserEntity(context: context)
        newUser.id = UUID()
        newUser.email = email
        newUser.password = pass
        newUser.name = name
        newUser.role = "user"
            
        saveContext()
        // Автоматический вход после регистрации
        self.currentUser = newUser
        self.currentRole = .user
        self.isAuthenticated = true
        logAction(userId: newUser.id!, action: "Register")
        }

    // Сделаем метод видимым для расширений в других файлах
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Save error: \(error)")
        }
    }
    
    // MARK: - Избранное
    func removeFavorite(offsets: IndexSet, from notaries: [NotaryEntity]) {
        guard let user = currentUser else { return }
        
        // 1. Находим объекты, которые нужно удалить
        let objectsToRemove = offsets.map { notaries[$0] }
        
        // 2. Для каждого объекта удаляем его из отношений 'favorites' текущего пользователя
        for notary in objectsToRemove {
            user.removeFromFavorites(notary)
        }
        
        // 3. Сохраняем контекст
        do {
            try PersistenceController.shared.container.viewContext.save()
            // Форсируем обновление UI, так как изменения происходят в Core Data
            objectWillChange.send()
        } catch {
            print("Ошибка при удалении избранного нотариуса: \(error)")
        }
    }
    
    func isFavorite(notary: NotaryEntity) -> Bool {
        guard let user = currentUser else {
            // Если пользователя нет (Гость), избранного быть не может
            return false
        }
        
        let favoriteSet = user.favorites as? Set<NotaryEntity>
        return favoriteSet?.contains(notary) ?? false
    }


    // 2. ФУНКЦИЯ ПЕРЕКЛЮЧЕНИЯ СТАТУСА (ПОЛНАЯ ВЕРСИЯ)
    func toggleFavorite(notary: NotaryEntity) {
        // Пользователь должен быть авторизован, чтобы иметь избранное
        guard let user = currentUser else { return }

        // Используем только что созданную функцию для определения действия
        if isFavorite(notary: notary) {
            // Если в избранном, удаляем
            user.removeFromFavorites(notary)
            print("Удален из избранного: \(notary.fio ?? "N/A")")
        } else {
            // Если не в избранном, добавляем
            user.addToFavorites(notary)
            print("Добавлен в избранное: \(notary.fio ?? "N/A")")
        }
        
        // Сохранение изменений в Core Data
        do {
            try PersistenceController.shared.container.viewContext.save()
            // Важно: уведомляем UI об изменении (например, чтобы обновилась кнопка-сердечко)
            objectWillChange.send()
        } catch {
            print("Ошибка сохранения избранного: \(error)")
        }
    }
}

extension AppViewModel {
    
    func registerUser(name: String, email: String, pass: String) -> Bool {
        // Проверка на дубликат email
        let checkRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        checkRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let existingUsers = try context.fetch(checkRequest)
            if !existingUsers.isEmpty {
                print("Registration error: Email already exists.")
                return false
            }
        } catch {
            print("Database check error: \(error)")
            return false
        }
        
        // Создание нового пользователя
        let newUser = UserEntity(context: context)
        newUser.id = UUID()
        newUser.name = name
        newUser.email = email
        newUser.password = pass 
        newUser.role = "user"
        
        do {
            try context.save()
            logAction(userId: newUser.id!, action: "New user registered")
            return true
        } catch {
            print("Registration save error: \(error)")
            return false
        }
    }
}


extension AppViewModel {
    
    // Логика удаления статей
    func deleteArticle(offsets: IndexSet, articles: FetchedResults<ArticleEntity>) {
        guard currentRole == .admin else { return }
        
        offsets.map { articles[$0] }.forEach(context.delete)
        
        do {
            try context.save()
            print("✅ Статья(и) успешно удалены.")
        } catch {
            print("❌ Ошибка при удалении статьи: \(error)")
        }
    }
}

// MARK: - Удаление нотариусов
extension AppViewModel {
    func deleteNotary(offsets: IndexSet, notaries: FetchedResults<NotaryEntity>) {
        guard currentRole == .admin else { return }
        
        offsets.map { notaries[$0] }.forEach(context.delete)
        
        do {
            try context.save()
            print("✅ Нотариус(ы) успешно удалены.")
        } catch {
            print("❌ Ошибка при удалении нотариуса: \(error)")
        }
    }
}

extension UserRole {
    var localizedName: String {
        switch self {
        case .admin: return "Администратор"
        case .notary: return "Нотариус"
        case .user: return "Пользователь"
        case .guest: return "Гость"
        }
    }
}

