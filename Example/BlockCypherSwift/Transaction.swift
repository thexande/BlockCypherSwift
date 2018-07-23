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
    
    static func map(_ transaction: Transaction) -> TransactionDetailViewProperties {
        var timingItems: [MetadataTitleRowItemProperties] = []
        
        return TransactionDetailViewProperties(
            title: "Details",
            transactionItemProperties: Transaction.map(transaction),
            sections: [
                MetadataTitleSectionProperties(displayStyle: .metadata, title: "Transaction Metadata", items: [
                    MetadataTitleRowItemProperties(title: "Hash", content: transaction.hash),
                    MetadataTitleRowItemProperties(title: "Amount", content: transaction.total.satoshiToReadableBtc()),
                    MetadataTitleRowItemProperties(title: "Block Index", content: "58"),
                    MetadataTitleRowItemProperties(title: "Block Height", content: "19823129038"),
                    MetadataTitleRowItemProperties(title: "Confirmations", content: "123"),
                    MetadataTitleRowItemProperties(title: "Relayed By", content: transaction.relayed_by ?? ""),
                    ]
                ),
                MetadataTitleSectionProperties(displayStyle: .metadata, title: "Timing", items: [
                    MetadataTitleRowItemProperties(title: "Received", content: transaction.received.transactionFormatString()),
                    MetadataTitleRowItemProperties(title: "Confirmed", content: transaction.confirmed.transactionFormatString()),
                    ]
                )
            ]
        )
    }
}


extension Int {
    func satoshiToReadableBtc() -> String {
        return "\(self.satoshiToBtc.toString(numberOfDecimalPlaces: 8)) BTC"
    }
}
