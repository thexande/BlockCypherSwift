import BlockCypherSwift

final class WalletDetailPresenter: WalletActionDispatching {
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
                reloadWallet(walletAddress: wallet.0, walletType: wallet.1)
            }
        }
    }
    
    private func reloadWallet(walletAddress: String, walletType: WalletCurrency) {
        dataProperties.showNavLoader = true
        
        walletService.wallet(address: walletAddress, currency: walletType) { [weak self] walletResult in
            switch walletResult {
            case .success(let wallet):
                let walletProps = Wallet.recentWalletDetailViewProperties(wallet)
                self?.wallet = wallet
                self?.dataProperties = walletProps
                self?.dataProperties.showNavLoader = false
                
                if let props = self?.dataProperties {
                    self?.properties = .data(props)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func dispatch(walletAction: WalletAction) {
        switch walletAction {
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
        case .reloadWallet(let wallet, let type): reloadWallet(walletAddress: wallet, walletType: type)
        default: dispatcher?.dispatch(walletAction: walletAction)
        }
    }
}
