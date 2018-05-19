public struct Wallet: Codable {
    let address: String
    let total_received: Int
    let total_sent: Int
    let balance: Int
    let unconfirmed_balance: Int
    let final_balance: Int
    let n_tx: Int
    let unconfirmed_n_tx: Int
    let final_n_tx: Int
    let txs: [Transaction]
}
