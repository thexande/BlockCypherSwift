import UIKit
import Anchorage

final class WalletDetailShowMoreResultsFooterView: UIView {
    let button = PrimaryButton()
    weak var dispatcher: WalletDetailActionDispatching?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(button)
        button.edgeAnchors == edgeAnchors + UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        button.setTitle("Show More Transactions", for: .normal)
        button.addTarget(self, action: #selector(showMoreTransactions), for: .touchUpInside)
    }
    
    @objc private func showMoreTransactions() {
        dispatcher?.dispatch(.showMoreTransactions)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
