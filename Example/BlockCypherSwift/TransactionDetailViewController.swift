import UIKit
import Anchorage

protocol WalletTableSectionController: UITableViewDelegate, UITableViewDataSource {
    var dispatcher: WalletDetailActionDispatching? { get set }
    var sectionTitle: String? { get }
    func registerReusableTypes(tableView: UITableView)
}

protocol WalletCollectionSectionController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func registerReusableTypes(collectionView: UICollectionView)
}

enum MetadataRowDisplayStyle {
    case metadata
    case address
    case transactionSegment
}

/// Metadata Table row item view properties
protocol MetadataRowItemProperties {
    //    static var `default`: Self { get }
}

struct MetadataTitleRowItemProperties: MetadataRowItemProperties {
    let title: String
    let content: String
    static let `default` = MetadataTitleRowItemProperties(title: "", content: "")
}

struct MetadataAddressRowItemProperties: MetadataRowItemProperties {
    let address: String
    static let `default` = MetadataAddressRowItemProperties(address: "")
}

struct MetadataTransactionSegmentRowItemProperties: MetadataRowItemProperties {
    let address: String
    static let `default` = MetadataTransactionSegmentRowItemProperties(address: "")
}


/// Metadata Table row item view properties
protocol MetadataSectionProperties {
    var displayStyle: MetadataRowDisplayStyle { get }
    var title: String { get }
    var items: [MetadataRowItemProperties] { get }
}

struct MetadataTitleSectionProperties: MetadataSectionProperties {
    let displayStyle: MetadataRowDisplayStyle
    let title: String
    let items: [MetadataRowItemProperties]
    static let `default` = MetadataTitleSectionProperties(displayStyle: .address, title: "", items: [])
}

struct MetadataAddressSectionProperties: MetadataSectionProperties {
    var displayStyle: MetadataRowDisplayStyle
    let title: String
    var items: [MetadataRowItemProperties]
    static let `default` = MetadataAddressSectionProperties(displayStyle: .address, title: "", items: [])
}

struct MetadataTransactionSegmentSectionProperties: MetadataSectionProperties {
    let displayStyle: MetadataRowDisplayStyle
    let title: String
    var items: [MetadataRowItemProperties]
    static let `default` = MetadataTransactionSegmentSectionProperties(displayStyle: .transactionSegment, title: "", items: [])
}

struct TransactionDetailViewProperties {
    let title: String
    let transactionItemProperties: TransactionRowItemProperties
    let sections: [MetadataSectionProperties]
    static let `default` = TransactionDetailViewProperties(title: "", transactionItemProperties: .default, sections: [])
}

protocol TransactionDetailViewPropertiesUpdating: ViewPropertiesUpdating where ViewProperties == LoadableProps<TransactionDetailViewProperties> { }

final class TransactionDetailViewController: SectionProxyTableViewController, TransactionDetailViewPropertiesUpdating {
    private let loading = TableLoadingView()
    weak var dispatcher: WalletDetailActionDispatching?
    var properties: TransactionDetailViewProperties = .default
    
    override var sections: [WalletTableSectionController] {
        didSet {
            sections.forEach { $0.registerReusableTypes(tableView: tableView) }
            tableView.reloadData()
        }
    }
    
    func render(_ properties: LoadableProps<TransactionDetailViewProperties>) {
        switch properties {
        case .data(let properties):
            update(from: properties, to: properties)
        case .error(let error): return
        case .loading:
            DispatchQueue.main.async {
                self.tableView.backgroundView?.isHidden = false
                self.tableView.tableHeaderView?.isHidden = true
                self.tableView.bringSubview(toFront: self.loading)
                self.tableView.tableHeaderView = UIView()
                self.tableView.tableFooterView = UIView()
            }
        }
    }
    
    func update(from old: TransactionDetailViewProperties,
                to new: TransactionDetailViewProperties) {
        
//        guard old != new else {
//            return
//        }
//
        self.properties = new
        
        sections = []
        title = new.title
        let metadataSections = MetadataTableSectionFactory.mapControllerFromSections(properties.sections, dispatcher: dispatcher)
        let transactionController = TransactionTableSectionController()
        transactionController.properties = [properties.transactionItemProperties]
        
        var sectionControllers: [WalletTableSectionController] = []
        sectionControllers.append(transactionController)
        sectionControllers.append(contentsOf: metadataSections)
        
        sections = sectionControllers
        tableView.reloadData()
        self.tableView.sendSubview(toBack: self.loading)
    }
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    @objc func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.refreshControl?.endRefreshing()
        }
    }
}
