//
//  UIColorMarshalling.swift
//  Tracker
//

import UIKit

/// Вспомогательный класс-конвертер цвета: переводит UIColor в текстовый HEX-код (например, "FD4C49") для хранения в Core Data и обратно в UIColor
final class UIColorMarshalling {
    // MARK: - Public Methods

    // Преобразует объект UIColor в шестнадцатеричную строку (HEX)
    func hexString(from color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        return String.init(
            format: "%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
    }

    // Восстанавливает объект UIColor из шестнадцатеричной строки (HEX)
    func color(from hex: String) -> UIColor {
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
