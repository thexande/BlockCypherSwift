import Result
import BlockCypherSwift
import Hydra

final class WalletsPresenter: WalletActionDispatching {
    weak var dispatcher: WalletActionDispatching?
    var deliver: ((LoadableProps<WalletsViewProperties>) -> Void)?
    private var walletService: WalletService
    
    var loaableProperties: LoadableProps<WalletsViewProperties> = .loading {
        didSet {
            deliver?(loaableProperties)
        }
    }
    
    private var dataProperties: WalletsViewProperties = .default {
        didSet {
            loaableProperties = .data(dataProperties)
        }
    }
    
    init(walletService: WalletService) {
        self.walletService = walletService
    }
    
    func dispatch(walletAction: WalletAction) {
        switch walletAction {
        case .displayDefaultWallets: dataProperties = WalletsViewProperties(title: "Example Wallets", sections: DummyData.sections, displayLoading: false)
        case .reloadWallets:
            dataProperties.displayLoading = true
            reloadCurrentWallets()
        default: dispatcher?.dispatch(walletAction: walletAction)
        }
    }
    
    private func recieveWallets(_ wallets: [CryptoWallet]) {
        let currencies = Set(wallets.map { $0.currency })
        let sections: [[CryptoWallet]] = currencies.map { currency in
            return wallets.filter({ $0.currency == currency })
        }
        
        let sectionProps: [WalletsSectionProperties] = sections.map { section in
            let rowItems = section.map { cryptoWallet in
                return Wallet.walletItemViewProperties(
                    cryptoWallet.wallet,
                    walletCurrency: cryptoWallet.currency
                )
            }
            
            return WalletsSectionProperties(
                items: rowItems,
                title: section.first?.currency.rawValue.uppercased() ?? ""
            )
        }
        
        dataProperties = WalletsViewProperties(title: "Example Wallets", sections: sectionProps, displayLoading: false)
    }
    
    
    
    private func reloadCurrentWallets() {
        let walletProps: [(String, WalletCurrency)] = dataProperties.sections.flatMap { section in
            return section.items.compactMap { ($0.address, $0.walletType) }
        }
        
        all(walletProps.map({ walletService.wallet(address: $0.0, type: $0.1) })).then { [weak self] wallets in
            let cryptoWallets = wallets
                .enumerated()
                .map { CryptoWallet(wallet: $0.element, currency: walletProps[$0.offset].1) }
            self?.recieveWallets(cryptoWallets)
        }
    }
}
