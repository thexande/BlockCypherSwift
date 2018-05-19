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
