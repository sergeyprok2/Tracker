//
//  TrackerRecordStore.swift
//  Tracker
//

import UIKit
import CoreData

/// Хранилище (Store) для работы с отметками о выполнении трекеров (TrackerRecordCoreData) в базе Core Data
final class TrackerRecordStore: NSObject {
    // MARK: - Private Properties

    // Контекст Core Data для добавления, удаления и чтения записей выполнения
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

    // Добавляет в базу новую запись о том, что трекер с указанным id был выполнен в указанную дату
    func addRecord(trackerId: UUID, date: Date) throws {
        let record = TrackerRecordCoreData(context: context)
        record.trackerId = trackerId
        record.date = date

        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        record.tracker = try context.fetch(request).first
        try context.save()
    }

    // Находит и удаляет из базы запись о выполнении трекера за выбранный день (при снятии галочки)
    func deleteRecord(trackerId: UUID, date: Date) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        let records = try context.fetch(request)
        if let recordToDelete = records.first(where: { record in
            guard let recordDate = record.date else { return false }
            return Calendar.current.isDate(recordDate, inSameDayAs: date)
        }) {
            context.delete(recordToDelete)
            try context.save()
        }
    }

    // Загружает все сохранённые отметки о выполнении из базы и переводит их в массив моделей TrackerRecord
    func fetchRecords() throws -> [TrackerRecord] {
        let request = TrackerRecordCoreData.fetchRequest()
        let recordsCoreData = try context.fetch(request)
        return recordsCoreData.compactMap { record in
            guard let trackerId = record.trackerId, let date = record.date else { return nil }
            return TrackerRecord(trackerId: trackerId, date: date)
        }
    }
}
