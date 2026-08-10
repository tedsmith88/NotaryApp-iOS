//
//  DatabaseMigrationHelper.swift
//  NotoryApp
//
//  Created by Fedor Overchenko
//
//  Вспомогательный файл для миграции существующих данных
//  после исправления архитектуры связи UserEntity <-> NotaryEntity
//

import CoreData
import Foundation

extension PersistenceController {
    
    /// Вызовите этот метод ОДИН РАЗ после обновления кода,
    /// чтобы исправить существующие связи между UserEntity и NotaryEntity
    func migrateNotaryUserRelationships() {
        container.viewContext.performAndWait {
            let context = container.viewContext
            
            print("🔄 Начинаем миграцию связей UserEntity <-> NotaryEntity...")
            
            // 1. Получаем всех пользователей с ролью "notary"
            let userFetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            userFetchRequest.predicate = NSPredicate(format: "role == %@", "notary")
            
            guard let notaryUsers = try? context.fetch(userFetchRequest) else {
                print("❌ Ошибка при получении пользователей-нотариусов")
                return
            }
            
            print("ℹ️ Найдено \(notaryUsers.count) пользователей с ролью 'notary'")
            
            // 2. Для каждого пользователя-нотариуса
            for notaryUser in notaryUsers {
                guard let notaryProfileID = notaryUser.notaryID else {
                    print("⚠️ У пользователя \(notaryUser.email ?? "N/A") нет notaryID. Пропускаем.")
                    continue
                }
                
                // 3. Находим соответствующий NotaryEntity
                let notaryFetchRequest: NSFetchRequest<NotaryEntity> = NotaryEntity.fetchRequest()
                notaryFetchRequest.predicate = NSPredicate(format: "id == %@", notaryProfileID as CVarArg)
                
                guard let notaryProfile = try? context.fetch(notaryFetchRequest).first else {
                    print("❌ NotaryEntity с ID \(notaryProfileID.uuidString.prefix(8)) не найден")
                    continue
                }
                
                // 4. КЛЮЧЕВОЕ ИЗМЕНЕНИЕ: Синхронизируем ID
                let oldUserID = notaryUser.id
                notaryUser.id = notaryProfile.id // Устанавливаем ID пользователя равным ID профиля
                
                print("✅ Обновлен UserEntity для '\(notaryUser.name ?? "N/A")':")
                print("   Старый ID: \(oldUserID?.uuidString.prefix(8) ?? "N/A")")
                print("   Новый ID:  \(notaryUser.id?.uuidString.prefix(8) ?? "N/A")")
                print("   NotaryID:  \(notaryUser.notaryID?.uuidString.prefix(8) ?? "N/A")")
            }
            
            // 5. Сохраняем изменения
            do {
                try context.save()
                print("✅ Миграция завершена успешно!")
                print("⚠️ ВАЖНО: Удалите вызов миgrateNotaryUserRelationships() из кода после первого запуска!")
            } catch {
                print("❌ Ошибка при сохранении миграции: \(error.localizedDescription)")
            }
        }
    }
}
