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
