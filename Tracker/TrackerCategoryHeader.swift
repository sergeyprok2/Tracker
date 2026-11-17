//
//  TrackerCategoryHeader.swift
//  Tracker
//

import UIKit

/// Переиспользуемый заголовок секции UICollectionView: отображает жирное название категории (а также заголовки «Emoji» и «Цвет»)
final class TrackerCategoryHeader: UICollectionReusableView {
    // MARK: - Properties

    static let identifier = "TrackerCategoryHeader"

    // MARK: - UI Components

    // Текстовая метка заголовка секции
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(named: "Black [day]") ?? .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    // Устанавливает текст заголовка секции
    func configure(title: String) {
        titleLabel.text = title
    }
}
