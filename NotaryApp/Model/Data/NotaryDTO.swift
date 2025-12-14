import Foundation

// Notary Data Transfer Object - используется для декодирования данных из JSON
struct NotaryDTO: Decodable {
    
    // Обязательные поля
    let id: String
    let fio: String
    let region: String
    let address: String
    let specialization: String
    
    // Новые поля для карт - должны быть опциональными (Double?), если
    // они могут отсутствовать в JSON, но в нашем случае они обязательны для карт.
    let latitude: Double
    let longitude: Double
    
    // Опциональные поля
    let schedule: String?
    let phone: String?
}
