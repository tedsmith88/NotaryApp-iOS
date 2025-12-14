# 🏛️ Информационно-справочная система нотариата (iOS)

**Курсовая работа по дисциплине «Современные технологии программирования»**

### 📋 Описание проекта

Мобильное приложение для платформы iOS, разработанное в рамках курсовой работы для **Финансового университета при Правительстве РФ**. Система "Нотариат" представляет собой многопользовательскую информационно-справочную систему, предназначенную для эффективного взаимодействия граждан, нотариусов и администраторов с актуальными данными нотариального реестра.

### ✨ Ключевой функционал и Ролевая модель

Приложение реализует строгую ролевую модель доступа, дифференцируя возможности для каждой категории пользователей:

| Роль | Основной функционал |
| :--- | :--- |
| **Гость** | Просмотр полного реестра нотариусов, поиск и фильтрация, геопозиционная визуализация на карте (MapKit). |
| **Пользователь** | Аутентификация, управление персональным списком **"Избранное"** (Many-to-Many Core Data Relationship). |
| **Нотариус** | Управление информацией о своей конторе (контакты, расписание), просмотр и обработка заявок на приём (ограниченный CRUD). |
| **Администратор** | Полный CRUD-доступ (Создание, Чтение, Изменение, Удаление). |

### 🛠️ Технологический стек

Проект разработан на нативных технологиях Apple, обеспечивающих высокую производительность и легкость поддержки.

* **Язык программирования:** Swift 5+
* **Интерфейс:** SwiftUI (Декларативное программирование)
* **Архитектура:** Model-View-ViewModel (MVVM)
* **Слой постоянства (Локальная СУБД):** Core Data (SQLite Store)
* **Инициализация данных:** JSON Seeding с использованием протокола `Codable`.

### 🏗️ Архитектура MVVM и Core Data

Архитектура проекта основана на паттерне MVVM с централизованным управлением состоянием через **`AppViewModel`** (ObservableObject).

* **Persistence:** Реализован **`PersistenceController`** (Singleton) для потокобезопасного доступа к контексту Core Data.
* **Data Seeding:** Автоматическая загрузка начальных данных (`notaries.json`, `articles.json`, `UserEntity` для ролей) при первом запуске приложения.
* **Relationships:** Использовано сложное отношение **"Многие-ко-Многим"** для реализации функционала "Избранное" между `UserEntity` и `NotaryEntity`.

### ⚙️ Инструкция по установке и запуску

1.  **Клонирование репозитория:**
    ```bash
    git clone [https://github.com/ВАШ_USERNAME/NotaryApp-iOS.git](https://github.com/ВАШ_USERNAME/NotaryApp-iOS.git)
    cd NotaryApp-iOS
    ```

2.  **Открытие проекта:**
    Откройте файл `NotaryApp.xcodeproj` в Xcode (версия 15.0 или выше).

3.  **Запуск:**
    Выберите симулятор (например, iPhone 15 Pro) и нажмите кнопку **Run** (`⌘R`).

### 🔑 Тестовые учетные записи для Seeding

Для тестирования ролевого доступа используйте следующие данные (устанавливаются в базе данных при первом запуске через JSON Seeding):

| Роль | Email | Пароль |
| :--- | :--- | :--- |
| **Администратор** | `admin@notary.ru` | `123456` |
| **Нотариус** | `ivanov@notary.ru` | `123456` |
| **Пользователь** | `user@test.ru` | `123456` |

---
---

# 🏛️ Notary Information and Reference System (iOS)

**Coursework for the discipline "Modern Programming Technologies"**

### 📋 Project Description

A mobile application for the iOS platform, developed as part of a university coursework for the **Financial University under the Government of the Russian Federation**. The "Notary System" is a multi-user information and reference application designed for the efficient interaction of citizens, notaries, and administrators with up-to-date notary registry data.

### ✨ Key Features and Role-Based Model

The application implements a strict role-based access control (RBAC) model, differentiating capabilities for each user category:

| Role | Core Functionality |
| :--- | :--- |
| **Guest** | Viewing the full notary registry, search and filtering, geolocation visualization on a map (MapKit). |
| **User** | Authentication, managing a personal **"Favorites"** list (Many-to-Many Core Data Relationship). |
| **Notary** | Managing their office information (contacts, schedule), viewing and processing appointment requests (limited CRUD). |
| **Administrator** | Full CRUD access (Create, Read, Update, Delete). |

### 🛠️ Technology Stack

The project is developed using native Apple technologies, ensuring high performance and ease of maintenance.

* **Programming Language:** Swift 5+
* **User Interface:** SwiftUI (Declarative Programming)
* **Architecture:** Model-View-ViewModel (MVVM)
* **Persistence Layer (Local DB):** Core Data (SQLite Store)
* **Data Initialization:** JSON Seeding using the `Codable` protocol.

### 🏗️ MVVM Architecture and Core Data

The project's architecture is based on the MVVM pattern with centralized state management via **`AppViewModel`** (ObservableObject).

* **Persistence:** Implements **`PersistenceController`** (Singleton) for thread-safe access to the Core Data context.
* **Data Seeding:** Automatic initial data loading (`notaries.json`, `articles.json`, `UserEntity` for roles) upon first launch.
* **Relationships:** A complex **Many-to-Many** relationship is used to implement the "Favorites" feature between `UserEntity` and `NotaryEntity`.

### ⚙️ Setup and Run Instructions

1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/NotaryApp-iOS.git](https://github.com/YOUR_USERNAME/NotaryApp-iOS.git)
    cd NotaryApp-iOS
    ```

2.  **Open the Project:**
    Open the `NotaryApp.xcodeproj` file in Xcode (version 15.0 or higher).

3.  **Run:**
    Select a simulator (e.g., iPhone 15 Pro) and press the **Run** button (`⌘R`).

### 🔑 Testing Accounts for Seeding

Use the following credentials to test the role-based access (these are established in the database on first run via JSON Seeding):

| Role | Email | Password |
| :--- | :--- | :--- |
| **Administrator** | `admin@notary.ru` | `123456` |
| **Notary** | `ivanov@notary.ru` | `123456` |
| **User** | `user@test.ru` | `123456` |
