import UIKit

final class TransactionSegmentViewController: SectionProxyTableViewController, ViewPropertiesUpdating {
    typealias ViewProperties = TransactionSegmentViewProperties
    public var dispatcher: WalletActionDispatching?
    public var properties: TransactionSegmentViewProperties = .default {
        didSet {
            update(properties)
        }
    }
    
    override var sections: [WalletTableSectionController] {
        didSet {
            sections.forEach { $0.registerReusableTypes(tableView: tableView) }
            tableView.reloadData()
        }
    }
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ properties: TransactionSegmentViewProperties) {
        title = properties.title
        let metadataSections = MetadataTableSectionHelper.mapControllerFromSections(properties.sections, dispatcher: dispatcher)
        sections = metadataSections
        tableView.reloadData()
    }
}
