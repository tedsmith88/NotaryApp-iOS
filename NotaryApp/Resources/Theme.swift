//
//  Theme.swift
//  NotoryApp
//
//  Created by Fedor Overchenko
//

import SwiftUI

struct Theme {
    // Палитра 
    static let primary = Color(red: 0.08, green: 0.18, blue: 0.35) // Глубокий Индиго
    static let accentStart = Color(red: 0.85, green: 0.75, blue: 0.55) // Светлое Золото
    static let accentEnd = Color(red: 0.65, green: 0.55, blue: 0.35)   // Темное Золото
    static let background = Color(red: 0.98, green: 0.98, blue: 0.99) // Очень светлый фон
    static let textMain = Color(red: 0.10, green: 0.10, blue: 0.15)
    static let textSecondary = Color.gray
    static let backgroundCard = Color(.systemGray6)
    
    // Константы
    static let cornerRadius: CGFloat = 16 // Чуть более мягкие углы
    static let padding: CGFloat = 24
}

extension View {
    // Стиль для основной кнопки с градиентом
    func primaryButtonStyle() -> some View {
        self.font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(gradient: Gradient(colors: [Theme.accentStart, Theme.accentEnd]), startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Theme.accentEnd.opacity(0.4), radius: 8, x: 0, y: 4)
    }
    
    // Стиль для карточек
    func cardStyle() -> some View {
        self.padding()
            .background(Color.white)
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4) // Более выраженная тень
    }
}
