public struct Transaction: Codable {
    public let block_hash: String
    public let block_height: Int
    public let block_index: Int
    public let hash: String
    public let addresses: [String]
    public let total: Int
    public let fees: Int
    public let size: Int
    public let preference: String
    public let relayed_by: String?
    public let confirmed: Date
    public let received: String
    public let ver: Int
    public let double_spend: Bool
    public let vin_sz: Int
    public let vout_sz: Int
    public let confirmations: Int
    public let confidence: Int
    public let inputs: [Input]
    public let outputs: [Output]
}

// Computed transaction details
extension Transaction {
    public var transactionTotal: String {
        return String(total.satoshiToBtc.toString(numberOfDecimalPlaces: 8))
    }
    
    public var confirmationCountMaxSixPlus: String {
        return isConfirmed ? "6+" : String(confirmations)
    }
    
    public var isConfirmed: Bool {
        return confirmations > 6
    }
}

extension Double {
    func toString(numberOfDecimalPlaces:Int) -> String {
        return String(format:"%."+numberOfDecimalPlaces.description+"f", self)
    }
}

extension Int {
    var satoshiToBtc: Double {
        return Double(self) * 0.00000001
    }
}
