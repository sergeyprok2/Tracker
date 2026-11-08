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
    
    // текущая выбранная дата (по требованию ТЗ).
    var currentDate: Date = Date()
    
    // отфильтрованные категории, которые реально показываются на экране.
    private var visibleCategories: [TrackerCategory] = []

    
    // MARK: - Private Properties
    
    private let cellIdentifier = "cell"
    // контроллер поисковой строки.
    private let searchController = UISearchController(searchResultsController: nil)

    
    // ДОБАВЛЕНО: две колонки, боковые отступы 16, промежуток 9.
    private let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 8)

    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 66, right: 0)
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
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitle("Фильтры", for: .normal)
        button.setTitleColor(.whiteDay, for: .normal)
        button.backgroundColor = .blue1
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapFiltersButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteDay // явно задаём белый фон экрана

        
        setupNavigationBar()
        setupSubviews()
        setupConstraints()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Регистрация кастомной ячейки
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: cellIdentifier)
        // регистрация заголовка категории
        collectionView.register(TrackerCategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeader.identifier)

        
        
        
        // Временные тестовые данные, чтобы увидеть ячейку на экране
//        let testTracker = Tracker(
//            id: UUID(),
//            name: "Тестовый трекер",
//            color: .systemBlue,
//            emoji: "🔥",
//            schedule: WeekDay.allCases // показываем во все дни недели для теста
//        )
//        categories = [
//            TrackerCategory(title: "Полезные привычки", trackers: [testTracker])
//        ]
        
        reloadVisibleCategories() // вместо reloadData() и reloadPlaceholder() вызываем общий метод фильтрации

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
        datePicker.locale = Locale(identifier: "ru_RU") // цифровой формат даты (08.11.2026) как в макете
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        // ограничиваем ширину пикера, чтобы белая капсула не растягивалась влево
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        let rightBarButton = UIBarButtonItem(customView: datePicker)
        // убираем внешнюю белую капсулу iOS 26 у кнопок навигации (если доступно в SDK)
        if #available(iOS 26.0, *) {
            addTrackerButton.hidesSharedBackground = true
            rightBarButton.hidesSharedBackground = true
        }
        navigationItem.rightBarButtonItem = rightBarButton

        
        // поисковая строка под заголовком «Трекеры».
        searchController.searchBar.placeholder = "Поиск"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date // ИЗМЕНЕНО: сохраняем выбранную дату в свойство currentDate
        reloadVisibleCategories() // ИЗМЕНЕНО: пересчитываем список подходящих трекеров и обновляем экран
    }

    /// Обрабатывает нажатие на кнопку добавления нового трекера.
    @objc private func didTappedAddButton() {
        let createTrackerTypeVC = CreateTrackerTypeViewController() // ИЗМЕНЕНО: открываем выбор типа трекера
        createTrackerTypeVC.delegate = self // ДОБАВЛЕНО: назначаем себя делегатом
        let navController = UINavigationController(rootViewController: createTrackerTypeVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    @objc private func didTapFiltersButton() {
        
    }


    
    /// Добавляет основные дочерние вьюхи на корневой экран.
    private func setupSubviews() {
        view.addSubview(placeholderContainerView)
        view.addSubview(collectionView)
        view.addSubview(filtersButton)
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
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    // фильтрует categories по выбранному дню недели (currentDate) и тексту поиска.
    private func reloadVisibleCategories() {
        guard let filterWeekday = WeekDay.from(date: currentDate) else { return }
        let searchText = (searchController.searchBar.text ?? "").lowercased()
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                // 1. Проверяем день недели (для нерегулярного события после выполнения показываем только в дату выполнения)
                let matchesDay: Bool
                if tracker.schedule.isEmpty {
                    if let completedRecord = completedTrackers.first(where: { $0.trackerId == tracker.id }) {
                        matchesDay = Calendar.current.isDate(completedRecord.date, inSameDayAs: currentDate)
                    } else {
                        matchesDay = true
                    }
                } else {
                    matchesDay = tracker.schedule.contains(filterWeekday)
                }
                
                // 2. Проверяем поиск (если строка пустая — подходят все названия)
                let matchesSearch = searchText.isEmpty || tracker.name.lowercased().contains(searchText)
                
                return matchesDay && matchesSearch
            }
            
            // Если после фильтрации в категории не осталось трекеров — саму категорию (и её заголовок) не показываем
            if trackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(title: category.title, trackers: trackers)
        }
        
        collectionView.reloadData()
        reloadPlaceholder()
    }


    /// Проверяет, есть ли трекеры для отображения, и управляет заглушкой
    private func reloadPlaceholder() {
        let hasVisibleTrackers = !visibleCategories.isEmpty // проверяем отфильтрованный массив, а не исходный
        placeholderContainerView.isHidden = hasVisibleTrackers
        collectionView.isHidden = !hasVisibleTrackers
        filtersButton.isHidden = !hasVisibleTrackers
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
        
        reloadVisibleCategories() // обновляем видимые категории и коллекцию после добавления трекера
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count // берём количество из отфильтрованных категорий
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count // берём трекеры из отфильтрованных категорий
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row] // читаем из visibleCategories
        let trackerId = tracker.id
        
        let isCompleted = completedTrackers.contains { record in
            let isSameDay = Calendar.current.isDate(record.date, inSameDayAs: currentDate) // используем currentDate
            return record.trackerId == trackerId && isSameDay
        }
        
        let completedDays = completedTrackers.filter { $0.trackerId == trackerId }.count
        
        cell.configure(with: tracker, isCompleted: isCompleted, completedDays: completedDays)
        
        return cell
    }
    
    // заголовок каждой категории.
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerCategoryHeader.identifier, for: indexPath) as? TrackerCategoryHeader else { // безопасное приведение типа через guard let ... as? TrackerCategoryHeader else
            return UICollectionReusableView() // возвращаем пустой UICollectionReusableView, если каст не удался
        }
        header.configure(title: visibleCategories[indexPath.section].title) // передаём только название категории
        return header
    }


}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    
}

// MARK: - TrackerCellDelegate Implementation
extension TrackersViewController: TrackerCellDelegate {
    
    func completedTracker(cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        // Защита от будущих дат (сравниваем только дни, без учета часов и минут)
        let calendar = Calendar.current
        if calendar.compare(currentDate, to: Date(), toGranularity: .day) == .orderedDescending { // сравниваем с currentDate
            return
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row] // берём трекер из visibleCategories
        
        let isCompleted = completedTrackers.contains { record in
            let isSameDay = calendar.isDate(record.date, inSameDayAs: currentDate) // проверяем по currentDate
            return record.trackerId == tracker.id && isSameDay
        }
        
        if isCompleted {
            uncompleteTracker(id: tracker.id, date: currentDate) // передаём currentDate
        } else {
            completeTracker(id: tracker.id, date: currentDate) // передаём currentDate
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
}


extension TrackersViewController: UICollectionViewDelegateFlowLayout {

    // формула из урока, параметры берём из params.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - params.paddingWidth
        let cellWidth = availableWidth / CGFloat(params.cellCount)

        return CGSize(width: cellWidth, height: 148)
    }
    
    // высота заголовка категории.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 20)
    }


    // боковые отступы берём из params.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: params.leftInset, bottom: 12, right: params.rightInset)
    }

    // промежуток берём из тех же параметров, что и при расчёте ширины.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// обновление коллекции при изменении текста поиска.
extension TrackersViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        reloadVisibleCategories() // при вводе текста в поиск фильтруем трекеры
    }
}

// MARK: - TrackerCreationDelegate (ДОБАВЛЕНО: получаем созданный трекер через делегат)
extension TrackersViewController: TrackerCreationDelegate {
    
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String) {
        addTracker(tracker, toCategoryTitle: categoryTitle)
    }
}






