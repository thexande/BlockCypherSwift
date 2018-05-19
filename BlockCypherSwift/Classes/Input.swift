public struct Input: Codable {
    public let prev_hash: String
    public let output_index: Int
    public let output_value: Int
    public let script_type: String
    public let script: String
    public let addresses: [String]
    public let sequence: Int
    public let age: Int
    public let wallet_name: String?
    public let wallet_token: String?
}
