public struct Wallet: Codable {
    public let address: String
    public let total_received: Int
    public let total_sent: Int
    public let balance: Int
    public let unconfirmed_balance: Int
    public let final_balance: Int
    public let n_tx: Int
    public let unconfirmed_n_tx: Int
    public let final_n_tx: Int
    public let txs: [Transaction]
}

extension Wallet {
    public var totalReceivedBtc: String {
        return String(total_received.satoshiToBtc.toString(numberOfDecimalPlaces: 8))
    }
    
    public var totalSentBtc: String {
        return String(total_sent.satoshiToBtc.toString(numberOfDecimalPlaces: 8))
    }
    
    public var finalBalanceBtc: String {
        return String(final_balance.satoshiToBtc.toString(numberOfDecimalPlaces: 8))
    }
}
