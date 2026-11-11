//
//  EmojiCell.swift
//  Tracker
//
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    
    static let identifier = "EmojiCell"
    
    override var isSelected: Bool {
        didSet{
            if isSelected {
                contentView.backgroundColor = .lightGray1
            } else {
                contentView.backgroundColor = .clear
            }
        }
    }
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
    
    func configure(emoji: String) {
        emojiLabel.text = emoji
    }
    
}
