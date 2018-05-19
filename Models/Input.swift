struct Input: Codable {
    let prev_hash: String
    let output_index: Int
    let output_value: Int
    let script_type: String
    let script: String
    let addresses: [String]
    let sequence: Int
    let age: Int
    let wallet_name: String?
    let wallet_token: String?
}
