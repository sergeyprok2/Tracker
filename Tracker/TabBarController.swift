

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
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white

        // ИЗМЕНЕНО: серый цвет для неактивной вкладки и синий для активной
        let normalColor = UIColor(named: "Gray [day]") ?? UIColor(named: "Gray1") ?? .systemGray
        let selectedColor = UIColor(named: "Blue [day]") ?? UIColor(named: "Blue1") ?? .systemBlue

        let itemAppearances = [
            appearance.stackedLayoutAppearance,
            appearance.inlineLayoutAppearance,
            appearance.compactInlineLayoutAppearance
        ]

        for itemAppearance in itemAppearances {
            itemAppearance.normal.iconColor = normalColor
            itemAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]

            itemAppearance.selected.iconColor = selectedColor
            itemAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
        }

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = selectedColor
        tabBar.unselectedItemTintColor = normalColor
    }

    /// Инициализация, сборка MVP-связей и назначение дочерних контроллеров
    private func setupViewControllers() {
        let normalColor = UIColor(named: "Gray1") ?? .systemGray
        let selectedColor = UIColor(named: "Blue1") ?? .systemBlue

        let trackersViewController = TrackersViewController()
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "trackers")?.withTintColor(normalColor, renderingMode: .alwaysOriginal),
            selectedImage: UIImage(named: "trackers")?.withTintColor(selectedColor, renderingMode: .alwaysOriginal)
        )
        // явно задаём серый цвет текста для неактивного состояния и синий для выбранного
        trackersNavigationController.tabBarItem.setTitleTextAttributes([.foregroundColor: normalColor], for: .normal)
        trackersNavigationController.tabBarItem.setTitleTextAttributes([.foregroundColor: selectedColor], for: .selected)

        let statisticsViewController = StatisticsViewController()
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        statisticsNavigationController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "statistics")?.withTintColor(normalColor, renderingMode: .alwaysOriginal),
            selectedImage: UIImage(named: "statistics")?.withTintColor(selectedColor, renderingMode: .alwaysOriginal)
        )
        // явно задаём серый цвет текста для слова «Статистика»
        statisticsNavigationController.tabBarItem.setTitleTextAttributes([.foregroundColor: normalColor], for: .normal)
        statisticsNavigationController.tabBarItem.setTitleTextAttributes([.foregroundColor: selectedColor], for: .selected)

        self.viewControllers = [trackersNavigationController, statisticsNavigationController]
    }


}

