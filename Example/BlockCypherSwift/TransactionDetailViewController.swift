import UIKit
import Anchorage
import BlockCypherSwift

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
    
    init(title: String,
         transactionItemProperties: TransactionRowItemProperties,
         sections: [MetadataSectionProperties]) {
        self.title = title
        self.transactionItemProperties = transactionItemProperties
        self.sections = sections
    }
    
    init(_ transaction: Transaction) {
        var metadataItems: [MetadataTitleRowItemProperties] = []
        
        metadataItems.append(contentsOf: 
            [
                MetadataTitleRowItemProperties(title: "Hash", content: transaction.hash),
                MetadataTitleRowItemProperties(title: "Amount", content: transaction.total.satoshiToReadableBtc()),
                MetadataTitleRowItemProperties(title: "Block Index", content: String(transaction.block_index)),
                MetadataTitleRowItemProperties(title: "Block Height", content: String(transaction.block_height)),
                MetadataTitleRowItemProperties(title: "Confirmations", content: String(transaction.confirmations)),
                MetadataTitleRowItemProperties(title: "Double Spend", content: String(transaction.double_spend))
            ]
        )
        
        let timingItems: [MetadataTitleRowItemProperties] = [
            MetadataTitleRowItemProperties(title: "Received", content: transaction.received.transactionFormatString()),
            MetadataTitleRowItemProperties(title: "Confirmed", content: transaction.confirmed.transactionFormatString()),
        ]
        
        if let relayed = transaction.relayed_by {
            metadataItems.append(MetadataTitleRowItemProperties(title: "Relayed By", content: relayed))
        }
        
        let addressItems: [MetadataAddressRowItemProperties] = transaction.addresses.map { address in
            return MetadataAddressRowItemProperties(address: address)
        }
        
        let inputItems: [MetadataTransactionSegmentRowItemProperties] = transaction.inputs.map { input in
            return MetadataTransactionSegmentRowItemProperties(address: input.script)
        }
        
        let outputItems: [MetadataTransactionSegmentRowItemProperties] = transaction.outputs.map { output in
            return MetadataTransactionSegmentRowItemProperties(address: output.script)
        }
            
        self.title = "Details"
        self.transactionItemProperties = Transaction.map(transaction)
        self.sections = [
            MetadataTitleSectionProperties(displayStyle: .metadata, title: "Metadata", items: metadataItems),
            MetadataTitleSectionProperties(displayStyle: .metadata, title: "Timing", items: timingItems),
            MetadataAddressSectionProperties(displayStyle: .metadata, title: "Addresses", items: addressItems),
            MetadataTransactionSegmentSectionProperties(displayStyle: .transactionSegment, title: "Inputs", items: inputItems),
            MetadataTransactionSegmentSectionProperties(displayStyle: .transactionSegment, title: "Outputs", items: outputItems),
        ]
    }
}

protocol TransactionDetailViewPropertiesUpdating: ViewPropertiesUpdating where ViewProperties == LoadableProps<TransactionDetailViewProperties> { }

final class TransactionDetailViewController: SectionProxyTableViewController, TransactionDetailViewPropertiesUpdating {
    private let loading = TableLoadingView()
    weak var dispatcher: WalletDetailActionDispatching?
    var properties: TransactionDetailViewProperties = .default
    
    override var sections: [WalletTableSectionController] {
        didSet {
            self.sections.forEach { $0.registerReusableTypes(tableView: self.tableView) }
        }
    }
    
    func render(_ properties: LoadableProps<TransactionDetailViewProperties>) {
        switch properties {
        case .data(let properties):
            DispatchQueue.main.async {
                self.update(from: self.properties, to: properties)
            }
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
