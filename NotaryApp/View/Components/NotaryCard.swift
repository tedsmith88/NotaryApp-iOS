//
//  NotaryCard.swift
//  NotoryApp
//
//  Created by Fedor Overchenko
//

import SwiftUI

struct NotaryCard: View {
    let notary: NotaryEntity
    // Получаем доступ к главному менеджеру состояния
    @EnvironmentObject var vm: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(notary.fio ?? "ФИО не указано")
                        .font(.headline)
                        .foregroundColor(Theme.textMain)
                    Text(notary.specialization ?? "Общая практика")
                        .font(.caption)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Theme.accentStart.opacity(0.3))
                        .foregroundColor(Theme.primary)
                        .cornerRadius(4)
                }
                
                Spacer()
                
                if vm.currentRole == .user {
                    Button {
                        // Переключение статуса избранного
                        vm.toggleFavorite(notary: notary)
                    } label: {
                        Image(systemName: vm.isFavorite(notary: notary) ? "heart.fill" : "heart")
                            .foregroundColor(vm.isFavorite(notary: notary) ? .red : Theme.textSecondary)
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Theme.textSecondary.opacity(0.5))
                }
            }
            
            Divider()
            
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(Theme.accentEnd)
                Text(notary.region ?? "") + Text(", ") + Text(notary.address ?? "")
            }
            .font(.caption).foregroundColor(Theme.textSecondary)
        }
        .cardStyle()
    }
}
