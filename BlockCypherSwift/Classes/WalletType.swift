public enum WalletType: String {
    case bitcoin
    case litecoin
    case dogecoin
    case dash
    
    public var symbol: String {
        switch self {
        case .bitcoin: return "BTC"
        case .litecoin: return "LTC"
        case .dogecoin: return "DOGE"
        case .dash: return "DASH"
        }
    }
}
