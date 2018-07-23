import BlockCypherSwift

extension Transaction {
    static func map(_ transaction: Transaction) -> TransactionRowItemProperties {
        return TransactionRowItemProperties(
            transactionHash: transaction.hash,
            transactionType: .recieved,
            title: transaction.transactionTotal.btcPostfix,
            subTitle: transaction.confirmed.transactionFormatString(),
            confirmationCount: String(transaction.confirmationCountMaxSixPlus),
            isConfirmed: transaction.isConfirmed,
            identifier: transaction.hash
        )
    }
}


extension Int {
    func satoshiToReadableBtc() -> String {
        return "\(self.satoshiToBtc.toString(numberOfDecimalPlaces: 8)) BTC"
    }
}
