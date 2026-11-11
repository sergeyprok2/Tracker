//
//  EmojiCollectionView.swift
//  Tracker
//
//

import UIKit

protocol EmojiCollectionViewDelegate: AnyObject {
    func didSelectEmoji(_ emoji: String)
}

final class EmojiCollectionView: UIView {
    
    weak var delegate: EmojiCollectionViewDelegate?
    
    private let emojiList: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    private let params = GeometricParams(cellCount: 6, leftInset: 18, rightInset: 19, cellSpacing: 5)

    private lazy var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false  //  отключить у коллекции собственную прокрутку
        collectionView.dataSource = self
        collectionView.delegate = self
        // Регистрация кастомной ячейки
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collectionView.register(TrackerCategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeader.identifier)
        return collectionView
    }()
    
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

extension EmojiCollectionView: UICollectionViewDataSource {
    
    // 2. Количество элементов в секции:
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiList.count
    }
    
    // 3. Создание ячейки:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(emoji: emojiList[indexPath.row])
        
        return cell
    }
    
    // заголовок каждой категории.
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerCategoryHeader.identifier, for: indexPath) as? TrackerCategoryHeader else { // безопасное приведение типа через guard let ... as? TrackerCategoryHeader else
            return UICollectionReusableView() // возвращаем пустой UICollectionReusableView, если каст не удался
        }
        header.configure(title: "Emoji") // передаём только название категории
        return header
    }
}

extension EmojiCollectionView: UICollectionViewDelegateFlowLayout {

    // формула из урока, параметры берём из params.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - params.paddingWidth
        let cellWidth = availableWidth / CGFloat(params.cellCount)

        return CGSize(width: cellWidth, height: 52)
    }
    
    // высота заголовка категории.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 20)
    }


    // боковые отступы берём из params.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: params.leftInset, bottom: 24, right: params.rightInset)
    }

    // промежуток берём из тех же параметров, что и при расчёте ширины.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emoji = emojiList[indexPath.row]
        delegate?.didSelectEmoji(emoji)
    }
}
                                    
