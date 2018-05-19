import UIKit

final class MetadataTableSectionHelper {
    static func mapControllerFromSections(_ sections: [MetadataSectionProperties], dispatcher: WalletActionDispatching?) -> [WalletTableSectionController] {
        return sections.flatMap { section -> WalletTableSectionController? in
            if let properties = section as? MetadataAddressSectionProperties {
                guard let items = properties.items as? [MetadataAddressRowItemProperties] else { return nil }
                let controller = MetadataAddressTableSectionController.mapControllerFromProperties(items)
                controller.dispatcher = dispatcher
                controller.sectionTitle = properties.title
                return controller
            } else if let properties = section as? MetadataTitleSectionProperties {
                guard let items = properties.items as? [MetadataTitleRowItemProperties] else { return nil }
                let controller = MetadataTitleTableSectionController.mapControllerFromProperties(items)
                controller.dispatcher = dispatcher
                controller.sectionTitle = properties.title
                return controller
            } else if let properties = section as? MetadataTransactionSegmentSectionProperties {
                guard let items = properties.items as? [MetadataTransactionSegmentRowItemProperties] else { return nil }
                let controller = MetadataTransactionSegmentTableSectionController()
                controller.dispatcher = dispatcher
                controller.properties = items
                controller.sectionTitle = properties.title
                return controller
            }
            else {
                return nil
            }
        }
    }
}

final class MetadataAddressTableSectionController: NSObject, WalletTableSectionController {
    public var dispatcher: WalletActionDispatching?
    public var properties: [MetadataAddressRowItemProperties] = []
    var sectionTitle: String?
    
    func registerReusableTypes(tableView: UITableView) {
        tableView.register(MetadataAddressRowItemCell.self, forCellReuseIdentifier: String(describing: MetadataAddressRowItemCell.self))
        tableView.register(WalletSectionHeader.self, forHeaderFooterViewReuseIdentifier: String(describing: WalletSectionHeader.self))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MetadataAddressRowItemCell.self)) as? MetadataAddressRowItemCell else {
            return UITableViewCell()
        }
        cell.address = properties[indexPath.row].address
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: WalletSectionHeader.self)) as? WalletSectionHeader else {
            return UIView()
        }
        header.textLabel?.text = sectionTitle
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dispatcher?.dispatch(walletAction: .selectedTransactionSegment(properties[indexPath.row].address))
    }
    
    static func mapControllerFromProperties(_ properties: [MetadataAddressRowItemProperties]) -> MetadataAddressTableSectionController {
        let controller = MetadataAddressTableSectionController()
        controller.properties = properties
        return controller
    }
}

final class MetadataTitleTableSectionController: NSObject, WalletTableSectionController {
    public var dispatcher: WalletActionDispatching?
    public var properties: [MetadataTitleRowItemProperties] = []
    var sectionTitle: String?
    
    func registerReusableTypes(tableView: UITableView) {
        tableView.register(MetadataTitleRowItemCell.self, forCellReuseIdentifier: String(describing: MetadataTitleRowItemCell.self))
        tableView.register(WalletSectionHeader.self, forHeaderFooterViewReuseIdentifier: String(describing: WalletSectionHeader.self))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MetadataTitleRowItemCell.self)) as? MetadataTitleRowItemCell else {
            return UITableViewCell()
        }
        cell.properties = properties[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: WalletSectionHeader.self)) as? WalletSectionHeader else {
            return UIView()
        }
        header.textLabel?.text = sectionTitle
        return header
    }
    
    static func mapControllerFromProperties(_ properties: [MetadataTitleRowItemProperties]) -> MetadataTitleTableSectionController {
        let controller = MetadataTitleTableSectionController()
        controller.properties = properties
        return controller
    }
}


final class MetadataTransactionSegmentTableSectionController: NSObject, WalletTableSectionController {
    public var dispatcher: WalletActionDispatching?
    public var properties: [MetadataTransactionSegmentRowItemProperties] = []
    var sectionTitle: String?
    
    func registerReusableTypes(tableView: UITableView) {
        tableView.register(MetadataTransactionSegmentRowItemCell.self, forCellReuseIdentifier: String(describing: MetadataTransactionSegmentRowItemCell.self))
        tableView.register(WalletSectionHeader.self, forHeaderFooterViewReuseIdentifier: String(describing: WalletSectionHeader.self))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MetadataTransactionSegmentRowItemCell.self)) as? MetadataTransactionSegmentRowItemCell else {
            return UITableViewCell()
        }
        cell.address = properties[indexPath.row].address
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: WalletSectionHeader.self)) as? WalletSectionHeader else {
            return UIView()
        }
        header.textLabel?.text = sectionTitle
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dispatcher?.dispatch(walletAction: .selectedTransactionSegment(properties[indexPath.row].address))
    }
    
    static func mapControllerFromProperties(_ properties: [MetadataTitleRowItemProperties]) -> MetadataTitleTableSectionController {
        let controller = MetadataTitleTableSectionController()
        controller.properties = properties
        return controller
    }
}

