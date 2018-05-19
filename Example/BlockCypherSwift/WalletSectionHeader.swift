import UIKit
import Anchorage

final class WalletSectionHeader: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        self.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
