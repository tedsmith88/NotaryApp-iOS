//
//  ProfileView.swift
//  NotaryApp
//
//  Created by Fedor Overchenko
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var vm: AppViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // Секция Профиля
                VStack(spacing: 15) {
                    
                    // Аватар / Иконка
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Theme.primary)
                    
                    // Имя пользователя
                    Text(vm.currentUser?.name ?? "Гость")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.bottom, 20)
                
                // Основные данные (только для авторизованных)
                if let user = vm.currentUser {
                    VStack(alignment: .leading, spacing: 15) {
                        
                        // Email
                        HStack {
                            Text("Email:")
                            Spacer()
                            Text(user.email ?? "N/A")
                                .foregroundColor(Theme.textMain)
                        }
                        
                        HStack {
                            Text("Роль:")
                            Spacer()
                            Text(vm.currentRole.localizedName) // Теперь на русском
                                .foregroundColor(Theme.accentEnd)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(Theme.padding)
                    .background(Theme.backgroundCard)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                
                Spacer()
                
                // Кнопка выхода (Logout)
                Button(action: vm.logout) {
                    Text("Выход")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, Theme.padding)
                
            }
            .navigationTitle("Профиль")
            .padding(.top, Theme.padding)
        }
    }
}
