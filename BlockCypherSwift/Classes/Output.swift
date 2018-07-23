public struct Output: Codable {
    public let addresses: [String]
    public let value: Int
    public let script: String
    public let script_type: String
    public let spent_by: String?
    public let data_hex: String?
    public let data_tring: String?
}
