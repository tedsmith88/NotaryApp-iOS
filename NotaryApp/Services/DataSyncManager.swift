//
//  DataSyncManager.swift
//  NotoryApp
//
//  Created by Fedor Overchenko
//

import CoreData
import Foundation

class DataSyncManager {
    static let shared = DataSyncManager()
    
    // Используем фоновый контекст для асинхронных операций записи/обновления
    private let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
    
    // Метод синхронизации: загрузка DTO -> маппинг -> сохранение в SQLite
    func syncNotaries() async {
        do {
            // 1. Получаем данные (DTO) из NetworkService
            let dtos = try await NetworkService.shared.fetchNotaries()
            
            // 2. Выполняем операции с Core Data в безопасном фоновом контексте
            await backgroundContext.perform {
                for dto in dtos {
                    
                    // Запрос для поиска существующей записи по строковому ID
                    let fetchRequest: NSFetchRequest<NotaryEntity> = NotaryEntity.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "idString == %@", dto.id)
                    
                    do {
                        let existingNotaries = try self.backgroundContext.fetch(fetchRequest)
                        
                        let entityToUpdate: NotaryEntity
                        
                        if let existing = existingNotaries.first {
                            // Найдена существующая запись: обновляем ее
                            entityToUpdate = existing
                        } else {
                            // Запись не найдена: создаем новую NotaryEntity
                            let newNotary = NotaryEntity(context: self.backgroundContext)
                            newNotary.id = UUID(uuidString: dto.id) ?? UUID() // UUID
                            newNotary.idString = dto.id // строковый ID для поиска
                            entityToUpdate = newNotary
                        }
                        
                        // 3. ORM Mapping: Копирование данных из DTO в Entity
                        entityToUpdate.fio = dto.fio
                        entityToUpdate.region = dto.region
                        entityToUpdate.address = dto.address
                        entityToUpdate.specialization = dto.specialization
                        entityToUpdate.schedule = dto.schedule
                        entityToUpdate.phone = dto.phone
                        
                        // !!! ОБНОВЛЕНИЕ НОВЫХ ПОЛЕЙ (Latitude и Longitude) !!!
                        entityToUpdate.latitude = dto.latitude
                        entityToUpdate.longitude = dto.longitude
                        
                    } catch {
                        print("Ошибка при поиске/создании NotaryEntity: \(error)")
                    }
                }
                
                // 4. Сохранение изменений в Core Data (SQLite)
                if self.backgroundContext.hasChanges {
                    do {
                        try self.backgroundContext.save()
                        print("✅ Синхронизация Core Data успешна. \(dtos.count) записей нотариусов сохранены в SQLite.")
                    } catch {
                        print("❌ Ошибка при сохранении контекста: \(error)")
                    }
                }
            }
        } catch {
            print("❌ Ошибка загрузки данных из сети/JSON: \(error)")
        }
    }
}
