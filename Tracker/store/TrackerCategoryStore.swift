//
//  TrackerCategoryStore.swift
//  Tracker
//

import UIKit
import CoreData

/// Хранилище (Store) для работы с категориями в базе данных Core Data: ищет существующую категорию по имени или создаёт новую
final class TrackerCategoryStore: NSObject {
    // MARK: - Private Properties

    // Контекст Core Data для выполнения запросов и сохранения категорий
    private let context: NSManagedObjectContext

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
    }

    // MARK: - Public Methods

    // Ищет категорию с указанным названием в базе, а если её ещё нет — создаёт и сохраняет новую
    func fetchOrCreateCategory(title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), title)
        let categories = try context.fetch(request)
        if let existingCategory = categories.first {
            return existingCategory
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = title
            try context.save()
            return newCategory
        }
    }
}
