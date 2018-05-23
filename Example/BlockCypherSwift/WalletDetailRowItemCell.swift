import UIKit
import Anchorage

struct TransactionRowItemProperties {
    enum WalletDetailRowType {
        case sent
        case recieved
    }
    
    let transactionHash: String
    let transactionType: WalletDetailRowType
    let title: String
    let subTitle: String
    let confirmationCount: String
    let isConfirmed: Bool
    let identifier: String
    static let `default` = TransactionRowItemProperties(transactionHash: "", transactionType: .sent, title: "", subTitle: "", confirmationCount: "", isConfirmed: false, identifier: "")
}

protocol TransactionRowViewPropertiesUpdating: ViewPropertiesUpdating where ViewProperties == TransactionRowItemProperties { }

final class TransactionRowItemCell: UITableViewCell, TransactionRowViewPropertiesUpdating {
    private let title = UILabel()
    private let subTitle = UILabel()
    private let transactionIcon = UIImageView()
    private let transactionBackground = UIView()
    private let lockIcon = UIImageView()
    private let confirmationCount = UILabel()
    
    public var properties: TransactionRowItemProperties = .default {
        didSet {
            update(properties)
        }
    }
    
    func update(_ properties: TransactionRowItemProperties) {
        title.text = properties.title
        subTitle.text = properties.subTitle
        confirmationCount.text = properties.confirmationCount
        
        switch properties.transactionType {
        case .recieved:
            transactionBackground.backgroundColor = StyleConstants.primaryGreen
            transactionIcon.image = #imageLiteral(resourceName: "down_arrow")
        case.sent:
            transactionBackground.backgroundColor = StyleConstants.primaryRed
            transactionIcon.image = #imageLiteral(resourceName: "up_arrow")
        }
        
        lockIcon.tintColor = (properties.isConfirmed ? StyleConstants.primaryGreen : StyleConstants.primaryRed)
    }
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(transactionBackground)
        transactionBackground.sizeAnchors == CGSize(width: 36, height: 36)
        transactionBackground.backgroundColor = StyleConstants.primaryGreen
        transactionBackground.layer.cornerRadius = 18
        transactionBackground.leadingAnchor == contentView.leadingAnchor + 12
        transactionBackground.centerYAnchor == contentView.centerYAnchor
        transactionBackground.addSubview(transactionIcon)
        
        transactionIcon.image = #imageLiteral(resourceName: "up_arrow")
        transactionIcon.contentMode = .scaleAspectFit
        let inset: CGFloat = 8
        transactionIcon.edgeAnchors == transactionBackground.edgeAnchors + UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        
        let stack = UIStackView(arrangedSubviews: [title, subTitle])
        stack.axis = .vertical
        stack.spacing = 6
        contentView.addSubview(stack)
        stack.leadingAnchor == transactionBackground.trailingAnchor + 12
        stack.verticalAnchors == contentView.verticalAnchors + 8
        
        title.font = UIFont.systemFont(ofSize: 18)
        
        subTitle.font = UIFont.systemFont(ofSize: 16)
        subTitle.textColor = .gray
        
        let lock = #imageLiteral(resourceName: "lock")
        lockIcon.image = lock.withRenderingMode(.alwaysTemplate)
        contentView.addSubview(lockIcon)
        lockIcon.sizeAnchors == CGSize(width: 32, height: 32)
        lockIcon.trailingAnchor == contentView.trailingAnchor - 12
        lockIcon.centerYAnchor == contentView.centerYAnchor
        
        contentView.addSubview(confirmationCount)
        confirmationCount.textColor = .white
        confirmationCount.textAlignment = .center
        confirmationCount.font = UIFont.systemFont(ofSize: 13)
        confirmationCount.centerXAnchor == lockIcon.centerXAnchor
        confirmationCount.centerYAnchor == lockIcon.centerYAnchor + 6
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

