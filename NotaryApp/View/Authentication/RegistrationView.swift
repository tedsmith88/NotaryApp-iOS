//
//  RegistrationView.swift
//  NotoryApp
//
//  Created by Fedor Overchenko
//

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Создание аккаунта")
                    .font(.largeTitle).bold()
                    .foregroundColor(Theme.primary)
                
                VStack(spacing: 15) {
                    // Используем стильный TextField из LoginView
                    LoginView().customTextField(icon: "person", placeholder: "Ваше ФИО", text: $name)
                    LoginView().customTextField(icon: "envelope", placeholder: "Email", text: $email)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                    LoginView().customTextField(icon: "lock", placeholder: "Пароль", text: $password, isSecure: true)
                }
                
                Button(action: registerUser) {
                    Text("Зарегистрироваться")
                }
                .primaryButtonStyle()
                
                Spacer()
            }
            .padding(Theme.padding)
        }
        .navigationTitle("Регистрация")
    }
    
    func registerUser() {
        guard vm.registerUser(name: name, email: email, pass: password) else {
            // Показать ошибку
            return
        }
        dismiss() // Вернуться на экран входа
    }
}
