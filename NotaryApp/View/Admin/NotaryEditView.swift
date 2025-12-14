//
//  NotaryEditView.swift
//  NotaryApp
//
//  Created by Fedor Overchenko
//

import SwiftUI
import CoreData

struct NotaryEditView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    
    // Ссылка на существующий объект (может быть nil для создания)
    let existingNotary: NotaryEntity?
    private var isNew: Bool { existingNotary == nil }
    
    // Временные @State переменные для полей ввода
    @State private var fio: String
    @State private var address: String
    @State private var specialization: String
    @State private var region: String
    @State private var schedule: String
    @State private var phone: String
    @State private var latitudeString: String
    @State private var longitudeString: String
    
    // Инициализатор, принимающий опциональный NotaryEntity?
    init(notary: NotaryEntity?) {
        self.existingNotary = notary
        
        // Инициализация стейтов на основе существующего объекта или пустых значений
        _fio = State(initialValue: notary?.fio ?? "")
        _address = State(initialValue: notary?.address ?? "")
        _specialization = State(initialValue: notary?.specialization ?? "")
        _region = State(initialValue: notary?.region ?? "")
        _schedule = State(initialValue: notary?.schedule ?? "")
        _phone = State(initialValue: notary?.phone ?? "")
        
        // Инициализация координат: конвертируем Double в String. Если nil, то 0.0
        _latitudeString = State(initialValue: String(notary?.latitude ?? 0.0))
        _longitudeString = State(initialValue: String(notary?.longitude ?? 0.0))
    }
    
    var body: some View {
        Form {
            Section(header: Text("Основные данные")) {
                TextField("ФИО", text: $fio)
                TextField("Регион", text: $region)
                TextField("Адрес", text: $address)
                TextField("Специализация", text: $specialization)
            }
            
            Section(header: Text("Контакты и расписание")) {
                TextField("Расписание", text: $schedule)
                TextField("Телефон", text: $phone)
            }
            
            Section(header: Text("Географические координаты")) {
                TextField("Широта (Latitude)", text: $latitudeString)
                    .keyboardType(.decimalPad)
                TextField("Долгота (Longitude)", text: $longitudeString)
                    .keyboardType(.decimalPad)
            }
            
            Button("Сохранить", action: saveChanges)
                .primaryButtonStyle()
                .padding(.vertical)
        }
        .navigationTitle(isNew ? "Создать нотариуса" : "Редактировать \(fio)")
    }
    
    private func saveChanges() {
        let notaryToSave: NotaryEntity
        
        if isNew {
            notaryToSave = NotaryEntity(context: context)
            notaryToSave.id = UUID()
        } else {
            notaryToSave = existingNotary!
        }
        
        notaryToSave.fio = fio
        notaryToSave.address = address
        notaryToSave.specialization = specialization
        notaryToSave.region = region
        notaryToSave.schedule = schedule
        notaryToSave.phone = phone
        
        if let lat = Double(latitudeString), let lon = Double(longitudeString) {
            notaryToSave.latitude = lat
            notaryToSave.longitude = lon
        }
        
        do {
            try context.save()
            dismiss()
        } catch {
            print("Ошибка сохранения нотариуса: \(error)")
        }
    }
}
