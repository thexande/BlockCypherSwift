public struct Transaction: Codable {
    let block_hash: String
    let block_height: Int
    let block_index: Int
    let hash: String
    let addresses: [String]
    let total: Int
    let fees: Int
    let size: Int
    let preference: String
    let relayed_by: String?
    let confirmed: Date
    let received: String
    let ver: Int
    let double_spend: Bool
    let vin_sz: Int
    let vout_sz: Int
    let confirmations: Int
    let confidence: Int
    let inputs: [Input]
    let outputs: [Output]
}
