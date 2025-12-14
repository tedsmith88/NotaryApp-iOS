//
//  FavoriteNotariesView.swift
//  NotaryApp
//
//  Created by Fedor Overchenko
//

import SwiftUI
import CoreData

struct FavoriteNotariesView: View {
    @EnvironmentObject var vm: AppViewModel
    
    var body: some View {
        NavigationStack {
            
            // Безопасно получаем избранных нотариусов и их количество
            let favoriteSet = vm.currentUser?.favorites as? Set<NotaryEntity>
            let sortedFavorites = favoriteSet?.sorted(by: { $0.fio ?? "" < $1.fio ?? "" }) ?? []
            
            List {
                if sortedFavorites.isEmpty {
                    Text("У вас пока нет избранных нотариусов. Нажмите на сердечко в Реестре, чтобы добавить.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ForEach(sortedFavorites) { notary in
                        NavigationLink(destination: NotaryDetailView(notary: notary)) {
                            NotaryCard(notary: notary)
                        }
                        .listRowInsets(EdgeInsets())
                    }
                    .onDelete { offsets in
                        vm.removeFavorite(offsets: offsets, from: sortedFavorites)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Мое избранное")
            .id(sortedFavorites.count)
        }
    }
}
