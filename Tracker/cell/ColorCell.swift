//
//  ColorCell.swift
//  Tracker
//

import UIKit

/// Ячейка коллекции с цветным квадратом для выбора цвета будущего трекера
final class ColorCell: UICollectionViewCell {
    // MARK: - Properties

    static let identifier = "ColorCell"

    // При выборе ячейки рисуем вокруг неё полупрозрачную рамку в цвет квадрата
    override var isSelected: Bool {
        didSet {
            if isSelected {
                contentView.layer.borderWidth = 3 // рамка толщиной 3 на внешней коробке contentView
                contentView.layer.borderColor = colorView.backgroundColor?.withAlphaComponent(0.3).cgColor // берём цвет квадратика с прозрачностью 0.3
            } else {
                contentView.layer.borderWidth = 0 // убираем рамку при снятии выбора
            }
        }
    }

    // MARK: - UI Components

    // Внутренний цветной квадрат размером 40x40 внутри ячейки
    private lazy var colorView: UIView = {
        let color = UIView()
        color.layer.cornerRadius = 8
        color.layer.masksToBounds = true
        color.translatesAutoresizingMaskIntoConstraints = false
        return color
    }()

    // MARK: - Initialization

    // Инициализатор для создания ячейки в коде
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.addSubview(colorView)

        colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        colorView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        colorView.widthAnchor.constraint(equalToConstant: 40).isActive = true
    }

    // Обязательный инициализатор для работы со сторибордами (требует компилятор)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Public Methods

    // Устанавливает переданный цвет для внутреннего квадрата ячейки
    func configure(color: UIColor) {
        colorView.backgroundColor = color
    }
}
