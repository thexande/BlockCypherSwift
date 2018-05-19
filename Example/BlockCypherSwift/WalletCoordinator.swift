import UIKit
import Result
import BlockCypherSwift

enum WalletAction {
    case reloadWallets
    case reloadWallet(String)
    case selectedWallet(String)
    case reloadTransaction(String)
    case selectedTransaction(String)
    case reloadTransactionSegment(String)
    case selectedTransactionSegment(String)
    case walletTypeSelectAlert
    case walletNameSelectAlert
    case displayWalletQR(String, String)
    case scanQR(WalletType)
    case deliverQRResult(String, WalletType?)
    case copyWalletAddressToClipboard(String)
}

enum WalletDescription {
    case coinbase
    case exodusWallet
    case coldStorage
    case ledgerNano
    case trezor
    
    public var title: String {
        switch self {
        case .coinbase: return "Coinbase"
        case .exodusWallet: return "Exodus"
        case .coldStorage: return "Cold Storage"
        case .ledgerNano: return "Ledger Nano"
        case .trezor: return "Trezor"
        }
    }
    
    static let props: [WalletDescription] = [.coinbase, .exodusWallet, .coldStorage, .ledgerNano, .trezor]
}

struct TransactionSegmentViewProperties {
    let title: String
    let sections: [MetadataSectionProperties]
    static let `default` = TransactionSegmentViewProperties(title: "", sections: [])
}

enum WalletRoute {
    case walletDetail(WalletDetailViewProperties)
    case transactionDetail(TransactionDetailViewProperties)
    case transactionSegmentDetail(TransactionSegmentViewProperties)
    case wallets(WalletsViewProperties)
    case qrCodeDisplay(String, String)
    case walletTypeSelectAlert
    case walletNameSelectAlert
    case scanQRCode
}

protocol WalletActionDispatching: class {
    func dispatch(walletAction: WalletAction)
}

protocol WalletRoutable {
    func handleRoute(route: WalletRoute)
    weak var navigation: UINavigationController? { get }
}


final class WalletCoordinator: WalletActionDispatching {
    private let factory = WalletControllerFactory()
    private let walletService = WalletService()
    private let navigationController = UINavigationController(rootViewController: UIViewController())
    private let walletViewController = WalletsViewController()
    private let walletDetailViewController = WalletDetailController()
    private let transactionDetailViewController = TransactionDetailViewController()
    private let transactionSegmentDetailViewController = TransactionSegmentViewController()
    private let qrDisplayViewController = QRDispalyViewController()
    private let     scannerViewController = ScannerViewController()
    private let walletTypeAlertController = UIAlertController(title: "Wallet Type", message: "Select your Wallet type.", preferredStyle: .actionSheet)
    private let walletNameAlertController = UIAlertController(title: "Wallet Name", message: "Select a name for your new wallet, or input a custom name.", preferredStyle: .actionSheet)
    
    public var rootViewController: UIViewController {
        return self.navigationController
    }
    
    deinit {
        
    }
    init() {
        self.navigationController.viewControllers = [walletViewController]
        walletViewController.dispatcher = self
        walletDetailViewController.dispatcher = self
        transactionDetailViewController.dispatcher = self
        factory.dispatcher = self
        
        scannerViewController.success = { [weak self] address, walletType in
            self?.dispatch(walletAction: .deliverQRResult(address, walletType))
        }
        
        let walletTypes: [WalletType] = [.bitcoin, .litecoin, .dash, .dogecoin]
        
        factory.addWalletSelectAlertActions(walletTypeAlertController, walletTypes: walletTypes)
        factory.addWalletNameAlertActions(walletNameAlertController, walletDescriptions: WalletDescription.props)
        //
        //        let attributes = [
        //            NSAttributedStringKey.foregroundColor : UIColor.white
        //        ]
        //
        //        navigation?.navigationBar.largeTitleTextAttributes = attributes
        //
        //        var navigationBarAppearace = UINavigationBar.appearance()
        //        navigationBarAppearace.tintColor = .white
        //        navigationBarAppearace.barTintColor = WalletType.litecoin.color
        //        // change navigation item title color
        //        navigationBarAppearace.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        //        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        //
    }
    
    func dispatch(walletAction: WalletAction) {
        switch walletAction {
        case .reloadWallets: return
        case .reloadWallet(let walletAddress): return
        case .selectedWallet(let walletAddress):
            handleRoute(route: .walletDetail(DummyData.detailProperties))
            
        case .reloadTransaction(let transactionHash): return
        case .selectedTransaction(let transactionHash):
            handleRoute(route: .transactionDetail(DummyData.transacctionDetailProps))
            
        case .reloadTransactionSegment(let transactionSegmentAddress): return
        case .selectedTransactionSegment(let transactionSegmentAddress):
            handleRoute(route: .transactionSegmentDetail(TransactionSegmentViewProperties(title: "segment detail", sections: DummyData.transacctionDetailProps.sections)))
            
            
        case .displayWalletQR(let walletAddress, let walletTitle):
            handleRoute(route: .qrCodeDisplay(walletAddress, walletTitle))
            
        case .scanQR(let walletType):
            scannerViewController.walletType = walletType
            handleRoute(route: .scanQRCode)
            
        case .deliverQRResult(let walletAddress, let walletType):
            handleQRResult(walletAddress: walletAddress, walletType: walletType)
            
        case .walletTypeSelectAlert:
            handleRoute(route: .walletTypeSelectAlert)
            
        case .copyWalletAddressToClipboard(let walletAddress):
            handleCopyWalletAddressToClipboard(walletAddress: walletAddress)
            
        case .walletNameSelectAlert:
            handleRoute(route: .walletNameSelectAlert)
        }
    }
}

/// Coordinator Action Handling Extension
extension WalletCoordinator {
    private func handleCopyWalletAddressToClipboard(walletAddress: String) {
        let alert = UIAlertController.confirmationAlert(
            confirmationTitle: "Coppied.",
            confirmationMessage: "Wallet address \(walletAddress) has been coppied to your clipboard."
        )
        navigation?.present(alert, animated: true, completion: nil)
    }
    
    private func handleQRResult(walletAddress: String, walletType: WalletType?) {
        guard let walletType = walletType else { return }
        walletService.fetchWallet(walletAddress: walletAddress, walletType: walletType) { [weak self] walletResult in
            switch walletResult {
            case .success(let wallet):
                print(wallet)
                let properties = Wallet.viewProperties(wallet)
                self?.walletDetailViewController.properties = properties
                self?.handleRoute(route: .walletDetail(properties))
                
                
            case .failure(let error):
                print(error.localizedDescription)
                let alertController = UIAlertController.confirmationAlert(
                    confirmationTitle: "Sorry.",
                    confirmationMessage: String(
                        format: "We could not find a wallet with that address on the %@ blockchain.",
                        walletType.rawValue.capitalized
                    )
                )
                DispatchQueue.main.async {
                    self?.navigation?.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

extension WalletCoordinator: WalletRoutable {
    var navigation: UINavigationController? {
        get {
            return self.navigationController
        }
    }
    
    func handleRoute(route: WalletRoute) {
        switch route {
        case .walletDetail(let properties):
            walletDetailViewController.properties = properties
            DispatchQueue.main.async { [weak self] in
                guard let controller = self?.walletDetailViewController else { return }
                self?.navigation?.pushViewController(controller, animated: true)
            }
        case .wallets(let properties):
            walletViewController.properties = properties
            navigation?.pushViewController(walletViewController, animated: true)
        case .transactionDetail(let properties):
            transactionDetailViewController.properties = properties
            navigation?.pushViewController(transactionDetailViewController, animated: true)
        case .transactionSegmentDetail(let properties):
            transactionSegmentDetailViewController.properties = properties
            navigation?.pushViewController(transactionSegmentDetailViewController, animated: true)
        case .qrCodeDisplay(let walletAddress, let walletTitle):
            qrDisplayViewController.address = walletAddress
            qrDisplayViewController.title = walletTitle
            navigation?.present(UINavigationController(rootViewController: qrDisplayViewController), animated: true, completion: nil)
        case .walletTypeSelectAlert:
            navigation?.present(walletTypeAlertController, animated: true, completion: nil)
        case .scanQRCode:
            navigation?.present(scannerViewController, animated: true, completion: nil)
        case .walletNameSelectAlert:
            navigation?.present(walletNameAlertController, animated: true, completion: nil)
        }
    }
}

extension Wallet {
  
    
    static func viewProperties(_ wallet: Wallet) -> WalletDetailViewProperties {
        let headerProperties = WalletDetailHeaderViewProperties(
            balance: "",
            received: wallet.totalReceived,
            send: wallet.totalSent,
            address: wallet.address,
            title: ""
        )
        
        return WalletDetailViewProperties(
            title: "New Wallet",
            headerProperties: headerProperties,
            sections: [WalletDetailSectionProperties(title: "Transactions", items: wallet.txs.map(Transaction.map))]
        )
    }
}

extension Transaction {
    static func map(_ transaction: Transaction) -> TransactionRowItemProperties {
        
        return TransactionRowItemProperties(
            transactionHash: transaction.hash,
            transactionType: .recieved,
            title: "Sent \(transaction.transactionTotal)",
            subTitle: transaction.confirmed.transactionFormatString(),
            confirmationCount: String(transaction.confirmations)
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
                ),
                ]
        )
    }
}


