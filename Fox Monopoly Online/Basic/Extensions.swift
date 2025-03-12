//
//  Extensions.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 05.02.2025.
//
import UIKit

extension UILabel {
    /// Управляет поворотом текста в UILabel.
    /// При установке значения преобразует градусы в радианы и применяет аффинное преобразование.
    /// - Note: Геттер всегда возвращает 0, так как трансформация не хранит информацию об исходном угле
    var rotation: Int {
        get {
            return .zero
        } set {
            let radians = CGFloat(CGFloat(Double.pi) * CGFloat(newValue) / CGFloat(180.0))
            self.transform = CGAffineTransform(rotationAngle: radians)
        }
    }
}

extension UIColor {
    /// Корректирует яркость цвета, увеличивая RGB-компоненты.
    /// - Parameter factor: Коэффициент коррекции (0.0 - исходный цвет, 1.0 - максимальная яркость).
    /// - Returns: Новый цвет с измененной яркостью.
    /// - Note: При factor > 0 цвет светлеет, при factor < 0 поведение не определено
    func adjust(by factor: CGFloat) -> UIColor {
        var red: CGFloat = .zero
        var green: CGFloat = .zero
        var blue: CGFloat = .zero
        var alpha: CGFloat = .zero
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        red += (1 - red) * factor
        green += (1 - green) * factor
        blue += (1 - blue) * factor

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

public extension String {
    /// Пустая строка для удобства использования вместо литерала ""
    static let empty = ""
}

extension UIFont {
    /// Создает динамически масштабируемый шрифт с указанными параметрами.
    /// - Parameters:
    ///   - style: Текстовый стиль системы (например, .body, .caption1).
    ///   - weight: Насыщенность шрифта (например, .regular, .bold).
    ///   - maxSize: Максимально допустимый размер шрифта (опционально).
    /// - Returns: Масштабируемый шрифт с учетом ограничений размера.
    static func preferredFont(
        forTextStyle style: UIFont.TextStyle,
        weight: UIFont.Weight,
        maxSize: CGFloat? = nil
    ) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        var size = desc.pointSize
        if let maxSize = maxSize, size > maxSize { size = maxSize }
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        return metrics.scaledFont(for: font)
    }
}

extension UIView {
    /// Добавляет несколько subview на текущее представление.
    /// - Parameter views: Произвольное количество UIView для добавления.
    /// - Note: Выполняется последовательное добавление через forEach
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}

extension UIDevice {
    /// Возвращает true, если текущее устройство - iPad
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    /// Возвращает true, если текущее устройство - iPhone
    static var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}

extension Int {
    /// Возвращает строковое представление числа с разделителями тысяч.
    /// - Example: 1000000 → "1 000 000".
    /// - Note: Использует пробел в качестве разделителя..
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}

extension Array where Element == Property {
    /// Вычисляет суммарную стоимость всех элементов массива.
    /// - Returns: Сумма значений `price` для всех элементов коллекции.
    /// - Note: Элементы массива должны иметь свойство `price` типа Int.
    var totalValue: Int {
        reduce(0) { $0 + $1.price }
    }
}

extension UIViewController {
    var top: UIViewController? {
        if let presented = presentedViewController {
            return presented.top
        }

        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.top
        }

        return self
    }
}
