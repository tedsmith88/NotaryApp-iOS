//
//  ArticlesView.swift
//  NotaryApp
//
//  Created by Fedor Overchenko
//

import SwiftUI
import CoreData

struct ArticlesView: View {
    // Фетч всех статей, сортированных по дате публикации
    @FetchRequest(sortDescriptors: [SortDescriptor(\.publishDate, order: .reverse)])
    var articles: FetchedResults<ArticleEntity>
    @EnvironmentObject var vm: AppViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(articles, id: \.objectID) { article in
                    // Навигация к полному тексту статьи
                    NavigationLink(destination: ArticleDetailView(article: article)) {
                        VStack(alignment: .leading) {
                            Text(article.title ?? "Нет заголовка").font(.headline)
                            Text("Опубликовано: \(article.publishDate ?? Date(), style: .date)").font(.caption).foregroundColor(.gray)
                        }
                    }
                }
                // onDELETE: всегда добавляем обработчик, но проверяем роль внутри
                .onDelete(perform: handleDelete)
            }
            .navigationTitle("Статьи и Инструкции")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if vm.currentRole == .admin {
                        NavigationLink(destination: ArticleEditView(article: nil)) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
            }
        }
    }
    
    private func handleDelete(offsets: IndexSet) {
        guard vm.currentRole == .admin else { return }
        deleteArticles(offsets: offsets)
    }
    
    private func deleteArticles(offsets: IndexSet) {
        vm.deleteArticle(offsets: offsets, articles: articles)
    }
}
