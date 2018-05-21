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
    let sub: String?
    let items: [TransactionRowItemProperties]
    static let `default` = WalletDetailSectionProperties(title: "", items: [])
    
    init(title: String, sub: String? = nil, items: [TransactionRowItemProperties]) {
        self.title = title
        self.sub = sub
        self.items = items
    }
    
    static func map(_ properties: WalletDetailSectionProperties) -> TransactionTableSectionController {
        let controller = TransactionTableSectionController()
        controller.properties = properties.items
        controller.sectionTitle = properties.title
        controller.sectionSubtitle = properties.sub
        return controller
    }
}

struct WalletDetailViewProperties {
    let title: String
    var headerProperties: WalletDetailHeaderViewProperties
    let sections: [WalletDetailSectionProperties]
    let identifier: String
    var showNavLoader: Bool
    static let `default` = WalletDetailViewProperties(title: "", headerProperties: .default, sections: [], identifier: "", showNavLoader: false)
}

struct WalletDetailHeaderViewProperties {
    let balance: String
    let received: String
    let send: String
    let address: String
    let title: String
    var backgroundImage: UIImage?
    static let `default` = WalletDetailHeaderViewProperties(balance: "", received: "", send: "", address: "", title: "", backgroundImage: UIImage())
    
    init(balance: String, received: String, send: String, address: String, title: String, backgroundImage: UIImage? = nil) {
        self.balance = balance
        self.received = received
        self.send = send
        self.address = address
        self.title = title
        self.backgroundImage = backgroundImage
    }
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
    private let refresh = UIRefreshControl()
    
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
                
                switch properties.showNavLoader {
                case true: self.refresh.beginRefreshing()
                case false: self.refresh.endRefreshing()
                }
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
        
        tableView.refreshControl = refresh
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    @objc func refreshData() {
        switch properties {
        case .data(let props): dispatcher?.dispatch(walletAction: .reloadWallet(props.identifier, .bitcoin))
        default: return
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
