//
//  NotaryListView.swift
//  NotoryApp
//
//  Created by Fedor Overchenko
//

import SwiftUI
import CoreData

struct NotaryListView: View {
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.fio, order: .forward)])
    var notaries: FetchedResults<NotaryEntity>
    
    @EnvironmentObject var vm: AppViewModel
    @State private var searchText = ""
    
    var filteredNotaries: [NotaryEntity] {
        guard !searchText.isEmpty else { return Array(notaries) }
        
        return notaries.filter {
            ($0.fio?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            ($0.specialization?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredNotaries) { notary in
                
                // Навигация: Админ идет на редактирование, остальные на просмотр
                NavigationLink(destination: destinationView(for: notary)) {
                    NotaryCard(notary: notary)
                }
            }
            
            // Сообщение, если список пуст
            if notaries.isEmpty {
                Text("Список нотариусов пуст.")
                    .foregroundColor(.gray)
            }
        }
        .listStyle(.plain)
        // ----------------------------------------------------
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Реестр Нотариатов")
        .toolbar {
            if vm.currentRole == .admin {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: NotaryEditView(notary: nil)) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for notary: NotaryEntity) -> some View {
        if vm.currentRole == .admin {
            NotaryEditView(notary: notary)
        } else {
            NotaryDetailView(notary: notary)
        }
    }
}
