//
//  Tracker.swift
//  Tracker
//
//

import UIKit

enum WeekDay: Int, Codable, CaseIterable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    // Русское название дня недели прямо в модели
    public var stringValue: String {
        switch self {
        case .monday: "Понедельник"
        case .tuesday: "Вторник"
        case .wednesday: "Среда"
        case .thursday: "Четверг"
        case .friday: "Пятница"
        case .saturday: "Суббота"
        case .sunday: "Воскресенье"
        }
    }
    
    // переводим системный номер дня недели (где 1 — воскресенье) в наш WeekDay (где 1 — понедельник).
    static func from(date: Date) -> WeekDay? {
        let systemWeekday = Calendar.current.component(.weekday, from: date)
        let convertedIndex = systemWeekday == 1 ? 7 : systemWeekday - 1
        return WeekDay(rawValue: convertedIndex)
    }
}

public struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
}
