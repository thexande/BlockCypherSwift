import BlockCypherSwift

enum WalletDetailAcitons {
    enum WalletDetailSortOrder {
        case recent
        case largest
    }
    case sortWalletDetail(WalletDetailSortOrder)
    case showMoreTransactions
    case reloadWallet(String, WalletCurrency)
    case selectedTransaction(String)
    case displayWalletQR(String, String)
    case copyWalletAddressToClipboard(String)
    case selectedTransactionSegment(String)
    case walletNameSelectAlert

}

protocol WalletDetailActionDispatching: AnyObject {
    func dispatch(_ action: WalletDetailAcitons)
}

final class WalletDetailPresenter: WalletDetailActionDispatching {
    weak var dispatcher: WalletActionDispatching?
    private let walletService = WalletService(session: URLSession.shared)
    var wallet: Wallet?
    var deliver: ((LoadableProps<WalletDetailViewProperties>) -> Void)?
    
    var properties: LoadableProps<WalletDetailViewProperties> = .loading {
        didSet {
            deliver?(properties)
        }
    }
    
    private var dataProperties: WalletDetailViewProperties = .default {
        didSet {
            properties = .data(dataProperties)
        }
    }
    
    var cryptoWallet: (String, WalletCurrency)? {
        didSet {
            if let wallet = cryptoWallet {
                properties = .loading
                reloadWallet(walletAddress: wallet.0, walletType: wallet.1)
            }
        }
    }
    
    private func reloadWallet(walletAddress: String, walletType: WalletCurrency) {
        dataProperties.showNavLoader = true
        walletService.wallet(address: walletAddress,
                             currency: walletType) { [weak self] walletResult in
            switch walletResult {
            case .success(let wallet):
                let walletProps = Wallet.recentWalletDetailViewProperties(wallet)
                self?.wallet = wallet
                self?.dataProperties = walletProps
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    self?.dataProperties.showNavLoader = false
                })
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func dispatch(_ action: WalletDetailAcitons) {
        switch action {
        case .sortWalletDetail(let sortOrder):
            switch sortOrder {
            case .largest:
                if let wallet = wallet {
                    self.properties = .data(Wallet.largestWalletDetailViewProperties(wallet))
                }
            case .recent:
                if let wallet = wallet {
                    self.properties = .data(Wallet.recentWalletDetailViewProperties(wallet))
                }
            }
        case .reloadWallet(let wallet, let type): return
            reloadWallet(walletAddress: wallet,
                         walletType: type)
        case .showMoreTransactions: return
        default: return //dispatcher?.dispatch(action)
        }
    }
}
