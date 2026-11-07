//
//  CreateTrackerTypeViewController.swift
//  Tracker
//
//

import UIKit

final class CreateTrackerTypeViewController: UIViewController {
    
    private lazy var habitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapHabitButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var eventsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapEventButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle (Жизненный цикл контроллера)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Установка нативного заголовка навигационной панели
        title = "Создание трекера"
        navigationController?.navigationBar.prefersLargeTitles = false
        // Полностью убирает кнопку «Назад» и стрелочку слева
        navigationItem.hidesBackButton = true
        setupSubviews()
        setupConstraints()
    }
    
    @objc private func didTapHabitButton() {
        dismiss(animated: true) {
            let createTrackerVC = CreateTrackerViewController()
            
            // Оборачиваем в UINavigationController, чтобы работал заголовок сверху
            let navController = UINavigationController(rootViewController: createTrackerVC)
            navController.modalPresentationStyle = .pageSheet
            
            // Находим текущий экран и презентуем шторку
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let topController = windowScene.windows.first?.rootViewController else {
                return
            }
            topController.present(navController, animated: true)
        }
    }
    
    @objc private func didTapEventButton() {
        dismiss(animated: true) {
            let createEventVC = CreateEventViewController()
            
            // Оборачиваем в UINavigationController, чтобы работал заголовок сверху
            let navController = UINavigationController(rootViewController: createEventVC)
            navController.modalPresentationStyle = .pageSheet
            
            // Находим текущий экран и презентуем шторку
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let topController = windowScene.windows.first?.rootViewController else {
                return
            }
            topController.present(navController, animated: true)
        }
    }

    // MARK: - Setup Layout (Добавление подпредставлений)
    
    private func setupSubviews() {
        view.addSubview(habitButton)
        view.addSubview(eventsButton)
    }
    
    // MARK: - Constraints (Настройка программных ограничений)
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            eventsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -247),
            eventsButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            eventsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            eventsButton.heightAnchor.constraint(equalToConstant: 60),
            
            habitButton.bottomAnchor.constraint(equalTo: eventsButton.topAnchor, constant: -16),
            habitButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
