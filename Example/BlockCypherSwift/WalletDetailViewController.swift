import UIKit
import Anchorage
import BlockCypherSwift

protocol ViewPropertiesUpdating {
    associatedtype ViewProperties
    var properties: ViewProperties { get set }
    func update(_ properties: ViewProperties)
}

struct WalletDetailSectionProperties {
    let title: String
    let items: [TransactionRowItemProperties]
    static let `default` = WalletDetailSectionProperties(title: "", items: [])
    
    static func map(_ properties: WalletDetailSectionProperties) -> TransactionTableSectionController {
        let controller = TransactionTableSectionController()
        controller.properties = properties.items
        controller.sectionTitle = properties.title
        return controller
    }
    
//    static func sort(
//                    _ properties: WalletDetailSectionProperties,
//                    sortOrder: WalletAction.WalletDetailSortOrder) -> WalletDetailSectionProperties {
//        switch sortOrder {
//        case .largest:
//            return WalletDetailSectionProperties(
//                title: properties.title,
//                items: properties.items.sort { }
//            )
//        case .recent:
//        }
//    }
}

struct WalletDetailViewProperties {
    let title: String
    let headerProperties: WalletDetailHeaderViewProperties
    let sections: [WalletDetailSectionProperties]
    static let `default` = WalletDetailViewProperties(title: "", headerProperties: WalletDetailHeaderViewProperties(balance: "", received: "", send: "", address: "", title: ""), sections: [])
}

struct WalletDetailHeaderViewProperties {
    let balance: String
    let received: String
    let send: String
    let address: String
    let title: String
    static let `default` = WalletDetailHeaderViewProperties(balance: "", received: "", send: "", address: "", title: "")
}

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
    static let `default` = TransactionRowItemProperties(transactionHash: "", transactionType: .sent, title: "", subTitle: "", confirmationCount: "", isConfirmed: false)
}

protocol WalletDetailPropertiesUpdating: ViewPropertiesUpdating where ViewProperties == LoadableProps<WalletDetailViewProperties> { }

final class WalletDetailController: SectionProxyTableViewController, WalletDetailPropertiesUpdating {
    private let header = WalletDetailHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 172))
    private let segment = UISegmentedControl(items: [ "Recent", "Largest"])
    private let loading = TableLoadingView()
    
    public weak var dispatcher: WalletActionDispatching? {
        didSet {
            header.dispatcher = dispatcher
        }
    }
    
    public var properties: LoadableProps<WalletDetailViewProperties> = .loading {
        didSet {
            update(properties)
        }
    }
    
    func update(_ properties: LoadableProps<WalletDetailViewProperties>) {
        switch properties {
        case .loading:
            DispatchQueue.main.async {
                self.tableView.backgroundView = self.loading
                self.tableView.backgroundView?.isHidden = false
                self.tableView.tableHeaderView?.isHidden = true
            }
        case .data(let properties):
            sections = []
            let controllers = properties.sections.map(WalletDetailSectionProperties.map)
            sections = controllers
            
            DispatchQueue.main.async {
                controllers.forEach {
                    $0.dispatcher = self.dispatcher
                    $0.registerReusableTypes(tableView: self.tableView)
                }
                
                self.header.properties = properties.headerProperties
                self.title = properties.title
                self.tableView.tableHeaderView?.isHidden = false
                self.tableView.backgroundView?.isHidden = true
                self.tableView.reloadData()
            }
            
        case .error(let error):
            return
        }
    }
    
    init() {
        super.init(style: .grouped)
        segment.addTarget(self, action: #selector(didChangeSegmentedControl), for: .valueChanged)
        segment.selectedSegmentIndex = 0
        navigationItem.titleView = segment
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        tableView.tableHeaderView = header
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        tableView.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    @objc func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.refreshControl?.endRefreshing()
        }
    }
    
    @objc func didChangeSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: dispatcher?.dispatch(walletAction: .sortWalletDetail(.recent))
        case 1: dispatcher?.dispatch(walletAction: .sortWalletDetail(.largest))
        default: return
        }
    }
    
    @objc func pressedSave() {
        dispatcher?.dispatch(walletAction: .walletNameSelectAlert)
    }
}



final class WalletDetailPresenter: WalletActionDispatching {
    weak var dispatcher: WalletActionDispatching?
    var wallet: Wallet?
    var deliver: ((LoadableProps<WalletDetailViewProperties>) -> Void)?
    
    var properties: LoadableProps<WalletDetailViewProperties> = .loading {
        didSet {
            deliver?(properties)
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
        default: dispatcher?.dispatch(walletAction: walletAction)
        }
    }
}
