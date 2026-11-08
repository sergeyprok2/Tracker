//
//  TrackerRecord.swift
//  Tracker
//
//

import Foundation

public struct TrackerRecord: Hashable {  // Hashable для быстрой работы с Set
    let trackerId: UUID
    let date: Date
}
