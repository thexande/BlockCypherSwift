import UIKit
import BlockCypherSwift

protocol WalletFactory {
    func makeWalletSelectorAlertController() -> UIAlertController
    func makeWalletSelectorAction(_ walletType: WalletCurrency) -> UIAlertAction
    func addWalletSelectAlertActions(_ controller: UIAlertController, walletTypes: [WalletCurrency])
}

final class WalletControllerFactory: WalletFactory {
    public weak var dispatcher: WalletActionDispatching?
    
    func makeWalletSelectorAlertController() -> UIAlertController {
        let controller = UIAlertController(title: "Wallet Type", message: "Select your Wallet type.", preferredStyle: .actionSheet)
        let walletTypes: [WalletCurrency] = [.bitcoin, .litecoin, .dash, .dogecoin]
        return controller
    }
    
    func addWalletSelectAlertActions(_ controller: UIAlertController, walletTypes: [WalletCurrency]) {
        var actions: [UIAlertAction] = walletTypes.map(self.makeWalletSelectorAction(_:))
        actions.append(.cancel())
        
        actions.forEach { action in
            controller.addAction(action)
        }
    }
    
    func addWalletNameAlertActions(_ controller: UIAlertController, walletDescriptions: [WalletDescription]) {
        var actions: [UIAlertAction] = walletDescriptions.map(self.makeWalletNameSelectorAction(_:))
        actions.append(.cancel())
        
        actions.forEach { action in
            controller.addAction(action)
        }
    }
    
    func makeWalletSelectorAction(_ walletType: WalletCurrency) -> UIAlertAction {
        return UIAlertAction(title: walletType.rawValue.capitalized, style: .default, handler: { [weak self] _ in
            self?.dispatcher?.dispatch(walletAction: .scanQR(walletType))
        })
    }
    
    func makeWalletNameSelectorAction(_ walletName: WalletDescription) -> UIAlertAction {
        return UIAlertAction(title: walletName.title, style: .default, handler: { [weak self] _ in
            //            self?.dispatch(walletAction: .scanQR(walletType))
        })
    }
}

