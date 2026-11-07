//
//  File.swift
//  Tracker
//
//

import UIKit

/// Экран «Трекеры», отображающий список привычек и событий,
/// а также пустой соус (placeholder) при отсутствии данных.
final class TrackersViewController: UIViewController {
    
    // Список категорий и вложенных в них трекеров
    var categories: [TrackerCategory] = []
    
    // Список выполненных трекеров
    var completedTrackers: [TrackerRecord] = []
    
    // MARK: - Private Properties
    
    private let cellIdentifier = "cell"
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "trackers_placeholder")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "Black [day]")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var placeholderContainerView: UIView = {
        let containerView = UIView()
        containerView.addSubview(placeholderImageView)
        containerView.addSubview(placeholderLabel)
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    // MARK: - Lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupSubviews()
        setupConstraints()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Регистрация кастомной ячейки
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        
        
        // Временные тестовые данные, чтобы увидеть ячейку на экране
        let testTracker = Tracker(
            id: UUID(),
            name: "Тестовый трекер",
            color: .systemBlue,
            emoji: "🔥",
            schedule: []
        )
        categories = [
            TrackerCategory(title: "Полезные привычки", trackers: [testTracker])
        ]
        collectionView.reloadData()
        
        reloadPlaceholder() // Вызываем нашу проверку при запуске
    }
    
    // MARK: - Private Methods
    
    /// Настраивает внешний вид и элементы навигационной панели.
    private func setupNavigationBar() {
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addTrackerButton = UIBarButtonItem(
            image: UIImage(named: "add_tracker"),
            style: .plain,
            target: self,
            action: #selector(didTappedAddButton)
        )
        navigationItem.leftBarButtonItem = addTrackerButton
        
        let datePicker = UIDatePicker()
        let currentDate = Date()
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -10, to: currentDate)
        let maxDate = calendar.date(byAdding: .year, value: 10, to: currentDate)
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
        
        collectionView.reloadData()
        reloadPlaceholder() // Вызываем нашу проверку при запуске
    }
    
    /// Обрабатывает нажатие на кнопку добавления нового трекера.
    @objc private func didTappedAddButton() {
        // Логика открытия экрана создания трекера
        let createTrackerTypeVC = CreateTrackerTypeViewController()
        let navController = UINavigationController(rootViewController: createTrackerTypeVC)
        navController.modalPresentationStyle = .pageSheet // или .automatic, чтобы открывалось шторкой
        present(navController, animated: true)
    }
    
    /// Добавляет основные дочерние вьюхи на корневой экран.
    private func setupSubviews() {
        view.addSubview(placeholderContainerView)
        view.addSubview(collectionView)
    }
    
    /// Устанавливает констрейнты для элементов интерфейса через Auto Layout.
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            placeholderContainerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            placeholderContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            placeholderContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            placeholderContainerView.heightAnchor.constraint(equalToConstant: 106),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: placeholderContainerView.centerXAnchor),
            placeholderImageView.topAnchor.constraint(equalTo: placeholderContainerView.topAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderContainerView.centerXAnchor),
            
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    /// Проверяет, есть ли трекеры для отображения, и управляет заглушкой
    private func reloadPlaceholder() {
        // Проверяем, есть ли хоть один трекер во всех категориях
        let hasTrackers = categories.contains { !$0.trackers.isEmpty }
        
        // Если трекеров нет, показываем заглушку, иначе скрываем
        placeholderContainerView.isHidden = hasTrackers
        collectionView.isHidden = !hasTrackers
    }
}

// MARK: - Tracker Operations Extensions
extension TrackersViewController {
    
    func completeTracker(id: UUID, date: Date) {
        let newRecord = TrackerRecord(trackerId: id, date: date)
        completedTrackers.append(newRecord)
    }
    
    func uncompleteTracker(id: UUID, date: Date) {
        completedTrackers.removeAll { record in
            let isSameDay = Calendar.current.isDate(record.date, inSameDayAs: date)
            return record.trackerId == id && isSameDay
        }
    }
    
    func addTracker(_ tracker: Tracker, toCategoryTitle categoryTitle: String) {
        if let categoryIndex = categories.firstIndex(where: { $0.title == categoryTitle }) {
            let existingCategory = categories[categoryIndex]
            let updatedTrackers = existingCategory.trackers + [tracker]
            let updatedCategory = TrackerCategory(
                title: existingCategory.title,
                trackers: updatedTrackers
            )
            var newCategories = categories
            newCategories[categoryIndex] = updatedCategory
            categories = newCategories
        } else {
            let newCategory = TrackerCategory(
                title: categoryTitle,
                trackers: [tracker]
            )
            categories = categories + [newCategory]
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        
        let datePicker = (navigationItem.rightBarButtonItem?.customView as? UIDatePicker) ?? UIDatePicker()
        let selectedDate = datePicker.date
        
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        let trackerId = tracker.id
        
        let isCompleted = completedTrackers.contains { record in
            let isSameDay = Calendar.current.isDate(record.date, inSameDayAs: selectedDate)
            return record.trackerId == trackerId && isSameDay
        }
        
        let completedDays = completedTrackers.filter { $0.trackerId == trackerId }.count
        
        cell.configure(with: tracker, isCompleted: isCompleted, completedDays: completedDays)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    
}

// MARK: - TrackerCellDelegate Implementation
extension TrackersViewController: TrackerCellDelegate {
    
    func completedTracker(cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let datePicker = (navigationItem.rightBarButtonItem?.customView as? UIDatePicker) ?? UIDatePicker()
        let selectedDate = datePicker.date
        
        // Защита от будущих дат (сравниваем только дни, без учета часов и минут)
        let calendar = Calendar.current
        if calendar.compare(selectedDate, to: Date(), toGranularity: .day) == .orderedDescending {
            return // Если дата в будущем — ничего не делаем
        }
        
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        
        let isCompleted = completedTrackers.contains { record in
            let isSameDay = calendar.isDate(record.date, inSameDayAs: selectedDate)
            return record.trackerId == tracker.id && isSameDay
        }
        
        if isCompleted {
            uncompleteTracker(id: tracker.id, date: selectedDate)
        } else {
            completeTracker(id: tracker.id, date: selectedDate)
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    // Размер ячейки (ширина — половина экрана минус отступы, высота — 148)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - 32 - 9 // 16 отступы по краям + 9 между ячейками
        let cellWidth = availableWidth / 2
        return CGSize(width: cellWidth, height: 148)
    }
    
    // Отступы от краев коллекции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    }
}
