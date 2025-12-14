//
//  ArticleEditView.swift
//  NotaryApp
//
//  Created by Fedor Overchenko
//

import SwiftUI
import CoreData

struct ArticleEditView: View {
    // Используем контекст для сохранения
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss // Для закрытия представления после сохранения
    
    // Редактируемая статья (nil для создания новой)
    @State var article: ArticleEntity?
    
    // Временные переменные для полей ввода
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var author: String = "Администратор"
    
    // Заголовок для NavigationBar
    var navigationTitle: String {
        article == nil ? "Создать статью" : "Редактировать статью"
    }
    
    var body: some View {
        VStack {
            Form {
                // Поле ввода заголовка
                TextField("Заголовок статьи", text: $title)
                    .font(.headline)
                
                // Поле ввода автора
                TextField("Автор", text: $author)
                    .foregroundColor(.gray)
                
                // Многострочное поле для контента
                TextEditor(text: $content)
                    .frame(height: 300)
                    .border(Color.gray.opacity(0.2))
            }
            
            Button(action: saveArticle) {
                Text("Сохранить")
                    .primaryButtonStyle()
            }
            .padding(Theme.padding)
            .disabled(title.isEmpty || content.isEmpty) // Отключаем, если поля пустые
        }
        .navigationTitle(navigationTitle)
        .onAppear {
            // Загрузка данных, если статья существует
            if let existingArticle = article {
                self.title = existingArticle.title ?? ""
                self.content = existingArticle.content ?? ""
                self.author = existingArticle.author ?? "Администратор"
            }
        }
    }
    
    private func saveArticle() {
        let articleToSave: ArticleEntity
        
        if let existingArticle = article {
            // Редактирование существующей статьи
            articleToSave = existingArticle
        } else {
            // Создание новой статьи
            articleToSave = ArticleEntity(context: context)
            articleToSave.id = UUID()
            articleToSave.publishDate = Date()
        }
        
        // Маппинг данных
        articleToSave.title = title
        articleToSave.content = content
        articleToSave.author = author
        
        // Сохранение в Core Data (SQLite)
        do {
            try context.save()
            dismiss() // Закрыть окно после сохранения
        } catch {
            print("Ошибка сохранения статьи: \(error)")
        }
    }
}
