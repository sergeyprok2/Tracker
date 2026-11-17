//
//  CreateTrackerViewController.swift
//  Tracker
//

import UIKit

/// Экран создания регулярной привычки: ввод названия, выбор категории, расписания по дням недели, эмодзи и цвета
final class CreateTrackerViewController: UIViewController, EmojiCollectionViewDelegate, ColorCollectionViewDelegate {
    // MARK: - Properties

    // Делегат для передачи созданного трекера и названия категории на главный экран
    weak var delegate: TrackerCreationDelegate?

    // MARK: - Private Properties

    // Категория по умолчанию (по подсказке из ТЗ)
    private let defaultCategoryTitle = "Домашний уют"

    // Массив выбранных дней недели для расписания
    private var selectedSchedule: [WeekDay] = [] {
        didSet {
            updateScheduleButtonTitle()
            updateCreateButtonState()
        }
    }

    // Выбранный эмодзи привычки
    private var selectedEmoji: String? {
        didSet {
            updateCreateButtonState()
        }
    }

    // Выбранный цвет привычки
    private var selectedColor: UIColor? {
        didSet {
            updateCreateButtonState()
        }
    }

    // MARK: - UI Components

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

        // используем Configuration, чтобы легко добавлять подпись с выбранными днями недели
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

    // Прокручиваемый контейнер экрана
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    // Внутренний контейнер для всех элементов внутри scrollView
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

        title = "Новая привычка"
        navigationController?.navigationBar.prefersLargeTitles = false

        setupSubviews()
        setupConstraints()
        setupHideKeyboardGesture() // скрытие клавиатуры по тапу на экран
    }

    // MARK: - Public Methods

    // Сохраняет выбранный эмодзи
    func didSelectEmoji(_ emoji: String) {
        selectedEmoji = emoji
    }

    // Сохраняет выбранный цвет
    func didSelectColor(_ color: UIColor) {
        selectedColor = color
    }

    // MARK: - Private Methods

    // Добавление подпредставлений
    private func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(textField)

        contentView.addSubview(optionsContainerView)
        optionsContainerView.addSubview(categoryButton)
        optionsContainerView.addSubview(separatorView)
        optionsContainerView.addSubview(scheduleButton)

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

    // Проверяем, введено ли название и выбраны ли расписание, эмодзи и цвет
    private func updateCreateButtonState() {
        let name = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let isValid = !name.isEmpty && !selectedSchedule.isEmpty && selectedEmoji != nil && selectedColor != nil
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? (UIColor(named: "Black [day]") ?? .black) : .gray
    }

    // Обновляем подпись под кнопкой «Расписание» (например, «Пн, Ср, Пт» или «Каждый день»)
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

    // Жест для скрытия клавиатуры при нажатии на свободное место
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
        guard let selectedEmoji, let selectedColor else { return }

        let newTracker = Tracker(
            id: UUID(),
            name: name,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedSchedule
        )

        delegate?.didCreateTracker(newTracker, categoryTitle: defaultCategoryTitle) // передаём трекер через делегат
        view.window?.rootViewController?.dismiss(animated: true) // закрываем оба модальных окна
    }
}

// MARK: - UITextFieldDelegate

extension CreateTrackerViewController: UITextFieldDelegate {
    // Закрытие клавиатуры по кнопке Done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // Ограничение длины вводимого названия до 38 символов
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 38
    }
}
