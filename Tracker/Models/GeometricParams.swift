//
//  GeometricParams.swift
//  Tracker
//

import UIKit

/// Вспомогательная структура для хранения отступов и количества колонок, чтобы удобно считать ширину ячеек UICollectionView
struct GeometricParams {
    // MARK: - Properties

    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    let paddingWidth: CGFloat

    // MARK: - Initialization

    init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}
