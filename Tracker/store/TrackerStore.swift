//
//  TrackerStore.swift
//  Tracker
//

import UIKit
import CoreData

/// Протокол для уведомления экрана трекеров о том, что данные в базе Core Data изменились
protocol TrackerStoreDelegate: AnyObject {
    func storeDidUpdate()
}

/// Хранилище (Store) для работы с трекерами в Core Data: сохраняет новые трекеры, следит за изменениями через NSFetchedResultsController и собирает массив категорий
final class TrackerStore: NSObject {
    // MARK: - Properties

    weak var delegate: TrackerStoreDelegate?

    // Готовый список категорий с трекерами, сгруппированный контроллером выборки из базы
    var categories: [TrackerCategory] {
        guard let sections = fetchedResultsController.sections else { return [] }
        return sections.compactMap { section in
            guard let trackersCoreData = section.objects as? [TrackerCoreData] else { return nil }
            let trackers = trackersCoreData.compactMap { makeTracker(from: $0) }
            return TrackerCategory(title: section.name, trackers: trackers)
        }
    }

    // MARK: - Private Properties

    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private let categoryStore: TrackerCategoryStore

    // Контроллер автоматической выборки и группировки трекеров по названию категории из базы данных
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category.title", ascending: true), NSSortDescriptor(key: "name", ascending: true)]

        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "category.title", cacheName: nil)
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()

    // MARK: - Initialization

    convenience override init() {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            self.init(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
            return
        }
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
        self.categoryStore = TrackerCategoryStore(context: context)
    }

    // MARK: - Public Methods

    // Создаёт объект TrackerCoreData, привязывает его к категории и сохраняет в базу данных
    func addTracker(tracker: Tracker, categoryTitle: String) throws {
        let categoryCoreData = try categoryStore.fetchOrCreateCategory(title: categoryTitle)

        let trackerCoreData = TrackerCoreData(context: context)

        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.schedule = tracker.schedule as NSObject
        trackerCoreData.category = categoryCoreData

        try context.save()
    }

    // MARK: - Private Methods

    // Преобразует объект базы данных TrackerCoreData в обычную структуру Tracker для интерфейса
    private func makeTracker(from trackerCoreData: TrackerCoreData) -> Tracker? {
        guard let id = trackerCoreData.id, let name = trackerCoreData.name, let emoji = trackerCoreData.emoji, let colorHex = trackerCoreData.color else { return nil }
        let schedule = (trackerCoreData.schedule as? [WeekDay]) ?? []
        let color = uiColorMarshalling.color(from: colorHex)
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    // Вызывается автоматически, когда в базе Core Data добавился, изменился или удалился трекер
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate()
    }
}
