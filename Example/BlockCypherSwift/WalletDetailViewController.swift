import UIKit
import Anchorage
import BlockCypherSwift

protocol ViewPropertiesUpdating {
    associatedtype ViewProperties
    var properties: ViewProperties { get set }
    func update(_ properties: ViewProperties)
}

struct WalletDetailSectionProperties: Equatable {
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

struct WalletDetailViewProperties: Equatable {
    let title: String
    var headerProperties: WalletDetailHeaderViewProperties
    let sections: [WalletDetailSectionProperties]
    let identifier: String
    var showNavLoader: Bool
    static let `default` = WalletDetailViewProperties(
        title: "",
        headerProperties: .default,
        sections: [],
        identifier: "",
        showNavLoader: false
    )
}

//protocol WalletDetailPropertiesUpdating: ViewPropertiesUpdating where ViewProperties == LoadableProps<WalletDetailViewProperties> { }

final class WalletDetailController: SectionProxyTableViewController {
    private let header = WalletDetailHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 172))
    private let segment = UISegmentedControl(items: [ "Recent", "Largest"])
    private let loading = TableLoadingView()
    private let refresh = UIRefreshControl()
    public var properties: WalletDetailViewProperties = .default
    
    public weak var dispatcher: WalletActionDispatching? {
        didSet {
            header.dispatcher = dispatcher
        }
    }
    
    func render(_ properties: LoadableProps<WalletDetailViewProperties>) {
        switch properties {
        case .loading:
            DispatchQueue.main.async {
                self.tableView.backgroundView = self.loading
                self.tableView.backgroundView?.isHidden = false
                self.tableView.tableHeaderView?.isHidden = true
            }
        case .data(let properties): update(from: self.properties, to: properties)
        case .error(let error): return
        }
    }
    
    func update(from old: WalletDetailViewProperties,
                to new: WalletDetailViewProperties) {
        
        guard old != new else {
            return
        }
        
        self.properties = new
        
        sections = []
        let controllers = new.sections.map(WalletDetailSectionProperties.map)
        
        DispatchQueue.main.async {
            controllers.forEach {
                $0.registerReusableTypes(tableView: self.tableView)
                $0.dispatcher = self.dispatcher
            }
            
            self.sections = controllers
            
            self.header.properties = new.headerProperties
            self.title = new.title
            self.tableView.tableHeaderView?.isHidden = false
            self.tableView.backgroundView?.isHidden = true
            self.tableView.reloadData()
            
            switch new.showNavLoader {
            case true: self.refresh.beginRefreshing()
            case false: self.refresh.endRefreshing()
            }
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
        dispatcher?.dispatch(walletAction: .reloadWallet(properties.identifier, .bitcoin))
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
