import UIKit
import Result

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
    fileprivate let factory = WalletControllerFactory()
    fileprivate let navigationController = UINavigationController(rootViewController: UIViewController())
    fileprivate let walletViewController = WalletsViewController()
    fileprivate let walletDetailViewController = WalletDetailController()
    fileprivate let transactionDetailViewController = TransactionDetailViewController()
    fileprivate let transactionSegmentDetailViewController = TransactionSegmentViewController()
    fileprivate let qrDisplayViewController = QRDispalyViewController()
    fileprivate let     scannerViewController = ScannerViewController()
    fileprivate let walletTypeAlertController = UIAlertController(title: "Wallet Type", message: "Select your Wallet type.", preferredStyle: .actionSheet)
    fileprivate let walletNameAlertController = UIAlertController(title: "Wallet Name", message: "Select a name for your new wallet, or input a custom name.", preferredStyle: .actionSheet)
    
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
    fileprivate func handleCopyWalletAddressToClipboard(walletAddress: String) {
        let alert = UIAlertController.confirmationAlert(
            confirmationTitle: "Coppied.",
            confirmationMessage: "Wallet address \(walletAddress) has been coppied to your clipboard."
        )
        navigation?.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func handleQRResult(walletAddress: String, walletType: WalletType?) {
        guard let walletType = walletType else { return }
        WalletService.fetchWallet(walletAddress: walletAddress, walletType: walletType) { [weak self] walletResult in
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

struct Wallet: Codable {
    let address: String
    let total_received: Int
    let total_sent: Int
    let balance: Int
    let unconfirmed_balance: Int
    let final_balance: Int
    let n_tx: Int
    let unconfirmed_n_tx: Int
    let final_n_tx: Int
    let txs: [Transaction]
    
    var totalReceived: String {
        return String(total_received)
    }
    
    static func viewProperties(_ wallet: Wallet) -> WalletDetailViewProperties {
        let headerProperties = WalletDetailHeaderViewProperties(
            balance: "",
            received: wallet.totalReceived,
            send: "",
            address: "",
            title: ""
        )
        
        return .default
        
        //        return WalletDetailViewProperties(
        //            title: "New Wallet",
        //            headerProperties: headerProperties,
        //            items: wallet.txs.map(Transaction.viewPropertyItem(_:))
        //        )
    }
}

struct Transaction: Codable {
    let block_hash: String
    let block_height: Int
    let block_index: Int
    let hash: String
    let addresses: [String]
    let total: Int
    let fees: Int
    let size: Int
    let preference: String
    let relayed_by: String?
    let confirmed: Date
    let received: String
    let ver: Int
    let double_spend: Bool
    let vin_sz: Int
    let vout_sz: Int
    let confirmations: Int
    let confidence: Int
    let inputs: [Input]
    let outputs: [Output]
    
    static func map(_ transaction: Transaction) -> TransactionRowItemProperties {
        
        return TransactionRowItemProperties(
            transactionHash: transaction.hash,
            transactionType: .recieved,
            title: "sent",
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

struct Input: Codable {
    let prev_hash: String
    let output_index: Int
    let output_value: Int
    let script_type: String
    let script: String
    let addresses: [String]
    let sequence: Int
    let age: Int
    let wallet_name: String?
    let wallet_token: String?
}

struct Output: Codable {
    let value: Int
    let script: String
    let addresses: [String]
    let script_type: String
    let spent_by: String?
    let data_hex: String?
    let data_string: String?
}



