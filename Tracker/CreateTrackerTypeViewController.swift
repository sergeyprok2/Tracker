//
//  CreateTrackerTypeViewController.swift
//  Tracker
//

import UIKit

// протокол делегата для передачи созданного трекера на главный экран
protocol TrackerCreationDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String)
}

final class CreateTrackerTypeViewController: UIViewController {
    
    // ссылка на делегат (TrackersViewController)
    weak var delegate: TrackerCreationDelegate?
    
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
        
        title = "Создание трекера"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.hidesBackButton = true
        setupSubviews()
        setupConstraints()
    }
    
    @objc private func didTapHabitButton() {
        // открываем экран привычки и передаём ему наш delegate
        let createTrackerVC = CreateTrackerViewController()
        createTrackerVC.delegate = delegate
        let navController = UINavigationController(rootViewController: createTrackerVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    @objc private func didTapEventButton() {
        // открываем экран нерегулярного события и передаём ему наш delegate
        let createEventVC = CreateEventViewController()
        createEventVC.delegate = delegate
        let navController = UINavigationController(rootViewController: createEventVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
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

