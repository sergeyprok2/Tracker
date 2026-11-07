

import UIKit

// MARK: - TabBarController

final class TabBarController: UITabBarController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAppearance()
        setupViewControllers()
    }

    // MARK: - Private Methods

    /// Настройка внешнего вида и стилей таб-бара
    private func setupAppearance() {
        tabBar.backgroundColor = UIColor(named: "YP Black (iOS)")
        tabBar.tintColor = .white
    }

    /// Инициализация, сборка MVP-связей и назначение дочерних контроллеров
    private func setupViewControllers() {
        let trackersViewController = TrackersViewController()
        // Оборачиваем в навигационный контроллер
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "trackers"),
            selectedImage: nil
        )

        let statisticsViewController = StatisticsViewController()
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        statisticsNavigationController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "statistics"),
            selectedImage: nil
        )

        self.viewControllers = [trackersNavigationController, statisticsNavigationController]
    }
}
