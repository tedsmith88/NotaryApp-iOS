//
//  ArticleDetailView.swift
//  NotaryApp
//
//  Created by Fedor Overchenko
//

import SwiftUI
import CoreData

struct ArticleDetailView: View {
    // Получаем сущность статьи, переданную через NavigationLink
    let article: ArticleEntity
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Заголовок
                Text(article.title ?? "Статья без заголовка")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.primary)
                
                // Метаданные
                HStack {
                    Text("Автор: \(article.author ?? "Администратор")")
                    Spacer()
                    Text("Дата: \(article.publishDate ?? Date(), style: .date)")
                }
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
                
                Divider()
                
                // Полный текст статьи
                Text(article.content ?? "Содержание отсутствует.")
                    .font(.body)
                    .lineSpacing(5) // Улучшает читаемость
                    .foregroundColor(Theme.textMain)
                
                Spacer()
            }
            .padding(Theme.padding)
        }
        .navigationTitle("Инструкция")
        .navigationBarTitleDisplayMode(.inline)
    }
}
