//
//  TrackerRecord.swift
//  Tracker
//

import Foundation

/// Модель записи о выполнении трекера: связывает id выполненного трекера и конкретную дату, когда нажали «+»
public struct TrackerRecord: Hashable { // Hashable для быстрой работы с Set
    let trackerId: UUID
    let date: Date
}
