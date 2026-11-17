//
//  CreateEventViewController.swift
//  Tracker
//

import UIKit

/// Экран создания нерегулярного события (трекера без привязки к дням недели): ввод имени, выбор категории, эмодзи и цвета
final class CreateEventViewController: UIViewController, EmojiCollectionViewDelegate, ColorCollectionViewDelegate {
    // MARK: - Properties

    // Делегат для передачи созданного нерегулярного события на главный экран
    weak var delegate: TrackerCreationDelegate?

    // MARK: - Private Properties

    // Категория по умолчанию
    private let defaultCategoryTitle = "Домашний уют"

    // Выбранный эмодзи (при изменении проверяет, можно ли включить кнопку «Создать»)
    private var selectedEmoji: String? {
        didSet {
            updateCreateButtonState()
        }
    }

    // Выбранный цвет (при изменении проверяет, можно ли включить кнопку «Создать»)
    private var selectedColor: UIColor? {
        didSet {
            updateCreateButtonState()
        }
    }

    // MARK: - UI Components

    // Поле ввода названия нерегулярного события
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

    // Серая скруглённая подложка под кнопку «Категория»
    private let optionsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .backgroundDay)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // Кнопка перехода к выбору категории
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

    // Горизонтальный стек для кнопок «Отменить» и «Создать»
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // Кнопка «Отменить»
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

    // Кнопка «Создать»
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

    // Прокручиваемый контейнер для всего содержимого экрана
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    // Внутренняя вью-обёртка внутри scrollView, на которую кладутся все элементы
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // Блок коллекции выбора эмодзи
    private lazy var emojiCollectionView: EmojiCollectionView = {
        let emojiView = EmojiCollectionView()
        emojiView.delegate = self
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        return emojiView
    }()

    // Блок коллекции выбора цвета
    private lazy var colorCollectionView: ColorCollectionView = {
        let colorView = ColorCollectionView()
        colorView.delegate = self
        colorView.translatesAutoresizingMaskIntoConstraints = false
        return colorView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        title = "Новое нерегулярное событие"
        navigationController?.navigationBar.prefersLargeTitles = false

        setupSubviews()
        setupConstraints()
        setupHideKeyboardGesture() // скрытие клавиатуры по тапу на экран
    }

    // MARK: - Public Methods

    // Сохраняет выбранный пользователем эмодзи
    func didSelectEmoji(_ emoji: String) {
        selectedEmoji = emoji
    }

    // Сохраняет выбранный пользователем цвет
    func didSelectColor(_ color: UIColor) {
        selectedColor = color
    }

    // MARK: - Private Methods

    // Добавление подпредставлений на экран
    private func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(textField)

        contentView.addSubview(optionsContainerView)
        optionsContainerView.addSubview(categoryButton)

        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorCollectionView)

        contentView.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
    }

    // Настройка программных ограничений
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),

            optionsContainerView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            optionsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            optionsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            optionsContainerView.heightAnchor.constraint(equalToConstant: 75),

            categoryButton.topAnchor.constraint(equalTo: optionsContainerView.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),

            emojiCollectionView.topAnchor.constraint(equalTo: optionsContainerView.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 224),

            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 224),

            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            buttonsStackView.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // Проверяет, заполнены ли имя, эмодзи и цвет, и включает/выключает кнопку «Создать»
    private func updateCreateButtonState() {
        let name = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let isValid = !name.isEmpty && selectedEmoji != nil && selectedColor != nil
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? (UIColor(named: "Black [day]") ?? .black) : .gray
    }

    // Добавляет жест нажатия по экрану для сворачивания клавиатуры
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
        guard let selectedEmoji, let selectedColor else { return }

        let newEvent = Tracker(
            id: UUID(),
            name: name,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: []
        )

        delegate?.didCreateTracker(newEvent, categoryTitle: defaultCategoryTitle)
        view.window?.rootViewController?.dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension CreateEventViewController: UITextFieldDelegate {
    // Скрывает клавиатуру при нажатии на кнопку Done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // Ограничивает ввод названия максимум 38 символами
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 38
    }
}
