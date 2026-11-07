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
        // Используем .custom, чтобы UIKit вообще не лез в цвета и не пытался ничего перекрашивать
        let button = UIButton(type: .custom)
        
        // Загружаем картинку из Ассетов
        let image = UIImage(named: "Plus")
        button.setImage(image, for: .normal)
        
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
        fatalError("init(coder:) has not been implemented")
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
        // Устанавливаем текст, эмодзи и цвета из объекта tracker
        textCard.text = tracker.name
        emodjCard.text = tracker.emoji
        
        // Устанавливаем количество пройденных дней
        textDay.text = "\(completedDays) дней"
        
        // Меняем иконку кнопки в зависимости от того, выполнен трекер или нет
        let buttonImageName = isCompleted ? "Checkmark" : "Plus"
        actionButton.setImage(UIImage(named: buttonImageName), for: .normal)
        
        // Делаем кнопку чуть полупрозрачной, если трекер выполнен
        actionButton.alpha = isCompleted ? 0.5 : 1.0
    }
}
