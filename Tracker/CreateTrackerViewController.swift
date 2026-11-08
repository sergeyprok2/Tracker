//
//  CreateTrackerViewController.swift
//  Tracker
//

import UIKit

final class CreateTrackerViewController: UIViewController {

    // MARK: - Properties

    // делегат для передачи созданного трекера и названия категории на главный экран
    weak var delegate: TrackerCreationDelegate?

    // категория по умолчанию (по подсказке из ТЗ)
    private let defaultCategoryTitle = "Домашний уют"

    // массив выбранных дней недели для расписания
    private var selectedSchedule: [WeekDay] = [] {
        didSet {
            updateScheduleButtonTitle()
            updateCreateButtonState()
        }
    }

    // MARK: - UI Elements (Создание графических элементов)
    
    // Текстовое поле для ввода названия трекера с отступами внутри
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17)
        textField.backgroundColor = UIColor(resource: .backgroundDay)
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        textField.clearButtonMode = .whileEditing // крестик очистки текста справа, как в макете
        textField.returnKeyType = .done // кнопка Done на клавиатуре
        textField.delegate = self // делегат для скрытия клавиатуры и лимита 38 символов
        
        // Создаем отступы слева и справа для текста внутри инпута, чтобы он не прилипал к краям
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        // отслеживаем ввод текста, чтобы включать/выключать кнопку «Создать»
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // Единый светлый контейнер-подложка для опций «Категория» и «Расписание»
    private let optionsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundDay
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Кнопка выбора категории со стрелочкой справа и современными отступами
    private lazy var categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .left
        
        // настраиваем заголовок и серый подзаголовок с категорией по умолчанию через Configuration
        var config = UIButton.Configuration.plain()
        config.title = "Категория"
        config.subtitle = defaultCategoryTitle
        config.titlePadding = 2
        config.baseForegroundColor = .black
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 40)
        button.configuration = config
        
        let chevron = UIImageView(image: ImageName.chevronRight)
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
        button.contentHorizontalAlignment = .left
        
        // ИЗМЕНЕНО: используем Configuration, чтобы легко добавлять подпись с выбранными днями недели
        var config = UIButton.Configuration.plain()
        config.title = "Расписание"
        config.titlePadding = 2
        config.baseForegroundColor = .black
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 40)
        button.configuration = config
        
        let chevron = UIImageView(image: ImageName.chevronRight)
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
        button.isEnabled = false // по умолчанию выключена, пока не заполнены поля
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle (Жизненный цикл контроллера)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        title = "Новая привычка"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupSubviews()
        setupConstraints()
        setupHideKeyboardGesture() // скрытие клавиатуры по тапу на экран
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
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            optionsContainerView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            optionsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            optionsContainerView.heightAnchor.constraint(equalToConstant: 150),
            
            categoryButton.topAnchor.constraint(equalTo: optionsContainerView.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            
            separatorView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            scheduleButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            scheduleButton.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor),
            scheduleButton.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor),
            scheduleButton.heightAnchor.constraint(equalToConstant: 75),
            
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Private Helpers

    // проверяем, введено ли название и выбрано ли расписание
    private func updateCreateButtonState() {
        let name = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let isValid = !name.isEmpty && !selectedSchedule.isEmpty
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? (UIColor(named: "Black [day]") ?? .black) : .gray
    }

    // обновляем подпись под кнопкой «Расписание» (например, «Пн, Ср, Пт» или «Каждый день»)
    private func updateScheduleButtonTitle() {
        var config = scheduleButton.configuration
        if selectedSchedule.count == WeekDay.allCases.count {
            config?.subtitle = "Каждый день"
        } else if selectedSchedule.isEmpty {
            config?.subtitle = nil
        } else {
            let shortNames: [WeekDay: String] = [.monday: "Пн", .tuesday: "Вт", .wednesday: "Ср", .thursday: "Чт", .friday: "Пт", .saturday: "Сб", .sunday: "Вс"]
            config?.subtitle = selectedSchedule.compactMap { shortNames[$0] }.joined(separator: ", ")
        }
        scheduleButton.configuration = config
    }

    // жест для скрытия клавиатуры при нажатии на свободное место
    private func setupHideKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }

    // MARK: - Actions (Обработчики нажатий на элементы)
    
    @objc private func didTapCategoryButton() {
        print("Нажата Категория")
    }
    
    @objc private func didTapScheduleButton() {
        // передаём уже выбранные дни и подписываемся на возврат результата
        let scheduleVC = ScheduleViewController(selectedDays: selectedSchedule)
        scheduleVC.onScheduleSelected = { [weak self] days in
            self?.selectedSchedule = days
        }
        let navController = UINavigationController(rootViewController: scheduleVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    @objc private func didTapCancelButton() {
        view.window?.rootViewController?.dismiss(animated: true) // закрываем оба модальных окна
    }
    
    @objc private func didTapCreateButton() {
        guard let name = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { return }
        
        let newTracker = Tracker(
            id: UUID(),
            name: name,
            color: UIColor(named: "Color selection 5") ?? .systemGreen,
            emoji: "❤️",
            schedule: selectedSchedule
        )
        
        delegate?.didCreateTracker(newTracker, categoryTitle: defaultCategoryTitle) // передаём трекер через делегат
        view.window?.rootViewController?.dismiss(animated: true) // закрываем оба модальных окна
    }

}

// MARK: - UITextFieldDelegate (закрытие клавиатуры по Done и лимит 38 символов)
extension CreateTrackerViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 38
    }
}

