import BlockCypherSwift

extension Wallet {
    static func walletItemViewProperties(_ wallet: Wallet, walletCurrency: WalletCurrency) -> WalletRowProperties {
        return WalletRowProperties(
            name: wallet.address,
            address: wallet.address,
            holdings: wallet.finalBalanceBtc,
            spent: wallet.totalSentBtc,
            walletType: .bitcoin
        )
    }
    
    static func recentWalletDetailViewProperties(_ wallet: Wallet) -> WalletDetailViewProperties {
        let headerProperties = WalletDetailHeaderViewProperties(
            balance: wallet.finalBalanceBtc.btcPostfix,
            received: wallet.totalReceivedBtc.btcPostfix,
            send: wallet.totalSentBtc.btcPostfix,
            address: wallet.address,
            title: ""
        )
        
        let monthSections = DateFormatter().monthSymbols.compactMap { month -> WalletDetailSectionProperties? in
            let transactions = wallet.txs
                .sorted(by: { $0.confirmed > $1.confirmed })
                .filter { $0.confirmed.monthAsString() == month }
            
            guard transactions.count > 0 else {
                return nil
            }
            
            let total = transactions
                .map({ $0.total })
                .reduce(0, +)
                .satoshiToBtc
                .toString(numberOfDecimalPlaces: 8)
                .btcPostfix
            
            return WalletDetailSectionProperties(
                title: month,
                sub: "Transaction Total: \(total)",
                items: transactions.map(Transaction.map)
            )
        }
        
        return WalletDetailViewProperties(
            title: "New Wallet",
            headerProperties: headerProperties,
            sections: monthSections,
            identifier: wallet.address,
            showNavLoader: true
        )
    }
    
    static func largestWalletDetailViewProperties(_ wallet: Wallet) -> WalletDetailViewProperties {
        let headerProperties = WalletDetailHeaderViewProperties(
            balance: wallet.finalBalanceBtc.btcPostfix,
            received: wallet.totalReceivedBtc.btcPostfix,
            send: wallet.totalSentBtc.btcPostfix,
            address: wallet.address,
            title: ""
        )
        
        let largestSection = WalletDetailSectionProperties(
            title: "Largest Transactions",
            items: wallet.txs
                .sorted(by: { $0.total > $1.total })
                .map(Transaction.map)
        )
        
        return WalletDetailViewProperties(
            title: "New Wallet",
            headerProperties: headerProperties,
            sections: [largestSection],
            identifier: wallet.address,
            showNavLoader: false
        )
    }
}
