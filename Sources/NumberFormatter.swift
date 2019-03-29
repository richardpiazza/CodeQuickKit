import Foundation

public enum NumberFormat {
    case integer
    case singleDecimal
    case decimal
    case currency
    case percent
    
    public var numberStyle: NumberFormatter.Style {
        switch self {
        case .currency: return .currency
        case .percent: return .percent
        default: return .decimal
        }
    }
    
    public var minimumFractionDigits: Int {
        switch self {
        case .percent: return 1
        default: return 0
        }
    }
    
    public var maximumFractionDigits: Int {
        switch self {
        case .integer: return 0
        case .singleDecimal: return 1
        case .decimal, .currency: return 2
        case .percent: return 4
        }
    }
    
    public var locale: Locale {
        switch self {
        default: return Locale.current
        }
    }
}

public extension NumberFormatter {
    fileprivate struct common {
        static let integerFormatter = NumberFormatter(.integer)
        static let singleDecimalFormatter = NumberFormatter(.singleDecimal)
        static let decimalFormatter = NumberFormatter(.decimal)
        static let currencyFormatter = NumberFormatter(.currency)
        static let percentFormatter = NumberFormatter(.percent)
    }
    
    convenience init(_ format: NumberFormat) {
        self.init()
        numberStyle = format.numberStyle
        locale = format.locale
        minimumFractionDigits = format.minimumFractionDigits
        maximumFractionDigits = format.maximumFractionDigits
    }
    
    /// An NumberFormatter for whole integers.
    /// Uses the NumberFormatterDecimalStyle with MaximumFractionDigits set to
    /// 0 (zero).
    static func integerFormatter() -> NumberFormatter {
        return common.integerFormatter
    }
    
    static func integer(fromString string: String) -> Int? {
        return common.integerFormatter.number(from: string)?.intValue
    }
    
    static func string(fromInteger number: Int) -> String? {
        return common.integerFormatter.string(from: NSNumber(value: number))
    }
    
    /// An NumberFormatter for whole integers.
    /// Uses the NumberFormatterDecimalStyle with MaximumFractionDigits set to
    /// 1 (one).
    static func singleDecimalFormatter() -> NumberFormatter {
        return common.singleDecimalFormatter
    }
    
    static func singleDecimal(fromString string: String) -> Double? {
        return common.singleDecimalFormatter.number(from: string)?.doubleValue
    }
    
    static func string(fromSingleDecimal number: Double) -> String? {
        return common.singleDecimalFormatter.string(from: NSNumber(value: number))
    }
    
    /// An NumberFormatter for whole integers.
    /// Uses the NumberFormatterDecimalStyle with MaximumFractionDigits set to
    /// 2 (two).
    static func decimalFormatter() -> NumberFormatter {
        return common.decimalFormatter
    }
    
    static func decimal(fromString string: String) -> Double? {
        return common.decimalFormatter.number(from: string)?.doubleValue
    }
    
    static func string(fromDecimal number: Double) -> String? {
        return common.decimalFormatter.string(from: NSNumber(value: number))
    }
    
    /// An NumberFormatter for whole integers.
    /// Uses the NumberFormatterCurrencyStyle.
    static func currencyFormatter() -> NumberFormatter {
        return common.currencyFormatter
    }
    
    static func currency(fromString string: String) -> Double? {
        return common.currencyFormatter.number(from: string)?.doubleValue
    }
    
    static func string(fromCurrency number: Double) -> String? {
        return common.currencyFormatter.string(from: NSNumber(value: number))
    }
    
    /// An NumberFormatter for whole integers.
    /// Uses the NumberFormatterPercentStyle with MinimumFractionDigits set to
    /// 1 (one) and MaximumFractionDigits set to 3 (three).
    static func percentFormatter() -> NumberFormatter {
        return common.percentFormatter
    }
    
    static func percent(fromString string: String) -> Double? {
        return common.percentFormatter.number(from: string)?.doubleValue
    }
    
    static func string(fromPercent number: Double) -> String? {
        return common.percentFormatter.string(from: NSNumber(value: number))
    }
}
