//
//  ColorCollectionView.swift
//  Tracker
//

import UIKit

/// Протокол для передачи выбранного пользователем цвета на экран создания трекера
protocol ColorCollectionViewDelegate: AnyObject {
    func didSelectColor(_ color: UIColor)
}

/// Переиспользуемый блок с заголовком «Цвет» и коллекцией из 18 цветных ячеек (6 колонок в 3 ряда)
final class ColorCollectionView: UIView {
    // MARK: - Properties

    weak var delegate: ColorCollectionViewDelegate?

    // MARK: - Private Properties

    // Фиксированный набор из 18 цветов по макету
    private let colorList: [UIColor] = [
        UIColor(red: 0.99, green: 0.30, blue: 0.29, alpha: 1.0), // 1: #FD4C49
        UIColor(red: 1.00, green: 0.53, blue: 0.12, alpha: 1.0), // 2: #FF881E
        UIColor(red: 0.00, green: 0.48, blue: 0.98, alpha: 1.0), // 3: #007BFA
        UIColor(red: 0.43, green: 0.27, blue: 0.99, alpha: 1.0), // 4: #6E44FE
        UIColor(red: 0.20, green: 0.81, blue: 0.41, alpha: 1.0), // 5: #33CF69
        UIColor(red: 0.90, green: 0.43, blue: 0.83, alpha: 1.0), // 6: #E66DD4
        UIColor(red: 0.98, green: 0.83, blue: 0.83, alpha: 1.0), // 7: #F9D4D4
        UIColor(red: 0.20, green: 0.65, blue: 0.99, alpha: 1.0), // 8: #34A7FE
        UIColor(red: 0.27, green: 0.90, blue: 0.62, alpha: 1.0), // 9: #46E69D
        UIColor(red: 0.21, green: 0.20, blue: 0.49, alpha: 1.0), // 10: #35347C
        UIColor(red: 1.00, green: 0.40, blue: 0.30, alpha: 1.0), // 11: #FF674D
        UIColor(red: 1.00, green: 0.60, blue: 0.80, alpha: 1.0), // 12: #FF99CC
        UIColor(red: 0.96, green: 0.77, blue: 0.55, alpha: 1.0), // 13: #F6C48B
        UIColor(red: 0.47, green: 0.58, blue: 0.96, alpha: 1.0), // 14: #7994F5
        UIColor(red: 0.51, green: 0.17, blue: 0.95, alpha: 1.0), // 15: #832CF1
        UIColor(red: 0.68, green: 0.34, blue: 0.85, alpha: 1.0), // 16: #AD56DA
        UIColor(red: 0.55, green: 0.45, blue: 0.90, alpha: 1.0), // 17: #8D72E6
        UIColor(red: 0.18, green: 0.82, blue: 0.35, alpha: 1.0)  // 18: #2FD058
    ]

    // Геометрические параметры сетки: 6 ячеек в ряд
    private let params = GeometricParams(cellCount: 6, leftInset: 18, rightInset: 19, cellSpacing: 5)

    // MARK: - UI Components

    // Сама коллекция цветов без собственного скролла (прокручивается вместе с внешним UIScrollView)
    private lazy var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false // отключить у коллекции собственную прокрутку
        collectionView.dataSource = self
        collectionView.delegate = self
        // Регистрация кастомной ячейки
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        collectionView.register(TrackerCategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeader.identifier)
        return collectionView
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(collection)

        collection.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collection.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        collection.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collection.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    // Обязательный инициализатор для работы со сторибордами (требует компилятор)
    required init?(coder: NSCoder) {
        nil
    }
}

// MARK: - UICollectionViewDataSource

extension ColorCollectionView: UICollectionViewDataSource {
    // 2. Количество элементов в секции:
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorList.count
    }

    // 3. Создание ячейки:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else {
            return UICollectionViewCell()
        }

        cell.configure(color: colorList[indexPath.row])

        return cell
    }

    // Заголовок каждой категории.
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerCategoryHeader.identifier, for: indexPath) as? TrackerCategoryHeader else { // безопасное приведение типа через guard let ... as? TrackerCategoryHeader else
            return UICollectionReusableView() // возвращаем пустой UICollectionReusableView, если каст не удался
        }
        header.configure(title: "Цвет") // передаём только название категории
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ColorCollectionView: UICollectionViewDelegateFlowLayout {
    // Формула из урока, параметры берём из params.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - params.paddingWidth
        let cellWidth = availableWidth / CGFloat(params.cellCount)

        return CGSize(width: cellWidth, height: 52)
    }

    // Высота заголовка категории.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 20)
    }

    // Боковые отступы берём из params.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: params.leftInset, bottom: 24, right: params.rightInset)
    }

    // Промежуток берём из тех же параметров, что и при расчёте ширины.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }

    // Расстояние между рядами ячеек по вертикали
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // Передача выбранного цвета делегату при нажатии на ячейку
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let color = colorList[indexPath.row]
        delegate?.didSelectColor(color)
    }
}
