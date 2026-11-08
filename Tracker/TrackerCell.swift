//
//  TrackerCell.swift
//  Tracker
//
//

import UIKit

/// Протокол для передачи нажатия кнопки из ячейки в контроллер
protocol TrackerCellDelegate: AnyObject {
    func completedTracker(cell: TrackerCell)
}

final class TrackerCell: UICollectionViewCell {
    
    // Ссылка на делегат (обязательно weak, чтобы не было утечки памяти)
    weak var delegate: TrackerCellDelegate?
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Color selection 5")
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var textCard: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "White [day]")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emodjCard: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textDay: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "Black [day]")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system) // .system позволяет красить иконку через tintColor
        button.tintColor = UIColor(named: "White [day]") ?? .white // белый цвет значка + и галочки
        button.layer.cornerRadius = 17 // половина от 34, чтобы кнопка была ровным кругом
        button.layer.masksToBounds = true // обрезаем края по кругу
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    
    // Инициализатор для создания ячейки в коде
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
        setupConstraints()
    }
    
    // Обязательный инициализатор для работы со сторибордами (требует компилятор)
    required init?(coder: NSCoder) {
        nil
    }
    
    /// Метод вызывается при нажатии на кнопку выполнения трекера
    @objc private func didTapButton() {
        // Вызываем метод делегата, передавая текущую ячейку
        delegate?.completedTracker(cell: self)
    }
    
    private func setupSubviews() {
        contentView.addSubview(cardView)
        contentView.addSubview(bottomView)
        cardView.addSubview(textCard)
        cardView.addSubview(emodjCard)
        bottomView.addSubview(textDay)
        bottomView.addSubview(actionButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            bottomView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomView.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            
            textCard.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            textCard.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            textCard.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            textCard.topAnchor.constraint(equalTo: emodjCard.bottomAnchor, constant: 8),
            
            emodjCard.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emodjCard.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emodjCard.widthAnchor.constraint(equalToConstant: 24),
            emodjCard.heightAnchor.constraint(equalToConstant: 24),
            
            actionButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 8),
            actionButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -12),
            actionButton.widthAnchor.constraint(equalToConstant: 34),
            actionButton.heightAnchor.constraint(equalToConstant: 34),
            
            textDay.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 12),
            textDay.heightAnchor.constraint(equalToConstant: 18),
            textDay.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor)
        ])
    }
    
    /// Конфигурация ячейки данными трекера и его текущим состоянием
    func configure(with tracker: Tracker, isCompleted: Bool, completedDays: Int) {
        textCard.text = tracker.name
        emodjCard.text = tracker.emoji
        cardView.backgroundColor = tracker.color
        
        // правильное склонение слова «день / дня / дней» (1 день, 2 дня, 5 дней)
        textDay.text = formatDaysText(completedDays)
        
        // ставим системный плюс или галочку и красим фон кнопки в цвет карточки
        let pointSize = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        let imageName = isCompleted ? "checkmark" : "plus"
        let image = UIImage(systemName: imageName, withConfiguration: pointSize)
        actionButton.setImage(image, for: .normal)
        actionButton.backgroundColor = tracker.color
        
        // Делаем кнопку чуть полупрозрачной, если трекер выполнен (по макету 0.3)
        actionButton.alpha = isCompleted ? 0.3 : 1.0 // ИЗМЕНЕНО: прозрачность по макету
    }
    
    // функция для правильного склонения (0 дней, 1 день, 2 дня, 5 дней) — как на макете!
    private func formatDaysText(_ count: Int) -> String {
        let remainder100 = count % 100
        let remainder10 = count % 10
        if remainder100 >= 11 && remainder100 <= 14 {
            return "\(count) дней"
        }
        switch remainder10 {
        case 1: return "\(count) день"
        case 2, 3, 4: return "\(count) дня"
        default: return "\(count) дней"
        }
    }

}
