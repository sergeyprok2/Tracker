//
//  SceneDelegate.swift
//  Tracker
//

import UIKit

/// Класс управления окном приложения: создаёт главное окно UIWindow и назначает TabBarController стартовым экраном
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // MARK: - Properties

    var window: UIWindow?

    // MARK: - Lifecycle

    // Настройка главного окна и запуск приложения с экрана вкладок TabBarController
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()
    }
}
