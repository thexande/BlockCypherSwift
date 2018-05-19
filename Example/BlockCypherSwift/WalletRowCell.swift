import UIKit
import Anchorage
import BlockCypherSwift

extension WalletType {
    public var icon: UIImage {
        switch self {
        case .bitcoin: return #imageLiteral(resourceName: "btc")
        case .litecoin: return #imageLiteral(resourceName: "litecoin")
        case .dash: return #imageLiteral(resourceName: "dash")
        case .dogecoin: return #imageLiteral(resourceName: "dogecoin")
        }
    }
    
    public var color: UIColor {
        switch self {
        case .bitcoin: return UIColor(red:0.97, green:0.58, blue:0.10, alpha:1.0)
        case .litecoin: return UIColor.gray
        case .dogecoin: return UIColor(red:0.76, green:0.65, blue:0.20, alpha:1.0)
        case .dash: return UIColor(red:0.22, green:0.45, blue:0.71, alpha:1.0)
        }
    }
}

final class WalletRowCell: UITableViewCell, WalletRowItemPropertiesUpdating {
    private let icon = UIImageView()
    private let title = UILabel()
    private let address = UILabel()
    private let holding = UILabel()
    private let spent = UILabel()
    
    public var properties: WalletRowProperties = .default {
        didSet {
            update(properties)
        }
    }
    
    func update(_ properties: WalletRowProperties) {
        title.text = properties.name
        address.text = properties.address
        holding.text = properties.holdings
        holding.textColor = properties.walletType.color
        spent.text = properties.spent
        spent.textColor = properties.walletType.color
        icon.image = properties.walletType.icon
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stackLabels = [title, address, holding, spent]
        stackLabels.forEach { label in label.numberOfLines = 0 }
        
        let labelStack = UIStackView(arrangedSubviews: stackLabels)
        labelStack.axis = .vertical
        labelStack.spacing = 6
        
        contentView.addSubview(labelStack)
        contentView.addSubview(icon)
        
        labelStack.verticalAnchors == contentView.verticalAnchors + 6
        labelStack.trailingAnchor == contentView.trailingAnchor - 12
        labelStack.leadingAnchor == icon.trailingAnchor + 12
        
        icon.sizeAnchors == CGSize(width: 56, height: 56)
        icon.centerYAnchor == contentView.centerYAnchor
        icon.leadingAnchor == contentView.leadingAnchor + 12
        
        title.font = UIFont.systemFont(ofSize: 20)
        address.font = UIFont.systemFont(ofSize: 12)
        address.textColor = .gray
        
        holding.font = UIFont.systemFont(ofSize: 16)
        
        spent.font = UIFont.systemFont(ofSize: 16)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
