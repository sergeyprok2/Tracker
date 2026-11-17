//
//  DaysValueTransformer.swift
//  Tracker
//

import Foundation

/// Класс-переводчик (трансформер) для Core Data: превращает массив дней недели [WeekDay] в бинарные данные Data при сохранении в базу и обратно при чтении
@objc
final class DaysValueTransformer: ValueTransformer {
    // MARK: - Public Methods

    // Тип данных, в который конвертируем (NSData)
    override class func transformedValueClass() -> AnyClass { NSData.self }

    // Разрешаем обратное преобразование из базы в массив
    override class func allowsReverseTransformation() -> Bool { true }

    // Упаковывает массив [WeekDay] в Data перед сохранением в Core Data
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [WeekDay] else { return nil }
        return try? JSONEncoder().encode(days)
    }

    // Распаковывает Data из базы обратно в массив [WeekDay]
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([WeekDay].self, from: data as Data)
    }

    // Регистрирует трансформер в памяти при старте приложения
    static func register() {
        ValueTransformer.setValueTransformer(
            DaysValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: DaysValueTransformer.self))
        )
    }
}
