import Result
import BlockCypherSwift

final class TransactionDetailPresenter: WalletActionDispatching {
    var deliver: ((LoadableProps<TransactionDetailViewProperties>) -> Void)?
    
    var transaction: Transaction? {
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
    
    func dispatch(_ action: WalletAction) {
        switch action {
        case .reloadTransaction(let transactionHash): return
        default: return
        }
    }
}
