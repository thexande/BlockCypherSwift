import Result
import BlockCypherSwift

final class TransactionDetailPresenter: WalletActionDispatching {
    var deliver: ((LoadableProps<TransactionDetailViewProperties>) -> Void)?
    let walletService = WalletService(session: URLSession.shared)
    
    private var transaction: Transaction? {
        didSet {
            if let transaction = transaction {
                properties = .data(Transaction.map(transaction))
            }
        }
    }
    
    var properties: LoadableProps<TransactionDetailViewProperties> = .loading {
        didSet {
            deliver?(properties)
        }
    }
    
    func loadTransaction(hash: String, currency: WalletCurrency) {
        walletService.transaction(hash: hash, currency: currency) { result in
            switch result {
            case let .success(transaction):
                self.transaction = transaction
            case let .failure(error): return
            }
        }
    }
    
    func dispatch(_ action: WalletAction) {
        switch action {
        case .reloadTransaction(let transactionHash): return
        default: return
        }
    }
}
