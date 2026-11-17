//
//  TrackerCategory.swift
//  Tracker
//

import Foundation

/// Модель категории трекеров: хранит название заголовка категории и список привязанных к ней трекеров
public struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}
