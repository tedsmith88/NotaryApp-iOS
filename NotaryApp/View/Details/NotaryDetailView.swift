//
//  NotaryDetailView.swift
//  NotoryApp
//
//  Created by Fedor Overchenko
//

import SwiftUI
import CoreData

struct NotaryDetailView: View {
    let notary: NotaryEntity
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.managedObjectContext) var context
    
    @State private var showBookingSuccess = false
    @State private var selectedDate = Date().addingTimeInterval(3600) // По умолчанию через час
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Хедер
                VStack(alignment: .leading, spacing: 8) {
                    Text(notary.fio ?? "Нотариус").font(.title2).bold().foregroundColor(Theme.primary)
                    Text("Регион: \(notary.region ?? "")").font(.subheadline)
                }
                .padding(.bottom, 10)
                
                Divider()
                
                // Инфо-блоки
                InfoRow(icon: "briefcase", title: "Специализация", value: notary.specialization)
                InfoRow(icon: "clock", title: "График работы", value: notary.schedule ?? "Пн-Пт: 09:00 - 18:00")
                InfoRow(icon: "map", title: "Адрес", value: notary.address)
                InfoRow(icon: "phone", title: "Телефон", value: notary.phone)
                
                Spacer(minLength: 30)
                
                // Форма записи (видна только пользователям)
                if vm.currentRole == .user {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Записаться на прием").font(.headline).foregroundColor(Theme.primary)
                        
                        DatePicker("Дата и время", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .padding(.horizontal, -10)
                        
                        Button(action: bookAppointment) {
                            Text("Отправить заявку")
                        }
                        .primaryButtonStyle()
                    }
                    .padding()
                    .cardStyle() // Обернуть форму в карточку
                } else if vm.currentRole == .guest {
                    Text("Авторизуйтесь как 'Пользователь', чтобы записаться на приём.").foregroundColor(.red).padding()
                }
            }
            .padding()
        }
        .background(Theme.background)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Заявка отправлена", isPresented: $showBookingSuccess) {
            Button("OK") {}
        } message: {
            Text("Ваша заявка на \(selectedDate.formatted()) отправлена нотариусу и ожидает подтверждения.")
        }
    }
    
    func bookAppointment() {
        guard let userId = vm.currentUser?.id, let notaryId = notary.id else { return }
        
        let appointment = AppointmentEntity(context: context)
        appointment.id = UUID()
        appointment.userID = userId
        appointment.notaryID = notaryId
        appointment.date = selectedDate
        appointment.status = "pending"
        
        try? context.save()
        vm.logAction(userId: userId, action: "Appointment booked for \(notary.fio ?? "")")
        showBookingSuccess = true
    }
}

// Компонент для красивого отображения информации
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String?
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(Theme.accentEnd)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value ?? "Нет данных")
                    .font(.body)
                    .foregroundColor(Theme.textMain)
            }
        }
    }
}
