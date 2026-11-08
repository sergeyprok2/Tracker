//
//  ScheduleViewController.swift
//  Tracker

//

import UIKit

final class ScheduleViewController: UIViewController {

    // MARK: - Properties (Свойства и данные экрана)
    
    // Словарь для отслеживания состояния переключателей (выбран день или нет)
    private var selectedDays: [WeekDay: Bool] = [:]
    
    // Замыкание (closure) для передачи выбранного массива дней обратно на экран создания привычки
    var onScheduleSelected: (([WeekDay]) -> Void)?
    
    // принимаем уже выбранные дни, чтобы переключатели не сбрасывались при повторном входе
    init(selectedDays: [WeekDay] = []) {
        super.init(nibName: nil, bundle: nil)
        for day in selectedDays {
            self.selectedDays[day] = true
        }
    }
    
    // обязательный инициализатор при добавлении своего init
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - UI Elements (Создание графических элементов)
    
    // Общий скругленный контейнер-подложка для всей таблицы с днями недели
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundDay
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Таблица для отображения списка дней недели
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .singleLine
        table.isScrollEnabled = false // Фиксированная высота ровно под 7 дней, скролл не нужен
        table.delegate = self
        table.dataSource = self
        table.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // Кнопка «Готово» в нижней части экрана для подтверждения выбора
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle (Жизненный цикл контроллера)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Установка нативного заголовка в Navigation Bar
        title = "Расписание"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupSubviews()
        setupConstraints()
    }

    // MARK: - Setup Layout (Настройка иерархии и констрейнтов)
    
    private func setupSubviews() {
        view.addSubview(containerView)
        containerView.addSubview(tableView)
        view.addSubview(doneButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Контейнер с таблицей дней недели под навигационным баром
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 75 * 7), // 7 ячеек по 75 пунктов высоты
            
            // Таблица заполняет весь контейнер целиком
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Нижняя кнопка «Готово» с привязкой к безопасной зоне экрана
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Actions (Обработчики нажатий)
    
    @objc private func didTapDoneButton() {
        // Фильтруем и собираем только те дни недели, у которых переключатель в положении true
        let activeDays = WeekDay.allCases.filter { selectedDays[$0] == true }
        
        // Передаем выбранный массив дней через замыкание назад и закрываем модальное окно
        onScheduleSelected?(activeDays)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate (Настройка таблицы дней недели)

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Количество строк в таблице соответствует количеству дней в перечислении WeekDay
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        WeekDay.allCases.count
    }
    
    // Конфигурация ячейки для каждого дня недели
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.identifier, for: indexPath) as? ScheduleCell else {
            return UITableViewCell()
        }
        
        let day = WeekDay.allCases[indexPath.row]
        let isOn = selectedDays[day] ?? false
        
        // Настраиваем ячейку и передаем замыкание отслеживания свитча
        cell.configure(with: day.stringValue, isOn: isOn) { [weak self] isSwitchOn in
            self?.selectedDays[day] = isSwitchOn
        }
        
        // Убираем разделительную линию у самой нижней ячейки контейнера
        cell.separatorInset = indexPath.row == WeekDay.allCases.count - 1 ?
            UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.width + 1000) :
            UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        cell.selectionStyle = .none // убираем серую подсветку ячейки при нажатии
        return cell
    }
    
    // Фиксированная высота каждой строки таблицы
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - ScheduleCell (Кастомная ячейка дня недели с переключателем UISwitch)

final class ScheduleCell: UITableViewCell {
    static let identifier = "ScheduleCell"
    
    // Замыкание для передачи состояния свитча наружу в контроллер
    private var switchChangedAction: ((Bool) -> Void)?
    
    // Текстовая метка с названием дня недели
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Интерактивный переключатель UISwitch на правом крае ячейки
    private lazy var daySwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = .systemBlue // Цвет активного переключателя по гайдлайнам
        switcher.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        switcher.translatesAutoresizingMaskIntoConstraints = false
        return switcher
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupCellSubviews()
        setupCellConstraints()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupCellSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(daySwitch)
    }
    
    private func setupCellConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // Метод внешнего наполнения ячейки данными
    func configure(with title: String, isOn: Bool, action: @escaping (Bool) -> Void) {
        titleLabel.text = title
        daySwitch.isOn = isOn
        switchChangedAction = action
    }
    
    // Действие при переключении тумблера
    @objc private func switchChanged(_ sender: UISwitch) {
        switchChangedAction?(sender.isOn)
    }
}
