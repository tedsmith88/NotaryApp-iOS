//
//  LoginView.swift
//  NotoryApp
//
//  Created by Fedor Overchenko
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegistration = false // Флаг для перехода
    @State private var showError = false
    
    var body: some View {
        // Оборачиваем в NavigationStack, чтобы переход работал
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(spacing: 25) {
                    Spacer()
                    
                    // Логотип и заголовок
                    VStack(spacing: 10) {
                        Image(systemName: "building.columns.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Theme.primary)
                        
                        Text("НОТАРИАТ").font(.title2).fontWeight(.heavy).tracking(2)
                            .foregroundColor(Theme.primary)
                        
                        Text("Единая справочная система").font(.caption).foregroundColor(Theme.textSecondary)
                    }
                    .padding(.bottom, 30)
                    
                    // Поля ввода
                    VStack(spacing: 15) {
                        customTextField(icon: "envelope", placeholder: "Email", text: $email)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                        customTextField(icon: "lock", placeholder: "Пароль", text: $password, isSecure: true)
                    }
                    
                    // 1. Кнопка Входа
                    Button(action: handleAuth) {
                        Text("Войти в систему")
                    }
                    .primaryButtonStyle()
                    
                    // 2. Кнопка Регистрации
                    Button("У меня нет аккаунта - Регистрация") {
                        showingRegistration = true // Устанавливаем флаг перехода
                    }
                    .font(.subheadline)
                    .foregroundColor(Theme.primary)
                    .padding(.top, -10) // Прижимаем к кнопке входа
                    
                    // 3. Кнопка Гостя
                    Button("Продолжить как гость") {
                        vm.currentRole = .guest
                        vm.isAuthenticated = true
                    }
                    .font(.footnote)
                    .foregroundColor(Theme.textSecondary)
                    
                    Spacer()
                }
                .padding(Theme.padding)
            }
            // Целевой экран перехода
            .navigationDestination(isPresented: $showingRegistration) {
                RegistrationView()
                    // Передаем VM в окружение нового View
                    .environmentObject(vm)
            }
            .alert("Ошибка", isPresented: $showError) { Button("OK") {} } message: { Text("Неверные данные") }
        }
    }
    
    func handleAuth() {
        if !vm.login(email: email, pass: password) {
            showError = true
        }
    }
    
    // Кастомное поле ввода (для стилизации)
    func customTextField(icon: String, placeholder: String, text: Binding<String>, isSecure: Bool = false) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(Theme.primary.opacity(0.6)).frame(width: 20)
            if isSecure { SecureField(placeholder, text: text) }
            else { TextField(placeholder, text: text) }
        }
        .padding()
        .background(Color.white).cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}
