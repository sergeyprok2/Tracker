//
//  AppDelegate.swift
//  Tracker
//

import UIKit
import CoreData

/// Главный класс приложения: отвечает за старт программы, регистрацию трансформера и настройку базы данных Core Data
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properties

    var window: UIWindow?

    // Контейнер Core Data для загрузки и хранения файла базы данных TrackerDataModel
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Код для обработки ошибки
                print("ошибка: \(error)")
            }
        })
        return container
    }()

    // MARK: - Lifecycle

    // Вызывается при запуске приложения: регистрируем трансформер для массива дней недели
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DaysValueTransformer.register()
        return true
    }

    // Настройка конфигурации сцены при создании нового окна
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // MARK: - Public Methods

    // Сохранение несохранённых изменений из контекста памяти в базу данных Core Data
    func saveContext() {
        let context = persistentContainer.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("ошибка в сохранении контекста: \(error)")
            }
        }
    }
}
