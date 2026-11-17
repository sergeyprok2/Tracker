//
//  EmojiCell.swift
//  Tracker
//

import UIKit

/// Ячейка коллекции для отображения одного смайлика (эмодзи) при создании трекера
final class EmojiCell: UICollectionViewCell {
    // MARK: - Properties

    static let identifier = "EmojiCell"

    // При выборе ячейки закрашиваем её подложку светло-серым цветом
    override var isSelected: Bool {
        didSet {
            if isSelected {
                contentView.backgroundColor = .lightGray1
            } else {
                contentView.backgroundColor = .clear
            }
        }
    }

    // MARK: - UI Components

    // Текстовая метка по центру ячейки для показа смайлика
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initialization

    // Инициализатор для создания ячейки в коде
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.addSubview(emojiLabel)

        emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }

    // Обязательный инициализатор для работы со сторибордами (требует компилятор)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Public Methods

    // Устанавливает символ эмодзи в текстовую метку ячейки
    func configure(emoji: String) {
        emojiLabel.text = emoji
    }
}
