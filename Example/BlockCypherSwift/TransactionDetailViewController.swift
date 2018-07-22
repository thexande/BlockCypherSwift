import UIKit
import Anchorage

protocol WalletTableSectionController: UITableViewDelegate, UITableViewDataSource {
    var dispatcher: WalletActionDispatching? { get set }
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
    weak var dispatcher: WalletActionDispatching?
    override var sections: [WalletTableSectionController] {
        didSet {
            sections.forEach { $0.registerReusableTypes(tableView: tableView) }
            tableView.reloadData()
        }
    }
    
    var properties: LoadableProps<TransactionDetailViewProperties> = .loading {
        didSet {
            render(properties)
        }
    }
    
    func render(_ properties: LoadableProps<TransactionDetailViewProperties>) {
        switch properties {
        case .data(let properties):
            title = properties.title
            let metadataSections = MetadataTableSectionFactory.mapControllerFromSections(properties.sections, dispatcher: dispatcher)
            let transactionController = TransactionTableSectionController()
            transactionController.properties = [properties.transactionItemProperties]
            
            var sectionControllers: [WalletTableSectionController] = []
            sectionControllers.append(transactionController)
            sectionControllers.append(contentsOf: metadataSections)
            
            sections = sectionControllers
            tableView.reloadData()
        case .error(let error): return
        case .loading: return
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
