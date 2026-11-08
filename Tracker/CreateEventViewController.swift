//
//  CreateEventViewController.swift
//  Tracker
//

import UIKit

final class CreateEventViewController: UIViewController {

    // MARK: - Properties

    // делегат для передачи созданного нерегулярного события на главный экран
    weak var delegate: TrackerCreationDelegate?

    // категория по умолчанию
    private let defaultCategoryTitle = "Домашний уют"

    // MARK: - UI Elements (Создание графических элементов)
    
    private lazy var textField: UITextField = { // lazy var для подключения delegate и target
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17)
        textField.backgroundColor = UIColor(resource: .backgroundDay)
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        textField.clearButtonMode = .whileEditing // крестик очистки
        textField.returnKeyType = .done // кнопка Done
        textField.delegate = self // делегат текстового поля
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        // отслеживаем ввод текста для активации кнопки «Создать»
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let optionsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .backgroundDay)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .left
        
        // показываем подзаголовок с категорией по умолчанию
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
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
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
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 16
        button.isEnabled = false // по умолчанию неактивна
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle (Жизненный цикл контроллера)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        title = "Новое нерегулярное событие"
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
            optionsContainerView.heightAnchor.constraint(equalToConstant: 75),
            
            categoryButton.topAnchor.constraint(equalTo: optionsContainerView.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Private Helpers (ДОБАВЛЕНО)

    private func updateCreateButtonState() {
        let name = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let isValid = !name.isEmpty
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? (UIColor(named: "Black [day]") ?? .black) : .gray
    }

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
    
    @objc private func didTapCancelButton() {
        // закрываем все модальные окна сразу
        view.window?.rootViewController?.dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        // создаём нерегулярное событие и передаём через делегат
        guard let name = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { return }
        
        let newEvent = Tracker(
            id: UUID(),
            name: name,
            color: UIColor(named: "Color selection 5") ?? .systemGreen,
            emoji: "🎉",
            schedule: []
        )
        
        delegate?.didCreateTracker(newEvent, categoryTitle: defaultCategoryTitle)
        view.window?.rootViewController?.dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate (ДОБАВЛЕНО)
extension CreateEventViewController: UITextFieldDelegate {
    
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

