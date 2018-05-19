public struct Output: Codable {
    let value: Int
    let script: String
    let addresses: [String]
    let script_type: String
    let spent_by: String?
    let data_hex: String?
    let data_string: String?
}
