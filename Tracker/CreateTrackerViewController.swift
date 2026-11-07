//
//  CreateTrackerViewController.swift
//  Tracker

//

import UIKit

final class CreateTrackerViewController: UIViewController {

    // MARK: - UI Elements (Создание графических элементов)
    
    // Текстовое поле для ввода названия трекера с отступами внутри
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17)
        textField.backgroundColor = UIColor(named: "YP Background") ?? UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        
        // Создаем отступы слева и справа для текста внутри инпута, чтобы он не прилипал к краям
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // Единый светлый контейнер-подложка для опций «Категория» и «Расписание»
    private let optionsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "YP Background") ?? UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Кнопка выбора категории со стрелочкой справа и современными отступами
    private lazy var categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Категория", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.contentHorizontalAlignment = .left
        
        // Настройка внутренних отступов контента кнопки (без устаревших property)
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        button.configuration = config
        
        // Добавление иконки-стрелочки (`chevron.right`) на правый край кнопки
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .gray
        chevron.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(chevron)
        
        NSLayoutConstraint.activate([
            chevron.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        button.addTarget(self, action: #selector(didTapCategoryButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Тонкая разделительная линия между пунктами «Категория» и «Расписание»
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Кнопка выбора расписания со стрелочкой справа
    private lazy var scheduleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Расписание", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.contentHorizontalAlignment = .left
        
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        button.configuration = config
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .gray
        chevron.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(chevron)
        
        NSLayoutConstraint.activate([
            chevron.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        button.addTarget(self, action: #selector(didTapScheduleButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Горизонтальный стек-контейнер для нижних кнопок управления
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Кнопка «Отменить» с красной рамкой и текстом
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        return button
    }()
    
    // Кнопка «Создать» (по умолчанию серая, неактивная)
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle (Жизненный цикл контроллера)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Установка нативного заголовка навигационной панели
        title = "Новая привычка"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupSubviews()
        setupConstraints()
    }

    // MARK: - Setup Layout (Добавление подпредставлений)
    
    private func setupSubviews() {
        view.addSubview(textField)
        
        view.addSubview(optionsContainerView)
        optionsContainerView.addSubview(categoryButton)
        optionsContainerView.addSubview(separatorView)
        optionsContainerView.addSubview(scheduleButton)
        
        view.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
    }
    
    // MARK: - Constraints (Настройка программных ограничений)
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Текстовое поле ввода названия трекера под навигационным баром
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            // Общий контейнер опций («Категория» + «Расписание»)
            optionsContainerView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            optionsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            optionsContainerView.heightAnchor.constraint(equalToConstant: 150),
            
            // Верхняя кнопка «Категория» внутри контейнера
            categoryButton.topAnchor.constraint(equalTo: optionsContainerView.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            
            // Тонкая разделительная линия между ячейками
            separatorView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            // Нижняя кнопка «Расписание» внутри контейнера
            scheduleButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            scheduleButton.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor),
            scheduleButton.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor),
            scheduleButton.heightAnchor.constraint(equalToConstant: 75),
            
            // Нижний стэк с кнопками «Отменить» и «Создать» с привязкой к безопасной зоне
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Actions (Обработчики нажатий на элементы)
    
    @objc private func didTapCategoryButton() {
        print("Нажата Категория")
    }
    
    @objc private func didTapScheduleButton() {
        let scheduleVC = ScheduleViewController()
        let navController = UINavigationController(rootViewController: scheduleVC)
        navController.modalPresentationStyle = .pageSheet // или .automatic, чтобы открывалось шторкой
        present(navController, animated: true)
    }
    
    @objc private func didTapCancelButton() {
        // Закрытие модального окна создания привычки
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        print("Нажата Создать")
    }
}
