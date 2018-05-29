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
        return TransactionDetailViewProperties(
            title: "detail",
            transactionItemProperties: Transaction.map(transaction),
            sections: [
                MetadataTitleSectionProperties(displayStyle: .metadata, title: "Transaction Metadata", items: [
                    MetadataTitleRowItemProperties(title: "Hash", content: transaction.hash),
                    MetadataTitleRowItemProperties(title: "Block Index", content: "58"),
                    MetadataTitleRowItemProperties(title: "Block Height", content: "19823129038"),
                    MetadataTitleRowItemProperties(title: "Confirmations", content: "123"),
                    ]
                )
            ]
        )
    }
}
