import UIKit
import Anchorage
import BlockCypherSwift

protocol ViewPropertiesUpdating {
    associatedtype ViewProperties
    var properties: ViewProperties { get set }
    func render(_ properties: ViewProperties)
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
        showNavLoader: true
    )
}

protocol WalletDetailPropertiesUpdating: ViewPropertiesUpdating where ViewProperties == LoadableProps<WalletDetailViewProperties> { }

final class WalletDetailController: SectionProxyTableViewController {
    private let header = WalletDetailHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 172))
    private let footer = WalletDetailShowMoreResultsFooterView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80))
    private let segment = UISegmentedControl(items: [ "Recent", "Largest"])
    private let loading = TableLoadingView()
    private let refresh = UIRefreshControl()
    public var properties: WalletDetailViewProperties = .default
    
    public weak var dispatcher: WalletDetailActionDispatching? {
        didSet {
            header.dispatcher = dispatcher
            footer.dispatcher = dispatcher
        }
    }
    
    func render(_ properties: LoadableProps<WalletDetailViewProperties>) {
        switch properties {
        case .loading:
            DispatchQueue.main.async {
                self.tableView.backgroundView?.isHidden = false
                self.tableView.tableHeaderView?.isHidden = true
                self.tableView.bringSubview(toFront: self.loading)
                self.tableView.tableHeaderView = UIView()
                self.tableView.tableFooterView = UIView()
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
        let controllers = new.sections.map(TransactionTableSectionController.init)
        
        DispatchQueue.main.async {
            controllers.forEach {
                $0.registerReusableTypes(tableView: self.tableView)
                $0.dispatcher = self.dispatcher
            }
            
            self.sections = controllers
            
            self.header.properties = new.headerProperties
            self.title = new.title
            self.tableView.reloadData()
            
            self.tableView.tableHeaderView?.isHidden = false
            self.tableView.backgroundView?.isHidden = true
            self.tableView.sendSubview(toBack: self.loading)
            self.tableView.tableHeaderView = self.header
            self.tableView.tableFooterView = self.footer
            
            if !new.showNavLoader {
                self.refresh.endRefreshing()
            }
        }
    }
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.backgroundView = self.loading
        
        tableView.refreshControl = refresh
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        segment.addTarget(self, action: #selector(didChangeSegmentedControl), for: .valueChanged)
        segment.selectedSegmentIndex = 0
        navigationItem.titleView = segment
    }
    
    @objc func refreshData() {
        dispatcher?.dispatch(.reloadWallet(properties.identifier, .bitcoin))
    }
    
    @objc func didChangeSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: dispatcher?.dispatch(.sortWalletDetail(.recent))
        case 1: dispatcher?.dispatch(.sortWalletDetail(.largest))
        default: return
        }
    }
    
    @objc func pressedSave() {
        dispatcher?.dispatch(.walletNameSelectAlert)
    }
}
