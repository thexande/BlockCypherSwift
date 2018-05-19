public struct Output: Codable {
    public let value: Int
    public let script: String
    public let addresses: [String]
    public let script_type: String
    public let spent_by: String?
    public let data_hex: String?
    public let data_string: String?
}
