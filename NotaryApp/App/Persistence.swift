//
//  Persistence.swift
//  NotoryApp
//
//  Created by Fedor Overchenko
//

import CoreData
import Foundation

// MARK: - Вспомогательные структуры для декодирования JSON

// Структура для декодирования данных нотариусов
struct NotaryData: Decodable {
    let id: String
    let fio: String
    let region: String
    let address: String
    let specialization: String
    let schedule: String
    let phone: String
    let latitude: Double
    let longitude: Double
}

// Структура для декодирования статей
struct ArticleData: Decodable {
    let title: String
    let content: String
    let date: String // Предполагаем, что дата приходит в виде строки
}

// MARK: - Главный класс PersistenceController

final class PersistenceController {
    
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Убедитесь, что имя контейнера соответствует вашему проекту
        container = NSPersistentContainer(name: "NotaryApp")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // ВАЖНО: Асинхронная загрузка хранилища.
        // Seeding должен происходить только после успешной загрузки.
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Неразрешимая ошибка при загрузке: \(error), \(error.userInfo)")
            }
            
            // --- КЛЮЧЕВОЕ ИСПРАВЛЕНИЕ: ПОРЯДОК SEEDING ВЫЗВАН ПОСЛЕ ЗАГРУЗКИ ---
            if !inMemory {
                // 1. Загружаем NotaryEntity
                self.createInitialNotaries()
                
                // 2. Загружаем статьи
                self.createInitialArticles()

                // 3. Создаем UserEntity
                self.createInitialUsers()
            }
            
            // Устанавливаем merge policy для предотвращения конфликтов
            self.container.viewContext.automaticallyMergesChangesFromParent = true
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }
    }
    
    // MARK: - Сохранение контекста

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Неразрешимая ошибка при сохранении: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // MARK: - Seeding (Начальное заполнение данных)

    private func createInitialNotaries() {
        // Используем performAndWait для синхронной работы с контекстом
        container.viewContext.performAndWait {
            let context = container.viewContext
            let fetchRequest: NSFetchRequest<NotaryEntity> = NotaryEntity.fetchRequest()

            if (try? context.count(for: fetchRequest)) == 0 {
                do {
                    guard let url = Bundle.main.url(forResource: "notaries", withExtension: "json"),
                          let data = try? Data(contentsOf: url),
                          let notaryData = try? JSONDecoder().decode([NotaryData].self, from: data) else {
                        print("❌ Ошибка: Не удалось загрузить или декодировать notaries.json.")
                        return
                    }
                    
                    for data in notaryData {
                        let notary = NotaryEntity(context: context)
                        notary.id = UUID(uuidString: data.id) ?? UUID()
                        notary.fio = data.fio
                        notary.region = data.region
                        notary.address = data.address
                        notary.specialization = data.specialization
                        notary.schedule = data.schedule
                        notary.phone = data.phone
                        notary.latitude = data.latitude
                        notary.longitude = data.longitude
                    }
                    
                    try context.save()
                    print("✅ \(notaryData.count) NotaryEntity успешно загружены из JSON.")
                    
                } catch {
                    print("❌ Ошибка сеяния NotaryEntity: \(error.localizedDescription)")
                }
            } else {
                print("ℹ️ NotaryEntity уже существуют в базе данных.")
            }
        }
    }

    private func createInitialArticles() {
        container.viewContext.performAndWait {
            let context = container.viewContext
            let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()

            if (try? context.count(for: fetchRequest)) == 0 {
                do {
                    guard let url = Bundle.main.url(forResource: "articles", withExtension: "json"),
                          let data = try? Data(contentsOf: url),
                          let articleData = try? JSONDecoder().decode([ArticleData].self, from: data) else {
                        print("❌ Ошибка: Не удалось загрузить или декодировать articles.json.")
                        return
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    for data in articleData {
                        let article = ArticleEntity(context: context)
                        article.id = UUID()
                        article.title = data.title
                        article.content = data.content
                        // Предполагаем, что имя атрибута - publishDate
                        article.publishDate = dateFormatter.date(from: data.date) ?? Date()
                    }
                    
                    try context.save()
                    print("✅ \(articleData.count) Статьи успешно загружены из Articles.json.")
                    
                } catch {
                    print("❌ Ошибка сеяния ArticleEntity: \(error.localizedDescription)")
                }
            } else {
                print("ℹ️ ArticleEntity уже существуют в базе данных.")
            }
        }
    }

    private func createInitialUsers() {
        container.viewContext.performAndWait {
            let context = container.viewContext
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
                
            if (try? context.count(for: fetchRequest)) == 0 {
                
                // Администратор
                let admin = UserEntity(context: context)
                admin.id = UUID()
                admin.name = "Администратор"
                admin.email = "admin@notary.ru"
                admin.password = "123456"
                admin.role = "admin"
                
                // Обычный Пользователь
                let user = UserEntity(context: context)
                user.id = UUID()
                user.name = "Тестовый Пользователь"
                user.email = "user@test.ru"
                user.password = "123456"
                user.role = "user"
                
                // --- БЛОК СВЯЗЫВАНИЯ НОТАРИУСА ---
                
                // 1. Ищем NotaryEntity (должен существовать на этом этапе!)
                let notaryNameForLink = "Иванов Иван Иванович"
                let notaryFetchRequest: NSFetchRequest<NotaryEntity> = NotaryEntity.fetchRequest()
                notaryFetchRequest.predicate = NSPredicate(format: "fio == %@", notaryNameForLink)
                
                var linkedNotaryID: UUID? = nil
                
                if let linkedNotaryProfile = try? context.fetch(notaryFetchRequest).first {
                    linkedNotaryID = linkedNotaryProfile.id
                    print("✅ Профиль нотариуса '\(notaryNameForLink)' найден. ID: \(linkedNotaryID!.uuidString.prefix(8)).")
                } else {
                    print("❌ NotaryEntity для '\(notaryNameForLink)' не найден в базе данных.")
                }
                
                // 2. Создаем UserEntity для нотариуса
                let notaryUser = UserEntity(context: context) // Переименовано для ясности
                notaryUser.id = UUID()
                notaryUser.name = notaryNameForLink
                notaryUser.email = "ivanov@notary.ru"
                notaryUser.password = "123456"
                notaryUser.role = "notary"
                
                // 3. УСТАНАВЛИВАЕМ СВЯЗЬ ЧЕРЕЗ ID!
                notaryUser.notaryID = linkedNotaryID // !!! Ключевое исправление !!!
                
                do {
                    try context.save()
                    print("✅ Пользователи (admin, user, notary) успешно созданы и связаны.")
                } catch {
                    print("❌ Ошибка сеяния пользователей: \(error)")
                }
            } else {
                print("ℹ️ UserEntity уже существуют в базе данных.")
            }
        }
    }
}
