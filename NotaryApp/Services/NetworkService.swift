//
//  NetworkService.swift
//  NotoryApp
//
//  Created by Fedor Overchenko
//

import Foundation

// Перечисляем возможные ошибки сети/парсинга
enum NetworkError: Error {
    case invalidURL
    case fileNotFound
    case decodingFailed(Error)
}

class NetworkService {
    static let shared = NetworkService()
    
    // Метод для загрузки данных из локального JSON, имитирующий реальный API-вызов
    func fetchNotaries() async throws -> [NotaryDTO] {
        
        // Поиск файла notaries.json в главном пакете
        guard let url = Bundle.main.url(forResource: "notaries", withExtension: "json") else {
            throw NetworkError.fileNotFound
        }
        
        // Загрузка данных
        let data = try Data(contentsOf: url)
        
        // Декодирование (парсинг JSON в массив DTO)
        do {
            let decoder = JSONDecoder()
            let dtos = try decoder.decode([NotaryDTO].self, from: data)
            return dtos
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
