//
//  TrackersViewController.swift
//  Tracker
//

import UIKit

/// Главный экран «Трекеры»: отображает коллекцию карточек привычек и событий по категориям, поиск, выбор даты, заглушку и работу со сторами Core Data
final class TrackersViewController: UIViewController {
    // MARK: - Private Properties

    // Список категорий и вложенных в них трекеров
    private var categories: [TrackerCategory] = []

    // Список выполненных трекеров
    private var completedTrackers: [TrackerRecord] = []

    // Текущая выбранная дата (по требованию ТЗ).
    private var currentDate: Date = Date()

    // Отфильтрованные категории, которые реально показываются на экране.
    private var visibleCategories: [TrackerCategory] = []

    private let cellIdentifier = "cell"

    // Контроллер поисковой строки.
    private let searchController = UISearchController(searchResultsController: nil)
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()

    // Две колонки, боковые отступы 16, промежуток 8.
    private let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 8)

    // MARK: - UI Components

    // Коллекция для отображения категорий и карточек трекеров
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 66, right: 0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    // Картинка-заглушка при отсутствии трекеров
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "trackers_placeholder")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // Текст под картинкой-заглушкой
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "Black [day]")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Контейнер, объединяющий картинку и текст заглушки
    private lazy var placeholderContainerView: UIView = {
        let containerView = UIView()
        containerView.addSubview(placeholderImageView)
        containerView.addSubview(placeholderLabel)
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()

    // Плавающая синяя кнопка «Фильтры» внизу экрана
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

    // MARK: - Initialization

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

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
        // Регистрация заголовка категории
        collectionView.register(TrackerCategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeader.identifier)
        trackerStore.delegate = self

        categories = trackerStore.categories
        completedTrackers = (try? trackerRecordStore.fetchRecords()) ?? []

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

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date // сохраняем выбранную дату в свойство currentDate
        reloadVisibleCategories() // пересчитываем список подходящих трекеров и обновляем экран
    }

    /// Обрабатывает нажатие на кнопку добавления нового трекера.
    @objc private func didTappedAddButton() {
        let createTrackerTypeVC = CreateTrackerTypeViewController() // открываем выбор типа трекера
        createTrackerTypeVC.delegate = self // назначаем себя делегатом
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

    // Фильтрует categories по выбранному дню недели (currentDate) и тексту поиска.
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
    // Сохраняет отметку о выполнении трекера в Core Data и обновляет массив выполненных записей
    private func completeTracker(id: UUID, date: Date) {
        try? trackerRecordStore.addRecord(trackerId: id, date: date)
        completedTrackers = (try? trackerRecordStore.fetchRecords()) ?? []
    }

    // Удаляет отметку о выполнении трекера из Core Data и обновляет массив выполненных записей
    private func uncompleteTracker(id: UUID, date: Date) {
        try? trackerRecordStore.deleteRecord(trackerId: id, date: date)
        completedTrackers = (try? trackerRecordStore.fetchRecords()) ?? []
    }

    // Передаёт новый трекер в TrackerStore для сохранения в базу данных
    private func addTracker(_ tracker: Tracker, toCategoryTitle categoryTitle: String) {
        try? trackerStore.addTracker(tracker: tracker, categoryTitle: categoryTitle)
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    // Количество секций равно числу видимых категорий
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count // берём количество из отфильтрованных категорий
    }

    // Количество карточек трекеров в конкретной категории
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count // берём трекеры из отфильтрованных категорий
    }

    // Создание и настройка ячейки карточки трекера
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

    // Заголовок каждой категории.
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

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    // Обработка нажатия на круглую кнопку выполнения трекера в ячейке
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

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    // Формула из урока, параметры берём из params.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - params.paddingWidth
        let cellWidth = availableWidth / CGFloat(params.cellCount)

        return CGSize(width: cellWidth, height: 148)
    }

    // Высота заголовка категории.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 20)
    }

    // Боковые отступы берём из params.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: params.leftInset, bottom: 12, right: params.rightInset)
    }

    // Промежуток берём из тех же параметров, что и при расчёте ширины.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }

    // Вертикальный отступ между строками карточек в секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    // Обновление коллекции при изменении текста поиска.
    func updateSearchResults(for searchController: UISearchController) {
        reloadVisibleCategories() // при вводе текста в поиск фильтруем трекеры
    }
}

// MARK: - TrackerCreationDelegate

extension TrackersViewController: TrackerCreationDelegate {
    // Получаем созданный трекер через делегат и сохраняем его
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String) {
        addTracker(tracker, toCategoryTitle: categoryTitle)
    }
}

// MARK: - TrackerStoreDelegate

extension TrackersViewController: TrackerStoreDelegate {
    // Обновляем список категорий и экран при любых изменениях в базе Core Data
    func storeDidUpdate() {
        categories = trackerStore.categories
        reloadVisibleCategories()
    }
}
