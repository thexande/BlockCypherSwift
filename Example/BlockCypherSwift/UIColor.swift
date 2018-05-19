import UIKit

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
    convenience init(cryptoSymbol: String) {
        switch cryptoSymbol {
        case "BTC": self.init(hex: "E9973D")
        case "ETH": self.init(hex: "343535")
        case "XRP": self.init(hex: "4499CF")
        case "LTC": self.init(hex: "BEBEBE")
        case "BCH": self.init(hex: "E9973D")
        case "NEO": self.init(hex: "86BA46")
        case "ADA": self.init(hex: "6E99F7")
        case "XLM": self.init(hex: "607273")
        default: self.init(hex: "000000")
        }
    }
}
